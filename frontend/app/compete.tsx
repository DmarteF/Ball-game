import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Alert, Dimensions, Modal, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { DualArenaView } from '@/src/components/DualArenaView';
import { NeonButton } from '@/src/components/NeonButton';
import { useGame } from '@/src/contexts/GameContext';
import { buyArenaUpgrade, createArenaState, DualArenaState, getArenaProgress, getArenaUpgradeCost, tickArenaPhysics } from '@/src/game/dualArena';
import { RewardGrant, describeReward } from '@/src/game/retention';
import { getSkinById } from '@/src/game/skins';
import { playSound } from '@/src/utils/audio';

const { width } = Dimensions.get('window');
const ARENA_SIZE = Math.min(width - 42, 214);

type Result = { won: boolean; trophiesDelta: number; newPosition: number; rewards: RewardGrant[] };

export default function CompeteScreen() {
  const router = useRouter();
  const game = useGame();
  const match = useMemo(() => game.createLeagueMatch(), []);
  const playerSkin = getSkinById(game.ballTransformation);
  const rivalSkin = getSkinById(match.rival.favoriteSkin);
  const [playerArena, setPlayerArena] = useState<DualArenaState | null>(null);
  const [rivalArena, setRivalArena] = useState<DualArenaState | null>(null);
  const [paused, setPaused] = useState(false);
  const [result, setResult] = useState<Result | null>(null);
  const finishing = useRef(false);
  const playerArenaRef = useRef<DualArenaState | null>(null);

  const rivalRank = useMemo(() => {
    const position = game.getLeagueStandings().findIndex(item => item.id === match.rival.id) + 1;
    if (position > 0 && position <= 3) return 'top3';
    if (position > 0 && position <= 10) return 'top10';
    if (match.rival.trophies > game.getLeaguePlayer().trophies + 700) return 'strong';
    if (match.rival.trophies > game.getLeaguePlayer().trophies + 120) return 'medium';
    return 'weak';
  }, [match.rival.id]);

  const solidCount = rivalRank === 'top3' ? 6 : rivalRank === 'top10' ? 5 : rivalRank === 'strong' ? 3 : rivalRank === 'medium' ? 2 : 1;
  const basePhase = rivalRank === 'top3' ? 22 : rivalRank === 'top10' ? 18 : rivalRank === 'strong' ? 14 : rivalRank === 'medium' ? 9 : 6;

  const makeRingConfig = (side: 'player' | 'rival') => ({
    count: Math.max(10, Math.floor(match.map.rings * 0.62)),
    innerRadius: 24,
    outerRadius: ARENA_SIZE / 2 - 14,
    baseRotationSpeed: 0.012 * match.map.rotationMultiplier,
    baseHp: 24 * match.map.hpMultiplier * (side === 'rival' ? 1 + match.rival.level / 120 : 1),
    baseGapSize: 3.25 * match.map.gapMultiplier,
    baseThickness: 4,
    closingSpeed: 0.045 * match.map.closingMultiplier,
    colors: [side === 'rival' ? rivalSkin.primaryColor : playerSkin.primaryColor, match.map.color, '#ffffff88'],
    solidCount,
    solidHpMultiplier: rivalRank === 'top3' ? 1.9 : rivalRank === 'top10' ? 1.7 : rivalRank === 'strong' ? 1.5 : 1.35,
  });

  const startMatch = () => {
    setPlayerArena(createArenaState({
      id: 'player',
      name: game.nickname || 'Você',
      skinIcon: playerSkin.icon,
      skinColor: playerSkin.primaryColor,
      size: ARENA_SIZE,
      phase: basePhase,
      ringConfig: makeRingConfig('player'),
      speedMultiplier: 1 + game.stats.baseSpeed / 950,
      damageMultiplier: 1 + game.stats.baseDamage / 200,
    }));
    setRivalArena(createArenaState({
      id: 'rival',
      name: match.rival.name,
      skinIcon: rivalSkin.icon,
      skinColor: rivalSkin.primaryColor,
      size: ARENA_SIZE,
      phase: basePhase,
      ringConfig: makeRingConfig('rival'),
      aiQuality: rivalRank === 'top3' ? 0.95 : rivalRank === 'top10' ? 0.88 : rivalRank === 'strong' ? 0.76 : rivalRank === 'medium' ? 0.62 : 0.46,
      speedMultiplier: 1 + match.rival.level / 120,
      damageMultiplier: 1 + match.rival.trophies / 9000,
    }));
    finishing.current = false;
    setResult(null);
    setPaused(false);
    playSound('buttonConfirm', game.settings.sound);
  };

  useEffect(() => {
    startMatch();
  }, []);

  useEffect(() => {
    playerArenaRef.current = playerArena;
  }, [playerArena]);

  useEffect(() => {
    if (paused || result) return;
    const interval = setInterval(() => {
      setPlayerArena(current => current ? tickArenaPhysics(current, { damageMultiplier: 1 + game.stats.baseDamage / 240 }).state : current);
      setRivalArena(current => current ? tickArenaPhysics(current, {
        isAi: true,
        opponentProgress: playerArenaRef.current ? getArenaProgress(playerArenaRef.current) : 0,
        shrinkMultiplier: 1 + Math.min(0.18, match.rival.trophies / 50000),
        damageMultiplier: 1 + Math.min(0.9, match.rival.trophies / 11000),
      }).state : current);
    }, 34);
    return () => clearInterval(interval);
  }, [paused, !!result, playerArena?.id]);

  useEffect(() => {
    if (!playerArena || !rivalArena || finishing.current) return;
    if (!playerArena.finished && !rivalArena.finished && !playerArena.crushed && !rivalArena.crushed) return;
    const won = playerArena.finished || rivalArena.crushed;
    finishMatch(won);
  }, [playerArena?.finished, rivalArena?.finished, playerArena?.crushed, rivalArena?.crushed]);

  const finishMatch = async (won: boolean) => {
    if (finishing.current) return;
    finishing.current = true;
    const rewardRoll = Math.random();
    const baseCoins = Math.round((won ? 420 : 140) * match.map.rewardMultiplier);
    const baseXp = Math.round((won ? 160 : 55) * match.map.rewardMultiplier);
    const saved = await game.recordLeagueCompetitionResult({
      rivalId: match.rival.id,
      won,
      noRevive: true,
      coins: baseCoins,
      profileXp: baseXp,
      gems: won && rewardRoll > 0.68 ? 4 : undefined,
      keys: won && rewardRoll > 0.88 ? 1 : undefined,
      fragments: won && rewardRoll > 0.78 ? { skinId: match.rival.favoriteSkin, amount: 8 } : undefined,
      chest: won && rewardRoll > 0.93 ? { label: 'Baú Neon', icon: '🎁', rarity: 'rare' } : undefined,
    });
    setResult({ won, ...saved });
    playSound(won ? 'victory' : 'defeat', game.settings.sound);
  };

  const buy = (type: 'atk' | 'gold') => {
    if (!playerArena) return;
    const cost = getArenaUpgradeCost(playerArena, type);
    if (playerArena.coins < cost) {
      playSound('buttonError', game.settings.sound);
      return;
    }
    playSound('buttonConfirm', game.settings.sound);
    setPlayerArena(buyArenaUpgrade(playerArena, type));
  };

  const confirmExit = () => {
    playSound('buttonClick', game.settings.sound);
    Alert.alert('Sair da competição?', 'A partida atual será encerrada como derrota.', [
      { text: 'Cancelar', style: 'cancel', onPress: () => playSound('buttonClick', game.settings.sound) },
      { text: 'Sair', style: 'destructive', onPress: () => finishMatch(false) },
    ]);
  };

  return (
    <LinearGradient colors={['#08121d', '#1a0a2e', '#16003b']} style={styles.container}>
      {!playerArena || !rivalArena ? (
        <View style={styles.header}>
          <NeonButton title="← LIGA" variant="secondary" audioSettings={game.settings} onPress={() => router.replace('/league' as any)} style={styles.backButton} />
          <Text style={styles.title}>COMPETIR</Text>
          <Text style={styles.subtitle}>{match.map.theme} • {match.map.modifier} • {match.rival.trophies.toLocaleString('pt-BR')} troféus</Text>
        </View>
      ) : (
        <View style={styles.topHUD}>
          <View style={styles.hudRow}>
            <View style={styles.hudItem}><Text style={styles.hudIcon}>💰</Text><Text style={styles.hudValue}>{playerArena.coins}</Text></View>
            <View style={styles.hudItem}><Text style={styles.hudIcon}>⭐</Text><Text style={styles.hudValue}>Lv.{playerArena.level}</Text></View>
            <TouchableOpacity style={styles.pauseMiniButton} onPress={() => setPaused(value => !value)}>
              <Text style={styles.pauseMiniText}>{paused ? '▶' : '⏸'}</Text>
            </TouchableOpacity>
          </View>
          <View style={styles.levelRow}>
            <Text style={styles.levelText}>XP {playerArena.xp}</Text>
            <View style={styles.progressBar}>
              <LinearGradient colors={['#ff0055', '#ff8800', '#ffd700']} start={{ x: 0, y: 0 }} end={{ x: 1, y: 0 }} style={[styles.progressFill, { width: `${getArenaProgress(playerArena) * 100}%` }]} />
            </View>
          </View>
          <Text style={styles.progressText}>🌀 Anéis: {playerArena.rings.filter(ring => ring.status === 'active' && ring.hp > 0).length}/{playerArena.rings.length} {playerArena.combo >= 2 ? `• Combo x${playerArena.combo}` : ''}</Text>
        </View>
      )}

      {playerArena && rivalArena && (
        <View style={styles.arenas}>
          <DualArenaView arena={rivalArena} meta={`${match.rival.division} • ${rivalArena.coins} moedas`} accent="#ff4fd8" leader={getArenaProgress(rivalArena) > getArenaProgress(playerArena)} />
          <DualArenaView arena={playerArena} meta={`Moedas ${playerArena.coins} • XP ${playerArena.xp} • Lv.${playerArena.level}`} accent="#00f0ff" leader={getArenaProgress(playerArena) >= getArenaProgress(rivalArena)} />
          <View style={styles.shopRow}>
            {(['atk', 'gold'] as const).map(type => {
              const cost = getArenaUpgradeCost(playerArena, type);
              const canBuy = playerArena.coins >= cost;
              return (
                <TouchableOpacity key={type} style={[styles.runUpgradeButton, !canBuy && styles.disabled]} onPress={() => buy(type)}>
                  <Text style={styles.runUpgradeIcon}>{type === 'atk' ? '⚔️' : '💰'}</Text>
                  <Text style={styles.runUpgradeLabel}>{type === 'atk' ? 'ATK' : 'Gold'} Lv.{playerArena[type]}</Text>
                  <Text style={styles.runUpgradeCost}>{cost} 💰</Text>
                </TouchableOpacity>
              );
            })}
            <NeonButton title="SAIR" variant="danger" audioSettings={game.settings} onPress={confirmExit} />
          </View>
        </View>
      )}

      <Modal visible={!!result} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.resultBox}>
            <Text style={[styles.resultTitle, { color: result?.won ? '#00ff88' : '#ff4fd8' }]}>{result?.won ? 'VITÓRIA' : 'DERROTA'}</Text>
            <Text style={styles.resultText}>Resultado definido pela partida real contra {match.rival.name}</Text>
            <Text style={styles.trophyDelta}>{result?.trophiesDelta || 0} troféus</Text>
            <Text style={styles.resultText}>Nova posição: #{result?.newPosition}</Text>
            {result?.rewards.map(reward => <Text key={describeReward(reward)} style={styles.rewardLine}>{describeReward(reward)}</Text>)}
            <NeonButton title="COMPETIR NOVAMENTE" variant="primary" audioSettings={game.settings} onPress={startMatch} />
            <NeonButton title="VOLTAR PARA LIGA" variant="secondary" audioSettings={game.settings} onPress={() => router.replace('/league' as any)} />
            <NeonButton title="VOLTAR PARA HOME" variant="secondary" audioSettings={game.settings} onPress={() => router.replace('/' as any)} />
          </View>
        </View>
      </Modal>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 52, paddingHorizontal: 16, paddingBottom: 6 },
  topHUD: { paddingTop: 45, paddingHorizontal: 12, paddingBottom: 4 },
  hudRow: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 8, gap: 6 },
  hudItem: { flex: 1, flexDirection: 'row', backgroundColor: '#ffffff11', paddingVertical: 8, paddingHorizontal: 10, borderRadius: 10, borderWidth: 1, borderColor: '#ffffff22', alignItems: 'center', justifyContent: 'center', gap: 6 },
  hudIcon: { fontSize: 18 },
  hudValue: { fontSize: 16, fontWeight: 'bold', color: '#00f0ff' },
  pauseMiniButton: { width: 42, height: 38, borderRadius: 10, backgroundColor: '#ffffff18', borderWidth: 1, borderColor: '#ffffff33', alignItems: 'center', justifyContent: 'center' },
  pauseMiniText: { color: '#ffffff', fontSize: 18, fontWeight: 'bold' },
  levelRow: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#ffffff11', padding: 8, borderRadius: 10, borderWidth: 1, borderColor: '#ffffff22', marginBottom: 4, gap: 10 },
  levelText: { fontSize: 14, fontWeight: 'bold', color: '#ffd700' },
  progressText: { fontSize: 12, color: '#ffffff', marginBottom: 2, textAlign: 'center', fontWeight: 'bold' },
  progressBar: { flex: 1, height: 14, backgroundColor: '#ffffff11', borderRadius: 7, overflow: 'hidden', borderWidth: 1, borderColor: '#ffffff22' },
  progressFill: { height: '100%' },
  backButton: { alignSelf: 'flex-start', minWidth: 100 },
  title: { color: '#ffffff', fontSize: 28, fontWeight: 'bold', marginTop: 8 },
  subtitle: { color: '#ffffff99', fontWeight: 'bold', marginTop: 3 },
  arenas: { flex: 1, paddingHorizontal: 14, paddingBottom: 10, gap: 8, justifyContent: 'space-evenly' },
  shopRow: { width: '100%', flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  runUpgradeButton: {
    flexGrow: 1,
    flexBasis: 118,
    minHeight: 58,
    borderRadius: 12,
    backgroundColor: '#06162a',
    borderWidth: 1.5,
    borderColor: '#00f0ffaa',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 6,
    shadowColor: '#00f0ff',
    shadowOpacity: 0.35,
    shadowRadius: 8,
  },
  disabled: { opacity: 0.45 },
  runUpgradeIcon: { fontSize: 18 },
  runUpgradeLabel: { color: '#ffffff', fontSize: 11, fontWeight: 'bold', marginTop: 2 },
  runUpgradeCost: { color: '#ffd700', fontSize: 11, fontWeight: 'bold', marginTop: 2 },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', justifyContent: 'center', alignItems: 'center', padding: 18 },
  resultBox: { width: '100%', maxWidth: 390, backgroundColor: '#1a0a2e', borderWidth: 1, borderColor: '#00f0ff88', borderRadius: 18, padding: 18, gap: 10, alignItems: 'stretch' },
  resultTitle: { fontSize: 30, fontWeight: 'bold', textAlign: 'center' },
  resultText: { color: '#ffffff', fontWeight: 'bold', textAlign: 'center' },
  trophyDelta: { color: '#ffd700', fontSize: 24, fontWeight: 'bold', textAlign: 'center' },
  rewardLine: { color: '#00ff88', fontWeight: 'bold', textAlign: 'center' },
});

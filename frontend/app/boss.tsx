import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Alert, Dimensions, Modal, ScrollView, StyleSheet, Text, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { DualArenaView } from '@/src/components/DualArenaView';
import { NeonButton } from '@/src/components/NeonButton';
import { useGame } from '@/src/contexts/GameContext';
import { BOSS_DIFFICULTIES, BossDifficultyId, createBossPhaseConfig, getBossDifficulty } from '@/src/game/boss';
import { buyArenaUpgrade, createArenaState, DualArenaState, getArenaProgress, getArenaUpgradeCost, tickArenaPhysics } from '@/src/game/dualArena';
import { getSkinById } from '@/src/game/skins';
import { playSound } from '@/src/utils/audio';

const { width } = Dimensions.get('window');
const ARENA_SIZE = Math.min(width - 42, 214);

type DuelState = 'menu' | 'playing' | 'paused' | 'result';

const difficultyLabel = (id: string) => BOSS_DIFFICULTIES.find(item => item.id === id)?.name || 'Nenhuma';

export default function BossScreen() {
  const router = useRouter();
  const game = useGame();
  const unlocked = game.lifetimeStats.highestPhase >= 5 || game.level >= 5;
  const [difficultyId, setDifficultyId] = useState<BossDifficultyId>('medium');
  const [duelState, setDuelState] = useState<DuelState>('menu');
  const [playerArena, setPlayerArena] = useState<DualArenaState | null>(null);
  const [bossArena, setBossArena] = useState<DualArenaState | null>(null);
  const [resultWon, setResultWon] = useState(false);
  const [resultRewards, setResultRewards] = useState<string[]>([]);
  const finishing = useRef(false);
  const difficulty = getBossDifficulty(difficultyId);
  const playerSkin = getSkinById(game.ballTransformation);
  const bossSkin = getSkinById(difficulty.skinId);
  const config = useMemo(() => createBossPhaseConfig(difficultyId), [difficultyId]);

  const makeRingConfig = (count: number, side: 'player' | 'boss') => ({
    count,
    innerRadius: 24,
    outerRadius: ARENA_SIZE / 2 - 14,
    baseRotationSpeed: config.rotationSpeed * (side === 'boss' ? difficulty.speedMultiplier : 1),
    baseHp: config.baseHp * (side === 'boss' ? difficulty.damageMultiplier : 1),
    baseGapSize: config.gapSize,
    baseThickness: 4,
    closingSpeed: config.closingSpeed * (side === 'boss' ? difficulty.shrinkMultiplier : 1),
    colors: [side === 'boss' ? bossSkin.primaryColor : playerSkin.primaryColor, '#ffffff88', '#ffd700aa'],
    solidCount: difficulty.id === 'easy' ? 1 : difficulty.id === 'medium' ? 2 : difficulty.id === 'hard' ? 3 : 5,
    solidHpMultiplier: difficulty.id === 'insane' ? 1.8 : difficulty.id === 'hard' ? 1.55 : 1.35,
  });

  const startDuel = () => {
    if (!unlocked) {
      playSound('buttonError', game.settings.sound);
      return;
    }
    const nextConfig = createBossPhaseConfig(difficultyId);
    const nextDifficulty = getBossDifficulty(difficultyId);
    setPlayerArena(createArenaState({
      id: 'player',
      name: game.nickname || 'Você',
      skinIcon: playerSkin.icon,
      skinColor: playerSkin.primaryColor,
      size: ARENA_SIZE,
      phase: nextDifficulty.id === 'easy' ? 5 : nextDifficulty.id === 'medium' ? 8 : nextDifficulty.id === 'hard' ? 12 : 16,
      ringConfig: makeRingConfig(nextConfig.playerRingCount, 'player'),
      speedMultiplier: 1 + game.stats.baseSpeed / 900,
      damageMultiplier: 1 + game.stats.baseDamage / 180,
    }));
    setBossArena(createArenaState({
      id: 'boss',
      name: `Boss ${nextDifficulty.name}`,
      skinIcon: bossSkin.icon,
      skinColor: bossSkin.primaryColor,
      size: ARENA_SIZE,
      phase: nextDifficulty.id === 'easy' ? 5 : nextDifficulty.id === 'medium' ? 8 : nextDifficulty.id === 'hard' ? 12 : 16,
      ringConfig: makeRingConfig(nextConfig.bossRingCount, 'boss'),
      aiQuality: nextDifficulty.aiQuality,
      speedMultiplier: nextDifficulty.speedMultiplier,
      damageMultiplier: nextDifficulty.damageMultiplier,
    }));
    finishing.current = false;
    setResultRewards([]);
    setDuelState('playing');
  };

  useEffect(() => {
    if (duelState !== 'playing') return;
    const interval = setInterval(() => {
      setPlayerArena(current => current ? tickArenaPhysics(current, { damageMultiplier: 1 + game.stats.baseDamage / 220 }).state : current);
      setBossArena(current => current ? tickArenaPhysics(current, {
        isAi: true,
        opponentProgress: playerArena ? getArenaProgress(playerArena) : 0,
        shrinkMultiplier: difficulty.shrinkMultiplier,
        damageMultiplier: difficulty.damageMultiplier,
      }).state : current);
    }, 34);
    return () => clearInterval(interval);
  }, [duelState, difficultyId, playerArena?.id]);

  useEffect(() => {
    if (duelState !== 'playing' || !playerArena || !bossArena || finishing.current) return;
    if (!playerArena.finished && !bossArena.finished && !playerArena.crushed && !bossArena.crushed) return;
    const won = playerArena.finished || bossArena.crushed;
    finishDuel(won);
  }, [playerArena?.finished, bossArena?.finished, playerArena?.crushed, bossArena?.crushed, duelState]);

  const finishDuel = async (won: boolean) => {
    if (finishing.current) return;
    finishing.current = true;
    setResultWon(won);
    const rewards = difficulty.rewards;
    const coins = won ? rewards.coins : Math.floor(rewards.coins * 0.35);
    const xp = won ? rewards.xp : Math.floor(rewards.xp * 0.4);
    const gems = won ? Math.max(0, Math.floor((BOSS_DIFFICULTIES.findIndex(item => item.id === difficultyId) + 1) * 3)) : 0;
    const keys = won && Math.random() < rewards.keyChance ? 1 : 0;
    const fragments = won && Math.random() < rewards.fragmentChance ? { skinId: bossSkin.id, amount: difficultyId === 'insane' ? 10 : difficultyId === 'hard' ? 7 : 4 } : undefined;
    const chest = won && Math.random() < rewards.chestChance
      ? { label: difficultyId === 'insane' ? 'Baú Épico do Boss' : 'Baú Raro do Boss', icon: '🎁', rarity: difficultyId === 'insane' ? 'epic' : 'rare' }
      : undefined;
    await game.recordBossResult({ difficulty: difficultyId, won, coins, profileXp: xp, gems, keys, fragments, chest });
    playSound(won ? 'victory' : 'defeat', game.settings.sound);
    setResultRewards([`Moedas +${coins}`, `XP perfil +${xp}`, gems ? `Gemas +${gems}` : '', keys ? 'Chave +1' : '', fragments ? `Fragmentos +${fragments.amount} ${bossSkin.name}` : '', chest ? chest.label : ''].filter(Boolean));
    setDuelState('result');
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
    Alert.alert('Sair do Boss Mode?', 'A disputa atual será encerrada como derrota.', [
      { text: 'Cancelar', style: 'cancel', onPress: () => playSound('buttonClick', game.settings.sound) },
      { text: 'Sair', style: 'destructive', onPress: () => finishDuel(false) },
    ]);
  };

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <NeonButton title="← VOLTAR" variant="secondary" audioSettings={game.settings} onPress={() => router.back()} style={styles.backButton} />
        <Text style={styles.title}>BOSS MODE</Text>
        <Text style={styles.subtitle}>Melhor vitória: {difficultyLabel(game.lifetimeStats.bossBestDifficulty)} • {game.lifetimeStats.bossWins}V/{game.lifetimeStats.bossLosses}D</Text>
      </View>

      {duelState === 'menu' && (
        <ScrollView contentContainerStyle={styles.menuContent}>
          {!unlocked && <Text style={styles.lockText}>Complete a fase 5 ou alcance nível de perfil 5 para desbloquear.</Text>}
          {BOSS_DIFFICULTIES.map(item => {
            const boss = getSkinById(item.skinId);
            return (
              <NeonButton
                key={item.id}
                title={`${boss.icon} ${item.name} • IA ${Math.round(item.aiQuality * 100)}% • ${item.rewards.coins} moedas`}
                variant={difficultyId === item.id ? 'primary' : 'secondary'}
                sound="buttonClick"
                audioSettings={game.settings}
                onPress={() => setDifficultyId(item.id)}
              />
            );
          })}
          <NeonButton title="INICIAR BOSS" variant="primary" disabled={!unlocked} audioSettings={game.settings} onPress={startDuel} />
        </ScrollView>
      )}

      {(duelState === 'playing' || duelState === 'paused') && playerArena && bossArena && (
        <View style={styles.duelContent}>
          <DualArenaView arena={bossArena} meta={`Dificuldade ${difficulty.name}${bossArena.lastAiChoice ? ` • IA comprou ${bossArena.lastAiChoice}` : ''}`} accent="#ff4fd8" leader={getArenaProgress(bossArena) > getArenaProgress(playerArena)} />
          <View style={styles.vsBand}>
            <Text style={styles.vsText}>VS REAL</Text>
            <Text style={styles.aiText}>Sólidos fechados nos dois lados. Resultado sai da física.</Text>
          </View>
          <DualArenaView arena={playerArena} meta={`Moedas ${playerArena.coins} • XP ${playerArena.xp}`} accent="#00f0ff" leader={getArenaProgress(playerArena) >= getArenaProgress(bossArena)} />
          <View style={styles.shopRow}>
            <NeonButton title={`ATK ${getArenaUpgradeCost(playerArena, 'atk')} moedas`} variant="primary" audioSettings={game.settings} onPress={() => buy('atk')} />
            <NeonButton title={`Gold ${getArenaUpgradeCost(playerArena, 'gold')} moedas`} variant="primary" audioSettings={game.settings} onPress={() => buy('gold')} />
            <NeonButton title={duelState === 'paused' ? 'RETOMAR' : 'PAUSAR'} variant="secondary" audioSettings={game.settings} onPress={() => setDuelState(duelState === 'paused' ? 'playing' : 'paused')} />
            <NeonButton title="SAIR" variant="danger" audioSettings={game.settings} onPress={confirmExit} />
          </View>
        </View>
      )}

      <Modal visible={duelState === 'result'} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.resultModal}>
            <Text style={[styles.resultTitle, { color: resultWon ? '#00ff88' : '#ff0055' }]}>{resultWon ? 'VITÓRIA!' : 'DERROTA'}</Text>
            <Text style={styles.resultSubtitle}>{resultWon ? 'Você concluiu a arena real primeiro.' : 'O Boss venceu na arena real.'}</Text>
            {resultRewards.map(item => <Text key={item} style={styles.rewardLine}>{item}</Text>)}
            <NeonButton title="JOGAR NOVAMENTE" variant="primary" audioSettings={game.settings} onPress={startDuel} />
            <NeonButton title="VOLTAR PARA BOSS" variant="secondary" audioSettings={game.settings} onPress={() => setDuelState('menu')} />
            <NeonButton title="VOLTAR PARA HOME" variant="secondary" audioSettings={game.settings} onPress={() => router.replace('/' as any)} />
          </View>
        </View>
      </Modal>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 52, paddingHorizontal: 16, paddingBottom: 8 },
  backButton: { alignSelf: 'flex-start', minWidth: 110 },
  title: { color: '#00f0ff', fontSize: 30, fontWeight: 'bold', marginTop: 8 },
  subtitle: { color: '#ffffffaa', marginTop: 4, fontWeight: 'bold' },
  menuContent: { padding: 16, gap: 12 },
  lockText: { color: '#ffd700', backgroundColor: '#ffd70018', borderWidth: 1, borderColor: '#ffd70066', padding: 12, borderRadius: 12, fontWeight: 'bold' },
  duelContent: { flex: 1, alignItems: 'center', justifyContent: 'space-evenly', paddingHorizontal: 14, paddingBottom: 10 },
  vsBand: { alignItems: 'center', paddingVertical: 2 },
  vsText: { color: '#ffd700', fontSize: 18, fontWeight: 'bold' },
  aiText: { color: '#ffffff99', fontSize: 11, marginTop: 2, textAlign: 'center' },
  shopRow: { width: '100%', flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', justifyContent: 'center', alignItems: 'center', padding: 18 },
  resultModal: { width: '100%', maxWidth: 390, backgroundColor: '#1a0a2e', borderWidth: 1, borderColor: '#00f0ff88', borderRadius: 18, padding: 18, gap: 10, alignItems: 'stretch' },
  resultTitle: { fontSize: 30, fontWeight: 'bold', textAlign: 'center' },
  resultSubtitle: { color: '#ffffffcc', textAlign: 'center', fontWeight: 'bold' },
  rewardLine: { color: '#ffd700', fontWeight: 'bold', textAlign: 'center' },
});

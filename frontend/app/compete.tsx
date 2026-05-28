import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Modal, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useGame } from '@/src/contexts/GameContext';
import { RewardGrant, describeReward } from '@/src/game/retention';
import { getSkinById } from '@/src/game/skins';
import { playSound } from '@/src/utils/audio';

type Result = { won: boolean; trophiesDelta: number; newPosition: number; rewards: RewardGrant[] };

export default function CompeteScreen() {
  const router = useRouter();
  const game = useGame();
  const match = useMemo(() => game.createLeagueMatch(), []);
  const playerSkin = getSkinById(game.ballTransformation);
  const rivalSkin = getSkinById(match.rival.favoriteSkin);
  const [playerProgress, setPlayerProgress] = useState(0);
  const [rivalProgress, setRivalProgress] = useState(0);
  const [result, setResult] = useState<Result | null>(null);
  const finishing = useRef(false);

  useEffect(() => {
    playSound('buttonConfirm', game.settings.sound);
    const playerPower =
      0.022 +
      Math.min(0.026, game.level * 0.0009 + game.lifetimeStats.highestPhase * 0.00035) +
      (game.unlockedUpgrades.includes('bossHunter') ? 0.004 : 0) +
      (game.unlockedUpgrades.includes('rivalCrusher') ? 0.006 : 0);
    const rivalPower = 0.018 + Math.min(0.038, match.rival.level * 0.00065 + match.rival.trophies / 420000);
    const interval = setInterval(() => {
      setPlayerProgress(value => Math.min(1, value + playerPower * (0.75 + Math.random() * 0.65)));
      setRivalProgress(value => Math.min(1, value + rivalPower * (0.72 + Math.random() * 0.7)));
    }, 220);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    if (finishing.current || (playerProgress < 1 && rivalProgress < 1)) return;
    finishing.current = true;
    const won = playerProgress >= rivalProgress;
    const rewardRoll = Math.random();
    const baseCoins = Math.round((won ? 420 : 140) * match.map.rewardMultiplier);
    const baseXp = Math.round((won ? 160 : 55) * match.map.rewardMultiplier);
    game.recordLeagueCompetitionResult({
      rivalId: match.rival.id,
      won,
      noRevive: true,
      coins: baseCoins,
      profileXp: baseXp,
      gems: won && rewardRoll > 0.68 ? 4 : undefined,
      keys: won && rewardRoll > 0.88 ? 1 : undefined,
      fragments: won && rewardRoll > 0.78 ? { skinId: match.rival.favoriteSkin, amount: 8 } : undefined,
      chest: won && rewardRoll > 0.93 ? { label: 'Baú Neon', icon: '🎁', rarity: 'rare' } : undefined,
    }).then(saved => {
      setResult({ won, ...saved });
      playSound(won ? 'victory' : 'defeat', game.settings.sound);
    });
  }, [playerProgress, rivalProgress]);

  const Arena = ({ label, skinIcon, progress, trophies, top }: { label: string; skinIcon: string; progress: number; trophies: number; top?: boolean }) => {
    const ringsLeft = Math.max(0, Math.round(match.map.rings * (1 - progress)));
    return (
      <View style={[styles.arena, top && styles.rivalArena]}>
        <View style={styles.arenaHeader}>
          <Text style={styles.arenaName} numberOfLines={1}>{skinIcon} {label}</Text>
          <Text style={styles.arenaMeta}>{trophies.toLocaleString('pt-BR')} 🏆 • {ringsLeft} anéis</Text>
        </View>
        <View style={styles.ringStage}>
          <View style={[styles.ringOuter, { borderColor: match.map.color, transform: [{ rotate: `${progress * 250}deg` }] }]}>
            <View style={[styles.ringInner, { borderColor: top ? '#ff4fd8' : '#00f0ff' }]}>
              <Text style={styles.skinOrb}>{skinIcon}</Text>
            </View>
          </View>
        </View>
        <View style={styles.progressTrack}><View style={[styles.progressFill, { width: `${progress * 100}%`, backgroundColor: top ? '#ff4fd8' : '#00f0ff' }]} /></View>
      </View>
    );
  };

  return (
    <LinearGradient colors={['#08121d', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}><Text style={styles.backText}>← LIGA</Text></TouchableOpacity>
        <Text style={styles.title}>COMPETIR</Text>
        <Text style={styles.subtitle}>{match.map.theme} • {match.map.modifier} • {match.map.rings} anéis</Text>
      </View>

      <View style={styles.arenas}>
        <Arena top label={match.rival.name} skinIcon={rivalSkin.icon} progress={rivalProgress} trophies={match.rival.trophies} />
        <Arena label={game.nickname || 'Você'} skinIcon={playerSkin.icon} progress={playerProgress} trophies={game.getLeaguePlayer().trophies} />
      </View>

      <Modal visible={!!result} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.resultBox}>
            <Text style={[styles.resultTitle, { color: result?.won ? '#00ff88' : '#ff4fd8' }]}>{result?.won ? 'VITÓRIA' : 'DERROTA'}</Text>
            <Text style={styles.resultText}>Rival: {match.rival.name}</Text>
            <Text style={styles.trophyDelta}>{result?.trophiesDelta || 0} troféus</Text>
            <Text style={styles.resultText}>Nova posição: #{result?.newPosition}</Text>
            <Text style={styles.resultText}>Sequência: {result?.won ? (game.league.history.currentWinStreak || 0) + 1 : 0}</Text>
            {result?.rewards.map(reward => <Text key={describeReward(reward)} style={styles.rewardLine}>{describeReward(reward)}</Text>)}
            <TouchableOpacity style={styles.primaryButton} onPress={() => router.replace('/compete' as any)}>
              <Text style={styles.primaryButtonText}>COMPETIR NOVAMENTE</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.secondaryButton} onPress={() => router.replace('/league' as any)}>
              <Text style={styles.secondaryButtonText}>VOLTAR PARA LIGA</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 54, paddingHorizontal: 16, paddingBottom: 8 },
  backText: { color: '#00f0ff', fontWeight: 'bold' },
  title: { color: '#ffffff', fontSize: 28, fontWeight: 'bold', marginTop: 8 },
  subtitle: { color: '#ffffff99', fontWeight: 'bold', marginTop: 3 },
  arenas: { flex: 1, padding: 14, gap: 12 },
  arena: { flex: 1, minHeight: 210, backgroundColor: '#ffffff10', borderWidth: 1, borderColor: '#00f0ff55', borderRadius: 14, padding: 12 },
  rivalArena: { borderColor: '#ff4fd866' },
  arenaHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', gap: 8 },
  arenaName: { color: '#ffffff', fontSize: 15, fontWeight: 'bold', flex: 1 },
  arenaMeta: { color: '#ffffffaa', fontSize: 11, fontWeight: 'bold' },
  ringStage: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  ringOuter: { width: 150, height: 150, borderRadius: 75, borderWidth: 14, alignItems: 'center', justifyContent: 'center' },
  ringInner: { width: 94, height: 94, borderRadius: 47, borderWidth: 3, alignItems: 'center', justifyContent: 'center', backgroundColor: '#050516' },
  skinOrb: { fontSize: 42 },
  progressTrack: { height: 8, borderRadius: 4, backgroundColor: '#ffffff18', overflow: 'hidden' },
  progressFill: { height: 8, borderRadius: 4 },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', justifyContent: 'center', alignItems: 'center', padding: 18 },
  resultBox: { width: '100%', maxWidth: 390, backgroundColor: '#1a0a2e', borderWidth: 1, borderColor: '#00f0ff88', borderRadius: 18, padding: 20, alignItems: 'center' },
  resultTitle: { fontSize: 30, fontWeight: 'bold' },
  resultText: { color: '#ffffff', fontWeight: 'bold', marginTop: 7 },
  trophyDelta: { color: '#ffd700', fontSize: 24, fontWeight: 'bold', marginTop: 10 },
  rewardLine: { color: '#00ff88', fontWeight: 'bold', marginTop: 5 },
  primaryButton: { width: '100%', backgroundColor: '#00f0ff', borderRadius: 10, padding: 13, alignItems: 'center', marginTop: 16 },
  primaryButtonText: { color: '#001018', fontWeight: 'bold' },
  secondaryButton: { width: '100%', borderWidth: 1, borderColor: '#ffffff44', borderRadius: 10, padding: 13, alignItems: 'center', marginTop: 9 },
  secondaryButtonText: { color: '#ffffff', fontWeight: 'bold' },
});

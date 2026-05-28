import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Dimensions, Modal, ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import Svg, { Circle } from 'react-native-svg';
import { useGame } from '@/src/contexts/GameContext';
import { BOSS_DIFFICULTIES, BossDifficultyId, chooseBossUpgrade, createBossPhaseConfig, getBossDifficulty } from '@/src/game/boss';
import { getSkinById } from '@/src/game/skins';

const { width } = Dimensions.get('window');
const ARENA_SIZE = Math.min(width - 36, 230);
const CENTER = ARENA_SIZE / 2;
const OUTER = ARENA_SIZE / 2 - 9;

type DuelState = 'menu' | 'playing' | 'result';

const difficultyLabel = (id: string) => BOSS_DIFFICULTIES.find(item => item.id === id)?.name || 'Nenhuma';

export default function BossScreen() {
  const router = useRouter();
  const game = useGame();
  const unlocked = game.lifetimeStats.highestPhase >= 5 || game.level >= 5;
  const [difficultyId, setDifficultyId] = useState<BossDifficultyId>('medium');
  const [duelState, setDuelState] = useState<DuelState>('menu');
  const [playerProgress, setPlayerProgress] = useState(0);
  const [bossProgress, setBossProgress] = useState(0);
  const [playerRings, setPlayerRings] = useState(0);
  const [bossRings, setBossRings] = useState(0);
  const [resultWon, setResultWon] = useState(false);
  const [resultRewards, setResultRewards] = useState<string[]>([]);
  const [bossUpgrade, setBossUpgrade] = useState('damage');
  const [tick, setTick] = useState(0);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const playerSkin = getSkinById(game.ballTransformation);
  const difficulty = getBossDifficulty(difficultyId);
  const bossSkin = getSkinById(difficulty.skinId);
  const config = useMemo(() => createBossPhaseConfig(difficultyId), [difficultyId]);

  useEffect(() => () => {
    if (intervalRef.current) clearInterval(intervalRef.current);
  }, []);

  const startDuel = () => {
    if (!unlocked) return;
    const nextConfig = createBossPhaseConfig(difficultyId);
    setPlayerProgress(0);
    setBossProgress(0);
    setPlayerRings(nextConfig.playerRingCount);
    setBossRings(nextConfig.bossRingCount);
    setResultRewards([]);
    setDuelState('playing');
    if (intervalRef.current) clearInterval(intervalRef.current);

    intervalRef.current = setInterval(() => {
      setTick(value => value + 1);
      setPlayerProgress(previous => {
        const skinBonus = playerSkin.rarity === 'ultimate' ? 0.12 : playerSkin.rarity === 'legendary' ? 0.07 : playerSkin.rarity === 'epic' ? 0.04 : 0;
        const gain = 0.7 + game.stats.baseDamage / 115 + game.stats.baseSpeed / 520 + skinBonus + Math.random() * 0.42;
        return Math.min(100, previous + gain);
      });
      setBossProgress(previous => {
        const smartChoice = chooseBossUpgrade(['damage', 'speed', 'perfect', 'chainBreak', 'ringRepulse'], difficultyId, {
          ringsRemaining: Math.ceil(nextConfig.bossRingCount * (1 - previous / 100)),
          speed: difficulty.speedMultiplier * 2.4,
          perfectWindows: Math.random() > 0.55 ? 1 : 0,
        });
        setBossUpgrade(smartChoice);
        const aiBonus = smartChoice === 'damage' ? 0.18 : smartChoice === 'speed' ? 0.13 : smartChoice === 'chainBreak' ? 0.16 : smartChoice === 'ringRepulse' ? 0.12 : 0.09;
        const ultimateBurst = Math.random() < difficulty.ultimateChance ? 0.85 : 0;
        const gain = 0.58 * difficulty.speedMultiplier + 0.52 * difficulty.damageMultiplier + difficulty.aiQuality * 0.28 + aiBonus + ultimateBurst + Math.random() * 0.28;
        return Math.min(100, previous + gain);
      });
    }, 180);
  };

  useEffect(() => {
    if (duelState !== 'playing') return;
    setPlayerRings(Math.max(0, Math.ceil(config.playerRingCount * (1 - playerProgress / 100))));
    setBossRings(Math.max(0, Math.ceil(config.bossRingCount * (1 - bossProgress / 100))));
    if (playerProgress >= 100 || bossProgress >= 100) finishDuel(playerProgress >= bossProgress);
  }, [playerProgress, bossProgress, duelState]);

  const finishDuel = async (won: boolean) => {
    if (intervalRef.current) clearInterval(intervalRef.current);
    intervalRef.current = null;
    setResultWon(won);
    setDuelState('result');
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
    setResultRewards([
      `💰 +${coins}`,
      `👤 XP +${xp}`,
      gems ? `💎 +${gems}` : '',
      keys ? '🔑 +1' : '',
      fragments ? `🧩 +${fragments.amount} ${bossSkin.name}` : '',
      chest ? `🎁 ${chest.label}` : '',
    ].filter(Boolean));
  };

  const Arena = ({ title, skinIcon, progress, rings, color, boss }: { title: string; skinIcon: string; progress: number; rings: number; color: string; boss?: boolean }) => {
    const visibleRings = Array.from({ length: Math.min(12, Math.max(1, rings)) }, (_, index) => OUTER - index * 8);
    const ballAngle = (tick * (boss ? 0.28 : 0.34)) % (Math.PI * 2);
    const ballRadius = OUTER * 0.42;
    const ballX = CENTER + Math.cos(ballAngle) * ballRadius;
    const ballY = CENTER + Math.sin(ballAngle) * ballRadius;

    return (
      <View style={styles.arenaPanel}>
        <View style={styles.arenaHeader}>
          <Text style={styles.arenaTitle}>{title}</Text>
          <Text style={styles.arenaMeta}>{rings} anéis</Text>
        </View>
        <View style={styles.arenaBox}>
          <Svg width={ARENA_SIZE} height={ARENA_SIZE} style={StyleSheet.absoluteFill}>
            {visibleRings.map((radius, index) => (
              <Circle key={radius} cx={CENTER} cy={CENTER} r={radius} stroke={index % 2 ? color : '#ffffff66'} strokeWidth={4} fill="none" opacity={0.75 - index * 0.035} strokeDasharray={`${radius * 4.6} ${radius * 0.9}`} transform={`rotate(${tick * (boss ? 5 + index : -6 - index)} ${CENTER} ${CENTER})`} />
            ))}
          </Svg>
          <View style={[styles.duelBall, { left: ballX - 14, top: ballY - 14, shadowColor: color }]}>
            <LinearGradient colors={['#ffffff', color]} style={styles.duelBallGradient}>
              <Text style={styles.duelBallIcon}>{skinIcon}</Text>
            </LinearGradient>
          </View>
        </View>
        <View style={styles.progressBar}>
          <View style={[styles.progressFill, { width: `${progress}%`, backgroundColor: color }]} />
          <Text style={styles.progressText}>{Math.floor(progress)}%</Text>
        </View>
      </View>
    );
  };

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}><Text style={styles.backText}>← VOLTAR</Text></TouchableOpacity>
        <Text style={styles.title}>BOSS MODE</Text>
        <Text style={styles.subtitle}>Melhor vitória: {difficultyLabel(game.lifetimeStats.bossBestDifficulty)} • {game.lifetimeStats.bossWins}V/{game.lifetimeStats.bossLosses}D</Text>
      </View>

      {duelState === 'menu' && (
        <ScrollView contentContainerStyle={styles.menuContent}>
          {!unlocked && <Text style={styles.lockText}>🔒 Complete a fase 5 ou alcance nível de perfil 5 para desbloquear.</Text>}
          <Text style={styles.sectionTitle}>DIFICULDADE</Text>
          {BOSS_DIFFICULTIES.map(item => {
            const boss = getSkinById(item.skinId);
            return (
              <TouchableOpacity key={item.id} style={[styles.difficultyCard, difficultyId === item.id && styles.difficultySelected]} onPress={() => setDifficultyId(item.id)}>
                <Text style={styles.difficultyIcon}>{boss.icon}</Text>
                <View style={styles.difficultyInfo}>
                  <Text style={styles.difficultyName}>{item.name}</Text>
                  <Text style={styles.difficultyText}>Boss usa {boss.name}. IA {Math.round(item.aiQuality * 100)}% otimizada.</Text>
                  <Text style={styles.difficultyReward}>Recompensas: 💰 {item.rewards.coins} • XP {item.rewards.xp} • chave/fragmentos/baú</Text>
                </View>
              </TouchableOpacity>
            );
          })}
          <TouchableOpacity style={[styles.startButton, !unlocked && styles.disabled]} disabled={!unlocked} onPress={startDuel}>
            <LinearGradient colors={['#ff0055', '#7c3aed']} style={styles.startGradient}>
              <Text style={styles.startText}>INICIAR DUELO</Text>
            </LinearGradient>
          </TouchableOpacity>
        </ScrollView>
      )}

      {duelState === 'playing' && (
        <View style={styles.duelContent}>
          <Arena title={`BOSS • ${difficulty.name}`} skinIcon={bossSkin.icon} progress={bossProgress} rings={bossRings} color={bossSkin.primaryColor} boss />
          <View style={styles.vsBand}>
            <Text style={styles.vsText}>VS</Text>
            <Text style={styles.aiText}>IA escolheu: {bossUpgrade}</Text>
          </View>
          <Arena title="VOCÊ" skinIcon={playerSkin.icon} progress={playerProgress} rings={playerRings} color={playerSkin.primaryColor} />
        </View>
      )}

      <Modal visible={duelState === 'result'} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.resultModal}>
            <LinearGradient colors={['#1a0a2e', '#16003b']} style={styles.modalContent}>
              <Text style={[styles.resultTitle, { color: resultWon ? '#00ff88' : '#ff0055' }]}>{resultWon ? 'VITÓRIA!' : 'DERROTA'}</Text>
              <Text style={styles.resultSubtitle}>{resultWon ? 'Você superou os anéis antes do Boss.' : 'O Boss completou a arena primeiro.'}</Text>
              {resultRewards.map(item => <Text key={item} style={styles.rewardLine}>{item}</Text>)}
              <TouchableOpacity style={styles.resultButton} onPress={() => setDuelState('menu')}>
                <Text style={styles.resultButtonText}>VOLTAR AO BOSS MODE</Text>
              </TouchableOpacity>
            </LinearGradient>
          </View>
        </View>
      </Modal>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 56, paddingHorizontal: 18, paddingBottom: 12 },
  backText: { color: '#00f0ff', fontWeight: 'bold', fontSize: 16 },
  title: { color: '#00f0ff', fontSize: 30, fontWeight: 'bold', marginTop: 8 },
  subtitle: { color: '#ffffffaa', marginTop: 4, fontWeight: 'bold' },
  menuContent: { padding: 16, gap: 12 },
  lockText: { color: '#ffd700', backgroundColor: '#ffd70018', borderWidth: 1, borderColor: '#ffd70066', padding: 12, borderRadius: 12, fontWeight: 'bold' },
  sectionTitle: { color: '#ffffff88', fontWeight: 'bold', letterSpacing: 2, marginTop: 4 },
  difficultyCard: { flexDirection: 'row', gap: 12, backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#ffffff22', borderRadius: 12, padding: 14 },
  difficultySelected: { borderColor: '#00f0ff', backgroundColor: '#00f0ff18' },
  difficultyIcon: { fontSize: 38 },
  difficultyInfo: { flex: 1 },
  difficultyName: { color: '#ffffff', fontSize: 18, fontWeight: 'bold' },
  difficultyText: { color: '#ffffffaa', fontSize: 13, marginTop: 3 },
  difficultyReward: { color: '#ffd700', fontSize: 12, marginTop: 5, fontWeight: 'bold' },
  startButton: { height: 54, borderRadius: 14, overflow: 'hidden', marginTop: 8 },
  startGradient: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  startText: { color: '#ffffff', fontSize: 17, fontWeight: 'bold', letterSpacing: 2 },
  disabled: { opacity: 0.45 },
  duelContent: { flex: 1, alignItems: 'center', justifyContent: 'space-evenly', paddingHorizontal: 18, paddingBottom: 18 },
  arenaPanel: { width: '100%', alignItems: 'center', backgroundColor: '#ffffff0f', borderRadius: 12, borderWidth: 1, borderColor: '#ffffff20', padding: 10 },
  arenaHeader: { width: '100%', flexDirection: 'row', justifyContent: 'space-between', marginBottom: 8 },
  arenaTitle: { color: '#ffffff', fontWeight: 'bold' },
  arenaMeta: { color: '#ffffffaa', fontWeight: 'bold' },
  arenaBox: { width: ARENA_SIZE, height: ARENA_SIZE, borderRadius: ARENA_SIZE / 2, backgroundColor: '#00000044', overflow: 'hidden', borderWidth: 2, borderColor: '#ffffff12' },
  duelBall: { position: 'absolute', width: 28, height: 28, borderRadius: 14, shadowOpacity: 1, shadowRadius: 12 },
  duelBallGradient: { flex: 1, borderRadius: 14, alignItems: 'center', justifyContent: 'center' },
  duelBallIcon: { fontSize: 16 },
  progressBar: { width: '100%', height: 18, backgroundColor: '#00000066', borderRadius: 9, overflow: 'hidden', justifyContent: 'center', marginTop: 8 },
  progressFill: { position: 'absolute', left: 0, top: 0, bottom: 0 },
  progressText: { color: '#ffffff', fontSize: 12, fontWeight: 'bold', textAlign: 'center' },
  vsBand: { alignItems: 'center', paddingVertical: 4 },
  vsText: { color: '#ffd700', fontSize: 22, fontWeight: 'bold' },
  aiText: { color: '#ffffff99', fontSize: 12, marginTop: 2 },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', justifyContent: 'center', alignItems: 'center' },
  resultModal: { width: '86%', maxWidth: 390, borderRadius: 16, overflow: 'hidden' },
  modalContent: { padding: 22, alignItems: 'center' },
  resultTitle: { fontSize: 32, fontWeight: 'bold' },
  resultSubtitle: { color: '#ffffffcc', textAlign: 'center', marginTop: 6, marginBottom: 12 },
  rewardLine: { color: '#ffffff', fontWeight: 'bold', marginTop: 5 },
  resultButton: { marginTop: 18, backgroundColor: '#00f0ff', paddingVertical: 12, paddingHorizontal: 18, borderRadius: 10 },
  resultButtonText: { color: '#001018', fontWeight: 'bold' },
});

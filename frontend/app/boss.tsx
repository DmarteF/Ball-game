import React, { useEffect, useRef, useState } from 'react';
import { Dimensions, Modal, ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { DualArenaView } from '@/src/components/DualArenaView';
import { NeonButton } from '@/src/components/NeonButton';
import { useGame } from '@/src/contexts/GameContext';
import {
  BossLevelDefinition,
  BossLevelId,
  createBossRingConfig,
  describeBossReward,
  getBossMonthKey,
  getMonthlyBoss,
  getNextBossLevel,
  isBossDailyComplete,
  normalizeBossProgress,
} from '@/src/game/boss';
import { applyArenaRunUpgrade, buyArenaUpgrade, createArenaState, DualArenaState, getArenaProgress, getArenaUpgradeCost, tickArenaPhysics } from '@/src/game/dualArena';
import { getSkinById } from '@/src/game/skins';
import { playSound } from '@/src/utils/audio';
import { getRandomUpgrades, getRarityColor, Upgrade } from '@/src/game/upgrades';

const { width, height } = Dimensions.get('window');
const ARENA_SIZE = Math.max(132, Math.min(width - 72, (height - 288) / 2, 188));

type DuelState = 'menu' | 'playing' | 'paused' | 'result';

const formatMs = (ms: number) => {
  const totalMinutes = Math.max(0, Math.floor(ms / 60000));
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;
  return `${hours}h ${String(minutes).padStart(2, '0')}min`;
};

const getResetTimes = () => {
  const now = new Date();
  const nextDay = new Date(now);
  nextDay.setHours(24, 0, 0, 0);
  const nextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1, 0, 0, 0, 0);
  return { daily: formatMs(nextDay.getTime() - now.getTime()), monthly: formatMs(nextMonth.getTime() - now.getTime()) };
};

export default function BossScreen() {
  const router = useRouter();
  const game = useGame();
  const unlocked = game.lifetimeStats.highestPhase >= 5 || game.level >= 5;
  const progress = normalizeBossProgress(game.bossProgress);
  const monthlyBoss = getMonthlyBoss();
  const currentLevel = getNextBossLevel(progress);
  const completed = isBossDailyComplete(progress);
  const [duelState, setDuelState] = useState<DuelState>('menu');
  const [playerArena, setPlayerArena] = useState<DualArenaState | null>(null);
  const [bossArena, setBossArena] = useState<DualArenaState | null>(null);
  const [activeLevel, setActiveLevel] = useState<BossLevelDefinition>(currentLevel);
  const [resultWon, setResultWon] = useState(false);
  const [resultRewards, setResultRewards] = useState<string[]>([]);
  const [runUpgrades, setRunUpgrades] = useState<Record<string, number>>({});
  const [levelChoices, setLevelChoices] = useState<Upgrade[]>([]);
  const [exitConfirmVisible, setExitConfirmVisible] = useState(false);
  const [clock, setClock] = useState(getResetTimes());
  const finishing = useRef(false);
  const playerArenaRef = useRef<DualArenaState | null>(null);
  const playerSkin = getSkinById(game.ballTransformation);
  const bossSkin = getSkinById(monthlyBoss.skinId);
  const skinDamageBonus = ['damage_multiplier', 'cosmic_critical', 'league_king_wave'].includes(playerSkin.passive.type) ? playerSkin.passive.value : 0;
  const skinSpeedBonus = playerSkin.passive.type === 'speed' ? playerSkin.passive.value : 0;
  const skinCoinBonus = ['coin_multiplier', 'cosmic_critical', 'league_starter_champion', 'league_king_wave'].includes(playerSkin.passive.type) ? playerSkin.passive.value * 0.6 : 0;
  const skinXpBonus = ['xp_multiplier', 'cosmic_critical', 'league_starter_champion', 'league_king_wave'].includes(playerSkin.passive.type) ? playerSkin.passive.value * 0.5 : 0;

  useEffect(() => {
    const interval = setInterval(() => setClock(getResetTimes()), 30000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    playerArenaRef.current = playerArena;
  }, [playerArena]);

  const startDuel = () => {
    if (!unlocked) {
      playSound('buttonError', game.settings.sound);
      return;
    }
    const level = completed ? monthlyBoss.levels[monthlyBoss.levels.length - 1] : getNextBossLevel(normalizeBossProgress(game.bossProgress));
    setActiveLevel(level);
    setPlayerArena(createArenaState({
      id: 'player',
      name: game.nickname || 'Você',
      skinIcon: playerSkin.icon,
      skinColor: playerSkin.primaryColor,
      size: ARENA_SIZE,
      phase: level.phase,
      ringConfig: createBossRingConfig(level, ARENA_SIZE, [playerSkin.primaryColor, '#ffffff88', '#ffd700aa'], 'player'),
      speedMultiplier: 1 + game.stats.baseSpeed / 900 + skinSpeedBonus,
      damageMultiplier: 1 + game.stats.baseDamage / 180,
    }));
    setBossArena(createArenaState({
      id: 'boss',
      name: monthlyBoss.name,
      skinIcon: bossSkin.icon,
      skinColor: bossSkin.primaryColor,
      size: ARENA_SIZE,
      phase: level.phase,
      ringConfig: createBossRingConfig(level, ARENA_SIZE, monthlyBoss.colors, 'boss'),
      aiQuality: level.aiQuality,
      speedMultiplier: level.bossSpeedMultiplier,
      damageMultiplier: level.bossDamageMultiplier,
    }));
    finishing.current = false;
    setResultRewards([]);
    setRunUpgrades({});
    setLevelChoices([]);
    setDuelState('playing');
  };

  useEffect(() => {
    if (duelState !== 'playing') return;
    const interval = setInterval(() => {
      setPlayerArena(current => {
        if (!current) return current;
        const beforeLevel = current.level;
        const result = tickArenaPhysics(current, {
          damageMultiplier: (1 + game.stats.baseDamage / 240 + skinDamageBonus) * (1 + (runUpgrades.damage || 0) * 0.16),
          coinMultiplier: game.stats.coinMultiplier * (1 + skinCoinBonus + (runUpgrades.coinBoost || 0) * 0.24),
          xpMultiplier: game.stats.xpMultiplier * (1 + skinXpBonus + (runUpgrades.xpBoost || 0) * 0.2),
          speedMultiplier: 1 + (runUpgrades.speed || 0) * 0.04,
          shrinkMultiplier: 1 - Math.min(0.24, (game.permanentUpgrades.slowRings || 0) * 0.018),
        }).state;
        if (result.level > beforeLevel && levelChoices.length === 0) {
          setLevelChoices(getRandomUpgrades(3, runUpgrades, game.level, game.unlockedUpgrades));
          playSound('levelUp', game.settings.sound);
          setDuelState('paused');
        }
        return result;
      });
      setBossArena(current => current ? tickArenaPhysics(current, {
        isAi: true,
        opponentProgress: playerArenaRef.current ? getArenaProgress(playerArenaRef.current) : 0,
        shrinkMultiplier: activeLevel.bossShrinkMultiplier,
        damageMultiplier: activeLevel.bossDamageMultiplier,
        xpMultiplier: 1,
      }).state : current);
    }, 34);
    return () => clearInterval(interval);
  }, [duelState, activeLevel.id, activeLevel.bossDamageMultiplier, activeLevel.bossShrinkMultiplier, game.stats.baseDamage, game.stats.coinMultiplier, game.stats.xpMultiplier, runUpgrades, levelChoices.length]);

  useEffect(() => {
    if (duelState !== 'playing' || !playerArena || !bossArena || finishing.current) return;
    if (!playerArena.finished && !bossArena.finished && !playerArena.crushed && !bossArena.crushed) return;
    finishDuel(playerArena.finished || bossArena.crushed);
  }, [playerArena?.finished, bossArena?.finished, playerArena?.crushed, bossArena?.crushed, duelState]);

  const finishDuel = async (won: boolean) => {
    if (finishing.current) return;
    finishing.current = true;
    setResultWon(won);
    setDuelState('result');
    const currentProgress = normalizeBossProgress(game.bossProgress);
    const alreadyClaimed = currentProgress.dailyRewardsClaimed.includes(activeLevel.id);
    const reward = activeLevel.reward;
    const coins = won ? (alreadyClaimed ? 90 : reward.coins) : Math.floor(reward.coins * 0.25);
    const xp = Math.floor((won ? (alreadyClaimed ? 35 : reward.xp) : Math.floor(reward.xp * 0.3)) * game.stats.xpMultiplier * (1 + skinXpBonus + (runUpgrades.xpBoost || 0) * 0.2));
    const gems = won && !alreadyClaimed ? reward.gems || 0 : 0;
    const keys = won && !alreadyClaimed ? reward.keys || 0 : 0;
    const fragments = won && !alreadyClaimed && reward.fragments ? { skinId: bossSkin.id, amount: reward.fragments } : undefined;
    const chest = won && !alreadyClaimed && reward.chest ? { label: `Baú ${reward.chest} do Boss`, icon: '🎁', rarity: reward.chest } : undefined;
    await game.recordBossResult({ difficulty: activeLevel.id, levelId: activeLevel.id as BossLevelId, monthlyBossId: monthlyBoss.id, won, coins, profileXp: xp, gems, keys, fragments, chest });
    playSound(won ? 'victory' : 'defeat', game.settings.sound);
    setResultRewards([
      alreadyClaimed && won ? 'Recompensa diária alta já coletada neste nível' : '',
      `Moedas +${coins}`,
      `XP perfil +${xp}`,
      gems ? `Gemas +${gems}` : '',
      keys ? `Chaves +${keys}` : '',
      fragments ? `Fragmentos +${fragments.amount} ${bossSkin.name}` : '',
      chest ? chest.label : '',
      won && activeLevel.id === 'impossivel' ? 'Boss diário concluído' : '',
    ].filter(Boolean));
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
    setDuelState('paused');
    setExitConfirmVisible(true);
  };

  const cancelExit = () => {
    playSound('buttonClick', game.settings.sound);
    setExitConfirmVisible(false);
    if (!finishing.current) setDuelState('playing');
  };

  const leaveDuel = () => {
    playSound('buttonConfirm', game.settings.sound);
    setExitConfirmVisible(false);
    finishDuel(false);
  };

  const chooseLevelUpgrade = (upgrade: Upgrade) => {
    if (!playerArena) return;
    playSound('buttonConfirm', game.settings.sound);
    setRunUpgrades(prev => ({ ...prev, [upgrade.id]: (prev[upgrade.id] || 0) + 1 }));
    setPlayerArena(applyArenaRunUpgrade(playerArena, upgrade.id));
    setLevelChoices([]);
    setDuelState('playing');
  };

  const monthlyBest = progress.monthlyBestLevelWon === 'none' ? 'Nenhum' : monthlyBoss.levels.find(level => level.id === progress.monthlyBestLevelWon)?.name || 'Nenhum';

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      {duelState === 'menu' ? (
        <View style={styles.header}>
          <NeonButton title="← VOLTAR" variant="secondary" audioSettings={game.settings} onPress={() => router.back()} style={styles.backButton} />
          <Text style={styles.title}>BOSS MODE</Text>
          <Text style={styles.subtitle}>Boss do mês: {monthlyBoss.name}</Text>
        </View>
      ) : playerArena && bossArena ? (
        <View style={styles.topHUD}>
          <View style={styles.hudRow}>
            <View style={styles.hudItem}><Text style={styles.hudIcon}>💰</Text><Text style={styles.hudValue}>{playerArena.coins}</Text></View>
            <View style={styles.hudItem}><Text style={styles.hudIcon}>⭐</Text><Text style={styles.hudValue}>Lv.{playerArena.level}</Text></View>
            <TouchableOpacity style={styles.pauseMiniButton} onPress={() => setDuelState(duelState === 'paused' ? 'playing' : 'paused')}>
              <Text style={styles.pauseMiniText}>{duelState === 'paused' ? '▶' : '⏸'}</Text>
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
      ) : null}

      {duelState === 'menu' && (
        <ScrollView contentContainerStyle={styles.menuContent}>
          {!unlocked && <Text style={styles.lockText}>Complete a fase 5 ou alcance nível de perfil 5 para desbloquear.</Text>}
          <View style={[styles.bossCard, { borderColor: bossSkin.primaryColor }]}>
            <Text style={styles.bossIcon}>{bossSkin.icon}</Text>
            <Text style={styles.bossName}>{monthlyBoss.name}</Text>
            <Text style={styles.bossText}>Tema: {monthlyBoss.theme}</Text>
            <Text style={styles.bossText}>{monthlyBoss.description}</Text>
            <Text style={styles.bossText}>Passiva: {monthlyBoss.passive}</Text>
            <Text style={styles.bossText}>Mês ativo: {getBossMonthKey()}</Text>
          </View>
          <View style={styles.progressBox}>
            <Text style={styles.progressLine}>Nível atual: {completed ? 'Concluído hoje' : currentLevel.name}</Text>
            <Text style={styles.progressLine}>Vitórias hoje: {Math.min(progress.dailyLevelWins.length, 5)}/5</Text>
            <Text style={styles.progressLine}>Melhor nível do mês: {monthlyBest}</Text>
            <Text style={styles.progressLine}>Vitórias no mês: {progress.monthlyTotalWins}</Text>
            <Text style={styles.progressLine}>Impossível no mês: {progress.monthlyImpossibleWins}</Text>
            <Text style={styles.progressLine}>Próxima recompensa: {completed ? 'Rejogue por recompensa reduzida' : describeBossReward(currentLevel.reward)}</Text>
            <Text style={styles.progressLine}>Reset diário: {clock.daily}</Text>
            <Text style={styles.progressLine}>Troca mensal: {clock.monthly}</Text>
          </View>
          <NeonButton title={completed ? 'ENFRENTAR NOVAMENTE' : 'ENFRENTAR'} variant="primary" disabled={!unlocked} audioSettings={game.settings} onPress={startDuel} />
        </ScrollView>
      )}

      {(duelState === 'playing' || duelState === 'paused') && playerArena && bossArena && (
        <View style={styles.duelContent}>
          <DualArenaView arena={bossArena} meta={`${activeLevel.name} • ${bossArena.coins} moedas`} accent="#ff4fd8" leader={getArenaProgress(bossArena) > getArenaProgress(playerArena)} />
          <DualArenaView arena={playerArena} meta={`Moedas ${playerArena.coins} • XP ${playerArena.xp} • Lv.${playerArena.level}`} accent="#00f0ff" leader={getArenaProgress(playerArena) >= getArenaProgress(bossArena)} />
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

      <Modal visible={duelState === 'result'} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.resultModal}>
            <Text style={[styles.resultTitle, { color: resultWon ? '#00ff88' : '#ff0055' }]}>{resultWon ? 'VITÓRIA!' : 'DERROTA'}</Text>
            <Text style={styles.resultSubtitle}>{resultWon ? 'Resultado decidido pela arena real.' : 'O Boss venceu na arena real.'}</Text>
            {resultRewards.map(item => <Text key={item} style={styles.rewardLine}>{item}</Text>)}
            <NeonButton title="ENFRENTAR NOVAMENTE" variant="primary" audioSettings={game.settings} onPress={startDuel} />
            {resultRewards.some(item => item.includes('Chaves') || item.includes('Baú')) && <NeonButton title="ABRIR INVENTÁRIO" variant="primary" audioSettings={game.settings} onPress={() => router.replace('/inventory' as any)} />}
            <NeonButton title="VOLTAR PARA BOSS" variant="secondary" audioSettings={game.settings} onPress={() => setDuelState('menu')} />
            <NeonButton title="VOLTAR PARA HOME" variant="secondary" audioSettings={game.settings} onPress={() => router.replace('/' as any)} />
          </View>
        </View>
      </Modal>

      <Modal visible={exitConfirmVisible} transparent animationType="fade" onRequestClose={cancelExit}>
        <View style={styles.modalOverlay}>
          <View style={styles.resultModal}>
            <Text style={styles.resultTitle}>SAIR DO BOSS?</Text>
            <Text style={styles.resultSubtitle}>A disputa atual será encerrada como derrota.</Text>
            <NeonButton title="SAIR" variant="danger" audioSettings={game.settings} onPress={leaveDuel} />
            <NeonButton title="CANCELAR" variant="secondary" audioSettings={game.settings} onPress={cancelExit} />
          </View>
        </View>
      </Modal>

      <Modal visible={levelChoices.length > 0} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.resultModal}>
            <Text style={styles.resultTitle}>LEVEL UP</Text>
            <Text style={styles.resultSubtitle}>Escolha uma melhoria temporária.</Text>
            {levelChoices.map(upgrade => (
              <TouchableOpacity key={upgrade.id} style={[styles.choiceCard, { borderColor: getRarityColor(upgrade.rarity) }]} onPress={() => chooseLevelUpgrade(upgrade)}>
                <Text style={styles.choiceIcon}>{upgrade.icon}</Text>
                <View style={styles.choiceTextBox}>
                  <Text style={styles.choiceTitle}>{upgrade.name} Lv.{(runUpgrades[upgrade.id] || 0) + 1}</Text>
                  <Text style={styles.choiceText}>{upgrade.description}</Text>
                </View>
              </TouchableOpacity>
            ))}
          </View>
        </View>
      </Modal>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 52, paddingHorizontal: 16, paddingBottom: 8 },
  topHUD: { paddingTop: 45, paddingHorizontal: 12, paddingBottom: 4, zIndex: 20, elevation: 20 },
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
  backButton: { alignSelf: 'flex-start', minWidth: 110 },
  title: { color: '#00f0ff', fontSize: 30, fontWeight: 'bold', marginTop: 8 },
  subtitle: { color: '#ffffffaa', marginTop: 4, fontWeight: 'bold' },
  menuContent: { padding: 16, gap: 12 },
  lockText: { color: '#ffd700', backgroundColor: '#ffd70018', borderWidth: 1, borderColor: '#ffd70066', padding: 12, borderRadius: 12, fontWeight: 'bold' },
  bossCard: { backgroundColor: '#ffffff10', borderWidth: 1.5, borderRadius: 14, padding: 14, alignItems: 'center', gap: 6 },
  bossIcon: { fontSize: 42 },
  bossName: { color: '#ffffff', fontSize: 24, fontWeight: 'bold', textAlign: 'center' },
  bossText: { color: '#ffffffbb', fontWeight: 'bold', textAlign: 'center' },
  progressBox: { backgroundColor: '#00000044', borderWidth: 1, borderColor: '#00f0ff55', borderRadius: 12, padding: 12, gap: 5 },
  progressLine: { color: '#ffffff', fontWeight: 'bold' },
  duelContent: { flex: 1, alignItems: 'center', justifyContent: 'space-evenly', paddingHorizontal: 14, paddingBottom: 10, width: '100%', zIndex: 1, elevation: 1 },
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
  resultModal: { width: '100%', maxWidth: 390, backgroundColor: '#1a0a2e', borderWidth: 1, borderColor: '#00f0ff88', borderRadius: 18, padding: 18, gap: 10, alignItems: 'stretch' },
  resultTitle: { fontSize: 30, fontWeight: 'bold', textAlign: 'center' },
  resultSubtitle: { color: '#ffffffcc', textAlign: 'center', fontWeight: 'bold' },
  rewardLine: { color: '#ffd700', fontWeight: 'bold', textAlign: 'center' },
  choiceCard: { flexDirection: 'row', alignItems: 'center', gap: 10, backgroundColor: '#ffffff12', borderWidth: 1.5, borderRadius: 12, padding: 12 },
  choiceIcon: { fontSize: 28 },
  choiceTextBox: { flex: 1 },
  choiceTitle: { color: '#ffffff', fontWeight: 'bold' },
  choiceText: { color: '#ffffffaa', fontSize: 12, marginTop: 2 },
});

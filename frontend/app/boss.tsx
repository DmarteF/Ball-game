import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Modal, ScrollView, StyleSheet, Text, TouchableOpacity, useWindowDimensions, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
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
import { applyArenaRunUpgrade, buyArenaUpgrade, chooseAiArenaRunUpgrade, createArenaState, DualArenaState, getArenaProgress, getArenaUpgradeCost, tickArenaPhysics } from '@/src/game/dualArena';
import { getSkinById } from '@/src/game/skins';
import { playSound } from '@/src/utils/audio';
import { getRandomUpgrades, getRarityColor, Upgrade } from '@/src/game/upgrades';
import { calculateFinalGameplayAttributes } from '@/src/game/playerAttributes';
import { UiIcon } from '@/src/components/UiIcon';
import { UpgradeIcon } from '@/src/components/UpgradeIcon';
import { MuteButton } from '@/src/components/MuteButton';
import { SkinIcon } from '@/src/components/SkinIcon';
import { getDualArenaSize, getSafePaddingBottom, getSafePaddingTop } from '@/src/utils/gameplayLayout';
import { startFrameLoop } from '@/src/utils/frameLoop';
import { getPerformanceFrameIntervalMs } from '@/src/utils/performance';
import { useTranslation } from '@/src/i18n';
import { useGameText } from '@/src/i18n/gameText';

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
  const dimensions = useWindowDimensions();
  const insets = useSafeAreaInsets();
  const game = useGame();
  const { t, language } = useTranslation();
  const gameText = useGameText();
  const unlocked = game.lifetimeStats.highestPhase >= 5 || game.level >= 5;
  const progress = normalizeBossProgress(game.bossProgress);
  const monthlyBoss = getMonthlyBoss();
  const localizedBoss = gameText.bossText(monthlyBoss);
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
  const [bossNotice, setBossNotice] = useState('');
  const [exitConfirmVisible, setExitConfirmVisible] = useState(false);
  const [clock, setClock] = useState(getResetTimes());
  const finishing = useRef(false);
  const playerArenaRef = useRef<DualArenaState | null>(null);
  const playerSkin = getSkinById(game.ballTransformation);
  const bossSkin = getSkinById(monthlyBoss.skinId);
  const arenaSize = useMemo(
    () => getDualArenaSize({ width: dimensions.width, height: dimensions.height, insets }),
    [dimensions.width, dimensions.height, insets]
  );

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
    try {
      const level = completed ? monthlyBoss.levels[monthlyBoss.levels.length - 1] : getNextBossLevel(normalizeBossProgress(game.bossProgress));
      const safeArenaSize = Math.max(118, arenaSize);
      const startAttrs = calculateFinalGameplayAttributes({
        stats: game.stats,
        skin: playerSkin,
        permanentUpgrades: game.permanentUpgrades,
      });
      setActiveLevel(level);
      setPlayerArena(createArenaState({
        id: 'player',
        name: game.nickname || 'Você',
        skinIcon: playerSkin.icon,
        skinImageAsset: playerSkin.imageAsset,
        skinColor: playerSkin.primaryColor,
        size: safeArenaSize,
        phase: level.phase,
        ringConfig: createBossRingConfig(level, safeArenaSize, [playerSkin.primaryColor, '#ffffff88', '#ffd700aa'], 'player'),
        speedMultiplier: startAttrs.speedMultiplier,
        damageMultiplier: startAttrs.damageMultiplier,
      }));
      setBossArena(createArenaState({
        id: 'boss',
        name: monthlyBoss.name,
        skinIcon: bossSkin.icon,
        skinImageAsset: bossSkin.imageAsset,
        skinColor: bossSkin.primaryColor,
        size: safeArenaSize,
        phase: level.phase,
        ringConfig: createBossRingConfig(level, safeArenaSize, monthlyBoss.colors, 'boss'),
        aiQuality: level.aiQuality,
        speedMultiplier: level.bossSpeedMultiplier,
        damageMultiplier: level.bossDamageMultiplier,
      }));
      finishing.current = false;
      setResultRewards([]);
      setRunUpgrades({});
      setLevelChoices([]);
      setBossNotice('');
      setDuelState('playing');
    } catch (error) {
      setBossNotice(error instanceof Error ? error.message : 'Boss indisponível');
      setDuelState('menu');
      playSound('buttonError', game.settings.sound);
    }
  };

  useEffect(() => {
    if (duelState !== 'playing') return;
    const stopLoop = startFrameLoop((deltaTime) => {
      setPlayerArena(current => {
        if (!current) return current;
        const beforeLevel = current.level;
        const attrs = calculateFinalGameplayAttributes({
          stats: game.stats,
          skin: playerSkin,
          temporaryUpgrades: runUpgrades,
          arenaAtk: current.atk,
          arenaGold: current.gold,
          permanentUpgrades: game.permanentUpgrades,
        });
        const tick = tickArenaPhysics(current, {
          damageMultiplier: attrs.damageMultiplier,
          coinMultiplier: attrs.coinMultiplier,
          xpMultiplier: attrs.xpMultiplier,
          speedMultiplier: attrs.speedMultiplier,
          shrinkMultiplier: attrs.ringShrinkMultiplier,
          ringMinGap: 8,
          skinPassive: playerSkin.passive,
          skinLevel: game.skinLevels[playerSkin.id] || 1,
          deltaTime,
        });
        const result = tick.state;
        if (tick.brokeRing) playSound(tick.brokeSolid ? 'hitHeavy' : 'ringBreak', game.settings.sound);
        if (tick.skinEffectLabel) playSound('combo', game.settings.sound);
        if (result.level > beforeLevel && levelChoices.length === 0) {
          setLevelChoices(getRandomUpgrades(3, runUpgrades, game.level, game.unlockedUpgrades));
          playSound('levelUp', game.settings.sound);
          setDuelState('paused');
        }
        return result;
      });
      setBossArena(current => {
        if (!current) return current;
        const beforeLevel = current.level;
        const bossAttrs = calculateFinalGameplayAttributes({
          stats: game.stats,
          skin: bossSkin,
          temporaryUpgrades: current.runUpgrades,
          arenaAtk: current.atk,
          arenaGold: current.gold,
          modeBonus: {
            damageMultiplier: activeLevel.bossDamageMultiplier,
            speedMultiplier: activeLevel.bossSpeedMultiplier,
          },
        });
        const tick = tickArenaPhysics(current, {
          isAi: true,
          opponentProgress: playerArenaRef.current ? getArenaProgress(playerArenaRef.current) : 0,
          shrinkMultiplier: activeLevel.bossShrinkMultiplier,
          damageMultiplier: bossAttrs.damageMultiplier,
          coinMultiplier: bossAttrs.coinMultiplier,
          xpMultiplier: bossAttrs.xpMultiplier,
          speedMultiplier: bossAttrs.speedMultiplier,
          ringMinGap: 8,
          skinPassive: bossSkin.passive,
          skinLevel: game.skinLevels[bossSkin.id] || 1,
          deltaTime,
        });
        let next = tick.state;
        if (tick.brokeRing) playSound(tick.brokeSolid ? 'hitHeavy' : 'ringBreak', game.settings.sound);
        if (tick.skinEffectLabel) playSound('combo', game.settings.sound);
        if (next.level > beforeLevel) {
          const aiUpgrade = chooseAiArenaRunUpgrade(next, {
            opponentProgress: playerArenaRef.current ? getArenaProgress(playerArenaRef.current) : 0,
            bossPhase: activeLevel.phase,
          });
          if (aiUpgrade) {
            next = applyArenaRunUpgrade(next, aiUpgrade.id);
            setBossNotice(`Boss fortaleceu: ${aiUpgrade.name}`);
          }
        } else if (tick.skinEffectLabel && Math.random() < 0.14) {
          setBossNotice(tick.skinEffectLabel);
        }
        return next;
      });
    }, { minIntervalMs: getPerformanceFrameIntervalMs(game.settings) });
    return stopLoop;
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
    const attrs = calculateFinalGameplayAttributes({
      stats: game.stats,
      skin: playerSkin,
      temporaryUpgrades: runUpgrades,
      arenaAtk: playerArenaRef.current?.atk || 0,
      arenaGold: playerArenaRef.current?.gold || 0,
      permanentUpgrades: game.permanentUpgrades,
    });
    const xp = Math.floor((won ? (alreadyClaimed ? 35 : reward.xp) : Math.floor(reward.xp * 0.3)) * attrs.xpMultiplier);
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
    setPlayerArena(current => current ? buyArenaUpgrade(current, type) : current);
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
    setPlayerArena(current => current ? applyArenaRunUpgrade(current, upgrade.id) : current);
    setLevelChoices([]);
    setDuelState('playing');
  };

  const monthlyBest = progress.monthlyBestLevelWon === 'none' ? 'Nenhum' : monthlyBoss.levels.find(level => level.id === progress.monthlyBestLevelWon)?.name || 'Nenhum';

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      {duelState !== 'menu' && playerArena && bossArena ? (
        <View style={[styles.topHUD, { paddingTop: getSafePaddingTop(insets, 45) }]}>
          <View style={styles.hudRow}>
            <View style={styles.hudItem}><UiIcon iconKey="ui_coin" fallback="💰" size={18} /><Text style={styles.hudValue}>{playerArena.coins}</Text></View>
            <View style={styles.hudItem}><UiIcon iconKey="ui_achievements" fallback="⭐" size={18} /><Text style={styles.hudValue}>Lv.{playerArena.level}</Text></View>
            <MuteButton size={38} />
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
          <View style={styles.progressTextRow}><UiIcon iconKey="ui_aura" fallback="🌀" size={14} /><Text style={styles.progressText}>Anéis: {playerArena.rings.filter(ring => ring.status === 'active' && ring.hp > 0).length}/{playerArena.rings.length} {playerArena.combo >= 2 ? `• Combo x${playerArena.combo}` : ''}</Text></View>
        </View>
      ) : null}

      {duelState === 'menu' && (
        <ScrollView
          style={styles.menuScroll}
          contentContainerStyle={[
            styles.menuContent,
            {
              minHeight: dimensions.height,
              paddingTop: getSafePaddingTop(insets, 52),
              paddingBottom: getSafePaddingBottom(insets),
            },
          ]}
          showsVerticalScrollIndicator={false}
        >
          <View style={styles.header}>
            <NeonButton title={`← ${t('common.back').toUpperCase()}`} variant="secondary" audioSettings={game.settings} onPress={() => router.back()} style={styles.backButton} />
            <Text style={styles.title}>BOSS MODE</Text>
            <Text style={styles.subtitle}>{language === 'pt-BR' ? 'Boss do mês' : 'Monthly boss'}: {localizedBoss.name}</Text>
            {!!bossNotice && <Text style={styles.noticeText}>{bossNotice}</Text>}
          </View>
          {!unlocked && <Text style={styles.lockText}>Complete a fase 5 ou alcance nível de perfil 5 para desbloquear.</Text>}
          <View style={[styles.bossCard, { borderColor: bossSkin.primaryColor }]}>
            <SkinIcon skin={bossSkin} size={84} style={styles.bossSkinIcon} />
            <Text style={styles.bossName}>{localizedBoss.name}</Text>
            <Text style={styles.bossText}>{language === 'pt-BR' ? 'Tema' : 'Theme'}: {localizedBoss.theme}</Text>
            <Text style={styles.bossText}>{localizedBoss.description}</Text>
            <Text style={styles.bossText}>{language === 'pt-BR' ? 'Passiva' : 'Passive'}: {localizedBoss.passive}</Text>
            <Text style={styles.bossText}>Mês ativo: {getBossMonthKey()}</Text>
          </View>
          <View style={styles.progressBox}>
            <Text style={styles.progressLine}>{language === 'pt-BR' ? 'Nível atual' : 'Current level'}: {completed ? (language === 'pt-BR' ? 'Concluído hoje' : 'Completed today') : gameText.bossLevelName(currentLevel)}</Text>
            <Text style={styles.progressLine}>Vitórias hoje: {Math.min(progress.dailyLevelWins.length, 5)}/5</Text>
            <Text style={styles.progressLine}>{language === 'pt-BR' ? 'Melhor nível do mês' : 'Best monthly level'}: {monthlyBest === 'Nenhum' ? (language === 'pt-BR' ? 'Nenhum' : 'None') : gameText.bossLevelName(monthlyBest)}</Text>
            <Text style={styles.progressLine}>Vitórias no mês: {progress.monthlyTotalWins}</Text>
            <Text style={styles.progressLine}>Impossível no mês: {progress.monthlyImpossibleWins}</Text>
            <Text style={styles.progressLine}>{language === 'pt-BR' ? 'Próxima recompensa' : 'Next reward'}: {completed ? (language === 'pt-BR' ? 'Rejogue por recompensa reduzida' : 'Replay for reduced reward') : describeBossReward(currentLevel.reward)}</Text>
            <Text style={styles.progressLine}>Reset diário: {clock.daily}</Text>
            <Text style={styles.progressLine}>Troca mensal: {clock.monthly}</Text>
          </View>
          <NeonButton title={completed ? (language === 'pt-BR' ? 'ENFRENTAR NOVAMENTE' : 'FIGHT AGAIN') : (language === 'pt-BR' ? 'ENFRENTAR' : 'FIGHT')} variant="primary" disabled={!unlocked} audioSettings={game.settings} onPress={startDuel} />
        </ScrollView>
      )}

      {(duelState === 'playing' || duelState === 'paused') && playerArena && bossArena && (
        <View style={[styles.duelContent, { paddingBottom: getSafePaddingBottom(insets) }]}>
          <DualArenaView arena={bossArena} meta={bossNotice || `${activeLevel.name} • ${bossArena.coins} moedas`} accent="#ff4fd8" leader={getArenaProgress(bossArena) > getArenaProgress(playerArena)} />
          <DualArenaView arena={playerArena} meta={`Moedas ${playerArena.coins} • XP ${playerArena.xp} • Lv.${playerArena.level}`} accent="#00f0ff" leader={getArenaProgress(playerArena) >= getArenaProgress(bossArena)} />
          <View style={styles.shopRow}>
            {(['atk', 'gold'] as const).map(type => {
              const cost = getArenaUpgradeCost(playerArena, type);
              const canBuy = playerArena.coins >= cost;
              return (
                <TouchableOpacity key={type} style={[styles.runUpgradeButton, !canBuy && styles.disabled]} onPress={() => buy(type)}>
                  <UiIcon iconKey={type === 'atk' ? 'ui_upgrades' : 'ui_coin'} fallback={type === 'atk' ? '⚔️' : '💰'} size={18} />
                  <Text style={styles.runUpgradeLabel}>{type === 'atk' ? 'ATK' : 'Gold'} Lv.{playerArena[type]}</Text>
                  <View style={styles.runUpgradeCostRow}><Text style={styles.runUpgradeCost}>{cost}</Text><UiIcon iconKey="ui_coin" fallback="💰" size={12} /></View>
                </TouchableOpacity>
              );
            })}
            <NeonButton title={t('common.exit').toUpperCase()} variant="danger" audioSettings={game.settings} onPress={confirmExit} />
          </View>
        </View>
      )}

      <Modal visible={duelState === 'result'} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.resultModal}>
            <Text style={[styles.resultTitle, { color: resultWon ? '#00ff88' : '#ff0055' }]}>{resultWon ? t('game.victory').toUpperCase() : t('game.defeat').toUpperCase()}</Text>
            <Text style={styles.resultSubtitle}>{resultWon ? (language === 'pt-BR' ? 'Resultado decidido pela arena real.' : 'Result decided by the real arena.') : (language === 'pt-BR' ? 'O Boss venceu na arena real.' : 'The Boss won in the real arena.')}</Text>
            {resultRewards.map(item => <Text key={item} style={styles.rewardLine}>{item}</Text>)}
            <NeonButton title={language === 'pt-BR' ? 'ENFRENTAR NOVAMENTE' : 'FIGHT AGAIN'} variant="primary" audioSettings={game.settings} onPress={startDuel} />
            {resultRewards.some(item => item.includes('Chaves') || item.includes('Baú')) && <NeonButton title={t('inventory.openChest').toUpperCase()} variant="primary" audioSettings={game.settings} onPress={() => router.replace('/inventory' as any)} />}
            <NeonButton title={`${t('common.back').toUpperCase()} BOSS`} variant="secondary" audioSettings={game.settings} onPress={() => setDuelState('menu')} />
            <NeonButton title={`${t('common.back').toUpperCase()} HOME`} variant="secondary" audioSettings={game.settings} onPress={() => router.replace('/' as any)} />
          </View>
        </View>
      </Modal>

      <Modal visible={exitConfirmVisible} transparent animationType="fade" onRequestClose={cancelExit}>
        <View style={styles.modalOverlay}>
          <View style={styles.resultModal}>
            <Text style={styles.resultTitle}>{language === 'pt-BR' ? 'SAIR DO BOSS?' : 'EXIT BOSS?'}</Text>
            <Text style={styles.resultSubtitle}>{language === 'pt-BR' ? 'A disputa atual será encerrada como derrota.' : 'The current duel will end as a defeat.'}</Text>
            <NeonButton title={t('common.exit').toUpperCase()} variant="danger" audioSettings={game.settings} onPress={leaveDuel} />
            <NeonButton title={t('common.cancel').toUpperCase()} variant="secondary" audioSettings={game.settings} onPress={cancelExit} />
          </View>
        </View>
      </Modal>

      <Modal visible={levelChoices.length > 0} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.resultModal}>
            <Text style={styles.resultTitle}>LEVEL UP</Text>
            <Text style={styles.resultSubtitle}>{t('game.chooseUpgrade')}</Text>
            {levelChoices.map(upgrade => (
              <TouchableOpacity key={upgrade.id} style={[styles.choiceCard, { borderColor: getRarityColor(upgrade.rarity) }]} onPress={() => chooseLevelUpgrade(upgrade)}>
                <UpgradeIcon upgrade={upgrade} size={28} />
                <View style={styles.choiceTextBox}>
                  <Text style={styles.choiceTitle}>{gameText.upgradeName(upgrade)} Lv.{(runUpgrades[upgrade.id] || 0) + 1}</Text>
                  <Text style={styles.choiceText}>{gameText.upgradeDescription(upgrade)}</Text>
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
  header: { paddingBottom: 8 },
  topHUD: { paddingTop: 45, paddingHorizontal: 12, paddingBottom: 4, zIndex: 20, elevation: 20 },
  hudRow: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 8, gap: 6 },
  hudItem: { flex: 1, flexDirection: 'row', backgroundColor: '#ffffff11', paddingVertical: 8, paddingHorizontal: 10, borderRadius: 10, borderWidth: 1, borderColor: '#ffffff22', alignItems: 'center', justifyContent: 'center', gap: 6 },
  hudValue: { fontSize: 16, fontWeight: 'bold', color: '#00f0ff' },
  pauseMiniButton: { width: 42, height: 38, borderRadius: 10, backgroundColor: '#ffffff18', borderWidth: 1, borderColor: '#ffffff33', alignItems: 'center', justifyContent: 'center' },
  pauseMiniText: { color: '#ffffff', fontSize: 18, fontWeight: 'bold' },
  levelRow: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#ffffff11', padding: 8, borderRadius: 10, borderWidth: 1, borderColor: '#ffffff22', marginBottom: 4, gap: 10 },
  levelText: { fontSize: 14, fontWeight: 'bold', color: '#ffd700' },
  progressTextRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 5, marginBottom: 2 },
  progressText: { fontSize: 12, color: '#ffffff', textAlign: 'center', fontWeight: 'bold' },
  progressBar: { flex: 1, height: 14, backgroundColor: '#ffffff11', borderRadius: 7, overflow: 'hidden', borderWidth: 1, borderColor: '#ffffff22' },
  progressFill: { height: '100%' },
  backButton: { alignSelf: 'flex-start', minWidth: 110 },
  title: { color: '#00f0ff', fontSize: 30, fontWeight: 'bold', marginTop: 8 },
  subtitle: { color: '#ffffffaa', marginTop: 4, fontWeight: 'bold' },
  noticeText: { color: '#ffd700', marginTop: 6, fontSize: 12, fontWeight: 'bold' },
  menuScroll: { flex: 1 },
  menuContent: { paddingHorizontal: 16, gap: 12, flexGrow: 1 },
  lockText: { color: '#ffd700', backgroundColor: '#ffd70018', borderWidth: 1, borderColor: '#ffd70066', padding: 12, borderRadius: 12, fontWeight: 'bold' },
  bossCard: { backgroundColor: '#ffffff10', borderWidth: 1.5, borderRadius: 14, padding: 14, alignItems: 'center', gap: 6 },
  bossSkinIcon: { borderWidth: 0 },
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
  runUpgradeLabel: { color: '#ffffff', fontSize: 11, fontWeight: 'bold', marginTop: 2 },
  runUpgradeCostRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 3, marginTop: 2 },
  runUpgradeCost: { color: '#ffd700', fontSize: 11, fontWeight: 'bold', marginTop: 2 },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', justifyContent: 'center', alignItems: 'center', padding: 18 },
  resultModal: { width: '100%', maxWidth: 390, backgroundColor: '#1a0a2e', borderWidth: 1, borderColor: '#00f0ff88', borderRadius: 18, padding: 18, gap: 10, alignItems: 'stretch' },
  resultTitle: { fontSize: 30, fontWeight: 'bold', textAlign: 'center' },
  resultSubtitle: { color: '#ffffffcc', textAlign: 'center', fontWeight: 'bold' },
  rewardLine: { color: '#ffd700', fontWeight: 'bold', textAlign: 'center' },
  choiceCard: { flexDirection: 'row', alignItems: 'center', gap: 10, backgroundColor: '#ffffff12', borderWidth: 1.5, borderRadius: 12, padding: 12 },
  choiceTextBox: { flex: 1 },
  choiceTitle: { color: '#ffffff', fontWeight: 'bold' },
  choiceText: { color: '#ffffffaa', fontSize: 12, marginTop: 2 },
});

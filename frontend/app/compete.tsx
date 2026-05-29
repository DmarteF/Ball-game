import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Modal, StyleSheet, Text, TouchableOpacity, useWindowDimensions, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { DualArenaView } from '@/src/components/DualArenaView';
import { NeonButton } from '@/src/components/NeonButton';
import { useGame } from '@/src/contexts/GameContext';
import { applyArenaRunUpgrade, buyArenaUpgrade, chooseAiArenaRunUpgrade, createArenaState, DualArenaState, getArenaProgress, getArenaUpgradeCost, tickArenaPhysics } from '@/src/game/dualArena';
import { RewardGrant, describeReward } from '@/src/game/retention';
import { getSkinById } from '@/src/game/skins';
import { playSound } from '@/src/utils/audio';
import { GAMEPLAY_TUNING } from '@/src/game/balance';
import { getRandomUpgrades, getRarityColor, Upgrade } from '@/src/game/upgrades';
import { calculateFinalGameplayAttributes } from '@/src/game/playerAttributes';
import { UiIcon } from '@/src/components/UiIcon';
import { UpgradeIcon } from '@/src/components/UpgradeIcon';
import { MuteButton } from '@/src/components/MuteButton';
import { getDualArenaSize, getSafePaddingBottom, getSafePaddingTop } from '@/src/utils/gameplayLayout';
import { startFrameLoop } from '@/src/utils/frameLoop';
import { useGameText } from '@/src/i18n/gameText';
import { useTranslation } from '@/src/i18n';

type Result = { won: boolean; trophiesDelta: number; newPosition: number; rewards: RewardGrant[] };

export default function CompeteScreen() {
  const router = useRouter();
  const dimensions = useWindowDimensions();
  const insets = useSafeAreaInsets();
  const game = useGame();
  const gameText = useGameText();
  const { language } = useTranslation();
  const match = useMemo(() => game.createLeagueMatch(), []);
  const playerSkin = getSkinById(game.ballTransformation);
  const rivalSkin = getSkinById(match.rival.favoriteSkin);
  const [playerArena, setPlayerArena] = useState<DualArenaState | null>(null);
  const [rivalArena, setRivalArena] = useState<DualArenaState | null>(null);
  const [paused, setPaused] = useState(false);
  const [result, setResult] = useState<Result | null>(null);
  const [runUpgrades, setRunUpgrades] = useState<Record<string, number>>({});
  const [levelChoices, setLevelChoices] = useState<Upgrade[]>([]);
  const [rivalNotice, setRivalNotice] = useState('');
  const [exitConfirmVisible, setExitConfirmVisible] = useState(false);
  const finishing = useRef(false);
  const arenaTheme = language === 'pt-BR' ? match.map.theme : ({
    'Neon Azul': 'Blue Neon',
    'Vazio Roxo': 'Purple Void',
    'Inferno Vermelho': 'Red Inferno',
    'Gelo Cósmico': 'Cosmic Ice',
    'Dourado': 'Golden',
    Glitch: 'Glitch',
    Plasma: 'Plasma',
    Sombra: 'Shadow',
  }[match.map.theme] || match.map.theme);
  const arenaModifier = language === 'pt-BR' ? match.map.modifier : ({
    'Anéis rápidos': 'Fast rings',
    'Anéis resistentes': 'Resistant rings',
    'Aberturas maiores': 'Larger gaps',
    'Mais recompensa': 'More rewards',
    'Perfect favorável': 'Perfect friendly',
    'Fechamento lento': 'Slow closing',
    'Rotação invertida': 'Inverted rotation',
  }[match.map.modifier] || match.map.modifier);
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
  const arenaSize = useMemo(
    () => getDualArenaSize({ width: dimensions.width, height: dimensions.height, insets }),
    [dimensions.width, dimensions.height, insets]
  );

  const makeRingConfig = (side: 'player' | 'rival') => ({
    count: Math.max(8, Math.floor(match.map.rings * 0.42)),
    minCount: 8,
    countGrowth: 0.12,
    difficultyGrowth: 0.035,
    gapShrinkPerPhase: 0.005,
    minGapSize: Math.PI / 6.8,
    minSpacing: 8,
    safeStartRadius: 48,
    innerRadius: 34,
    outerRadius: arenaSize / 2 - 14,
    baseRotationSpeed: 0.0082 * match.map.rotationMultiplier,
    baseHp: 24 * match.map.hpMultiplier * (side === 'rival' ? 1 + match.rival.level / 120 : 1),
    baseGapSize: Math.min(1.18, Math.max(Math.PI / 6.6, 1.9 * match.map.gapMultiplier * GAMEPLAY_TUNING.league.gapScale)),
    baseThickness: 4,
    closingSpeed: 0.024 * match.map.closingMultiplier,
    colors: [side === 'rival' ? rivalSkin.primaryColor : playerSkin.primaryColor, match.map.color, '#ffffff88'],
    solidCount,
    solidHpMultiplier: rivalRank === 'top3' ? 1.9 : rivalRank === 'top10' ? 1.7 : rivalRank === 'strong' ? 1.5 : 1.35,
    maxCount: rivalRank === 'top3' ? 18 : rivalRank === 'top10' ? 16 : 14,
    spawnBatchSize: 4,
    respawnThreshold: 3,
  });

  const startMatch = () => {
    const startAttrs = calculateFinalGameplayAttributes({
      stats: game.stats,
      skin: playerSkin,
      permanentUpgrades: game.permanentUpgrades,
    });
    setPlayerArena(createArenaState({
      id: 'player',
      name: game.nickname || 'Você',
      skinIcon: playerSkin.icon,
      skinImageAsset: playerSkin.imageAsset,
      skinColor: playerSkin.primaryColor,
      size: arenaSize,
      phase: basePhase,
      ringConfig: makeRingConfig('player'),
      speedMultiplier: startAttrs.speedMultiplier,
      damageMultiplier: startAttrs.damageMultiplier,
    }));
    setRivalArena(createArenaState({
      id: 'rival',
      name: match.rival.name,
      skinIcon: rivalSkin.icon,
      skinImageAsset: rivalSkin.imageAsset,
      skinColor: rivalSkin.primaryColor,
      size: arenaSize,
      phase: basePhase,
      ringConfig: makeRingConfig('rival'),
      aiQuality: rivalRank === 'top3' ? 0.95 : rivalRank === 'top10' ? 0.88 : rivalRank === 'strong' ? 0.76 : rivalRank === 'medium' ? 0.62 : 0.46,
      speedMultiplier: 1 + match.rival.level / 120,
      damageMultiplier: 1 + match.rival.trophies / 9000,
    }));
    finishing.current = false;
    setResult(null);
    setRunUpgrades({});
    setLevelChoices([]);
    setRivalNotice('');
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
    if (paused || result || levelChoices.length > 0) return;
    const stopLoop = startFrameLoop(() => {
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
        });
        const next = tick.state;
        if (tick.brokeRing) playSound(tick.brokeSolid ? 'hitHeavy' : 'ringBreak', game.settings.sound);
        if (tick.skinEffectLabel) playSound('combo', game.settings.sound);
        if (next.level > beforeLevel && levelChoices.length === 0) {
          setLevelChoices(getRandomUpgrades(3, runUpgrades, game.level, game.unlockedUpgrades));
          playSound('levelUp', game.settings.sound);
          setPaused(true);
        }
        return next;
      });
      setRivalArena(current => {
        if (!current) return current;
        const beforeLevel = current.level;
        const rivalAttrs = calculateFinalGameplayAttributes({
          stats: game.stats,
          skin: rivalSkin,
          temporaryUpgrades: current.runUpgrades,
          arenaAtk: current.atk,
          arenaGold: current.gold,
          modeBonus: {
            damageMultiplier: 1 + Math.min(0.9, match.rival.trophies / 11000),
            speedMultiplier: 1 + match.rival.level / 180,
          },
        });
        const tick = tickArenaPhysics(current, {
          isAi: true,
          opponentProgress: playerArenaRef.current ? getArenaProgress(playerArenaRef.current) : 0,
          shrinkMultiplier: 1 + Math.min(0.18, match.rival.trophies / 50000),
          damageMultiplier: rivalAttrs.damageMultiplier,
          coinMultiplier: rivalAttrs.coinMultiplier,
          xpMultiplier: rivalAttrs.xpMultiplier,
          speedMultiplier: rivalAttrs.speedMultiplier,
          ringMinGap: 8,
          skinPassive: rivalSkin.passive,
          skinLevel: game.skinLevels[rivalSkin.id] || 1,
        });
        let next = tick.state;
        if (tick.brokeRing) playSound(tick.brokeSolid ? 'hitHeavy' : 'ringBreak', game.settings.sound);
        if (tick.skinEffectLabel) playSound('combo', game.settings.sound);
        if (next.level > beforeLevel) {
          const aiUpgrade = chooseAiArenaRunUpgrade(next, { opponentProgress: playerArenaRef.current ? getArenaProgress(playerArenaRef.current) : 0 });
          if (aiUpgrade) {
            next = applyArenaRunUpgrade(next, aiUpgrade.id);
            setRivalNotice(`Rival evoluiu: ${aiUpgrade.name}`);
          }
        } else if (tick.skinEffectLabel && Math.random() < 0.12) {
          setRivalNotice(tick.skinEffectLabel);
        }
        return next;
      });
    }, { minIntervalMs: 32 });
    return stopLoop;
  }, [paused, !!result, playerArena?.id, levelChoices.length, game.stats.baseDamage, game.stats.coinMultiplier, game.stats.xpMultiplier, runUpgrades, match.rival.trophies]);

  useEffect(() => {
    if (!playerArena || !rivalArena || finishing.current) return;
    if (!playerArena.finished && !rivalArena.finished && !playerArena.crushed && !rivalArena.crushed) return;
    const won = playerArena.finished || rivalArena.crushed;
    finishMatch(won);
  }, [playerArena?.finished, rivalArena?.finished, playerArena?.crushed, rivalArena?.crushed]);

  const finishMatch = async (won: boolean) => {
    if (finishing.current) return;
    finishing.current = true;
    setPaused(true);
    const rewardRoll = Math.random();
    const baseCoins = Math.round((won ? 420 : 140) * match.map.rewardMultiplier);
    const attrs = calculateFinalGameplayAttributes({
      stats: game.stats,
      skin: playerSkin,
      temporaryUpgrades: runUpgrades,
      arenaAtk: playerArenaRef.current?.atk || 0,
      arenaGold: playerArenaRef.current?.gold || 0,
      permanentUpgrades: game.permanentUpgrades,
    });
    const baseXp = Math.round((won ? 160 : 55) * match.map.rewardMultiplier * attrs.xpMultiplier);
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
    setPlayerArena(current => current ? buyArenaUpgrade(current, type) : current);
  };

  const confirmExit = () => {
    playSound('buttonClick', game.settings.sound);
    setPaused(true);
    setExitConfirmVisible(true);
  };

  const cancelExit = () => {
    playSound('buttonClick', game.settings.sound);
    setExitConfirmVisible(false);
    if (!finishing.current && !result) setPaused(false);
  };

  const leaveMatch = () => {
    playSound('buttonConfirm', game.settings.sound);
    setExitConfirmVisible(false);
    finishMatch(false);
  };

  const chooseLevelUpgrade = (upgrade: Upgrade) => {
    if (!playerArena) return;
    playSound('buttonConfirm', game.settings.sound);
    setRunUpgrades(prev => ({ ...prev, [upgrade.id]: (prev[upgrade.id] || 0) + 1 }));
    setPlayerArena(current => current ? applyArenaRunUpgrade(current, upgrade.id) : current);
    setLevelChoices([]);
    setPaused(false);
  };

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      {!playerArena || !rivalArena ? (
        <View style={[styles.header, { paddingTop: getSafePaddingTop(insets, 52) }]}>
          <NeonButton title={language === 'pt-BR' ? '← LIGA' : '← LEAGUE'} variant="secondary" audioSettings={game.settings} onPress={() => router.replace('/league' as any)} style={styles.backButton} />
          <Text style={styles.title}>{language === 'pt-BR' ? 'COMPETIR' : 'COMPETE'}</Text>
          <Text style={styles.subtitle}>{arenaTheme} • {arenaModifier} • {match.rival.trophies.toLocaleString('pt-BR')} {language === 'pt-BR' ? 'troféus' : 'trophies'}</Text>
        </View>
      ) : (
        <View style={[styles.topHUD, { paddingTop: getSafePaddingTop(insets, 45) }]}>
          <View style={styles.hudRow}>
            <View style={styles.hudItem}><UiIcon iconKey="ui_coin" fallback="💰" size={18} /><Text style={styles.hudValue}>{playerArena.coins}</Text></View>
            <View style={styles.hudItem}><UiIcon iconKey="ui_achievements" fallback="⭐" size={18} /><Text style={styles.hudValue}>Lv.{playerArena.level}</Text></View>
            <MuteButton size={38} />
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
          <View style={styles.progressTextRow}><UiIcon iconKey="ui_aura" fallback="🌀" size={14} /><Text style={styles.progressText}>Anéis: {playerArena.rings.filter(ring => ring.status === 'active' && ring.hp > 0).length}/{playerArena.rings.length} {playerArena.combo >= 2 ? `• Combo x${playerArena.combo}` : ''}</Text></View>
        </View>
      )}

      {playerArena && rivalArena && (
        <View style={[styles.arenas, { paddingBottom: getSafePaddingBottom(insets) }]}>
          <DualArenaView arena={rivalArena} meta={rivalNotice || `${match.rival.division} • ${rivalArena.coins} moedas`} accent="#ff4fd8" leader={getArenaProgress(rivalArena) > getArenaProgress(playerArena)} />
          <DualArenaView arena={playerArena} meta={`Moedas ${playerArena.coins} • XP ${playerArena.xp} • Lv.${playerArena.level}`} accent="#00f0ff" leader={getArenaProgress(playerArena) >= getArenaProgress(rivalArena)} />
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
            <NeonButton title={language === 'pt-BR' ? 'SAIR' : 'EXIT'} variant="danger" audioSettings={game.settings} onPress={confirmExit} />
          </View>
        </View>
      )}

      <Modal visible={!!result} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.resultBox}>
            <Text style={[styles.resultTitle, { color: result?.won ? '#00ff88' : '#ff4fd8' }]}>{result?.won ? (language === 'pt-BR' ? 'VITÓRIA' : 'VICTORY') : (language === 'pt-BR' ? 'DERROTA' : 'DEFEAT')}</Text>
            <Text style={styles.resultText}>{language === 'pt-BR' ? 'Resultado definido pela partida real contra' : 'Result decided by the real match against'} {match.rival.name}</Text>
            <Text style={styles.trophyDelta}>{result?.trophiesDelta || 0} {language === 'pt-BR' ? 'troféus' : 'trophies'}</Text>
            <Text style={styles.resultText}>{language === 'pt-BR' ? 'Nova posição' : 'New rank'}: #{result?.newPosition}</Text>
            {result?.rewards.map(reward => <Text key={describeReward(reward)} style={styles.rewardLine}>{gameText.rewardText(reward)}</Text>)}
            <NeonButton title={language === 'pt-BR' ? 'COMPETIR NOVAMENTE' : 'COMPETE AGAIN'} variant="primary" audioSettings={game.settings} onPress={startMatch} />
            {result?.rewards.some(reward => reward.type === 'keys' || reward.type === 'chest') && <NeonButton title={language === 'pt-BR' ? 'ABRIR INVENTÁRIO' : 'OPEN INVENTORY'} variant="primary" audioSettings={game.settings} onPress={() => router.replace('/inventory' as any)} />}
            <NeonButton title={language === 'pt-BR' ? 'VOLTAR PARA LIGA' : 'BACK TO LEAGUE'} variant="secondary" audioSettings={game.settings} onPress={() => router.replace('/league' as any)} />
            <NeonButton title={language === 'pt-BR' ? 'VOLTAR PARA HOME' : 'BACK TO HOME'} variant="secondary" audioSettings={game.settings} onPress={() => router.replace('/' as any)} />
          </View>
        </View>
      </Modal>
      <Modal visible={exitConfirmVisible} transparent animationType="fade" onRequestClose={cancelExit}>
        <View style={styles.modalOverlay}>
          <View style={styles.resultBox}>
            <Text style={styles.resultTitle}>{language === 'pt-BR' ? 'SAIR DA LIGA?' : 'EXIT LEAGUE?'}</Text>
            <Text style={styles.resultText}>{language === 'pt-BR' ? 'A partida atual será encerrada como derrota.' : 'The current match will end as a defeat.'}</Text>
            <NeonButton title={language === 'pt-BR' ? 'SAIR' : 'EXIT'} variant="danger" audioSettings={game.settings} onPress={leaveMatch} />
            <NeonButton title={language === 'pt-BR' ? 'CANCELAR' : 'CANCEL'} variant="secondary" audioSettings={game.settings} onPress={cancelExit} />
          </View>
        </View>
      </Modal>
      <Modal visible={levelChoices.length > 0} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.resultBox}>
            <Text style={styles.resultTitle}>LEVEL UP</Text>
            <Text style={styles.resultText}>{language === 'pt-BR' ? 'Escolha uma melhoria temporária.' : 'Choose a temporary upgrade.'}</Text>
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
  header: { paddingTop: 52, paddingHorizontal: 16, paddingBottom: 6 },
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
  backButton: { alignSelf: 'flex-start', minWidth: 100 },
  title: { color: '#ffffff', fontSize: 28, fontWeight: 'bold', marginTop: 8 },
  subtitle: { color: '#ffffff99', fontWeight: 'bold', marginTop: 3 },
  arenas: { flex: 1, paddingHorizontal: 14, paddingBottom: 10, gap: 8, justifyContent: 'space-evenly', width: '100%', zIndex: 1, elevation: 1 },
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
  resultBox: { width: '100%', maxWidth: 390, backgroundColor: '#1a0a2e', borderWidth: 1, borderColor: '#00f0ff88', borderRadius: 18, padding: 18, gap: 10, alignItems: 'stretch' },
  resultTitle: { fontSize: 30, fontWeight: 'bold', textAlign: 'center' },
  resultText: { color: '#ffffff', fontWeight: 'bold', textAlign: 'center' },
  trophyDelta: { color: '#ffd700', fontSize: 24, fontWeight: 'bold', textAlign: 'center' },
  rewardLine: { color: '#00ff88', fontWeight: 'bold', textAlign: 'center' },
  choiceCard: { flexDirection: 'row', alignItems: 'center', gap: 10, backgroundColor: '#ffffff12', borderWidth: 1.5, borderRadius: 12, padding: 12 },
  choiceTextBox: { flex: 1 },
  choiceTitle: { color: '#ffffff', fontWeight: 'bold' },
  choiceText: { color: '#ffffffaa', fontSize: 12, marginTop: 2 },
});

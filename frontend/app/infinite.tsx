import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Modal, StyleSheet, Text, TouchableOpacity, useWindowDimensions, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { DualArenaView } from '@/src/components/DualArenaView';
import { NeonButton } from '@/src/components/NeonButton';
import { useGame } from '@/src/contexts/GameContext';
import { GAMEPLAY_TUNING } from '@/src/game/balance';
import { applyArenaRunUpgrade, createArenaState, DualArenaState, getArenaUpgradeCost, buyArenaUpgrade, tickArenaPhysics } from '@/src/game/dualArena';
import { getRandomUpgrades, getRarityColor, Upgrade } from '@/src/game/upgrades';
import { getSkinById } from '@/src/game/skins';
import { playSound } from '@/src/utils/audio';
import { calculateFinalGameplayAttributes } from '@/src/game/playerAttributes';
import { clampRingSpacing, Ring } from '@/src/game/rings';
import { UiIcon } from '@/src/components/UiIcon';
import { UpgradeIcon } from '@/src/components/UpgradeIcon';
import { MuteButton } from '@/src/components/MuteButton';
import { getSafePaddingBottom, getSafePaddingTop, getSingleArenaSize } from '@/src/utils/gameplayLayout';
import { startFrameLoop } from '@/src/utils/frameLoop';

export default function InfiniteScreen() {
  const router = useRouter();
  const dimensions = useWindowDimensions();
  const insets = useSafeAreaInsets();
  const game = useGame();
  const skin = getSkinById(game.ballTransformation);
  const infiniteUnlocked = game.unlockedPhases.includes(6) || game.lifetimeStats.highestPhase >= 5;
  const [arena, setArena] = useState<DualArenaState | null>(null);
  const [paused, setPaused] = useState(false);
  const [finished, setFinished] = useState(false);
  const [wave, setWave] = useState(1);
  const [runUpgrades, setRunUpgrades] = useState<Record<string, number>>({});
  const [choices, setChoices] = useState<Upgrade[]>([]);
  const [choiceMode, setChoiceMode] = useState<'level' | 'challenge'>('level');
  const [startedAt, setStartedAt] = useState(Date.now());
  const [seconds, setSeconds] = useState(0);
  const [ringsBroken, setRingsBroken] = useState(0);
  const [challengeCount, setChallengeCount] = useState(0);
  const [activeChallengeId, setActiveChallengeId] = useState<string | null>(null);
  const [exitConfirmVisible, setExitConfirmVisible] = useState(false);
  const finishing = useRef(false);
  const ringsBrokenRef = useRef(0);
  const challengeCountRef = useRef(0);
  const arenaSize = useMemo(
    () => getSingleArenaSize({
      width: dimensions.width,
      height: dimensions.height,
      insets,
      hudHeight: GAMEPLAY_TUNING.infinite.safeHudReserve,
      controlsHeight: 62,
    }),
    [dimensions.width, dimensions.height, insets]
  );

  const makeArena = (nextWave: number, carry?: DualArenaState) => {
    const ramp = 1 + (nextWave - 1) * 0.08;
    const attrs = calculateFinalGameplayAttributes({
      stats: game.stats,
      skin,
      temporaryUpgrades: carry?.runUpgrades || runUpgrades,
      arenaAtk: carry?.atk || 0,
      arenaGold: carry?.gold || 0,
      permanentUpgrades: game.permanentUpgrades,
      modeBonus: { speedMultiplier: 1 + (nextWave - 1) * GAMEPLAY_TUNING.infinite.ballRampPerMinute * 0.12 },
    });
    return createArenaState({
      id: 'infinite',
      name: game.nickname || 'Você',
      skinIcon: skin.icon,
      skinImageAsset: skin.imageAsset,
      skinColor: skin.primaryColor,
      size: arenaSize,
      phase: Math.min(50, nextWave),
      speedMultiplier: attrs.speedMultiplier,
      damageMultiplier: attrs.damageMultiplier,
      ringConfig: {
        count: Math.min(42, 16 + Math.floor(nextWave * 1.15)),
        minCount: 14,
        countGrowth: 0.55,
        difficultyGrowth: 0.055,
        gapShrinkPerPhase: 0.012,
        minSpacing: 6,
        safeStartRadius: 52,
        innerRadius: 34,
        outerRadius: arenaSize / 2 - 12,
        baseRotationSpeed: 0.0085 * ramp,
        baseHp: 20 * ramp,
        baseGapSize: Math.max(Math.PI / 7.4, 1.85 * GAMEPLAY_TUNING.infinite.gapScale - nextWave * 0.018),
        baseThickness: 5,
        closingSpeed: 0.026 * GAMEPLAY_TUNING.infinite.ringClosingScale * ramp,
        colors: [skin.primaryColor, '#00f0ff', '#ff0055', '#ffd700', '#00ff88'],
        solidCount: Math.max(1, Math.floor(nextWave / 4)),
        solidHpMultiplier: 1.35 + nextWave * 0.02,
      },
    });
  };

  const createRingBatch = (current: DualArenaState, nextWave: number, challengeId?: string): Ring[] => {
    const source = makeArena(nextWave, current);
    const batchSize = challengeId ? 7 : Math.min(6, 3 + Math.floor(nextWave / 5));
    return source.rings.slice(-batchSize).map((ring, index) => {
      const radius = current.size / 2 - 12 - index * Math.max(5, ring.thickness + 1);
      const hp = Math.floor(ring.hp * (challengeId ? 1.22 : 1));
      return {
        ...ring,
        id: `${challengeId || 'inf_wave'}_${nextWave}_${index}_${Date.now()}`,
        radius,
        initialRadius: radius,
        hp,
        maxHp: hp,
        closingSpeed: ring.closingSpeed * (challengeId ? 1.18 : 1),
        rotationSpeed: ring.rotationSpeed * (challengeId ? 1.15 : 1),
        gapSize: ring.type === 'solid' ? 0 : Math.max(Math.PI / 8, ring.gapSize * (challengeId ? 0.72 : 0.9)),
      };
    });
  };

  const appendRingBatch = (current: DualArenaState, nextWave: number, challengeId?: string) => ({
    ...current,
    rings: clampRingSpacing([
      ...current.rings.filter(ring => ring.status === 'active' && ring.hp > 0),
      ...createRingBatch(current, nextWave, challengeId),
    ]),
  });

  const start = () => {
    if (!infiniteUnlocked) {
      playSound('buttonError', game.settings.sound);
      return;
    }
    setStartedAt(Date.now());
    setSeconds(0);
    setWave(1);
    setRunUpgrades({});
    setChoices([]);
    setChoiceMode('level');
    setRingsBroken(0);
    ringsBrokenRef.current = 0;
    setChallengeCount(0);
    challengeCountRef.current = 0;
    setActiveChallengeId(null);
    setFinished(false);
    finishing.current = false;
    setArena(makeArena(1));
    setPaused(false);
    playSound('buttonConfirm', game.settings.sound);
  };

  useEffect(() => {
    if (infiniteUnlocked) start();
    else playSound('buttonError', game.settings.sound);
  }, [infiniteUnlocked]);

  useEffect(() => {
    if (!infiniteUnlocked) return;
    if (paused || finished || choices.length > 0) return;
    const stopTimer = startFrameLoop(() => setSeconds(Math.floor((Date.now() - startedAt) / 1000)), { minIntervalMs: 1000 });
    const stopLoop = startFrameLoop(() => {
      setArena(current => {
        if (!current) return current;
        const beforeLevel = current.level;
        const attrs = calculateFinalGameplayAttributes({
          stats: game.stats,
          skin,
          temporaryUpgrades: runUpgrades,
          arenaAtk: current.atk,
          arenaGold: current.gold,
          permanentUpgrades: game.permanentUpgrades,
          modeBonus: {
            coinMultiplier: 1 + wave * 0.015,
            speedMultiplier: 1 + Math.min(0.3, wave * 0.008),
          },
        });
        const tick = tickArenaPhysics(current, {
          damageMultiplier: attrs.damageMultiplier,
          coinMultiplier: attrs.coinMultiplier,
          xpMultiplier: attrs.xpMultiplier,
          speedMultiplier: attrs.speedMultiplier,
          shrinkMultiplier: attrs.ringShrinkMultiplier,
          ringMinGap: 6,
          skinPassive: skin.passive,
          skinLevel: game.skinLevels[skin.id] || 1,
        });
        let result = tick.state;
        if (tick.brokeRing) {
          ringsBrokenRef.current += 1;
          setRingsBroken(ringsBrokenRef.current);
          playSound(tick.brokeSolid ? 'hitHeavy' : 'ringBreak', game.settings.sound);
        }
        if (tick.skinEffectLabel) {
          playSound('combo', game.settings.sound);
        }
        if (result.level > beforeLevel && choices.length === 0) {
          setChoiceMode('level');
          setChoices(getRandomUpgrades(3, runUpgrades, game.level, game.unlockedUpgrades));
          setPaused(true);
          playSound('levelUp', game.settings.sound);
        }
        if (activeChallengeId && !result.rings.some(ring => ring.status === 'active' && ring.id.startsWith(activeChallengeId))) {
          setActiveChallengeId(null);
          challengeCountRef.current += 1;
          setChallengeCount(challengeCountRef.current);
          setChoiceMode('challenge');
          setChoices(getRandomUpgrades(3, runUpgrades, game.level, game.unlockedUpgrades));
          setPaused(true);
          playSound('chestOpen', game.settings.sound);
        }
        const activeCount = result.rings.filter(ring => ring.status === 'active' && ring.hp > 0).length;
        if (result.finished || activeCount < 9) {
          const nextWave = wave + 1;
          const shouldChallenge = !activeChallengeId && nextWave > 1 && nextWave % 4 === 0;
          const nextChallengeId = shouldChallenge ? `challenge_${nextWave}` : undefined;
          if (nextChallengeId) setActiveChallengeId(nextChallengeId);
          setWave(nextWave);
          result = appendRingBatch(result, nextWave, nextChallengeId);
        }
        if (result.crushed) finish(false, result);
        return result;
      });
    }, { minIntervalMs: 32 });
    return () => {
      stopTimer();
      stopLoop();
    };
  }, [infiniteUnlocked, paused, finished, choices.length, startedAt, runUpgrades, wave, activeChallengeId]);

  const finish = async (_won: boolean, finalArena = arena) => {
    if (finishing.current) return;
    finishing.current = true;
    setFinished(true);
    setPaused(true);
    const survived = Math.max(seconds, Math.floor((Date.now() - startedAt) / 1000));
    await game.recordRunRewards({
      coins: finalArena?.coins || 0,
      profileXp: Math.floor((finalArena?.xp || 0) * 0.7 + survived * 0.8),
      ringsDestroyed: ringsBroken,
      runLevel: finalArena?.level || 1,
      runUpgrades: Object.values(runUpgrades).reduce((sum, value) => sum + value, 0),
      bestCombo: finalArena?.combo || 0,
      infiniteBestSeconds: survived,
      infiniteBestRings: ringsBrokenRef.current,
      infiniteBestLevel: finalArena?.level || 1,
      infiniteChallengeCompletions: challengeCountRef.current,
    });
    playSound('defeat', game.settings.sound);
  };

  const chooseUpgrade = (upgrade: Upgrade) => {
    if (!arena) return;
    playSound('buttonConfirm', game.settings.sound);
    setRunUpgrades(prev => ({ ...prev, [upgrade.id]: (prev[upgrade.id] || 0) + 1 }));
    setArena(current => current ? applyArenaRunUpgrade(current, upgrade.id) : current);
    setChoices([]);
    setPaused(false);
  };

  const exit = () => {
    playSound('buttonClick', game.settings.sound);
    setPaused(true);
    setExitConfirmVisible(true);
  };

  const cancelExit = () => {
    playSound('buttonClick', game.settings.sound);
    setExitConfirmVisible(false);
    if (!finishing.current && !finished) setPaused(false);
  };

  const leaveInfinite = () => {
    playSound('buttonConfirm', game.settings.sound);
    setExitConfirmVisible(false);
    finish(false);
  };

  const mm = Math.floor(seconds / 60);
  const ss = String(seconds % 60).padStart(2, '0');

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      {!infiniteUnlocked ? (
        <View style={styles.lockedScreen}>
          <UiIcon iconKey="ui_infinite" fallback="∞" size={72} />
          <Text style={styles.modalTitle}>MODO INFINITO BLOQUEADO</Text>
          <Text style={styles.resultText}>Complete a Fase 5 para desbloquear.</Text>
          <NeonButton title="VOLTAR PARA JOGAR" variant="secondary" audioSettings={game.settings} onPress={() => router.replace('/phase-select' as any)} />
        </View>
      ) : (
      <>
      <View style={[styles.hud, { paddingTop: getSafePaddingTop(insets, 46) }]}>
        <View style={styles.hudRow}>
          <View style={styles.badgeRow}><UiIcon iconKey="ui_infinite" fallback="∞" size={18} /><Text style={styles.badgeText}>{mm}:{ss}</Text></View>
          <Text style={styles.badge}>Onda {wave}</Text>
          <MuteButton size={38} />
          <TouchableOpacity style={styles.pauseButton} onPress={() => setPaused(value => !value)}><Text style={styles.pauseText}>{paused ? '▶' : '⏸'}</Text></TouchableOpacity>
        </View>
        <View style={styles.hudRow}>
          <View style={styles.badgeRow}><UiIcon iconKey="ui_coin" fallback="💰" size={18} /><Text style={styles.badgeText}>{arena?.coins || 0}</Text></View>
          <View style={styles.badgeRow}><UiIcon iconKey="ui_achievements" fallback="⭐" size={18} /><Text style={styles.badgeText}>Lv.{arena?.level || 1}</Text></View>
          <TouchableOpacity style={styles.exitButton} onPress={exit}><Text style={styles.exitText}>SAIR</Text></TouchableOpacity>
        </View>
      </View>

      <View style={[styles.playArea, { paddingBottom: getSafePaddingBottom(insets) }]}>
        {arena && <DualArenaView arena={arena} meta={`XP ${arena.xp} • ATK ${arena.atk} • Gold ${arena.gold} • Desafios ${challengeCount}`} accent="#00f0ff" leader />}
        {arena && (
          <View style={styles.shopRow}>
            {(['atk', 'gold'] as const).map(type => {
              const cost = getArenaUpgradeCost(arena, type);
              return (
                <TouchableOpacity key={type} style={[styles.buyButton, arena.coins < cost && styles.disabled]} onPress={() => {
                  if (arena.coins < cost) {
                    playSound('buttonError', game.settings.sound);
                    return;
                  }
                  playSound('buttonConfirm', game.settings.sound);
                  setArena(current => current ? buyArenaUpgrade(current, type) : current);
                }}>
                  <View style={styles.buyTextRow}>
                    <UiIcon iconKey={type === 'atk' ? 'ui_upgrades' : 'ui_coin'} fallback={type === 'atk' ? '⚔️' : '💰'} size={15} />
                    <Text style={styles.buyText}>{type === 'atk' ? `ATK Lv.${arena.atk}` : `Gold Lv.${arena.gold}`} • {cost}</Text>
                    <UiIcon iconKey="ui_coin" fallback="💰" size={13} />
                  </View>
                </TouchableOpacity>
              );
            })}
          </View>
        )}
      </View>

      <Modal visible={choices.length > 0} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.modalBox}>
            <Text style={styles.modalTitle}>{choiceMode === 'challenge' ? 'BAÚ DE UPGRADE' : 'LEVEL UP'}</Text>
            {choices.map(upgrade => (
              <TouchableOpacity key={upgrade.id} style={[styles.choiceCard, { borderColor: getRarityColor(upgrade.rarity) }]} onPress={() => chooseUpgrade(upgrade)}>
                <UpgradeIcon upgrade={upgrade} size={28} />
                <View style={styles.choiceTextBox}>
                  <Text style={styles.choiceTitle}>{upgrade.name} Lv.{(runUpgrades[upgrade.id] || 0) + 1}</Text>
                  <Text style={styles.choiceText}>{upgrade.description}</Text>
                </View>
              </TouchableOpacity>
            ))}
          </View>
        </View>
      </Modal>

      <Modal visible={finished} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.modalBox}>
            <Text style={styles.modalTitle}>RESULTADO INFINITO</Text>
            <Text style={styles.resultText}>Tempo: {mm}:{ss}</Text>
            <Text style={styles.resultText}>Recorde: {Math.floor((game.lifetimeStats.infiniteBestSeconds || 0) / 60)}:{String((game.lifetimeStats.infiniteBestSeconds || 0) % 60).padStart(2, '0')}</Text>
            <Text style={styles.resultText}>Moedas: {arena?.coins || 0}</Text>
            <Text style={styles.resultText}>XP: {arena?.xp || 0}</Text>
            <Text style={styles.resultText}>Anéis: {ringsBroken}</Text>
            <Text style={styles.resultText}>Desafios: {challengeCount}</Text>
            <NeonButton title="JOGAR NOVAMENTE" variant="primary" audioSettings={game.settings} onPress={start} />
            <NeonButton title="VOLTAR" variant="secondary" audioSettings={game.settings} onPress={() => router.replace('/' as any)} />
          </View>
        </View>
      </Modal>

      <Modal visible={exitConfirmVisible} transparent animationType="fade" onRequestClose={cancelExit}>
        <View style={styles.modalOverlay}>
          <View style={styles.modalBox}>
            <Text style={styles.modalTitle}>SAIR DO INFINITO?</Text>
            <Text style={styles.resultText}>A rodada será encerrada e as recompensas atuais serão salvas.</Text>
            <NeonButton title="SAIR" variant="danger" audioSettings={game.settings} onPress={leaveInfinite} />
            <NeonButton title="CANCELAR" variant="secondary" audioSettings={game.settings} onPress={cancelExit} />
          </View>
        </View>
      </Modal>
      </>
      )}
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  lockedScreen: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, gap: 14 },
  lockedIcon: { color: '#00f0ff', fontSize: 62, fontWeight: 'bold' },
  hud: { paddingTop: 46, paddingHorizontal: 12, gap: 8, zIndex: 20, elevation: 20 },
  hudRow: { flexDirection: 'row', gap: 8, alignItems: 'center' },
  badge: { flex: 1, color: '#ffffff', fontWeight: 'bold', textAlign: 'center', backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#ffffff22', borderRadius: 10, paddingVertical: 8, overflow: 'hidden' },
  badgeRow: { flex: 1, minHeight: 38, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 5, backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#ffffff22', borderRadius: 10, paddingVertical: 8 },
  badgeText: { color: '#ffffff', fontWeight: 'bold' },
  pauseButton: { width: 44, height: 38, borderRadius: 10, backgroundColor: '#ffffff18', borderWidth: 1, borderColor: '#ffffff33', alignItems: 'center', justifyContent: 'center' },
  pauseText: { color: '#ffffff', fontWeight: 'bold' },
  exitButton: { minWidth: 72, height: 38, borderRadius: 10, backgroundColor: '#330816', borderWidth: 1, borderColor: '#ff4d6d', alignItems: 'center', justifyContent: 'center' },
  exitText: { color: '#ffccd6', fontWeight: 'bold' },
  playArea: { flex: 1, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 12, paddingBottom: 10, zIndex: 1 },
  shopRow: { width: '100%', flexDirection: 'row', gap: 8, marginTop: 8 },
  buyButton: { flex: 1, minHeight: 48, borderRadius: 10, backgroundColor: '#06162a', borderWidth: 1.5, borderColor: '#00f0ffaa', alignItems: 'center', justifyContent: 'center' },
  buyTextRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 4 },
  buyText: { color: '#ffffff', fontWeight: 'bold' },
  disabled: { opacity: 0.45 },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', alignItems: 'center', justifyContent: 'center', padding: 18 },
  modalBox: { width: '100%', maxWidth: 390, backgroundColor: '#1a0a2e', borderWidth: 1, borderColor: '#00f0ff88', borderRadius: 18, padding: 18, gap: 10 },
  modalTitle: { color: '#00f0ff', fontSize: 24, fontWeight: 'bold', textAlign: 'center' },
  resultText: { color: '#ffffff', fontWeight: 'bold', textAlign: 'center' },
  choiceCard: { flexDirection: 'row', alignItems: 'center', gap: 10, backgroundColor: '#ffffff12', borderWidth: 1.5, borderRadius: 12, padding: 12 },
  choiceTextBox: { flex: 1 },
  choiceTitle: { color: '#ffffff', fontWeight: 'bold' },
  choiceText: { color: '#ffffffaa', fontSize: 12, marginTop: 2 },
});

import React, { useEffect, useRef, useState } from 'react';
import { Dimensions, Modal, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { DualArenaView } from '@/src/components/DualArenaView';
import { NeonButton } from '@/src/components/NeonButton';
import { useGame } from '@/src/contexts/GameContext';
import { GAMEPLAY_TUNING } from '@/src/game/balance';
import { applyArenaRunUpgrade, createArenaState, DualArenaState, getArenaUpgradeCost, buyArenaUpgrade, tickArenaPhysics } from '@/src/game/dualArena';
import { getRandomUpgrades, getRarityColor, Upgrade } from '@/src/game/upgrades';
import { getSkinById } from '@/src/game/skins';
import { playSound } from '@/src/utils/audio';

const { width, height } = Dimensions.get('window');
const ARENA_SIZE = Math.max(220, Math.min(width - 24, height - GAMEPLAY_TUNING.infinite.safeHudReserve));

export default function InfiniteScreen() {
  const router = useRouter();
  const game = useGame();
  const skin = getSkinById(game.ballTransformation);
  const skinDamageBonus = ['damage_multiplier', 'cosmic_critical', 'league_king_wave'].includes(skin.passive.type) ? skin.passive.value : 0;
  const skinSpeedBonus = skin.passive.type === 'speed' ? skin.passive.value : 0;
  const skinCoinBonus = ['coin_multiplier', 'cosmic_critical', 'league_starter_champion', 'league_king_wave'].includes(skin.passive.type) ? skin.passive.value * 0.6 : 0;
  const skinXpBonus = ['xp_multiplier', 'cosmic_critical', 'league_starter_champion', 'league_king_wave'].includes(skin.passive.type) ? skin.passive.value * 0.5 : 0;
  const [arena, setArena] = useState<DualArenaState | null>(null);
  const [paused, setPaused] = useState(false);
  const [finished, setFinished] = useState(false);
  const [wave, setWave] = useState(1);
  const [runUpgrades, setRunUpgrades] = useState<Record<string, number>>({});
  const [choices, setChoices] = useState<Upgrade[]>([]);
  const [startedAt, setStartedAt] = useState(Date.now());
  const [seconds, setSeconds] = useState(0);
  const [ringsBroken, setRingsBroken] = useState(0);
  const [exitConfirmVisible, setExitConfirmVisible] = useState(false);
  const finishing = useRef(false);

  const makeArena = (nextWave: number, carry?: DualArenaState) => {
    const ramp = 1 + (nextWave - 1) * 0.08;
    return createArenaState({
      id: 'infinite',
      name: game.nickname || 'Você',
      skinIcon: skin.icon,
      skinColor: skin.primaryColor,
      size: ARENA_SIZE,
      phase: Math.min(50, nextWave),
      speedMultiplier: (1 + game.stats.baseSpeed / 1200 + skinSpeedBonus) * (1 + (nextWave - 1) * GAMEPLAY_TUNING.infinite.ballRampPerMinute * 0.12),
      damageMultiplier: 1 + game.stats.baseDamage / 220 + skinDamageBonus,
      ringConfig: {
        count: Math.min(42, 16 + Math.floor(nextWave * 1.15)),
        innerRadius: 34,
        outerRadius: ARENA_SIZE / 2 - 12,
        baseRotationSpeed: 0.0085 * ramp,
        baseHp: 20 * ramp,
        baseGapSize: Math.max(Math.PI / 8, 2.35 * GAMEPLAY_TUNING.infinite.gapScale - nextWave * 0.025),
        baseThickness: 5,
        closingSpeed: 0.026 * GAMEPLAY_TUNING.infinite.ringClosingScale * ramp,
        colors: [skin.primaryColor, '#00f0ff', '#ff0055', '#ffd700', '#00ff88'],
        solidCount: Math.max(1, Math.floor(nextWave / 4)),
        solidHpMultiplier: 1.35 + nextWave * 0.02,
      },
    });
  };

  const start = () => {
    setStartedAt(Date.now());
    setSeconds(0);
    setWave(1);
    setRunUpgrades({});
    setChoices([]);
    setRingsBroken(0);
    setFinished(false);
    finishing.current = false;
    setArena(makeArena(1));
    setPaused(false);
    playSound('buttonConfirm', game.settings.sound);
  };

  useEffect(() => {
    start();
  }, []);

  useEffect(() => {
    if (paused || finished || choices.length > 0) return;
    const timer = setInterval(() => setSeconds(Math.floor((Date.now() - startedAt) / 1000)), 1000);
    const loop = setInterval(() => {
      setArena(current => {
        if (!current) return current;
        const beforeLevel = current.level;
        const result = tickArenaPhysics(current, {
          damageMultiplier: (1 + game.stats.baseDamage / 240 + skinDamageBonus) * (1 + (runUpgrades.damage || 0) * 0.16),
          coinMultiplier: game.stats.coinMultiplier * (1 + skinCoinBonus + (runUpgrades.coinBoost || 0) * 0.24) * (1 + wave * 0.015),
          xpMultiplier: game.stats.xpMultiplier * (1 + skinXpBonus + (runUpgrades.xpBoost || 0) * 0.2),
          speedMultiplier: 1 + (runUpgrades.speed || 0) * 0.04 + Math.min(0.3, wave * 0.008),
          shrinkMultiplier: 1 - Math.min(0.24, (game.permanentUpgrades.slowRings || 0) * 0.018),
        }).state;
        if (result.level > beforeLevel && choices.length === 0) {
          setChoices(getRandomUpgrades(3, runUpgrades, game.level, game.unlockedUpgrades));
          setPaused(true);
          playSound('levelUp', game.settings.sound);
        }
        if (result.finished) {
          setRingsBroken(prev => prev + result.rings.length);
          setWave(prev => prev + 1);
          return { ...makeArena(wave + 1), coins: result.coins, xp: result.xp, level: result.level, atk: result.atk, gold: result.gold, runUpgrades: result.runUpgrades };
        }
        if (result.crushed) finish(false, result);
        return result;
      });
    }, 34);
    return () => {
      clearInterval(timer);
      clearInterval(loop);
    };
  }, [paused, finished, choices.length, startedAt, runUpgrades, wave]);

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
    });
    playSound('defeat', game.settings.sound);
  };

  const chooseUpgrade = (upgrade: Upgrade) => {
    if (!arena) return;
    playSound('buttonConfirm', game.settings.sound);
    setRunUpgrades(prev => ({ ...prev, [upgrade.id]: (prev[upgrade.id] || 0) + 1 }));
    setArena(applyArenaRunUpgrade(arena, upgrade.id));
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
      <View style={styles.hud}>
        <View style={styles.hudRow}>
          <Text style={styles.badge}>∞ {mm}:{ss}</Text>
          <Text style={styles.badge}>Onda {wave}</Text>
          <TouchableOpacity style={styles.pauseButton} onPress={() => setPaused(value => !value)}><Text style={styles.pauseText}>{paused ? '▶' : '⏸'}</Text></TouchableOpacity>
        </View>
        <View style={styles.hudRow}>
          <Text style={styles.badge}>💰 {arena?.coins || 0}</Text>
          <Text style={styles.badge}>⭐ Lv.{arena?.level || 1}</Text>
          <TouchableOpacity style={styles.exitButton} onPress={exit}><Text style={styles.exitText}>SAIR</Text></TouchableOpacity>
        </View>
      </View>

      <View style={styles.playArea}>
        {arena && <DualArenaView arena={arena} meta={`XP ${arena.xp} • ATK ${arena.atk} • Gold ${arena.gold}`} accent="#00f0ff" leader />}
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
                  setArena(buyArenaUpgrade(arena, type));
                }}>
                  <Text style={styles.buyText}>{type === 'atk' ? 'ATK' : 'Gold'} {cost} 💰</Text>
                </TouchableOpacity>
              );
            })}
          </View>
        )}
      </View>

      <Modal visible={choices.length > 0} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.modalBox}>
            <Text style={styles.modalTitle}>LEVEL UP</Text>
            {choices.map(upgrade => (
              <TouchableOpacity key={upgrade.id} style={[styles.choiceCard, { borderColor: getRarityColor(upgrade.rarity) }]} onPress={() => chooseUpgrade(upgrade)}>
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

      <Modal visible={finished} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.modalBox}>
            <Text style={styles.modalTitle}>RESULTADO INFINITO</Text>
            <Text style={styles.resultText}>Tempo: {mm}:{ss}</Text>
            <Text style={styles.resultText}>Recorde: {Math.floor((game.lifetimeStats.infiniteBestSeconds || 0) / 60)}:{String((game.lifetimeStats.infiniteBestSeconds || 0) % 60).padStart(2, '0')}</Text>
            <Text style={styles.resultText}>Moedas: {arena?.coins || 0}</Text>
            <Text style={styles.resultText}>XP: {arena?.xp || 0}</Text>
            <Text style={styles.resultText}>Anéis: {ringsBroken}</Text>
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
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  hud: { paddingTop: 46, paddingHorizontal: 12, gap: 8, zIndex: 20, elevation: 20 },
  hudRow: { flexDirection: 'row', gap: 8, alignItems: 'center' },
  badge: { flex: 1, color: '#ffffff', fontWeight: 'bold', textAlign: 'center', backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#ffffff22', borderRadius: 10, paddingVertical: 8, overflow: 'hidden' },
  pauseButton: { width: 44, height: 38, borderRadius: 10, backgroundColor: '#ffffff18', borderWidth: 1, borderColor: '#ffffff33', alignItems: 'center', justifyContent: 'center' },
  pauseText: { color: '#ffffff', fontWeight: 'bold' },
  exitButton: { minWidth: 72, height: 38, borderRadius: 10, backgroundColor: '#330816', borderWidth: 1, borderColor: '#ff4d6d', alignItems: 'center', justifyContent: 'center' },
  exitText: { color: '#ffccd6', fontWeight: 'bold' },
  playArea: { flex: 1, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 12, paddingBottom: 10, zIndex: 1 },
  shopRow: { width: '100%', flexDirection: 'row', gap: 8, marginTop: 8 },
  buyButton: { flex: 1, minHeight: 48, borderRadius: 10, backgroundColor: '#06162a', borderWidth: 1.5, borderColor: '#00f0ffaa', alignItems: 'center', justifyContent: 'center' },
  buyText: { color: '#ffffff', fontWeight: 'bold' },
  disabled: { opacity: 0.45 },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', alignItems: 'center', justifyContent: 'center', padding: 18 },
  modalBox: { width: '100%', maxWidth: 390, backgroundColor: '#1a0a2e', borderWidth: 1, borderColor: '#00f0ff88', borderRadius: 18, padding: 18, gap: 10 },
  modalTitle: { color: '#00f0ff', fontSize: 24, fontWeight: 'bold', textAlign: 'center' },
  resultText: { color: '#ffffff', fontWeight: 'bold', textAlign: 'center' },
  choiceCard: { flexDirection: 'row', alignItems: 'center', gap: 10, backgroundColor: '#ffffff12', borderWidth: 1.5, borderRadius: 12, padding: 12 },
  choiceIcon: { fontSize: 28 },
  choiceTextBox: { flex: 1 },
  choiceTitle: { color: '#ffffff', fontWeight: 'bold' },
  choiceText: { color: '#ffffffaa', fontSize: 12, marginTop: 2 },
});

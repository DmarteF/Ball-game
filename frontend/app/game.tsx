import React, { useState, useEffect, useRef } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Dimensions, Modal } from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import Animated, { useSharedValue, useAnimatedStyle } from 'react-native-reanimated';
import Svg, { Circle } from 'react-native-svg';
import { useGame } from '@/src/contexts/GameContext';
import {
  createRings,
  updateRing,
  findClosestCollidingRing,
  reflectBallOffRing,
  Ring,
} from '@/src/game/rings';
import { getRandomUpgrades, Upgrade, getRarityColor, getRarityName } from '@/src/game/upgrades';
import { FloatingNumber } from '@/src/components/FloatingNumber';
import { AdModal } from '@/src/components/AdModal';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');
const GAME_SIZE = Math.min(SCREEN_WIDTH, SCREEN_HEIGHT - 240) * 0.98;
const CENTER_X = GAME_SIZE / 2;
const CENTER_Y = GAME_SIZE / 2;
const BALL_RADIUS = 10;
const OUTER_RADIUS = GAME_SIZE / 2 - 8;
const INNER_RADIUS = 35;

interface FloatingNumberData {
  id: string;
  value: number;
  x: number;
  y: number;
  isCritical: boolean;
}

const PHASE_CONFIGS = [
  { ringCount: 20, baseHp: 30, closingSpeed: 0.015, rotationSpeed: 0.012 },
  { ringCount: 24, baseHp: 50, closingSpeed: 0.02, rotationSpeed: 0.015 },
  { ringCount: 28, baseHp: 80, closingSpeed: 0.025, rotationSpeed: 0.018 },
  { ringCount: 32, baseHp: 120, closingSpeed: 0.03, rotationSpeed: 0.022 },
  { ringCount: 36, baseHp: 180, closingSpeed: 0.035, rotationSpeed: 0.025 },
];

export default function GameScreen() {
  const router = useRouter();
  const { phase } = useLocalSearchParams();
  const { stats, updateCoins, updateGems, unlockPhase, gems } = useGame();
  
  const [isPaused, setIsPaused] = useState(false);
  const [showLevelUp, setShowLevelUp] = useState(false);
  const [showVictory, setShowVictory] = useState(false);
  const [showGameOver, setShowGameOver] = useState(false);
  const [showAdRevive, setShowAdRevive] = useState(false);
  const [showAdReroll, setShowAdReroll] = useState(false);
  
  const [coins, setCoins] = useState(0);
  const [xp, setXp] = useState(0);
  const [level, setLevel] = useState(1);
  const [score, setScore] = useState(0);
  const [dps, setDps] = useState(0);
  
  const [currentUpgrades, setCurrentUpgrades] = useState<Record<string, number>>({});
  const [availableUpgrades, setAvailableUpgrades] = useState<Upgrade[]>([]);
  const [floatingNumbers, setFloatingNumbers] = useState<FloatingNumberData[]>([]);
  const [rerollsUsed, setRerollsUsed] = useState(0);
  
  // Refs for game state
  const ringsRef = useRef<Ring[]>([]);
  const ballPosRef = useRef({ x: CENTER_X, y: CENTER_Y });
  const velocityRef = useRef({ x: 0, y: 0 });
  const isPausedRef = useRef(false);
  const isGameOverRef = useRef(false);
  const showLevelUpRef = useRef(false);
  const lastHitTimeRef = useRef(0);
  const initializedRef = useRef(false);
  const recentHitDpsRef = useRef<number[]>([]);
  
  const ballX = useSharedValue(CENTER_X);
  const ballY = useSharedValue(CENTER_Y);
  const [renderTick, setRenderTick] = useState(0);
  
  const gameLoopRef = useRef<NodeJS.Timeout | null>(null);
  const xpToNextLevel = level * 80;
  
  // Calculated stats
  const baseDamage = stats.baseDamage * (1 + (currentUpgrades['damage'] || 0) * 0.15);
  const critChance = stats.critChance + (currentUpgrades['critical'] || 0) * 5;
  const coinMultiplier = stats.coinMultiplier * (1 + (currentUpgrades['coinBoost'] || 0) * 0.5);
  const xpMultiplier = stats.xpMultiplier * (1 + (currentUpgrades['xpBoost'] || 0) * 0.5);
  const speedMultiplier = 1 + (currentUpgrades['speed'] || 0) * 0.2;

  useEffect(() => {
    initializeGame();
    return () => {
      if (gameLoopRef.current) clearInterval(gameLoopRef.current);
    };
  }, []);

  useEffect(() => { isPausedRef.current = isPaused; }, [isPaused]);
  useEffect(() => { showLevelUpRef.current = showLevelUp; }, [showLevelUp]);

  const initializeGame = () => {
    const phaseNumber = Number(phase) || 1;
    const config = PHASE_CONFIGS[phaseNumber - 1] || PHASE_CONFIGS[0];
    
    const newRings = createRings({
      count: config.ringCount,
      innerRadius: INNER_RADIUS,
      outerRadius: OUTER_RADIUS,
      baseRotationSpeed: config.rotationSpeed,
      baseHp: config.baseHp,
      baseGapSize: Math.PI / 3.5,
      baseThickness: 5,
      closingSpeed: config.closingSpeed,
      colors: ['#00f0ff', '#b000ff', '#ff0055', '#00ff88', '#ffd700', '#ff8800'],
    }, phaseNumber);
    
    ringsRef.current = newRings;
    
    // Initialize ball with random angle
    const startAngle = Math.random() * Math.PI * 2;
    const speed = 3.5;
    velocityRef.current = {
      x: Math.cos(startAngle) * speed,
      y: Math.sin(startAngle) * speed,
    };
    ballPosRef.current = { x: CENTER_X, y: CENTER_Y };
    
    initializedRef.current = true;
    startGameLoop();
  };

  const startGameLoop = () => {
    if (gameLoopRef.current) clearInterval(gameLoopRef.current);
    
    gameLoopRef.current = setInterval(() => {
      if (!isPausedRef.current && !isGameOverRef.current && !showLevelUpRef.current && initializedRef.current) {
        updateGame();
      }
    }, 16);
  };

  const updateGame = () => {
    const speed = Math.sqrt(
      velocityRef.current.x ** 2 + velocityRef.current.y ** 2
    );
    const targetSpeed = 3.5 * speedMultiplier;
    
    // Normalize speed
    if (speed > 0) {
      velocityRef.current.x = (velocityRef.current.x / speed) * targetSpeed;
      velocityRef.current.y = (velocityRef.current.y / speed) * targetSpeed;
    }
    
    // Move ball
    ballPosRef.current.x += velocityRef.current.x;
    ballPosRef.current.y += velocityRef.current.y;

    // Update animated position
    ballX.value = ballPosRef.current.x;
    ballY.value = ballPosRef.current.y;

    // Update all rings
    let updatedRings = ringsRef.current.map(ring => updateRing(ring, 1));

    // Check collision with closest ring only
    const { ring: closestRing, index, isInSolidPart } = findClosestCollidingRing(
      ballPosRef.current.x,
      ballPosRef.current.y,
      BALL_RADIUS,
      updatedRings,
      CENTER_X,
      CENTER_Y
    );

    const now = Date.now();
    const canHit = now - lastHitTimeRef.current > 80;

    if (closestRing && isInSolidPart && canHit) {
      lastHitTimeRef.current = now;
      
      const isCrit = Math.random() * 100 < critChance;
      const damage = baseDamage * (isCrit ? stats.critMultiplier : 1);
      const newHP = Math.max(0, closestRing.hp - damage);
      
      updatedRings[index] = { ...updatedRings[index], hp: newHP };
      
      // Reflect ball
      const reflection = reflectBallOffRing(
        ballPosRef.current.x,
        ballPosRef.current.y,
        velocityRef.current.x,
        velocityRef.current.y,
        CENTER_X,
        CENTER_Y,
        0.25
      );
      velocityRef.current.x = reflection.newVelX;
      velocityRef.current.y = reflection.newVelY;
      
      // Push ball away from ring slightly
      const dx = ballPosRef.current.x - CENTER_X;
      const dy = ballPosRef.current.y - CENTER_Y;
      const distFromCenter = Math.sqrt(dx * dx + dy * dy);
      const nx = dx / distFromCenter;
      const ny = dy / distFromCenter;
      
      // Push ball INSIDE the ring
      const safeDistance = closestRing.radius - closestRing.thickness / 2 - BALL_RADIUS - 2;
      ballPosRef.current.x = CENTER_X + nx * Math.min(distFromCenter, safeDistance);
      ballPosRef.current.y = CENTER_Y + ny * Math.min(distFromCenter, safeDistance);
      
      // Floating number
      addFloatingNumber(damage, ballPosRef.current.x, ballPosRef.current.y, isCrit);
      
      // Rewards
      const coinsGained = Math.floor(damage * 0.5 * coinMultiplier);
      const xpGained = Math.floor(damage * xpMultiplier);
      
      setCoins(prev => prev + coinsGained);
      setScore(prev => prev + damage);
      setXp(prev => {
        const newXP = prev + xpGained;
        if (newXP >= xpToNextLevel) {
          handleLevelUp();
          return newXP - xpToNextLevel;
        }
        return newXP;
      });
      
      // Track DPS
      recentHitDpsRef.current.push(damage);
      if (recentHitDpsRef.current.length > 60) {
        recentHitDpsRef.current.shift();
      }
      const totalDamage = recentHitDpsRef.current.reduce((sum, d) => sum + d, 0);
      setDps(Math.floor(totalDamage));
    }

    ringsRef.current = updatedRings;

    // Check victory (all rings destroyed)
    const activeRings = updatedRings.filter(r => r.hp > 0);
    if (activeRings.length === 0) {
      handleVictory();
      return;
    }

    // Check game over (rings too close to ball)
    const innermostActive = activeRings.reduce((closest, ring) =>
      ring.radius < closest.radius ? ring : closest
    );
    
    if (innermostActive.radius <= INNER_RADIUS - 5) {
      handleGameOver();
      return;
    }

    setRenderTick(t => (t + 1) % 1000);
  };

  const addFloatingNumber = (value: number, x: number, y: number, isCritical: boolean) => {
    const id = `num_${Date.now()}_${Math.random()}`;
    setFloatingNumbers(prev => [...prev.slice(-15), { id, value, x, y, isCritical }]);
  };

  const removeFloatingNumber = (id: string) => {
    setFloatingNumbers(prev => prev.filter(num => num.id !== id));
  };

  const handleLevelUp = () => {
    setLevel(prev => {
      const newLevel = prev + 1;
      const upgrades = getRandomUpgrades(3, currentUpgrades, newLevel);
      setAvailableUpgrades(upgrades);
      setShowLevelUp(true);
      return newLevel;
    });
  };

  const selectUpgrade = (upgrade: Upgrade) => {
    setCurrentUpgrades(prev => ({
      ...prev,
      [upgrade.id]: (prev[upgrade.id] || 0) + 1,
    }));
    setShowLevelUp(false);
    setRerollsUsed(0);
  };

  const handleRerollAd = () => {
    setShowAdReroll(true);
  };

  const handleRerollGems = async () => {
    if (gems >= 10) {
      await updateGems(-10);
      const upgrades = getRandomUpgrades(3, currentUpgrades, level);
      setAvailableUpgrades(upgrades);
      setRerollsUsed(prev => prev + 1);
    }
  };

  const handleAdRerollCompleted = () => {
    const upgrades = getRandomUpgrades(3, currentUpgrades, level);
    setAvailableUpgrades(upgrades);
    setRerollsUsed(prev => prev + 1);
    setShowAdReroll(false);
  };

  const handleGameOver = () => {
    isGameOverRef.current = true;
    if (gameLoopRef.current) clearInterval(gameLoopRef.current);
    setShowGameOver(true);
  };

  const handleRevive = () => {
    isGameOverRef.current = false;
    setShowGameOver(false);
    setShowAdRevive(false);
    
    // Push rings back
    ringsRef.current = ringsRef.current.map(ring => ({
      ...ring,
      radius: Math.min(ring.initialRadius, ring.radius + 80),
    }));
    
    startGameLoop();
  };

  const handleGiveUp = async () => {
    await updateCoins(coins);
    router.back();
  };

  const handleVictory = async () => {
    if (gameLoopRef.current) clearInterval(gameLoopRef.current);
    isGameOverRef.current = true;
    setShowVictory(true);
    
    await updateCoins(coins);
    
    const nextPhase = Number(phase) + 1;
    if (nextPhase <= 5) {
      await unlockPhase(nextPhase);
    }
  };

  const ballAnimatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: ballX.value - BALL_RADIUS },
      { translateY: ballY.value - BALL_RADIUS },
    ],
  }));

  const activeRings = ringsRef.current.filter(r => r.hp > 0);
  const totalRings = ringsRef.current.length;
  const remainingPercentage = totalRings > 0 ? (activeRings.length / totalRings) * 100 : 0;

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      {/* Top HUD */}
      <View style={styles.topHUD}>
        <View style={styles.hudRow}>
          <View style={styles.hudItem}>
            <Text style={styles.hudIcon}>💰</Text>
            <Text style={styles.hudValue}>{coins}</Text>
          </View>
          <View style={styles.hudItem}>
            <Text style={styles.hudIcon}>💎</Text>
            <Text style={styles.hudValue}>{gems}</Text>
          </View>
          <View style={styles.hudItem}>
            <Text style={styles.hudIcon}>⚔️</Text>
            <Text style={styles.hudValue}>{Math.floor(dps)}</Text>
          </View>
        </View>

        <View style={styles.levelRow}>
          <Text style={styles.levelText}>⭐ Lv.{level}</Text>
          <View style={styles.xpBarLarge}>
            <View style={[styles.xpFillLarge, { width: `${(xp / xpToNextLevel) * 100}%` }]} />
            <Text style={styles.xpText}>{xp}/{xpToNextLevel}</Text>
          </View>
        </View>

        <View style={styles.progressContainer}>
          <Text style={styles.progressText}>
            🌀 Anéis: {activeRings.length}/{totalRings}
          </Text>
          <View style={styles.progressBar}>
            <LinearGradient
              colors={['#ff0055', '#ff8800', '#ffd700']}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
              style={[styles.progressFill, { width: `${remainingPercentage}%` }]}
            />
          </View>
        </View>
      </View>

      {/* Game Arena */}
      <View style={styles.gameContainer}>
        <View style={[styles.gameArea, { width: GAME_SIZE, height: GAME_SIZE }]}>
          <Svg width={GAME_SIZE} height={GAME_SIZE} style={StyleSheet.absoluteFill}>
            {ringsRef.current.map((ring) => {
              if (ring.hp <= 0) return null;
              
              const circumference = 2 * Math.PI * ring.radius;
              const gapLength = (ring.gapSize / (Math.PI * 2)) * circumference;
              const arcLength = circumference - gapLength;
              const opacity = Math.max(0.4, ring.hp / ring.maxHp);
              const rotationDeg = (ring.rotation * 180) / Math.PI;
              const gapOffsetDeg = (ring.gapStart * 180) / Math.PI;
              
              return (
                <Circle
                  key={ring.id}
                  cx={CENTER_X}
                  cy={CENTER_Y}
                  r={ring.radius}
                  stroke={ring.color}
                  strokeWidth={ring.thickness}
                  fill="none"
                  opacity={opacity}
                  strokeDasharray={`${arcLength} ${gapLength}`}
                  strokeDashoffset={-(gapOffsetDeg / 360) * circumference}
                  transform={`rotate(${rotationDeg} ${CENTER_X} ${CENTER_Y})`}
                  strokeLinecap="round"
                />
              );
            })}
            
            {/* Danger zone indicator */}
            <Circle
              cx={CENTER_X}
              cy={CENTER_Y}
              r={INNER_RADIUS}
              stroke="#ff0055"
              strokeWidth={1}
              fill="none"
              opacity={0.3}
              strokeDasharray="4 4"
            />
          </Svg>

          {/* Ball */}
          <Animated.View style={[styles.ball, ballAnimatedStyle]}>
            <View style={styles.ballGlow}>
              <LinearGradient
                colors={['#ffffff', '#00f0ff', '#0088ff']}
                style={styles.ballGradient}
              />
            </View>
          </Animated.View>

          {/* Floating Numbers */}
          {floatingNumbers.map(num => (
            <FloatingNumber
              key={num.id}
              value={num.value}
              x={num.x}
              y={num.y}
              isCritical={num.isCritical}
              onComplete={() => removeFloatingNumber(num.id)}
            />
          ))}
        </View>
      </View>

      {/* Bottom Controls */}
      <View style={styles.bottomControls}>
        <TouchableOpacity style={styles.controlButton} onPress={() => setIsPaused(!isPaused)}>
          <Text style={styles.controlIcon}>{isPaused ? '▶️' : '⏸️'}</Text>
        </TouchableOpacity>
        
        <TouchableOpacity style={styles.controlButton} onPress={() => router.back()}>
          <Text style={styles.controlIcon}>🏠</Text>
        </TouchableOpacity>
      </View>

      {/* Level Up Modal */}
      {showLevelUp && (
        <Modal visible transparent animationType="fade">
          <View style={styles.modalOverlay}>
            <View style={styles.levelUpModal}>
              <LinearGradient colors={['#1a0a2e', '#16003b']} style={styles.modalContent}>
                <Text style={styles.modalTitle}>⬆️ LEVEL {level} ⬆️</Text>
                <Text style={styles.modalSubtitle}>Escolha um upgrade:</Text>

                {availableUpgrades.map((upgrade) => (
                  <TouchableOpacity
                    key={upgrade.id}
                    style={styles.upgradeCard}
                    onPress={() => selectUpgrade(upgrade)}
                  >
                    <LinearGradient
                      colors={[getRarityColor(upgrade.rarity) + '88', getRarityColor(upgrade.rarity) + '22']}
                      style={[styles.upgradeCardContent, { borderColor: getRarityColor(upgrade.rarity) }]}
                    >
                      <Text style={styles.upgradeIcon}>{upgrade.icon}</Text>
                      <View style={styles.upgradeInfo}>
                        <Text style={styles.upgradeName}>{upgrade.name}</Text>
                        <Text style={styles.upgradeDescription}>{upgrade.description}</Text>
                        <Text style={[styles.upgradeRarity, { color: getRarityColor(upgrade.rarity) }]}>
                          {getRarityName(upgrade.rarity)} • Lv.{(currentUpgrades[upgrade.id] || 0) + 1}
                        </Text>
                      </View>
                    </LinearGradient>
                  </TouchableOpacity>
                ))}

                {/* Reroll Options */}
                {rerollsUsed < 2 && (
                  <View style={styles.rerollContainer}>
                    <TouchableOpacity style={styles.rerollButton} onPress={handleRerollAd}>
                      <LinearGradient colors={['#00ff88', '#00aa66']} style={styles.rerollGradient}>
                        <Text style={styles.rerollIcon}>📺</Text>
                        <Text style={styles.rerollText}>Trocar (Ad)</Text>
                      </LinearGradient>
                    </TouchableOpacity>
                    
                    <TouchableOpacity 
                      style={[styles.rerollButton, gems < 10 && styles.disabled]} 
                      onPress={handleRerollGems}
                      disabled={gems < 10}
                    >
                      <LinearGradient colors={['#b000ff', '#6600cc']} style={styles.rerollGradient}>
                        <Text style={styles.rerollIcon}>💎</Text>
                        <Text style={styles.rerollText}>Trocar (10)</Text>
                      </LinearGradient>
                    </TouchableOpacity>
                  </View>
                )}
              </LinearGradient>
            </View>
          </View>
        </Modal>
      )}

      {/* Victory Modal */}
      {showVictory && (
        <Modal visible transparent animationType="fade">
          <View style={styles.modalOverlay}>
            <View style={styles.victoryModal}>
              <LinearGradient colors={['#1a0a2e', '#16003b']} style={styles.modalContent}>
                <Text style={styles.victoryTitle}>🎉 VITÓRIA! 🎉</Text>
                <View style={styles.statsContainer}>
                  <Text style={styles.statText}>💰 Moedas: {coins}</Text>
                  <Text style={styles.statText}>⭐ Level: {level}</Text>
                  <Text style={styles.statText}>🎯 Score: {Math.floor(score)}</Text>
                </View>
                <TouchableOpacity style={styles.actionButton} onPress={() => router.back()}>
                  <LinearGradient colors={['#00f0ff', '#0088ff']} style={styles.buttonGradient}>
                    <Text style={styles.buttonText}>CONTINUAR</Text>
                  </LinearGradient>
                </TouchableOpacity>
              </LinearGradient>
            </View>
          </View>
        </Modal>
      )}

      {/* Game Over Modal */}
      {showGameOver && (
        <Modal visible transparent animationType="fade">
          <View style={styles.modalOverlay}>
            <View style={styles.gameOverModal}>
              <LinearGradient colors={['#1a0a2e', '#16003b']} style={styles.modalContent}>
                <Text style={styles.gameOverTitle}>💀 DERROTA 💀</Text>
                <Text style={styles.gameOverSubtitle}>A bolinha foi esmagada!</Text>
                
                <View style={styles.statsContainer}>
                  <Text style={styles.statText}>💰 Moedas: {coins}</Text>
                  <Text style={styles.statText}>⭐ Level: {level}</Text>
                  <Text style={styles.statText}>🎯 Score: {Math.floor(score)}</Text>
                </View>

                <TouchableOpacity
                  style={styles.reviveButton}
                  onPress={() => { setShowGameOver(false); setShowAdRevive(true); }}
                >
                  <LinearGradient colors={['#ff0055', '#cc0000']} style={styles.buttonGradient}>
                    <Text style={styles.buttonText}>📺 REVIVER (AD)</Text>
                  </LinearGradient>
                </TouchableOpacity>

                <TouchableOpacity style={styles.giveUpButton} onPress={handleGiveUp}>
                  <Text style={styles.giveUpText}>Desistir</Text>
                </TouchableOpacity>
              </LinearGradient>
            </View>
          </View>
        </Modal>
      )}

      {/* Ad Modals */}
      <AdModal
        visible={showAdRevive}
        onClose={() => setShowAdRevive(false)}
        onRewardClaimed={handleRevive}
        rewardType="revive"
      />
      
      <AdModal
        visible={showAdReroll}
        onClose={() => setShowAdReroll(false)}
        onRewardClaimed={handleAdRerollCompleted}
        rewardType="double"
      />
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  topHUD: { paddingTop: 45, paddingHorizontal: 12 },
  hudRow: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 8, gap: 6 },
  hudItem: {
    flex: 1,
    flexDirection: 'row',
    backgroundColor: '#ffffff11',
    paddingVertical: 8,
    paddingHorizontal: 10,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#ffffff22',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 6,
  },
  hudIcon: { fontSize: 18 },
  hudValue: { fontSize: 16, fontWeight: 'bold', color: '#00f0ff' },
  levelRow: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#ffffff11',
    padding: 8,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#ffffff22',
    marginBottom: 8,
    gap: 10,
  },
  levelText: { fontSize: 14, fontWeight: 'bold', color: '#ffd700' },
  xpBarLarge: {
    flex: 1,
    height: 18,
    backgroundColor: '#ffffff22',
    borderRadius: 9,
    overflow: 'hidden',
    position: 'relative',
    justifyContent: 'center',
  },
  xpFillLarge: {
    position: 'absolute',
    left: 0,
    top: 0,
    bottom: 0,
    backgroundColor: '#00f0ff',
  },
  xpText: {
    textAlign: 'center',
    fontSize: 11,
    color: '#ffffff',
    fontWeight: 'bold',
    zIndex: 1,
  },
  progressContainer: { marginBottom: 4 },
  progressText: { fontSize: 12, color: '#ffffff', marginBottom: 4, textAlign: 'center', fontWeight: 'bold' },
  progressBar: {
    height: 14,
    backgroundColor: '#ffffff11',
    borderRadius: 7,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: '#ffffff22',
  },
  progressFill: { height: '100%' },
  gameContainer: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  gameArea: {
    backgroundColor: '#00000033',
    borderRadius: 999,
    position: 'relative',
    overflow: 'hidden',
    borderWidth: 2,
    borderColor: '#ffffff11',
  },
  ball: {
    position: 'absolute',
    width: BALL_RADIUS * 2,
    height: BALL_RADIUS * 2,
    borderRadius: BALL_RADIUS,
  },
  ballGlow: {
    width: '100%',
    height: '100%',
    borderRadius: BALL_RADIUS,
    overflow: 'hidden',
    shadowColor: '#00f0ff',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 1,
    shadowRadius: 15,
    elevation: 10,
  },
  ballGradient: { width: '100%', height: '100%' },
  bottomControls: { flexDirection: 'row', justifyContent: 'center', gap: 20, paddingVertical: 16 },
  controlButton: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: '#ffffff22',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#ffffff44',
  },
  controlIcon: { fontSize: 20 },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', justifyContent: 'center', alignItems: 'center' },
  levelUpModal: { width: '92%', maxWidth: 420, borderRadius: 20, overflow: 'hidden' },
  modalContent: { padding: 20 },
  modalTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#00f0ff',
    textAlign: 'center',
    marginBottom: 4,
  },
  modalSubtitle: { fontSize: 14, color: '#ffffff', textAlign: 'center', marginBottom: 14 },
  upgradeCard: { marginBottom: 10, borderRadius: 12, overflow: 'hidden' },
  upgradeCardContent: {
    flexDirection: 'row',
    padding: 12,
    alignItems: 'center',
    borderWidth: 2,
  },
  upgradeIcon: { fontSize: 36, marginRight: 14 },
  upgradeInfo: { flex: 1 },
  upgradeName: { fontSize: 17, fontWeight: 'bold', color: '#ffffff', marginBottom: 2 },
  upgradeDescription: { fontSize: 13, color: '#ffffffaa', marginBottom: 4 },
  upgradeRarity: { fontSize: 11, fontWeight: 'bold', letterSpacing: 1 },
  rerollContainer: { flexDirection: 'row', gap: 8, marginTop: 8 },
  rerollButton: { flex: 1, height: 44, borderRadius: 10, overflow: 'hidden' },
  rerollGradient: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 6,
  },
  rerollIcon: { fontSize: 16 },
  rerollText: { fontSize: 13, fontWeight: 'bold', color: '#ffffff' },
  disabled: { opacity: 0.5 },
  victoryModal: { width: '90%', maxWidth: 400, borderRadius: 20, overflow: 'hidden' },
  victoryTitle: { fontSize: 32, fontWeight: 'bold', color: '#ffd700', textAlign: 'center', marginBottom: 16 },
  gameOverModal: { width: '90%', maxWidth: 400, borderRadius: 20, overflow: 'hidden' },
  gameOverTitle: { fontSize: 32, fontWeight: 'bold', color: '#ff0055', textAlign: 'center', marginBottom: 8 },
  gameOverSubtitle: { fontSize: 14, color: '#ffffff', textAlign: 'center', marginBottom: 16 },
  statsContainer: { backgroundColor: '#ffffff11', padding: 14, borderRadius: 12, marginBottom: 16 },
  statText: { fontSize: 16, color: '#ffffff', marginBottom: 4 },
  actionButton: { height: 50, borderRadius: 12, overflow: 'hidden' },
  reviveButton: { height: 50, borderRadius: 12, overflow: 'hidden', marginBottom: 10 },
  giveUpButton: { padding: 10, alignItems: 'center' },
  giveUpText: { color: '#ffffff88', fontSize: 14 },
  buttonGradient: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  buttonText: { fontSize: 16, fontWeight: 'bold', color: '#ffffff' },
});

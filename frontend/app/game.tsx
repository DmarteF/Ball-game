import React, { useState, useEffect, useRef } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Dimensions, Modal } from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
} from 'react-native-reanimated';
import Svg, { Circle } from 'react-native-svg';
import { useGame } from '@/src/contexts/GameContext';
import { createRings, updateRing, checkBallRingCollision, Ring } from '@/src/game/rings';
import { getRandomUpgrades, Upgrade, getRarityColor } from '@/src/game/upgrades';
import { FloatingNumber } from '@/src/components/FloatingNumber';
import { AdModal } from '@/src/components/AdModal';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');
const GAME_SIZE = Math.min(SCREEN_WIDTH, SCREEN_HEIGHT - 280) * 0.95;
const CENTER_X = GAME_SIZE / 2;
const CENTER_Y = GAME_SIZE / 2;
const BALL_RADIUS = 12;

interface FloatingNumberData {
  id: string;
  value: number;
  x: number;
  y: number;
  isCritical: boolean;
}

export default function GameScreen() {
  const router = useRouter();
  const { phase } = useLocalSearchParams();
  const { stats, updateCoins, unlockPhase } = useGame();
  
  const [, forceUpdate] = useState(0);
  const [isPaused, setIsPaused] = useState(false);
  const [showLevelUp, setShowLevelUp] = useState(false);
  const [showVictory, setShowVictory] = useState(false);
  const [showAdRevive, setShowAdRevive] = useState(false);
  
  const [coins, setCoins] = useState(0);
  const [xp, setXp] = useState(0);
  const [level, setLevel] = useState(1);
  const [score, setScore] = useState(0);
  const [dps, setDps] = useState(0);
  
  const [currentUpgrades, setCurrentUpgrades] = useState<Record<string, number>>({});
  const [availableUpgrades, setAvailableUpgrades] = useState<Upgrade[]>([]);
  const [floatingNumbers, setFloatingNumbers] = useState<FloatingNumberData[]>([]);
  
  // Refs for game state (avoid closure issues)
  const ringsRef = useRef<Ring[]>([]);
  const totalRingsHPRef = useRef(0);
  const maxTotalHPRef = useRef(0);
  const ballPositionRef = useRef({ x: CENTER_X, y: CENTER_Y });
  const velocityRef = useRef({ x: 3, y: -3 });
  const isPausedRef = useRef(false);
  const isGameOverRef = useRef(false);
  const showLevelUpRef = useRef(false);
  const lastHitTimeRef = useRef(0);
  const initializedRef = useRef(false);
  
  // Visual state
  const ballX = useSharedValue(CENTER_X);
  const ballY = useSharedValue(CENTER_Y);
  const [renderTick, setRenderTick] = useState(0);
  
  const gameLoopRef = useRef<NodeJS.Timeout | null>(null);
  const xpToNextLevel = level * 100;
  
  // Calculated stats
  const baseDamage = stats.baseDamage * (1 + (currentUpgrades['damage'] || 0) * 0.15);
  const critChance = stats.critChance + (currentUpgrades['critical'] || 0) * 5;
  const coinMultiplier = stats.coinMultiplier * (1 + (currentUpgrades['coinBoost'] || 0) * 0.5);
  const xpMultiplier = stats.xpMultiplier * (1 + (currentUpgrades['xpBoost'] || 0) * 0.5);
  const speedMultiplier = 1 + (currentUpgrades['speed'] || 0) * 0.2;

  useEffect(() => {
    initializeGame();
    return () => {
      if (gameLoopRef.current) {
        clearInterval(gameLoopRef.current);
      }
    };
  }, []);

  useEffect(() => {
    isPausedRef.current = isPaused;
  }, [isPaused]);

  useEffect(() => {
    showLevelUpRef.current = showLevelUp;
  }, [showLevelUp]);

  const initializeGame = () => {
    const phaseNumber = Number(phase) || 1;
    
    const ringCount = 15 + (phaseNumber - 1) * 3;
    const newRings = createRings({
      count: ringCount,
      baseRadius: 80,
      radiusIncrement: 18,
      baseRotationSpeed: 0.015,
      baseHp: 50,
      baseGapSize: Math.PI / 2.5,
      baseThickness: 6,
      closingSpeed: 0.03,
      colors: ['#00f0ff', '#b000ff', '#ff0055', '#00ff88', '#ffd700'],
    }, phaseNumber);
    
    ringsRef.current = newRings;
    const totalHP = newRings.reduce((sum, ring) => sum + ring.hp, 0);
    totalRingsHPRef.current = totalHP;
    maxTotalHPRef.current = totalHP;
    initializedRef.current = true;
    
    startGameLoop();
  };

  const startGameLoop = () => {
    if (gameLoopRef.current) {
      clearInterval(gameLoopRef.current);
    }
    
    gameLoopRef.current = setInterval(() => {
      if (!isPausedRef.current && !isGameOverRef.current && !showLevelUpRef.current && initializedRef.current) {
        updateGame();
      }
    }, 16);
  };

  const updateGame = () => {
    // Update ball position
    ballPositionRef.current.x += velocityRef.current.x * speedMultiplier;
    ballPositionRef.current.y += velocityRef.current.y * speedMultiplier;

    // Bounce off boundaries
    if (ballPositionRef.current.x <= BALL_RADIUS || ballPositionRef.current.x >= GAME_SIZE - BALL_RADIUS) {
      velocityRef.current.x *= -1;
      ballPositionRef.current.x = Math.max(BALL_RADIUS, Math.min(GAME_SIZE - BALL_RADIUS, ballPositionRef.current.x));
    }
    if (ballPositionRef.current.y <= BALL_RADIUS || ballPositionRef.current.y >= GAME_SIZE - BALL_RADIUS) {
      velocityRef.current.y *= -1;
      ballPositionRef.current.y = Math.max(BALL_RADIUS, Math.min(GAME_SIZE - BALL_RADIUS, ballPositionRef.current.y));
    }

    // Update animated ball position
    ballX.value = ballPositionRef.current.x;
    ballY.value = ballPositionRef.current.y;

    // Update rings
    const updatedRings = ringsRef.current.map(ring => updateRing(ring, 1));
    let totalHP = 0;
    let hitOccurred = false;

    const now = Date.now();
    const canHit = now - lastHitTimeRef.current > 100; // Throttle hits

    const finalRings = updatedRings.map(ring => {
      if (ring.hp <= 0) {
        return ring;
      }
      
      const collision = checkBallRingCollision(
        ballPositionRef.current.x,
        ballPositionRef.current.y,
        BALL_RADIUS,
        ring,
        CENTER_X,
        CENTER_Y
      );

      if (collision.hit && canHit) {
        hitOccurred = true;
        lastHitTimeRef.current = now;
        
        const isCrit = Math.random() * 100 < critChance;
        const damage = baseDamage * (isCrit ? stats.critMultiplier : 1);
        const newHP = Math.max(0, ring.hp - damage);
        
        // Bounce ball
        const dx = ballPositionRef.current.x - CENTER_X;
        const dy = ballPositionRef.current.y - CENTER_Y;
        const dist = Math.sqrt(dx * dx + dy * dy);
        const normalX = dx / dist;
        const normalY = dy / dist;
        const dot = velocityRef.current.x * normalX + velocityRef.current.y * normalY;
        velocityRef.current.x -= 2 * dot * normalX;
        velocityRef.current.y -= 2 * dot * normalY;
        
        // Add floating number
        addFloatingNumber(damage, ballPositionRef.current.x, ballPositionRef.current.y, isCrit);
        
        // Gain rewards
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
        
        totalHP += newHP;
        return { ...ring, hp: newHP };
      }
      
      totalHP += ring.hp;
      return ring;
    });

    ringsRef.current = finalRings;
    totalRingsHPRef.current = totalHP;

    if (hitOccurred) {
      setDps(Math.floor(baseDamage * 10));
    }

    // Check victory
    if (maxTotalHPRef.current > 0 && totalHP <= 0) {
      handleVictory();
      return;
    }

    // Check game over (closest ring too small)
    const activeRings = finalRings.filter(r => r.hp > 0);
    if (activeRings.length > 0) {
      const closestRing = activeRings.reduce((closest, ring) => 
        ring.radius < closest.radius ? ring : closest
      );
      
      if (closestRing.radius <= 50) {
        handleGameOver();
        return;
      }
    }

    // Trigger re-render for rings
    setRenderTick(t => t + 1);
  };

  const addFloatingNumber = (value: number, x: number, y: number, isCritical: boolean) => {
    const id = `num_${Date.now()}_${Math.random()}`;
    setFloatingNumbers(prev => [...prev.slice(-10), { id, value, x, y, isCritical }]);
  };

  const removeFloatingNumber = (id: string) => {
    setFloatingNumbers(prev => prev.filter(num => num.id !== id));
  };

  const handleLevelUp = () => {
    setLevel(prev => prev + 1);
    const upgrades = getRandomUpgrades(3, currentUpgrades);
    setAvailableUpgrades(upgrades);
    setShowLevelUp(true);
  };

  const selectUpgrade = (upgrade: Upgrade) => {
    setCurrentUpgrades(prev => ({
      ...prev,
      [upgrade.id]: (prev[upgrade.id] || 0) + 1,
    }));
    setShowLevelUp(false);
  };

  const handleGameOver = () => {
    isGameOverRef.current = true;
    if (gameLoopRef.current) {
      clearInterval(gameLoopRef.current);
    }
    setShowAdRevive(true);
  };

  const handleRevive = () => {
    isGameOverRef.current = false;
    setShowAdRevive(false);
    
    // Push rings back
    ringsRef.current = ringsRef.current.map(ring => ({
      ...ring,
      radius: Math.min(ring.radius + 60, ring.radius + 60),
    }));
    
    startGameLoop();
  };

  const handleVictory = async () => {
    if (gameLoopRef.current) {
      clearInterval(gameLoopRef.current);
    }
    isGameOverRef.current = true;
    setShowVictory(true);
    
    await updateCoins(coins);
    
    const nextPhase = Number(phase) + 1;
    if (nextPhase <= 5) {
      await unlockPhase(nextPhase);
    }
  };

  const ballAnimatedStyle = useAnimatedStyle(() => {
    return {
      transform: [
        { translateX: ballX.value - BALL_RADIUS },
        { translateY: ballY.value - BALL_RADIUS },
      ],
    };
  });

  const progressPercentage = maxTotalHPRef.current > 0 
    ? (totalRingsHPRef.current / maxTotalHPRef.current) * 100 
    : 100;

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
            <Text style={styles.hudIcon}>⭐</Text>
            <Text style={styles.hudValue}>Lv.{level}</Text>
            <View style={styles.xpBar}>
              <View style={[styles.xpFill, { width: `${(xp / xpToNextLevel) * 100}%` }]} />
            </View>
          </View>
          <View style={styles.hudItem}>
            <Text style={styles.hudIcon}>⚔️</Text>
            <Text style={styles.hudValue}>{Math.floor(dps)}</Text>
          </View>
        </View>

        <View style={styles.progressContainer}>
          <Text style={styles.progressText}>
            Anéis: {Math.floor(progressPercentage)}% ({ringsRef.current.filter(r => r.hp > 0).length}/{ringsRef.current.length})
          </Text>
          <View style={styles.progressBar}>
            <LinearGradient
              colors={['#ff0055', '#ff8800', '#ffd700']}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
              style={[styles.progressFill, { width: `${progressPercentage}%` }]}
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
              const opacity = Math.max(0.3, ring.hp / ring.maxHp);
              const rotationDeg = (ring.rotation * 180) / Math.PI;
              
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
                  strokeDashoffset={-(ring.gapStart / (Math.PI * 2)) * circumference}
                  transform={`rotate(${rotationDeg} ${CENTER_X} ${CENTER_Y})`}
                  strokeLinecap="round"
                />
              );
            })}
            
            {/* Center circle */}
            <Circle
              cx={CENTER_X}
              cy={CENTER_Y}
              r={3}
              fill="#ffffff44"
            />
          </Svg>

          {/* Ball */}
          <Animated.View style={[styles.ball, ballAnimatedStyle]}>
            <LinearGradient
              colors={['#ffffff', '#00f0ff']}
              style={styles.ballGradient}
            />
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
        <TouchableOpacity
          style={styles.controlButton}
          onPress={() => setIsPaused(!isPaused)}
        >
          <Text style={styles.controlIcon}>{isPaused ? '▶️' : '⏸️'}</Text>
        </TouchableOpacity>
        
        <TouchableOpacity
          style={styles.controlButton}
          onPress={() => router.back()}
        >
          <Text style={styles.controlIcon}>🏠</Text>
        </TouchableOpacity>
      </View>

      {/* Level Up Modal */}
      {showLevelUp && (
        <Modal visible transparent animationType="fade">
          <View style={styles.modalOverlay}>
            <View style={styles.levelUpModal}>
              <LinearGradient colors={['#1a0a2e', '#16003b']} style={styles.modalContent}>
                <Text style={styles.modalTitle}>⬆️ LEVEL UP! ⬆️</Text>
                <Text style={styles.modalSubtitle}>Escolha um upgrade:</Text>

                {availableUpgrades.map((upgrade) => (
                  <TouchableOpacity
                    key={upgrade.id}
                    style={styles.upgradeCard}
                    onPress={() => selectUpgrade(upgrade)}
                  >
                    <LinearGradient
                      colors={[getRarityColor(upgrade.rarity) + '66', getRarityColor(upgrade.rarity) + '22']}
                      style={[styles.upgradeCardContent, { borderColor: getRarityColor(upgrade.rarity) }]}
                    >
                      <Text style={styles.upgradeIcon}>{upgrade.icon}</Text>
                      <View style={styles.upgradeInfo}>
                        <Text style={styles.upgradeName}>{upgrade.name}</Text>
                        <Text style={styles.upgradeDescription}>{upgrade.description}</Text>
                        <Text style={[styles.upgradeRarity, { color: getRarityColor(upgrade.rarity) }]}>
                          {upgrade.rarity.toUpperCase()} • Lv.{(currentUpgrades[upgrade.id] || 0) + 1}
                        </Text>
                      </View>
                    </LinearGradient>
                  </TouchableOpacity>
                ))}
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

                <TouchableOpacity
                  style={styles.actionButton}
                  onPress={() => router.back()}
                >
                  <LinearGradient colors={['#00f0ff', '#0088ff']} style={styles.buttonGradient}>
                    <Text style={styles.buttonText}>CONTINUAR</Text>
                  </LinearGradient>
                </TouchableOpacity>
              </LinearGradient>
            </View>
          </View>
        </Modal>
      )}

      {/* Ad Revive Modal */}
      <AdModal
        visible={showAdRevive}
        onClose={() => router.back()}
        onRewardClaimed={handleRevive}
        rewardType="revive"
      />
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  topHUD: { paddingTop: 50, paddingHorizontal: 16 },
  hudRow: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 12, gap: 8 },
  hudItem: {
    flex: 1,
    backgroundColor: '#ffffff11',
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#ffffff22',
    alignItems: 'center',
  },
  hudIcon: { fontSize: 16, marginBottom: 2 },
  hudValue: { fontSize: 16, fontWeight: 'bold', color: '#00f0ff' },
  xpBar: {
    height: 4,
    backgroundColor: '#ffffff22',
    borderRadius: 2,
    overflow: 'hidden',
    marginTop: 4,
    width: '100%',
  },
  xpFill: { height: '100%', backgroundColor: '#00f0ff' },
  progressContainer: { marginTop: 4 },
  progressText: { fontSize: 11, color: '#ffffff', marginBottom: 4, textAlign: 'center' },
  progressBar: {
    height: 16,
    backgroundColor: '#ffffff11',
    borderRadius: 8,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: '#ffffff22',
  },
  progressFill: { height: '100%' },
  gameContainer: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  gameArea: {
    backgroundColor: '#ffffff05',
    borderRadius: 20,
    position: 'relative',
    overflow: 'hidden',
  },
  ball: {
    position: 'absolute',
    width: BALL_RADIUS * 2,
    height: BALL_RADIUS * 2,
    borderRadius: BALL_RADIUS,
    overflow: 'hidden',
    shadowColor: '#00f0ff',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 1,
    shadowRadius: 10,
  },
  ballGradient: { width: '100%', height: '100%' },
  bottomControls: { flexDirection: 'row', justifyContent: 'center', gap: 20, paddingVertical: 20 },
  controlButton: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: '#ffffff22',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#ffffff44',
  },
  controlIcon: { fontSize: 24 },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', justifyContent: 'center', alignItems: 'center' },
  levelUpModal: { width: '90%', maxWidth: 400, borderRadius: 20, overflow: 'hidden' },
  modalContent: { padding: 24 },
  modalTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#00f0ff',
    textAlign: 'center',
    marginBottom: 8,
  },
  modalSubtitle: { fontSize: 14, color: '#ffffff', textAlign: 'center', marginBottom: 16 },
  upgradeCard: { marginBottom: 10, borderRadius: 12, overflow: 'hidden' },
  upgradeCardContent: {
    flexDirection: 'row',
    padding: 14,
    alignItems: 'center',
    borderWidth: 2,
  },
  upgradeIcon: { fontSize: 36, marginRight: 14 },
  upgradeInfo: { flex: 1 },
  upgradeName: { fontSize: 17, fontWeight: 'bold', color: '#ffffff', marginBottom: 2 },
  upgradeDescription: { fontSize: 13, color: '#ffffffaa', marginBottom: 4 },
  upgradeRarity: { fontSize: 11, fontWeight: 'bold' },
  victoryModal: { width: '90%', maxWidth: 400, borderRadius: 20, overflow: 'hidden' },
  victoryTitle: { fontSize: 36, fontWeight: 'bold', color: '#ffd700', textAlign: 'center', marginBottom: 20 },
  statsContainer: { backgroundColor: '#ffffff11', padding: 16, borderRadius: 12, marginBottom: 20 },
  statText: { fontSize: 18, color: '#ffffff', marginBottom: 6 },
  actionButton: { height: 56, borderRadius: 12, overflow: 'hidden' },
  buttonGradient: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  buttonText: { fontSize: 18, fontWeight: 'bold', color: '#ffffff' },
});

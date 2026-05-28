import React, { useState, useEffect, useRef } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Dimensions } from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withRepeat,
  withSequence,
} from 'react-native-reanimated';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');
const BALL_SIZE = 30;
const ARENA_SIZE = Math.min(SCREEN_WIDTH, SCREEN_HEIGHT) * 0.7;

export default function GameScreen() {
  const router = useRouter();
  const { phase } = useLocalSearchParams();
  const [isPaused, setIsPaused] = useState(false);
  const [showLevelUp, setShowLevelUp] = useState(false);
  
  // Game state
  const [coins, setCoins] = useState(0);
  const [xp, setXp] = useState(0);
  const [level, setLevel] = useState(1);
  const [targetHP, setTargetHP] = useState(100);
  const [maxHP, setMaxHP] = useState(100);
  const [damage, setDamage] = useState(10);
  const [score, setScore] = useState(0);
  
  // Ball physics
  const ballX = useSharedValue(ARENA_SIZE / 2);
  const ballY = useSharedValue(ARENA_SIZE / 2);
  const velocityX = useRef(3);
  const velocityY = useRef(-3);
  
  const gameLoopRef = useRef<NodeJS.Timeout | null>(null);
  const xpToNextLevel = level * 100;

  useEffect(() => {
    // Initialize game based on phase
    const phaseData = getPhaseData(Number(phase) || 1);
    setMaxHP(phaseData.targetHP);
    setTargetHP(phaseData.targetHP);
    
    startGameLoop();
    
    return () => {
      if (gameLoopRef.current) {
        clearInterval(gameLoopRef.current);
      }
    };
  }, []);

  const getPhaseData = (phaseId: number) => {
    const phases = [
      { targetHP: 100, color: '#00f0ff' },
      { targetHP: 250, color: '#b000ff' },
      { targetHP: 500, color: '#00ff88' },
      { targetHP: 1000, color: '#ff0055' },
      { targetHP: 2000, color: '#ffd700' },
    ];
    return phases[phaseId - 1] || phases[0];
  };

  const startGameLoop = () => {
    gameLoopRef.current = setInterval(() => {
      if (!isPaused) {
        updateBallPosition();
      }
    }, 16); // ~60 FPS
  };

  const updateBallPosition = () => {
    ballX.value += velocityX.current;
    ballY.value += velocityY.current;

    // Collision with walls
    const radius = BALL_SIZE / 2;
    
    if (ballX.value <= radius || ballX.value >= ARENA_SIZE - radius) {
      velocityX.current *= -1;
      onHit();
    }
    
    if (ballY.value <= radius || ballY.value >= ARENA_SIZE - radius) {
      velocityY.current *= -1;
      onHit();
    }
  };

  const onHit = () => {
    // Damage calculation
    const dmg = damage * (Math.random() > 0.95 ? 2 : 1); // 5% crit chance
    const newHP = Math.max(0, targetHP - dmg);
    setTargetHP(newHP);
    
    // Coins and XP
    const coinsGained = Math.floor(dmg / 2);
    const xpGained = Math.floor(dmg);
    
    setCoins(prev => prev + coinsGained);
    setScore(prev => prev + dmg);
    
    const newXP = xp + xpGained;
    if (newXP >= xpToNextLevel) {
      levelUp();
      setXp(newXP - xpToNextLevel);
    } else {
      setXp(newXP);
    }
    
    // Check win condition
    if (newHP <= 0) {
      handleWin();
    }
  };

  const levelUp = () => {
    setLevel(prev => prev + 1);
    setShowLevelUp(true);
    setIsPaused(true);
  };

  const selectUpgrade = (upgrade: string) => {
    // Apply upgrade
    switch(upgrade) {
      case 'damage':
        setDamage(prev => prev * 1.1);
        break;
      case 'speed':
        velocityX.current *= 1.15;
        velocityY.current *= 1.15;
        break;
      case 'coins':
        setCoins(prev => prev + 100);
        break;
    }
    
    setShowLevelUp(false);
    setIsPaused(false);
  };

  const handleWin = () => {
    if (gameLoopRef.current) {
      clearInterval(gameLoopRef.current);
    }
    // TODO: Show victory screen
    alert('Vitória!');
    router.back();
  };

  const ballAnimatedStyle = useAnimatedStyle(() => {
    return {
      transform: [
        { translateX: ballX.value - BALL_SIZE / 2 },
        { translateY: ballY.value - BALL_SIZE / 2 },
      ],
    };
  });

  const hpPercentage = (targetHP / maxHP) * 100;

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      {/* HUD */}
      <View style={styles.hud}>
        <View style={styles.hudTop}>
          <View style={styles.statBox}>
            <Text style={styles.statLabel}>Moedas</Text>
            <Text style={styles.statValue}>{coins}</Text>
          </View>
          <View style={styles.statBox}>
            <Text style={styles.statLabel}>Level {level}</Text>
            <View style={styles.xpBar}>
              <View style={[styles.xpFill, { width: `${(xp / xpToNextLevel) * 100}%` }]} />
            </View>
          </View>
          <View style={styles.statBox}>
            <Text style={styles.statLabel}>Score</Text>
            <Text style={styles.statValue}>{Math.floor(score)}</Text>
          </View>
        </View>
        
        {/* HP Bar */}
        <View style={styles.hpBarContainer}>
          <Text style={styles.hpText}>HP: {Math.floor(targetHP)} / {maxHP}</Text>
          <View style={styles.hpBar}>
            <LinearGradient
              colors={['#ff0055', '#ff8800']}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
              style={[styles.hpFill, { width: `${hpPercentage}%` }]}
            />
          </View>
        </View>
      </View>

      {/* Game Arena */}
      <View style={styles.arenaContainer}>
        <View style={[styles.arena, { width: ARENA_SIZE, height: ARENA_SIZE }]}>
          {/* Ball */}
          <Animated.View style={[styles.ball, ballAnimatedStyle]}>
            <LinearGradient
              colors={['#00f0ff', '#0088ff']}
              style={styles.ballGradient}
            />
          </Animated.View>
        </View>
      </View>

      {/* Controls */}
      <View style={styles.controls}>
        <TouchableOpacity
          style={styles.controlButton}
          onPress={() => setIsPaused(!isPaused)}
        >
          <Text style={styles.controlText}>{isPaused ? '▶' : '⏸'}</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.controlButton}
          onPress={() => router.back()}
        >
          <Text style={styles.controlText}>✕</Text>
        </TouchableOpacity>
      </View>

      {/* Level Up Modal */}
      {showLevelUp && (
        <View style={styles.modalOverlay}>
          <View style={styles.levelUpModal}>
            <Text style={styles.modalTitle}>LEVEL UP!</Text>
            <Text style={styles.modalSubtitle}>Escolha um upgrade:</Text>
            
            <TouchableOpacity
              style={styles.upgradeOption}
              onPress={() => selectUpgrade('damage')}
            >
              <Text style={styles.upgradeText}>⚔️ +10% Dano</Text>
            </TouchableOpacity>
            
            <TouchableOpacity
              style={styles.upgradeOption}
              onPress={() => selectUpgrade('speed')}
            >
              <Text style={styles.upgradeText}>⚡ +15% Velocidade</Text>
            </TouchableOpacity>
            
            <TouchableOpacity
              style={styles.upgradeOption}
              onPress={() => selectUpgrade('coins')}
            >
              <Text style={styles.upgradeText}>💰 +100 Moedas</Text>
            </TouchableOpacity>
          </View>
        </View>
      )}
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  hud: {
    paddingTop: 60,
    paddingHorizontal: 20,
  },
  hudTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  statBox: {
    backgroundColor: '#ffffff11',
    padding: 12,
    borderRadius: 8,
    minWidth: 100,
    borderWidth: 1,
    borderColor: '#ffffff22',
  },
  statLabel: {
    fontSize: 12,
    color: '#ffffff88',
    marginBottom: 4,
  },
  statValue: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#00f0ff',
  },
  xpBar: {
    height: 8,
    backgroundColor: '#ffffff22',
    borderRadius: 4,
    overflow: 'hidden',
    marginTop: 4,
  },
  xpFill: {
    height: '100%',
    backgroundColor: '#00f0ff',
  },
  hpBarContainer: {
    marginTop: 8,
  },
  hpText: {
    fontSize: 14,
    color: '#ffffff',
    marginBottom: 8,
    textAlign: 'center',
  },
  hpBar: {
    height: 24,
    backgroundColor: '#ffffff11',
    borderRadius: 12,
    overflow: 'hidden',
    borderWidth: 2,
    borderColor: '#ffffff22',
  },
  hpFill: {
    height: '100%',
  },
  arenaContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  arena: {
    backgroundColor: '#ffffff08',
    borderRadius: 20,
    borderWidth: 3,
    borderColor: '#00f0ff44',
    position: 'relative',
  },
  ball: {
    position: 'absolute',
    width: BALL_SIZE,
    height: BALL_SIZE,
    borderRadius: BALL_SIZE / 2,
    overflow: 'hidden',
  },
  ballGradient: {
    width: '100%',
    height: '100%',
    shadowColor: '#00f0ff',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 1,
    shadowRadius: 10,
  },
  controls: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 20,
    padding: 20,
  },
  controlButton: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: '#ffffff22',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#ffffff44',
  },
  controlText: {
    fontSize: 24,
    color: '#ffffff',
  },
  modalOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: '#000000cc',
    justifyContent: 'center',
    alignItems: 'center',
  },
  levelUpModal: {
    backgroundColor: '#1a0a2e',
    borderRadius: 20,
    padding: 30,
    width: '80%',
    maxWidth: 400,
    borderWidth: 3,
    borderColor: '#00f0ff',
  },
  modalTitle: {
    fontSize: 36,
    fontWeight: 'bold',
    color: '#00f0ff',
    textAlign: 'center',
    marginBottom: 10,
    textShadowColor: '#00f0ff',
    textShadowOffset: { width: 0, height: 0 },
    textShadowRadius: 20,
  },
  modalSubtitle: {
    fontSize: 18,
    color: '#ffffff',
    textAlign: 'center',
    marginBottom: 30,
  },
  upgradeOption: {
    backgroundColor: '#ffffff22',
    padding: 20,
    borderRadius: 12,
    marginBottom: 12,
    borderWidth: 2,
    borderColor: '#ffffff44',
  },
  upgradeText: {
    fontSize: 20,
    color: '#ffffff',
    fontWeight: 'bold',
    textAlign: 'center',
  },
});

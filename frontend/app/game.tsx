import React, { useState, useEffect, useRef } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Dimensions, Modal, ScrollView, Alert } from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import Animated, { useSharedValue, useAnimatedStyle, withTiming } from 'react-native-reanimated';
import Svg, { Circle } from 'react-native-svg';
import { useGame } from '@/src/contexts/GameContext';
import {
  createRings,
  updateRing,
  findClosestCollidingRing,
  findPerfectEscapeRing,
  reflectBallOffRing,
  clampBallSpeed,
  checkRingCollision,
  Ring,
} from '@/src/game/rings';
import { getRandomUpgrades, Upgrade, getRarityColor, getRarityName } from '@/src/game/upgrades';
import { getSkinById } from '@/src/game/skins';
import { getPhaseConfig } from '@/src/game/phases';
import { FloatingNumber } from '@/src/components/FloatingNumber';
import { AdModal } from '@/src/components/AdModal';
import { ECONOMY_BALANCE, getComboMultiplier, getGlobalCoinsFromRun, getRunProfileXp } from '@/src/game/economy';
import { playSound } from '@/src/utils/audio';
import { triggerHaptic } from '@/src/utils/feedback';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');
const GAME_SIZE = Math.min(SCREEN_WIDTH, SCREEN_HEIGHT - 240) * 0.98;
const CENTER_X = GAME_SIZE / 2;
const CENTER_Y = GAME_SIZE / 2;
const BALL_RADIUS = 10;
const OUTER_RADIUS = GAME_SIZE / 2 - 8;
const INNER_RADIUS = 35;
const INITIAL_BALL_SPEED = 2.05;
const INITIAL_RING_ROTATION_SPEED = 0.006;
const INITIAL_RING_SHRINK_SPEED = 0.026;
const XP_BASE_REQUIREMENT = 150;
const DIFFICULTY_SCALE = 0.13;

interface FloatingNumberData {
  id: string;
  value: number | string;
  x: number;
  y: number;
  isCritical: boolean;
  color?: string;
}

interface RunRewards {
  coins: number;
  gems: number;
  xp: number;
  ringsBroken: number;
  perfectEscapes: number;
  keys: number;
  chests: number;
  bestScore: number;
  bestCombo: number;
  criticals: number;
  skinEffects: number;
  runUpgrades: number;
  bonuses: string[];
}

const createProceduralPhaseConfig = (phaseNumber: number, playerLevel: number) => {
  const phase = getPhaseConfig(phaseNumber);
  const difficulty = 1 + (phaseNumber - 1) * DIFFICULTY_SCALE + Math.max(0, playerLevel - 1) * 0.012;
  const pattern = phaseNumber % 4;

  return {
    ringCount: Math.min(45, Math.floor((phase.ringMin + phase.ringMax) / 2) + Math.floor(playerLevel / 10)),
    baseHp: Math.round(phase.baseHp * difficulty),
    closingSpeed: Math.min(0.145, phase.closingSpeed + playerLevel * 0.00035),
    rotationSpeed: Math.min(0.034, phase.rotationSpeed + playerLevel * 0.0002),
    gapSize: Math.max(Math.PI / 7.2, phase.gapSize - playerLevel * 0.001),
    pattern,
  };
};

export default function GameScreen() {
  const router = useRouter();
  const { phase } = useLocalSearchParams();
  const { stats, updateGems, unlockPhase, gems, coins: accountCoins, ballTransformation, level: savedLevel, profileXp, settings, unlockedUpgrades, recordRunRewards, recordAdUse } = useGame();
  
  const [isPaused, setIsPaused] = useState(false);
  const [showPauseMenu, setShowPauseMenu] = useState(false);
  const [showLevelUp, setShowLevelUp] = useState(false);
  const [showVictory, setShowVictory] = useState(false);
  const [showGameOver, setShowGameOver] = useState(false);
  const [showAdRevive, setShowAdRevive] = useState(false);
  const [showAdReroll, setShowAdReroll] = useState(false);
  const [showAdDouble, setShowAdDouble] = useState(false);
  const [resultStatus, setResultStatus] = useState<'victory' | 'defeat' | 'quit'>('defeat');
  const [hasMounted, setHasMounted] = useState(false);
  
  const [coins, setCoins] = useState(0);
  const [xp, setXp] = useState(0);
  const [level, setLevel] = useState(1);
  const [score, setScore] = useState(0);
  const [dps, setDps] = useState(0);
  const [combo, setCombo] = useState(0);
  const [rewardMultiplier, setRewardMultiplier] = useState(1);
  const [runRewards, setRunRewards] = useState<RunRewards>({
    coins: 0,
    gems: 0,
    xp: 0,
    ringsBroken: 0,
    perfectEscapes: 0,
    keys: 0,
    chests: 0,
    bestScore: 0,
    bestCombo: 0,
    criticals: 0,
    skinEffects: 0,
    runUpgrades: 0,
    bonuses: [],
  });
  const [invincibleUntil, setInvincibleUntil] = useState(0);
  const [reviveMessage, setReviveMessage] = useState('');
  
  const [currentUpgrades, setCurrentUpgrades] = useState<Record<string, number>>({});
  const [runShopUpgrades, setRunShopUpgrades] = useState({ atk: 0, xp: 0, gold: 0 });
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
  const previousDistanceRef = useRef(0);
  const levelUpPendingRef = useRef(false);
  const rewardsSavedRef = useRef(false);
  const invincibleUntilRef = useRef(0);
  const usedReviveRef = useRef(false);
  const comboRef = useRef(0);
  const lastComboAtRef = useRef(0);
  const bestComboRef = useRef(0);
  
  const ballX = useSharedValue(CENTER_X);
  const ballY = useSharedValue(CENTER_Y);
  const shakeX = useSharedValue(0);
  const shakeY = useSharedValue(0);
  const [, setRenderTick] = useState(0);
  
  const gameLoopRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const xpToNextLevel = Math.floor(XP_BASE_REQUIREMENT * Math.pow(level, 1.55));
  const xpProgress = Math.min(100, (xp / xpToNextLevel) * 100);
  const protectionSeconds = Math.max(0, Math.ceil((invincibleUntil - Date.now()) / 1000));
  
  // Calculated stats
  const equippedSkin = getSkinById(ballTransformation);
  const skinPassive = equippedSkin.passive;
  const skinDamageBonus = skinPassive.type === 'damage_multiplier' || skinPassive.type === 'cosmic_critical' ? skinPassive.value : 0;
  const baseDamage = stats.baseDamage * (1 + skinDamageBonus + (currentUpgrades['damage'] || 0) * 0.15 + runShopUpgrades.atk * 0.18);
  const critChance = stats.critChance + (currentUpgrades['critical'] || 0) * 5 + (currentUpgrades['criticalOverload'] || 0) * 2 + (skinPassive.type === 'crit_chance' ? skinPassive.value : 0);
  const coinMultiplier = stats.coinMultiplier * (1 + (currentUpgrades['coinBoost'] || 0) * 0.25 + (currentUpgrades['magnetCoins'] || 0) * 0.25 + runShopUpgrades.gold * 0.22 + (skinPassive.type === 'coin_multiplier' || skinPassive.type === 'cosmic_critical' ? skinPassive.value * 0.7 : 0));
  const xpMultiplier = stats.xpMultiplier * (1 + (currentUpgrades['xpBoost'] || 0) * 0.25 + runShopUpgrades.xp * 0.2 + (skinPassive.type === 'xp_multiplier' || skinPassive.type === 'cosmic_critical' ? skinPassive.value * 0.55 : 0));
  const speedMultiplier = 1 + (currentUpgrades['speed'] || 0) * 0.12 + (skinPassive.type === 'speed' ? skinPassive.value : 0);
  const perfectDiamondChance = Math.min(0.18, 0.03 + (currentUpgrades['perfectChance'] || 0) * 0.01 + (skinPassive.type === 'perfect_chance' || skinPassive.type === 'cosmic_critical' ? skinPassive.value : 0));

  const getSafeUpgradeOptions = (previous: Upgrade[] = []) => {
    const options = getRandomUpgrades(3, currentUpgrades, savedLevel, unlockedUpgrades)
      .filter(upgrade => upgrade?.id && upgrade.name && upgrade.description && upgrade.icon);
    return options.length >= 3 ? options.slice(0, 3) : previous.length >= 3 ? previous : options;
  };

  useEffect(() => {
    setHasMounted(true);
    initializeGame();
    return () => {
      if (gameLoopRef.current) clearInterval(gameLoopRef.current);
    };
  }, []);

  useEffect(() => { isPausedRef.current = isPaused; }, [isPaused]);
  useEffect(() => { showLevelUpRef.current = showLevelUp; }, [showLevelUp]);
  useEffect(() => { invincibleUntilRef.current = invincibleUntil; }, [invincibleUntil]);

  const initializeGame = () => {
    const phaseNumber = Number(phase) || 1;
    const config = createProceduralPhaseConfig(phaseNumber, savedLevel);
    setShowVictory(false);
    setShowGameOver(false);
    setShowLevelUp(false);
    setCoins(0);
    setXp(0);
    setLevel(1);
    setScore(0);
    setDps(0);
    setCurrentUpgrades({});
    setRunShopUpgrades({ atk: 0, xp: 0, gold: 0 });
    setRunRewards({
      coins: 0,
      gems: 0,
      xp: 0,
      ringsBroken: 0,
      perfectEscapes: 0,
      keys: 0,
      chests: 0,
      bestScore: 0,
      bestCombo: 0,
      criticals: 0,
      skinEffects: 0,
      runUpgrades: 0,
      bonuses: [],
    });
    setCombo(0);
    setRewardMultiplier(1);
    setInvincibleUntil(0);
    
    const newRings = createRings({
      count: config.ringCount,
      innerRadius: INNER_RADIUS,
      outerRadius: OUTER_RADIUS,
      baseRotationSpeed: config.rotationSpeed,
      baseHp: config.baseHp,
      baseGapSize: config.gapSize,
      baseThickness: 5,
      closingSpeed: config.closingSpeed,
      colors: ['#00f0ff', '#b000ff', '#ff0055', '#00ff88', '#ffd700', '#ff8800'],
    }, phaseNumber);
    
    ringsRef.current = newRings;
    
    // Initialize ball with random angle
    const startAngle = Math.random() * Math.PI * 2;
    const speed = INITIAL_BALL_SPEED + Math.min(0.9, (phaseNumber - 1) * 0.13 + savedLevel * 0.01);
    velocityRef.current = {
      x: Math.cos(startAngle) * speed,
      y: Math.sin(startAngle) * speed,
    };
    ballPosRef.current = { x: CENTER_X, y: CENTER_Y };
    ballX.value = CENTER_X;
    ballY.value = CENTER_Y;
    previousDistanceRef.current = 0;
    rewardsSavedRef.current = false;
    usedReviveRef.current = false;
    comboRef.current = 0;
    bestComboRef.current = 0;
    lastComboAtRef.current = 0;
    levelUpPendingRef.current = false;
    
    initializedRef.current = true;
    isGameOverRef.current = false;
    startGameLoop();
  };

  const startGameLoop = () => {
    if (gameLoopRef.current) clearInterval(gameLoopRef.current);
    
    gameLoopRef.current = setInterval(() => {
      if (!isPausedRef.current && !isGameOverRef.current && !showLevelUpRef.current && initializedRef.current) {
        updateGame(1);
      }
    }, 16);
  };

  const addBonus = (label: string) => {
    setRunRewards(prev => ({
      ...prev,
      bonuses: prev.bonuses.includes(label) ? prev.bonuses : [...prev.bonuses.slice(-5), label],
    }));
  };

  const awardCoins = (amount: number) => {
    if (amount <= 0) return;
    const comboBonus = getComboMultiplier(comboRef.current).coins;
    const balanced = Math.max(1, Math.floor(amount * comboBonus * ECONOMY_BALANCE.runCoinMultiplier));
    setCoins(prev => prev + balanced);
    setRunRewards(prev => ({ ...prev, coins: prev.coins + balanced }));
  };

  const awardGem = async (amount: number) => {
    if (amount <= 0) return;
    setRunRewards(prev => ({ ...prev, gems: prev.gems + amount }));
  };

  const awardXp = (amount: number) => {
    if (amount <= 0) return;
    const balancedAmount = Math.max(1, Math.floor(amount * getComboMultiplier(comboRef.current).xp));
    setRunRewards(prev => ({ ...prev, xp: prev.xp + balancedAmount }));
    setXp(prev => {
      const newXP = prev + balancedAmount;
      if (!levelUpPendingRef.current && newXP >= xpToNextLevel) {
        levelUpPendingRef.current = true;
        handleLevelUp();
        return newXP - xpToNextLevel;
      }
      return newXP;
    });
  };

  const triggerImpact = (type: 'hit' | 'critical' | 'perfect' | 'break' | 'victory' | 'defeat' | 'skin') => {
    triggerHaptic(type, settings.haptics);
    if (type === 'hit' || type === 'critical' || type === 'break') {
      const force = type === 'critical' ? 5 : type === 'break' ? 4 : 2;
      shakeX.value = withTiming(force, { duration: 35 }, () => {
        shakeX.value = withTiming(0, { duration: 90 });
      });
      shakeY.value = withTiming(-force * 0.5, { duration: 35 }, () => {
        shakeY.value = withTiming(0, { duration: 90 });
      });
    }
  };

  const registerCombo = (x: number, y: number, label = 'Combo') => {
    const now = Date.now();
    const nextCombo = now - lastComboAtRef.current <= ECONOMY_BALANCE.comboWindowMs ? comboRef.current + 1 : 1;
    lastComboAtRef.current = now;
    comboRef.current = nextCombo;
    bestComboRef.current = Math.max(bestComboRef.current, nextCombo);
    setCombo(nextCombo);
    setRunRewards(prev => ({ ...prev, bestCombo: Math.max(prev.bestCombo, nextCombo) }));
    if (nextCombo >= 2) {
      const comboBonus = getComboMultiplier(nextCombo);
      addFloatingNumber(`${comboBonus.label} x${nextCombo}`, x - 18, y - 26, false, nextCombo >= 20 ? '#ffffff' : nextCombo >= 10 ? '#ffd700' : '#00f0ff');
      if (nextCombo === 5 || nextCombo === 10 || nextCombo === 20) {
        triggerImpact('critical');
        playSound('combo', settings.sound);
      }
    } else if (label) {
      addFloatingNumber(label, x, y - 18, false, '#00f0ff');
    }
  };

  const checkGameOver = (
    ball: { x: number; y: number; radius: number },
    rings: Ring[],
    gameState: { now: number; invincibleUntil: number }
  ) => {
    const safetyMargin = 12;

    if (gameState.now < gameState.invincibleUntil) return false;
    if (!rings.length) return false;
    if (!Number.isFinite(ball.x) || !Number.isFinite(ball.y) || !Number.isFinite(ball.radius)) return false;

    const dx = ball.x - CENTER_X;
    const dy = ball.y - CENTER_Y;
    const ballDistance = Math.sqrt(dx * dx + dy * dy);

    return rings.some(ring => {
      if (!ring || ring.status !== 'active' || ring.hp <= 0 || !Number.isFinite(ring.radius)) return false;

      const collision = checkRingCollision(ball.x, ball.y, ball.radius, ring, CENTER_X, CENTER_Y);
      if (collision.isInGap) return false;

      if (ballDistance <= ball.radius + safetyMargin) {
        return ring.radius <= Math.max(2, ball.radius * 0.35);
      }

      const crushRadius = Math.max(0, ballDistance - ball.radius - safetyMargin);
      const ringHasPassedThroughBall = ring.radius <= crushRadius;
      const ringStillNearBall = Math.abs(ballDistance - ring.radius) <= ball.radius + safetyMargin + ring.thickness;

      return ringHasPassedThroughBall && ringStillNearBall;
    });
  };

  const saveRunRewards = async (won = false) => {
    if (rewardsSavedRef.current) return;
    rewardsSavedRef.current = true;
    const multiplier = rewardMultiplier;
    const profileXpReward = getRunProfileXp(runRewards.xp, runRewards.ringsBroken, runRewards.perfectEscapes, runRewards.bestCombo) * multiplier;
    await recordRunRewards({
      coins: coins * multiplier,
      gems: runRewards.gems * multiplier,
      keys: runRewards.keys * multiplier,
      profileXp: profileXpReward,
      ringsDestroyed: runRewards.ringsBroken,
      perfectEscapes: runRewards.perfectEscapes,
      phase: Number(phase) || 1,
      runLevel: level,
      won,
      usedRevive: usedReviveRef.current,
      bestCombo: runRewards.bestCombo,
      runUpgrades: runRewards.runUpgrades,
      criticals: runRewards.criticals,
      skinEffects: runRewards.skinEffects,
    });
  };

  const updateGame = (deltaTime = 1) => {
    const targetSpeed = (INITIAL_BALL_SPEED + Math.min(0.9, (Number(phase) - 1 || 0) * 0.12)) * speedMultiplier;
    velocityRef.current = clampBallSpeed(velocityRef.current, targetSpeed * 0.78, targetSpeed * 1.42);

    if (
      !Number.isFinite(ballPosRef.current.x) ||
      !Number.isFinite(ballPosRef.current.y) ||
      !Number.isFinite(velocityRef.current.x) ||
      !Number.isFinite(velocityRef.current.y)
    ) {
      ballPosRef.current = { x: CENTER_X, y: CENTER_Y };
      velocityRef.current = { x: targetSpeed, y: 0 };
    }

    const prevDx = ballPosRef.current.x - CENTER_X;
    const prevDy = ballPosRef.current.y - CENTER_Y;
    const prevDist = Math.sqrt(prevDx * prevDx + prevDy * prevDy);
    ballPosRef.current.x += velocityRef.current.x * deltaTime;
    ballPosRef.current.y += velocityRef.current.y * deltaTime;

    const arenaDx = ballPosRef.current.x - CENTER_X;
    const arenaDy = ballPosRef.current.y - CENTER_Y;
    const arenaDist = Math.sqrt(arenaDx * arenaDx + arenaDy * arenaDy);
    const maxBallDistance = OUTER_RADIUS - BALL_RADIUS;
    if (arenaDist > maxBallDistance && Number.isFinite(arenaDist) && arenaDist > 0) {
      const nx = arenaDx / arenaDist;
      const ny = arenaDy / arenaDist;
      ballPosRef.current.x = CENTER_X + nx * maxBallDistance;
      ballPosRef.current.y = CENTER_Y + ny * maxBallDistance;

      const outwardVelocity = velocityRef.current.x * nx + velocityRef.current.y * ny;
      if (outwardVelocity > 0) {
        velocityRef.current.x -= 2 * outwardVelocity * nx;
        velocityRef.current.y -= 2 * outwardVelocity * ny;
      }
    }

    const nextDx = ballPosRef.current.x - CENTER_X;
    const nextDy = ballPosRef.current.y - CENTER_Y;
    const nextDist = Math.sqrt(nextDx * nextDx + nextDy * nextDy);

    ballX.value = ballPosRef.current.x;
    ballY.value = ballPosRef.current.y;

    const now = Date.now();
    if (comboRef.current > 0 && now - lastComboAtRef.current > ECONOMY_BALANCE.comboWindowMs) {
      comboRef.current = 0;
      setCombo(0);
    }
    let updatedRings = ringsRef.current.map(ring => updateRing(ring, deltaTime, now));

    const perfectEscape = findPerfectEscapeRing(
      prevDist,
      nextDist,
      ballPosRef.current.x,
      ballPosRef.current.y,
      BALL_RADIUS,
      updatedRings,
      CENTER_X,
      CENTER_Y
    );

    if (perfectEscape.ring && perfectEscape.index >= 0) {
      updatedRings[perfectEscape.index] = { ...perfectEscape.ring, status: 'cleared', hp: 0 };
      const perfectCoins = Math.max(2, Math.floor(5 * coinMultiplier));
      const perfectXp = Math.floor((10 + Math.random() * 11) * xpMultiplier);
      awardCoins(perfectCoins);
      awardXp(perfectXp);
      setRunRewards(prev => ({ ...prev, perfectEscapes: prev.perfectEscapes + 1 }));
      addFloatingNumber('Perfect', ballPosRef.current.x, ballPosRef.current.y, false, '#b8f3ff');
      registerCombo(ballPosRef.current.x, ballPosRef.current.y, 'Perfect');
      triggerImpact('perfect');
      playSound('perfect', settings.sound);

      if (Math.random() < perfectDiamondChance) {
        awardGem(1);
        if (skinPassive.type === 'perfect_chance') addBonus('Perfect Chance!');
        addFloatingNumber('Perfect +1 💎', ballPosRef.current.x + 10, ballPosRef.current.y + 10, false, '#c084fc');
      }
    }

    const { ring: closestRing, index, isInSolidPart } = findClosestCollidingRing(
      ballPosRef.current.x,
      ballPosRef.current.y,
      BALL_RADIUS,
      updatedRings,
      CENTER_X,
      CENTER_Y
    );

    const canHit = now - lastHitTimeRef.current > 80;

    if (closestRing && index >= 0 && isInSolidPart && canHit) {
      lastHitTimeRef.current = now;

      const ghostPass = skinPassive.type === 'phase_solid' && Math.random() < (skinPassive.chance || 0);
      if (ghostPass) {
        updatedRings[index] = { ...updatedRings[index], status: 'cleared', hp: 0 };
        setRunRewards(prev => ({ ...prev, perfectEscapes: prev.perfectEscapes + 1 }));
        awardXp(Math.floor((8 + Math.random() * 8) * xpMultiplier));
        addBonus('Phase!');
        addFloatingNumber('Phase!', ballPosRef.current.x, ballPosRef.current.y, false, '#dff7ff');
        registerCombo(ballPosRef.current.x, ballPosRef.current.y, 'Phase');
        setRunRewards(prev => ({ ...prev, skinEffects: prev.skinEffects + 1 }));
        triggerImpact('skin');
      } else {
      const megaCrit = skinPassive.type === 'mega_crit' && Math.random() < (skinPassive.chance || 0);
      const isCrit = megaCrit || Math.random() * 100 < critChance;
      const damage = baseDamage * (1 + (currentUpgrades['laserCut'] && Math.random() < 0.08 ? currentUpgrades['laserCut'] * 0.5 : 0)) * (isCrit ? (megaCrit ? skinPassive.value : stats.critMultiplier + (currentUpgrades['criticalOverload'] || 0) * 0.15) : 1);
      const wasAlive = closestRing.hp > 0;
      const newHP = Math.max(0, closestRing.hp - damage);
      
      updatedRings[index] = { ...updatedRings[index], hp: newHP, status: newHP <= 0 ? 'broken' as const : 'active' as const };

      updatedRings = applySkinImpact(updatedRings, index, damage, now);
      triggerImpact(isCrit ? 'critical' : 'hit');
      playSound('hit', settings.sound);
      if (isCrit) setRunRewards(prev => ({ ...prev, criticals: prev.criticals + 1 }));
      
      const reflection = reflectBallOffRing(
        ballPosRef.current.x,
        ballPosRef.current.y,
        velocityRef.current.x,
        velocityRef.current.y,
        CENTER_X,
        CENTER_Y,
        0.08
      );
      velocityRef.current.x = reflection.newVelX;
      velocityRef.current.y = reflection.newVelY;

      if (skinPassive.type === 'slime_bounce' && Math.random() < (skinPassive.chance || 0)) {
        velocityRef.current.x *= 1 + skinPassive.value;
        velocityRef.current.y *= 1 + skinPassive.value;
        addFloatingNumber('Slime!', ballPosRef.current.x, ballPosRef.current.y, false, '#3dff8f');
      }
      
      const dx = ballPosRef.current.x - CENTER_X;
      const dy = ballPosRef.current.y - CENTER_Y;
      const distFromCenter = Math.sqrt(dx * dx + dy * dy) || 1;
      const nx = dx / distFromCenter;
      const ny = dy / distFromCenter;
      const safeDistance = closestRing.radius + (distFromCenter > closestRing.radius ? 1 : -1) * (closestRing.thickness / 2 + BALL_RADIUS + 2);
      ballPosRef.current.x = CENTER_X + nx * safeDistance;
      ballPosRef.current.y = CENTER_Y + ny * safeDistance;
      ballX.value = ballPosRef.current.x;
      ballY.value = ballPosRef.current.y;

      addFloatingNumber(damage, ballPosRef.current.x, ballPosRef.current.y, isCrit);
      if (wasAlive && newHP <= 0) {
        addFloatingNumber('Break!', ballPosRef.current.x + 8, ballPosRef.current.y - 8, false, '#ffd700');
        setRunRewards(prev => ({ ...prev, ringsBroken: prev.ringsBroken + 1 }));
        registerCombo(ballPosRef.current.x, ballPosRef.current.y, 'Break');
        triggerImpact('break');
        awardCoins(Math.max(6, Math.floor(12 * coinMultiplier)));
        awardXp(Math.floor((8 + Math.random() * 8) * xpMultiplier));
        if (currentUpgrades['chainBreak']) {
          updatedRings = updatedRings.map((ring, ringIndex) => {
            if (ringIndex <= index || ring.status !== 'active') return ring;
            const hp = Math.max(0, ring.hp - baseDamage * currentUpgrades['chainBreak'] * 0.35);
            return { ...ring, hp, status: hp <= 0 ? 'broken' as const : ring.status };
          });
          addFloatingNumber('Chain Break', ballPosRef.current.x, ballPosRef.current.y - 18, false, '#ffd700');
        }
      }

      let coinsGained = Math.floor(damage * 0.5 * coinMultiplier);
      if (skinPassive.type === 'coin_on_hit' && Math.random() < (skinPassive.chance || 0)) {
        coinsGained += skinPassive.value;
        addBonus('Bonus Coins!');
        addFloatingNumber(`+${skinPassive.value} 💰`, ballPosRef.current.x, ballPosRef.current.y + 10, false, '#ffd700');
      }
      const xpGained = Math.floor((isCrit ? 2 + Math.random() * 2 : 1) * xpMultiplier);
      
      awardCoins(coinsGained);
      setScore(prev => prev + damage);
      setRunRewards(prev => ({ ...prev, bestScore: Math.max(prev.bestScore, Math.floor(score + damage)) }));
      awardXp(xpGained);
      
      // Track DPS
      recentHitDpsRef.current.push(damage);
      if (recentHitDpsRef.current.length > 60) {
        recentHitDpsRef.current.shift();
      }
      const totalDamage = recentHitDpsRef.current.reduce((sum, d) => sum + d, 0);
      setDps(Math.floor(totalDamage));
      }
    }

    ringsRef.current = updatedRings;

    const activeRings = updatedRings.filter(r => r.status === 'active' && r.hp > 0);
    if (activeRings.length === 0) {
      handleVictory();
      return;
    }

    if (checkGameOver(
      { x: ballPosRef.current.x, y: ballPosRef.current.y, radius: BALL_RADIUS },
      activeRings,
      { now, invincibleUntil: invincibleUntilRef.current }
    )) {
      handleGameOver();
      return;
    }

    previousDistanceRef.current = nextDist;

    setRenderTick(t => (t + 1) % 1000);
  };

  const applySkinImpact = (rings: Ring[], hitIndex: number, damage: number, now: number) => {
    const ring = rings[hitIndex];
    if (!ring) return rings;
    const next = [...rings];
    const markSkinEffect = () => {
      setRunRewards(prev => ({ ...prev, skinEffects: prev.skinEffects + 1 }));
      triggerImpact('skin');
      playSound('combo', settings.sound);
    };

    if ((skinPassive.type === 'slow_ring' || skinPassive.type === 'freeze_ring') && Math.random() < (skinPassive.chance || 0)) {
      next[hitIndex] = { ...ring, slowUntil: now + (skinPassive.durationMs || 2200) };
      addBonus(skinPassive.type === 'freeze_ring' ? 'Frost!' : 'Slow!');
      addFloatingNumber(skinPassive.type === 'freeze_ring' ? 'Frost' : 'Slow', ballPosRef.current.x, ballPosRef.current.y, false, '#9be8ff');
      markSkinEffect();
    }

    if (currentUpgrades['slowField'] && Math.random() < 0.08 + currentUpgrades['slowField'] * 0.015) {
      addBonus('Slow Field!');
      return next.map(other => other.status === 'active' ? { ...other, slowUntil: now + 1800 + currentUpgrades['slowField'] * 250 } : other);
    }

    if (currentUpgrades['timeFreeze'] && Math.random() < 0.035 + currentUpgrades['timeFreeze'] * 0.01) {
      addBonus('Time Freeze!');
      return next.map(other => other.status === 'active' ? { ...other, slowUntil: now + 2400 } : other);
    }

    if ((skinPassive.type === 'repel_ring' && Math.random() < (skinPassive.chance || 0)) || (currentUpgrades['ringRepulse'] && Math.random() < 0.1)) {
      const repulse = skinPassive.type === 'repel_ring' ? skinPassive.value : 14 + currentUpgrades['ringRepulse'] * 3;
      next[hitIndex] = { ...next[hitIndex], radius: Math.min(ring.initialRadius + 24, ring.radius + repulse) };
      addBonus('Repel!');
      addFloatingNumber('Repel', ballPosRef.current.x, ballPosRef.current.y, false, '#c084fc');
      markSkinEffect();
    }

    if (currentUpgrades['shieldPulse'] && Math.random() < 0.06 + currentUpgrades['shieldPulse'] * 0.015) {
      const until = now + 1100 + currentUpgrades['shieldPulse'] * 350;
      setInvincibleUntil(until);
      invincibleUntilRef.current = until;
      addBonus('Shield Pulse!');
      addFloatingNumber('Shield', ballPosRef.current.x, ballPosRef.current.y, false, '#00ff88');
    }

    if (skinPassive.type === 'burn' && Math.random() < (skinPassive.chance || 0)) {
      next[hitIndex] = { ...next[hitIndex], burnUntil: now + (skinPassive.durationMs || 3000), burnDps: skinPassive.value };
      addBonus('Burn!');
      addFloatingNumber('Burn', ballPosRef.current.x, ballPosRef.current.y, false, '#ff8a00');
      markSkinEffect();
    }

    if (skinPassive.type === 'area_damage' && Math.random() < (skinPassive.chance || 0)) {
      addBonus('Area Damage!');
      markSkinEffect();
      return next.map((other, index) => {
        if (index === hitIndex || other.status !== 'active' || Math.abs(other.radius - ring.radius) > 34) return other;
        const hp = Math.max(0, other.hp - damage * skinPassive.value);
        return { ...other, hp, status: hp <= 0 ? 'broken' as const : other.status };
      });
    }

    if (skinPassive.type === 'chain_damage' && Math.random() < (skinPassive.chance || 0)) {
      const targetIndex = next.findIndex((other, index) => index !== hitIndex && other.status === 'active' && other.hp > 0);
      if (targetIndex >= 0) {
        const target = next[targetIndex];
        const hp = Math.max(0, target.hp - damage * skinPassive.value);
        next[targetIndex] = { ...target, hp, status: hp <= 0 ? 'broken' as const : target.status };
        addBonus('Chain!');
        addFloatingNumber('Chain', ballPosRef.current.x, ballPosRef.current.y, false, '#faff00');
        markSkinEffect();
      }
    }

    if (skinPassive.type === 'cosmic_critical' && Math.random() < (skinPassive.chance || 0)) {
      addBonus('Cosmic Repulse!');
      markSkinEffect();
      return next.map(other =>
        other.status === 'active'
          ? { ...other, radius: Math.min(other.initialRadius + 28, other.radius + 12 + skinPassive.value * 18) }
          : other
      );
    }

    return next;
  };

  const addFloatingNumber = (value: number | string, x: number, y: number, isCritical: boolean, color?: string) => {
    const id = `num_${Date.now()}_${Math.random()}`;
    setFloatingNumbers(prev => [...prev.slice(-18), { id, value, x, y, isCritical, color }]);
  };

  const removeFloatingNumber = (id: string) => {
    setFloatingNumbers(prev => prev.filter(num => num.id !== id));
  };

  const handleLevelUp = () => {
    setLevel(prev => {
      const newLevel = prev + 1;
      const upgrades = getSafeUpgradeOptions(availableUpgrades);
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
    setRunRewards(prev => ({ ...prev, runUpgrades: prev.runUpgrades + 1 }));
    setShowLevelUp(false);
    levelUpPendingRef.current = false;
    setRerollsUsed(0);
  };

  const handleRerollAd = () => {
    setShowAdReroll(true);
  };

  const handleRerollGems = async () => {
    if (gems < 10) {
      Alert.alert('Gemas insuficientes', 'Você precisa de 10 gemas para trocar as opções.');
      return;
    }
    const upgrades = getSafeUpgradeOptions(availableUpgrades);
    if (upgrades.length < 3) return;
    await updateGems(-10);
    setAvailableUpgrades(upgrades);
    setRerollsUsed(prev => prev + 1);
  };

  const handleAdRerollCompleted = () => {
    recordAdUse('upgrade_reroll');
    const upgrades = getSafeUpgradeOptions(availableUpgrades);
    if (upgrades.length >= 3) setAvailableUpgrades(upgrades);
    setRerollsUsed(prev => prev + 1);
    setShowAdReroll(false);
  };

  const getRunUpgradeCost = (type: 'atk' | 'xp' | 'gold') => {
    const base = type === 'atk' ? 20 : type === 'xp' ? 24 : 18;
    return Math.floor(base * Math.pow(1.35, runShopUpgrades[type]));
  };

  const buyRunUpgrade = (type: 'atk' | 'xp' | 'gold') => {
    const cost = getRunUpgradeCost(type);
    if (coins < cost) return;
    setCoins(prev => prev - cost);
    setRunShopUpgrades(prev => ({ ...prev, [type]: prev[type] + 1 }));
    setRunRewards(prev => ({ ...prev, runUpgrades: prev.runUpgrades + 1 }));
    addFloatingNumber(type === 'atk' ? 'ATK+' : type === 'xp' ? 'XP+' : 'Gold+', CENTER_X - 12, CENTER_Y - 28, false, '#ffd700');
  };

  const openPauseMenu = () => {
    setIsPaused(true);
    setShowPauseMenu(true);
  };

  const closePauseMenu = () => {
    setShowPauseMenu(false);
    setIsPaused(false);
  };

  const handleGameOver = () => {
    isGameOverRef.current = true;
    if (gameLoopRef.current) clearInterval(gameLoopRef.current);
    setResultStatus('defeat');
    setShowGameOver(true);
    triggerImpact('defeat');
    playSound('defeat', settings.sound);
  };

  const handleRevive = () => {
    recordAdUse('revive');
    const now = Date.now();
    isGameOverRef.current = false;
    setShowGameOver(false);
    setShowAdRevive(false);
    usedReviveRef.current = true;
    setInvincibleUntil(now + 3500);
    invincibleUntilRef.current = now + 3500;
    setReviveMessage('Revive ativado');
    setTimeout(() => setReviveMessage(''), 1800);
    
    ringsRef.current = ringsRef.current.map(ring => ({
      ...ring,
      radius: Math.min(ring.initialRadius + 36, ring.radius + 95),
      slowUntil: now + 2600,
    }));

    const reviveAngle = Math.random() * Math.PI * 2;
    const reviveSpeed = 3.4 * speedMultiplier;
    ballPosRef.current = { x: CENTER_X, y: CENTER_Y };
    ballX.value = CENTER_X;
    ballY.value = CENTER_Y;
    velocityRef.current = {
      x: Math.cos(reviveAngle) * reviveSpeed,
      y: Math.sin(reviveAngle) * reviveSpeed,
    };
    previousDistanceRef.current = 0;
    lastHitTimeRef.current = 0;
    addFloatingNumber('Revive ativado', CENTER_X - 40, CENTER_Y - 18, false, '#00ff88');
    
    startGameLoop();
  };

  const handleGiveUp = async () => {
    if (gameLoopRef.current) clearInterval(gameLoopRef.current);
    setShowPauseMenu(false);
    setIsPaused(false);
    isGameOverRef.current = true;
    setResultStatus('quit');
    setShowGameOver(true);
  };

  const handleRetry = async () => {
    await saveRunRewards(false);
    initializeGame();
  };

  const handleVictory = async () => {
    if (gameLoopRef.current) clearInterval(gameLoopRef.current);
    isGameOverRef.current = true;
    setResultStatus('victory');
    setShowVictory(true);
    triggerImpact('victory');
    playSound('victory', settings.sound);
  };

  const handleCollectAndExit = async (won: boolean) => {
    await saveRunRewards(won);
    if (won) {
      const nextPhase = Number(phase) + 1;
      if (nextPhase <= 20) await unlockPhase(nextPhase);
    }
    router.replace('/');
  };

  const handleNextPhase = async () => {
    await saveRunRewards(true);
    const nextPhase = Number(phase) + 1;
    if (nextPhase <= 20) await unlockPhase(nextPhase);
    router.replace({ pathname: '/game', params: { phase: Math.min(20, nextPhase) } });
  };

  const handleDoubleRewards = async () => {
    const ok = await recordAdUse('double_run_reward');
    if (!ok) return;
    setRewardMultiplier(2);
    setShowAdDouble(false);
    addFloatingNumber('Recompensas x2', CENTER_X - 38, CENTER_Y - 16, false, '#ffd700');
  };

  const ballAnimatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: ballX.value - BALL_RADIUS },
      { translateY: ballY.value - BALL_RADIUS },
    ],
  }));

  const shakeStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: shakeX.value },
      { translateY: shakeY.value },
    ],
  }));

  if (!hasMounted) {
    return (
      <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
        <View style={styles.serverFallback}>
          <Text style={styles.serverFallbackText}>Carregando arena...</Text>
        </View>
      </LinearGradient>
    );
  }

  const activeRings = ringsRef.current.filter(r => r.status === 'active' && r.hp > 0);
  const totalRings = ringsRef.current.length;
  const remainingPercentage = totalRings > 0 ? (activeRings.length / totalRings) * 100 : 0;
  const profileXpReward = getRunProfileXp(runRewards.xp, runRewards.ringsBroken, runRewards.perfectEscapes, runRewards.bestCombo) * rewardMultiplier;
  const globalCoinsReward = getGlobalCoinsFromRun(coins * rewardMultiplier, runRewards.bestCombo, showVictory);
  const nextProfileXpNeeded = Math.floor(220 * Math.pow(savedLevel, 1.45));
  const nextProfileProgress = Math.min(100, ((profileXp + profileXpReward) / nextProfileXpNeeded) * 100);

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
            <Text style={styles.hudValue}>{runRewards.gems}</Text>
          </View>
          <View style={styles.hudItem}>
            <Text style={styles.hudIcon}>🏦</Text>
            <Text style={styles.hudValue}>{accountCoins}</Text>
          </View>
          <TouchableOpacity style={styles.pauseMiniButton} onPress={openPauseMenu}>
            <Text style={styles.pauseMiniText}>⏸</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.levelRow}>
          <Text style={styles.levelText}>⭐ Lv.{level}</Text>
          <View style={styles.xpBarLarge}>
            <View style={[styles.xpFillLarge, { width: `${xpProgress}%` }]} />
            <Text style={styles.xpText}>{xp}/{xpToNextLevel}</Text>
          </View>
        </View>

        <View style={styles.progressContainer}>
          <Text style={styles.progressText}>
            🌀 Anéis: {activeRings.length}/{totalRings} • DPS {Math.floor(dps)} {combo >= 2 ? `• Combo x${combo}` : ''}
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
        <Animated.View style={[styles.gameArea, { width: GAME_SIZE, height: GAME_SIZE }, shakeStyle]}>
          {hasMounted && (
            <Svg width={GAME_SIZE} height={GAME_SIZE} style={StyleSheet.absoluteFill}>
              {ringsRef.current.map((ring) => {
                if (ring.status !== 'active' || ring.hp <= 0) return null;

                const circumference = 2 * Math.PI * ring.radius;
                const gapLength = (ring.gapSize / (Math.PI * 2)) * circumference;
                const arcLength = circumference - gapLength;
                const opacity = Math.max(0.4, ring.hp / ring.maxHp);
                const rotationDeg = (ring.rotation * 180) / Math.PI;
                const gapOffsetDeg = ((ring.gapStart + ring.gapSize / 2) * 180) / Math.PI;

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
              {protectionSeconds > 0 && (
                <Circle
                  cx={ballPosRef.current.x}
                  cy={ballPosRef.current.y}
                  r={BALL_RADIUS + 12}
                  stroke="#00ff88"
                  strokeWidth={2}
                  fill="none"
                  opacity={0.75}
                />
              )}
            </Svg>
          )}

          {/* Ball */}
          <Animated.View style={[styles.ball, ballAnimatedStyle]}>
            <View style={[styles.skinTrail, { borderColor: equippedSkin.secondaryColor }]} />
            <View style={[styles.ballGlow, protectionSeconds > 0 && styles.ballShield, { shadowColor: equippedSkin.primaryColor }]}>
              <LinearGradient
                colors={['#ffffff', equippedSkin.primaryColor, equippedSkin.secondaryColor]}
                style={styles.ballGradient}
              >
                <Text style={styles.skinIconInBall}>{equippedSkin.icon}</Text>
              </LinearGradient>
            </View>
          </Animated.View>

          {(protectionSeconds > 0 || reviveMessage) && (
            <View style={styles.protectionBadge}>
              <Text style={styles.protectionText}>
                {reviveMessage || `Escudo ${protectionSeconds}s`}
              </Text>
            </View>
          )}

          {/* Floating Numbers */}
          {floatingNumbers.map(num => (
            <FloatingNumber
              key={num.id}
              value={num.value}
              x={num.x}
              y={num.y}
              isCritical={num.isCritical}
              color={num.color}
              onComplete={() => removeFloatingNumber(num.id)}
            />
          ))}
          {combo >= 2 && (
            <View style={[styles.comboBadge, combo >= 10 && styles.comboBadgeHot]}>
              <Text style={styles.comboText}>{getComboMultiplier(combo).label} x{combo}</Text>
            </View>
          )}
        </Animated.View>
      </View>

      <View style={styles.runUpgradeBar}>
        {([
          ['atk', 'ATK', '⚔️'],
          ['xp', 'XP', '⭐'],
          ['gold', 'Gold', '💰'],
        ] as const).map(([type, label, icon]) => {
          const cost = getRunUpgradeCost(type);
          const canBuy = coins >= cost;
          return (
            <TouchableOpacity key={type} style={[styles.runUpgradeButton, !canBuy && styles.disabled]} onPress={() => buyRunUpgrade(type)} disabled={!canBuy}>
              <Text style={styles.runUpgradeIcon}>{icon}</Text>
              <Text style={styles.runUpgradeLabel}>{label} Lv.{runShopUpgrades[type]}</Text>
              <Text style={styles.runUpgradeCost}>{cost} 💰</Text>
            </TouchableOpacity>
          );
        })}
      </View>

      <Modal visible={showPauseMenu} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.pauseModal}>
            <LinearGradient colors={['#1a0a2e', '#16003b']} style={styles.modalContent}>
              <Text style={styles.modalTitle}>PAUSE</Text>
              <TouchableOpacity style={styles.actionButton} onPress={closePauseMenu}>
                <LinearGradient colors={['#00f0ff', '#0088ff']} style={styles.buttonGradient}>
                  <Text style={styles.buttonText}>CONTINUAR</Text>
                </LinearGradient>
              </TouchableOpacity>
              <TouchableOpacity style={styles.actionButton} onPress={handleRetry}>
                <LinearGradient colors={['#b000ff', '#6600cc']} style={styles.buttonGradient}>
                  <Text style={styles.buttonText}>REINICIAR</Text>
                </LinearGradient>
              </TouchableOpacity>
              <TouchableOpacity style={styles.giveUpButton} onPress={handleGiveUp}>
                <Text style={styles.giveUpText}>Sair para o menu</Text>
              </TouchableOpacity>
              <Text style={styles.pauseHint}>Configurações: som e vibração salvos no perfil local.</Text>
            </LinearGradient>
          </View>
        </View>
      </Modal>

      {/* Level Up Modal */}
      {showLevelUp && (
        <Modal visible transparent animationType="fade">
          <View style={styles.modalOverlay}>
            <View style={styles.levelUpModal}>
              <LinearGradient colors={['#1a0a2e', '#16003b']} style={styles.modalContent}>
                <ScrollView contentContainerStyle={styles.levelUpContent} showsVerticalScrollIndicator={false}>
                  <Text style={styles.modalTitle}>LEVEL {level}</Text>
                  <Text style={styles.modalSubtitle}>Escolha um upgrade</Text>

                  <View style={styles.upgradeGrid}>
                    {availableUpgrades.slice(0, 3).map((upgrade) => (
                      <TouchableOpacity
                        key={upgrade.id}
                        style={styles.upgradeCard}
                        onPress={() => selectUpgrade(upgrade)}
                      >
                        <LinearGradient
                          colors={[getRarityColor(upgrade.rarity) + '88', getRarityColor(upgrade.rarity) + '22']}
                          style={[styles.upgradeCardContent, { borderColor: getRarityColor(upgrade.rarity) }]}
                        >
                          <View style={styles.upgradeTopLine}>
                            <Text style={styles.upgradeIcon}>{upgrade.icon}</Text>
                            <Text style={[styles.upgradeRarityBadge, { backgroundColor: getRarityColor(upgrade.rarity) }]}>
                              {getRarityName(upgrade.rarity)}
                            </Text>
                          </View>
                          <Text style={styles.upgradeName}>{upgrade.name}</Text>
                          <Text style={styles.upgradeDescription}>{upgrade.description}</Text>
                          <Text style={styles.upgradeEffect}>Lv.{currentUpgrades[upgrade.id] || 0} → Lv.{(currentUpgrades[upgrade.id] || 0) + 1}</Text>
                          <Text style={styles.chooseText}>ESCOLHER</Text>
                        </LinearGradient>
                      </TouchableOpacity>
                    ))}
                  </View>

                  {availableUpgrades.length < 3 && (
                    <Text style={styles.modalSubtitle}>Carregando opções válidas...</Text>
                  )}

                  {rerollsUsed < 2 && availableUpgrades.length >= 3 && (
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
                      >
                        <LinearGradient colors={['#b000ff', '#6600cc']} style={styles.rerollGradient}>
                          <Text style={styles.rerollIcon}>💎</Text>
                          <Text style={styles.rerollText}>Trocar (10)</Text>
                        </LinearGradient>
                      </TouchableOpacity>
                    </View>
                  )}
                </ScrollView>
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
                <ScrollView style={styles.resultScroll} contentContainerStyle={styles.statsContainer}>
                  <Text style={styles.statText}>🏁 Fase: {Number(phase) || 1}</Text>
                  <Text style={styles.statText}>✅ Resultado: vitória</Text>
                  <Text style={styles.statText}>💰 Moedas da rodada: {runRewards.coins}</Text>
                  <Text style={styles.statText}>🏦 Moedas gerais: +{globalCoinsReward}</Text>
                  <Text style={styles.statText}>💎 Diamantes: {runRewards.gems * rewardMultiplier}</Text>
                  <Text style={styles.statText}>👤 XP de perfil: +{profileXpReward}</Text>
                  <Text style={styles.statText}>⭐ XP ganho: {runRewards.xp}</Text>
                  <Text style={styles.statText}>🌀 Quebrados: {runRewards.ringsBroken}</Text>
                  <Text style={styles.statText}>✨ Perfects: {runRewards.perfectEscapes}</Text>
                  <Text style={styles.statText}>🔥 Maior combo: x{runRewards.bestCombo}</Text>
                  <Text style={styles.statText}>🔑 Chaves/Baús: {runRewards.keys * rewardMultiplier}/{runRewards.chests}</Text>
                  <Text style={styles.statText}>🏆 Conquistas e missões sincronizadas ao coletar</Text>
                  <Text style={styles.statText}>📅 Missões diárias/evento recebem progresso desta rodada</Text>
                  <Text style={styles.statText}>⭐ Level: {level}</Text>
                  <Text style={styles.statText}>🎯 Score: {Math.floor(score)}</Text>
                  <View style={styles.profileProgress}>
                    <View style={[styles.profileProgressFill, { width: `${nextProfileProgress}%` }]} />
                  </View>
                </ScrollView>
                {rewardMultiplier === 1 && (
                  <TouchableOpacity style={styles.actionButton} onPress={() => setShowAdDouble(true)}>
                    <LinearGradient colors={['#ffd700', '#ff8800']} style={styles.buttonGradient}>
                      <Text style={styles.buttonText}>DOBRAR RECOMPENSA — AD</Text>
                    </LinearGradient>
                  </TouchableOpacity>
                )}
                <TouchableOpacity style={styles.actionButton} onPress={() => handleCollectAndExit(true)}>
                  <LinearGradient colors={['#00f0ff', '#0088ff']} style={styles.buttonGradient}>
                    <Text style={styles.buttonText}>COLETAR E SAIR</Text>
                  </LinearGradient>
                </TouchableOpacity>
                {Number(phase) < 20 && (
                  <TouchableOpacity style={styles.actionButton} onPress={handleNextPhase}>
                    <LinearGradient colors={['#00ff88', '#00aa66']} style={styles.buttonGradient}>
                      <Text style={styles.buttonText}>PRÓXIMA FASE</Text>
                    </LinearGradient>
                  </TouchableOpacity>
                )}
                <TouchableOpacity style={styles.giveUpButton} onPress={async () => { await saveRunRewards(true); initializeGame(); }}>
                  <Text style={styles.giveUpText}>Jogar novamente</Text>
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
                <Text style={styles.gameOverTitle}>{resultStatus === 'quit' ? '⏸ DESISTÊNCIA' : '💀 DERROTA 💀'}</Text>
                <Text style={styles.gameOverSubtitle}>{resultStatus === 'quit' ? 'Rodada encerrada pelo jogador.' : 'A bolinha foi esmagada!'}</Text>
                
                <ScrollView style={styles.resultScroll} contentContainerStyle={styles.statsContainer}>
                  <Text style={styles.statText}>🏁 Fase alcançada: {Number(phase) || 1}</Text>
                  <Text style={styles.statText}>❌ Resultado: {resultStatus === 'quit' ? 'desistência' : 'derrota'}</Text>
                  <Text style={styles.statText}>🌀 Anéis quebrados: {runRewards.ringsBroken}</Text>
                  <Text style={styles.statText}>✨ Escapes perfeitos: {runRewards.perfectEscapes}</Text>
                  <Text style={styles.statText}>🔥 Maior combo: x{runRewards.bestCombo}</Text>
                  <Text style={styles.statText}>💰 Moedas da rodada: {runRewards.coins}</Text>
                  <Text style={styles.statText}>🏦 Moedas gerais recebidas: +{globalCoinsReward}</Text>
                  <Text style={styles.statText}>💎 Diamantes ganhos: {runRewards.gems * rewardMultiplier}</Text>
                  <Text style={styles.statText}>👤 XP de perfil: +{profileXpReward}</Text>
                  <Text style={styles.statText}>⭐ XP ganho: {runRewards.xp}</Text>
                  <Text style={styles.statText}>🔑 Chaves: {runRewards.keys * rewardMultiplier}</Text>
                  <Text style={styles.statText}>🎁 Baús: {runRewards.chests}</Text>
                  <Text style={styles.statText}>🏆 Conquistas pendentes aparecem na tela de conquistas</Text>
                  <Text style={styles.statText}>📅 Missões diárias/evento recebem progresso ao coletar</Text>
                  <Text style={styles.statText}>🎯 Score: {Math.floor(score)}</Text>
                  {runRewards.bonuses.length > 0 && (
                    <Text style={styles.statText}>✨ Bônus: {runRewards.bonuses.join(', ')}</Text>
                  )}
                  <View style={styles.profileProgress}>
                    <View style={[styles.profileProgressFill, { width: `${nextProfileProgress}%` }]} />
                  </View>
                </ScrollView>

                {resultStatus !== 'quit' && (
                  <TouchableOpacity
                    style={styles.reviveButton}
                    onPress={() => { setShowGameOver(false); setShowAdRevive(true); }}
                  >
                    <LinearGradient colors={['#ff0055', '#cc0000']} style={styles.buttonGradient}>
                      <Text style={styles.buttonText}>📺 REVIVER (AD)</Text>
                    </LinearGradient>
                  </TouchableOpacity>
                )}

                {rewardMultiplier === 1 && (
                  <TouchableOpacity style={styles.actionButton} onPress={() => setShowAdDouble(true)}>
                    <LinearGradient colors={['#ffd700', '#ff8800']} style={styles.buttonGradient}>
                      <Text style={styles.buttonText}>DOBRAR RECOMPENSA — AD</Text>
                    </LinearGradient>
                  </TouchableOpacity>
                )}

                <TouchableOpacity style={styles.giveUpButton} onPress={() => handleCollectAndExit(false)}>
                  <Text style={styles.giveUpText}>Coletar e sair</Text>
                </TouchableOpacity>

                <TouchableOpacity style={styles.giveUpButton} onPress={handleRetry}>
                  <Text style={styles.giveUpText}>Jogar novamente</Text>
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

      <AdModal
        visible={showAdDouble}
        onClose={() => setShowAdDouble(false)}
        onRewardClaimed={handleDoubleRewards}
        rewardType="double"
      />
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  serverFallback: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  serverFallbackText: { color: '#ffffff', fontSize: 16, fontWeight: 'bold' },
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
  pauseMiniButton: {
    width: 42,
    height: 38,
    borderRadius: 10,
    backgroundColor: '#ffffff18',
    borderWidth: 1,
    borderColor: '#ffffff33',
    alignItems: 'center',
    justifyContent: 'center',
  },
  pauseMiniText: { color: '#ffffff', fontSize: 18, fontWeight: 'bold' },
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
  skinTrail: {
    position: 'absolute',
    left: -7,
    top: -7,
    width: BALL_RADIUS * 2 + 14,
    height: BALL_RADIUS * 2 + 14,
    borderRadius: BALL_RADIUS + 7,
    borderWidth: 1,
    opacity: 0.45,
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
  ballShield: {
    borderWidth: 2,
    borderColor: '#00ff88',
  },
  ballGradient: { width: '100%', height: '100%', justifyContent: 'center', alignItems: 'center' },
  skinIconInBall: { fontSize: 12, lineHeight: 14 },
  protectionBadge: {
    position: 'absolute',
    top: 12,
    alignSelf: 'center',
    backgroundColor: '#00ff8833',
    borderWidth: 1,
    borderColor: '#00ff88aa',
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 12,
  },
  protectionText: { color: '#ffffff', fontSize: 12, fontWeight: 'bold' },
  comboBadge: {
    position: 'absolute',
    bottom: 18,
    alignSelf: 'center',
    backgroundColor: '#00f0ff33',
    borderWidth: 1,
    borderColor: '#00f0ffaa',
    paddingVertical: 7,
    paddingHorizontal: 14,
    borderRadius: 12,
  },
  comboBadgeHot: {
    backgroundColor: '#ffd70033',
    borderColor: '#ffd700',
  },
  comboText: { color: '#ffffff', fontSize: 15, fontWeight: 'bold' },
  runUpgradeBar: { flexDirection: 'row', gap: 8, paddingHorizontal: 10, paddingBottom: 12 },
  runUpgradeButton: {
    flex: 1,
    minHeight: 58,
    borderRadius: 10,
    backgroundColor: '#ffffff14',
    borderWidth: 1,
    borderColor: '#00f0ff55',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 6,
  },
  runUpgradeIcon: { fontSize: 18 },
  runUpgradeLabel: { color: '#ffffff', fontSize: 11, fontWeight: 'bold', marginTop: 2 },
  runUpgradeCost: { color: '#ffd700', fontSize: 11, fontWeight: 'bold', marginTop: 2 },
  pauseModal: { width: '86%', maxWidth: 380, borderRadius: 16, overflow: 'hidden' },
  pauseHint: { color: '#ffffff88', fontSize: 12, textAlign: 'center', marginTop: 10 },
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
  levelUpModal: { width: '94%', maxWidth: 720, maxHeight: '86%', borderRadius: 20, overflow: 'hidden' },
  modalContent: { padding: 20 },
  modalTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#00f0ff',
    textAlign: 'center',
    marginBottom: 4,
  },
  modalSubtitle: { fontSize: 14, color: '#ffffff', textAlign: 'center', marginBottom: 14 },
  levelUpContent: { gap: 10, paddingBottom: 4 },
  upgradeGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10, justifyContent: 'center' },
  upgradeCard: { flexBasis: 190, flexGrow: 1, minWidth: 170, maxWidth: 220, borderRadius: 12, overflow: 'hidden' },
  upgradeCardContent: {
    minHeight: 178,
    padding: 12,
    borderWidth: 2,
    justifyContent: 'space-between',
  },
  upgradeTopLine: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  upgradeIcon: { fontSize: 32 },
  upgradeRarityBadge: { color: '#001018', fontSize: 10, fontWeight: 'bold', paddingVertical: 4, paddingHorizontal: 7, borderRadius: 8, overflow: 'hidden' },
  upgradeName: { fontSize: 17, fontWeight: 'bold', color: '#ffffff', marginBottom: 2 },
  upgradeDescription: { fontSize: 13, color: '#ffffffaa', marginBottom: 4 },
  upgradeEffect: { color: '#ffd700', fontSize: 12, fontWeight: 'bold' },
  chooseText: { color: '#00f0ff', fontSize: 12, fontWeight: 'bold', marginTop: 8 },
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
  resultScroll: { maxHeight: 330, marginBottom: 10 },
  profileProgress: { height: 12, backgroundColor: '#00000055', borderRadius: 8, overflow: 'hidden', marginTop: 8 },
  profileProgressFill: { height: '100%', backgroundColor: '#00f0ff' },
  actionButton: { height: 50, borderRadius: 12, overflow: 'hidden' },
  reviveButton: { height: 50, borderRadius: 12, overflow: 'hidden', marginBottom: 10 },
  giveUpButton: { padding: 10, alignItems: 'center' },
  giveUpText: { color: '#ffffff88', fontSize: 14 },
  buttonGradient: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  buttonText: { fontSize: 16, fontWeight: 'bold', color: '#ffffff' },
});

import { Ring, RingConfig, clampBallSpeed, clampRingSpacing, createRings, findClosestCollidingRing, findPerfectEscapeRing, isBallCrushedByRing, reflectBallOffRing, updateRings, withRingEffect } from './rings';
import { GAMEPLAY_TUNING } from './balance';
import { SkinDefinition } from './skins';
import { UPGRADES } from './upgrades';

export interface DualArenaState {
  id: string;
  name: string;
  skinIcon: string;
  skinImageAsset?: SkinDefinition['imageAsset'];
  skinColor: string;
  center: number;
  size: number;
  ballRadius: number;
  ball: { x: number; y: number };
  velocity: { x: number; y: number };
  rings: Ring[];
  coins: number;
  xp: number;
  level: number;
  combo: number;
  atk: number;
  gold: number;
  aiQuality: number;
  aiTimer: number;
  crushed: boolean;
  finished: boolean;
  lastSolidBreak: number;
  lastCollisionAt: number;
  lastRepulseAt: number;
  lastCollisionRingId?: string;
  lastAiChoice?: string;
  runUpgrades: Record<string, number>;
  ringConfig: RingConfig;
  phase: number;
  spawnedBatches: number;
  maxSpawnBatches: number;
}

export interface ArenaTickResult {
  state: DualArenaState;
  brokeRing: boolean;
  brokeSolid: boolean;
  skinEffectLabel?: string;
}

export interface AiArenaUpgradeContext {
  opponentProgress: number;
  bossPhase?: number;
}

export const createArenaState = (params: {
  id: string;
  name: string;
  skinIcon: string;
  skinImageAsset?: SkinDefinition['imageAsset'];
  skinColor: string;
  size: number;
  phase: number;
  ringConfig: RingConfig;
  aiQuality?: number;
  speedMultiplier?: number;
  damageMultiplier?: number;
  maxSpawnBatches?: number;
}) => {
  const center = params.size / 2;
  const speed = (params.ringConfig.count > 14 ? GAMEPLAY_TUNING.league.arenaBallSpeed : GAMEPLAY_TUNING.boss.arenaBallSpeed) * (params.speedMultiplier ?? 1);
  const ball = { x: center + 10, y: center - 16 };
  const desiredSafeRadius = Math.max(params.ringConfig.safeStartRadius ?? 0, Math.hypot(ball.x - center, ball.y - center) + 28);
  const safeRadius = Math.max(24, Math.min(desiredSafeRadius, params.ringConfig.outerRadius - 18));
  return {
    id: params.id,
    name: params.name,
    skinIcon: params.skinIcon,
    skinImageAsset: params.skinImageAsset,
    skinColor: params.skinColor,
    center,
    size: params.size,
    ballRadius: 8,
    ball,
    velocity: { x: speed, y: -speed * 0.72 },
    rings: clampRingSpacing(createRings({ ...params.ringConfig, safeStartRadius: safeRadius }, params.phase), params.ringConfig.minSpacing ?? 8),
    coins: 0,
    xp: 0,
    level: 1,
    combo: 0,
    atk: Math.max(0, Math.floor(((params.damageMultiplier ?? 1) - 1) * 4)),
    gold: 0,
    aiQuality: params.aiQuality ?? 0,
    aiTimer: 0,
    crushed: false,
    finished: false,
    lastSolidBreak: 0,
    lastCollisionAt: 0,
    lastRepulseAt: 0,
    runUpgrades: {},
    ringConfig: params.ringConfig,
    phase: params.phase,
    spawnedBatches: 0,
    maxSpawnBatches: params.maxSpawnBatches ?? (params.id === 'infinite' ? 0 : 3),
  } satisfies DualArenaState;
};

const xpNeeded = (level: number) => Math.floor(28 * Math.pow(level, 1.35));

export const buyArenaUpgrade = (state: DualArenaState, type: 'atk' | 'gold') => {
  const cost = getArenaUpgradeCost(state, type);
  if (state.coins < cost) return state;
  return {
    ...state,
    coins: state.coins - cost,
    [type]: state[type] + 1,
  };
};

export const getArenaUpgradeCost = (state: DualArenaState, type: 'atk' | 'gold') => {
  const base = type === 'atk' ? 16 : 14;
  return Math.floor(base * Math.pow(1.34, state[type]));
};

export const chooseAiArenaUpgrade = (state: DualArenaState, opponentProgress: number) => {
  const solidRemaining = state.rings.filter(ring => ring.status === 'active' && ring.type === 'solid').length;
  const ownProgress = getArenaProgress(state);
  if (solidRemaining >= 2 || ownProgress + 0.08 < opponentProgress) return 'atk';
  if (ownProgress < 0.45 && state.gold < 4 && Math.random() < 0.45 + state.aiQuality * 0.25) return 'gold';
  return Math.random() < 0.72 ? 'atk' : 'gold';
};

const AI_RUN_UPGRADE_IDS = [
  'damage',
  'speed',
  'coinBoost',
  'critical',
  'burn',
  'frost',
  'shockwave',
  'chainLightning',
  'laserCut',
  'shieldPulse',
  'chainBreak',
  'criticalOverload',
  'bossHunter',
  'rivalCrusher',
];

export const chooseAiArenaRunUpgrade = (state: DualArenaState, context: AiArenaUpgradeContext) => {
  const ownProgress = getArenaProgress(state);
  const activeRings = state.rings.filter(ring => ring.status === 'active' && ring.hp > 0);
  const solidRemaining = activeRings.filter(ring => ring.type === 'solid').length;
  const behind = ownProgress + 0.08 < context.opponentProgress;
  const danger = activeRings.some(ring => ring.radius <= state.ballRadius + 26);
  const choices = AI_RUN_UPGRADE_IDS
    .map(id => UPGRADES.find(upgrade => upgrade.id === id))
    .filter((upgrade): upgrade is NonNullable<typeof upgrade> => Boolean(upgrade))
    .filter(upgrade => (state.runUpgrades[upgrade.id] || 0) < upgrade.maxLevel);

  const score = (upgradeId: string) => {
    let value = Math.random() * 0.25;
    if (['damage', 'critical', 'criticalOverload', 'laserCut'].includes(upgradeId)) value += solidRemaining >= 2 ? 5 : 2.2;
    if (['speed', 'coinBoost'].includes(upgradeId)) value += behind ? 4 : 1.2;
    if (['shieldPulse', 'frost'].includes(upgradeId)) value += danger ? 4.5 : 0.8;
    if (['shockwave', 'chainLightning', 'chainBreak', 'burn'].includes(upgradeId)) value += activeRings.length >= 6 ? 3.5 : 1.4;
    if (['bossHunter', 'rivalCrusher'].includes(upgradeId)) value += context.bossPhase ? 3 + context.bossPhase * 0.08 : 1.6;
    value -= (state.runUpgrades[upgradeId] || 0) * 0.18;
    return value;
  };

  return choices.sort((a, b) => score(b.id) - score(a.id))[0];
};

export const getArenaProgress = (state: DualArenaState) => {
  const total = Math.max(1, state.rings.length);
  const remaining = state.rings.filter(ring => ring.status === 'active' && ring.hp > 0).length;
  return Math.max(0, Math.min(1, (total - remaining) / total));
};

const separateBallFromRing = (state: DualArenaState, ring: Ring, previousDistFromCenter: number) => {
  const dx = state.ball.x - state.center;
  const dy = state.ball.y - state.center;
  const dist = Math.sqrt(dx * dx + dy * dy) || 1;
  const nx = dx / dist;
  const ny = dy / dist;
  const halfThickness = ring.thickness / 2;
  const safeOffset = 2.2;
  const outsideTarget = ring.radius + halfThickness + state.ballRadius + safeOffset;
  const insideTarget = Math.max(0, ring.radius - halfThickness - state.ballRadius - safeOffset);
  const startedOutside = Number.isFinite(previousDistFromCenter) ? previousDistFromCenter > ring.radius : dist > ring.radius;
  const targetDist = startedOutside ? outsideTarget : insideTarget;
  const maxDist = state.size / 2 - state.ballRadius - 4;
  const clampedTargetDist = Math.max(0, Math.min(maxDist, targetDist));

  return {
    x: state.center + nx * clampedTargetDist,
    y: state.center + ny * clampedTargetDist,
  };
};

const reflectAndSeparateBall = (state: DualArenaState, ring: Ring, previousDistFromCenter: number) => {
  const ball = separateBallFromRing(state, ring, previousDistFromCenter);
  const dx = ball.x - state.center;
  const dy = ball.y - state.center;
  const dist = Math.sqrt(dx * dx + dy * dy) || 1;
  const side = Number.isFinite(previousDistFromCenter) && previousDistFromCenter < ring.radius ? -1 : 1;
  const nx = (dx / dist) * side;
  const ny = (dy / dist) * side;
  const dot = state.velocity.x * nx + state.velocity.y * ny;
  const reflected = dot < 0
    ? {
        x: state.velocity.x - 2 * dot * nx,
        y: state.velocity.y - 2 * dot * ny,
      }
    : state.velocity;

  return {
    ball,
    velocity: clampBallSpeed({ x: reflected.x * 1.04, y: reflected.y * 1.04 }, 2.15, 5.1),
  };
};

const createArenaRespawnBatch = (state: DualArenaState) => {
  const batchSize = state.ringConfig.spawnBatchSize ?? 4;
  const nextPhase = state.phase + state.spawnedBatches + 1;
  const desiredSafeRadius = Math.max(state.ringConfig.safeStartRadius ?? 0, Math.hypot(state.ball.x - state.center, state.ball.y - state.center) + 30);
  const safeStartRadius = Math.max(24, Math.min(desiredSafeRadius, state.ringConfig.outerRadius - 18));
  return createRings({
    ...state.ringConfig,
    count: Math.max(batchSize, Math.min(state.ringConfig.maxCount ?? state.ringConfig.count + 6, state.ringConfig.count + state.spawnedBatches + 2)),
    minCount: batchSize,
    safeStartRadius,
  }, nextPhase)
    .slice(-batchSize)
    .map((ring, index) => ({
      ...ring,
      id: `${state.id}_spawn_${state.spawnedBatches}_${index}_${Date.now()}`,
    }));
};

export const tickArenaPhysics = (
  state: DualArenaState,
  options: {
    isAi?: boolean;
    opponentProgress?: number;
    shrinkMultiplier?: number;
    damageMultiplier?: number;
    coinMultiplier?: number;
    xpMultiplier?: number;
    speedMultiplier?: number;
    ringMinGap?: number;
    skinPassive?: SkinDefinition['passive'];
    skinLevel?: number;
    onLevelUp?: boolean;
  } = {}
): ArenaTickResult => {
  if (state.finished || state.crushed) return { state, brokeRing: false, brokeSolid: false };
  const now = Date.now();
  const shrink = options.shrinkMultiplier ?? 1;
  const previousDist = Math.hypot(state.ball.x - state.center, state.ball.y - state.center);
  let next: DualArenaState = {
    ...state,
    ball: { x: state.ball.x + state.velocity.x * (options.speedMultiplier ?? 1), y: state.ball.y + state.velocity.y * (options.speedMultiplier ?? 1) },
    velocity: clampBallSpeed({ ...state.velocity }, 2.05 * (options.speedMultiplier ?? 1), 5.2),
    rings: updateRings(state.rings, shrink, now, options.ringMinGap ?? 7),
    aiTimer: state.aiTimer + 1,
    lastSolidBreak: Math.max(0, state.lastSolidBreak - 1),
  };

  const dx = next.ball.x - next.center;
  const dy = next.ball.y - next.center;
  const dist = Math.sqrt(dx * dx + dy * dy) || 1;
  const maxDist = next.size / 2 - next.ballRadius - 4;
  if (dist > maxDist) {
    const nx = dx / dist;
    const ny = dy / dist;
    next.ball = { x: next.center + nx * maxDist, y: next.center + ny * maxDist };
    const reflected = reflectBallOffRing(next.ball.x, next.ball.y, next.velocity.x, next.velocity.y, next.center, next.center, 0.15);
    next.velocity = { x: reflected.newVelX, y: reflected.newVelY };
  }

  let brokeRing = false;
  let brokeSolid = false;
  let skinEffectLabel: string | undefined;
  const nextDist = Math.hypot(next.ball.x - next.center, next.ball.y - next.center);
  const perfectEscape = findPerfectEscapeRing(
    previousDist,
    nextDist,
    next.ball.x,
    next.ball.y,
    next.ballRadius,
    next.rings,
    next.center,
    next.center
  );

  if (perfectEscape.ring && perfectEscape.index >= 0) {
    next.rings[perfectEscape.index] = { ...perfectEscape.ring, status: 'cleared', hp: 0 };
    next.coins += Math.max(2, Math.floor(5 * (1 + next.gold * 0.18) * (options.coinMultiplier ?? 1)));
    next.xp += Math.floor(12 * (options.xpMultiplier ?? 1));
    next.combo += 1;
    brokeRing = true;
  }

  const collision = findClosestCollidingRing(next.ball.x, next.ball.y, next.ballRadius, next.rings, next.center, next.center);
  if (collision.ring && collision.index >= 0 && collision.isInSolidPart) {
    const canDamage = collision.ring.id !== next.lastCollisionRingId || now - next.lastCollisionAt > 90;
    const passive = options.skinPassive;
    const passiveChance = Math.min(0.42, (passive?.chance ?? 0) + Math.max(0, (options.skinLevel ?? 1) - 1) * 0.015);
    const passiveTriggered = Boolean(passive && passiveChance > 0 && Math.random() < passiveChance);
    const critTriggered = passiveTriggered && Boolean(passive?.type && ['crit_chance', 'mega_crit', 'cosmic_critical'].includes(passive.type));
    const damage = (3.8 + next.atk * 1.45) * (options.damageMultiplier ?? 1) * (critTriggered ? Math.max(1.6, passive?.value || 2) : 1);
    const ring = collision.ring;
    const hp = canDamage ? Math.max(0, ring.hp - damage) : ring.hp;
    brokeRing = hp <= 0;
    brokeSolid = brokeRing && ring.type === 'solid';
    const xpGain = Math.floor((brokeRing ? (ring.type === 'solid' ? 18 : 9) : 1) * (options.xpMultiplier ?? 1));
    const coinGain = Math.floor((brokeRing ? (ring.type === 'solid' ? 8 : 4) : 1) * (options.coinMultiplier ?? 1));
    next.rings[collision.index] = { ...ring, hp, status: hp <= 0 ? 'broken' : 'active' };
    const targetWindow = next.rings
      .map((target, index) => ({ target, index, distance: Math.abs(target.radius - ring.radius) }))
      .filter(item => item.index !== collision.index && item.target.status === 'active' && item.target.hp > 0)
      .sort((a, b) => a.distance - b.distance)
      .slice(0, 3);
    if (canDamage && passiveTriggered && passive) {
      if (passive.type === 'burn') {
        next.rings[collision.index] = withRingEffect({ ...next.rings[collision.index], burnUntil: now + (passive.durationMs ?? 2400), burnDps: passive.value }, 'burning', passive.durationMs ?? 2400, now);
        skinEffectLabel = 'Queimadura da skin';
      } else if (passive.type === 'freeze_ring' || passive.type === 'slow_ring') {
        const duration = passive.durationMs ?? (passive.type === 'freeze_ring' ? 2400 : 2000);
        next.rings[collision.index] = withRingEffect({ ...next.rings[collision.index], slowUntil: now + duration }, passive.type === 'freeze_ring' ? 'frozen' : 'slowed', duration, now);
        skinEffectLabel = passive.type === 'freeze_ring' ? 'Congelamento da skin' : 'Lentidão da skin';
      } else if (passive.type === 'repel_ring') {
        if (now - next.lastRepulseAt > 1500) {
          const force = Math.min(14, Math.max(4, passive.value * 0.45));
          const radius = Math.min(next.size / 2 - 10, ring.initialRadius + 12, ring.radius + force);
          next.rings[collision.index] = withRingEffect({ ...next.rings[collision.index], radius }, 'repulsed', 700, now);
          next.lastRepulseAt = now;
          skinEffectLabel = 'Repulsão da skin';
        }
      } else if (passive.type === 'area_damage' || passive.type === 'cosmic_critical' || passive.type === 'league_king_wave') {
        targetWindow.forEach(({ target, index }) => {
          const areaDamage = damage * Math.min(0.85, passive.value || 0.35);
          const nextHp = Math.max(0, target.hp - areaDamage);
          next.rings[index] = withRingEffect({ ...target, hp: nextHp, status: nextHp <= 0 ? 'broken' : 'active' }, passive.type === 'cosmic_critical' ? 'gravity' : 'exploded', 800, now);
        });
        skinEffectLabel = passive.type === 'league_king_wave' ? 'Onda real da skin' : 'Explosão da skin';
      } else if (passive.type === 'chain_damage') {
        targetWindow.slice(0, 2).forEach(({ target, index }) => {
          const chainDamage = damage * Math.min(0.75, passive.value || 0.35);
          const nextHp = Math.max(0, target.hp - chainDamage);
          next.rings[index] = withRingEffect({ ...target, hp: nextHp, status: nextHp <= 0 ? 'broken' : 'active' }, 'shocked', 720, now);
        });
        skinEffectLabel = 'Corrente da skin';
      } else if (passive.type === 'phase_solid') {
        next.rings[collision.index] = withRingEffect({ ...next.rings[collision.index], status: 'cleared', hp: 0 }, 'pierced', 620, now);
        skinEffectLabel = 'Fase da skin';
      } else if (passive.type === 'coin_on_hit') {
        next.coins += Math.max(1, Math.floor(passive.value));
        skinEffectLabel = 'Moedas da skin';
      } else if (passive.type === 'slime_bounce' || passive.type === 'speed') {
        next.velocity = clampBallSpeed({ x: next.velocity.x * 1.06, y: next.velocity.y * 1.06 }, 2.1, 5.4);
        skinEffectLabel = 'Impulso da skin';
      } else if (critTriggered) {
        next.rings[collision.index] = withRingEffect(next.rings[collision.index], 'critical', 520, now);
        skinEffectLabel = 'Crítico da skin';
      }
    }
    if (canDamage) {
      const frostLevel = next.runUpgrades.frost || next.runUpgrades.slowField || 0;
      if (frostLevel && Math.random() < Math.min(0.34, 0.14 + frostLevel * 0.035)) {
        const duration = 1700 + frostLevel * 260;
        next.rings[collision.index] = withRingEffect({ ...next.rings[collision.index], slowUntil: now + duration }, 'frozen', duration, now);
        skinEffectLabel = skinEffectLabel || 'Congelamento';
      }

      const burnLevel = next.runUpgrades.burn || 0;
      if (burnLevel && Math.random() < Math.min(0.28, 0.1 + burnLevel * 0.03)) {
        const duration = 2100 + burnLevel * 220;
        next.rings[collision.index] = withRingEffect({ ...next.rings[collision.index], burnUntil: now + duration, burnDps: 4 + burnLevel * 2 }, 'burning', duration, now);
        skinEffectLabel = skinEffectLabel || 'Queimadura';
      }

      const poisonLevel = next.runUpgrades.penetration || 0;
      if (poisonLevel && Math.random() < Math.min(0.26, 0.08 + poisonLevel * 0.035)) {
        const duration = 2300 + poisonLevel * 260;
        next.rings[collision.index] = withRingEffect({ ...next.rings[collision.index], burnUntil: now + duration, burnDps: 3 + poisonLevel * 1.8 }, 'poisoned', duration, now);
        skinEffectLabel = skinEffectLabel || 'Veneno';
      }

      const repulseLevel = next.runUpgrades.ringRepulse || 0;
      if (repulseLevel && now - next.lastRepulseAt > 1650 && Math.random() < Math.min(0.18, 0.045 + repulseLevel * 0.018)) {
        const radius = Math.min(next.size / 2 - 10, ring.initialRadius + 10, ring.radius + 5 + repulseLevel * 2);
        next.rings[collision.index] = withRingEffect({ ...next.rings[collision.index], radius }, 'repulsed', 700, now);
        next.lastRepulseAt = now;
        skinEffectLabel = skinEffectLabel || 'Repulsão';
      }

      const shockLevel = next.runUpgrades.chainLightning || next.runUpgrades.shockwave || 0;
      if (shockLevel && Math.random() < Math.min(0.28, 0.08 + shockLevel * 0.035)) {
        targetWindow.slice(0, next.runUpgrades.chainLightning ? 2 : 3).forEach(({ target, index }) => {
          const shockDamage = damage * Math.min(0.45, 0.16 + shockLevel * 0.035);
          const nextHp = Math.max(0, target.hp - shockDamage);
          next.rings[index] = withRingEffect({ ...target, hp: nextHp, status: nextHp <= 0 ? 'broken' : 'active' }, next.runUpgrades.chainLightning ? 'shocked' : 'exploded', 720, now);
        });
        skinEffectLabel = skinEffectLabel || (next.runUpgrades.chainLightning ? 'Corrente' : 'Explosão');
      }
    }
    if (canDamage) {
      next.coins += Math.max(1, Math.floor(coinGain * (1 + next.gold * 0.18)));
      next.xp += xpGain;
      next.combo = brokeRing ? next.combo + 1 : next.combo;
      next.lastSolidBreak = brokeSolid ? 24 : next.lastSolidBreak;
      next.lastCollisionAt = now;
      next.lastCollisionRingId = ring.id;
    }
    if (canDamage && next.xp >= xpNeeded(next.level)) {
      next.xp -= xpNeeded(next.level);
      next.level += 1;
    }
    const bounced = reflectAndSeparateBall(next, ring, previousDist);
    next.ball = bounced.ball;
    next.velocity = bounced.velocity;
  }

  next.rings = clampRingSpacing(next.rings, options.ringMinGap ?? 7);

  const activeRings = next.rings.filter(ring => ring.status === 'active' && ring.hp > 0);
  const respawnThreshold = next.ringConfig.respawnThreshold ?? 3;
  if (
    !next.crushed &&
    next.maxSpawnBatches > 0 &&
    next.spawnedBatches < next.maxSpawnBatches &&
    activeRings.length <= respawnThreshold
  ) {
    next = {
      ...next,
      rings: clampRingSpacing([
        ...activeRings,
        ...createArenaRespawnBatch(next),
      ], options.ringMinGap ?? 7),
      spawnedBatches: next.spawnedBatches + 1,
    };
  }
  const currentActiveRings = next.rings.filter(ring => ring.status === 'active' && ring.hp > 0);
  next.finished = currentActiveRings.length === 0;
  next.crushed = currentActiveRings.some(ring =>
    ring.radius <= next.ballRadius + 3 ||
    isBallCrushedByRing(next.ball.x, next.ball.y, next.ballRadius, ring, next.center, next.center)
  );

  if (options.isAi && next.aiTimer >= Math.max(12, Math.floor(36 - next.aiQuality * 18))) {
    const choice = chooseAiArenaUpgrade(next, options.opponentProgress ?? 0);
    const upgraded = buyArenaUpgrade(next, choice);
    next = { ...upgraded, aiTimer: 0, lastAiChoice: choice === 'atk' ? 'ATK' : 'Gold' };
  }

  return { state: next, brokeRing, brokeSolid, skinEffectLabel };
};

export const applyArenaRunUpgrade = (state: DualArenaState, upgradeId: string): DualArenaState => {
  const runUpgrades = { ...state.runUpgrades, [upgradeId]: (state.runUpgrades[upgradeId] || 0) + 1 };
  const velocity = upgradeId === 'speed' || upgradeId === 'ricochet'
    ? clampBallSpeed({ x: state.velocity.x * 1.08, y: state.velocity.y * 1.08 }, 2.1, 5.4)
    : state.velocity;

  return {
    ...state,
    velocity,
    runUpgrades,
  };
};

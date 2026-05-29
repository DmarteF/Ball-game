import { Ring, RingConfig, clampBallSpeed, createRings, findClosestCollidingRing, findPerfectEscapeRing, reflectBallOffRing, updateRing } from './rings';

export interface DualArenaState {
  id: string;
  name: string;
  skinIcon: string;
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
  lastAiChoice?: 'ATK' | 'Gold';
}

export interface ArenaTickResult {
  state: DualArenaState;
  brokeRing: boolean;
  brokeSolid: boolean;
}

export const createArenaState = (params: {
  id: string;
  name: string;
  skinIcon: string;
  skinColor: string;
  size: number;
  phase: number;
  ringConfig: RingConfig;
  aiQuality?: number;
  speedMultiplier?: number;
  damageMultiplier?: number;
}) => {
  const center = params.size / 2;
  const speed = 2.25 * (params.speedMultiplier ?? 1);
  return {
    id: params.id,
    name: params.name,
    skinIcon: params.skinIcon,
    skinColor: params.skinColor,
    center,
    size: params.size,
    ballRadius: 8,
    ball: { x: center + 10, y: center - 16 },
    velocity: { x: speed, y: -speed * 0.72 },
    rings: createRings(params.ringConfig, params.phase),
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

export const tickArenaPhysics = (
  state: DualArenaState,
  options: { isAi?: boolean; opponentProgress?: number; shrinkMultiplier?: number; damageMultiplier?: number } = {}
): ArenaTickResult => {
  if (state.finished || state.crushed) return { state, brokeRing: false, brokeSolid: false };
  const now = Date.now();
  const shrink = options.shrinkMultiplier ?? 1;
  const previousDist = Math.hypot(state.ball.x - state.center, state.ball.y - state.center);
  let next: DualArenaState = {
    ...state,
    ball: { x: state.ball.x + state.velocity.x, y: state.ball.y + state.velocity.y },
    velocity: { ...state.velocity },
    rings: state.rings.map(ring => updateRing(ring, shrink, now)),
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
    next.coins += Math.max(2, Math.floor(5 * (1 + next.gold * 0.18)));
    next.xp += 12;
    next.combo += 1;
    brokeRing = true;
  }

  const collision = findClosestCollidingRing(next.ball.x, next.ball.y, next.ballRadius, next.rings, next.center, next.center);
  if (collision.ring && collision.index >= 0 && collision.isInSolidPart) {
    const canDamage = now - next.lastCollisionAt > 70;
    const damage = (3.8 + next.atk * 1.45) * (options.damageMultiplier ?? 1);
    const ring = collision.ring;
    const hp = canDamage ? Math.max(0, ring.hp - damage) : ring.hp;
    brokeRing = hp <= 0;
    brokeSolid = brokeRing && ring.type === 'solid';
    const xpGain = brokeRing ? (ring.type === 'solid' ? 18 : 9) : 1;
    const coinGain = brokeRing ? (ring.type === 'solid' ? 8 : 4) : 1;
    next.rings[collision.index] = { ...ring, hp, status: hp <= 0 ? 'broken' : 'active' };
    if (canDamage) {
      next.coins += Math.max(1, Math.floor(coinGain * (1 + next.gold * 0.18)));
      next.xp += xpGain;
      next.combo = brokeRing ? next.combo + 1 : next.combo;
      next.lastSolidBreak = brokeSolid ? 24 : next.lastSolidBreak;
      next.lastCollisionAt = now;
    }
    if (canDamage && next.xp >= xpNeeded(next.level)) {
      next.xp -= xpNeeded(next.level);
      next.level += 1;
      next.atk += Math.random() < 0.65 ? 1 : 0;
      next.gold += Math.random() < 0.35 ? 1 : 0;
    }
    next.ball = separateBallFromRing(next, ring, previousDist);
    const reflected = reflectBallOffRing(next.ball.x, next.ball.y, next.velocity.x, next.velocity.y, next.center, next.center, 0.18);
    next.velocity = clampBallSpeed({ x: reflected.newVelX * 1.035, y: reflected.newVelY * 1.035 }, 1.9, 4.8);
  }

  const activeRings = next.rings.filter(ring => ring.status === 'active' && ring.hp > 0);
  next.finished = activeRings.length === 0;
  next.crushed = activeRings.some(ring => ring.radius <= next.ballRadius + 3 && ring.status === 'active');

  if (options.isAi && next.aiTimer >= Math.max(12, Math.floor(36 - next.aiQuality * 18))) {
    const choice = chooseAiArenaUpgrade(next, options.opponentProgress ?? 0);
    const upgraded = buyArenaUpgrade(next, choice);
    next = { ...upgraded, aiTimer: 0, lastAiChoice: choice === 'atk' ? 'ATK' : 'Gold' };
  }

  return { state: next, brokeRing, brokeSolid };
};

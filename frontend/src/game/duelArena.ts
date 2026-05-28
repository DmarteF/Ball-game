import {
  Ring,
  checkRingCollision,
  createRings,
  findClosestCollidingRing,
  findPerfectEscapeRing,
  reflectBallOffRing,
  updateRing,
} from './rings';

export interface DuelArenaState {
  id: string;
  rings: Ring[];
  ball: { x: number; y: number; vx: number; vy: number };
  coins: number;
  xp: number;
  level: number;
  atkLevel: number;
  goldLevel: number;
  combo: number;
  broken: number;
  cleared: number;
  lost: boolean;
  finished: boolean;
  lastHitAt: number;
  solidBreaks: number;
}

export interface DuelArenaEvents {
  hit?: boolean;
  critical?: boolean;
  break?: boolean;
  solidBreak?: boolean;
  perfect?: boolean;
  levelUp?: boolean;
  lost?: boolean;
  finished?: boolean;
}

const TWO_PI = Math.PI * 2;

export const createDuelArena = (options: {
  id: string;
  phase: number;
  size: number;
  ringCount: number;
  baseHp: number;
  closingSpeed: number;
  rotationSpeed: number;
  solidCount: number;
  solidHpMultiplier?: number;
  color: string;
  speed?: number;
}): DuelArenaState => {
  const center = options.size / 2;
  const angle = Math.random() * TWO_PI;
  const speed = options.speed || 2.9;
  return {
    id: options.id,
    rings: createRings({
      count: options.ringCount,
      innerRadius: 18,
      outerRadius: options.size / 2 - 16,
      baseRotationSpeed: options.rotationSpeed,
      baseHp: options.baseHp,
      baseGapSize: Math.PI / 3.1,
      baseThickness: 4,
      closingSpeed: options.closingSpeed,
      solidCount: options.solidCount,
      solidHpMultiplier: options.solidHpMultiplier,
      colors: [options.color, '#ffffff', '#ffd700', '#ff4fd8'],
    }, options.phase),
    ball: { x: center, y: center, vx: Math.cos(angle) * speed, vy: Math.sin(angle) * speed },
    coins: 0,
    xp: 0,
    level: 1,
    atkLevel: 0,
    goldLevel: 0,
    combo: 0,
    broken: 0,
    cleared: 0,
    lost: false,
    finished: false,
    lastHitAt: 0,
    solidBreaks: 0,
  };
};

export const getDuelUpgradeCost = (type: 'atk' | 'gold', level: number) =>
  Math.floor((type === 'atk' ? 20 : 18) * Math.pow(1.35, level));

export const buyDuelUpgrade = (state: DuelArenaState, type: 'atk' | 'gold') => {
  const level = type === 'atk' ? state.atkLevel : state.goldLevel;
  const cost = getDuelUpgradeCost(type, level);
  if (state.coins < cost) return { state, ok: false };
  return {
    ok: true,
    state: {
      ...state,
      coins: state.coins - cost,
      atkLevel: type === 'atk' ? state.atkLevel + 1 : state.atkLevel,
      goldLevel: type === 'gold' ? state.goldLevel + 1 : state.goldLevel,
    },
  };
};

export const updateDuelArena = (
  state: DuelArenaState,
  options: { size: number; ballRadius: number; baseDamage: number; auto?: boolean; aiQuality?: number; deltaTime?: number }
): { state: DuelArenaState; events: DuelArenaEvents } => {
  if (state.finished || state.lost) return { state, events: {} };

  const center = options.size / 2;
  const now = Date.now();
  const deltaTime = options.deltaTime || 1;
  let next: DuelArenaState = { ...state, rings: state.rings.map(ring => updateRing(ring, deltaTime, now)), ball: { ...state.ball } };
  const events: DuelArenaEvents = {};

  if (options.auto && next.coins >= 18) {
    const solids = next.rings.filter(ring => ring.status === 'active' && ring.type === 'solid').length;
    const type: 'atk' | 'gold' = solids > 0 || next.rings.filter(ring => ring.status === 'active').length < next.rings.length * 0.55 || Math.random() < (options.aiQuality || 0.5) ? 'atk' : 'gold';
    next = buyDuelUpgrade(next, type).state;
  }

  const prevDist = Math.hypot(next.ball.x - center, next.ball.y - center);
  next.ball.x += next.ball.vx * deltaTime;
  next.ball.y += next.ball.vy * deltaTime;

  const dist = Math.hypot(next.ball.x - center, next.ball.y - center);
  const maxDistance = center - options.ballRadius - 8;
  if (dist > maxDistance && dist > 0) {
    const nx = (next.ball.x - center) / dist;
    const ny = (next.ball.y - center) / dist;
    next.ball.x = center + nx * maxDistance;
    next.ball.y = center + ny * maxDistance;
    const outward = next.ball.vx * nx + next.ball.vy * ny;
    if (outward > 0) {
      next.ball.vx -= 2 * outward * nx;
      next.ball.vy -= 2 * outward * ny;
    }
  }

  const nextDist = Math.hypot(next.ball.x - center, next.ball.y - center);
  const perfect = findPerfectEscapeRing(prevDist, nextDist, next.ball.x, next.ball.y, options.ballRadius, next.rings, center, center);
  if (perfect.ring && perfect.index >= 0) {
    next.rings[perfect.index] = { ...perfect.ring, status: 'cleared', hp: 0 };
    next.coins += 8 + next.goldLevel * 2;
    next.xp += 12;
    next.cleared += 1;
    next.combo += 1;
    events.perfect = true;
  }

  const collision = findClosestCollidingRing(next.ball.x, next.ball.y, options.ballRadius, next.rings, center, center);
  if (collision.ring && collision.index >= 0 && collision.isInSolidPart && now - next.lastHitAt > 80) {
    const isCrit = Math.random() < 0.1 + Math.min(0.12, next.atkLevel * 0.01);
    const damage = options.baseDamage * (1 + next.atkLevel * 0.16) * (isCrit ? 2 : 1);
    const wasSolid = collision.ring.type === 'solid';
    const hp = Math.max(0, collision.ring.hp - damage);
    next.rings[collision.index] = { ...collision.ring, hp, status: hp <= 0 ? 'broken' : 'active' };
    const reflected = reflectBallOffRing(next.ball.x, next.ball.y, next.ball.vx, next.ball.vy, center, center);
    next.ball.vx = reflected.newVelX;
    next.ball.vy = reflected.newVelY;
    next.lastHitAt = now;
    next.coins += Math.max(1, Math.floor(damage * 0.4 * (1 + next.goldLevel * 0.12)));
    next.xp += isCrit ? 2 : 1;
    events.hit = true;
    events.critical = isCrit;
    if (hp <= 0) {
      next.broken += 1;
      next.combo += 1;
      next.coins += wasSolid ? 20 : 12;
      next.xp += wasSolid ? 20 : 10;
      next.solidBreaks += wasSolid ? 1 : 0;
      events.break = true;
      events.solidBreak = wasSolid;
    }
  }

  const xpNeed = 38 + next.level * 18;
  if (next.xp >= xpNeed) {
    next.xp -= xpNeed;
    next.level += 1;
    next.atkLevel += options.auto ? 1 : 0;
    events.levelUp = true;
  }

  const active = next.rings.filter(ring => ring.status === 'active' && ring.hp > 0);
  if (active.length === 0) {
    next.finished = true;
    events.finished = true;
  } else if (active.some(ring => {
    const result = checkRingCollision(next.ball.x, next.ball.y, options.ballRadius, ring, center, center);
    return !result.isInGap && ring.radius <= Math.max(5, options.ballRadius * 0.45);
  })) {
    next.lost = true;
    events.lost = true;
  }

  return { state: next, events };
};

export const getDuelProgress = (state: DuelArenaState) => {
  const total = Math.max(1, state.rings.length);
  const active = state.rings.filter(ring => ring.status === 'active' && ring.hp > 0).length;
  return { total, active, percent: Math.min(100, Math.round(((total - active) / total) * 100)) };
};

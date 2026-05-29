export type RingStatus = 'active' | 'broken' | 'cleared';

export interface Ring {
  id: string;
  type?: 'normal' | 'solid';
  radius: number;
  initialRadius: number;
  closingSpeed: number;
  rotation: number;
  rotationSpeed: number;
  rotationDirection: 1 | -1;
  hp: number;
  maxHp: number;
  gapStart: number;
  gapSize: number;
  status: RingStatus;
  thickness: number;
  color: string;
  minRadius: number;
  slowUntil?: number;
  burnUntil?: number;
  burnDps?: number;
}

export interface RingConfig {
  count: number;
  innerRadius: number;
  outerRadius: number;
  baseRotationSpeed: number;
  baseHp: number;
  baseGapSize: number;
  baseThickness: number;
  closingSpeed: number;
  colors: string[];
  solidCount?: number;
  solidHpMultiplier?: number;
  minCount?: number;
  countGrowth?: number;
  difficultyGrowth?: number;
  gapShrinkPerPhase?: number;
  minGapSize?: number;
  minSpacing?: number;
  safeStartRadius?: number;
  maxCount?: number;
  spawnBatchSize?: number;
  respawnThreshold?: number;
}

const TWO_PI = Math.PI * 2;
export const MIN_RING_GAP = 5;

export const normalizeAngle = (angle: number) => ((angle % TWO_PI) + TWO_PI) % TWO_PI;

export const angleDistance = (a: number, b: number) => {
  const diff = Math.abs(normalizeAngle(a) - normalizeAngle(b));
  return Math.min(diff, TWO_PI - diff);
};

export const getRingGapCenter = (ring: Ring) => normalizeAngle(ring.gapStart + ring.rotation);

export const isAngleInsideRingGap = (angle: number, ring: Ring, padding = 0) => {
  const halfGap = Math.max(0, ring.gapSize / 2 - padding);
  return angleDistance(angle, getRingGapCenter(ring)) <= halfGap;
};

export const createRings = (config: RingConfig, phase: number): Ring[] => {
  const rings: Ring[] = [];
  const growth = config.difficultyGrowth ?? 0.22;
  const difficulty = 1 + Math.max(0, phase - 1) * growth;
  const countGrowth = config.countGrowth ?? 2;
  const requestedCount = Math.min(
    config.maxCount ?? Infinity,
    Math.max(config.minCount ?? 20, config.count + Math.floor(Math.max(0, phase - 1) * countGrowth))
  );
  const innerRadius = Math.max(config.innerRadius, config.safeStartRadius ?? config.innerRadius);
  const availableRadius = Math.max(1, config.outerRadius - innerRadius);
  const adaptiveMinSpacing = Math.min(config.minSpacing ?? MIN_RING_GAP, Math.max(2.25, availableRadius / Math.max(1, requestedCount - 1)));
  const maxCountBySpacing = Math.max(1, Math.floor(availableRadius / adaptiveMinSpacing) + 1);
  const count = Math.max(1, Math.min(requestedCount, maxCountBySpacing));
  const spacing = availableRadius / Math.max(1, count - 1);
  const minGap = config.minGapSize ?? Math.PI / 7.5;
  const phaseGap = Math.max(minGap, config.baseGapSize - (phase - 1) * (config.gapShrinkPerPhase ?? 0.045));
  const suggestedSolidCount =
    phase <= 5 ? 1 :
    phase <= 10 ? 1 + (phase >= 8 ? 1 : 0) :
    phase <= 20 ? 2 + Math.floor((phase - 11) / 5) :
    phase <= 35 ? 4 + Math.floor((phase - 21) / 6) :
    6 + Math.floor((phase - 36) / 5);
  const solidCount = Math.max(1, Math.min(count, config.solidCount ?? suggestedSolidCount));
  // The outer ring is reached last in the outward escape flow, so every stage ends on a solid ring.
  const solidIndexes = new Set<number>([count - 1]);
  for (let s = 1; s < solidCount; s += 1) {
    const slot = Math.max(1, count - 1 - Math.floor((s * count) / (solidCount + 1)));
    solidIndexes.add(slot);
  }

  for (let i = 0; i < count; i++) {
    const progress = count === 1 ? 0 : i / (count - 1);
    const radius = innerRadius + i * spacing;
    const direction: 1 | -1 = i % 2 === 0 ? 1 : -1;
    const patternShift = phase % 3 === 0 ? Math.sin(i * 0.9) * 0.18 : 0;
    const innerSpeedBias = 1.35 - progress * 0.55;
    const speedVariation = 0.86 + ((i * 17 + phase * 11) % 23) / 100;
    const isSolid = solidIndexes.has(i);
    const hp = Math.floor(config.baseHp * difficulty * (0.9 + progress * 1.55) * (isSolid ? config.solidHpMultiplier ?? 1.45 : 1));
    const gapSize = Math.max(minGap, phaseGap * (1.08 - progress * 0.16));

    rings.push({
      id: `ring_${phase}_${i}`,
      type: isSolid ? 'solid' : 'normal',
      radius,
      initialRadius: radius,
      closingSpeed: config.closingSpeed * difficulty * (0.75 + progress * 0.42),
      rotation: normalizeAngle(i * 0.61 + phase * 0.37 + patternShift),
      rotationSpeed: config.baseRotationSpeed * difficulty * innerSpeedBias * speedVariation * direction,
      rotationDirection: direction,
      gapStart: normalizeAngle(i * 0.83 + phase * 0.49 + patternShift),
      gapSize: isSolid ? 0 : gapSize,
      hp,
      maxHp: hp,
      status: 'active',
      thickness: isSolid ? config.baseThickness + 2 : config.baseThickness,
      color: isSolid ? ['#ff3d00', '#ff0055', '#b000ff'][i % 3] : config.colors[i % config.colors.length],
      minRadius: 4,
    });
  }

  return rings;
};

export const updateRing = (ring: Ring, deltaTime = 1, now = Date.now()): Ring => {
  if (
    !ring ||
    ring.status !== 'active' ||
    !Number.isFinite(ring.radius) ||
    !Number.isFinite(ring.rotation) ||
    !Number.isFinite(ring.closingSpeed) ||
    !Number.isFinite(ring.rotationSpeed)
  ) {
    return ring;
  }

  const slowMultiplier = ring.slowUntil && ring.slowUntil > now ? 0.45 : 1;
  const newRotation = normalizeAngle(ring.rotation + ring.rotationSpeed * slowMultiplier * deltaTime);
  const newRadius = Math.max(ring.minRadius, ring.radius - ring.closingSpeed * slowMultiplier * deltaTime);
  let hp = ring.hp;

  if (ring.burnUntil && ring.burnUntil > now && ring.burnDps) {
    hp = Math.max(0, hp - (ring.burnDps * deltaTime) / 60);
  }

  return {
    ...ring,
    rotation: newRotation,
    radius: newRadius,
    hp,
    status: hp <= 0 ? 'broken' : ring.status,
  };
};

export const clampRingSpacing = (rings: Ring[], minGap = MIN_RING_GAP): Ring[] => {
  let innerActive: Ring | null = null;

  return rings.map(ring => {
    if (!ring || ring.status !== 'active' || ring.hp <= 0 || !Number.isFinite(ring.radius)) return ring;

    const minRadiusFromInner = innerActive
      ? innerActive.radius + innerActive.thickness / 2 + ring.thickness / 2 + minGap
      : ring.minRadius;
    const minRadius = Math.max(ring.minRadius, minRadiusFromInner);
    const clampedRing = ring.radius < minRadius ? { ...ring, radius: minRadius } : ring;
    innerActive = clampedRing;
    return clampedRing;
  });
};

export const updateRings = (rings: Ring[], deltaTime = 1, now = Date.now(), minGap = MIN_RING_GAP): Ring[] =>
  clampRingSpacing(rings.map(ring => updateRing(ring, deltaTime, now)), minGap);

export const checkRingCollision = (
  ballX: number,
  ballY: number,
  ballRadius: number,
  ring: Ring,
  centerX: number,
  centerY: number
): { isOverlapping: boolean; isInSolidPart: boolean; isInGap: boolean; distFromRing: number; angle: number } => {
  if (
    !ring ||
    ring.status !== 'active' ||
    !Number.isFinite(ballX) ||
    !Number.isFinite(ballY) ||
    !Number.isFinite(ballRadius) ||
    !Number.isFinite(ring.radius) ||
    !Number.isFinite(ring.thickness)
  ) {
    return { isOverlapping: false, isInSolidPart: false, isInGap: false, distFromRing: Infinity, angle: 0 };
  }

  const dx = ballX - centerX;
  const dy = ballY - centerY;
  const distFromCenter = Math.sqrt(dx * dx + dy * dy);
  const distFromRing = Math.abs(distFromCenter - ring.radius);
  const isOverlapping = distFromRing <= ring.thickness / 2 + ballRadius;
  const angle = normalizeAngle(Math.atan2(dy, dx));
  const gapPadding = Math.min(0.08, ballRadius / Math.max(1, ring.radius));
  const isInGap = ring.type === 'solid' ? false : isAngleInsideRingGap(angle, ring, gapPadding);

  return {
    isOverlapping,
    isInSolidPart: isOverlapping && !isInGap,
    isInGap,
    distFromRing,
    angle,
  };
};

export const findClosestCollidingRing = (
  ballX: number,
  ballY: number,
  ballRadius: number,
  rings: Ring[],
  centerX: number,
  centerY: number
): { ring: Ring | null; index: number; isInSolidPart: boolean; isInGap: boolean } => {
  let closestRing: Ring | null = null;
  let closestIndex = -1;
  let closestDist = Infinity;
  let isInSolid = false;
  let isInGap = false;

  for (let i = 0; i < rings.length; i++) {
    const ring = rings[i];
    if (!ring || ring.status !== 'active' || !Number.isFinite(ring.radius)) continue;
    const result = checkRingCollision(ballX, ballY, ballRadius, ring, centerX, centerY);

    if (result.isOverlapping && result.distFromRing < closestDist) {
      closestDist = result.distFromRing;
      closestRing = ring;
      closestIndex = i;
      isInSolid = result.isInSolidPart;
      isInGap = result.isInGap;
    }
  }

  return { ring: closestRing, index: closestIndex, isInSolidPart: isInSolid, isInGap };
};

export const isBallCrushedByRing = (
  ballX: number,
  ballY: number,
  ballRadius: number,
  ring: Ring,
  centerX: number,
  centerY: number
) => {
  if (!ring || ring.status !== 'active' || ring.hp <= 0) return false;
  const collision = checkRingCollision(ballX, ballY, ballRadius, ring, centerX, centerY);
  if (collision.isInGap || !collision.isInSolidPart) return false;

  const dx = ballX - centerX;
  const dy = ballY - centerY;
  const dist = Math.sqrt(dx * dx + dy * dy);
  const outerEdge = ring.radius + ring.thickness / 2;
  const ringPassedIntoBall = outerEdge <= Math.max(0, dist - ballRadius * 0.25);
  const centerTrap = dist <= ballRadius * 1.15 && outerEdge <= ballRadius + 4;

  return ringPassedIntoBall || centerTrap;
};

export const findPerfectEscapeRing = (
  prevDist: number,
  nextDist: number,
  ballX: number,
  ballY: number,
  ballRadius: number,
  rings: Ring[],
  centerX: number,
  centerY: number
): { ring: Ring | null; index: number } => {
  const dx = ballX - centerX;
  const dy = ballY - centerY;
  const angle = normalizeAngle(Math.atan2(dy, dx));
  let bestIndex = -1;
  let bestDist = Infinity;

  for (let i = 0; i < rings.length; i++) {
    const ring = rings[i];
    if (!ring || ring.status !== 'active' || !Number.isFinite(ring.radius) || ring.type === 'solid') continue;
    const crossed = (prevDist - ring.radius) * (nextDist - ring.radius) <= 0;
    if (!crossed) continue;
    const near = Math.abs(nextDist - ring.radius) <= ballRadius + Math.abs(nextDist - prevDist) + ring.thickness;
    if (!near || !isAngleInsideRingGap(angle, ring, Math.min(0.06, ballRadius / Math.max(1, ring.radius)))) continue;

    const dist = Math.abs(nextDist - ring.radius);
    if (dist < bestDist) {
      bestDist = dist;
      bestIndex = i;
    }
  }

  return { ring: bestIndex >= 0 ? rings[bestIndex] : null, index: bestIndex };
};

export const reflectBallOffRing = (
  ballX: number,
  ballY: number,
  velX: number,
  velY: number,
  centerX: number,
  centerY: number,
  angleVariation = 0.08
): { newVelX: number; newVelY: number } => {
  if (![ballX, ballY, velX, velY, centerX, centerY].every(Number.isFinite)) {
    return { newVelX: Number.isFinite(velX) ? velX : 2.5, newVelY: Number.isFinite(velY) ? velY : 1.5 };
  }

  const dx = ballX - centerX;
  const dy = ballY - centerY;
  const dist = Math.sqrt(dx * dx + dy * dy) || 1;
  const nx = dx / dist;
  const ny = dy / dist;
  const dot = velX * nx + velY * ny;
  let newVelX = velX - 2 * dot * nx;
  let newVelY = velY - 2 * dot * ny;
  const speed = Math.sqrt(newVelX * newVelX + newVelY * newVelY) || 1;
  const tangentKick = (Math.random() - 0.5) * 0.12;

  newVelX += -ny * speed * tangentKick;
  newVelY += nx * speed * tangentKick;

  const newSpeed = Math.sqrt(newVelX * newVelX + newVelY * newVelY) || speed;
  const currentAngle = Math.atan2(newVelY, newVelX);
  const variedAngle = currentAngle + (Math.random() - 0.5) * angleVariation;

  return {
    newVelX: Math.cos(variedAngle) * newSpeed,
    newVelY: Math.sin(variedAngle) * newSpeed,
  };
};

export const clampBallSpeed = (velocity: { x: number; y: number }, minSpeed: number, maxSpeed: number) => {
  if (!Number.isFinite(velocity.x) || !Number.isFinite(velocity.y)) {
    return { x: minSpeed, y: 0 };
  }
  const speed = Math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y) || minSpeed;
  const clamped = Math.max(minSpeed, Math.min(maxSpeed, speed));
  return {
    x: (velocity.x / speed) * clamped,
    y: (velocity.y / speed) * clamped,
  };
};

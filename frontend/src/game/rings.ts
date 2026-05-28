export interface Ring {
  id: string;
  radius: number;
  rotation: number;
  rotationSpeed: number;
  gapStart: number;
  gapSize: number;
  hp: number;
  maxHp: number;
  thickness: number;
  color: string;
  closingSpeed: number;
  minRadius: number;
  initialRadius: number;
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
}

export const createRings = (config: RingConfig, phase: number): Ring[] => {
  const rings: Ring[] = [];
  const difficultyMultiplier = 1 + (phase - 1) * 0.4;
  const spacing = (config.outerRadius - config.innerRadius) / config.count;
  
  for (let i = 0; i < config.count; i++) {
    const radius = config.innerRadius + (i * spacing);
    const rotationDirection = i % 2 === 0 ? 1 : -1;
    const speedVariation = 0.7 + Math.random() * 0.6;
    const gapVariation = 0.9 + Math.random() * 0.2;
    
    rings.push({
      id: `ring_${i}`,
      radius,
      initialRadius: radius,
      rotation: Math.random() * Math.PI * 2,
      rotationSpeed: config.baseRotationSpeed * speedVariation * rotationDirection * difficultyMultiplier,
      gapStart: Math.random() * Math.PI * 2,
      gapSize: config.baseGapSize * gapVariation,
      hp: Math.floor(config.baseHp * (1 + i * 0.3) * difficultyMultiplier),
      maxHp: Math.floor(config.baseHp * (1 + i * 0.3) * difficultyMultiplier),
      thickness: config.baseThickness,
      color: config.colors[i % config.colors.length],
      closingSpeed: config.closingSpeed * (0.5 + Math.random() * 0.5),
      minRadius: 25,
    });
  }
  
  return rings;
};

export const updateRing = (ring: Ring, deltaTime: number = 1): Ring => {
  const newRotation = ring.rotation + ring.rotationSpeed * deltaTime;
  const newRadius = Math.max(ring.minRadius, ring.radius - ring.closingSpeed * deltaTime);
  
  return {
    ...ring,
    rotation: newRotation % (Math.PI * 2),
    radius: newRadius,
  };
};

// Check if ball is touching ring's solid part (not in gap)
export const checkRingCollision = (
  ballX: number,
  ballY: number,
  ballRadius: number,
  ring: Ring,
  centerX: number,
  centerY: number
): { isOverlapping: boolean; isInSolidPart: boolean; distFromRing: number } => {
  const dx = ballX - centerX;
  const dy = ballY - centerY;
  const distFromCenter = Math.sqrt(dx * dx + dy * dy);
  const distFromRing = Math.abs(distFromCenter - ring.radius);
  
  // Is ball overlapping this ring?
  const isOverlapping = distFromRing < ring.thickness / 2 + ballRadius;
  
  if (!isOverlapping) {
    return { isOverlapping: false, isInSolidPart: false, distFromRing };
  }
  
  // Calculate ball angle
  const ballAngle = Math.atan2(dy, dx);
  const normalizedBallAngle = (ballAngle + Math.PI * 2) % (Math.PI * 2);
  
  // Calculate current gap position (with rotation)
  const gapStartAngle = (ring.gapStart + ring.rotation + Math.PI * 4) % (Math.PI * 2);
  const gapEndAngle = (gapStartAngle + ring.gapSize) % (Math.PI * 2);
  
  let isInGap = false;
  if (gapStartAngle < gapEndAngle) {
    isInGap = normalizedBallAngle >= gapStartAngle && normalizedBallAngle <= gapEndAngle;
  } else {
    // Gap wraps around 0
    isInGap = normalizedBallAngle >= gapStartAngle || normalizedBallAngle <= gapEndAngle;
  }
  
  return {
    isOverlapping: true,
    isInSolidPart: !isInGap,
    distFromRing,
  };
};

// Find the ring the ball is most touching (closest one)
export const findClosestCollidingRing = (
  ballX: number,
  ballY: number,
  ballRadius: number,
  rings: Ring[],
  centerX: number,
  centerY: number
): { ring: Ring | null; index: number; isInSolidPart: boolean } => {
  let closestRing: Ring | null = null;
  let closestIndex = -1;
  let closestDist = Infinity;
  let isInSolid = false;
  
  for (let i = 0; i < rings.length; i++) {
    const ring = rings[i];
    if (ring.hp <= 0) continue;
    
    const result = checkRingCollision(ballX, ballY, ballRadius, ring, centerX, centerY);
    
    if (result.isOverlapping && result.distFromRing < closestDist) {
      closestDist = result.distFromRing;
      closestRing = ring;
      closestIndex = i;
      isInSolid = result.isInSolidPart;
    }
  }
  
  return { ring: closestRing, index: closestIndex, isInSolidPart: isInSolid };
};

// Reflect ball velocity off ring (radial reflection)
export const reflectBallOffRing = (
  ballX: number,
  ballY: number,
  velX: number,
  velY: number,
  centerX: number,
  centerY: number,
  angleVariation: number = 0.15
): { newVelX: number; newVelY: number; newBallX: number; newBallY: number } => {
  const dx = ballX - centerX;
  const dy = ballY - centerY;
  const dist = Math.sqrt(dx * dx + dy * dy);
  
  if (dist === 0) {
    return { newVelX: velX, newVelY: velY, newBallX: ballX, newBallY: ballY };
  }
  
  const nx = dx / dist;
  const ny = dy / dist;
  
  // Reflect velocity across radial normal
  const dot = velX * nx + velY * ny;
  let newVelX = velX - 2 * dot * nx;
  let newVelY = velY - 2 * dot * ny;
  
  // Add small random angle variation to prevent linear patterns
  const speed = Math.sqrt(newVelX * newVelX + newVelY * newVelY);
  const currentAngle = Math.atan2(newVelY, newVelX);
  const newAngle = currentAngle + (Math.random() - 0.5) * angleVariation;
  newVelX = Math.cos(newAngle) * speed;
  newVelY = Math.sin(newAngle) * speed;
  
  return { newVelX, newVelY, newBallX: ballX, newBallY: ballY };
};

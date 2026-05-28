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
}

export interface RingConfig {
  count: number;
  baseRadius: number;
  radiusIncrement: number;
  baseRotationSpeed: number;
  baseHp: number;
  baseGapSize: number;
  baseThickness: number;
  closingSpeed: number;
  colors: string[];
}

export const createRings = (config: RingConfig, phase: number): Ring[] => {
  const rings: Ring[] = [];
  const difficultyMultiplier = 1 + (phase - 1) * 0.3;
  
  for (let i = 0; i < config.count; i++) {
    const radius = config.baseRadius + (i * config.radiusIncrement);
    const rotationDirection = i % 2 === 0 ? 1 : -1;
    const speedVariation = 0.8 + Math.random() * 0.4;
    
    rings.push({
      id: `ring_${i}`,
      radius,
      rotation: Math.random() * Math.PI * 2,
      rotationSpeed: config.baseRotationSpeed * speedVariation * rotationDirection * difficultyMultiplier,
      gapStart: Math.random() * Math.PI * 2,
      gapSize: config.baseGapSize - (i * 0.02 * difficultyMultiplier),
      hp: config.baseHp * (1 + i * 0.5) * difficultyMultiplier,
      maxHp: config.baseHp * (1 + i * 0.5) * difficultyMultiplier,
      thickness: config.baseThickness,
      color: config.colors[i % config.colors.length],
      closingSpeed: config.closingSpeed * (1 + i * 0.1),
      minRadius: 80,
    });
  }
  
  return rings;
};

export const updateRing = (ring: Ring, deltaTime: number): Ring => {
  const newRotation = ring.rotation + ring.rotationSpeed * deltaTime;
  const newRadius = Math.max(ring.minRadius, ring.radius - ring.closingSpeed * deltaTime);
  
  return {
    ...ring,
    rotation: newRotation % (Math.PI * 2),
    radius: newRadius,
  };
};

export const checkBallRingCollision = (
  ballX: number,
  ballY: number,
  ballRadius: number,
  ring: Ring,
  centerX: number,
  centerY: number
): { hit: boolean; throughGap: boolean } => {
  const dx = ballX - centerX;
  const dy = ballY - centerY;
  const distanceFromCenter = Math.sqrt(dx * dx + dy * dy);
  
  const innerRadius = ring.radius - ring.thickness / 2;
  const outerRadius = ring.radius + ring.thickness / 2;
  
  const isInRingZone = distanceFromCenter + ballRadius > innerRadius && 
                       distanceFromCenter - ballRadius < outerRadius;
  
  if (!isInRingZone) {
    return { hit: false, throughGap: false };
  }
  
  const angle = Math.atan2(dy, dx);
  const normalizedAngle = (angle + Math.PI * 2) % (Math.PI * 2);
  const gapEnd = (ring.gapStart + ring.gapSize) % (Math.PI * 2);
  
  const isInGap = ring.gapStart < gapEnd
    ? normalizedAngle >= ring.gapStart && normalizedAngle <= gapEnd
    : normalizedAngle >= ring.gapStart || normalizedAngle <= gapEnd;
  
  return {
    hit: !isInGap,
    throughGap: isInGap,
  };
};

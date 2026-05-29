export const GAMEPLAY_TUNING = {
  solo: {
    ballSpeed: 2.2,
    ballPhaseGain: 0.08,
    ballMaxBonus: 0.62,
    ringClosingScale: 0.82,
    ringRotationScale: 0.9,
    safeHudReserve: 310,
  },
  boss: {
    arenaBallSpeed: 2.18,
    gapScale: 0.68,
    safeHudReserve: 288,
  },
  league: {
    arenaBallSpeed: 2.16,
    gapScale: 0.58,
    safeHudReserve: 288,
  },
  infinite: {
    ballSpeed: 2.14,
    ballRampPerMinute: 0.12,
    ringClosingScale: 0.78,
    ringRampPerMinute: 0.1,
    gapScale: 0.5,
    safeHudReserve: 310,
  },
};

export const PERMANENT_UPGRADE_LIMITS: Record<string, number> = {
  baseDamage: 30,
  baseSpeed: 18,
  coinMultiplier: 25,
  critChance: 20,
  xpBoost: 25,
  perfectChance: 12,
  slowRings: 10,
};

export const ECONOMY_BALANCE = {
  runCoinMultiplier: 0.92,
  globalCoinConversionRate: 0.72,
  profileXpMultiplier: 0.95,
  gemDropChance: 0.03,
  dailyMissionRewardScale: 1,
  eventRewardScale: 1,
  comboWindowMs: 2600,
  offlineMaxHours: 10,
  offlineCoinsPerHourBase: 42,
  adDailyLimit: 8,
  chestCostMultiplier: 1,
};

export const getComboMultiplier = (combo: number) => {
  if (combo >= 20) return { coins: 1.28, xp: 1.24, label: 'Ring Rush!' };
  if (combo >= 10) return { coins: 1.2, xp: 1.2, label: 'Perfect Chain!' };
  if (combo >= 5) return { coins: 1.1, xp: 1.1, label: 'Great!' };
  if (combo >= 2) return { coins: 1.05, xp: 1.03, label: 'Combo!' };
  return { coins: 1, xp: 1, label: '' };
};

export const getRunProfileXp = (xp: number, ringsBroken: number, perfectEscapes: number, bestCombo = 0) =>
  Math.max(8, Math.floor((xp * 0.42 + ringsBroken * 3.6 + perfectEscapes * 5 + bestCombo * 1.2) * ECONOMY_BALANCE.profileXpMultiplier));

export const getGlobalCoinsFromRun = (runCoins: number, bestCombo = 0, won = false) => {
  const comboBonus = bestCombo >= 20 ? 1.18 : bestCombo >= 10 ? 1.1 : bestCombo >= 5 ? 1.05 : 1;
  const winBonus = won ? 1.08 : 1;
  return Math.max(0, Math.floor(runCoins * ECONOMY_BALANCE.globalCoinConversionRate * comboBonus * winBonus));
};

export type RewardedAdPlacement =
  | 'default'
  | 'doubleRewards'
  | 'rerollUpgrades'
  | 'freeChest'
  | 'revive'
  | 'freeCoins'
  | 'freeGems'
  | 'store_gems'
  | 'store_coins'
  | 'store_chest'
  | 'store_key'
  | 'store_offline'
  | 'inventory_free_chest'
  | 'upgrade_reroll'
  | 'double_run_reward'
  | 'offline_double'
  | 'wheel_extra';

export type RewardedAdResult = {
  success: boolean;
  reward?: { type: string; amount: number };
  error?: string;
};

export async function initializeAds(): Promise<boolean> {
  return true;
}

export async function preloadRewardedAd(_placement: RewardedAdPlacement = 'default'): Promise<boolean> {
  return true;
}

export function isRewardedAdReady(_placement: RewardedAdPlacement = 'default') {
  return true;
}

export async function showRewardedAd(_placement: RewardedAdPlacement = 'default'): Promise<RewardedAdResult> {
  return { success: true, reward: { type: 'web-dev', amount: 1 } };
}

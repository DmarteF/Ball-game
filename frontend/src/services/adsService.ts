import Constants from 'expo-constants';

export type RewardedAdPlacement =
  | 'store_gems'
  | 'store_coins'
  | 'store_chest'
  | 'store_key'
  | 'store_offline'
  | 'inventory_free_chest'
  | 'upgrade_reroll'
  | 'double_run_reward'
  | 'revive';

export type RewardedAdResult = {
  rewarded: boolean;
  error?: string;
};

const DEV_REWARD_DELAY_MS = 900;

function isDevelopmentBuild() {
  return __DEV__ || Constants.executionEnvironment === 'storeClient';
}

export async function showRewardedAd(placement: RewardedAdPlacement): Promise<RewardedAdResult> {
  try {
    if (isDevelopmentBuild()) {
      await new Promise(resolve => setTimeout(resolve, DEV_REWARD_DELAY_MS));
      return { rewarded: true };
    }

    return {
      rewarded: false,
      error: `Rewarded ad SDK is not configured for ${placement}.`,
    };
  } catch (error) {
    return {
      rewarded: false,
      error: error instanceof Error ? error.message : 'Rewarded ad failed.',
    };
  }
}

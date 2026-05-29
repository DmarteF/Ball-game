import { Platform } from 'react-native';
import { ADS_CONFIG } from '@/src/services/adsConfig';
import { pauseMusicForAd, resumeMusicAfterAd } from '@/src/utils/audio';

export type RewardedAdPlacement =
  | 'default'
  | 'doubleRewards'
  | 'rerollUpgrades'
  | 'freeChest'
  | 'freeKey'
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

type RewardedAdReward = {
  type: string;
  amount: number;
};

type GoogleMobileAdsModule = typeof import('react-native-google-mobile-ads');
type RewardedAdInstance = import('react-native-google-mobile-ads').RewardedAd;

type PlacementState = {
  rewardedAd?: RewardedAdInstance;
  loadingPromise?: Promise<boolean>;
};

declare const require: (id: string) => GoogleMobileAdsModule;

const rewardedStates: Partial<Record<RewardedAdPlacement, PlacementState>> = {};
let mobileAdsModule: GoogleMobileAdsModule | null = null;
let initialized = false;
let initializingPromise: Promise<boolean> | null = null;
let showingPlacement: RewardedAdPlacement | null = null;

const canUseRealAds = () => ADS_CONFIG.enabled && Platform.OS !== 'web';

const getGoogleMobileAds = () => {
  if (!canUseRealAds()) return null;
  if (mobileAdsModule) return mobileAdsModule;
  try {
    mobileAdsModule = require('react-native-google-mobile-ads');
    return mobileAdsModule;
  } catch (error) {
    console.warn('AdMob SDK unavailable:', error);
    return null;
  }
};

const getPlacementState = (placement: RewardedAdPlacement) => {
  rewardedStates[placement] ||= {};
  return rewardedStates[placement]!;
};

const createRewardedAd = (placement: RewardedAdPlacement) => {
  const ads = getGoogleMobileAds();
  if (!ads) return null;
  const state = getPlacementState(placement);
  state.rewardedAd = ads.RewardedAd.createForAdRequest(ADS_CONFIG.rewardedAdUnitId, {
    requestNonPersonalizedAdsOnly: true,
  });
  return state.rewardedAd;
};

const simulationFallback = async (): Promise<RewardedAdResult> => {
  if (!ADS_CONFIG.simulationFallbackEnabled) {
    return { success: false, error: 'Anúncio indisponível no momento. Tente novamente.' };
  }
  await new Promise(resolve => setTimeout(resolve, 900));
  return { success: true, reward: { type: 'fallback', amount: 1 } };
};

export async function initializeAds(): Promise<boolean> {
  if (initialized) return true;
  if (!ADS_CONFIG.enabled) return ADS_CONFIG.simulationFallbackEnabled;
  if (!canUseRealAds()) return ADS_CONFIG.simulationFallbackEnabled;
  if (initializingPromise) return initializingPromise;

  initializingPromise = (async () => {
    const ads = getGoogleMobileAds();
    if (!ads) return ADS_CONFIG.simulationFallbackEnabled;
    try {
      await ads.default().initialize();
      initialized = true;
      return true;
    } catch (error) {
      console.warn('AdMob initialize failed:', error);
      return ADS_CONFIG.simulationFallbackEnabled;
    } finally {
      initializingPromise = null;
    }
  })();

  return initializingPromise;
}

export async function preloadRewardedAd(placement: RewardedAdPlacement = 'default'): Promise<boolean> {
  if (!ADS_CONFIG.enabled || !canUseRealAds()) return ADS_CONFIG.simulationFallbackEnabled;
  const ads = getGoogleMobileAds();
  if (!ads) return ADS_CONFIG.simulationFallbackEnabled;
  const ready = await initializeAds();
  if (!ready) return false;

  const state = getPlacementState(placement);
  if (state.rewardedAd?.loaded) return true;
  if (state.loadingPromise) return state.loadingPromise;

  const rewardedAd = createRewardedAd(placement);
  if (!rewardedAd) return ADS_CONFIG.simulationFallbackEnabled;

  state.loadingPromise = new Promise<boolean>(resolve => {
    let settled = false;
    const cleanupCallbacks: (() => void)[] = [];
    const finish = (loaded: boolean) => {
      if (settled) return;
      settled = true;
      cleanupCallbacks.forEach(cleanup => cleanup());
      state.loadingPromise = undefined;
      resolve(loaded);
    };

    cleanupCallbacks.push(
      rewardedAd.addAdEventListener(ads.RewardedAdEventType.LOADED, () => finish(true)),
      rewardedAd.addAdEventListener(ads.AdEventType.ERROR, error => {
        console.warn('Rewarded ad load failed:', error);
        finish(false);
      }),
    );

    setTimeout(() => finish(Boolean(rewardedAd.loaded)), 15000);
    rewardedAd.load();
  });

  return state.loadingPromise;
}

export function isRewardedAdReady(placement: RewardedAdPlacement = 'default') {
  if (!ADS_CONFIG.enabled || !canUseRealAds()) return ADS_CONFIG.simulationFallbackEnabled;
  return Boolean(getPlacementState(placement).rewardedAd?.loaded);
}

export async function showRewardedAd(placement: RewardedAdPlacement = 'default'): Promise<RewardedAdResult> {
  if (showingPlacement) {
    return { success: false, error: 'Anúncio já está em andamento.' };
  }

  if (!ADS_CONFIG.enabled || !canUseRealAds()) {
    return simulationFallback();
  }

  const ads = getGoogleMobileAds();
  if (!ads) return simulationFallback();

  showingPlacement = placement;
  pauseMusicForAd();

  try {
    const loaded = isRewardedAdReady(placement) || await preloadRewardedAd(placement);
    const rewardedAd = getPlacementState(placement).rewardedAd;
    if (!loaded || !rewardedAd?.loaded) {
      return { success: false, error: 'Anúncio indisponível no momento. Tente novamente.' };
    }

    const result = await new Promise<RewardedAdResult>(resolve => {
      let settled = false;
      let earnedReward: RewardedAdReward | undefined;
      const cleanupCallbacks: (() => void)[] = [];
      const cleanup = () => cleanupCallbacks.forEach(remove => remove());
      const finish = (nextResult: RewardedAdResult) => {
        if (settled) return;
        settled = true;
        cleanup();
        resolve(nextResult);
      };

      cleanupCallbacks.push(
        rewardedAd.addAdEventListener(ads.RewardedAdEventType.EARNED_REWARD, reward => {
          earnedReward = reward as RewardedAdReward;
        }),
        rewardedAd.addAdEventListener(ads.AdEventType.CLOSED, () => {
          if (earnedReward) {
            finish({ success: true, reward: earnedReward });
            return;
          }
          finish({ success: false, error: 'Assista ao vídeo completo para receber a recompensa.' });
        }),
        rewardedAd.addAdEventListener(ads.AdEventType.ERROR, error => {
          console.warn('Rewarded ad show failed:', error);
          finish({ success: false, error: 'Anúncio indisponível no momento. Tente novamente.' });
        }),
      );

      setTimeout(() => {
        if (!settled) finish({ success: false, error: 'Anúncio indisponível no momento. Tente novamente.' });
      }, 90000);

      rewardedAd.show().catch(error => {
        console.warn('Rewarded ad show error:', error);
        finish({ success: false, error: 'Anúncio indisponível no momento. Tente novamente.' });
      });
    });

    createRewardedAd(placement);
    void preloadRewardedAd(placement);
    return result;
  } finally {
    showingPlacement = null;
    resumeMusicAfterAd();
  }
}

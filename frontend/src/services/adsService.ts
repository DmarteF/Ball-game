import { Platform } from 'react-native';
import mobileAds, { AdEventType, RewardedAd, RewardedAdEventType, type RewardedAdReward } from 'react-native-google-mobile-ads';
import { ADMOB_CONFIG, type AdMobRewardedPlacement } from '@/src/services/adMobConfig';
import { pauseMusicForAd, resumeMusicAfterAd } from '@/src/utils/audio';

export type RewardedAdPlacement =
  | AdMobRewardedPlacement
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
  reward?: RewardedAdReward;
  error?: string;
};

type RewardedRecord = {
  ad: RewardedAd;
  loaded: boolean;
  loading?: Promise<boolean>;
};

const LOAD_TIMEOUT_MS = 15000;
const rewardedAds = new Map<AdMobRewardedPlacement, RewardedRecord>();
let initializePromise: Promise<boolean> | null = null;
let activeShowPlacement: AdMobRewardedPlacement | null = null;

const placementAliases: Record<string, AdMobRewardedPlacement> = {
  double_run_reward: 'doubleRewards',
  upgrade_reroll: 'rerollUpgrades',
  inventory_free_chest: 'freeChest',
  store_chest: 'freeChest',
  store_key: 'default',
  store_offline: 'doubleRewards',
  offline_double: 'doubleRewards',
  wheel_extra: 'default',
  store_coins: 'freeCoins',
  store_gems: 'freeGems',
  revive: 'revive',
};

function normalizePlacement(placement: RewardedAdPlacement): AdMobRewardedPlacement {
  if (placement in ADMOB_CONFIG.rewarded) return placement as AdMobRewardedPlacement;
  return placementAliases[placement] || 'default';
}

function getAdUnitId(placement: AdMobRewardedPlacement) {
  return ADMOB_CONFIG.rewarded[placement] || ADMOB_CONFIG.rewarded.default;
}

function webFallback(): RewardedAdResult {
  if (__DEV__) return { success: true, reward: { type: 'dev', amount: 1 } };
  return { success: false, error: 'Anúncios disponíveis apenas no Android.' };
}

export async function initializeAds(): Promise<boolean> {
  if (Platform.OS === 'web') return false;
  if (!initializePromise) {
    initializePromise = mobileAds()
      .initialize()
      .then(() => true)
      .catch(error => {
        initializePromise = null;
        console.warn('AdMob initialization failed:', error);
        return false;
      });
  }
  return initializePromise;
}

function createRewardedRecord(placement: AdMobRewardedPlacement): RewardedRecord {
  const ad = RewardedAd.createForAdRequest(getAdUnitId(placement), {
    requestNonPersonalizedAdsOnly: true,
  });
  const record: RewardedRecord = { ad, loaded: false };
  rewardedAds.set(placement, record);
  return record;
}

function disposeRewardedAd(placement: AdMobRewardedPlacement) {
  const record = rewardedAds.get(placement);
  if (!record) return;
  try {
    record.ad.removeAllListeners();
  } catch {}
  rewardedAds.delete(placement);
}

export async function preloadRewardedAd(placement: RewardedAdPlacement = 'default'): Promise<boolean> {
  if (Platform.OS === 'web') return __DEV__;
  const ready = await initializeAds();
  if (!ready) return false;

  const normalized = normalizePlacement(placement);
  const existing = rewardedAds.get(normalized);
  if (existing?.loaded) return true;
  if (existing?.loading) return existing.loading;

  const record = existing || createRewardedRecord(normalized);
  record.loading = new Promise<boolean>(resolve => {
    let settled = false;
    const cleanup = () => {
      clearTimeout(timeout);
      unsubscribeLoaded();
      unsubscribeError();
      record.loading = undefined;
    };
    const settle = (loaded: boolean) => {
      if (settled) return;
      settled = true;
      record.loaded = loaded;
      cleanup();
      if (!loaded) disposeRewardedAd(normalized);
      resolve(loaded);
    };
    const unsubscribeLoaded = record.ad.addAdEventListener(RewardedAdEventType.LOADED, () => settle(true));
    const unsubscribeError = record.ad.addAdEventListener(AdEventType.ERROR, () => settle(false));
    const timeout = setTimeout(() => settle(false), LOAD_TIMEOUT_MS);

    try {
      record.ad.load();
    } catch {
      settle(false);
    }
  });

  return record.loading;
}

export function isRewardedAdReady(placement: RewardedAdPlacement = 'default') {
  if (Platform.OS === 'web') return __DEV__;
  const normalized = normalizePlacement(placement);
  return Boolean(rewardedAds.get(normalized)?.loaded);
}

export async function showRewardedAd(placement: RewardedAdPlacement = 'default'): Promise<RewardedAdResult> {
  if (Platform.OS === 'web') return webFallback();

  const normalized = normalizePlacement(placement);
  if (activeShowPlacement) {
    return { success: false, error: 'Já existe um anúncio em andamento.' };
  }

  const loaded = await preloadRewardedAd(normalized);
  const record = rewardedAds.get(normalized);
  if (!loaded || !record?.loaded) {
    preloadRewardedAd(normalized);
    return { success: false, error: 'Anúncio indisponível. Tente novamente.' };
  }

  activeShowPlacement = normalized;
  pauseMusicForAd();

  return new Promise<RewardedAdResult>(resolve => {
    let resolved = false;
    let earnedReward: RewardedAdReward | undefined;

    const cleanup = () => {
      unsubscribeReward();
      unsubscribeClosed();
      unsubscribeError();
      disposeRewardedAd(normalized);
      activeShowPlacement = null;
      resumeMusicAfterAd();
      preloadRewardedAd(normalized);
    };

    const finish = (result: RewardedAdResult) => {
      if (resolved) return;
      resolved = true;
      cleanup();
      resolve(result);
    };

    const unsubscribeReward = record.ad.addAdEventListener(RewardedAdEventType.EARNED_REWARD, reward => {
      if (!earnedReward) earnedReward = reward;
    });
    const unsubscribeClosed = record.ad.addAdEventListener(AdEventType.CLOSED, () => {
      finish(
        earnedReward
          ? { success: true, reward: earnedReward }
          : { success: false, error: 'Anúncio fechado antes da recompensa.' }
      );
    });
    const unsubscribeError = record.ad.addAdEventListener(AdEventType.ERROR, error => {
      finish({ success: false, error: error?.message || 'Falha ao exibir anúncio.' });
    });

    record.ad.show().catch(error => {
      finish({ success: false, error: error instanceof Error ? error.message : 'Falha ao exibir anúncio.' });
    });
  });
}

import adsSettings from '@/src/services/adsConfig.shared.json';

export const ADS_PRODUCTION = adsSettings.ADS_PRODUCTION;
export const ADMOB_IDS = adsSettings.ADMOB_IDS;

export const ADS_CONFIG = {
  enabled: true,
  production: ADS_PRODUCTION,
  simulationFallbackEnabled: true,
  androidAppId: ADS_PRODUCTION
    ? ADMOB_IDS.production.androidAppId
    : ADMOB_IDS.test.androidAppId,
  rewardedAdUnitId: ADS_PRODUCTION
    ? ADMOB_IDS.production.rewardedAdUnitId
    : ADMOB_IDS.test.rewardedAdUnitId,
};

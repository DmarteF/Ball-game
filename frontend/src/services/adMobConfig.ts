export const ADMOB_CONFIG = {
  androidAppId: 'ca-app-pub-3940256099942544~3347511713',
  rewarded: {
    default: 'ca-app-pub-3940256099942544/5224354917',
    doubleRewards: 'ca-app-pub-3940256099942544/5224354917',
    rerollUpgrades: 'ca-app-pub-3940256099942544/5224354917',
    freeChest: 'ca-app-pub-3940256099942544/5224354917',
    revive: 'ca-app-pub-3940256099942544/5224354917',
    freeCoins: 'ca-app-pub-3940256099942544/5224354917',
    freeGems: 'ca-app-pub-3940256099942544/5224354917',
  },
  testMode: true,
} as const;

export type AdMobRewardedPlacement = keyof typeof ADMOB_CONFIG.rewarded;

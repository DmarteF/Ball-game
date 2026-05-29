import { STORE_PRODUCTS, STORE_PRODUCT_IDS, StoreProductId } from '@/src/services/billingConfig';
import { getChestById, rollChestReward } from '@/src/game/chests';
import { storage } from '@/src/utils/storage';

const PROCESSED_PURCHASES_KEY = 'appcoins_processed_purchase_transactions_v1';

export type BillingProduct = {
  id: StoreProductId;
  title: string;
  description: string;
  fallbackPrice: string;
  localizedPrice?: string;
  available: boolean;
};

export type PurchaseStatus = 'confirmed' | 'unavailable' | 'canceled' | 'pending' | 'failed';

export type PurchaseResult = {
  status: PurchaseStatus;
  productId: StoreProductId;
  transactionId?: string;
  message?: string;
};

export type PurchaseRewardGame = {
  unlockedSkins: string[];
  ballTransformation: string;
  updateGems: (amount: number) => Promise<void>;
  updateCoins: (amount: number) => Promise<void>;
  updateKeys: (amount: number) => Promise<void>;
  updateLegendaryKeys: (amount: number) => Promise<void>;
  addProfileXp: (amount: number) => Promise<void>;
  grantReward: (reward: { type: 'fragments'; skinId?: string; amount: number } | { type: 'chest'; chestType: 'common' | 'rare' | 'epic' | 'legendary'; amount: number }) => Promise<void>;
  grantChestReward: (reward: ReturnType<typeof rollChestReward>) => Promise<void>;
  recordStorePurchase: () => Promise<void>;
};

export async function initializeBilling(): Promise<boolean> {
  return false;
}

export async function getProducts(): Promise<BillingProduct[]> {
  return STORE_PRODUCT_IDS.map(id => ({
    id,
    title: STORE_PRODUCTS[id].title,
    description: STORE_PRODUCTS[id].description,
    fallbackPrice: STORE_PRODUCTS[id].fallbackPrice,
    available: false,
  }));
}

export async function purchaseProduct(productId: StoreProductId): Promise<PurchaseResult> {
  return {
    status: 'unavailable',
    productId,
    message: 'AppCoins Billing ainda não está disponível nesta build.',
  };
}

export async function restorePurchases(): Promise<PurchaseResult[]> {
  return [];
}

const getProcessedTransactions = async () => {
  const stored = await storage.getItem(PROCESSED_PURCHASES_KEY, '[]');
  if (typeof stored !== 'string') return [];
  try {
    const parsed = JSON.parse(stored);
    return Array.isArray(parsed) ? parsed.filter(item => typeof item === 'string') : [];
  } catch {
    return [];
  }
};

const markTransactionProcessed = async (transactionId: string) => {
  const processed = await getProcessedTransactions();
  await storage.setItem(PROCESSED_PURCHASES_KEY, JSON.stringify(Array.from(new Set([...processed, transactionId]))));
};

const openChestRewards = async (game: PurchaseRewardGame, chestType: 'common' | 'rare' | 'epic', amount: number) => {
  const chest = getChestById(chestType);
  for (let index = 0; index < amount; index += 1) {
    const reward = rollChestReward(chest, game.unlockedSkins);
    await game.grantChestReward(reward);
  }
};

export async function grantPurchaseReward(productId: StoreProductId, transactionId: string, game: PurchaseRewardGame) {
  if (!transactionId) return { granted: false, duplicate: false };
  const processed = await getProcessedTransactions();
  if (processed.includes(transactionId)) return { granted: false, duplicate: true };

  const product = STORE_PRODUCTS[productId];
  if (!product) return { granted: false, duplicate: false };
  const rewards = product.rewards;

  if (rewards.gems) await game.updateGems(rewards.gems);
  if (rewards.coins) await game.updateCoins(rewards.coins);
  if (rewards.keys) await game.updateKeys(rewards.keys);
  if (rewards.legendaryKeys) await game.updateLegendaryKeys(rewards.legendaryKeys);
  if (rewards.profileXp) await game.addProfileXp(rewards.profileXp);
  if (rewards.equippedSkinFragments) {
    await game.grantReward({ type: 'fragments', skinId: game.ballTransformation, amount: rewards.equippedSkinFragments });
  }
  if (rewards.rareChests) {
    await game.grantReward({ type: 'chest', chestType: 'rare', amount: rewards.rareChests });
  }
  if (rewards.epicChests) {
    await game.grantReward({ type: 'chest', chestType: 'epic', amount: rewards.epicChests });
  }
  if (rewards.rareChestsToOpen) await openChestRewards(game, 'rare', rewards.rareChestsToOpen);
  if (rewards.commonChestsToOpen) await openChestRewards(game, 'common', rewards.commonChestsToOpen);
  if (rewards.epicChestsToOpen) await openChestRewards(game, 'epic', rewards.epicChestsToOpen);

  await game.recordStorePurchase();
  await markTransactionProcessed(transactionId);
  return { granted: true, duplicate: false };
}

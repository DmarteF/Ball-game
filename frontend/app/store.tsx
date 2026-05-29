import React, { useEffect, useMemo, useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, Modal, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useGame } from '@/src/contexts/GameContext';
import { AdModal } from '@/src/components/AdModal';
import { CHESTS, ChestDefinition, ChestReward, getChestById, rollChestReward } from '@/src/game/chests';
import { getSkinById } from '@/src/game/skins';
import { playSound } from '@/src/utils/audio';
import { UiIcon } from '@/src/components/UiIcon';
import { SkinIcon } from '@/src/components/SkinIcon';
import { UiIconKey } from '@/src/game/uiIcons';
import { RewardedAdPlacement } from '@/src/services/adsService';
import { STORE_PRODUCTS, StoreProductId } from '@/src/services/billingConfig';
import { BillingProduct, getProducts, grantPurchaseReward, initializeBilling, purchaseProduct } from '@/src/services/billingService';
import { useGameText } from '@/src/i18n/gameText';
import { useTranslation } from '@/src/i18n';

type Tab = 'chests' | 'gems' | 'keys' | 'specials' | 'free';

export default function StoreScreen() {
  const router = useRouter();
  const game = useGame();
  const gameText = useGameText();
  const { t } = useTranslation();
  const [tab, setTab] = useState<Tab>('chests');
  const [confirm, setConfirm] = useState<{ title: string; action: () => Promise<void> } | null>(null);
  const [ad, setAd] = useState<null | 'gems' | 'coins' | 'chest' | 'key' | 'offline'>(null);
  const [reward, setReward] = useState<ChestReward | null>(null);
  const [billingProducts, setBillingProducts] = useState<BillingProduct[]>([]);
  const [billingLoaded, setBillingLoaded] = useState(false);
  const [purchasingId, setPurchasingId] = useState<StoreProductId | null>(null);

  useEffect(() => {
    let mounted = true;
    const loadBillingProducts = async () => {
      await initializeBilling();
      const products = await getProducts();
      if (!mounted) return;
      setBillingProducts(products);
      setBillingLoaded(true);
    };
    loadBillingProducts();
    return () => {
      mounted = false;
    };
  }, []);

  const billingProductMap = useMemo(
    () => Object.fromEntries(billingProducts.map(item => [item.id, item])) as Partial<Record<StoreProductId, BillingProduct>>,
    [billingProducts],
  );

  const tabs: { id: Tab; label: string }[] = [
    { id: 'chests', label: t('stats.chests') },
    { id: 'gems', label: t('stats.diamonds') },
    { id: 'keys', label: t('stats.keys') },
    { id: 'specials', label: t('inventory.rewards') },
    { id: 'free', label: t('shop.freeChest') },
  ];

  const simulateChest = async (chestId: string) => {
    const chest = CHESTS.find(item => item.id === chestId) || CHESTS[0];
    const chestReward = rollChestReward(chest, game.unlockedSkins);
    await game.grantChestReward(chestReward);
    playSound('chestOpen', game.settings.sound);
    if (chestReward.rarity === 'legendary' || chestReward.rarity === 'ultimate' || chestReward.rarity === 'mythic') playSound('legendaryDrop', game.settings.sound);
    else if (chestReward.rarity === 'rare' || chestReward.rarity === 'epic') playSound('rareDrop', game.settings.sound);
    setReward(chestReward);
  };

  const getStoredChestId = (itemId: string) => {
    if (itemId.startsWith('boss_chest_')) return itemId.replace('boss_chest_', '');
    return itemId.replace('chest_', '');
  };

  const openStoredChest = async (itemId: string, chestId: string) => {
    const chest = getChestById(chestId as ChestDefinition['id']);
    await game.saveProgress({
      inventoryItems: game.inventoryItems
        .map(item => item.id === itemId ? { ...item, amount: item.amount - 1 } : item)
        .filter(item => item.amount > 0),
    });
    await simulateChest(chest.id);
  };

  const canPay = (currency: string, cost: number) => {
    const wallet = currency === 'coins' ? game.coins : currency === 'gems' ? game.gems : currency === 'keys' ? game.keys : game.legendaryKeys;
    return wallet >= cost;
  };

  const pay = async (currency: string, cost: number) => {
    if (!canPay(currency, cost)) {
      Alert.alert('Saldo insuficiente', 'Você não tem recursos suficientes para essa compra simulada.');
      playSound('buttonError', game.settings.sound);
      return false;
    }
    if (currency === 'coins') await game.updateCoins(-cost);
    if (currency === 'gems') await game.updateGems(-cost);
    if (currency === 'keys') await game.updateKeys(-cost);
    if (currency === 'legendaryKeys') await game.updateLegendaryKeys(-cost);
    playSound('buttonConfirm', game.settings.sound);
    return true;
  };

  const handleAdReward = async () => {
    const allowed = await game.recordAdUse(`store_${ad || 'reward'}`);
    if (!allowed) {
      setAd(null);
      return;
    }
    if (ad === 'gems') await game.updateGems(12);
    if (ad === 'coins') await game.updateCoins(300);
    if (ad === 'chest') await simulateChest('common');
    if (ad === 'key') await game.updateKeys(1);
    if (ad === 'offline') await game.claimOfflineReward(true);
    playSound('buttonConfirm', game.settings.sound);
    setAd(null);
  };

  const adPlacement = (): RewardedAdPlacement => {
    if (ad === 'gems') return 'freeGems';
    if (ad === 'coins') return 'freeCoins';
    if (ad === 'chest') return 'freeChest';
    if (ad === 'offline') return 'doubleRewards';
    return 'default';
  };

  const currencyIcon = (currency: string): UiIconKey =>
    currency === 'coins' ? 'ui_coin' : currency === 'gems' ? 'ui_gem' : currency === 'keys' ? 'ui_key' : 'ui_legendary_key';

  const chestIcon = (id: string): UiIconKey =>
    id === 'rare' ? 'ui_chest_rare' : id === 'epic' ? 'ui_chest_epic' : id === 'legendary' ? 'ui_chest_legendary' : 'ui_chest_common';

  const rewardIcon = (chestReward?: ChestReward | null): UiIconKey => {
    if (!chestReward) return 'ui_daily_reward';
    if (chestReward.type === 'key') return chestReward.label.includes('Lendária') ? 'ui_legendary_key' : 'ui_key';
    if (chestReward.type === 'trail') return 'ui_trail';
    if (chestReward.type === 'aura') return 'ui_aura';
    if (chestReward.type === 'effect') return 'ui_effect';
    if (chestReward.type === 'coins') return 'ui_coin';
    if (chestReward.type === 'gems') return 'ui_gem';
    if (chestReward.type === 'fragments') return 'ui_fragments';
    return 'ui_skins';
  };

  const handlePaidPurchase = async (productId: StoreProductId) => {
    if (purchasingId) return;
    setPurchasingId(productId);
    try {
      const result = await purchaseProduct(productId);
      if (result.status !== 'confirmed' || !result.transactionId) {
        Alert.alert(t('purchase.unavailable'), result.message || t('store.purchaseUnavailableText'));
        playSound('buttonError', game.settings.sound);
        return;
      }
      const grant = await grantPurchaseReward(productId, result.transactionId, game);
      if (grant.duplicate) {
        Alert.alert(t('store.purchaseAlreadyProcessed'), t('store.purchaseAlreadyProcessedText'));
        return;
      }
      if (grant.granted) {
        Alert.alert(t('purchase.successful'), t('ads.rewardGranted'));
        playSound('buttonConfirm', game.settings.sound);
      }
    } finally {
      setPurchasingId(null);
    }
  };

  const product = (iconKey: UiIconKey, fallback: string, title: string, subtitle: string, price: string, action: () => Promise<void>, key?: string, priceIconKey?: UiIconKey) => (
    <TouchableOpacity key={key} style={styles.product} onPress={() => setConfirm({ title, action })}>
      <View style={styles.productIcon}><UiIcon iconKey={iconKey} fallback={fallback} size={34} /></View>
      <View style={styles.productInfo}>
        <Text style={styles.productTitle}>{title}</Text>
        <Text style={styles.productSubtitle}>{subtitle}</Text>
      </View>
      <View style={styles.priceBox}>
        <Text style={styles.price}>{price}</Text>
        {priceIconKey && <UiIcon iconKey={priceIconKey} fallback="" size={16} />}
      </View>
    </TouchableOpacity>
  );

  const paidProduct = (productId: StoreProductId, iconKey: UiIconKey, fallback: string) => {
    const config = gameText.storeProduct(STORE_PRODUCTS[productId]);
    const billingProduct = billingProductMap[productId];
    const unavailable = billingLoaded && !billingProduct?.available;
    const price = unavailable ? t('common.unavailable') : billingProduct?.localizedPrice || config.fallbackPrice;
    const isBusy = purchasingId === productId;
    return (
      <TouchableOpacity
        key={productId}
        style={[styles.product, unavailable && styles.disabledProduct]}
        onPress={() => handlePaidPurchase(productId)}
        disabled={isBusy}
      >
        <View style={styles.productIcon}><UiIcon iconKey={iconKey} fallback={fallback} size={34} /></View>
        <View style={styles.productInfo}>
          <Text style={styles.productTitle}>{config.title}</Text>
          <Text style={styles.productSubtitle}>{config.description}</Text>
        </View>
        <View style={[styles.priceBox, unavailable && styles.unavailablePriceBox]}>
          <Text style={[styles.price, unavailable && styles.unavailablePrice]}>{isBusy ? '...' : price}</Text>
        </View>
      </TouchableOpacity>
    );
  };

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}><Text style={styles.backText}>← {t('common.back').toUpperCase()}</Text></TouchableOpacity>
        <Text style={styles.title}>{t('nav.shop').toUpperCase()}</Text>
        <View style={styles.wallet}>
          <View style={styles.walletItem}><UiIcon iconKey="ui_coin" fallback="💰" size={17} /><Text style={styles.walletText}>{game.coins}</Text></View>
          <View style={styles.walletItem}><UiIcon iconKey="ui_gem" fallback="💎" size={17} /><Text style={styles.walletText}>{game.gems}</Text></View>
          <View style={styles.walletItem}><UiIcon iconKey="ui_key" fallback="🔑" size={17} /><Text style={styles.walletText}>{game.keys}</Text></View>
          <View style={styles.walletItem}><UiIcon iconKey="ui_legendary_key" fallback="🗝️" size={17} /><Text style={styles.walletText}>{game.legendaryKeys}</Text></View>
        </View>
      </View>

      <View style={styles.tabs}>
        {tabs.map(item => (
          <TouchableOpacity key={item.id} style={[styles.tab, tab === item.id && styles.activeTab]} onPress={() => setTab(item.id)}>
            <Text style={[styles.tabText, tab === item.id && styles.activeTabText]}>{item.label}</Text>
          </TouchableOpacity>
        ))}
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        {tab === 'chests' && (
          <>
            <Text style={styles.sectionTitle}>{t('store.buyOpen')}</Text>
            {CHESTS.map(chest => {
              const chances = Object.entries(chest.chances).map(([r, v]) => `${gameText.rarity(r).toLowerCase()} ${Math.round((v || 0) * 100)}%`).join(' / ');
              const affordable = canPay(chest.currency, chest.cost);
              return (
                <TouchableOpacity key={chest.id} style={[styles.chestCard, { borderColor: chest.color + '99' }]} onPress={() => setConfirm({ title: gameText.chestName(chest), action: async () => {
                  const paid = await pay(chest.currency, chest.cost);
                  if (!paid) return;
                  await simulateChest(chest.id);
                  await game.recordStorePurchase();
                } })}>
                  <LinearGradient colors={[chest.color + '44', '#ffffff0f']} style={styles.chestCardGradient}>
                    <View style={styles.chestIconBox}><UiIcon iconKey={chestIcon(chest.id)} fallback={chest.icon} size={42} /></View>
                    <View style={styles.chestInfo}>
                      <Text style={styles.chestTitle}>{gameText.chestName(chest)}</Text>
                      <Text style={styles.chestSubtitle}>{gameText.chestDescription(chest)}</Text>
                      <Text style={styles.chestChances}>{chances}</Text>
                    </View>
                    <View style={[styles.chestAction, !affordable && styles.disabled]}>
                      <View style={styles.chestPriceRow}>
                        <Text style={styles.chestPrice}>{chest.cost}</Text>
                        <UiIcon iconKey={currencyIcon(chest.currency)} fallback="" size={15} />
                      </View>
                      <Text style={styles.chestActionText}>ABRIR</Text>
                    </View>
                  </LinearGradient>
                </TouchableOpacity>
              );
            })}

            <Text style={styles.sectionTitle}>{t('store.ownedChests')}</Text>
            {game.inventoryItems.filter(item => item.type === 'chest').length === 0 ? (
              <Text style={styles.emptyText}>{t('store.emptyChests')}</Text>
            ) : game.inventoryItems.filter(item => item.type === 'chest').map(item => (
              <TouchableOpacity key={item.id} style={styles.ownedChest} onPress={() => openStoredChest(item.id, getStoredChestId(item.id))}>
                <UiIcon iconKey={chestIcon(getStoredChestId(item.id))} fallback={item.icon} size={32} />
                <View style={styles.ownedInfo}>
                  <Text style={styles.ownedTitle}>{item.type === 'chest' ? gameText.chestName(getStoredChestId(item.id) as ChestDefinition['id']) : item.label}</Text>
                  <Text style={styles.ownedSubtitle}>x{item.amount} disponível</Text>
                </View>
                <Text style={styles.ownedOpen}>ABRIR</Text>
              </TouchableOpacity>
            ))}
          </>
        )}

        {tab === 'gems' && (
          <>
            {paidProduct('diamonds_small', 'ui_gem', '💎')}
            {paidProduct('diamonds_medium', 'ui_gem', '💎')}
            {paidProduct('diamonds_large', 'ui_gem', '💎')}
            {paidProduct('daily_offer', 'ui_daily_reward', '🎁')}
            <TouchableOpacity style={styles.adButton} onPress={() => setAd('gems')}><UiIcon iconKey="ui_ad" fallback="📺" size={22} /><Text style={styles.adText}>{t('store.freeGems')}</Text></TouchableOpacity>
          </>
        )}

        {tab === 'keys' && (
          <>
            {product('ui_key', '🔑', 'Pacote de chaves', '+6 chaves raras', '80', async () => { const paid = await pay('gems', 80); if (paid) { await game.updateKeys(6); await game.recordStorePurchase(); } }, 'keys_pack', 'ui_gem')}
            {product('ui_legendary_key', '🗝️', 'Chaves lendárias', '+2 chaves lendárias', '180', async () => { const paid = await pay('gems', 180); if (paid) { await game.updateLegendaryKeys(2); await game.recordStorePurchase(); } }, 'legendary_key', 'ui_gem')}
            <TouchableOpacity style={styles.adButton} onPress={() => setAd('key')}><UiIcon iconKey="ui_ad" fallback="📺" size={22} /><Text style={styles.adText}>{t('store.freeKey')}</Text></TouchableOpacity>
          </>
        )}

        {tab === 'specials' && (
          <>
            {paidProduct('starter_pack', 'ui_inventory', '🎒')}
            {paidProduct('skin_pack', 'ui_skins', '✨')}
            {paidProduct('fragment_pack', 'ui_fragments', '🧩')}
            {paidProduct('event_pack', 'ui_event', '⚡')}
            {paidProduct('chest_pack', 'ui_chest_epic', '🏆')}
          </>
        )}

        {tab === 'free' && (
          <>
            <TouchableOpacity style={styles.adButton} onPress={() => setAd('gems')}><UiIcon iconKey="ui_ad" fallback="📺" size={22} /><Text style={styles.adText}>{t('store.freeGems')}</Text></TouchableOpacity>
            <TouchableOpacity style={styles.adButton} onPress={() => setAd('coins')}><UiIcon iconKey="ui_ad" fallback="📺" size={22} /><Text style={styles.adText}>{t('store.freeCoins')}</Text></TouchableOpacity>
            <TouchableOpacity style={styles.adButton} onPress={() => setAd('chest')}><UiIcon iconKey="ui_chest_common" fallback="📦" size={22} /><Text style={styles.adText}>{t('store.freeCommonChest')}</Text></TouchableOpacity>
            <TouchableOpacity style={styles.adButton} onPress={() => setAd('key')}><UiIcon iconKey="ui_key" fallback="🔑" size={22} /><Text style={styles.adText}>{t('store.freeKey')}</Text></TouchableOpacity>
            <TouchableOpacity style={styles.adButton} onPress={() => setAd('offline')}><UiIcon iconKey="ui_ad" fallback="📺" size={22} /><Text style={styles.adText}>{t('store.doubleOffline')}</Text></TouchableOpacity>
          </>
        )}
      </ScrollView>

      <Modal visible={!!confirm} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.confirmBox}>
            <Text style={styles.confirmTitle}>{confirm?.title}</Text>
            <Text style={styles.confirmText}>Confirme para continuar.</Text>
            <TouchableOpacity style={styles.confirmButton} onPress={async () => { await confirm?.action(); setConfirm(null); }}>
              <Text style={styles.confirmButtonText}>{t('common.confirm').toUpperCase()}</Text>
            </TouchableOpacity>
            <TouchableOpacity onPress={() => setConfirm(null)}><Text style={styles.cancelText}>{t('common.cancel')}</Text></TouchableOpacity>
          </View>
        </View>
      </Modal>

      <Modal visible={!!reward} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.confirmBox}>
            <Text style={styles.confirmTitle}>{t('inventory.youReceived')}</Text>
            {reward?.skinId ? (
              <SkinIcon skin={getSkinById(reward.skinId)} size={74} style={styles.rewardSkinIcon} />
            ) : (
              <UiIcon iconKey={rewardIcon(reward)} fallback={reward?.icon || '🎁'} size={64} />
            )}
            <Text style={styles.confirmTitle}>{gameText.chestRewardLabel(reward)}</Text>
            <Text style={styles.confirmText}>{gameText.rarity(reward?.rarity)} • {reward?.type}</Text>
            {reward?.type === 'skin' && reward.skinId && (
              <TouchableOpacity style={styles.confirmButton} onPress={async () => { await game.setBallTransformation(reward.skinId!); setReward(null); }}>
                <Text style={styles.confirmButtonText}>EQUIPAR SKIN</Text>
              </TouchableOpacity>
            )}
            <TouchableOpacity onPress={() => setReward(null)}><Text style={styles.cancelText}>{t('common.close')}</Text></TouchableOpacity>
          </View>
        </View>
      </Modal>

      <AdModal
        visible={!!ad}
        onClose={() => setAd(null)}
        onRewardClaimed={handleAdReward}
        placement={adPlacement()}
        rewardType={ad === 'gems' ? 'gems' : ad === 'chest' ? 'chest' : ad === 'key' ? 'key' : ad === 'offline' ? 'double' : 'coins'}
        rewardAmount={ad === 'gems' ? 12 : ad === 'key' ? 1 : 300}
      />
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 56, paddingHorizontal: 18, paddingBottom: 12 },
  backText: { color: '#00f0ff', fontWeight: 'bold', fontSize: 16 },
  title: { color: '#00f0ff', fontSize: 30, fontWeight: 'bold', marginTop: 8 },
  wallet: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 8 },
  walletItem: { flexDirection: 'row', alignItems: 'center', gap: 5, backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#ffffff22', borderRadius: 8, paddingVertical: 5, paddingHorizontal: 8 },
  walletText: { color: '#ffffff', fontWeight: 'bold' },
  tabs: { flexDirection: 'row', paddingHorizontal: 12, gap: 6 },
  tab: { flex: 1, paddingVertical: 10, borderRadius: 8, backgroundColor: '#ffffff11', alignItems: 'center' },
  activeTab: { backgroundColor: '#00f0ff' },
  tabText: { color: '#ffffffaa', fontWeight: 'bold', fontSize: 12 },
  activeTabText: { color: '#001018' },
  content: { padding: 16, gap: 12 },
  sectionTitle: { color: '#ffffff88', fontSize: 12, fontWeight: 'bold', letterSpacing: 1.5, marginTop: 4 },
  chestCard: { borderRadius: 12, overflow: 'hidden', borderWidth: 1 },
  chestCardGradient: { flexDirection: 'row', alignItems: 'center', padding: 14, gap: 12 },
  chestIconBox: { width: 54, height: 54, borderRadius: 14, backgroundColor: '#00000033', alignItems: 'center', justifyContent: 'center' },
  chestInfo: { flex: 1 },
  chestTitle: { color: '#ffffff', fontSize: 17, fontWeight: 'bold' },
  chestSubtitle: { color: '#ffffffaa', fontSize: 12, marginTop: 3 },
  chestChances: { color: '#ffd700', fontSize: 11, marginTop: 5, fontWeight: 'bold' },
  chestAction: { minWidth: 72, alignItems: 'center', backgroundColor: '#00000033', borderRadius: 10, paddingVertical: 8, paddingHorizontal: 8 },
  chestPriceRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 4 },
  chestPrice: { color: '#ffffff', fontWeight: 'bold', fontSize: 12 },
  chestActionText: { color: '#00f0ff', fontWeight: 'bold', fontSize: 11, marginTop: 3 },
  disabled: { opacity: 0.45 },
  ownedChest: { flexDirection: 'row', alignItems: 'center', gap: 12, backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#00f0ff44', borderRadius: 12, padding: 12 },
  ownedInfo: { flex: 1 },
  ownedTitle: { color: '#ffffff', fontWeight: 'bold', fontSize: 16 },
  ownedSubtitle: { color: '#ffffff88', fontSize: 12, marginTop: 2 },
  ownedOpen: { color: '#00f0ff', fontWeight: 'bold' },
  emptyText: { color: '#ffffff88', fontSize: 13 },
  product: { flexDirection: 'row', alignItems: 'center', padding: 14, borderRadius: 10, backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#ffffff22' },
  disabledProduct: { opacity: 0.72 },
  productIcon: { width: 48, height: 48, borderRadius: 24, backgroundColor: '#ffffff18', justifyContent: 'center', alignItems: 'center', marginRight: 12 },
  productInfo: { flex: 1 },
  productTitle: { color: '#ffffff', fontSize: 17, fontWeight: 'bold' },
  productSubtitle: { color: '#ffffff99', fontSize: 12, marginTop: 4 },
  priceBox: { flexDirection: 'row', alignItems: 'center', gap: 4, marginLeft: 10 },
  price: { color: '#ffd700', fontWeight: 'bold' },
  unavailablePriceBox: { borderWidth: 1, borderColor: '#ffffff22', borderRadius: 8, paddingVertical: 5, paddingHorizontal: 8 },
  unavailablePrice: { color: '#ffffff88', fontSize: 12 },
  adButton: { padding: 16, borderRadius: 10, backgroundColor: '#00ff8833', borderWidth: 1, borderColor: '#00ff8877', flexDirection: 'row', justifyContent: 'center', alignItems: 'center', gap: 8 },
  adText: { color: '#ffffff', fontWeight: 'bold', textAlign: 'center' },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', justifyContent: 'center', alignItems: 'center' },
  confirmBox: { width: '84%', backgroundColor: '#1a0a2e', padding: 24, borderRadius: 14, alignItems: 'center', borderWidth: 1, borderColor: '#00f0ff55' },
  confirmTitle: { color: '#ffffff', fontSize: 22, fontWeight: 'bold', textAlign: 'center' },
  confirmText: { color: '#ffffffaa', textAlign: 'center', marginVertical: 16 },
  confirmButton: { width: '100%', padding: 14, borderRadius: 10, backgroundColor: '#00f0ff', alignItems: 'center' },
  confirmButtonText: { color: '#001018', fontWeight: 'bold' },
  cancelText: { color: '#ffffff99', marginTop: 14 },
  rewardSkinIcon: { marginVertical: 8 },
});

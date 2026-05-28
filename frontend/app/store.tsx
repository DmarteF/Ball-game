import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, Modal, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useGame } from '@/src/contexts/GameContext';
import { AdModal } from '@/src/components/AdModal';
import { CHESTS, ChestDefinition, ChestReward, getChestById, rollChestReward } from '@/src/game/chests';
import { getSkinRarityColor } from '@/src/game/skins';

type Tab = 'chests' | 'gems' | 'keys' | 'specials' | 'free';

export default function StoreScreen() {
  const router = useRouter();
  const game = useGame();
  const [tab, setTab] = useState<Tab>('chests');
  const [confirm, setConfirm] = useState<{ title: string; action: () => Promise<void> } | null>(null);
  const [ad, setAd] = useState<null | 'gems' | 'coins' | 'chest' | 'key' | 'offline'>(null);
  const [reward, setReward] = useState<ChestReward | null>(null);

  const tabs: { id: Tab; label: string }[] = [
    { id: 'chests', label: 'Baús' },
    { id: 'gems', label: 'Gemas' },
    { id: 'keys', label: 'Chaves' },
    { id: 'specials', label: 'Especiais' },
    { id: 'free', label: 'Grátis' },
  ];

  const simulateChest = async (chestId: string) => {
    const chest = CHESTS.find(item => item.id === chestId) || CHESTS[0];
    const chestReward = rollChestReward(chest, game.unlockedSkins);
    await game.grantChestReward(chestReward);
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
      return false;
    }
    if (currency === 'coins') await game.updateCoins(-cost);
    if (currency === 'gems') await game.updateGems(-cost);
    if (currency === 'keys') await game.updateKeys(-cost);
    if (currency === 'legendaryKeys') await game.updateLegendaryKeys(-cost);
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
    setAd(null);
  };

  const product = (icon: string, title: string, subtitle: string, price: string, action: () => Promise<void>, key?: string) => (
    <TouchableOpacity key={key} style={styles.product} onPress={() => setConfirm({ title, action })}>
      <View style={styles.productIcon}><Text style={styles.productIconText}>{icon}</Text></View>
      <View style={styles.productInfo}>
        <Text style={styles.productTitle}>{title}</Text>
        <Text style={styles.productSubtitle}>{subtitle}</Text>
      </View>
      <Text style={styles.price}>{price}</Text>
    </TouchableOpacity>
  );

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}><Text style={styles.backText}>← VOLTAR</Text></TouchableOpacity>
        <Text style={styles.title}>LOJA</Text>
        <Text style={styles.wallet}>💰 {game.coins}   💎 {game.gems}   🔑 {game.keys}   🗝️ {game.legendaryKeys}</Text>
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
            <Text style={styles.sectionTitle}>Comprar e abrir</Text>
            {CHESTS.map(chest => {
              const price = `${chest.cost} ${chest.currency === 'coins' ? '💰' : chest.currency === 'gems' ? '💎' : chest.currency === 'keys' ? '🔑' : '🗝️'}`;
              const chances = Object.entries(chest.chances).map(([r, v]) => `${r} ${Math.round((v || 0) * 100)}%`).join(' / ');
              const affordable = canPay(chest.currency, chest.cost);
              return (
                <TouchableOpacity key={chest.id} style={[styles.chestCard, { borderColor: chest.color + '99' }]} onPress={() => setConfirm({ title: chest.name, action: async () => {
                  const paid = await pay(chest.currency, chest.cost);
                  if (!paid) return;
                  await simulateChest(chest.id);
                  await game.recordStorePurchase();
                } })}>
                  <LinearGradient colors={[chest.color + '44', '#ffffff0f']} style={styles.chestCardGradient}>
                    <View style={styles.chestIconBox}><Text style={styles.chestIcon}>{chest.icon}</Text></View>
                    <View style={styles.chestInfo}>
                      <Text style={styles.chestTitle}>{chest.name}</Text>
                      <Text style={styles.chestSubtitle}>{chest.description}</Text>
                      <Text style={styles.chestChances}>{chances}</Text>
                    </View>
                    <View style={[styles.chestAction, !affordable && styles.disabled]}>
                      <Text style={styles.chestPrice}>{price}</Text>
                      <Text style={styles.chestActionText}>ABRIR</Text>
                    </View>
                  </LinearGradient>
                </TouchableOpacity>
              );
            })}

            <Text style={styles.sectionTitle}>Baús possuídos</Text>
            {game.inventoryItems.filter(item => item.type === 'chest').length === 0 ? (
              <Text style={styles.emptyText}>Baús ganhos em missões, eventos e pacotes aparecem aqui.</Text>
            ) : game.inventoryItems.filter(item => item.type === 'chest').map(item => (
              <TouchableOpacity key={item.id} style={styles.ownedChest} onPress={() => openStoredChest(item.id, getStoredChestId(item.id))}>
                <Text style={styles.ownedIcon}>{item.icon}</Text>
                <View style={styles.ownedInfo}>
                  <Text style={styles.ownedTitle}>{item.label}</Text>
                  <Text style={styles.ownedSubtitle}>x{item.amount} disponível</Text>
                </View>
                <Text style={styles.ownedOpen}>ABRIR</Text>
              </TouchableOpacity>
            ))}
          </>
        )}

        {tab === 'gems' && (
          <>
            {product('💎', 'Pacote pequeno', '+80 gemas simuladas', 'Fake', async () => { await game.updateGems(80); await game.recordStorePurchase(); }, 'gems_small')}
            {product('💎', 'Pacote médio', '+260 gemas simuladas', 'Fake', async () => { await game.updateGems(260); await game.recordStorePurchase(); }, 'gems_medium')}
            {product('💎', 'Pacote grande', '+700 gemas simuladas', 'Fake', async () => { await game.updateGems(700); await game.recordStorePurchase(); }, 'gems_large')}
            {product('🎁', 'Oferta diária', '+35 gemas e 1 chave', 'Fake', async () => { await game.updateGems(35); await game.updateKeys(1); await game.recordStorePurchase(); }, 'daily_offer')}
            <TouchableOpacity style={styles.adButton} onPress={() => setAd('gems')}><Text style={styles.adText}>📺 Gemas grátis</Text></TouchableOpacity>
          </>
        )}

        {tab === 'keys' && (
          <>
            {product('🔑', 'Pacote de chaves', '+3 chaves raras', '80 💎', async () => { const paid = await pay('gems', 80); if (paid) { await game.updateKeys(3); await game.recordStorePurchase(); } }, 'keys_pack')}
            {product('🗝️', 'Chave lendária', '+1 chave lendária', '180 💎', async () => { const paid = await pay('gems', 180); if (paid) { await game.updateLegendaryKeys(1); await game.recordStorePurchase(); } }, 'legendary_key')}
            <TouchableOpacity style={styles.adButton} onPress={() => setAd('key')}><Text style={styles.adText}>📺 Ganhar chave</Text></TouchableOpacity>
          </>
        )}

        {tab === 'specials' && (
          <>
            {product('🎒', 'Starter Pack', 'Gemas, moedas e 2 chaves', 'Fake', async () => { await game.updateGems(120); await game.updateCoins(800); await game.updateKeys(2); await game.recordStorePurchase(); }, 'starter_pack')}
            {product('✨', 'Pacote de skins', 'Abre 3 baús raros simulados', 'Fake', async () => { await simulateChest('rare'); await simulateChest('rare'); await simulateChest('rare'); await game.recordStorePurchase(); }, 'skin_pack')}
            {product('🧩', 'Pacote de fragmentos', '+55 fragmentos da skin equipada', 'Fake', async () => { await game.grantReward({ type: 'fragments', amount: 55 }); await game.recordStorePurchase(); }, 'fragment_pack')}
            {product('⚡', 'Pacote de evento', 'Baú raro, gemas e XP', 'Fake', async () => { await game.grantReward({ type: 'chest', chestType: 'rare', amount: 1 }); await game.updateGems(25); await game.addProfileXp(140); await game.recordStorePurchase(); }, 'event_pack')}
            {product('🎁', 'Pacote de baús', '2 comuns e 1 épico simulados', 'Fake', async () => { await simulateChest('common'); await simulateChest('common'); await simulateChest('epic'); await game.recordStorePurchase(); }, 'chest_pack')}
            {product('🚫', 'No Ads', 'Marcador fake para versão futura', 'Fake', async () => game.saveProgress(), 'no_ads')}
          </>
        )}

        {tab === 'free' && (
          <>
            <TouchableOpacity style={styles.adButton} onPress={() => setAd('gems')}><Text style={styles.adText}>📺 Ganhar gemas</Text></TouchableOpacity>
            <TouchableOpacity style={styles.adButton} onPress={() => setAd('coins')}><Text style={styles.adText}>📺 Ganhar moedas</Text></TouchableOpacity>
            <TouchableOpacity style={styles.adButton} onPress={() => setAd('chest')}><Text style={styles.adText}>📺 Ganhar baú comum</Text></TouchableOpacity>
            <TouchableOpacity style={styles.adButton} onPress={() => setAd('key')}><Text style={styles.adText}>📺 Ganhar chave</Text></TouchableOpacity>
            <TouchableOpacity style={styles.adButton} onPress={() => setAd('offline')}><Text style={styles.adText}>📺 Dobrar recompensa offline</Text></TouchableOpacity>
          </>
        )}
      </ScrollView>

      <Modal visible={!!confirm} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.confirmBox}>
            <Text style={styles.confirmTitle}>{confirm?.title}</Text>
            <Text style={styles.confirmText}>Compra simulada. Nenhum pagamento real será feito.</Text>
            <TouchableOpacity style={styles.confirmButton} onPress={async () => { await confirm?.action(); setConfirm(null); }}>
              <Text style={styles.confirmButtonText}>CONFIRMAR</Text>
            </TouchableOpacity>
            <TouchableOpacity onPress={() => setConfirm(null)}><Text style={styles.cancelText}>Cancelar</Text></TouchableOpacity>
          </View>
        </View>
      </Modal>

      <Modal visible={!!reward} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.confirmBox}>
            <Text style={styles.confirmTitle}>Item recebido</Text>
            <Text style={[styles.rewardIcon, { color: reward ? getSkinRarityColor(reward.rarity) : '#ffffff' }]}>{reward?.icon}</Text>
            <Text style={styles.confirmTitle}>{reward?.label}</Text>
            <Text style={styles.confirmText}>{reward?.rarity.toUpperCase()} • {reward?.type}</Text>
            {reward?.type === 'skin' && reward.skinId && (
              <TouchableOpacity style={styles.confirmButton} onPress={async () => { await game.setBallTransformation(reward.skinId!); setReward(null); }}>
                <Text style={styles.confirmButtonText}>EQUIPAR SKIN</Text>
              </TouchableOpacity>
            )}
            <TouchableOpacity onPress={() => setReward(null)}><Text style={styles.cancelText}>Fechar</Text></TouchableOpacity>
          </View>
        </View>
      </Modal>

      <AdModal visible={!!ad} onClose={() => setAd(null)} onRewardClaimed={handleAdReward} rewardType={ad === 'gems' ? 'gems' : ad === 'chest' ? 'chest' : ad === 'key' ? 'key' : 'coins'} rewardAmount={ad === 'gems' ? 12 : ad === 'key' ? 1 : 300} />
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 56, paddingHorizontal: 18, paddingBottom: 12 },
  backText: { color: '#00f0ff', fontWeight: 'bold', fontSize: 16 },
  title: { color: '#00f0ff', fontSize: 30, fontWeight: 'bold', marginTop: 8 },
  wallet: { color: '#ffffff', fontWeight: 'bold', marginTop: 8 },
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
  chestIcon: { fontSize: 32 },
  chestInfo: { flex: 1 },
  chestTitle: { color: '#ffffff', fontSize: 17, fontWeight: 'bold' },
  chestSubtitle: { color: '#ffffffaa', fontSize: 12, marginTop: 3 },
  chestChances: { color: '#ffd700', fontSize: 11, marginTop: 5, fontWeight: 'bold' },
  chestAction: { minWidth: 72, alignItems: 'center', backgroundColor: '#00000033', borderRadius: 10, paddingVertical: 8, paddingHorizontal: 8 },
  chestPrice: { color: '#ffffff', fontWeight: 'bold', fontSize: 12 },
  chestActionText: { color: '#00f0ff', fontWeight: 'bold', fontSize: 11, marginTop: 3 },
  disabled: { opacity: 0.45 },
  ownedChest: { flexDirection: 'row', alignItems: 'center', gap: 12, backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#00f0ff44', borderRadius: 12, padding: 12 },
  ownedIcon: { fontSize: 30 },
  ownedInfo: { flex: 1 },
  ownedTitle: { color: '#ffffff', fontWeight: 'bold', fontSize: 16 },
  ownedSubtitle: { color: '#ffffff88', fontSize: 12, marginTop: 2 },
  ownedOpen: { color: '#00f0ff', fontWeight: 'bold' },
  emptyText: { color: '#ffffff88', fontSize: 13 },
  product: { flexDirection: 'row', alignItems: 'center', padding: 14, borderRadius: 10, backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#ffffff22' },
  productIcon: { width: 48, height: 48, borderRadius: 24, backgroundColor: '#ffffff18', justifyContent: 'center', alignItems: 'center', marginRight: 12 },
  productIconText: { fontSize: 26 },
  productInfo: { flex: 1 },
  productTitle: { color: '#ffffff', fontSize: 17, fontWeight: 'bold' },
  productSubtitle: { color: '#ffffff99', fontSize: 12, marginTop: 4 },
  price: { color: '#ffd700', fontWeight: 'bold', marginLeft: 10 },
  adButton: { padding: 16, borderRadius: 10, backgroundColor: '#00ff8833', borderWidth: 1, borderColor: '#00ff8877' },
  adText: { color: '#ffffff', fontWeight: 'bold', textAlign: 'center' },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', justifyContent: 'center', alignItems: 'center' },
  confirmBox: { width: '84%', backgroundColor: '#1a0a2e', padding: 24, borderRadius: 14, alignItems: 'center', borderWidth: 1, borderColor: '#00f0ff55' },
  confirmTitle: { color: '#ffffff', fontSize: 22, fontWeight: 'bold', textAlign: 'center' },
  confirmText: { color: '#ffffffaa', textAlign: 'center', marginVertical: 16 },
  confirmButton: { width: '100%', padding: 14, borderRadius: 10, backgroundColor: '#00f0ff', alignItems: 'center' },
  confirmButtonText: { color: '#001018', fontWeight: 'bold' },
  cancelText: { color: '#ffffff99', marginTop: 14 },
  rewardIcon: { fontSize: 58, marginVertical: 8 },
});

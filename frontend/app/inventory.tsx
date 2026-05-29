import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, Modal, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useGame } from '@/src/contexts/GameContext';
import { AdModal } from '@/src/components/AdModal';
import { CHESTS, ChestDefinition, ChestReward, getChestById, rollChestReward } from '@/src/game/chests';
import { getSkinById } from '@/src/game/skins';
import { playSound } from '@/src/utils/audio';
import { triggerHaptic } from '@/src/utils/feedback';
import { UiIcon } from '@/src/components/UiIcon';
import { SkinIcon } from '@/src/components/SkinIcon';
import { UiIconKey } from '@/src/game/uiIcons';
import { useGameText } from '@/src/i18n/gameText';
import { useTranslation } from '@/src/i18n';

export default function InventoryScreen() {
  const router = useRouter();
  const game = useGame();
  const gameText = useGameText();
  const { t } = useTranslation();
  const [showReward, setShowReward] = useState(false);
  const [showAd, setShowAd] = useState(false);
  const [currentReward, setCurrentReward] = useState<ChestReward | null>(null);
  const [opening, setOpening] = useState(false);

  const canAfford = (chest: ChestDefinition) => {
    const wallet = chest.currency === 'coins' ? game.coins : chest.currency === 'gems' ? game.gems : chest.currency === 'keys' ? game.keys : game.legendaryKeys;
    return wallet >= chest.cost;
  };

  const payChest = async (chest: ChestDefinition) => {
    if (chest.currency === 'coins') await game.updateCoins(-chest.cost);
    if (chest.currency === 'gems') await game.updateGems(-chest.cost);
    if (chest.currency === 'keys') await game.updateKeys(-chest.cost);
    if (chest.currency === 'legendaryKeys') await game.updateLegendaryKeys(-chest.cost);
  };

  const openChest = async (chest: ChestDefinition, free = false) => {
    if (!free && !canAfford(chest)) {
      playSound('buttonError', game.settings.sound);
      Alert.alert('Recursos insuficientes', `Você não tem o suficiente para abrir ${gameText.chestName(chest)}.`);
      return;
    }

    playSound('buttonConfirm', game.settings.sound);
    if (!free) await payChest(chest);
    setOpening(true);
    setTimeout(async () => {
      const reward = rollChestReward(chest, game.unlockedSkins);
      await game.grantChestReward(reward);
      playSound('chestOpen', game.settings.sound);
      if (reward.rarity === 'legendary' || reward.rarity === 'ultimate' || reward.rarity === 'mythic') playSound('legendaryDrop', game.settings.sound);
      else if (reward.rarity === 'rare' || reward.rarity === 'epic') playSound('rareDrop', game.settings.sound);
      triggerHaptic(chest.id === 'common' ? 'hit' : 'rareChest', game.settings.haptics);
      setCurrentReward(reward);
      setOpening(false);
      setShowReward(true);
    }, 650);
  };

  const openStoredChest = async (itemId: string, chestId: string) => {
    const chest = getChestById(chestId as ChestDefinition['id']);
    await game.saveProgress({
      inventoryItems: game.inventoryItems
        .map(item => item.id === itemId ? { ...item, amount: item.amount - 1 } : item)
        .filter(item => item.amount > 0),
    });
    await openChest(chest, true);
  };

  const getStoredChestId = (itemId: string) => {
    if (itemId.startsWith('boss_chest_')) return itemId.replace('boss_chest_', '');
    return itemId.replace('chest_', '');
  };

  const handleFreeChestReward = async () => {
    const allowed = await game.recordAdUse('inventory_free_chest');
    if (!allowed) {
      setShowAd(false);
      return;
    }
    await openChest(CHESTS[0], true);
  };

  const currencyIcon = (currency: string): UiIconKey =>
    currency === 'coins' ? 'ui_coin' : currency === 'gems' ? 'ui_gem' : currency === 'keys' ? 'ui_key' : 'ui_legendary_key';

  const chestIcon = (id: string): UiIconKey =>
    id === 'rare' ? 'ui_chest_rare' : id === 'epic' ? 'ui_chest_epic' : id === 'legendary' ? 'ui_chest_legendary' : 'ui_chest_common';

  const inventoryIcon = (item: { type: string; id: string }): UiIconKey => {
    if (item.type === 'chest') return chestIcon(getStoredChestId(item.id));
    if (item.type === 'trail') return 'ui_trail';
    if (item.type === 'aura') return 'ui_aura';
    if (item.type === 'effect') return 'ui_effect';
    if (item.type === 'key') return 'ui_key';
    if (item.type === 'coins') return 'ui_coin';
    if (item.type === 'gems') return 'ui_gem';
    if (item.type === 'fragments') return 'ui_fragments';
    return 'ui_inventory';
  };

  const equipRewardSkin = async () => {
    if (currentReward?.skinId && currentReward.type === 'skin') {
      await game.setBallTransformation(currentReward.skinId);
      playSound('buttonConfirm', game.settings.sound);
      setShowReward(false);
    }
  };

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
          <Text style={styles.backText}>← {t('common.back').toUpperCase()}</Text>
        </TouchableOpacity>
        <Text style={styles.title}>{t('inventory.title').toUpperCase()}</Text>
        <View style={styles.statsRow}>
          <View style={styles.statBadge}><UiIcon iconKey="ui_coin" fallback="💰" size={17} /><Text style={styles.statBadgeText}>{game.coins}</Text></View>
          <View style={styles.statBadge}><UiIcon iconKey="ui_gem" fallback="💎" size={17} /><Text style={styles.statBadgeText}>{game.gems}</Text></View>
          <View style={styles.statBadge}><UiIcon iconKey="ui_key" fallback="🔑" size={17} /><Text style={styles.statBadgeText}>{game.keys}</Text></View>
          <View style={styles.statBadge}><UiIcon iconKey="ui_legendary_key" fallback="🗝️" size={17} /><Text style={styles.statBadgeText}>{game.legendaryKeys}</Text></View>
        </View>
      </View>

      <ScrollView style={styles.scrollView} contentContainerStyle={styles.content}>
        <TouchableOpacity style={styles.freeChestButton} onPress={() => setShowAd(true)}>
          <LinearGradient colors={['#ffd700', '#ff8800']} style={styles.freeChestGradient}>
            <UiIcon iconKey="ui_daily_reward" fallback="🎁" size={48} />
            <View style={styles.freeChestInfo}>
              <Text style={styles.freeChestTitle}>{t('shop.freeChest').toUpperCase()}</Text>
              <Text style={styles.freeChestSubtitle}>{t('inventory.freeChestSubtitle')}</Text>
            </View>
            <UiIcon iconKey="ui_ad" fallback="📺" size={30} />
          </LinearGradient>
        </TouchableOpacity>

        <Text style={styles.sectionTitle}>{t('stats.chests').toUpperCase()}</Text>
        {CHESTS.map(chest => (
          <TouchableOpacity key={chest.id} style={styles.chestCard} onPress={() => openChest(chest)} disabled={opening || !canAfford(chest)}>
            <LinearGradient colors={[chest.color + '66', chest.color + '22']} style={[styles.chestGradient, !canAfford(chest) && styles.disabled]}>
              <UiIcon iconKey={opening ? 'ui_effect' : chestIcon(chest.id)} fallback={opening ? '✨' : chest.icon} size={44} />
              <View style={styles.chestInfo}>
                <Text style={styles.chestName}>{gameText.chestName(chest)}</Text>
                <Text style={styles.chestRewards}>{gameText.chestDescription(chest)}</Text>
                <Text style={styles.chestRewards}>Chances: {Object.entries(chest.chances).map(([r, v]) => `${gameText.rarity(r).toLowerCase()} ${Math.round((v || 0) * 100)}%`).join(' • ')}</Text>
              </View>
              <View style={styles.priceTag}>
                <Text style={styles.priceText}>{chest.cost}</Text>
                <UiIcon iconKey={currencyIcon(chest.currency)} fallback="" size={15} />
              </View>
            </LinearGradient>
          </TouchableOpacity>
        ))}

        <Text style={styles.sectionTitle}>{t('inventory.items').toUpperCase()}</Text>
        {game.inventoryItems.length === 0 ? (
          <Text style={styles.emptyText}>{t('inventory.emptyItems')}</Text>
        ) : game.inventoryItems.map(item => (
          <TouchableOpacity
            key={item.id}
            style={styles.itemRow}
            disabled={item.type !== 'chest' || opening}
            onPress={() => openStoredChest(item.id, getStoredChestId(item.id))}
          >
            <UiIcon iconKey={inventoryIcon(item)} fallback={item.icon} size={24} />
            <Text style={styles.itemText}>{item.type === 'chest' ? gameText.chestName(getStoredChestId(item.id) as ChestDefinition['id']) : item.label}</Text>
            <Text style={styles.itemAmount}>{item.type === 'chest' ? 'ABRIR ' : ''}x{item.amount}</Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      <Modal visible={showReward} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.rewardModal}>
            <LinearGradient colors={['#1a0a2e', '#16003b']} style={styles.modalContent}>
              <Text style={styles.rewardTitle}>{t('inventory.revealed').toUpperCase()}</Text>
              {currentReward?.skinId ? (
                <SkinIcon skin={getSkinById(currentReward.skinId)} size={82} style={styles.rewardSkinIcon} />
              ) : (
                <UiIcon iconKey={inventoryIcon({ type: currentReward?.type || 'effect', id: currentReward?.type || 'effect' })} fallback={currentReward?.icon || '🎁'} size={66} />
              )}
              <Text style={styles.rewardValue}>{gameText.chestRewardLabel(currentReward)}</Text>
              <Text style={styles.rewardSubtitle}>{currentReward?.isDuplicate ? `Duplicate: +${currentReward.amount} fragments` : currentReward?.type}</Text>
              {currentReward?.type === 'skin' && (
                <TouchableOpacity style={styles.claimButton} onPress={equipRewardSkin}>
                  <LinearGradient colors={['#00ff88', '#00aa66']} style={styles.claimGradient}>
                    <Text style={styles.claimText}>{t('inventory.equip').toUpperCase()}</Text>
                  </LinearGradient>
                </TouchableOpacity>
              )}
              <TouchableOpacity style={styles.claimButton} onPress={() => { playSound('buttonClick', game.settings.sound); setShowReward(false); }}>
                <LinearGradient colors={['#00f0ff', '#0088ff']} style={styles.claimGradient}>
                  <Text style={styles.claimText}>{t('common.collect').toUpperCase()}</Text>
                </LinearGradient>
              </TouchableOpacity>
            </LinearGradient>
          </View>
        </View>
      </Modal>

      <AdModal visible={showAd} onClose={() => setShowAd(false)} onRewardClaimed={handleFreeChestReward} placement="freeChest" rewardType="chest" rewardAmount={1} />
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 56, paddingHorizontal: 16, paddingBottom: 12 },
  backButton: { marginBottom: 8 },
  backText: { color: '#00f0ff', fontSize: 16, fontWeight: 'bold' },
  title: { fontSize: 25, fontWeight: 'bold', color: '#00f0ff', marginBottom: 12 },
  statsRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  statBadge: { flexDirection: 'row', alignItems: 'center', gap: 5, backgroundColor: '#ffffff16', paddingVertical: 7, paddingHorizontal: 10, borderRadius: 8, overflow: 'hidden' },
  statBadgeText: { color: '#ffffff', fontWeight: 'bold' },
  scrollView: { flex: 1 },
  content: { padding: 16, gap: 12 },
  freeChestButton: { height: 86, borderRadius: 12, overflow: 'hidden', marginBottom: 10 },
  freeChestGradient: { flex: 1, flexDirection: 'row', alignItems: 'center', paddingHorizontal: 18, gap: 14 },
  freeChestInfo: { flex: 1 },
  freeChestTitle: { fontSize: 18, fontWeight: 'bold', color: '#000' },
  freeChestSubtitle: { fontSize: 12, color: '#000000aa', marginTop: 4 },
  sectionTitle: { fontSize: 13, fontWeight: 'bold', color: '#ffffff88', letterSpacing: 2, marginTop: 8 },
  chestCard: { minHeight: 108, borderRadius: 12, overflow: 'hidden' },
  chestGradient: { flex: 1, flexDirection: 'row', alignItems: 'center', padding: 14, borderWidth: 1, borderColor: '#ffffff24', gap: 12 },
  disabled: { opacity: 0.5 },
  chestInfo: { flex: 1 },
  chestName: { fontSize: 18, fontWeight: 'bold', color: '#ffffff', marginBottom: 3 },
  chestRewards: { fontSize: 12, color: '#ffffffaa' },
  priceTag: { flexDirection: 'row', alignItems: 'center', gap: 4, backgroundColor: '#00000033', paddingVertical: 8, paddingHorizontal: 10, borderRadius: 8 },
  priceText: { color: '#ffffff', fontWeight: 'bold' },
  itemRow: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#ffffff11', padding: 12, borderRadius: 10, gap: 10 },
  itemText: { flex: 1, color: '#ffffff', fontWeight: 'bold' },
  itemAmount: { color: '#00f0ff', fontWeight: 'bold' },
  emptyText: { color: '#ffffff88', fontSize: 14 },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', justifyContent: 'center', alignItems: 'center' },
  rewardModal: { width: '84%', maxWidth: 400, borderRadius: 16, overflow: 'hidden' },
  modalContent: { padding: 26, alignItems: 'center', gap: 10 },
  rewardTitle: { fontSize: 24, fontWeight: 'bold', color: '#ffd700' },
  rewardSkinIcon: { marginVertical: 4 },
  rewardValue: { fontSize: 22, color: '#ffffff', fontWeight: 'bold', textAlign: 'center' },
  rewardSubtitle: { fontSize: 14, color: '#ffffffaa', marginBottom: 8 },
  claimButton: { width: '100%', height: 50, borderRadius: 10, overflow: 'hidden', marginTop: 8 },
  claimGradient: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  claimText: { fontSize: 16, fontWeight: 'bold', color: '#ffffff' },
});

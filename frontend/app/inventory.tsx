import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, Modal, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useGame } from '@/src/contexts/GameContext';
import { AdModal } from '@/src/components/AdModal';
import { CHESTS, ChestDefinition, ChestReward, getChestById, rollChestReward } from '@/src/game/chests';
import { getSkinRarityColor } from '@/src/game/skins';
import { playSound } from '@/src/utils/audio';
import { triggerHaptic } from '@/src/utils/feedback';

export default function InventoryScreen() {
  const router = useRouter();
  const game = useGame();
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
      Alert.alert('Recursos insuficientes', `Você não tem o suficiente para abrir ${chest.name}.`);
      return;
    }

    if (!free) await payChest(chest);
    setOpening(true);
    setTimeout(async () => {
      const reward = rollChestReward(chest, game.unlockedSkins);
      await game.grantChestReward(reward);
      playSound(chest.id === 'common' ? 'chestOpen' : 'rareDrop', game.settings.sound);
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
    await openChest(CHESTS[0], true);
  };

  const equipRewardSkin = async () => {
    if (currentReward?.skinId && currentReward.type === 'skin') {
      await game.setBallTransformation(currentReward.skinId);
      setShowReward(false);
    }
  };

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
          <Text style={styles.backText}>← VOLTAR</Text>
        </TouchableOpacity>
        <Text style={styles.title}>BAÚS & INVENTÁRIO</Text>
        <View style={styles.statsRow}>
          <Text style={styles.statBadge}>💰 {game.coins}</Text>
          <Text style={styles.statBadge}>💎 {game.gems}</Text>
          <Text style={styles.statBadge}>🔑 {game.keys}</Text>
          <Text style={styles.statBadge}>🗝️ {game.legendaryKeys}</Text>
        </View>
      </View>

      <ScrollView style={styles.scrollView} contentContainerStyle={styles.content}>
        <TouchableOpacity style={styles.freeChestButton} onPress={() => setShowAd(true)}>
          <LinearGradient colors={['#ffd700', '#ff8800']} style={styles.freeChestGradient}>
            <Text style={styles.freeChestIcon}>🎁</Text>
            <View style={styles.freeChestInfo}>
              <Text style={styles.freeChestTitle}>BAÚ GRÁTIS</Text>
              <Text style={styles.freeChestSubtitle}>Anúncio simulado</Text>
            </View>
            <Text style={styles.freeChestArrow}>📺</Text>
          </LinearGradient>
        </TouchableOpacity>

        <Text style={styles.sectionTitle}>BAÚS</Text>
        {CHESTS.map(chest => (
          <TouchableOpacity key={chest.id} style={styles.chestCard} onPress={() => openChest(chest)} disabled={opening || !canAfford(chest)}>
            <LinearGradient colors={[chest.color + '66', chest.color + '22']} style={[styles.chestGradient, !canAfford(chest) && styles.disabled]}>
              <Text style={styles.chestIcon}>{opening ? '✨' : chest.icon}</Text>
              <View style={styles.chestInfo}>
                <Text style={styles.chestName}>{chest.name}</Text>
                <Text style={styles.chestRewards}>{chest.description}</Text>
                <Text style={styles.chestRewards}>Chances: {Object.entries(chest.chances).map(([r, v]) => `${r} ${Math.round((v || 0) * 100)}%`).join(' • ')}</Text>
              </View>
              <View style={styles.priceTag}>
                <Text style={styles.priceText}>{chest.cost} {chest.currency === 'coins' ? '💰' : chest.currency === 'gems' ? '💎' : chest.currency === 'keys' ? '🔑' : '🗝️'}</Text>
              </View>
            </LinearGradient>
          </TouchableOpacity>
        ))}

        <Text style={styles.sectionTitle}>ITENS</Text>
        {game.inventoryItems.length === 0 ? (
          <Text style={styles.emptyText}>Trails, auras e efeitos aparecerão aqui.</Text>
        ) : game.inventoryItems.map(item => (
          <TouchableOpacity
            key={item.id}
            style={styles.itemRow}
            disabled={item.type !== 'chest' || opening}
            onPress={() => openStoredChest(item.id, getStoredChestId(item.id))}
          >
            <Text style={styles.itemIcon}>{item.icon}</Text>
            <Text style={styles.itemText}>{item.label}</Text>
            <Text style={styles.itemAmount}>{item.type === 'chest' ? 'ABRIR ' : ''}x{item.amount}</Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      <Modal visible={showReward} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.rewardModal}>
            <LinearGradient colors={['#1a0a2e', '#16003b']} style={styles.modalContent}>
              <Text style={styles.rewardTitle}>REVELADO</Text>
              <Text style={[styles.rewardIcon, { color: currentReward ? getSkinRarityColor(currentReward.rarity) : '#fff' }]}>{currentReward?.icon}</Text>
              <Text style={styles.rewardValue}>{currentReward?.label}</Text>
              <Text style={styles.rewardSubtitle}>{currentReward?.isDuplicate ? `Repetida: +${currentReward.amount} fragmentos` : currentReward?.type}</Text>
              {currentReward?.type === 'skin' && (
                <TouchableOpacity style={styles.claimButton} onPress={equipRewardSkin}>
                  <LinearGradient colors={['#00ff88', '#00aa66']} style={styles.claimGradient}>
                    <Text style={styles.claimText}>EQUIPAR</Text>
                  </LinearGradient>
                </TouchableOpacity>
              )}
              <TouchableOpacity style={styles.claimButton} onPress={() => setShowReward(false)}>
                <LinearGradient colors={['#00f0ff', '#0088ff']} style={styles.claimGradient}>
                  <Text style={styles.claimText}>COLETAR</Text>
                </LinearGradient>
              </TouchableOpacity>
            </LinearGradient>
          </View>
        </View>
      </Modal>

      <AdModal visible={showAd} onClose={() => setShowAd(false)} onRewardClaimed={handleFreeChestReward} rewardType="coins" rewardAmount={1} />
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
  statBadge: { color: '#ffffff', backgroundColor: '#ffffff16', paddingVertical: 7, paddingHorizontal: 10, borderRadius: 8, overflow: 'hidden', fontWeight: 'bold' },
  scrollView: { flex: 1 },
  content: { padding: 16, gap: 12 },
  freeChestButton: { height: 86, borderRadius: 12, overflow: 'hidden', marginBottom: 10 },
  freeChestGradient: { flex: 1, flexDirection: 'row', alignItems: 'center', paddingHorizontal: 18, gap: 14 },
  freeChestIcon: { fontSize: 44 },
  freeChestInfo: { flex: 1 },
  freeChestTitle: { fontSize: 18, fontWeight: 'bold', color: '#000' },
  freeChestSubtitle: { fontSize: 12, color: '#000000aa', marginTop: 4 },
  freeChestArrow: { fontSize: 28 },
  sectionTitle: { fontSize: 13, fontWeight: 'bold', color: '#ffffff88', letterSpacing: 2, marginTop: 8 },
  chestCard: { minHeight: 108, borderRadius: 12, overflow: 'hidden' },
  chestGradient: { flex: 1, flexDirection: 'row', alignItems: 'center', padding: 14, borderWidth: 1, borderColor: '#ffffff24', gap: 12 },
  disabled: { opacity: 0.5 },
  chestIcon: { fontSize: 42 },
  chestInfo: { flex: 1 },
  chestName: { fontSize: 18, fontWeight: 'bold', color: '#ffffff', marginBottom: 3 },
  chestRewards: { fontSize: 12, color: '#ffffffaa' },
  priceTag: { backgroundColor: '#00000033', paddingVertical: 8, paddingHorizontal: 10, borderRadius: 8 },
  priceText: { color: '#ffffff', fontWeight: 'bold' },
  itemRow: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#ffffff11', padding: 12, borderRadius: 10, gap: 10 },
  itemIcon: { fontSize: 22 },
  itemText: { flex: 1, color: '#ffffff', fontWeight: 'bold' },
  itemAmount: { color: '#00f0ff', fontWeight: 'bold' },
  emptyText: { color: '#ffffff88', fontSize: 14 },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', justifyContent: 'center', alignItems: 'center' },
  rewardModal: { width: '84%', maxWidth: 400, borderRadius: 16, overflow: 'hidden' },
  modalContent: { padding: 26, alignItems: 'center', gap: 10 },
  rewardTitle: { fontSize: 24, fontWeight: 'bold', color: '#ffd700' },
  rewardIcon: { fontSize: 64 },
  rewardValue: { fontSize: 22, color: '#ffffff', fontWeight: 'bold', textAlign: 'center' },
  rewardSubtitle: { fontSize: 14, color: '#ffffffaa', marginBottom: 8 },
  claimButton: { width: '100%', height: 50, borderRadius: 10, overflow: 'hidden', marginTop: 8 },
  claimGradient: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  claimText: { fontSize: 16, fontWeight: 'bold', color: '#ffffff' },
});

import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, Modal } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useGame } from '@/src/contexts/GameContext';
import { AdModal } from '@/src/components/AdModal';

const CHESTS = [
  {
    id: 'common',
    name: 'Baú Comum',
    icon: '📦',
    cost: 100,
    currency: 'coins',
    rewards: { coinsMin: 50, coinsMax: 200, gemsMin: 0, gemsMax: 5 },
    color: '#888888',
  },
  {
    id: 'rare',
    name: 'Baú Raro',
    icon: '💼',
    cost: 500,
    currency: 'coins',
    rewards: { coinsMin: 300, coinsMax: 800, gemsMin: 5, gemsMax: 20 },
    color: '#0088ff',
  },
  {
    id: 'epic',
    name: 'Baú Épico',
    icon: '🏆',
    cost: 100,
    currency: 'gems',
    rewards: { coinsMin: 1000, coinsMax: 3000, gemsMin: 50, gemsMax: 100 },
    color: '#b000ff',
  },
  {
    id: 'legendary',
    name: 'Baú Lendário',
    icon: '💎',
    cost: 500,
    currency: 'gems',
    rewards: { coinsMin: 5000, coinsMax: 15000, gemsMin: 200, gemsMax: 500 },
    color: '#ffd700',
  },
];

export default function InventoryScreen() {
  const router = useRouter();
  const { coins, gems, updateCoins, updateGems } = useGame();
  const [showReward, setShowReward] = useState(false);
  const [showAd, setShowAd] = useState(false);
  const [currentReward, setCurrentReward] = useState({ coins: 0, gems: 0, chestName: '' });

  const openChest = async (chest: any) => {
    const playerCurrency = chest.currency === 'coins' ? coins : gems;
    
    if (playerCurrency < chest.cost) return;

    if (chest.currency === 'coins') {
      await updateCoins(-chest.cost);
    } else {
      await updateGems(-chest.cost);
    }

    const earnedCoins = Math.floor(
      Math.random() * (chest.rewards.coinsMax - chest.rewards.coinsMin) + chest.rewards.coinsMin
    );
    const earnedGems = Math.floor(
      Math.random() * (chest.rewards.gemsMax - chest.rewards.gemsMin) + chest.rewards.gemsMin
    );

    await updateCoins(earnedCoins);
    await updateGems(earnedGems);

    setCurrentReward({ coins: earnedCoins, gems: earnedGems, chestName: chest.name });
    setShowReward(true);
  };

  const handleFreeChestReward = async () => {
    const earnedCoins = Math.floor(Math.random() * 500) + 100;
    const earnedGems = Math.floor(Math.random() * 20) + 5;
    
    await updateCoins(earnedCoins);
    await updateGems(earnedGems);
    
    setCurrentReward({ coins: earnedCoins, gems: earnedGems, chestName: 'Baú Grátis' });
    setShowReward(true);
  };

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
          <Text style={styles.backText}>← VOLTAR</Text>
        </TouchableOpacity>
        <Text style={styles.title}>BAÚS & RECOMPENSAS</Text>
        
        <View style={styles.statsRow}>
          <View style={styles.statBadge}>
            <Text>💰</Text>
            <Text style={styles.statText}>{coins}</Text>
          </View>
          <View style={styles.statBadge}>
            <Text>💎</Text>
            <Text style={styles.statText}>{gems}</Text>
          </View>
        </View>
      </View>

      <ScrollView style={styles.scrollView} contentContainerStyle={styles.content}>
        <TouchableOpacity style={styles.freeChestButton} onPress={() => setShowAd(true)}>
          <LinearGradient colors={['#ffd700', '#ff8800']} style={styles.freeChestGradient}>
            <Text style={styles.freeChestIcon}>🎁</Text>
            <View style={styles.freeChestInfo}>
              <Text style={styles.freeChestTitle}>BAÚ GRÁTIS</Text>
              <Text style={styles.freeChestSubtitle}>Assista um anúncio</Text>
            </View>
            <Text style={styles.freeChestArrow}>📺</Text>
          </LinearGradient>
        </TouchableOpacity>

        <Text style={styles.sectionTitle}>COMPRAR BAÚS</Text>

        {CHESTS.map((chest) => {
          const playerCurrency = chest.currency === 'coins' ? coins : gems;
          const canAfford = playerCurrency >= chest.cost;
          
          return (
            <TouchableOpacity
              key={chest.id}
              style={styles.chestCard}
              onPress={() => openChest(chest)}
              disabled={!canAfford}
            >
              <LinearGradient
                colors={[chest.color + '66', chest.color + '22']}
                style={[styles.chestGradient, !canAfford && styles.disabled]}
              >
                <Text style={styles.chestIcon}>{chest.icon}</Text>
                <View style={styles.chestInfo}>
                  <Text style={styles.chestName}>{chest.name}</Text>
                  <Text style={styles.chestRewards}>💰 {chest.rewards.coinsMin}-{chest.rewards.coinsMax}</Text>
                  <Text style={styles.chestRewards}>💎 {chest.rewards.gemsMin}-{chest.rewards.gemsMax}</Text>
                </View>
                <View style={[styles.priceTag, { backgroundColor: chest.color + '44' }]}>
                  <Text style={styles.priceIcon}>{chest.currency === 'coins' ? '💰' : '💎'}</Text>
                  <Text style={styles.priceText}>{chest.cost}</Text>
                </View>
              </LinearGradient>
            </TouchableOpacity>
          );
        })}
      </ScrollView>

      {showReward && (
        <Modal visible transparent animationType="fade">
          <View style={styles.modalOverlay}>
            <View style={styles.rewardModal}>
              <LinearGradient colors={['#1a0a2e', '#16003b']} style={styles.modalContent}>
                <Text style={styles.rewardTitle}>🎉 {currentReward.chestName}</Text>
                <Text style={styles.rewardSubtitle}>Você recebeu:</Text>
                
                <View style={styles.rewardsContainer}>
                  {currentReward.coins > 0 && (
                    <View style={styles.rewardItem}>
                      <Text style={styles.rewardIcon}>💰</Text>
                      <Text style={styles.rewardValue}>+{currentReward.coins}</Text>
                    </View>
                  )}
                  {currentReward.gems > 0 && (
                    <View style={styles.rewardItem}>
                      <Text style={styles.rewardIcon}>💎</Text>
                      <Text style={styles.rewardValue}>+{currentReward.gems}</Text>
                    </View>
                  )}
                </View>

                <TouchableOpacity style={styles.claimButton} onPress={() => setShowReward(false)}>
                  <LinearGradient colors={['#00f0ff', '#0088ff']} style={styles.claimGradient}>
                    <Text style={styles.claimText}>COLETAR</Text>
                  </LinearGradient>
                </TouchableOpacity>
              </LinearGradient>
            </View>
          </View>
        </Modal>
      )}

      <AdModal
        visible={showAd}
        onClose={() => setShowAd(false)}
        onRewardClaimed={handleFreeChestReward}
        rewardType="coins"
        rewardAmount={300}
      />
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 60, paddingHorizontal: 20, paddingBottom: 16 },
  backButton: { marginBottom: 10 },
  backText: { color: '#00f0ff', fontSize: 16, fontWeight: 'bold' },
  title: {
    fontSize: 26,
    fontWeight: 'bold',
    color: '#00f0ff',
    textShadowColor: '#00f0ff',
    textShadowOffset: { width: 0, height: 0 },
    textShadowRadius: 10,
    marginBottom: 16,
  },
  statsRow: { flexDirection: 'row', gap: 12 },
  statBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#ffffff11',
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#ffffff22',
    gap: 6,
  },
  statText: { fontSize: 14, fontWeight: 'bold', color: '#ffffff' },
  scrollView: { flex: 1 },
  content: { padding: 20, gap: 12 },
  freeChestButton: { height: 90, borderRadius: 16, overflow: 'hidden', marginBottom: 16 },
  freeChestGradient: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    gap: 16,
  },
  freeChestIcon: { fontSize: 48 },
  freeChestInfo: { flex: 1 },
  freeChestTitle: { fontSize: 18, fontWeight: 'bold', color: '#000000', letterSpacing: 2 },
  freeChestSubtitle: { fontSize: 12, color: '#000000aa', marginTop: 4 },
  freeChestArrow: { fontSize: 32 },
  sectionTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#ffffff88',
    letterSpacing: 2,
    marginBottom: 8,
  },
  chestCard: { height: 100, borderRadius: 16, overflow: 'hidden' },
  chestGradient: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    borderWidth: 2,
    borderColor: '#ffffff22',
    gap: 16,
  },
  disabled: { opacity: 0.5 },
  chestIcon: { fontSize: 48 },
  chestInfo: { flex: 1 },
  chestName: { fontSize: 18, fontWeight: 'bold', color: '#ffffff', marginBottom: 4 },
  chestRewards: { fontSize: 12, color: '#ffffffaa' },
  priceTag: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 8,
    gap: 6,
  },
  priceIcon: { fontSize: 16 },
  priceText: { fontSize: 16, fontWeight: 'bold', color: '#ffffff' },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', justifyContent: 'center', alignItems: 'center' },
  rewardModal: { width: '80%', maxWidth: 400, borderRadius: 20, overflow: 'hidden' },
  modalContent: { padding: 30, alignItems: 'center' },
  rewardTitle: { fontSize: 26, fontWeight: 'bold', color: '#ffd700', textAlign: 'center', marginBottom: 8 },
  rewardSubtitle: { fontSize: 16, color: '#ffffffaa', marginBottom: 24 },
  rewardsContainer: { flexDirection: 'row', gap: 20, marginBottom: 30, flexWrap: 'wrap', justifyContent: 'center' },
  rewardItem: { alignItems: 'center', backgroundColor: '#ffffff11', padding: 16, borderRadius: 12, minWidth: 100 },
  rewardIcon: { fontSize: 36, marginBottom: 8 },
  rewardValue: { fontSize: 20, fontWeight: 'bold', color: '#ffffff' },
  claimButton: { width: '100%', height: 60, borderRadius: 12, overflow: 'hidden' },
  claimGradient: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  claimText: { fontSize: 20, fontWeight: 'bold', color: '#ffffff', letterSpacing: 2 },
});

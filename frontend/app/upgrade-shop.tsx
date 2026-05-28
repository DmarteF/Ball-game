import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useGame } from '@/src/contexts/GameContext';

const UPGRADES = [
  { id: 'baseDamage', name: 'Dano Base', description: '+10% dano por nível', icon: '⚔️', baseCost: 100 },
  { id: 'baseSpeed', name: 'Velocidade', description: '+8% velocidade por nível', icon: '⚡', baseCost: 120 },
  { id: 'critChance', name: 'Chance Crítica', description: '+2% crítico por nível', icon: '💥', baseCost: 150 },
  { id: 'coinMultiplier', name: 'Multiplicador de Moedas', description: '+15% moedas por nível', icon: '💰', baseCost: 200 },
  { id: 'xpBoost', name: 'XP Boost', description: '+20% XP por nível', icon: '⭐', baseCost: 180 },
  { id: 'startingCoins', name: 'Moedas Iniciais', description: '+50 moedas iniciais', icon: '🪙', baseCost: 250 },
];

export default function UpgradeShopScreen() {
  const router = useRouter();
  const { coins, permanentUpgrades, purchaseUpgrade } = useGame();

  const getUpgradeCost = (upgrade: any) => {
    const level = permanentUpgrades[upgrade.id] || 0;
    return Math.floor(upgrade.baseCost * Math.pow(1.5, level));
  };

  const handlePurchase = async (upgrade: any) => {
    const cost = getUpgradeCost(upgrade);
    const success = await purchaseUpgrade(upgrade.id, cost);
    
    if (!success) {
      Alert.alert(
        'Moedas Insuficientes',
        `Você precisa de ${cost} moedas para comprar este upgrade.`,
        [{ text: 'OK' }]
      );
    }
  };

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
          <Text style={styles.backText}>← VOLTAR</Text>
        </TouchableOpacity>
        <Text style={styles.title}>UPGRADES PERMANENTES</Text>
        <View style={styles.coinsDisplay}>
          <Text style={styles.coinsText}>💰 {coins}</Text>
        </View>
      </View>

      <ScrollView style={styles.scrollView} contentContainerStyle={styles.upgradeList}>
        {UPGRADES.map((upgrade) => {
          const level = permanentUpgrades[upgrade.id] || 0;
          const cost = getUpgradeCost(upgrade);
          const canAfford = coins >= cost;

          return (
            <View key={upgrade.id} style={styles.upgradeCard}>
              <LinearGradient
                colors={['#ffffff22', '#ffffff11']}
                style={styles.cardGradient}
              >
                <View style={styles.upgradeIcon}>
                  <Text style={styles.iconText}>{upgrade.icon}</Text>
                </View>
                
                <View style={styles.upgradeInfo}>
                  <Text style={styles.upgradeName}>{upgrade.name}</Text>
                  <Text style={styles.upgradeDescription}>{upgrade.description}</Text>
                  <Text style={styles.upgradeLevel}>Nível: {level}</Text>
                </View>
                
                <TouchableOpacity
                  style={[styles.buyButton, !canAfford && styles.buyButtonDisabled]}
                  onPress={() => handlePurchase(upgrade)}
                  disabled={!canAfford}
                >
                  <LinearGradient
                    colors={canAfford ? ['#00f0ff', '#0088ff'] : ['#666666', '#444444']}
                    style={styles.buyButtonGradient}
                  >
                    <Text style={styles.buyButtonText}>{cost}</Text>
                    <Text style={styles.buyButtonIcon}>💰</Text>
                  </LinearGradient>
                </TouchableOpacity>
              </LinearGradient>
            </View>
          );
        })}
      </ScrollView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    paddingTop: 60,
    paddingHorizontal: 20,
    paddingBottom: 20,
  },
  backButton: {
    marginBottom: 10,
  },
  backText: {
    color: '#00f0ff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#00f0ff',
    textShadowColor: '#00f0ff',
    textShadowOffset: { width: 0, height: 0 },
    textShadowRadius: 10,
    marginBottom: 16,
  },
  coinsDisplay: {
    backgroundColor: '#ffffff22',
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 12,
    alignSelf: 'flex-start',
    borderWidth: 2,
    borderColor: '#ffd70044',
  },
  coinsText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#ffd700',
  },
  scrollView: {
    flex: 1,
  },
  upgradeList: {
    padding: 20,
    gap: 16,
  },
  upgradeCard: {
    borderRadius: 16,
    overflow: 'hidden',
  },
  cardGradient: {
    flexDirection: 'row',
    padding: 16,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#ffffff22',
  },
  upgradeIcon: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: '#ffffff22',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  iconText: {
    fontSize: 32,
  },
  upgradeInfo: {
    flex: 1,
  },
  upgradeName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#ffffff',
    marginBottom: 4,
  },
  upgradeDescription: {
    fontSize: 14,
    color: '#ffffffaa',
    marginBottom: 4,
  },
  upgradeLevel: {
    fontSize: 12,
    color: '#00f0ff',
    fontWeight: 'bold',
  },
  buyButton: {
    borderRadius: 12,
    overflow: 'hidden',
  },
  buyButtonDisabled: {
    opacity: 0.5,
  },
  buyButtonGradient: {
    paddingVertical: 12,
    paddingHorizontal: 20,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  buyButtonText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#ffffff',
  },
  buyButtonIcon: {
    fontSize: 16,
  },
});

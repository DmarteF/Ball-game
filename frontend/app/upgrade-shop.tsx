import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useGame } from '@/src/contexts/GameContext';
import { UPGRADES as RUN_UPGRADES } from '@/src/game/upgrades';

type ShopUpgrade = { id: string; name: string; description: string; icon: string; baseCost: number; unlockText: string; secret?: boolean };

const UPGRADES: ShopUpgrade[] = [
  { id: 'baseDamage', name: 'Damage', description: '+10% dano por nível', icon: '⚔️', baseCost: 100, unlockText: 'Disponível desde o início' },
  { id: 'baseSpeed', name: 'Speed', description: '+8% velocidade por nível', icon: '⚡', baseCost: 120, unlockText: 'Disponível desde o início' },
  { id: 'coinMultiplier', name: 'Cash Gain', description: '+15% moedas por nível', icon: '💰', baseCost: 200, unlockText: 'Disponível desde o início' },
  { id: 'critChance', name: 'Crit Chance', description: '+2% crítico por nível', icon: '💥', baseCost: 150, unlockText: 'Disponível desde o início' },
  { id: 'xpBoost', name: 'XP Boost', description: '+20% XP por nível', icon: '⭐', baseCost: 180, unlockText: 'Desbloqueia ao alcançar a fase 3' },
  { id: 'perfectChance', name: 'Perfect Chance', description: '+1% chance de diamante no perfect', icon: '💎', baseCost: 450, unlockText: 'Desbloqueia por baús raros ou fase 5' },
  { id: 'slowRings', name: 'Slow Rings', description: 'Anéis fecham mais devagar', icon: '🌀', baseCost: 600, unlockText: 'Desbloqueia por rank ou recompensas especiais' },
];

export default function UpgradeShopScreen() {
  const router = useRouter();
  const { coins, permanentUpgrades, unlockedUpgrades, purchaseUpgrade } = useGame();

  const secretUpgrades = RUN_UPGRADES
    .filter(item => item.secret)
    .map(item => ({
      id: item.id,
      name: item.name,
      description: item.description,
      icon: item.icon,
      baseCost: 0,
      unlockText: item.secretCondition || 'Conquista secreta',
      secret: true,
    }));
  const allUpgrades = [...UPGRADES, ...secretUpgrades];

  const getUpgradeCost = (upgrade: ShopUpgrade) => {
    if (upgrade.secret) return 0;
    const level = permanentUpgrades[upgrade.id] || 0;
    return Math.floor(upgrade.baseCost * Math.pow(1.5, level));
  };

  const handlePurchase = async (upgrade: ShopUpgrade) => {
    const cost = getUpgradeCost(upgrade);
    if (!unlockedUpgrades.includes(upgrade.id)) {
      Alert.alert(upgrade.secret ? '???' : 'Upgrade bloqueado', upgrade.unlockText, [{ text: 'OK' }]);
      return;
    }
    if (upgrade.secret) {
      Alert.alert(upgrade.name, 'Upgrade secreto liberado. Ele pode aparecer nas escolhas de level up durante a partida.', [{ text: 'OK' }]);
      return;
    }
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
        {allUpgrades.map((upgrade) => {
          const level = permanentUpgrades[upgrade.id] || 0;
          const cost = getUpgradeCost(upgrade);
          const isUnlocked = unlockedUpgrades.includes(upgrade.id);
          const canAfford = coins >= cost && isUnlocked && !upgrade.secret;

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
                  <Text style={styles.upgradeName}>{upgrade.secret && !isUnlocked ? '???' : upgrade.name}</Text>
                  <Text style={styles.upgradeDescription}>{isUnlocked ? upgrade.description : `🔒 ${upgrade.unlockText}`}</Text>
                  <Text style={styles.upgradeLevel}>{upgrade.secret ? (isUnlocked ? 'Secreto liberado' : 'Upgrade secreto') : `Nível: ${level}`}</Text>
                </View>
                
                <TouchableOpacity
                  style={[styles.buyButton, !canAfford && styles.buyButtonDisabled]}
                  onPress={() => handlePurchase(upgrade)}
                  disabled={!canAfford && !upgrade.secret}
                >
                  <LinearGradient
                    colors={canAfford ? ['#00f0ff', '#0088ff'] : upgrade.secret && isUnlocked ? ['#ffd700', '#ff8800'] : ['#666666', '#444444']}
                    style={styles.buyButtonGradient}
                  >
                    <Text style={styles.buyButtonText}>{upgrade.secret ? (isUnlocked ? 'OK' : '🔒') : isUnlocked ? cost : '🔒'}</Text>
                    {isUnlocked && !upgrade.secret && <Text style={styles.buyButtonIcon}>💰</Text>}
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

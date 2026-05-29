import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useGame } from '@/src/contexts/GameContext';
import { UPGRADES as RUN_UPGRADES } from '@/src/game/upgrades';
import { PERMANENT_UPGRADE_LIMITS } from '@/src/game/balance';
import { playSound } from '@/src/utils/audio';
import { UiIcon } from '@/src/components/UiIcon';
import { UpgradeIcon } from '@/src/components/UpgradeIcon';

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
  const { coins, permanentUpgrades, unlockedUpgrades, purchaseUpgrade, settings } = useGame();

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

  const getUpgradeValue = (upgradeId: string, level: number) => {
    switch (upgradeId) {
      case 'baseDamage':
        return `${(10 * Math.pow(1.1, level)).toFixed(1)} dano`;
      case 'baseSpeed':
        return `${(100 * Math.pow(1.08, level)).toFixed(0)} vel.`;
      case 'coinMultiplier':
        return `${(1 + level * 0.15).toFixed(2)}x moedas`;
      case 'critChance':
        return `${5 + level * 2}% crit.`;
      case 'xpBoost':
        return `${(1 + level * 0.2).toFixed(2)}x XP`;
      case 'perfectChance':
        return `${level}% perfect`;
      case 'slowRings':
        return `${Math.min(24, level * 1.8).toFixed(1)}% lento`;
      default:
        return `Lv.${level}`;
    }
  };

  const handlePurchase = async (upgrade: ShopUpgrade) => {
    const cost = getUpgradeCost(upgrade);
    const level = permanentUpgrades[upgrade.id] || 0;
    const maxLevel = PERMANENT_UPGRADE_LIMITS[upgrade.id] ?? 10;
    if (!unlockedUpgrades.includes(upgrade.id)) {
      playSound('buttonError', settings.sound);
      Alert.alert(upgrade.secret ? '???' : 'Upgrade bloqueado', upgrade.unlockText, [{ text: 'OK' }]);
      return;
    }
    if (upgrade.secret) {
      Alert.alert(upgrade.name, 'Upgrade secreto liberado. Ele pode aparecer nas escolhas de level up durante a partida.', [{ text: 'OK' }]);
      return;
    }
    if (level >= maxLevel) {
      Alert.alert('Máximo', `${upgrade.name} já está no nível máximo.`);
      return;
    }
    const success = await purchaseUpgrade(upgrade.id, cost);
    
    if (!success) {
      playSound('buttonError', settings.sound);
      Alert.alert(
        'Moedas Insuficientes',
        `Você precisa de ${cost} moedas para comprar este upgrade.`,
        [{ text: 'OK' }]
      );
    } else playSound('buttonConfirm', settings.sound);
  };

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
          <Text style={styles.backText}>← VOLTAR</Text>
        </TouchableOpacity>
        <Text style={styles.title}>UPGRADES PERMANENTES</Text>
        <View style={styles.coinsDisplay}>
          <UiIcon iconKey="ui_coin" fallback="💰" size={24} />
          <Text style={styles.coinsText}>{coins}</Text>
        </View>
      </View>

      <ScrollView style={styles.scrollView} contentContainerStyle={styles.upgradeList}>
        {allUpgrades.map((upgrade) => {
          const level = permanentUpgrades[upgrade.id] || 0;
          const maxLevel = PERMANENT_UPGRADE_LIMITS[upgrade.id] ?? 10;
          const cost = getUpgradeCost(upgrade);
          const isUnlocked = unlockedUpgrades.includes(upgrade.id);
          const isMaxed = !upgrade.secret && level >= maxLevel;
          const canAfford = coins >= cost && isUnlocked && !upgrade.secret && !isMaxed;

          return (
            <View key={upgrade.id} style={styles.upgradeCard}>
              <LinearGradient
                colors={['#ffffff22', '#ffffff11']}
                style={styles.cardGradient}
              >
                <View style={styles.upgradeIcon}>
                  <UpgradeIcon upgrade={upgrade.id} fallback={upgrade.icon} size={34} />
                </View>
                
                <View style={styles.upgradeInfo}>
                  <Text style={styles.upgradeName}>{upgrade.secret && !isUnlocked ? '???' : upgrade.name}</Text>
                  {isUnlocked ? (
                    <Text style={styles.upgradeDescription}>{upgrade.description}</Text>
                  ) : (
                    <View style={styles.lockedDescription}>
                      <UiIcon iconKey="ui_locked" fallback="🔒" size={14} />
                      <Text style={styles.upgradeDescription}>{upgrade.unlockText}</Text>
                    </View>
                  )}
                  <Text style={styles.upgradeLevel}>{upgrade.secret ? (isUnlocked ? 'Secreto liberado' : 'Upgrade secreto') : `Nível: ${level}/${maxLevel}`}</Text>
                  {!upgrade.secret && isUnlocked && (
                    <Text style={styles.nextEffect}>
                      {isMaxed ? `Atual: ${getUpgradeValue(upgrade.id, level)} • MAX` : `Atual: ${getUpgradeValue(upgrade.id, level)} • Próx: ${getUpgradeValue(upgrade.id, level + 1)}`}
                    </Text>
                  )}
                </View>
                
                <TouchableOpacity
                  style={[styles.buyButton, !canAfford && styles.buyButtonDisabled]}
                  onPress={() => handlePurchase(upgrade)}
                  disabled={!isUnlocked && !upgrade.secret}
                >
                  <LinearGradient
                    colors={canAfford ? ['#00f0ff', '#0088ff'] : upgrade.secret && isUnlocked ? ['#ffd700', '#ff8800'] : isMaxed ? ['#00ff88', '#008855'] : ['#666666', '#444444']}
                    style={styles.buyButtonGradient}
                  >
                    {upgrade.secret && !isUnlocked ? (
                      <UiIcon iconKey="ui_locked" fallback="🔒" size={16} />
                    ) : !isUnlocked ? (
                      <UiIcon iconKey="ui_locked" fallback="🔒" size={16} />
                    ) : (
                      <Text style={styles.buyButtonText}>{upgrade.secret ? 'OK' : isMaxed ? 'MAX' : cost}</Text>
                    )}
                    {isUnlocked && !upgrade.secret && !isMaxed && <UiIcon iconKey="ui_coin" fallback="💰" size={16} />}
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
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
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
    flexShrink: 1,
  },
  lockedDescription: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 5,
    marginBottom: 4,
  },
  upgradeLevel: {
    fontSize: 12,
    color: '#00f0ff',
    fontWeight: 'bold',
  },
  nextEffect: {
    fontSize: 11,
    color: '#ffffff88',
    marginTop: 2,
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
});

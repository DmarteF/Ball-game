import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useGame } from '@/src/contexts/GameContext';
import { UiIcon } from '@/src/components/UiIcon';
import { UiIconKey } from '@/src/game/uiIcons';

export default function StatsScreen() {
  const router = useRouter();
  const { coins, gems, stats, unlockedPhases, permanentUpgrades, ballTransformation } = useGame();

  const totalUpgrades = Object.values(permanentUpgrades).reduce((sum, level) => sum + level, 0);

  const statItems = [
    { label: 'Dano Base', value: stats.baseDamage.toFixed(1), icon: 'ui_damage', fallback: '⚔️', color: '#ff0055' },
    { label: 'Velocidade', value: stats.baseSpeed.toFixed(1), icon: 'ui_speed', fallback: '⚡', color: '#ffd700' },
    { label: 'Chance Crítica', value: `${stats.critChance.toFixed(1)}%`, icon: 'ui_crit', fallback: '💥', color: '#ff8800' },
    { label: 'Multiplicador Crítico', value: `${stats.critMultiplier}x`, icon: 'ui_crit', fallback: '✨', color: '#b000ff' },
    { label: 'Multiplicador de Moedas', value: `${stats.coinMultiplier.toFixed(2)}x`, icon: 'ui_coin', fallback: '💰', color: '#ffd700' },
    { label: 'Multiplicador de XP', value: `${stats.xpMultiplier.toFixed(2)}x`, icon: 'ui_xp', fallback: '⭐', color: '#00f0ff' },
  ];

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
          <Text style={styles.backText}>← VOLTAR</Text>
        </TouchableOpacity>
        <Text style={styles.title}>ESTATÍSTICAS</Text>
      </View>

      <ScrollView style={styles.scrollView} contentContainerStyle={styles.content}>
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>RECURSOS</Text>
          <View style={styles.row}>
            <View style={styles.currencyCard}>
              <UiIcon iconKey="ui_coin" fallback="💰" size={40} style={styles.currencyIcon} />
              <Text style={styles.currencyLabel}>Moedas</Text>
              <Text style={styles.currencyValue}>{coins}</Text>
            </View>
            <View style={styles.currencyCard}>
              <UiIcon iconKey="ui_gem" fallback="💎" size={40} style={styles.currencyIcon} />
              <Text style={styles.currencyLabel}>Gemas</Text>
              <Text style={styles.currencyValue}>{gems}</Text>
            </View>
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>ATRIBUTOS DA BOLINHA</Text>
          {statItems.map((item, index) => (
            <View key={index} style={styles.statCard}>
              <LinearGradient colors={[item.color + '33', item.color + '11']} style={styles.statGradient}>
                <UiIcon iconKey={item.icon as UiIconKey} fallback={item.fallback} size={32} />
                <View style={styles.statInfo}>
                  <Text style={styles.statLabel}>{item.label}</Text>
                  <Text style={[styles.statValue, { color: item.color }]}>{item.value}</Text>
                </View>
              </LinearGradient>
            </View>
          ))}
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>PROGRESSO</Text>
          <View style={styles.progressCard}>
            <LinearGradient colors={['#ffffff22', '#ffffff11']} style={styles.progressGradient}>
              <View style={styles.progressItem}>
                <Text style={styles.progressIcon}>🗺️</Text>
                <View style={styles.progressInfo}>
                  <Text style={styles.progressLabel}>Fases Desbloqueadas</Text>
                  <Text style={styles.progressValue}>{unlockedPhases.length} / 5</Text>
                </View>
              </View>
              
              <View style={styles.progressItem}>
                <Text style={styles.progressIcon}>⬆️</Text>
                <View style={styles.progressInfo}>
                  <Text style={styles.progressLabel}>Upgrades Comprados</Text>
                  <Text style={styles.progressValue}>{totalUpgrades}</Text>
                </View>
              </View>
              
              <View style={styles.progressItem}>
                <Text style={styles.progressIcon}>✨</Text>
                <View style={styles.progressInfo}>
                  <Text style={styles.progressLabel}>Skin Atual</Text>
                  <Text style={styles.progressValue}>{ballTransformation.replace('_', ' ').toUpperCase()}</Text>
                </View>
              </View>
            </LinearGradient>
          </View>
        </View>
      </ScrollView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 60, paddingHorizontal: 20, paddingBottom: 20 },
  backButton: { marginBottom: 10 },
  backText: { color: '#00f0ff', fontSize: 16, fontWeight: 'bold' },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#00f0ff',
    textShadowColor: '#00f0ff',
    textShadowOffset: { width: 0, height: 0 },
    textShadowRadius: 10,
  },
  scrollView: { flex: 1 },
  content: { padding: 20, gap: 24 },
  section: { gap: 12 },
  sectionTitle: { fontSize: 14, fontWeight: 'bold', color: '#ffffff88', letterSpacing: 2 },
  row: { flexDirection: 'row', gap: 12 },
  currencyCard: {
    flex: 1,
    backgroundColor: '#ffffff11',
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#ffffff22',
  },
  currencyIcon: { marginBottom: 8 },
  currencyLabel: { fontSize: 12, color: '#ffffffaa', marginBottom: 4 },
  currencyValue: { fontSize: 24, fontWeight: 'bold', color: '#00f0ff' },
  statCard: { borderRadius: 12, overflow: 'hidden' },
  statGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderWidth: 1,
    borderColor: '#ffffff22',
    gap: 16,
  },
  statIcon: { fontSize: 32 },
  statInfo: { flex: 1 },
  statLabel: { fontSize: 14, color: '#ffffffaa', marginBottom: 4 },
  statValue: { fontSize: 20, fontWeight: 'bold' },
  progressCard: { borderRadius: 12, overflow: 'hidden' },
  progressGradient: { padding: 16, borderWidth: 1, borderColor: '#ffffff22', gap: 16 },
  progressItem: { flexDirection: 'row', alignItems: 'center', gap: 16 },
  progressIcon: { fontSize: 32 },
  progressInfo: { flex: 1 },
  progressLabel: { fontSize: 14, color: '#ffffffaa', marginBottom: 4 },
  progressValue: { fontSize: 18, fontWeight: 'bold', color: '#00f0ff' },
});

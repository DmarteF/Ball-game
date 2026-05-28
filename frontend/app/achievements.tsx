import React, { useState } from 'react';
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { ACHIEVEMENTS, AchievementCategory } from '@/src/game/achievements';
import { useGame } from '@/src/contexts/GameContext';
import { getSkinRarityColor } from '@/src/game/skins';

const CATEGORIES: ('todas' | AchievementCategory)[] = ['todas', 'progresso', 'combate', 'coleção', 'economia', 'baús', 'skins', 'perfect escape', 'boss', 'liga', 'especiais'];

const rewardLabel = (reward: typeof ACHIEVEMENTS[number]['reward']) => {
  if (reward.type === 'coins') return `💰 ${reward.amount}`;
  if (reward.type === 'gems') return `💎 ${reward.amount}`;
  if (reward.type === 'keys') return `🔑 ${reward.amount}`;
  if (reward.type === 'legendaryKeys') return `🗝️ ${reward.amount}`;
  if (reward.type === 'chest') return `🎁 Baú ${reward.chestType}`;
  if (reward.type === 'fragments') return `🧩 ${reward.amount}`;
  if (reward.type === 'skin') return '🌟 Skin Ultimate';
  return `XP ${reward.amount}`;
};

export default function AchievementsScreen() {
  const router = useRouter();
  const game = useGame();
  const [category, setCategory] = useState<typeof CATEGORIES[number]>('todas');
  const completed = Object.values(game.achievements).filter(item => item.completed).length;
  const pending = Object.values(game.achievements).filter(item => item.completed && !item.claimed).length;
  const champion = game.achievements.stage_20_champion || { progress: 0, completed: false, claimed: false };
  const filtered = ACHIEVEMENTS.filter(item => category === 'todas' || item.category === category);

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}><Text style={styles.backText}>← VOLTAR</Text></TouchableOpacity>
        <Text style={styles.title}>CONQUISTAS</Text>
        <Text style={styles.counter}>{completed}/{ACHIEVEMENTS.length} concluídas • {pending} pendentes</Text>
        <View style={styles.specialBox}>
          <Text style={styles.specialTitle}>Campeão dos 50 Estágios</Text>
          <View style={styles.specialBar}>
            <View style={[styles.specialFill, { width: `${Math.min(100, (champion.progress / 50) * 100)}%` }]} />
            <Text style={styles.specialText}>{champion.progress}/50</Text>
          </View>
        </View>
      </View>

      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.filters}>
        {CATEGORIES.map(item => (
          <TouchableOpacity key={item} style={[styles.filter, category === item && styles.filterActive]} onPress={() => setCategory(item)}>
            <Text style={[styles.filterText, category === item && styles.filterTextActive]}>{item.toUpperCase()}</Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      <ScrollView contentContainerStyle={styles.list}>
        {filtered.map(achievement => {
          const state = game.achievements[achievement.id] || { progress: 0, completed: false, claimed: false };
          const progress = Math.min(100, (state.progress / achievement.required) * 100);
          const color = achievement.rarity === 'special' ? '#ffffff' : getSkinRarityColor(achievement.rarity);
          const hidden = achievement.rarity === 'ultimate' && !state.completed;
          return (
            <View key={achievement.id} style={[styles.card, { borderColor: color + '88' }]}>
              <View style={styles.cardHeader}>
                <View style={styles.cardTitleBox}>
                  <Text style={styles.name}>{hidden ? '???' : achievement.name}</Text>
                  <Text style={[styles.category, { color }]}>{achievement.category.toUpperCase()}</Text>
                </View>
                <Text style={styles.reward}>{rewardLabel(achievement.reward)}</Text>
              </View>
              <Text style={styles.description}>{hidden ? 'Conquista oculta. Continue avançando para revelar.' : achievement.description}</Text>
              <View style={styles.progressBar}>
                <View style={[styles.progressFill, { width: `${progress}%`, backgroundColor: color }]} />
                <Text style={styles.progressText}>{state.progress}/{achievement.required}</Text>
              </View>
              <View style={styles.footer}>
                <Text style={styles.status}>{state.claimed ? 'Coletada' : state.completed ? 'Disponível' : 'Em progresso'}</Text>
                {state.completed && !state.claimed && (
                  <TouchableOpacity style={styles.claimButton} onPress={() => game.collectAchievementReward(achievement.id)}>
                    <Text style={styles.claimText}>COLETAR</Text>
                  </TouchableOpacity>
                )}
              </View>
            </View>
          );
        })}
      </ScrollView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 56, paddingHorizontal: 18, paddingBottom: 12 },
  backText: { color: '#00f0ff', fontWeight: 'bold', fontSize: 16 },
  title: { color: '#00f0ff', fontSize: 30, fontWeight: 'bold', marginTop: 8 },
  counter: { color: '#ffffffaa', fontWeight: 'bold', marginTop: 4 },
  specialBox: { marginTop: 12, backgroundColor: '#ffffff12', borderRadius: 12, borderWidth: 1, borderColor: '#ffd70066', padding: 10 },
  specialTitle: { color: '#ffd700', fontWeight: 'bold', marginBottom: 6 },
  specialBar: { height: 20, backgroundColor: '#00000055', borderRadius: 10, overflow: 'hidden', justifyContent: 'center' },
  specialFill: { position: 'absolute', left: 0, top: 0, bottom: 0, backgroundColor: '#ffd700' },
  specialText: { color: '#ffffff', textAlign: 'center', fontSize: 12, fontWeight: 'bold' },
  filters: { paddingHorizontal: 16, gap: 8, paddingBottom: 12 },
  filter: { height: 34, paddingHorizontal: 12, borderRadius: 17, backgroundColor: '#ffffff12', justifyContent: 'center', borderWidth: 1, borderColor: '#ffffff22' },
  filterActive: { backgroundColor: '#00f0ff', borderColor: '#00f0ff' },
  filterText: { color: '#ffffffaa', fontSize: 11, fontWeight: 'bold' },
  filterTextActive: { color: '#001018' },
  list: { padding: 16, gap: 12 },
  card: { backgroundColor: '#ffffff12', borderWidth: 1, borderRadius: 12, padding: 14 },
  cardHeader: { flexDirection: 'row', alignItems: 'flex-start', gap: 10 },
  cardTitleBox: { flex: 1 },
  name: { color: '#ffffff', fontSize: 18, fontWeight: 'bold' },
  category: { fontSize: 11, fontWeight: 'bold', marginTop: 2 },
  reward: { color: '#ffd700', fontWeight: 'bold' },
  description: { color: '#ffffffbb', fontSize: 13, marginTop: 8 },
  progressBar: { height: 20, backgroundColor: '#00000055', borderRadius: 10, overflow: 'hidden', justifyContent: 'center', marginTop: 12 },
  progressFill: { position: 'absolute', left: 0, top: 0, bottom: 0 },
  progressText: { color: '#ffffff', fontSize: 12, fontWeight: 'bold', textAlign: 'center' },
  footer: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 10 },
  status: { color: '#ffffff88', fontSize: 12, fontWeight: 'bold' },
  claimButton: { backgroundColor: '#00ff88', paddingVertical: 8, paddingHorizontal: 14, borderRadius: 8 },
  claimText: { color: '#001018', fontWeight: 'bold', fontSize: 12 },
});

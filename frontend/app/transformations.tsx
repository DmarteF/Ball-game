import React, { useState } from 'react';
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useGame } from '@/src/contexts/GameContext';
import { HIDDEN_RARITIES, SKINS, SkinRarity, getSkinEvolutionCost, getSkinRarityColor } from '@/src/game/skins';
import { playSound } from '@/src/utils/audio';

type Filter = 'all' | SkinRarity | 'owned' | 'locked';

const FILTERS: { id: Filter; label: string }[] = [
  { id: 'all', label: 'Todas' },
  { id: 'common', label: 'Comuns' },
  { id: 'rare', label: 'Raras' },
  { id: 'epic', label: 'Épicas' },
  { id: 'legendary', label: 'Lendárias' },
  { id: 'ultimate', label: 'Ultimate' },
  { id: 'owned', label: 'Obtidas' },
  { id: 'locked', label: 'Bloqueadas' },
];

const RARITIES: SkinRarity[] = ['common', 'rare', 'epic', 'legendary', 'ultimate'];
const RARITY_ORDER: Record<SkinRarity, number> = { common: 0, rare: 1, epic: 2, legendary: 3, mythic: 4, ultimate: 5 };

export default function TransformationsScreen() {
  const router = useRouter();
  const game = useGame();
  const [filter, setFilter] = useState<Filter>('all');

  const visibleSkins = SKINS.filter(skin => {
    const owned = game.unlockedSkins.includes(skin.id);
    if (filter === 'owned') return owned;
    if (filter === 'locked') return !owned;
    if (filter === 'all') return true;
    return skin.rarity === filter;
  }).sort((a, b) => {
    const aOwned = game.unlockedSkins.includes(a.id);
    const bOwned = game.unlockedSkins.includes(b.id);
    const aEquipped = game.ballTransformation === a.id;
    const bEquipped = game.ballTransformation === b.id;
    const aHidden = !aOwned && HIDDEN_RARITIES.includes(a.rarity);
    const bHidden = !bOwned && HIDDEN_RARITIES.includes(b.rarity);
    if (aEquipped !== bEquipped) return aEquipped ? -1 : 1;
    if (aOwned !== bOwned) return aOwned ? -1 : 1;
    if (RARITY_ORDER[a.rarity] !== RARITY_ORDER[b.rarity]) return RARITY_ORDER[a.rarity] - RARITY_ORDER[b.rarity];
    if (aHidden !== bHidden) return aHidden ? 1 : -1;
    return a.name.localeCompare(b.name, 'pt-BR');
  });

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => { playSound('buttonClick', game.settings.sound); router.back(); }}><Text style={styles.backText}>← VOLTAR</Text></TouchableOpacity>
        <View style={styles.headerLine}>
          <Text style={styles.title}>SKINS</Text>
          <Text style={styles.wallet}>💰 {game.coins}  💎 {game.gems}  🔑 {game.keys}</Text>
        </View>
      </View>

      <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.content}>
        <View style={styles.progressGrid}>
          {RARITIES.map(rarity => {
            const owned = SKINS.filter(skin => skin.rarity === rarity && game.unlockedSkins.includes(skin.id)).length;
            const total = SKINS.filter(skin => skin.rarity === rarity).length;
            const hidden = HIDDEN_RARITIES.includes(rarity);
            return (
              <View key={rarity} style={[styles.progressCard, { borderColor: getSkinRarityColor(rarity) + '77' }]}>
                <Text style={[styles.progressRarity, { color: getSkinRarityColor(rarity) }]}>{rarity.toUpperCase()}</Text>
                <Text style={styles.progressCount}>{owned}/{hidden ? '???' : total}</Text>
              </View>
            );
          })}
        </View>

        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.filters}>
          {FILTERS.map(item => (
            <TouchableOpacity key={item.id} style={[styles.filter, filter === item.id && styles.filterActive]} onPress={() => { playSound('buttonClick', game.settings.sound); setFilter(item.id); }}>
              <Text style={[styles.filterText, filter === item.id && styles.filterTextActive]}>{item.label}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>

        <View style={styles.skinGrid}>
          {visibleSkins.map(skin => {
            const owned = game.unlockedSkins.includes(skin.id);
            const selected = game.ballTransformation === skin.id;
            const hidden = !owned && HIDDEN_RARITIES.includes(skin.rarity);
            const rarityColor = getSkinRarityColor(skin.rarity);
            const skinLevel = game.skinLevels[skin.id] || 1;
            const fragments = game.skinFragments[skin.id] || 0;
            const evolveCost = getSkinEvolutionCost(skin.rarity, skinLevel);
            const canEvolve = owned && skinLevel < 5 && fragments >= evolveCost;

            return (
              <View key={skin.id} style={[styles.skinCard, selected && styles.skinSelected, { borderColor: selected ? '#00ff88' : rarityColor + '88' }]}>
                <LinearGradient
                  colors={hidden ? ['#252536', '#111827'] : [skin.primaryColor + (owned ? '66' : '28'), skin.secondaryColor + '22']}
                  style={styles.skinGradient}
                >
                  <View style={styles.cardTop}>
                    <View style={[styles.previewBall, { backgroundColor: hidden ? '#111827' : skin.primaryColor }]}>
                      <Text style={styles.skinIcon}>{hidden ? '🔒' : skin.icon}</Text>
                    </View>
                    <Text style={[styles.rarityBadge, { backgroundColor: rarityColor }]}>{skin.rarity.toUpperCase()}</Text>
                  </View>

                  <Text style={styles.skinName} numberOfLines={1}>{hidden ? '???' : skin.name}</Text>
                  <Text style={styles.skinDescription} numberOfLines={2}>{hidden ? 'Skin oculta' : skin.description}</Text>

                  <View style={styles.metaRow}>
                    <Text style={styles.fragmentText}>{owned ? `Lv.${skinLevel} • ${fragments}/${evolveCost}` : hidden ? 'Oculta' : `${fragments}/${skin.fragmentsRequired}`}</Text>
                    {selected && <Text style={styles.equippedBadge}>Equipada</Text>}
                  </View>

                  {owned ? (
                    <View style={styles.actionRow}>
                      <TouchableOpacity style={[styles.cardButton, selected && styles.cardButtonDisabled]} disabled={selected} onPress={async () => { await game.setBallTransformation(skin.id); playSound('buttonConfirm', game.settings.sound); }}>
                        <Text style={styles.cardButtonText}>{selected ? 'USANDO' : 'EQUIPAR'}</Text>
                      </TouchableOpacity>
                      {skinLevel < 5 && (
                        <TouchableOpacity style={[styles.cardButtonAlt, !canEvolve && styles.cardButtonDisabled]} disabled={!canEvolve} onPress={async () => { const ok = await game.upgradeSkinLevel(skin.id); playSound(ok ? 'buttonConfirm' : 'buttonError', game.settings.sound); }}>
                          <Text style={styles.cardButtonText}>EVOLUIR</Text>
                        </TouchableOpacity>
                      )}
                    </View>
                  ) : (
                    <Text style={styles.lockedText}>{hidden ? 'Revele em baús' : 'Disponível em baús'}</Text>
                  )}
                </LinearGradient>
              </View>
            );
          })}
        </View>
      </ScrollView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 54, paddingHorizontal: 18, paddingBottom: 10 },
  backText: { color: '#00f0ff', fontSize: 16, fontWeight: 'bold' },
  headerLine: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-end', gap: 12, marginTop: 8 },
  title: { fontSize: 30, fontWeight: 'bold', color: '#00f0ff' },
  wallet: { color: '#ffffff', fontSize: 12, fontWeight: 'bold' },
  content: { padding: 14, paddingBottom: 28, gap: 12 },
  progressGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  progressCard: { flexGrow: 1, flexBasis: 92, backgroundColor: '#ffffff10', borderWidth: 1, borderRadius: 10, paddingVertical: 8, paddingHorizontal: 10 },
  progressRarity: { fontSize: 10, fontWeight: 'bold' },
  progressCount: { color: '#ffffff', fontSize: 15, fontWeight: 'bold', marginTop: 2 },
  filters: { gap: 8, paddingVertical: 2 },
  filter: { height: 34, paddingHorizontal: 13, borderRadius: 17, backgroundColor: '#ffffff12', justifyContent: 'center', borderWidth: 1, borderColor: '#ffffff22' },
  filterActive: { backgroundColor: '#00f0ff', borderColor: '#00f0ff' },
  filterText: { color: '#ffffffaa', fontSize: 12, fontWeight: 'bold' },
  filterTextActive: { color: '#001018' },
  skinGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
  skinCard: { flexGrow: 1, flexBasis: 156, maxWidth: 220, minHeight: 238, borderRadius: 14, overflow: 'hidden', borderWidth: 1 },
  skinSelected: { borderWidth: 2 },
  skinGradient: { flex: 1, padding: 12 },
  cardTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 9 },
  previewBall: { width: 54, height: 54, borderRadius: 27, justifyContent: 'center', alignItems: 'center', borderWidth: 1, borderColor: '#ffffff44' },
  skinIcon: { fontSize: 28 },
  rarityBadge: { color: '#001018', fontSize: 9, fontWeight: 'bold', paddingVertical: 4, paddingHorizontal: 6, borderRadius: 7, overflow: 'hidden' },
  skinName: { color: '#ffffff', fontSize: 16, fontWeight: 'bold' },
  skinDescription: { color: '#ffffffaa', fontSize: 12, minHeight: 34, marginTop: 5 },
  metaRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', gap: 8, marginTop: 9 },
  fragmentText: { color: '#ffd700', fontSize: 11, fontWeight: 'bold', flexShrink: 1 },
  equippedBadge: { color: '#00ff88', fontSize: 10, fontWeight: 'bold' },
  actionRow: { flexDirection: 'row', gap: 7, marginTop: 12 },
  cardButton: { flex: 1, backgroundColor: '#00f0ff', borderRadius: 8, alignItems: 'center', paddingVertical: 8 },
  cardButtonAlt: { flex: 1, backgroundColor: '#00ff88', borderRadius: 8, alignItems: 'center', paddingVertical: 8 },
  cardButtonDisabled: { opacity: 0.45 },
  cardButtonText: { color: '#001018', fontSize: 10, fontWeight: 'bold' },
  lockedText: { color: '#ffffff77', fontSize: 11, fontWeight: 'bold', marginTop: 14 },
});

import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, TextInput } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useGame, getProfileXpNeeded } from '@/src/contexts/GameContext';
import { UPGRADES } from '@/src/game/upgrades';
import { SKINS, getSkinById, getSkinRarityColor } from '@/src/game/skins';
import { ACHIEVEMENTS } from '@/src/game/achievements';

const AVATARS = ['🔵', '🐶', '🐱', '🐷', '🐰', '👻', '🤖', '🐉', '💀', '🌌'];

export default function ProfileScreen() {
  const router = useRouter();
  const game = useGame();
  const [nickname, setNickname] = useState(game.nickname);
  const xpNeeded = getProfileXpNeeded(game.level);
  const xpProgress = Math.min(100, (game.profileXp / xpNeeded) * 100);
  const favoriteSkin = getSkinById(game.favoriteSkin);
  const completedAchievements = Object.values(game.achievements).filter(item => item.completed).length;

  const saveNickname = async () => {
    const clean = nickname.trim().slice(0, 18) || 'Player';
    setNickname(clean);
    await game.updateProfile({ nickname: clean });
  };

  const nextUnlocks = UPGRADES
    .filter(upgrade => !game.unlockedUpgrades.includes(upgrade.id))
    .sort((a, b) => a.unlockLevel - b.unlockLevel)
    .slice(0, 5);

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}>
          <Text style={styles.backText}>← VOLTAR</Text>
        </TouchableOpacity>
        <Text style={styles.title}>PERFIL</Text>
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.card}>
          <Text style={styles.avatar}>{game.avatar}</Text>
          <TextInput value={nickname} onChangeText={setNickname} onBlur={saveNickname} style={styles.input} maxLength={18} />
          <TouchableOpacity style={styles.saveButton} onPress={saveNickname}>
            <Text style={styles.saveText}>SALVAR NICK</Text>
          </TouchableOpacity>
          <View style={styles.avatarRow}>
            {AVATARS.map(avatar => (
              <TouchableOpacity key={avatar} style={[styles.avatarPick, game.avatar === avatar && styles.avatarSelected]} onPress={() => game.updateProfile({ avatar })}>
                <Text style={styles.avatarPickText}>{avatar}</Text>
              </TouchableOpacity>
            ))}
          </View>
          <Text style={styles.sectionTitle}>SKIN FAVORITA</Text>
          <View style={styles.favoriteSkinBox}>
            <Text style={styles.favoriteIcon}>{favoriteSkin.icon}</Text>
            <View style={styles.favoriteInfo}>
              <Text style={styles.favoriteName}>{favoriteSkin.name}</Text>
              <Text style={[styles.favoriteRarity, { color: getSkinRarityColor(favoriteSkin.rarity) }]}>{favoriteSkin.rarity.toUpperCase()}</Text>
            </View>
          </View>
          <View style={styles.avatarRow}>
            {SKINS.filter(skin => game.unlockedSkins.includes(skin.id)).map(skin => (
              <TouchableOpacity key={skin.id} style={[styles.avatarPick, game.favoriteSkin === skin.id && styles.avatarSelected]} onPress={() => game.updateProfile({ favoriteSkin: skin.id })}>
                <Text style={styles.avatarPickText}>{skin.icon}</Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.sectionTitle}>CONTA</Text>
          <Text style={styles.profileLevel}>Nível {game.level}</Text>
          <View style={styles.xpBar}>
            <View style={[styles.xpFill, { width: `${xpProgress}%` }]} />
            <Text style={styles.xpText}>{game.profileXp}/{xpNeeded} XP</Text>
          </View>
          <View style={styles.resourceRow}>
            <Text style={styles.resource}>💰 {game.coins}</Text>
            <Text style={styles.resource}>💎 {game.gems}</Text>
            <Text style={styles.resource}>🔑 {game.keys}</Text>
            <Text style={styles.resource}>🗝️ {game.legendaryKeys}</Text>
          </View>
          <TouchableOpacity style={styles.achievementButton} onPress={() => router.push('/achievements' as any)}>
            <Text style={styles.achievementButtonText}>🏆 Conquistas {completedAchievements}/{ACHIEVEMENTS.length}</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.card}>
          <Text style={styles.sectionTitle}>ESTATÍSTICAS</Text>
          <Text style={styles.stat}>Partidas: {game.lifetimeStats.runsPlayed}</Text>
          <Text style={styles.stat}>Anéis destruídos: {game.lifetimeStats.ringsDestroyed}</Text>
          <Text style={styles.stat}>Escapes perfeitos: {game.lifetimeStats.perfectEscapes}</Text>
          <Text style={styles.stat}>Diamantes encontrados: {game.lifetimeStats.diamondsFound}</Text>
          <Text style={styles.stat}>Baús abertos: {game.lifetimeStats.chestsOpened}</Text>
          <Text style={styles.stat}>Skins desbloqueadas: {game.unlockedSkins.length}</Text>
          <Text style={styles.stat}>Maior fase: {game.lifetimeStats.highestPhase}</Text>
          <Text style={styles.stat}>Maior nível na partida: {game.lifetimeStats.highestRunLevel}</Text>
          <Text style={styles.stat}>Vitórias no Boss: {game.lifetimeStats.bossWins}</Text>
          <Text style={styles.stat}>Derrotas no Boss: {game.lifetimeStats.bossLosses}</Text>
          <Text style={styles.stat}>Melhor dificuldade Boss: {game.lifetimeStats.bossBestDifficulty}</Text>
        </View>

        <View style={styles.card}>
          <Text style={styles.sectionTitle}>HABILIDADES</Text>
          <Text style={styles.stat}>Desbloqueadas: {game.unlockedUpgrades.filter(id => UPGRADES.some(up => up.id === id)).length}</Text>
          {nextUnlocks.map(upgrade => (
            <Text key={upgrade.id} style={styles.locked}>
              🔒 {upgrade.name} - {upgrade.unlockRequirement || `Perfil nível ${upgrade.unlockLevel}`}
            </Text>
          ))}
        </View>
      </ScrollView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 56, paddingHorizontal: 18, paddingBottom: 12 },
  backText: { color: '#00f0ff', fontWeight: 'bold', fontSize: 16 },
  title: { color: '#00f0ff', fontSize: 30, fontWeight: 'bold', marginTop: 8 },
  content: { padding: 16, gap: 14 },
  card: { backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#ffffff22', borderRadius: 12, padding: 16 },
  avatar: { fontSize: 58, textAlign: 'center', marginBottom: 8 },
  input: { color: '#ffffff', fontSize: 20, fontWeight: 'bold', textAlign: 'center', borderBottomWidth: 1, borderBottomColor: '#00f0ff66', paddingVertical: 8 },
  saveButton: { alignSelf: 'center', marginTop: 10, paddingVertical: 8, paddingHorizontal: 16, borderRadius: 8, backgroundColor: '#00f0ff' },
  saveText: { color: '#001018', fontWeight: 'bold' },
  avatarRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, justifyContent: 'center', marginTop: 14 },
  avatarPick: { width: 42, height: 42, borderRadius: 21, backgroundColor: '#ffffff18', alignItems: 'center', justifyContent: 'center' },
  avatarSelected: { borderWidth: 2, borderColor: '#00ff88' },
  avatarPickText: { fontSize: 22 },
  sectionTitle: { color: '#ffffff88', fontSize: 13, fontWeight: 'bold', letterSpacing: 2, marginBottom: 8 },
  profileLevel: { color: '#ffd700', fontSize: 24, fontWeight: 'bold', marginBottom: 10 },
  xpBar: { height: 20, backgroundColor: '#ffffff22', borderRadius: 10, overflow: 'hidden', justifyContent: 'center' },
  xpFill: { position: 'absolute', left: 0, top: 0, bottom: 0, backgroundColor: '#00f0ff' },
  xpText: { color: '#ffffff', fontSize: 12, textAlign: 'center', fontWeight: 'bold' },
  resourceRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 12 },
  resource: { color: '#ffffff', fontWeight: 'bold', backgroundColor: '#ffffff14', paddingVertical: 6, paddingHorizontal: 10, borderRadius: 8, overflow: 'hidden' },
  stat: { color: '#ffffff', fontSize: 14, marginBottom: 6 },
  locked: { color: '#ffffffaa', fontSize: 13, marginTop: 6 },
  favoriteSkinBox: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#ffffff10', borderRadius: 12, padding: 12, gap: 12, marginTop: 8 },
  favoriteIcon: { fontSize: 36 },
  favoriteInfo: { flex: 1 },
  favoriteName: { color: '#ffffff', fontSize: 18, fontWeight: 'bold' },
  favoriteRarity: { fontSize: 11, fontWeight: 'bold', marginTop: 2 },
  achievementButton: { marginTop: 12, borderRadius: 10, backgroundColor: '#ffd70022', borderWidth: 1, borderColor: '#ffd70088', padding: 12, alignItems: 'center' },
  achievementButtonText: { color: '#ffd700', fontWeight: 'bold' },
});

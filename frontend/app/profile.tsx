import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, TextInput, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import * as ImagePicker from 'expo-image-picker';
import { useGame, getProfileXpNeeded } from '@/src/contexts/GameContext';
import { UPGRADES, getAvailableRunUpgrades } from '@/src/game/upgrades';
import { SKINS, getSkinById, getSkinRarityColor } from '@/src/game/skins';
import { ACHIEVEMENTS } from '@/src/game/achievements';
import { playSound } from '@/src/utils/audio';
import { SkinIcon } from '@/src/components/SkinIcon';
import { UiIcon } from '@/src/components/UiIcon';
import { ProfileAvatar } from '@/src/components/ProfileAvatar';
import { UpgradeIcon } from '@/src/components/UpgradeIcon';
import { SUPPORTED_LANGUAGES, useTranslation } from '@/src/i18n';
import { useGameText } from '@/src/i18n/gameText';

const AVATARS = ['🔵', '🐶', '🐱', '🐷', '🐰', '👻', '🤖', '🐉', '💀', '🌌'];

export default function ProfileScreen() {
  const router = useRouter();
  const game = useGame();
  const { t } = useTranslation();
  const gameText = useGameText();
  const [nickname, setNickname] = useState(game.nickname);
  const xpNeeded = getProfileXpNeeded(game.level);
  const xpProgress = Math.min(100, (game.profileXp / xpNeeded) * 100);
  const favoriteSkin = getSkinById(game.favoriteSkin);
  const completedAchievements = Object.values(game.achievements).filter(item => item.completed).length;
  const leaguePlayer = game.getLeaguePlayer();
  const leaguePosition = game.getLeagueStandings().findIndex(item => item.id === game.playerId) + 1;

  const saveNickname = async () => {
    const clean = nickname.trim().slice(0, 18) || 'Player';
    setNickname(clean);
    await game.updateProfile({ nickname: clean });
  };

  const chooseProfilePhoto = async () => {
    const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!permission.granted) {
      playSound('buttonError', game.settings.sound);
      Alert.alert(t('profile.photoPermissionTitle'), t('profile.photoPermissionMessage'));
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['images'],
      allowsEditing: true,
      aspect: [1, 1],
      quality: 0.65,
      base64: false,
    });

    if (result.canceled || !result.assets?.[0]?.uri) return;
    await game.updateProfile({ avatarImageUri: result.assets[0].uri });
    playSound('buttonConfirm', game.settings.sound);
  };

  const removeProfilePhoto = async () => {
    await game.updateProfile({ avatarImageUri: '' });
    playSound('buttonClick', game.settings.sound);
  };

  const availableRunUpgradeIds = new Set(getAvailableRunUpgrades({}, game.level, game.unlockedUpgrades).map(upgrade => upgrade.id));
  const nextUnlocks = UPGRADES
    .filter(upgrade => !availableRunUpgradeIds.has(upgrade.id))
    .sort((a, b) => a.unlockLevel - b.unlockLevel)
    .slice(0, 5);

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}>
          <Text style={styles.backText}>← {t('common.back').toUpperCase()}</Text>
        </TouchableOpacity>
        <Text style={styles.title}>{t('nav.profile').toUpperCase()}</Text>
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.card}>
          <ProfileAvatar avatar={game.avatar} imageUri={game.avatarImageUri} size={86} style={styles.profileAvatar} />
          <TextInput value={nickname} onChangeText={setNickname} onBlur={saveNickname} style={styles.input} maxLength={18} />
          <View style={styles.photoActions}>
            <TouchableOpacity style={styles.photoButton} onPress={chooseProfilePhoto}>
              <UiIcon iconKey="ui_camera" fallback="📷" size={16} />
              <Text style={styles.photoButtonText}>{t('profile.changeAvatar').toUpperCase()}</Text>
            </TouchableOpacity>
            {!!game.avatarImageUri && (
              <TouchableOpacity style={[styles.photoButton, styles.removeButton]} onPress={removeProfilePhoto}>
                <UiIcon iconKey="ui_remove_image" fallback="❌" size={16} />
                <Text style={styles.photoButtonText}>{t('profile.removePhoto').toUpperCase()}</Text>
              </TouchableOpacity>
            )}
          </View>
          <TouchableOpacity style={styles.saveButton} onPress={saveNickname}>
            <Text style={styles.saveText}>{t('profile.saveNick').toUpperCase()}</Text>
          </TouchableOpacity>
          <View style={styles.avatarRow}>
            {AVATARS.map(avatar => (
              <TouchableOpacity key={avatar} style={[styles.avatarPick, game.avatar === avatar && !game.avatarImageUri && styles.avatarSelected]} onPress={() => game.updateProfile({ avatar, avatarImageUri: '' })}>
                <Text style={styles.avatarPickText}>{avatar}</Text>
              </TouchableOpacity>
            ))}
          </View>
          <Text style={styles.sectionTitle}>{t('profile.favoriteSkin').toUpperCase()}</Text>
          <View style={styles.favoriteSkinBox}>
            <SkinIcon skin={favoriteSkin} size={44} style={styles.favoriteIcon} />
            <View style={styles.favoriteInfo}>
              <Text style={styles.favoriteName}>{gameText.skinName(favoriteSkin)}</Text>
              <Text style={[styles.favoriteRarity, { color: getSkinRarityColor(favoriteSkin.rarity) }]}>{favoriteSkin.rarity.toUpperCase()}</Text>
            </View>
          </View>
          <View style={styles.avatarRow}>
            {SKINS.filter(skin => game.unlockedSkins.includes(skin.id)).map(skin => (
              <TouchableOpacity key={skin.id} style={[styles.avatarPick, game.favoriteSkin === skin.id && styles.avatarSelected]} onPress={() => game.updateProfile({ favoriteSkin: skin.id })}>
                <SkinIcon skin={skin} size={34} style={styles.avatarSkinPick} />
              </TouchableOpacity>
            ))}
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.sectionTitle}>{t('profile.account').toUpperCase()}</Text>
          <Text style={styles.profileLevel}>{t('game.level')} {game.level}</Text>
          <View style={styles.xpBar}>
            <View style={[styles.xpFill, { width: `${xpProgress}%` }]} />
            <Text style={styles.xpText}>{game.profileXp}/{xpNeeded} XP</Text>
          </View>
          <View style={styles.resourceRow}>
            <View style={styles.resource}><UiIcon iconKey="ui_coin" fallback="💰" size={18} /><Text style={styles.resourceText}>{game.coins}</Text></View>
            <View style={styles.resource}><UiIcon iconKey="ui_gem" fallback="💎" size={18} /><Text style={styles.resourceText}>{game.gems}</Text></View>
            <View style={styles.resource}><UiIcon iconKey="ui_key" fallback="🔑" size={18} /><Text style={styles.resourceText}>{game.keys}</Text></View>
            <View style={styles.resource}><UiIcon iconKey="ui_legendary_key" fallback="🗝️" size={18} /><Text style={styles.resourceText}>{game.legendaryKeys}</Text></View>
          </View>
          <TouchableOpacity style={styles.achievementButton} onPress={() => router.push('/achievements' as any)}>
            <UiIcon iconKey="ui_achievements" fallback="🏆" size={18} />
            <Text style={styles.achievementButtonText}>{t('nav.achievements')} {completedAchievements}/{ACHIEVEMENTS.length}</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.card}>
          <Text style={styles.sectionTitle}>{t('settings.sound').toUpperCase()}</Text>
          <View style={styles.toggleRow}>
            <TouchableOpacity style={[styles.toggleButton, !game.settings.musicMuted && styles.toggleActive]} onPress={() => game.updateAudioSettings({ musicMuted: !game.settings.musicMuted })}>
              <UiIcon iconKey={game.settings.musicMuted ? 'ui_mute_off' : 'ui_mute_on'} fallback={game.settings.musicMuted ? '🔇' : '🔊'} size={18} />
              <Text style={styles.toggleText}>{t('settings.music')} {game.settings.musicMuted ? 'OFF' : 'ON'}</Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.toggleButton, !game.settings.sfxMuted && styles.toggleActive]} onPress={() => { game.updateAudioSettings({ sfxMuted: !game.settings.sfxMuted }); playSound('buttonClick'); }}>
              <UiIcon iconKey={game.settings.sfxMuted ? 'ui_mute_off' : 'ui_mute_on'} fallback={game.settings.sfxMuted ? '🔇' : '🔊'} size={18} />
              <Text style={styles.toggleText}>{t('settings.effects')} {game.settings.sfxMuted ? 'OFF' : 'ON'}</Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.toggleButton, !game.settings.masterMuted && styles.toggleActive]} onPress={() => game.updateAudioSettings({ masterMuted: !game.settings.masterMuted })}>
              <UiIcon iconKey={game.settings.masterMuted ? 'ui_mute_off' : 'ui_mute_on'} fallback={game.settings.masterMuted ? '🔇' : '🔊'} size={18} />
              <Text style={styles.toggleText}>{t('settings.master')} {game.settings.masterMuted ? 'OFF' : 'ON'}</Text>
            </TouchableOpacity>
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.sectionTitle}>{t('settings.language').toUpperCase()}</Text>
          <Text style={styles.stat}>{t('settings.selectLanguage')}</Text>
          <View style={styles.languageGrid}>
            {SUPPORTED_LANGUAGES.map(language => (
              <TouchableOpacity
                key={language.code}
                style={[styles.languageButton, game.language === language.code && styles.languageActive]}
                onPress={() => game.updateLanguage(language.code)}
              >
                <Text style={[styles.languageText, game.language === language.code && styles.languageTextActive]}>{language.label}</Text>
                {game.language === language.code && <Text style={styles.languageCheck}>✓</Text>}
              </TouchableOpacity>
            ))}
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.sectionTitle}>LIGA NEON</Text>
          <Text style={styles.stat}>Posição atual: #{leaguePosition}/201</Text>
          <Text style={styles.stat}>Divisão atual: {leaguePlayer.division}</Text>
          <Text style={styles.stat}>Troféus: {leaguePlayer.trophies.toLocaleString('pt-BR')}</Text>
          <Text style={styles.stat}>Pontuação secundária: {leaguePlayer.score.toLocaleString('pt-BR')}</Text>
          <Text style={styles.stat}>Melhor posição: #{game.league.history.bestPosition || leaguePosition}</Text>
          <Text style={styles.stat}>Melhor divisão: {game.league.history.bestDivision}</Text>
          <Text style={styles.stat}>Temporadas vencidas: {game.league.history.firstPlaceFinishes}</Text>
          <Text style={styles.stat}>Vitórias/derrotas: {game.league.history.competitionWins || 0}/{game.league.history.competitionLosses || 0}</Text>
          <Text style={styles.stat}>Maior sequência: {game.league.history.bestWinStreak || 0}</Text>
          <Text style={styles.stat}>Skins de ranking: {game.league.history.rankingSkinsObtained.length}</Text>
          <TouchableOpacity style={styles.achievementButton} onPress={() => router.push('/league' as any)}>
            <UiIcon iconKey="ui_league_neon" fallback="🏅" size={18} />
            <Text style={styles.achievementButtonText}>Abrir Liga Neon</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.card}>
          <Text style={styles.sectionTitle}>{t('profile.statistics').toUpperCase()}</Text>
          <Text style={styles.stat}>{t('profile.matchesPlayed')}: {game.lifetimeStats.runsPlayed}</Text>
          <Text style={styles.stat}>Anéis destruídos: {game.lifetimeStats.ringsDestroyed}</Text>
          <Text style={styles.stat}>Escapes perfeitos: {game.lifetimeStats.perfectEscapes}</Text>
          <Text style={styles.stat}>Diamantes encontrados: {game.lifetimeStats.diamondsFound}</Text>
          <Text style={styles.stat}>Baús abertos: {game.lifetimeStats.chestsOpened}</Text>
          <Text style={styles.stat}>Skins desbloqueadas: {game.unlockedSkins.length}</Text>
          <Text style={styles.stat}>Maior fase: {game.lifetimeStats.highestPhase}</Text>
          <Text style={styles.stat}>Maior nível na partida: {game.lifetimeStats.highestRunLevel}</Text>
          <Text style={styles.stat}>Vitórias no Boss: {game.lifetimeStats.bossWins}</Text>
          <Text style={styles.stat}>Derrotas no Boss: {game.lifetimeStats.bossLosses}</Text>
          <Text style={styles.stat}>Melhor nível Boss: {game.lifetimeStats.bossBestDifficulty}</Text>
          <Text style={styles.stat}>Impossível no mês: {game.bossProgress.monthlyImpossibleWins}</Text>
        </View>

        <View style={styles.card}>
          <Text style={styles.sectionTitle}>HABILIDADES</Text>
          <Text style={styles.stat}>Desbloqueadas: {availableRunUpgradeIds.size}</Text>
          {nextUnlocks.map(upgrade => (
            <View key={upgrade.id} style={styles.lockedRow}>
              <UiIcon iconKey="ui_locked" fallback="🔒" size={16} />
              <UpgradeIcon upgrade={upgrade} size={16} />
              <Text style={styles.locked}>{upgrade.name} - {upgrade.unlockRequirement || `Perfil nível ${upgrade.unlockLevel}`}</Text>
            </View>
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
  profileAvatar: { alignSelf: 'center', marginBottom: 8 },
  input: { color: '#ffffff', fontSize: 20, fontWeight: 'bold', textAlign: 'center', borderBottomWidth: 1, borderBottomColor: '#00f0ff66', paddingVertical: 8 },
  photoActions: { flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'center', gap: 8, marginTop: 10 },
  photoButton: { flexDirection: 'row', alignItems: 'center', gap: 6, paddingVertical: 8, paddingHorizontal: 12, borderRadius: 8, backgroundColor: '#00f0ff22', borderWidth: 1, borderColor: '#00f0ff88' },
  removeButton: { backgroundColor: '#ff005522', borderColor: '#ff005588' },
  photoButtonText: { color: '#ffffff', fontWeight: 'bold', fontSize: 11 },
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
  resource: { flexDirection: 'row', alignItems: 'center', gap: 6, backgroundColor: '#ffffff14', paddingVertical: 6, paddingHorizontal: 10, borderRadius: 8, overflow: 'hidden' },
  resourceText: { color: '#ffffff', fontWeight: 'bold' },
  stat: { color: '#ffffff', fontSize: 14, marginBottom: 6 },
  lockedRow: { flexDirection: 'row', alignItems: 'center', gap: 6, marginTop: 6 },
  locked: { color: '#ffffffaa', fontSize: 13, flex: 1 },
  favoriteSkinBox: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#ffffff10', borderRadius: 12, padding: 12, gap: 12, marginTop: 8 },
  favoriteIcon: { borderWidth: 0 },
  avatarSkinPick: { borderWidth: 0, backgroundColor: 'transparent' },
  favoriteInfo: { flex: 1 },
  favoriteName: { color: '#ffffff', fontSize: 18, fontWeight: 'bold' },
  favoriteRarity: { fontSize: 11, fontWeight: 'bold', marginTop: 2 },
  achievementButton: { marginTop: 12, borderRadius: 10, backgroundColor: '#ffd70022', borderWidth: 1, borderColor: '#ffd70088', padding: 12, alignItems: 'center', justifyContent: 'center', flexDirection: 'row', gap: 8 },
  achievementButtonText: { color: '#ffd700', fontWeight: 'bold' },
  toggleRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  toggleButton: { flexGrow: 1, minWidth: 96, backgroundColor: '#ffffff14', borderWidth: 1, borderColor: '#ffffff22', borderRadius: 10, paddingVertical: 10, alignItems: 'center', justifyContent: 'center', flexDirection: 'row', gap: 6 },
  toggleActive: { backgroundColor: '#00f0ff', borderColor: '#00f0ff' },
  toggleText: { color: '#ffffff', fontWeight: 'bold', fontSize: 12, textAlign: 'center', flexShrink: 1 },
  languageGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 8 },
  languageButton: { minWidth: 128, flexGrow: 1, flexBasis: '45%', minHeight: 44, borderRadius: 10, borderWidth: 1, borderColor: '#ffffff22', backgroundColor: '#ffffff14', paddingVertical: 10, paddingHorizontal: 12, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', gap: 8 },
  languageActive: { borderColor: '#00ff88', backgroundColor: '#00ff8822' },
  languageText: { color: '#ffffff', fontWeight: 'bold', fontSize: 13, flexShrink: 1 },
  languageTextActive: { color: '#00ff88' },
  languageCheck: { color: '#00ff88', fontSize: 16, fontWeight: 'bold' },
});

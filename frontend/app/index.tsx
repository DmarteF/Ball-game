import React, { useEffect, useState } from 'react';
import { ActivityIndicator, Modal, ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { AdModal } from '@/src/components/AdModal';
import { UiIcon } from '@/src/components/UiIcon';
import { ProfileAvatar } from '@/src/components/ProfileAvatar';
import { useGame } from '@/src/contexts/GameContext';
import { getWeeklyEvent } from '@/src/game/retention';
import { playSound } from '@/src/utils/audio';

export default function HomeScreen() {
  const router = useRouter();
  const game = useGame();
  const { coins, gems, keys, loading, nickname, avatar, avatarImageUri, level, lastAchievementUnlocked, clearAchievementToast, pendingOfflineReward } = game;
  const [moreOpen, setMoreOpen] = useState(false);
  const [offlineVisible, setOfflineVisible] = useState(!!pendingOfflineReward);
  const [showOfflineAd, setShowOfflineAd] = useState(false);
  const weeklyEvent = getWeeklyEvent(game.weeklyEvent.eventId);

  useEffect(() => {
    if (pendingOfflineReward) setOfflineVisible(true);
  }, [pendingOfflineReward]);

  useEffect(() => {
    if (!lastAchievementUnlocked) return;
    const timeout = setTimeout(() => clearAchievementToast(), 6500);
    return () => clearTimeout(timeout);
  }, [lastAchievementUnlocked, clearAchievementToast]);

  const secondaryItems = [
    { label: 'Loja', icon: '🛒', iconKey: 'ui_store' as const, route: '/store', color: '#00aaff' },
    { label: 'Inventário', icon: '🎒', iconKey: 'ui_inventory' as const, route: '/inventory', color: '#ffd700' },
    { label: 'Missões', icon: '📅', iconKey: 'ui_missions' as const, route: '/daily', color: '#ff8800' },
    { label: 'Evento', icon: '⚡', iconKey: 'ui_event' as const, route: '/events', color: weeklyEvent.color },
    { label: 'Roleta', icon: '🎡', iconKey: 'ui_wheel' as const, route: '/wheel', color: '#00ff88' },
    { label: 'Recompensa diária', icon: '🎁', iconKey: 'ui_daily_reward' as const, route: '/wheel', color: '#ffd700' },
    { label: 'Boss', icon: '👑', iconKey: 'ui_boss' as const, route: '/boss', color: '#ff0055' },
    { label: 'Liga Neon', icon: '🏅', iconKey: 'ui_league_neon' as const, route: '/league', color: '#00ff88' },
    { label: 'Conquistas', icon: '🏆', iconKey: 'ui_achievements' as const, route: '/achievements', color: '#ffd700' },
    { label: 'Configurações', icon: '⚙️', iconKey: 'ui_settings' as const, route: '/profile', color: '#b8f3ff' },
  ];

  const go = (route: string) => {
    playSound('buttonClick', game.settings.sound);
    setMoreOpen(false);
    router.push(route as any);
  };

  if (loading) {
    return (
      <LinearGradient colors={['#0a0a1a', '#1a0a2e']} style={styles.container}>
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#00f0ff" />
          <Text style={styles.loadingText}>Carregando...</Text>
        </View>
      </LinearGradient>
    );
  }

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.topBar}>
        <TouchableOpacity style={styles.profileBadge} onPress={() => go('/profile')}>
          <ProfileAvatar avatar={avatar} imageUri={avatarImageUri} size={34} style={styles.profileAvatar} />
          <View>
            <Text style={styles.nickname}>{nickname}</Text>
            <Text style={styles.levelText}>Lv.{level}</Text>
          </View>
        </TouchableOpacity>
        <View style={styles.resources}>
          <View style={styles.resource}><UiIcon iconKey="ui_coin" fallback="💰" size={18} /><Text style={styles.resourceText}>{coins}</Text></View>
          <View style={styles.resource}><UiIcon iconKey="ui_gem" fallback="💎" size={18} /><Text style={styles.resourceText}>{gems}</Text></View>
          <View style={styles.resource}><UiIcon iconKey="ui_key" fallback="🔑" size={18} /><Text style={styles.resourceText}>{keys}</Text></View>
        </View>
      </View>

      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        <View style={styles.titleContainer}>
          <Text style={styles.title}>NEON</Text>
          <Text style={styles.subtitle}>IDLE ESCAPE</Text>
        </View>

        <TouchableOpacity style={styles.playButton} onPress={() => go('/phase-select')}>
          <LinearGradient colors={['#00f0ff', '#0088ff']} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} style={styles.playGradient}>
            <UiIcon iconKey="ui_play" fallback="▶" size={32} style={styles.playIcon} />
            <Text style={styles.playText}>JOGAR</Text>
          </LinearGradient>
        </TouchableOpacity>

        <View style={styles.primaryRow}>
          <TouchableOpacity style={styles.primaryCard} onPress={() => go('/upgrade-shop')}>
            <LinearGradient colors={['#b000ff66', '#6600cc33']} style={styles.primaryCardGradient}>
              <UiIcon iconKey="ui_upgrades" fallback="⚔️" size={42} style={styles.primaryIcon} />
              <Text style={styles.primaryLabel}>UPGRADES</Text>
            </LinearGradient>
          </TouchableOpacity>
          <TouchableOpacity style={styles.primaryCard} onPress={() => go('/transformations')}>
            <LinearGradient colors={['#ff008866', '#cc006633']} style={styles.primaryCardGradient}>
              <UiIcon iconKey="ui_skins" fallback="✨" size={42} style={styles.primaryIcon} />
              <Text style={styles.primaryLabel}>SKINS</Text>
            </LinearGradient>
          </TouchableOpacity>
        </View>

        {lastAchievementUnlocked && (
          <TouchableOpacity
            style={styles.achievementToast}
            onPress={async () => {
              await clearAchievementToast();
              router.push('/achievements' as any);
            }}
          >
            <Text style={styles.achievementToastTitle}>Conquista desbloqueada</Text>
            <Text style={styles.achievementToastText}>{lastAchievementUnlocked}</Text>
          </TouchableOpacity>
        )}
      </ScrollView>

      <TouchableOpacity style={styles.moreButton} onPress={() => setMoreOpen(true)}>
        <UiIcon iconKey="ui_menu" fallback="☰" size={26} style={styles.moreIcon} />
        <Text style={styles.moreText}>Mais</Text>
      </TouchableOpacity>

      <Modal visible={moreOpen} transparent animationType="fade" onRequestClose={() => setMoreOpen(false)}>
        <View style={styles.modalOverlay}>
          <View style={styles.morePanel}>
            <View style={styles.moreHeader}>
              <Text style={styles.moreTitle}>Menu</Text>
              <TouchableOpacity onPress={() => setMoreOpen(false)}>
                <Text style={styles.closeText}>Fechar</Text>
              </TouchableOpacity>
            </View>
            <View style={styles.moreGrid}>
              {secondaryItems.map(item => (
                <TouchableOpacity key={item.label} style={[styles.moreItem, { borderColor: item.color + '88' }]} onPress={() => go(item.route)}>
                  <UiIcon iconKey={item.iconKey} fallback={item.icon} size={34} style={styles.moreItemIcon} />
                  <Text style={styles.moreItemLabel}>{item.label}</Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>
        </View>
      </Modal>

      <Modal visible={offlineVisible && !!pendingOfflineReward} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.offlineBox}>
            <Text style={styles.offlineTitle}>RECOMPENSA OFFLINE</Text>
            <Text style={styles.offlineText}>Você ficou fora por {pendingOfflineReward?.hours}h.</Text>
            <View style={styles.offlineRewardRow}><UiIcon iconKey="ui_coin" fallback="💰" size={34} /><Text style={styles.offlineReward}>{pendingOfflineReward?.coins}</Text></View>
            {pendingOfflineReward?.eventBonus && <Text style={styles.offlineText}>Bônus ativo: {pendingOfflineReward.eventBonus}</Text>}
            <TouchableOpacity style={styles.offlineButton} onPress={async () => { await game.claimOfflineReward(false); setOfflineVisible(false); }}>
              <Text style={styles.offlineButtonText}>COLETAR</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.offlineAdButton} onPress={() => setShowOfflineAd(true)}>
              <Text style={styles.offlineButtonText}>DOBRAR — AD</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>

      <AdModal
        visible={showOfflineAd}
        onClose={() => setShowOfflineAd(false)}
        placement="doubleRewards"
        onRewardClaimed={async () => {
          await game.recordAdUse('offline_double');
          await game.claimOfflineReward(true);
          setOfflineVisible(false);
        }}
        rewardType="double"
      />
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  loadingContainer: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  loadingText: { color: '#00f0ff', fontSize: 16, marginTop: 16 },
  topBar: { paddingTop: 50, paddingHorizontal: 18, paddingBottom: 8, gap: 10 },
  profileBadge: { flexDirection: 'row', alignItems: 'center', alignSelf: 'flex-start', backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#ffffff22', paddingVertical: 8, paddingHorizontal: 12, borderRadius: 14, gap: 10 },
  profileAvatar: { borderColor: '#ffffff55' },
  nickname: { color: '#ffffff', fontWeight: 'bold', fontSize: 14 },
  levelText: { color: '#00f0ff', fontSize: 12, fontWeight: 'bold' },
  resources: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  resource: { flexDirection: 'row', alignItems: 'center', gap: 5, backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#ffffff22', paddingVertical: 7, paddingHorizontal: 10, borderRadius: 10, overflow: 'hidden' },
  resourceText: { color: '#ffffff', fontWeight: 'bold' },
  content: { flexGrow: 1, paddingHorizontal: 20, paddingBottom: 96 },
  titleContainer: { alignItems: 'center', marginTop: 22, marginBottom: 26 },
  title: { fontSize: 60, fontWeight: 'bold', color: '#00f0ff', textShadowColor: '#00f0ff', textShadowOffset: { width: 0, height: 0 }, textShadowRadius: 18, letterSpacing: 6 },
  subtitle: { fontSize: 18, fontWeight: '300', color: '#ffffff', letterSpacing: 7, marginTop: 2 },
  playButton: { width: '100%', height: 78, borderRadius: 16, overflow: 'hidden', marginBottom: 12, shadowColor: '#00f0ff', shadowOffset: { width: 0, height: 0 }, shadowOpacity: 0.8, shadowRadius: 18 },
  playGradient: { flex: 1, flexDirection: 'row', justifyContent: 'center', alignItems: 'center', gap: 12 },
  playIcon: { tintColor: '#ffffff' },
  playText: { fontSize: 30, fontWeight: 'bold', color: '#ffffff', letterSpacing: 3 },
  primaryRow: { flexDirection: 'row', gap: 12, marginBottom: 12 },
  primaryCard: { flex: 1, height: 92, borderRadius: 14, overflow: 'hidden' },
  primaryCardGradient: { flex: 1, justifyContent: 'center', alignItems: 'center', borderWidth: 1, borderColor: '#ffffff24' },
  primaryIcon: { marginBottom: 6 },
  primaryLabel: { color: '#ffffff', fontSize: 14, fontWeight: 'bold', letterSpacing: 1 },
  achievementToast: { marginTop: 4, backgroundColor: '#00ff8822', borderWidth: 1, borderColor: '#00ff88aa', borderRadius: 12, padding: 12 },
  achievementToastTitle: { color: '#00ff88', fontSize: 13, fontWeight: 'bold' },
  achievementToastText: { color: '#ffffff', fontSize: 15, fontWeight: 'bold', marginTop: 2 },
  moreButton: { position: 'absolute', right: 18, bottom: 24, width: 64, height: 64, borderRadius: 18, backgroundColor: '#00f0ff', alignItems: 'center', justifyContent: 'center', shadowColor: '#00f0ff', shadowOffset: { width: 0, height: 0 }, shadowOpacity: 0.9, shadowRadius: 14 },
  moreIcon: { tintColor: '#001018' },
  moreText: { color: '#001018', fontSize: 11, fontWeight: 'bold' },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', justifyContent: 'center', alignItems: 'center', padding: 18 },
  morePanel: { width: '100%', maxWidth: 430, backgroundColor: '#1a0a2e', borderWidth: 1, borderColor: '#00f0ff66', borderRadius: 18, padding: 16 },
  moreHeader: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 },
  moreTitle: { color: '#00f0ff', fontSize: 24, fontWeight: 'bold' },
  closeText: { color: '#ffffffaa', fontWeight: 'bold' },
  moreGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
  moreItem: { width: '47%', minHeight: 76, backgroundColor: '#ffffff12', borderWidth: 1, borderRadius: 12, alignItems: 'center', justifyContent: 'center', padding: 10 },
  moreItemIcon: { marginBottom: 5 },
  moreItemLabel: { color: '#ffffff', fontSize: 12, fontWeight: 'bold', textAlign: 'center' },
  offlineBox: { width: '100%', maxWidth: 380, backgroundColor: '#1a0a2e', borderWidth: 1, borderColor: '#00f0ff66', borderRadius: 16, padding: 22, alignItems: 'center' },
  offlineTitle: { color: '#00f0ff', fontSize: 24, fontWeight: 'bold' },
  offlineText: { color: '#ffffffaa', textAlign: 'center', marginTop: 8 },
  offlineRewardRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, marginVertical: 12 },
  offlineReward: { color: '#ffd700', fontSize: 30, fontWeight: 'bold' },
  offlineButton: { width: '100%', backgroundColor: '#00f0ff', borderRadius: 10, padding: 14, alignItems: 'center', marginTop: 8 },
  offlineAdButton: { width: '100%', backgroundColor: '#ffd700', borderRadius: 10, padding: 14, alignItems: 'center', marginTop: 8 },
  offlineButtonText: { color: '#001018', fontWeight: 'bold' },
});

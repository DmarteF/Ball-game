import React, { useEffect, useState } from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { UiIcon } from '@/src/components/UiIcon';
import { useGame } from '@/src/contexts/GameContext';
import { useTranslation } from '@/src/i18n';
import { storage } from '@/src/utils/storage';
import { getLocalDayKey } from '@/src/utils/time';
import { playSound } from '@/src/utils/audio';

const CLAIM_KEY = 'daily_reward_claim_day_v1';

export default function DailyRewardScreen() {
  const router = useRouter();
  const game = useGame();
  const { t } = useTranslation();
  const [claimed, setClaimed] = useState(false);
  const todayKey = getLocalDayKey();
  const reward = { gems: 18, coins: 350, keys: 1 };

  useEffect(() => {
    storage.getItem(CLAIM_KEY, '').then(value => setClaimed(value === todayKey));
  }, [todayKey]);

  const claim = async () => {
    if (claimed) return;
    await game.updateGems(reward.gems);
    await game.updateCoins(reward.coins);
    await game.updateKeys(reward.keys);
    await storage.setItem(CLAIM_KEY, todayKey);
    setClaimed(true);
    playSound('buttonConfirm', game.settings.sound);
  };

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}><Text style={styles.backText}>← {t('common.back').toUpperCase()}</Text></TouchableOpacity>
        <Text style={styles.title}>{t('daily.rewardTitle').toUpperCase()}</Text>
        <Text style={styles.subtitle}>{t('daily.rewardSubtitle')}</Text>
      </View>

      <View style={styles.rewardBox}>
        <UiIcon iconKey="ui_daily_reward" fallback="🎁" size={72} />
        <Text style={styles.rewardTitle}>{claimed ? t('daily.claimedToday') : t('daily.claimToday')}</Text>
        <View style={styles.rewards}>
          <Text style={styles.rewardLine}>💎 {reward.gems}</Text>
          <Text style={styles.rewardLine}>💰 {reward.coins}</Text>
          <Text style={styles.rewardLine}>🔑 {reward.keys}</Text>
        </View>
        <TouchableOpacity style={[styles.claimButton, claimed && styles.disabled]} disabled={claimed} onPress={claim}>
          <Text style={styles.claimText}>{claimed ? t('daily.comeBack').toUpperCase() : t('common.collect').toUpperCase()}</Text>
        </TouchableOpacity>
      </View>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 56, paddingHorizontal: 18, paddingBottom: 12 },
  backText: { color: '#00f0ff', fontWeight: 'bold', fontSize: 16 },
  title: { color: '#00f0ff', fontSize: 30, fontWeight: 'bold', marginTop: 10 },
  subtitle: { color: '#ffffffaa', marginTop: 6, fontWeight: 'bold' },
  rewardBox: { margin: 18, flex: 1, borderRadius: 16, borderWidth: 1, borderColor: '#ffd70088', backgroundColor: '#ffffff12', alignItems: 'center', justifyContent: 'center', padding: 24 },
  rewardTitle: { color: '#ffd700', fontSize: 24, fontWeight: 'bold', marginTop: 18, textAlign: 'center' },
  rewards: { marginVertical: 22, gap: 8, alignItems: 'center' },
  rewardLine: { color: '#ffffff', fontSize: 22, fontWeight: 'bold' },
  claimButton: { width: '100%', borderRadius: 12, backgroundColor: '#00f0ff', padding: 15, alignItems: 'center' },
  disabled: { opacity: 0.45 },
  claimText: { color: '#001018', fontWeight: 'bold' },
});

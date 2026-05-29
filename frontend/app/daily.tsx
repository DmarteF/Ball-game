import React, { useState } from 'react';
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { AdModal } from '@/src/components/AdModal';
import { useGame } from '@/src/contexts/GameContext';
import { getDailyMission } from '@/src/game/retention';
import { useGameText } from '@/src/i18n/gameText';
import { useTranslation } from '@/src/i18n';

export default function DailyScreen() {
  const router = useRouter();
  const game = useGame();
  const gameText = useGameText();
  const { t } = useTranslation();
  const [adAction, setAdAction] = useState<null | { type: 'reroll' | 'boost'; missionId: string }>(null);

  const completeAdAction = async () => {
    if (!adAction) return;
    if (adAction.type === 'reroll') await game.rerollDailyMission(adAction.missionId);
    if (adAction.type === 'boost') await game.boostDailyMission(adAction.missionId);
    setAdAction(null);
  };

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}><Text style={styles.backText}>← {t('common.back').toUpperCase()}</Text></TouchableOpacity>
        <Text style={styles.title}>{t('daily.title').toUpperCase()}</Text>
        <Text style={styles.subtitle}>{t('daily.rotation')} • {game.dailyMissions.dayKey}</Text>
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        {game.dailyMissions.missions.map(state => {
          const mission = getDailyMission(state.id);
          if (!mission) return null;
          const progress = Math.min(100, (state.progress / mission.target) * 100);
          const done = state.progress >= mission.target;
          return (
            <View key={state.id} style={[styles.card, done && !state.claimed && styles.cardDone]}>
              <View style={styles.cardHeader}>
                <View style={styles.cardTitleBox}>
                  <Text style={styles.missionTitle}>{gameText.missionTitle(mission)}</Text>
                  <Text style={styles.reward}>{gameText.rewardText(mission.reward)}</Text>
                </View>
                <Text style={styles.difficulty}>{'★'.repeat(mission.difficulty)}</Text>
              </View>
              <View style={styles.progressBar}>
                <View style={[styles.progressFill, { width: `${progress}%` }]} />
                <Text style={styles.progressText}>{state.progress}/{mission.target}</Text>
              </View>
              <View style={styles.actions}>
                {done && !state.claimed ? (
                  <TouchableOpacity style={styles.claimButton} onPress={() => game.collectDailyMission(state.id)}>
                    <Text style={styles.claimText}>{t('common.collect').toUpperCase()}</Text>
                  </TouchableOpacity>
                ) : (
                  <Text style={styles.status}>{state.claimed ? t('common.claimed') : t('common.inProgress')}</Text>
                )}
                {!state.claimed && !state.rerolled && (
                  <TouchableOpacity style={styles.smallButton} onPress={() => setAdAction({ type: 'reroll', missionId: state.id })}>
                    <Text style={styles.smallButtonText}>{t('game.reroll')} 📺</Text>
                  </TouchableOpacity>
                )}
                {!state.claimed && !state.boosted && (
                  <TouchableOpacity style={styles.smallButton} onPress={() => setAdAction({ type: 'boost', missionId: state.id })}>
                    <Text style={styles.smallButtonText}>+25% 📺</Text>
                  </TouchableOpacity>
                )}
              </View>
            </View>
          );
        })}
      </ScrollView>

      <AdModal visible={!!adAction} onClose={() => setAdAction(null)} onRewardClaimed={completeAdAction} placement="default" rewardType="double" />
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 56, paddingHorizontal: 18, paddingBottom: 12 },
  backText: { color: '#00f0ff', fontWeight: 'bold', fontSize: 16 },
  title: { color: '#00f0ff', fontSize: 28, fontWeight: 'bold', marginTop: 8 },
  subtitle: { color: '#ffffff99', marginTop: 4 },
  content: { padding: 16, gap: 12 },
  card: { backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#ffffff24', borderRadius: 12, padding: 14 },
  cardDone: { borderColor: '#00ff88aa', backgroundColor: '#00ff8818' },
  cardHeader: { flexDirection: 'row', alignItems: 'flex-start', gap: 10 },
  cardTitleBox: { flex: 1 },
  missionTitle: { color: '#ffffff', fontSize: 17, fontWeight: 'bold' },
  reward: { color: '#ffd700', fontWeight: 'bold', marginTop: 4 },
  difficulty: { color: '#00f0ff', fontWeight: 'bold' },
  progressBar: { height: 22, backgroundColor: '#00000055', borderRadius: 11, overflow: 'hidden', justifyContent: 'center', marginTop: 12 },
  progressFill: { position: 'absolute', left: 0, top: 0, bottom: 0, backgroundColor: '#00f0ff' },
  progressText: { color: '#ffffff', fontSize: 12, fontWeight: 'bold', textAlign: 'center' },
  actions: { flexDirection: 'row', alignItems: 'center', gap: 8, marginTop: 12, flexWrap: 'wrap' },
  status: { flex: 1, color: '#ffffff88', fontWeight: 'bold' },
  claimButton: { flex: 1, backgroundColor: '#00ff88', borderRadius: 8, paddingVertical: 9, alignItems: 'center' },
  claimText: { color: '#001018', fontWeight: 'bold' },
  smallButton: { backgroundColor: '#ffffff16', borderWidth: 1, borderColor: '#ffffff30', borderRadius: 8, paddingVertical: 8, paddingHorizontal: 10 },
  smallButtonText: { color: '#ffffff', fontWeight: 'bold', fontSize: 12 },
});

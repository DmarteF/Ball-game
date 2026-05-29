import React from 'react';
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useGame } from '@/src/contexts/GameContext';
import { getEventMission, getWeeklyEvent } from '@/src/game/retention';
import { getEventTimeRemainingLabel } from '@/src/utils/time';
import { useGameText } from '@/src/i18n/gameText';
import { useTranslation } from '@/src/i18n';

export default function EventsScreen() {
  const router = useRouter();
  const game = useGame();
  const gameText = useGameText();
  const { t, language } = useTranslation();
  const event = getWeeklyEvent(game.weeklyEvent.eventId);
  const localizedEvent = gameText.eventText(event);
  const allClaimed = game.weeklyEvent.missions.every(item => item.claimed);

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}><Text style={styles.backText}>← {t('common.back').toUpperCase()}</Text></TouchableOpacity>
        <Text style={[styles.title, { color: event.color }]}>{localizedEvent.name.toUpperCase()}</Text>
        <Text style={styles.subtitle}>{getEventTimeRemainingLabel()} restantes • {game.weeklyEvent.weekKey}</Text>
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        <View style={[styles.hero, { borderColor: event.color + '88' }]}>
          <Text style={styles.heroTitle}>{localizedEvent.description}</Text>
          <Text style={[styles.bonus, { color: event.color }]}>{localizedEvent.bonus}</Text>
          <Text style={styles.grand}>{language === 'pt-BR' ? 'Prêmio principal' : 'Grand prize'}: {gameText.rewardText(event.grandReward)}</Text>
        </View>

        {game.weeklyEvent.missions.map(state => {
          const mission = getEventMission(event.id, state.id);
          if (!mission) return null;
          const progress = Math.min(100, (state.progress / mission.target) * 100);
          const done = state.progress >= mission.target;
          return (
            <View key={state.id} style={[styles.card, done && !state.claimed && { borderColor: event.color }]}>
              <Text style={styles.missionTitle}>{gameText.eventMissionTitle(mission)}</Text>
              <Text style={styles.reward}>{gameText.rewardText(mission.reward)}</Text>
              <View style={styles.progressBar}>
                <View style={[styles.progressFill, { width: `${progress}%`, backgroundColor: event.color }]} />
                <Text style={styles.progressText}>{state.progress}/{mission.target}</Text>
              </View>
              <View style={styles.footer}>
                <Text style={styles.status}>{state.claimed ? t('common.claimed') : done ? t('common.available') : t('common.inProgress')}</Text>
                {done && !state.claimed && (
                  <TouchableOpacity style={[styles.claimButton, { backgroundColor: event.color }]} onPress={() => game.collectEventMission(state.id)}>
                    <Text style={styles.claimText}>{t('common.collect').toUpperCase()}</Text>
                  </TouchableOpacity>
                )}
              </View>
            </View>
          );
        })}

        <TouchableOpacity style={[styles.grandButton, (!allClaimed || game.weeklyEvent.grandClaimed) && styles.disabled]} disabled={!allClaimed || game.weeklyEvent.grandClaimed} onPress={game.collectEventGrandReward}>
          <LinearGradient colors={[event.color, '#0088ff']} style={styles.buttonGradient}>
            <Text style={styles.buttonText}>{game.weeklyEvent.grandClaimed ? t('common.claimed').toUpperCase() : `${t('common.collect').toUpperCase()} ${language === 'pt-BR' ? 'PRÊMIO PRINCIPAL' : 'GRAND PRIZE'}`}</Text>
          </LinearGradient>
        </TouchableOpacity>
      </ScrollView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 56, paddingHorizontal: 18, paddingBottom: 12 },
  backText: { color: '#00f0ff', fontWeight: 'bold', fontSize: 16 },
  title: { fontSize: 28, fontWeight: 'bold', marginTop: 8 },
  subtitle: { color: '#ffffff99', marginTop: 4 },
  content: { padding: 16, gap: 12 },
  hero: { backgroundColor: '#ffffff12', borderWidth: 1, borderRadius: 14, padding: 16 },
  heroTitle: { color: '#ffffff', fontSize: 18, fontWeight: 'bold' },
  bonus: { marginTop: 8, fontWeight: 'bold' },
  grand: { color: '#ffd700', fontWeight: 'bold', marginTop: 8 },
  card: { backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#ffffff24', borderRadius: 12, padding: 14 },
  missionTitle: { color: '#ffffff', fontSize: 17, fontWeight: 'bold' },
  reward: { color: '#ffd700', fontWeight: 'bold', marginTop: 4 },
  progressBar: { height: 22, backgroundColor: '#00000055', borderRadius: 11, overflow: 'hidden', justifyContent: 'center', marginTop: 12 },
  progressFill: { position: 'absolute', left: 0, top: 0, bottom: 0 },
  progressText: { color: '#ffffff', fontSize: 12, fontWeight: 'bold', textAlign: 'center' },
  footer: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 12 },
  status: { color: '#ffffff88', fontWeight: 'bold' },
  claimButton: { borderRadius: 8, paddingVertical: 8, paddingHorizontal: 14 },
  claimText: { color: '#001018', fontWeight: 'bold' },
  grandButton: { height: 54, borderRadius: 12, overflow: 'hidden', marginTop: 8 },
  disabled: { opacity: 0.45 },
  buttonGradient: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  buttonText: { color: '#ffffff', fontWeight: 'bold' },
});

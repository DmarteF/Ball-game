import React, { useState } from 'react';
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { AdModal } from '@/src/components/AdModal';
import { useGame } from '@/src/contexts/GameContext';
import { RewardGrant, WHEEL_REWARDS, describeReward } from '@/src/game/retention';

export default function WheelScreen() {
  const router = useRouter();
  const game = useGame();
  const [reward, setReward] = useState<RewardGrant | null>(null);
  const [spinning, setSpinning] = useState(false);
  const [showAd, setShowAd] = useState(false);

  const spin = async (source: 'free' | 'ad') => {
    setSpinning(true);
    setTimeout(async () => {
      const result = await game.spinDailyWheel(source);
      if (result) setReward(result);
      setSpinning(false);
      setShowAd(false);
    }, 700);
  };

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}><Text style={styles.backText}>← VOLTAR</Text></TouchableOpacity>
        <Text style={styles.title}>ROLETA DIÁRIA</Text>
        <Text style={styles.subtitle}>1 giro grátis por dia • extras por anúncio</Text>
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.wheel}>
          {WHEEL_REWARDS.map((item, index) => (
            <View key={`${item.type}_${index}`} style={[styles.prizeCard, reward === item && styles.prizeCardActive]}>
              <Text style={styles.prizeText}>{describeReward(item)}</Text>
            </View>
          ))}
        </View>

        <View style={styles.resultBox}>
          <Text style={styles.resultTitle}>{spinning ? 'Girando...' : reward ? 'Prêmio revelado' : 'Pronto para girar'}</Text>
          <Text style={styles.resultReward}>{reward ? describeReward(reward) : '✨'}</Text>
        </View>

        <TouchableOpacity style={[styles.spinButton, (game.wheel.freeUsed || spinning) && styles.disabled]} disabled={game.wheel.freeUsed || spinning} onPress={() => spin('free')}>
          <LinearGradient colors={['#00f0ff', '#0088ff']} style={styles.buttonGradient}>
            <Text style={styles.buttonText}>{game.wheel.freeUsed ? 'GIRO GRÁTIS USADO' : 'GIRAR GRÁTIS'}</Text>
          </LinearGradient>
        </TouchableOpacity>

        <TouchableOpacity style={[styles.spinButton, (game.wheel.adSpinsUsed >= 2 || spinning) && styles.disabled]} disabled={game.wheel.adSpinsUsed >= 2 || spinning} onPress={() => setShowAd(true)}>
          <LinearGradient colors={['#ffd700', '#ff8800']} style={styles.buttonGradient}>
            <Text style={styles.buttonText}>GIRAR NOVAMENTE — AD ({game.wheel.adSpinsUsed}/2)</Text>
          </LinearGradient>
        </TouchableOpacity>
      </ScrollView>

      <AdModal visible={showAd} onClose={() => setShowAd(false)} onRewardClaimed={() => spin('ad')} rewardType="double" />
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 56, paddingHorizontal: 18, paddingBottom: 12 },
  backText: { color: '#00f0ff', fontWeight: 'bold', fontSize: 16 },
  title: { color: '#00f0ff', fontSize: 28, fontWeight: 'bold', marginTop: 8 },
  subtitle: { color: '#ffffff99', marginTop: 4 },
  content: { padding: 16, gap: 14 },
  wheel: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, justifyContent: 'center' },
  prizeCard: { width: '47%', minHeight: 70, borderRadius: 12, backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#ffffff24', justifyContent: 'center', alignItems: 'center', padding: 10 },
  prizeCardActive: { borderColor: '#ffd700', backgroundColor: '#ffd70026' },
  prizeText: { color: '#ffffff', fontWeight: 'bold', textAlign: 'center' },
  resultBox: { backgroundColor: '#ffffff12', borderRadius: 14, borderWidth: 1, borderColor: '#00f0ff66', alignItems: 'center', padding: 20 },
  resultTitle: { color: '#ffffffaa', fontWeight: 'bold' },
  resultReward: { color: '#ffd700', fontSize: 28, fontWeight: 'bold', marginTop: 8 },
  spinButton: { height: 54, borderRadius: 12, overflow: 'hidden' },
  disabled: { opacity: 0.45 },
  buttonGradient: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  buttonText: { color: '#ffffff', fontWeight: 'bold' },
});

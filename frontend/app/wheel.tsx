import React, { useMemo, useRef, useState } from 'react';
import { Animated, Modal, ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { AdModal } from '@/src/components/AdModal';
import { useGame } from '@/src/contexts/GameContext';
import { RewardGrant, WHEEL_REWARDS, describeReward } from '@/src/game/retention';
import { playSound } from '@/src/utils/audio';

const segmentColors = ['#00f0ff', '#ffd700', '#ff4fd8', '#00ff88', '#8b5cf6', '#ff8800', '#60a5fa', '#ff0055'];

export default function WheelScreen() {
  const router = useRouter();
  const game = useGame();
  const spinValue = useRef(new Animated.Value(0)).current;
  const spinTurns = useRef(0);
  const [reward, setReward] = useState<RewardGrant | null>(null);
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);
  const [spinning, setSpinning] = useState(false);
  const [showAd, setShowAd] = useState(false);
  const [resultVisible, setResultVisible] = useState(false);

  const wheelRewards = useMemo(() => WHEEL_REWARDS.slice(0, 10), []);
  const rotate = spinValue.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg'],
  });

  const spin = async (source: 'free' | 'ad') => {
    if (spinning) return;
    setSpinning(true);
    setReward(null);
    setResultVisible(false);
    playSound('buttonConfirm', game.settings.sound);
    const result = await game.spinDailyWheel(source);
    if (!result) {
      playSound('buttonError', game.settings.sound);
      setSpinning(false);
      setShowAd(false);
      return;
    }
    const index = Math.max(0, wheelRewards.findIndex(item => describeReward(item) === describeReward(result)));
    const segment = 1 / wheelRewards.length;
    const target = spinTurns.current + 5 + (1 - index * segment) - segment / 2;
    spinTurns.current = target;
    Animated.timing(spinValue, {
      toValue: target,
      duration: 3600,
      useNativeDriver: true,
    }).start(() => {
      setSelectedIndex(index);
      setReward(result);
      setResultVisible(true);
      setSpinning(false);
      setShowAd(false);
      playSound(result.type === 'gems' ? 'diamondGain' : result.type === 'chest' ? 'chestOpen' : 'coinGain', game.settings.sound);
    });
  };

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}><Text style={styles.backText}>← VOLTAR</Text></TouchableOpacity>
        <Text style={styles.title}>ROLETA DIÁRIA</Text>
        <Text style={styles.subtitle}>1 giro grátis por dia • até 2 extras por anúncio simulado</Text>
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.wheelShell}>
          <View style={styles.pointer} />
          <Animated.View style={[styles.wheel, { transform: [{ rotate }] }]}>
            {wheelRewards.map((item, index) => {
              const angle = `${(360 / wheelRewards.length) * index}deg`;
              const active = selectedIndex === index;
              return (
                <View key={`${item.type}_${index}`} style={[styles.segmentAnchor, { transform: [{ rotate: angle }] }]}>
                  <View style={[styles.segment, { backgroundColor: segmentColors[index % segmentColors.length] + '33', borderColor: active ? '#ffffff' : segmentColors[index % segmentColors.length] }]}>
                    <Text style={styles.segmentText}>{describeReward(item)}</Text>
                  </View>
                </View>
              );
            })}
            <View style={styles.hub}>
              <Text style={styles.hubText}>{spinning ? '...' : 'NEON'}</Text>
            </View>
          </Animated.View>
        </View>

        <View style={styles.resultBox}>
          <Text style={styles.resultTitle}>{spinning ? 'Girando e desacelerando...' : reward ? 'Prêmio selecionado' : 'Toque para girar'}</Text>
          <Text style={styles.resultReward}>{reward ? describeReward(reward) : '🎡'}</Text>
        </View>

        <TouchableOpacity style={[styles.spinButton, (game.wheel.freeUsed || spinning) && styles.disabled]} disabled={game.wheel.freeUsed || spinning} onPress={() => spin('free')}>
          <LinearGradient colors={['#00f0ff', '#0088ff']} style={styles.buttonGradient}>
            <Text style={styles.buttonText}>{game.wheel.freeUsed ? 'GIRO GRÁTIS USADO' : 'GIRAR'}</Text>
          </LinearGradient>
        </TouchableOpacity>

        <TouchableOpacity style={[styles.spinButton, (game.wheel.adSpinsUsed >= 2 || spinning) && styles.disabled]} disabled={game.wheel.adSpinsUsed >= 2 || spinning} onPress={() => setShowAd(true)}>
          <LinearGradient colors={['#ffd700', '#ff8800']} style={styles.buttonGradient}>
            <Text style={styles.buttonText}>GIRAR NOVAMENTE COM ANÚNCIO ({game.wheel.adSpinsUsed}/2)</Text>
          </LinearGradient>
        </TouchableOpacity>
      </ScrollView>

      <Modal visible={resultVisible} transparent animationType="fade" onRequestClose={() => setResultVisible(false)}>
        <View style={styles.modalOverlay}>
          <View style={styles.resultModal}>
            <Text style={styles.modalTitle}>PRÊMIO DA ROLETA</Text>
            <Text style={styles.modalReward}>{reward ? describeReward(reward) : ''}</Text>
            <TouchableOpacity style={styles.modalButton} onPress={() => setResultVisible(false)}>
              <Text style={styles.modalButtonText}>COLETAR</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>

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
  content: { padding: 16, gap: 14, alignItems: 'center' },
  wheelShell: { width: 304, height: 326, alignItems: 'center', justifyContent: 'flex-end' },
  pointer: { width: 0, height: 0, borderLeftWidth: 15, borderRightWidth: 15, borderTopWidth: 30, borderLeftColor: 'transparent', borderRightColor: 'transparent', borderTopColor: '#ffd700', zIndex: 3, marginBottom: -12 },
  wheel: { width: 292, height: 292, borderRadius: 146, borderWidth: 4, borderColor: '#00f0ffaa', backgroundColor: '#ffffff10', alignItems: 'center', justifyContent: 'center', shadowColor: '#00f0ff', shadowOpacity: 0.8, shadowRadius: 18 },
  segmentAnchor: { position: 'absolute', width: 292, height: 292, alignItems: 'center' },
  segment: { width: 82, minHeight: 48, borderRadius: 10, borderWidth: 1, alignItems: 'center', justifyContent: 'center', padding: 5, marginTop: 12 },
  segmentText: { color: '#ffffff', fontSize: 9, fontWeight: 'bold', textAlign: 'center' },
  hub: { width: 86, height: 86, borderRadius: 43, backgroundColor: '#050516', borderWidth: 2, borderColor: '#ffd700', alignItems: 'center', justifyContent: 'center' },
  hubText: { color: '#ffd700', fontWeight: 'bold' },
  resultBox: { width: '100%', backgroundColor: '#ffffff12', borderRadius: 14, borderWidth: 1, borderColor: '#00f0ff66', alignItems: 'center', padding: 20 },
  resultTitle: { color: '#ffffffaa', fontWeight: 'bold' },
  resultReward: { color: '#ffd700', fontSize: 25, fontWeight: 'bold', marginTop: 8, textAlign: 'center' },
  spinButton: { width: '100%', height: 54, borderRadius: 12, overflow: 'hidden' },
  disabled: { opacity: 0.45 },
  buttonGradient: { flex: 1, justifyContent: 'center', alignItems: 'center', paddingHorizontal: 10 },
  buttonText: { color: '#ffffff', fontWeight: 'bold', textAlign: 'center' },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', justifyContent: 'center', alignItems: 'center', padding: 18 },
  resultModal: { width: '100%', maxWidth: 380, backgroundColor: '#1a0a2e', borderWidth: 1, borderColor: '#ffd700aa', borderRadius: 18, padding: 22, alignItems: 'center' },
  modalTitle: { color: '#ffd700', fontSize: 22, fontWeight: 'bold' },
  modalReward: { color: '#ffffff', fontSize: 24, fontWeight: 'bold', marginVertical: 18, textAlign: 'center' },
  modalButton: { width: '100%', backgroundColor: '#00f0ff', borderRadius: 12, padding: 14, alignItems: 'center' },
  modalButtonText: { color: '#001018', fontWeight: 'bold' },
});

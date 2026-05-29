import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useGame } from '@/src/contexts/GameContext';
import { PHASES } from '@/src/game/phases';
import { playSound } from '@/src/utils/audio';

export default function PhaseSelectScreen() {
  const router = useRouter();
  const game = useGame();
  const { unlockedPhases } = game;
  const infiniteUnlocked = unlockedPhases.includes(6) || game.lifetimeStats.highestPhase >= 5;

  const handlePhaseSelect = (phaseId: number) => {
    if (unlockedPhases.includes(phaseId)) {
      router.push(`/game?phase=${phaseId}`);
    }
  };

  const handleInfiniteSelect = () => {
    if (!infiniteUnlocked) {
      playSound('buttonError', game.settings.sound);
      return;
    }
    playSound('buttonConfirm', game.settings.sound);
    router.push('/infinite' as any);
  };

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
          <Text style={styles.backText}>← VOLTAR</Text>
        </TouchableOpacity>
        <Text style={styles.title}>SELECIONAR FASE</Text>
      </View>

      <ScrollView style={styles.scrollView} contentContainerStyle={styles.phaseList}>
        <TouchableOpacity style={styles.phaseCard} onPress={handleInfiniteSelect}>
          <LinearGradient colors={infiniteUnlocked ? ['#00ff8888', '#00f0ff33'] : ['#333333', '#222222']} style={styles.cardGradient}>
            <View style={styles.phaseNumber}><Text style={styles.phaseNumberText}>∞</Text></View>
            <View style={styles.phaseInfo}>
              <Text style={[styles.phaseName, !infiniteUnlocked && styles.lockedText]}>Modo Infinito</Text>
              <Text style={[styles.phaseDescription, !infiniteUnlocked && styles.lockedText]}>{infiniteUnlocked ? 'Ondas sem fim com desafios progressivos.' : 'Complete a Fase 5 para desbloquear.'}</Text>
              <View style={styles.phaseStats}>
                <Text style={[styles.phaseDifficulty, !infiniteUnlocked && styles.lockedText]}>Especial</Text>
                <Text style={[styles.phaseHP, !infiniteUnlocked && styles.lockedText]}>Progressão infinita</Text>
              </View>
            </View>
            {!infiniteUnlocked && <View style={styles.lockOverlay}><Text style={styles.lockText}>🔒 FASE 5</Text></View>}
          </LinearGradient>
        </TouchableOpacity>
        {PHASES.map(phase => {
          const isUnlocked = unlockedPhases.includes(phase.id);
          return (
            <TouchableOpacity key={phase.id} style={styles.phaseCard} onPress={() => handlePhaseSelect(phase.id)} disabled={!isUnlocked}>
              <LinearGradient colors={isUnlocked ? [phase.color + '88', phase.color + '44'] : ['#333333', '#222222']} style={styles.cardGradient}>
                <View style={styles.phaseNumber}><Text style={styles.phaseNumberText}>{phase.id}</Text></View>
                <View style={styles.phaseInfo}>
                  <Text style={[styles.phaseName, !isUnlocked && styles.lockedText]}>{phase.name}</Text>
                  <Text style={[styles.phaseDescription, !isUnlocked && styles.lockedText]}>{phase.description}</Text>
                  <View style={styles.phaseStats}>
                    <Text style={[styles.phaseDifficulty, !isUnlocked && styles.lockedText]}>Dificuldade: {phase.difficulty}</Text>
                    <Text style={[styles.phaseHP, !isUnlocked && styles.lockedText]}>{phase.ringMin}-{phase.ringMax} anéis • HP {phase.baseHp}</Text>
                  </View>
                </View>
                {!isUnlocked && <View style={styles.lockOverlay}><Text style={styles.lockText}>🔒 BLOQUEADO</Text></View>}
              </LinearGradient>
            </TouchableOpacity>
          );
        })}
      </ScrollView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 60, paddingHorizontal: 20, paddingBottom: 20 },
  backButton: { marginBottom: 10 },
  backText: { color: '#00f0ff', fontSize: 16, fontWeight: 'bold' },
  title: { fontSize: 32, fontWeight: 'bold', color: '#00f0ff' },
  scrollView: { flex: 1 },
  phaseList: { padding: 20, gap: 16 },
  phaseCard: { height: 140, borderRadius: 16, overflow: 'hidden' },
  cardGradient: { flex: 1, flexDirection: 'row', padding: 20, borderWidth: 2, borderColor: '#ffffff22' },
  phaseNumber: { width: 60, height: 60, borderRadius: 30, backgroundColor: '#ffffff22', justifyContent: 'center', alignItems: 'center', marginRight: 16 },
  phaseNumberText: { fontSize: 32, fontWeight: 'bold', color: '#ffffff' },
  phaseInfo: { flex: 1, justifyContent: 'center' },
  phaseName: { fontSize: 20, fontWeight: 'bold', color: '#ffffff', marginBottom: 4 },
  phaseDescription: { fontSize: 14, color: '#ffffffaa', marginBottom: 8 },
  phaseStats: { flexDirection: 'row', gap: 16 },
  phaseDifficulty: { fontSize: 12, color: '#ffffff88', textTransform: 'uppercase' },
  phaseHP: { fontSize: 12, color: '#ffffff88' },
  lockedText: { opacity: 0.3 },
  lockOverlay: { position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: '#00000066', justifyContent: 'center', alignItems: 'center' },
  lockText: { fontSize: 18, fontWeight: 'bold', color: '#ffffff' },
});

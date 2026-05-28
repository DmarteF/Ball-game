import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';

const TRANSFORMATIONS = [
  { id: 'neon_blue', name: 'Neon Azul', colors: ['#00f0ff', '#0088ff'], unlocked: true, cost: 0 },
  { id: 'plasma_purple', name: 'Plasma Roxo', colors: ['#b000ff', '#6600cc'], unlocked: false, cost: 500 },
  { id: 'infernal_red', name: 'Infernal Vermelho', colors: ['#ff0055', '#cc0000'], unlocked: false, cost: 1000 },
  { id: 'electric', name: 'Elétrica', colors: ['#ffff00', '#00ffff'], unlocked: false, cost: 1500 },
  { id: 'glitch', name: 'Glitch', colors: ['#ff00ff', '#00ff00'], unlocked: false, cost: 2000 },
  { id: 'golden', name: 'Dourada', colors: ['#ffd700', '#ffaa00'], unlocked: false, cost: 3000 },
  { id: 'crystal', name: 'Cristalina', colors: ['#ffffff', '#aaffff'], unlocked: false, cost: 3500 },
  { id: 'shadow', name: 'Sombria', colors: ['#666666', '#000000'], unlocked: false, cost: 4000 },
  { id: 'radioactive', name: 'Radioativa', colors: ['#00ff00', '#88ff00'], unlocked: false, cost: 5000 },
  { id: 'cosmic', name: 'Cósmica', colors: ['#ff00ff', '#0088ff'], unlocked: false, cost: 10000 },
];

export default function TransformationsScreen() {
  const router = useRouter();
  const [gems, setGems] = useState(5000); // Mock gems
  const [selected, setSelected] = useState('neon_blue');
  const [unlockedTransformations, setUnlockedTransformations] = useState(['neon_blue']);

  const unlockTransformation = (transformation: any) => {
    if (gems >= transformation.cost && !unlockedTransformations.includes(transformation.id)) {
      setGems(prev => prev - transformation.cost);
      setUnlockedTransformations(prev => [...prev, transformation.id]);
      setSelected(transformation.id);
    }
  };

  return (
    <LinearGradient colors={['#0a0a1a', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
          <Text style={styles.backText}>← VOLTAR</Text>
        </TouchableOpacity>
        <Text style={styles.title}>TRANSFORMAÇÕES</Text>
        <View style={styles.gemsDisplay}>
          <Text style={styles.gemsText}>💎 {gems}</Text>
        </View>
      </View>

      <ScrollView style={styles.scrollView} contentContainerStyle={styles.transformationList}>
        {TRANSFORMATIONS.map((transformation) => {
          const isUnlocked = unlockedTransformations.includes(transformation.id);
          const isSelected = selected === transformation.id;

          return (
            <TouchableOpacity
              key={transformation.id}
              style={styles.transformationCard}
              onPress={() => isUnlocked ? setSelected(transformation.id) : unlockTransformation(transformation)}
            >
              <LinearGradient
                colors={isUnlocked ? [...transformation.colors, transformation.colors[0] + '44'] : ['#333333', '#222222']}
                style={[styles.cardGradient, isSelected && styles.selectedCard]}
              >
                <View style={styles.previewBall}>
                  <LinearGradient
                    colors={transformation.colors}
                    style={styles.ballGradient}
                  />
                </View>
                
                <View style={styles.transformationInfo}>
                  <Text style={[styles.transformationName, !isUnlocked && styles.lockedText]}>
                    {transformation.name}
                  </Text>
                  {isSelected && (
                    <Text style={styles.selectedBadge}>✓ EQUIPADO</Text>
                  )}
                </View>
                
                {!isUnlocked && (
                  <View style={styles.unlockButton}>
                    <Text style={styles.unlockText}>💎 {transformation.cost}</Text>
                  </View>
                )}
                
                {!isUnlocked && (
                  <View style={styles.lockOverlay}>
                    <Text style={styles.lockIcon}>🔒</Text>
                  </View>
                )}
              </LinearGradient>
            </TouchableOpacity>
          );
        })}
      </ScrollView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    paddingTop: 60,
    paddingHorizontal: 20,
    paddingBottom: 20,
  },
  backButton: {
    marginBottom: 10,
  },
  backText: {
    color: '#00f0ff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#00f0ff',
    textShadowColor: '#00f0ff',
    textShadowOffset: { width: 0, height: 0 },
    textShadowRadius: 10,
    marginBottom: 16,
  },
  gemsDisplay: {
    backgroundColor: '#ffffff22',
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 12,
    alignSelf: 'flex-start',
    borderWidth: 2,
    borderColor: '#ff00ff44',
  },
  gemsText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#ff00ff',
  },
  scrollView: {
    flex: 1,
  },
  transformationList: {
    padding: 20,
    gap: 16,
  },
  transformationCard: {
    height: 120,
    borderRadius: 16,
    overflow: 'hidden',
  },
  cardGradient: {
    flex: 1,
    flexDirection: 'row',
    padding: 20,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#ffffff22',
  },
  selectedCard: {
    borderColor: '#00ff00',
    borderWidth: 3,
  },
  previewBall: {
    width: 60,
    height: 60,
    borderRadius: 30,
    overflow: 'hidden',
    marginRight: 20,
  },
  ballGradient: {
    flex: 1,
  },
  transformationInfo: {
    flex: 1,
  },
  transformationName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#ffffff',
  },
  selectedBadge: {
    fontSize: 12,
    color: '#00ff00',
    fontWeight: 'bold',
    marginTop: 4,
  },
  lockedText: {
    opacity: 0.3,
  },
  unlockButton: {
    backgroundColor: '#ffffff22',
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 8,
  },
  unlockText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#ffffff',
  },
  lockOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: '#00000066',
    justifyContent: 'center',
    alignItems: 'center',
  },
  lockIcon: {
    fontSize: 32,
  },
});

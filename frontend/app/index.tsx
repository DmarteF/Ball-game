import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useGame } from '@/src/contexts/GameContext';

export default function HomeScreen() {
  const router = useRouter();
  const { coins, gems, level, loading } = useGame();

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
      {/* Top Stats Bar */}
      <View style={styles.topBar}>
        <View style={styles.statBadge}>
          <Text style={styles.statIcon}>💰</Text>
          <Text style={styles.statText}>{coins}</Text>
        </View>
        <View style={styles.statBadge}>
          <Text style={styles.statIcon}>💎</Text>
          <Text style={styles.statText}>{gems}</Text>
        </View>
        <View style={styles.statBadge}>
          <Text style={styles.statIcon}>🔑</Text>
          <Text style={styles.statText}>0</Text>
        </View>
      </View>

      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        {/* Title */}
        <View style={styles.titleContainer}>
          <Text style={styles.title}>NEON</Text>
          <Text style={styles.subtitle}>IDLE ESCAPE</Text>
          <View style={styles.divider} />
        </View>

        {/* Primary Action - Play */}
        <TouchableOpacity
          style={styles.primaryButton}
          onPress={() => router.push('/phase-select')}
        >
          <LinearGradient
            colors={['#00f0ff', '#0088ff']}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={styles.primaryButtonGradient}
          >
            <Text style={styles.playIcon}>▶</Text>
            <Text style={styles.primaryButtonText}>JOGAR</Text>
          </LinearGradient>
        </TouchableOpacity>

        {/* Secondary Actions Grid */}
        <View style={styles.gridContainer}>
          <TouchableOpacity
            style={styles.gridButton}
            onPress={() => router.push('/upgrade-shop')}
          >
            <LinearGradient
              colors={['#b000ff66', '#6600cc44']}
              style={styles.gridButtonGradient}
            >
              <Text style={styles.gridIcon}>⚔️</Text>
              <Text style={styles.gridText}>UPGRADES</Text>
            </LinearGradient>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.gridButton}
            onPress={() => router.push('/transformations')}
          >
            <LinearGradient
              colors={['#ff008866', '#cc006644']}
              style={styles.gridButtonGradient}
            >
              <Text style={styles.gridIcon}>✨</Text>
              <Text style={styles.gridText}>SKINS</Text>
            </LinearGradient>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.gridButton}
            onPress={() => router.push('/inventory')}
          >
            <LinearGradient
              colors={['#00ff8866', '#00cc6644']}
              style={styles.gridButtonGradient}
            >
              <Text style={styles.gridIcon}>🎁</Text>
              <Text style={styles.gridText}>BAÚS</Text>
            </LinearGradient>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.gridButton}
            onPress={() => router.push('/stats')}
          >
            <LinearGradient
              colors={['#ffd70066', '#ffaa0044']}
              style={styles.gridButtonGradient}
            >
              <Text style={styles.gridIcon}>📊</Text>
              <Text style={styles.gridText}>STATS</Text>
            </LinearGradient>
          </TouchableOpacity>
        </View>

        {/* Daily Rewards */}
        <TouchableOpacity style={styles.dailyButton}>
          <LinearGradient
            colors={['#ffd700', '#ff8800']}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 0 }}
            style={styles.dailyGradient}
          >
            <Text style={styles.dailyIcon}>🎁</Text>
            <View style={styles.dailyTextContainer}>
              <Text style={styles.dailyTitle}>RECOMPENSA DIÁRIA</Text>
              <Text style={styles.dailySubtitle}>Toque para coletar!</Text>
            </View>
            <Text style={styles.dailyArrow}>▶</Text>
          </LinearGradient>
        </TouchableOpacity>

        {/* Footer Info */}
        <View style={styles.footer}>
          <Text style={styles.footerText}>v1.0.0 - Neon Edition</Text>
        </View>
      </ScrollView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    color: '#00f0ff',
    fontSize: 16,
    marginTop: 16,
  },
  topBar: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingTop: 50,
    paddingHorizontal: 20,
    paddingBottom: 10,
  },
  statBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#ffffff11',
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#ffffff22',
    gap: 8,
  },
  statIcon: {
    fontSize: 18,
  },
  statText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#ffffff',
  },
  content: {
    flexGrow: 1,
    paddingHorizontal: 20,
    paddingBottom: 40,
  },
  titleContainer: {
    alignItems: 'center',
    marginVertical: 40,
  },
  title: {
    fontSize: 72,
    fontWeight: 'bold',
    color: '#00f0ff',
    textShadowColor: '#00f0ff',
    textShadowOffset: { width: 0, height: 0 },
    textShadowRadius: 20,
    letterSpacing: 8,
  },
  subtitle: {
    fontSize: 24,
    fontWeight: '300',
    color: '#ffffff',
    letterSpacing: 10,
    marginTop: 4,
  },
  divider: {
    width: 100,
    height: 2,
    backgroundColor: '#00f0ff',
    marginTop: 16,
    shadowColor: '#00f0ff',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 1,
    shadowRadius: 10,
  },
  primaryButton: {
    width: '100%',
    height: 80,
    borderRadius: 16,
    overflow: 'hidden',
    marginBottom: 20,
    shadowColor: '#00f0ff',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 1,
    shadowRadius: 20,
  },
  primaryButtonGradient: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 12,
  },
  playIcon: {
    fontSize: 32,
    color: '#ffffff',
  },
  primaryButtonText: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#ffffff',
    letterSpacing: 4,
  },
  gridContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
    marginBottom: 20,
  },
  gridButton: {
    width: '48%',
    height: 100,
    borderRadius: 16,
    overflow: 'hidden',
  },
  gridButtonGradient: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#ffffff22',
  },
  gridIcon: {
    fontSize: 32,
    marginBottom: 4,
  },
  gridText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#ffffff',
    letterSpacing: 2,
  },
  dailyButton: {
    width: '100%',
    height: 80,
    borderRadius: 16,
    overflow: 'hidden',
    marginBottom: 20,
  },
  dailyGradient: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    gap: 16,
  },
  dailyIcon: {
    fontSize: 40,
  },
  dailyTextContainer: {
    flex: 1,
  },
  dailyTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#000000',
    letterSpacing: 2,
  },
  dailySubtitle: {
    fontSize: 12,
    color: '#000000aa',
    marginTop: 2,
  },
  dailyArrow: {
    fontSize: 24,
    color: '#000000',
  },
  footer: {
    alignItems: 'center',
    marginTop: 20,
  },
  footerText: {
    color: '#666',
    fontSize: 12,
  },
});

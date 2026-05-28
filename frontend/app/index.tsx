import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ImageBackground } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';

export default function HomeScreen() {
  const router = useRouter();

  return (
    <LinearGradient
      colors={['#0a0a1a', '#1a0a2e', '#16003b']}
      style={styles.container}
    >
      <View style={styles.content}>
        <View style={styles.titleContainer}>
          <Text style={styles.title}>NEON</Text>
          <Text style={styles.subtitle}>IDLE ESCAPE</Text>
        </View>

        <View style={styles.menuContainer}>
          <TouchableOpacity
            style={styles.menuButton}
            onPress={() => router.push('/phase-select')}
          >
            <LinearGradient
              colors={['#00f0ff', '#0088ff']}
              style={styles.buttonGradient}
            >
              <Text style={styles.buttonText}>JOGAR</Text>
            </LinearGradient>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.menuButton}
            onPress={() => router.push('/upgrade-shop')}
          >
            <LinearGradient
              colors={['#b000ff', '#6600cc']}
              style={styles.buttonGradient}
            >
              <Text style={styles.buttonText}>UPGRADES</Text>
            </LinearGradient>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.menuButton}
            onPress={() => router.push('/transformations')}
          >
            <LinearGradient
              colors={['#ff0088', '#cc0066']}
              style={styles.buttonGradient}
            >
              <Text style={styles.buttonText}>TRANSFORMAÇÕES</Text>
            </LinearGradient>
          </TouchableOpacity>
        </View>

        <View style={styles.footer}>
          <Text style={styles.footerText}>v1.0.0 - MVP</Text>
        </View>
      </View>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  titleContainer: {
    alignItems: 'center',
    marginBottom: 80,
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
    fontSize: 28,
    fontWeight: '300',
    color: '#ffffff',
    letterSpacing: 12,
    marginTop: 10,
  },
  menuContainer: {
    width: '100%',
    maxWidth: 400,
    gap: 20,
  },
  menuButton: {
    width: '100%',
    height: 60,
    borderRadius: 12,
    overflow: 'hidden',
  },
  buttonGradient: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  buttonText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#ffffff',
    letterSpacing: 2,
  },
  footer: {
    position: 'absolute',
    bottom: 20,
  },
  footerText: {
    color: '#666',
    fontSize: 12,
  },
});

import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Modal } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';

interface AdModalProps {
  visible: boolean;
  onClose: () => void;
  onRewardClaimed: () => void;
  rewardType: 'coins' | 'gems' | 'key' | 'chest' | 'revive' | 'double';
  rewardAmount?: number;
}

export const AdModal: React.FC<AdModalProps> = ({
  visible,
  onClose,
  onRewardClaimed,
  rewardType,
  rewardAmount = 100,
}) => {
  const [adWatching, setAdWatching] = useState(false);
  const [countdown, setCountdown] = useState(5);

  useEffect(() => {
    if (adWatching && countdown > 0) {
      const timer = setTimeout(() => setCountdown(countdown - 1), 1000);
      return () => clearTimeout(timer);
    } else if (adWatching && countdown === 0) {
      handleAdComplete();
    }
  }, [adWatching, countdown]);

  const handleWatchAd = () => {
    setAdWatching(true);
    setCountdown(5);
  };

  const handleAdComplete = () => {
    setAdWatching(false);
    setCountdown(5);
    onRewardClaimed();
    onClose();
  };

  const handleSkip = () => {
    setAdWatching(false);
    setCountdown(5);
    onClose();
  };

  const getRewardText = () => {
    switch (rewardType) {
      case 'coins':
        return `+${rewardAmount} Moedas`;
      case 'gems':
        return `+${rewardAmount} Gemas`;
      case 'revive':
        return 'Reviver';
      case 'key':
        return `+${rewardAmount} Chave`;
      case 'chest':
        return 'Baú grátis';
      case 'double':
        return 'Dobrar Recompensa';
      default:
        return 'Recompensa';
    }
  };

  const getRewardIcon = () => {
    switch (rewardType) {
      case 'coins':
        return '💰';
      case 'gems':
        return '💎';
      case 'revive':
        return '❤️';
      case 'key':
        return '🔑';
      case 'chest':
        return '🎁';
      case 'double':
        return '✨';
      default:
        return '🎁';
    }
  };

  return (
    <Modal
      visible={visible}
      transparent
      animationType="fade"
      onRequestClose={handleSkip}
    >
      <View style={styles.overlay}>
        <View style={styles.modalContainer}>
          {!adWatching ? (
            // Offer screen
            <>
              <LinearGradient
                colors={['#1a0a2e', '#16003b']}
                style={styles.modalContent}
              >
                <Text style={styles.icon}>{getRewardIcon()}</Text>
                <Text style={styles.title}>Assistir Anúncio?</Text>
                <Text style={styles.description}>
                  Assista um anúncio de 5 segundos para ganhar:
                </Text>
                <Text style={styles.reward}>{getRewardText()}</Text>

                <TouchableOpacity
                  style={styles.watchButton}
                  onPress={handleWatchAd}
                >
                  <LinearGradient
                    colors={['#00f0ff', '#0088ff']}
                    style={styles.buttonGradient}
                  >
                    <Text style={styles.buttonText}>📺 ASSISTIR ANÚNCIO</Text>
                  </LinearGradient>
                </TouchableOpacity>

                <TouchableOpacity
                  style={styles.skipButton}
                  onPress={handleSkip}
                >
                  <Text style={styles.skipText}>Não, obrigado</Text>
                </TouchableOpacity>
              </LinearGradient>
            </>
          ) : (
            // Ad watching screen
            <>
              <LinearGradient
                colors={['#000000', '#1a1a1a']}
                style={styles.adScreen}
              >
                <Text style={styles.adTitle}>ANÚNCIO SIMULADO</Text>
                <Text style={styles.adSubtitle}>
                  (Na versão final, aqui aparecerá um anúncio real)
                </Text>
                
                <View style={styles.adContent}>
                  <Text style={styles.adEmoji}>📱</Text>
                  <Text style={styles.adText}>Baixe nosso app!</Text>
                  <Text style={styles.adDescription}>
                    O melhor aplicativo de exemplo para demonstração
                  </Text>
                </View>

                <View style={styles.countdownContainer}>
                  <Text style={styles.countdownText}>
                    Você pode fechar em {countdown}s
                  </Text>
                  <View style={styles.progressBar}>
                    <View 
                      style={[
                        styles.progressFill, 
                        { width: `${((5 - countdown) / 5) * 100}%` }
                      ]} 
                    />
                  </View>
                </View>
              </LinearGradient>
            </>
          )}
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.9)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContainer: {
    width: '90%',
    maxWidth: 400,
    borderRadius: 20,
    overflow: 'hidden',
  },
  modalContent: {
    padding: 30,
    alignItems: 'center',
  },
  icon: {
    fontSize: 64,
    marginBottom: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#00f0ff',
    marginBottom: 10,
    textAlign: 'center',
  },
  description: {
    fontSize: 16,
    color: '#ffffffaa',
    textAlign: 'center',
    marginBottom: 20,
  },
  reward: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#ffd700',
    marginBottom: 30,
  },
  watchButton: {
    width: '100%',
    height: 60,
    borderRadius: 12,
    overflow: 'hidden',
    marginBottom: 16,
  },
  buttonGradient: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  buttonText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#ffffff',
  },
  skipButton: {
    padding: 12,
  },
  skipText: {
    fontSize: 16,
    color: '#ffffff66',
  },
  adScreen: {
    padding: 40,
    alignItems: 'center',
    minHeight: 400,
    justifyContent: 'space-between',
  },
  adTitle: {
    fontSize: 12,
    color: '#666',
    letterSpacing: 2,
  },
  adSubtitle: {
    fontSize: 10,
    color: '#444',
    textAlign: 'center',
    marginTop: 5,
  },
  adContent: {
    alignItems: 'center',
    flex: 1,
    justifyContent: 'center',
  },
  adEmoji: {
    fontSize: 80,
    marginBottom: 20,
  },
  adText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#ffffff',
    marginBottom: 10,
  },
  adDescription: {
    fontSize: 14,
    color: '#999',
    textAlign: 'center',
  },
  countdownContainer: {
    width: '100%',
  },
  countdownText: {
    fontSize: 14,
    color: '#ffffff',
    textAlign: 'center',
    marginBottom: 10,
  },
  progressBar: {
    height: 4,
    backgroundColor: '#333',
    borderRadius: 2,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#00f0ff',
  },
});

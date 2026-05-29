import React, { useEffect, useRef, useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Modal } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { UiIcon } from '@/src/components/UiIcon';
import { UiIconKey } from '@/src/game/uiIcons';
import { RewardedAdPlacement, showRewardedAd } from '@/src/services/adsService';

interface AdModalProps {
  visible: boolean;
  onClose: () => void;
  onRewardClaimed: () => void | Promise<void>;
  rewardType: 'coins' | 'gems' | 'key' | 'chest' | 'revive' | 'double';
  rewardAmount?: number;
  placement?: RewardedAdPlacement;
}

export const AdModal: React.FC<AdModalProps> = ({
  visible,
  onClose,
  onRewardClaimed,
  rewardType,
  rewardAmount = 100,
  placement = 'double_run_reward',
}) => {
  const [adWatching, setAdWatching] = useState(false);
  const [feedback, setFeedback] = useState('');
  const rewardedRef = useRef(false);

  useEffect(() => {
    if (!visible) {
      setAdWatching(false);
      setFeedback('');
      rewardedRef.current = false;
    }
  }, [visible]);

  const handleWatchAd = async () => {
    if (adWatching) return;
    setAdWatching(true);
    setFeedback('Carregando anúncio...');
    const result = await showRewardedAd(placement);
    setAdWatching(false);
    if (!result.success) {
      setFeedback(result.error || 'Anúncio indisponível. Tente novamente em instantes.');
      return;
    }
    if (!rewardedRef.current) {
      rewardedRef.current = true;
      await onRewardClaimed();
      onClose();
    }
  };

  const handleSkip = () => {
    setAdWatching(false);
    setFeedback('');
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

  const getRewardIconKey = (): UiIconKey => {
    switch (rewardType) {
      case 'coins':
        return 'ui_coin';
      case 'gems':
        return 'ui_gem';
      case 'key':
        return 'ui_key';
      case 'chest':
        return 'ui_chest_common';
      case 'double':
        return 'ui_daily_reward';
      case 'revive':
      default:
        return 'ui_effect';
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
                <UiIcon iconKey={getRewardIconKey()} fallback={getRewardIcon()} size={58} style={styles.icon} />
                <Text style={styles.title}>Assistir Anúncio?</Text>
                <Text style={styles.description}>Assista ao vídeo até o fim para ganhar:</Text>
                <Text style={styles.reward}>{getRewardText()}</Text>
                {!!feedback && <Text style={styles.feedback}>{feedback}</Text>}

                <TouchableOpacity
                  style={[styles.watchButton, adWatching && styles.disabled]}
                  onPress={handleWatchAd}
                  disabled={adWatching}
                >
                  <LinearGradient
                    colors={['#00f0ff', '#0088ff']}
                    style={styles.buttonGradient}
                  >
                    <UiIcon iconKey="ui_ad" fallback="📺" size={18} />
                    <Text style={styles.buttonText}>ASSISTIR ANÚNCIO</Text>
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
                <Text style={styles.adTitle}>CARREGANDO ANÚNCIO</Text>
                <Text style={styles.adSubtitle}>
                  A recompensa só é liberada ao concluir o vídeo.
                </Text>
                
                <View style={styles.adContent}>
                  <UiIcon iconKey="ui_ad" fallback="📺" size={64} />
                  <Text style={styles.adText}>Abrindo vídeo premiado</Text>
                  <Text style={styles.adDescription}>Não feche antes da recompensa aparecer.</Text>
                </View>

                <View style={styles.countdownContainer}>
                  <Text style={styles.countdownText}>{feedback || 'Aguardando conclusão do anúncio'}</Text>
                  <View style={styles.progressBar}>
                    <View style={[styles.progressFill, { width: '72%' }]} />
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
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 8,
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
  feedback: {
    color: '#ffd700',
    fontSize: 13,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 14,
  },
  disabled: {
    opacity: 0.55,
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

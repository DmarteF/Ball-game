import React, { memo } from 'react';
import { StyleProp, StyleSheet, TouchableOpacity, ViewStyle } from 'react-native';
import { UiIcon } from '@/src/components/UiIcon';
import { useGame } from '@/src/contexts/GameContext';
import { playSound } from '@/src/utils/audio';

interface MuteButtonProps {
  size?: number;
  style?: StyleProp<ViewStyle>;
}

function MuteButtonBase({ size = 38, style }: MuteButtonProps) {
  const game = useGame();
  const muted = game.settings.masterMuted;

  const toggleMute = async () => {
    await game.updateAudioSettings({ masterMuted: !muted });
    if (muted) playSound('buttonConfirm', true);
  };

  return (
    <TouchableOpacity
      accessibilityRole="button"
      accessibilityLabel={muted ? 'Ativar som' : 'Mutar som'}
      style={[styles.button, { width: size, height: size, borderRadius: size / 2 }, style]}
      onPress={toggleMute}
      activeOpacity={0.8}
    >
      <UiIcon iconKey={muted ? 'ui_mute_off' : 'ui_mute_on'} fallback={muted ? '🔇' : '🔊'} size={Math.round(size * 0.62)} />
    </TouchableOpacity>
  );
}

export const MuteButton = memo(MuteButtonBase);

const styles = StyleSheet.create({
  button: {
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#08131fcc',
    borderWidth: 1,
    borderColor: '#00f0ff77',
    zIndex: 80,
    elevation: 80,
  },
});

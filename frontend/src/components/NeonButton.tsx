import React from 'react';
import { StyleSheet, Text, TouchableOpacity, ViewStyle } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { AudioSettings, playSound, SoundKey } from '@/src/utils/audio';

type NeonButtonVariant = 'primary' | 'secondary' | 'danger';

interface NeonButtonProps {
  title: string;
  onPress: () => void | Promise<void>;
  variant?: NeonButtonVariant;
  disabled?: boolean;
  sound?: SoundKey;
  audioSettings?: Partial<AudioSettings> & { sound?: boolean };
  style?: ViewStyle | ViewStyle[];
}

const variantColors: Record<NeonButtonVariant, [string, string]> = {
  primary: ['#00f0ff', '#006dff'],
  secondary: ['#1a2040', '#0c1026'],
  danger: ['#ff1744', '#7f1027'],
};

const borderColors: Record<NeonButtonVariant, string> = {
  primary: '#00f0ff',
  secondary: '#ffffff55',
  danger: '#ff4d6d',
};

const textColors: Record<NeonButtonVariant, string> = {
  primary: '#ffffff',
  secondary: '#ffffff',
  danger: '#ffffff',
};

export function NeonButton({
  title,
  onPress,
  variant = 'secondary',
  disabled = false,
  sound = variant === 'primary' ? 'buttonConfirm' : variant === 'danger' ? 'buttonClick' : 'buttonClick',
  audioSettings,
  style,
}: NeonButtonProps) {
  const handlePress = async () => {
    if (disabled) {
      await playSound('buttonError', audioSettings?.sound ?? true);
      return;
    }
    await playSound(sound, audioSettings?.sound ?? true);
    await onPress();
  };

  return (
    <TouchableOpacity
      activeOpacity={0.78}
      style={[styles.shell, { borderColor: borderColors[variant], shadowColor: borderColors[variant] }, disabled && styles.disabled, style]}
      onPress={handlePress}
    >
      <LinearGradient colors={variantColors[variant]} style={styles.fill}>
        <Text style={[styles.text, { color: textColors[variant] }]} numberOfLines={1} adjustsFontSizeToFit>
          {title}
        </Text>
      </LinearGradient>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  shell: {
    minHeight: 48,
    borderRadius: 12,
    borderWidth: 1.5,
    overflow: 'hidden',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.5,
    shadowRadius: 10,
    backgroundColor: '#050516',
  },
  fill: {
    flex: 1,
    minHeight: 48,
    paddingHorizontal: 14,
    alignItems: 'center',
    justifyContent: 'center',
  },
  text: {
    fontSize: 14,
    fontWeight: 'bold',
    letterSpacing: 0,
    textAlign: 'center',
  },
  disabled: {
    opacity: 0.45,
    shadowOpacity: 0,
  },
});

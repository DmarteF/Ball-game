import React, { memo } from 'react';
import { Image, StyleProp, StyleSheet, Text, View, ViewStyle } from 'react-native';
import { SkinDefinition } from '@/src/game/skins';

interface SkinIconProps {
  skin?: Pick<SkinDefinition, 'icon' | 'imageAsset' | 'primaryColor'>;
  icon?: string;
  size?: number;
  style?: StyleProp<ViewStyle>;
  imageScale?: number;
  hidden?: boolean;
}

function SkinIconBase({ skin, icon, size = 48, style, imageScale = 0.92, hidden }: SkinIconProps) {
  const fallback = hidden ? icon || '?' : skin?.icon || icon || '?';
  const imageSize = Math.max(1, size * imageScale);

  return (
    <View
      style={[
        styles.container,
        {
          width: size,
          height: size,
          borderRadius: size / 2,
          backgroundColor: hidden ? '#111827' : skin?.primaryColor || '#ffffff22',
        },
        style,
      ]}
    >
      {!hidden && skin?.imageAsset ? (
        <Image
          source={skin.imageAsset}
          resizeMode="contain"
          style={{ width: imageSize, height: imageSize }}
        />
      ) : (
        <Text style={[styles.fallback, { fontSize: Math.max(12, size * 0.5), lineHeight: Math.max(14, size * 0.58) }]}>{fallback}</Text>
      )}
    </View>
  );
}

export const SkinIcon = memo(SkinIconBase);

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: '#ffffff44',
  },
  fallback: {
    color: '#ffffff',
    textAlign: 'center',
  },
});

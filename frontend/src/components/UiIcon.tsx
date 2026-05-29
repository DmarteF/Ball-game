import React, { memo } from 'react';
import { Image, ImageStyle, StyleProp, StyleSheet, Text, TextStyle } from 'react-native';
import { UI_ICON_ASSETS, UiIconKey } from '@/src/game/uiIcons';

interface UiIconProps {
  iconKey?: UiIconKey;
  fallback?: string;
  size?: number;
  style?: StyleProp<ImageStyle | TextStyle>;
}

function UiIconBase({ iconKey, fallback = '', size = 22, style }: UiIconProps) {
  const asset = iconKey ? UI_ICON_ASSETS[iconKey] : undefined;

  if (asset) {
    return <Image source={asset} resizeMode="contain" style={[styles.image, { width: size, height: size }, style as StyleProp<ImageStyle>]} />;
  }

  return <Text style={[styles.text, { fontSize: size, lineHeight: size + 2 }, style as StyleProp<TextStyle>]}>{fallback}</Text>;
}

export const UiIcon = memo(UiIconBase);

const styles = StyleSheet.create({
  image: {
    flexShrink: 0,
  },
  text: {
    color: '#ffffff',
    textAlign: 'center',
  },
});

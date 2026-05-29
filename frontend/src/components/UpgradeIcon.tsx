import React, { memo } from 'react';
import { ImageStyle, StyleProp, TextStyle } from 'react-native';
import { UiIcon } from '@/src/components/UiIcon';
import { Upgrade } from '@/src/game/upgrades';
import { getUpgradeIconKey } from '@/src/game/upgradeIcons';

interface UpgradeIconProps {
  upgrade?: Pick<Upgrade, 'id' | 'icon' | 'effects'> | string;
  fallback?: string;
  size?: number;
  style?: StyleProp<ImageStyle | TextStyle>;
}

function UpgradeIconBase({ upgrade, fallback = '⚔️', size = 28, style }: UpgradeIconProps) {
  const iconKey = getUpgradeIconKey(typeof upgrade === 'string' ? upgrade : upgrade?.id ? upgrade : undefined);
  const fallbackIcon = typeof upgrade === 'string' ? fallback : upgrade?.icon || fallback;
  return <UiIcon iconKey={iconKey} fallback={fallbackIcon} size={size} style={style} />;
}

export const UpgradeIcon = memo(UpgradeIconBase);

import { EdgeInsets } from 'react-native-safe-area-context';

export const MIN_TOUCH_BOTTOM_SPACE = 14;

export function getSafePaddingTop(insets: EdgeInsets, base = 12) {
  return Math.max(base, insets.top + 8);
}

export function getSafePaddingBottom(insets: EdgeInsets, base = MIN_TOUCH_BOTTOM_SPACE) {
  return Math.max(base, insets.bottom + 12);
}

export function getDualArenaSize(params: {
  width: number;
  height: number;
  insets: EdgeInsets;
  hudHeight?: number;
  controlsHeight?: number;
  gap?: number;
  min?: number;
  max?: number;
}) {
  const {
    width,
    height,
    insets,
    hudHeight = 126,
    controlsHeight = 82,
    gap = 52,
    min = 118,
    max = 188,
  } = params;
  const usableWidth = Math.max(0, width - 28);
  const usableHeight = Math.max(0, height - getSafePaddingTop(insets) - getSafePaddingBottom(insets) - hudHeight - controlsHeight - gap);
  const size = Math.min(usableWidth, usableHeight / 2, max);
  return Math.max(min, Math.floor(Number.isFinite(size) && size > 0 ? size : min));
}

export function getSingleArenaSize(params: {
  width: number;
  height: number;
  insets: EdgeInsets;
  hudHeight?: number;
  controlsHeight?: number;
  min?: number;
  max?: number;
}) {
  const { width, height, insets, hudHeight = 126, controlsHeight = 78, min = 220, max } = params;
  const usableWidth = Math.max(0, width - 24);
  const usableHeight = Math.max(0, height - getSafePaddingTop(insets) - getSafePaddingBottom(insets) - hudHeight - controlsHeight - 16);
  const size = Math.min(usableWidth, usableHeight, max || usableWidth);
  return Math.max(min, Math.floor(Number.isFinite(size) && size > 0 ? size : min));
}

export function getGameplayInsetsStyle(insets: EdgeInsets, topBase = 12, bottomBase = MIN_TOUCH_BOTTOM_SPACE) {
  return {
    paddingTop: getSafePaddingTop(insets, topBase),
    paddingBottom: getSafePaddingBottom(insets, bottomBase),
  };
}

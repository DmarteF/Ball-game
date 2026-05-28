import * as Haptics from 'expo-haptics';

export type FeedbackEvent = 'hit' | 'critical' | 'perfect' | 'break' | 'rareChest' | 'victory' | 'defeat' | 'skin';

export const triggerHaptic = async (event: FeedbackEvent, enabled = true) => {
  if (!enabled) return;
  try {
    if (event === 'hit' || event === 'skin') {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      return;
    }
    if (event === 'critical' || event === 'perfect' || event === 'break') {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
      return;
    }
    await Haptics.notificationAsync(event === 'defeat' ? Haptics.NotificationFeedbackType.Warning : Haptics.NotificationFeedbackType.Success);
  } catch {
    // Haptics are best-effort and may be unavailable on web/simulator.
  }
};

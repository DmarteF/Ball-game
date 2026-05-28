export type SoundKey = 'hit' | 'click' | 'perfect' | 'combo' | 'chestOpen' | 'rareDrop' | 'victory' | 'defeat';

export const playSound = async (_sound: SoundKey, enabled = true) => {
  if (!enabled) return;
  // Future hook point for expo-av or another audio layer.
  // Keeping this silent makes current builds safe without bundled sound assets.
};

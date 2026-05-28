import { useEffect } from 'react';
import { usePathname } from 'expo-router';
import { useGame } from '@/src/contexts/GameContext';
import { applyAudioSettings, playMusic } from '@/src/utils/audio';

export function AudioController() {
  const pathname = usePathname();
  const { settings, loading } = useGame();

  useEffect(() => {
    applyAudioSettings(settings);
  }, [settings]);

  useEffect(() => {
    if (loading) return;
    if (pathname.includes('/game')) playMusic('gameplay');
    else if (pathname.includes('/boss')) playMusic('boss');
    else playMusic('menu');
  }, [pathname, loading]);

  return null;
}

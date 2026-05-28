import { createAudioPlayer, setAudioModeAsync, type AudioPlayer } from 'expo-audio';

export type MusicKey = 'menu' | 'gameplay' | 'boss';
export type SoundKey =
  | 'buttonClick'
  | 'buttonConfirm'
  | 'buttonError'
  | 'chestOpen'
  | 'coinGain'
  | 'combo'
  | 'defeat'
  | 'diamondGain'
  | 'hitHeavy'
  | 'hitLight'
  | 'legendaryDrop'
  | 'levelUp'
  | 'perfect'
  | 'rareDrop'
  | 'revive'
  | 'ringBreak'
  | 'sayPerfect'
  | 'victory'
  | 'xpGain'
  | 'hit'
  | 'click';

export interface AudioSettings {
  musicMuted: boolean;
  sfxMuted: boolean;
  masterMuted: boolean;
  musicVolume: number;
  sfxVolume: number;
}

const musicAssets: Record<MusicKey, number[]> = {
  menu: [
    require('../../assets/audio/music/menu.mp3'),
    require('../../assets/audio/music/menu2.mp3'),
  ],
  gameplay: [
    require('../../assets/audio/music/gameplay.mp3'),
    require('../../assets/audio/music/gameplay2.mp3'),
  ],
  boss: [
    require('../../assets/audio/music/boss1.wav'),
    require('../../assets/audio/music/boss2.wav'),
  ],
};

const sfxAssets: Record<Exclude<SoundKey, 'hit' | 'click'>, number> = {
  buttonClick: require('../../assets/audio/sfx/button_click.mp3'),
  buttonConfirm: require('../../assets/audio/sfx/button_confirm.mp3'),
  buttonError: require('../../assets/audio/sfx/button_error.mp3'),
  chestOpen: require('../../assets/audio/sfx/chest_open.mp3'),
  coinGain: require('../../assets/audio/sfx/coin_gain.mp3'),
  combo: require('../../assets/audio/sfx/combo.mp3'),
  defeat: require('../../assets/audio/sfx/defeat.mp3'),
  diamondGain: require('../../assets/audio/sfx/diamond_gain.mp3'),
  hitHeavy: require('../../assets/audio/sfx/hit_heavy.mp3'),
  hitLight: require('../../assets/audio/sfx/hit_light.mp3'),
  legendaryDrop: require('../../assets/audio/sfx/legendary_drop.mp3'),
  levelUp: require('../../assets/audio/sfx/level_up.mp3'),
  perfect: require('../../assets/audio/sfx/perfect.mp3'),
  rareDrop: require('../../assets/audio/sfx/rare_drop.mp3'),
  revive: require('../../assets/audio/sfx/revive.mp3'),
  ringBreak: require('../../assets/audio/sfx/ring_break.mp3'),
  sayPerfect: require('../../assets/audio/sfx/say_perfect.mp3'),
  victory: require('../../assets/audio/sfx/victory.mp3'),
  xpGain: require('../../assets/audio/sfx/xp_gain.mp3'),
};

const aliases: Partial<Record<SoundKey, Exclude<SoundKey, 'hit' | 'click'>>> = {
  hit: 'hitLight',
  click: 'buttonClick',
};

const soundConfig: Record<Exclude<SoundKey, 'hit' | 'click'>, { volume: number; cooldownMs: number; maxOverlap: number }> = {
  buttonClick: { volume: 0.35, cooldownMs: 70, maxOverlap: 1 },
  buttonConfirm: { volume: 0.5, cooldownMs: 120, maxOverlap: 2 },
  buttonError: { volume: 0.55, cooldownMs: 220, maxOverlap: 1 },
  chestOpen: { volume: 0.75, cooldownMs: 450, maxOverlap: 1 },
  coinGain: { volume: 0.4, cooldownMs: 220, maxOverlap: 2 },
  combo: { volume: 0.58, cooldownMs: 240, maxOverlap: 1 },
  defeat: { volume: 0.78, cooldownMs: 700, maxOverlap: 1 },
  diamondGain: { volume: 0.68, cooldownMs: 260, maxOverlap: 2 },
  hitHeavy: { volume: 0.55, cooldownMs: 90, maxOverlap: 2 },
  hitLight: { volume: 0.24, cooldownMs: 70, maxOverlap: 2 },
  legendaryDrop: { volume: 0.9, cooldownMs: 900, maxOverlap: 1 },
  levelUp: { volume: 0.78, cooldownMs: 500, maxOverlap: 1 },
  perfect: { volume: 0.82, cooldownMs: 280, maxOverlap: 1 },
  rareDrop: { volume: 0.7, cooldownMs: 650, maxOverlap: 1 },
  revive: { volume: 0.78, cooldownMs: 700, maxOverlap: 1 },
  ringBreak: { volume: 0.62, cooldownMs: 130, maxOverlap: 2 },
  sayPerfect: { volume: 0.72, cooldownMs: 1500, maxOverlap: 1 },
  victory: { volume: 0.8, cooldownMs: 700, maxOverlap: 1 },
  xpGain: { volume: 0.38, cooldownMs: 220, maxOverlap: 2 },
};

const defaultAudioSettings: AudioSettings = {
  musicMuted: false,
  sfxMuted: false,
  masterMuted: false,
  musicVolume: 0.38,
  sfxVolume: 0.82,
};

let currentMusic: { key: MusicKey; asset: number; player: AudioPlayer } | null = null;
let settings: AudioSettings = defaultAudioSettings;
let configured = false;
const lastPlayed: Partial<Record<SoundKey, number>> = {};
const activeCounts: Partial<Record<SoundKey, number>> = {};

const normalizeKey = (key: SoundKey) => aliases[key] || key as Exclude<SoundKey, 'hit' | 'click'>;
const clamp = (value: number) => Math.max(0, Math.min(1, Number.isFinite(value) ? value : 0));
const canPlayMusic = () => !settings.masterMuted && !settings.musicMuted && settings.musicVolume > 0;
const canPlaySfx = () => !settings.masterMuted && !settings.sfxMuted && settings.sfxVolume > 0;

const configureAudio = async () => {
  if (configured) return;
  configured = true;
  try {
    await setAudioModeAsync({
      playsInSilentMode: true,
      shouldPlayInBackground: false,
      interruptionMode: 'mixWithOthers',
    });
  } catch (error) {
    console.warn('Audio mode unavailable:', error);
  }
};

export const audioService = {
  applySettings(next: Partial<AudioSettings>) {
    settings = {
      ...settings,
      ...next,
      musicVolume: clamp(next.musicVolume ?? settings.musicVolume),
      sfxVolume: clamp(next.sfxVolume ?? settings.sfxVolume),
    };
    if (currentMusic) {
      currentMusic.player.volume = canPlayMusic() ? settings.musicVolume : 0;
      if (!canPlayMusic()) currentMusic.player.pause();
      else if (!currentMusic.player.playing) currentMusic.player.play();
    }
  },

  async playMusic(key: MusicKey) {
    await configureAudio();
    const choices = musicAssets[key];
    const asset = choices[Math.floor(Math.random() * choices.length)] || choices[0];

    if (currentMusic?.key === key && currentMusic.player.playing) {
      currentMusic.player.volume = canPlayMusic() ? settings.musicVolume : 0;
      return;
    }

    if (currentMusic) {
      try {
        currentMusic.player.pause();
        currentMusic.player.remove();
      } catch {}
      currentMusic = null;
    }

    const player = createAudioPlayer(asset, { updateInterval: 1000 });
    player.loop = true;
    player.volume = canPlayMusic() ? settings.musicVolume : 0;
    currentMusic = { key, asset, player };
    if (canPlayMusic()) {
      try {
        player.play();
      } catch (error) {
        console.warn('Music playback blocked:', error);
      }
    }
  },

  stopMusic() {
    if (!currentMusic) return;
    try {
      currentMusic.player.pause();
      currentMusic.player.remove();
    } catch {}
    currentMusic = null;
  },

  async playSound(key: SoundKey) {
    await configureAudio();
    const soundKey = normalizeKey(key);
    if (!canPlaySfx()) return;
    const config = soundConfig[soundKey];
    const now = Date.now();
    if (now - (lastPlayed[soundKey] || 0) < config.cooldownMs) return;
    if ((activeCounts[soundKey] || 0) >= config.maxOverlap) return;

    lastPlayed[soundKey] = now;
    activeCounts[soundKey] = (activeCounts[soundKey] || 0) + 1;
    const player = createAudioPlayer(sfxAssets[soundKey], { updateInterval: 1000 });
    player.volume = clamp(settings.sfxVolume * config.volume);
    try {
      player.play();
    } catch (error) {
      console.warn('SFX playback blocked:', error);
    }
    setTimeout(() => {
      activeCounts[soundKey] = Math.max(0, (activeCounts[soundKey] || 1) - 1);
      try {
        player.remove();
      } catch {}
    }, 2600);
  },
};

export const playSound = async (sound: SoundKey, enabled = true) => {
  if (!enabled) return;
  await audioService.playSound(sound);
};

export const playMusic = audioService.playMusic;
export const stopMusic = audioService.stopMusic;
export const applyAudioSettings = audioService.applySettings;
export const DEFAULT_AUDIO_SETTINGS = defaultAudioSettings;

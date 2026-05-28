import { getPhaseConfig } from './phases';

export type BossDifficultyId = 'easy' | 'medium' | 'hard' | 'insane';

export interface BossDifficulty {
  id: BossDifficultyId;
  name: string;
  skinId: string;
  speedMultiplier: number;
  damageMultiplier: number;
  shrinkMultiplier: number;
  aiQuality: number;
  ultimateChance: number;
  rewards: { coins: number; xp: number; keyChance: number; fragmentChance: number; chestChance: number };
}

export const BOSS_DIFFICULTIES: BossDifficulty[] = [
  { id: 'easy', name: 'Fácil', skinId: 'divine_core', speedMultiplier: 0.84, damageMultiplier: 0.86, shrinkMultiplier: 0.92, aiQuality: 0.45, ultimateChance: 0.08, rewards: { coins: 180, xp: 70, keyChance: 0.08, fragmentChance: 0.18, chestChance: 0.04 } },
  { id: 'medium', name: 'Médio', skinId: 'divine_core', speedMultiplier: 1, damageMultiplier: 1, shrinkMultiplier: 1, aiQuality: 0.7, ultimateChance: 0.14, rewards: { coins: 260, xp: 110, keyChance: 0.12, fragmentChance: 0.25, chestChance: 0.07 } },
  { id: 'hard', name: 'Difícil', skinId: 'living_singularity', speedMultiplier: 1.12, damageMultiplier: 1.18, shrinkMultiplier: 1.08, aiQuality: 0.86, ultimateChance: 0.2, rewards: { coins: 390, xp: 165, keyChance: 0.17, fragmentChance: 0.34, chestChance: 0.1 } },
  { id: 'insane', name: 'Insano', skinId: 'cosmic_champion', speedMultiplier: 1.24, damageMultiplier: 1.34, shrinkMultiplier: 1.16, aiQuality: 0.96, ultimateChance: 0.28, rewards: { coins: 560, xp: 240, keyChance: 0.24, fragmentChance: 0.46, chestChance: 0.14 } },
];

export const getBossDifficulty = (id: string) => BOSS_DIFFICULTIES.find(item => item.id === id) || BOSS_DIFFICULTIES[1];

export const createBossPhaseConfig = (difficultyId: string) => {
  const difficulty = getBossDifficulty(difficultyId);
  const basePhase = difficulty.id === 'easy' ? 5 : difficulty.id === 'medium' ? 8 : difficulty.id === 'hard' ? 12 : 16;
  const phase = getPhaseConfig(basePhase);

  return {
    playerRingCount: Math.floor((phase.ringMin + phase.ringMax) / 2),
    bossRingCount: Math.max(7, Math.floor((phase.ringMin + phase.ringMax) / 2) - (difficulty.id === 'easy' ? 3 : difficulty.id === 'medium' ? 1 : 0)),
    baseHp: phase.baseHp,
    closingSpeed: phase.closingSpeed,
    rotationSpeed: phase.rotationSpeed,
    gapSize: phase.gapSize,
  };
};

export const chooseBossUpgrade = (
  choices: string[],
  difficultyId: string,
  state: { ringsRemaining: number; speed: number; perfectWindows: number }
) => {
  const difficulty = getBossDifficulty(difficultyId);
  const weighted = choices.map(id => {
    let score = Math.random() * (1 - difficulty.aiQuality);
    if (id.includes('damage') || id.includes('critical') || id.includes('laser')) score += state.ringsRemaining > 10 ? 0.55 : 0.25;
    if (id.includes('speed')) score += state.speed < 2.6 ? 0.45 : 0.14;
    if (id.includes('perfect') || id.includes('shield') || id.includes('slow')) score += state.perfectWindows > 0 ? 0.36 : 0.18;
    if (id.includes('chain') || id.includes('repulse')) score += 0.28;
    return { id, score };
  });
  return weighted.sort((a, b) => b.score - a.score)[0]?.id || choices[0];
};

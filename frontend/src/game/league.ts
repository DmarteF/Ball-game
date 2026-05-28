import { RewardGrant } from './retention';

export type LeagueDivision = 'Bronze' | 'Prata' | 'Ouro' | 'Platina' | 'Diamante' | 'Mestre' | 'Lendário' | 'Ultimate';

export interface LeagueRival {
  id: string;
  name: string;
  avatar: string;
  favoriteSkin: string;
  level: number;
  trophies: number;
  score: number;
  secondaryScore: number;
  maxPhase: number;
  bossWins: number;
  competitionWins: number;
  competitionLosses: number;
  division: LeagueDivision;
  title: string;
}

export interface LeagueSeasonReward {
  seasonKey: string;
  finalDivision: LeagueDivision;
  finalPosition: number;
  newDivision: LeagueDivision;
  rewards: RewardGrant[];
  skinId?: string;
  firstInitialChampionUltimate?: boolean;
  claimed: boolean;
}

export interface LeagueHistory {
  bestPosition: number;
  bestDivision: LeagueDivision;
  seasonsPlayed: number;
  firstPlaceFinishes: number;
  top3Finishes: number;
  top10Finishes: number;
  ultimateFirstPlaceFinishes: number;
  initialFirstPlaceFinishes: number;
  competitionWins: number;
  competitionLosses: number;
  currentWinStreak: number;
  bestWinStreak: number;
  totalTrophiesGained: number;
  rankingSkinsObtained: string[];
  lastReward?: string;
}

export interface LeagueSave {
  rivals: LeagueRival[];
  seasonKey: string;
  lastDailyProgressKey: string;
  claimedDivisionRewards: LeagueDivision[];
  pendingSeasonReward?: LeagueSeasonReward;
  history: LeagueHistory;
  forcedDivision?: LeagueDivision;
  playerTrophies?: number;
}

export const DIVISIONS: { name: LeagueDivision; minScore: number }[] = [
  { name: 'Bronze', minScore: 0 },
  { name: 'Prata', minScore: 300 },
  { name: 'Ouro', minScore: 800 },
  { name: 'Platina', minScore: 1500 },
  { name: 'Diamante', minScore: 2500 },
  { name: 'Mestre', minScore: 4000 },
  { name: 'Lendário', minScore: 6000 },
  { name: 'Ultimate', minScore: 9000 },
];

const avatars = ['🔵', '🟣', '🟡', '🤖', '👑', '💎', '⚡', '🔥', '❄️', '🌙', '🌟', '🌀'];
const skins = ['neon_blue', 'hamster', 'panda', 'fox_common', 'wolf_rare', 'robot', 'fire', 'ice', 'lightning', 'crystal', 'astral_eye', 'solar_guardian', 'black_sun', 'league_king_neon'];
const prefixes = ['Neon', 'Dark', 'Cosmic', 'Lucky', 'Pixel', 'Cyber', 'Nitro', 'Solar', 'Lunar', 'Ghost', 'Frost', 'Fire', 'Void', 'Turbo', 'Mystic'];
const suffixes = ['Fox', 'Cat', 'Pig', 'Orb', 'Runner', 'Breaker', 'Hunter', 'Slime', 'Ghost', 'King', 'Core', 'Eye', 'Star', 'Bot', 'Ring'];
const baseNames = ['NeonFox', 'RingBreaker', 'LunaBot', 'OrbKing', 'PixelGhost', 'NitroCat', 'CosmicPig', 'DarkSlime', 'StarRunner', 'BossHunter', 'CyberPanda', 'VoidCat', 'PlasmaPig', 'FrostByte', 'FireOrb', 'LuckySlime', 'GhostRunner', 'DiamondEye', 'SolarKid', 'MoonRabbit'];
const titles = ['Rival Local', 'Quebra-Anéis', 'Caçador de Boss', 'Especialista Neon', 'Corredor de Fases', 'Bot da Arena', 'Colecionador', 'Elite Simulada'];

const hash = (seed: string) => {
  let value = 2166136261;
  for (let i = 0; i < seed.length; i += 1) {
    value ^= seed.charCodeAt(i);
    value = Math.imul(value, 16777619);
  }
  return value >>> 0;
};

const random = (seed: string) => {
  let value = hash(seed);
  return () => {
    value = Math.imul(value ^ (value >>> 15), 1 | value);
    value ^= value + Math.imul(value ^ (value >>> 7), 61 | value);
    return ((value ^ (value >>> 14)) >>> 0) / 4294967296;
  };
};

export const getSeasonKey = (date = new Date()) => `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
export const getDayKey = (date = new Date()) => date.toISOString().slice(0, 10);

export const getDaysRemainingInSeason = (date = new Date()) => {
  const end = new Date(date.getFullYear(), date.getMonth() + 1, 1).getTime();
  const diff = Math.max(0, end - date.getTime());
  return Math.max(1, Math.ceil(diff / 86400000));
};

export const getDivisionForScore = (score: number): LeagueDivision => {
  let division: LeagueDivision = 'Bronze';
  DIVISIONS.forEach(item => {
    if (score >= item.minScore) division = item.name;
  });
  return division;
};

export const getDivisionMinScore = (division: LeagueDivision) => DIVISIONS.find(item => item.name === division)?.minScore || 0;
export const getPreviousDivision = (division: LeagueDivision): LeagueDivision => {
  const index = DIVISIONS.findIndex(item => item.name === division);
  return DIVISIONS[Math.max(0, index - 1)]?.name || 'Bronze';
};

export const compareDivision = (a: LeagueDivision, b: LeagueDivision) =>
  DIVISIONS.findIndex(item => item.name === a) - DIVISIONS.findIndex(item => item.name === b);

export const calculateRankingScore = (source: {
  highestPhase: number;
  profileLevel: number;
  ringsDestroyed: number;
  perfectEscapes: number;
  unlockedSkins: number;
  bossWins: number;
  completedAchievements: number;
}) =>
  source.highestPhase * 1000 +
  source.profileLevel * 250 +
  source.ringsDestroyed * 2 +
  source.perfectEscapes * 25 +
  source.unlockedSkins * 150 +
  source.bossWins * 500 +
  source.completedAchievements * 300;

const scoreForSlot = (slot: number, rand: () => number, playerScore: number) => {
  if (slot < 19) return 215000 + (19 - slot) * 9000 + Math.floor(rand() * 42000);
  if (slot < 79) return 65000 + (79 - slot) * 2100 + Math.floor(rand() * 14000);
  if (slot < 149) return 14000 + (149 - slot) * 740 + Math.floor(rand() * 5200);
  return Math.max(600, Math.floor(1200 + (199 - slot) * 72 + rand() * 1800 + playerScore * 0.08));
};

const trophiesForSlot = (slot: number, rand: () => number, playerTrophies: number) => {
  const baseline = Math.max(80, playerTrophies || Math.floor(playerTrophies * 0.7));
  if (slot < 3) return 9200 + Math.floor(rand() * 1800);
  if (slot < 10) return 6200 + Math.floor(rand() * 2600);
  if (slot < 30) return 3600 + Math.floor(rand() * 2500);
  if (slot < 80) return 1600 + Math.floor(rand() * 2300);
  if (slot < 150) return 420 + Math.floor(rand() * 1500);
  return Math.max(20, Math.floor(40 + rand() * 520 + baseline * 0.18));
};

const skinForSlot = (slot: number, rand: () => number) => {
  if (slot < 3) return ['league_king_neon', 'divine_core', 'living_singularity'][slot] || 'league_king_neon';
  if (slot < 10) return ['black_sun', 'void_dragon', 'cosmic_emperor', 'neon_dragon'][Math.floor(rand() * 4)];
  if (slot < 55) return ['astral_eye', 'living_plasma', 'blue_comet', 'solar_guardian', 'orbital_blade'][Math.floor(rand() * 5)];
  if (slot < 130) return ['wolf_rare', 'meteor_rare', 'purple_crystal', 'ninja_rare', 'alien_rare'][Math.floor(rand() * 5)];
  return ['hamster', 'panda', 'fox_common', 'bee_common', 'neon_blue'][Math.floor(rand() * 5)];
};

export const createLeagueRivals = (playerId: string, playerScore: number, seasonKey = getSeasonKey(), playerTrophies = 120): LeagueRival[] => {
  const rand = random(`${playerId}_${seasonKey}_league_neon`);
  return Array.from({ length: 200 }, (_, index) => {
    const generatedName = index < baseNames.length ? baseNames[index] : `${prefixes[Math.floor(rand() * prefixes.length)]}${suffixes[Math.floor(rand() * suffixes.length)]}${Math.floor(rand() * 90)}`;
    const score = scoreForSlot(index, rand, playerScore);
    const trophies = trophiesForSlot(index, rand, playerTrophies);
    return {
      id: `rival_${seasonKey}_${index}`,
      name: generatedName,
      avatar: avatars[Math.floor(rand() * avatars.length)],
      favoriteSkin: skinForSlot(index, rand) || skins[Math.floor(rand() * skins.length)],
      level: Math.max(1, Math.floor(trophies / 120) + Math.floor(rand() * 8)),
      trophies,
      score,
      secondaryScore: score,
      maxPhase: Math.max(1, Math.min(50, Math.floor(trophies / 185) + Math.ceil(rand() * 8))),
      bossWins: Math.floor(trophies / 750 + rand() * 8),
      competitionWins: Math.floor(trophies / 18 + rand() * 28),
      competitionLosses: Math.floor(trophies / 34 + rand() * 18),
      division: getDivisionForScore(trophies),
      title: titles[Math.floor(rand() * titles.length)],
    };
  });
};

export const progressRivals = (rivals: LeagueRival[], days: number, seed: string) => {
  if (days <= 0) return rivals;
  const rand = random(seed);
  return rivals.map((rival, index) => {
    const eliteFactor = index < 30 ? 1.12 : index > 150 ? 0.58 : 0.86;
    const gain = Math.floor((90 + rand() * 620) * days * eliteFactor);
    const trophyGain = Math.floor((2 + rand() * 13) * days * eliteFactor);
    const score = rival.score + gain;
    const trophies = rival.trophies + trophyGain;
    return {
      ...rival,
      trophies,
      score,
      secondaryScore: score,
      division: getDivisionForScore(trophies),
      level: Math.max(rival.level, Math.floor(trophies / 120)),
    };
  });
};

export const defaultLeagueSave = (playerId: string, playerScore = 0): LeagueSave => ({
  rivals: createLeagueRivals(playerId, playerScore),
  seasonKey: getSeasonKey(),
  lastDailyProgressKey: getDayKey(),
  claimedDivisionRewards: [],
  playerTrophies: Math.max(80, Math.floor(playerScore / 850)),
  history: {
    bestPosition: 201,
    bestDivision: 'Bronze',
    seasonsPlayed: 0,
    firstPlaceFinishes: 0,
    top3Finishes: 0,
    top10Finishes: 0,
    ultimateFirstPlaceFinishes: 0,
    initialFirstPlaceFinishes: 0,
    competitionWins: 0,
    competitionLosses: 0,
    currentWinStreak: 0,
    bestWinStreak: 0,
    totalTrophiesGained: 0,
    rankingSkinsObtained: [],
  },
});

export const getRankedLeague = (rivals: LeagueRival[], player: LeagueRival) =>
  [...rivals, player].sort((a, b) => b.trophies - a.trophies || b.score - a.score || a.name.localeCompare(b.name));

export interface CompetitionMap {
  id: string;
  theme: string;
  color: string;
  rings: number;
  hpMultiplier: number;
  closingMultiplier: number;
  rotationMultiplier: number;
  gapMultiplier: number;
  modifier: string;
  rewardMultiplier: number;
}

const themes = [
  ['Neon Azul', '#00f0ff'],
  ['Vazio Roxo', '#8b5cf6'],
  ['Inferno Vermelho', '#ff1744'],
  ['Gelo Cósmico', '#9be8ff'],
  ['Dourado', '#ffd700'],
  ['Glitch', '#39ff14'],
  ['Plasma', '#ff4fd8'],
  ['Sombra', '#111827'],
] as const;

const modifiers = [
  ['Anéis rápidos', 1, 1.12, 1.16, 1, 1.12],
  ['Anéis resistentes', 1.18, 1, 1, 1, 1.14],
  ['Aberturas maiores', 1, 0.96, 1, 1.12, 1.02],
  ['Mais recompensa', 1, 1, 1, 1, 1.28],
  ['Perfect favorável', 0.96, 0.95, 0.95, 1.08, 1.08],
  ['Fechamento lento', 1, 0.86, 1, 1, 1.04],
  ['Rotação invertida', 1, 1, 1.1, 1, 1.1],
  ['Combo forte', 1, 1.04, 1.04, 1, 1.18],
] as const;

export const createCompetitionMap = (seed: string, playerTrophies: number): CompetitionMap => {
  const rand = random(`${seed}_${playerTrophies}_competition_map`);
  const theme = themes[Math.floor(rand() * themes.length)];
  const modifier = modifiers[Math.floor(rand() * modifiers.length)];
  const tier = Math.min(1, playerTrophies / 9000);
  return {
    id: `map_${hash(seed).toString(16)}`,
    theme: theme[0],
    color: theme[1],
    rings: Math.round(14 + tier * 34 + rand() * 12),
    hpMultiplier: modifier[1] + tier * 0.42,
    closingMultiplier: modifier[2] + tier * 0.26,
    rotationMultiplier: modifier[3] + tier * 0.28,
    gapMultiplier: modifier[4],
    modifier: modifier[0],
    rewardMultiplier: modifier[5] + tier * 0.3,
  };
};

export const findMatchmakingRival = (rivals: LeagueRival[], player: LeagueRival, seed: string) => {
  const rand = random(seed);
  const roll = rand();
  const targetOffset = roll < 0.7 ? 260 : roll < 0.9 ? 850 : -420;
  const target = player.trophies + targetOffset + (rand() - 0.5) * 360;
  const sorted = [...rivals].sort((a, b) => Math.abs(a.trophies - target) - Math.abs(b.trophies - target));
  return sorted[Math.floor(rand() * Math.min(12, sorted.length))] || rivals[0];
};

export const calculateTrophyDelta = (player: LeagueRival, rival: LeagueRival, won: boolean, winStreak: number, noRevive = true, secretBonus = 0) => {
  const diff = rival.trophies - player.trophies;
  if (!won) {
    if (diff > 700) return -3;
    if (diff > 150) return -5;
    if (diff < -500) return -8;
    return -6;
  }
  const base = diff > 700 ? 18 : diff > 150 ? 14 : diff < -500 ? 8 : 12;
  const streakBonus = winStreak >= 10 ? 8 : winStreak >= 5 ? 4 : winStreak >= 3 ? 2 : 0;
  const upsetBonus = diff > 1100 ? 5 : diff > 700 ? 3 : 0;
  return base + streakBonus + upsetBonus + (noRevive ? 1 : 0) + secretBonus;
};

export const getDivisionReward = (division: LeagueDivision): RewardGrant[] => {
  switch (division) {
    case 'Prata': return [{ type: 'coins', amount: 1500 }];
    case 'Ouro': return [{ type: 'gems', amount: 30 }];
    case 'Platina': return [{ type: 'keys', amount: 2 }];
    case 'Diamante': return [{ type: 'chest', chestType: 'rare', amount: 1 }];
    case 'Mestre': return [{ type: 'chest', chestType: 'epic', amount: 1 }];
    case 'Lendário': return [{ type: 'legendaryKeys', amount: 1 }];
    case 'Ultimate': return [{ type: 'fragments', skinId: 'league_king_neon', amount: 50 }];
    default: return [];
  }
};

export const getSeasonRewards = (position: number, division: LeagueDivision): RewardGrant[] => {
  const multiplier = Math.max(1, DIVISIONS.findIndex(item => item.name === division) + 1);
  if (position === 1) return [{ type: 'gems', amount: 80 * multiplier }, { type: 'legendaryKeys', amount: 1 }, { type: 'chest', chestType: multiplier >= 6 ? 'legendary' : 'epic', amount: 1 }];
  if (position <= 3) return [{ type: 'gems', amount: 45 * multiplier }, { type: 'chest', chestType: 'epic', amount: 1 }];
  if (position <= 10) return [{ type: 'gems', amount: 22 * multiplier }, { type: 'chest', chestType: 'rare', amount: 1 }];
  if (position <= 50) return [{ type: 'coins', amount: 1300 * multiplier }, { type: 'keys', amount: 1 }];
  return [{ type: 'coins', amount: 500 * multiplier }, { type: 'profileXp', amount: 120 * multiplier }];
};

export const getFirstPlaceSkinForDivision = (division: LeagueDivision) => {
  const skinsByDivision: Record<LeagueDivision, string> = {
    Bronze: 'league_bronze_champion',
    Prata: 'astral_crown',
    Ouro: 'star_king',
    Platina: 'cosmic_emperor',
    Diamante: 'black_sun',
    Mestre: 'celestial_core',
    Lendário: 'ring_devourer',
    Ultimate: 'league_king_neon',
  };
  return skinsByDivision[division];
};

export const rewardToLabel = (reward: RewardGrant) => {
  if (reward.type === 'coins') return `Moedas +${reward.amount}`;
  if (reward.type === 'gems') return `Gemas +${reward.amount}`;
  if (reward.type === 'keys') return `Chaves +${reward.amount}`;
  if (reward.type === 'legendaryKeys') return `Chave lendária +${reward.amount}`;
  if (reward.type === 'profileXp') return `XP +${reward.amount}`;
  if (reward.type === 'fragments') return `Fragmentos +${reward.amount}`;
  return `Baú ${reward.chestType} x${reward.amount}`;
};

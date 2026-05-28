import { RewardGrant } from './retention';

export type LeagueDivision = 'Bronze' | 'Prata' | 'Ouro' | 'Platina' | 'Diamante' | 'Mestre' | 'Lendário' | 'Ultimate';

export interface LeagueRival {
  id: string;
  name: string;
  avatar: string;
  favoriteSkin: string;
  level: number;
  score: number;
  maxPhase: number;
  bossWins: number;
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
  top10Finishes: number;
  ultimateFirstPlaceFinishes: number;
  initialFirstPlaceFinishes: number;
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
}

export const DIVISIONS: { name: LeagueDivision; minScore: number }[] = [
  { name: 'Bronze', minScore: 0 },
  { name: 'Prata', minScore: 5000 },
  { name: 'Ouro', minScore: 15000 },
  { name: 'Platina', minScore: 35000 },
  { name: 'Diamante', minScore: 70000 },
  { name: 'Mestre', minScore: 120000 },
  { name: 'Lendário', minScore: 200000 },
  { name: 'Ultimate', minScore: 350000 },
];

const avatars = ['🔵', '🟣', '🟡', '🤖', '👑', '💎', '⚡', '🔥', '❄️', '🌙', '🌟', '🌀'];
const skins = ['neon_blue', 'robot', 'fire', 'ice', 'lightning', 'crystal', 'cosmic_eye', 'solar_orb', 'black_hole', 'divine_core'];
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

export const createLeagueRivals = (playerId: string, playerScore: number, seasonKey = getSeasonKey()): LeagueRival[] => {
  const rand = random(`${playerId}_${seasonKey}_league_neon`);
  return Array.from({ length: 200 }, (_, index) => {
    const generatedName = index < baseNames.length ? baseNames[index] : `${prefixes[Math.floor(rand() * prefixes.length)]}${suffixes[Math.floor(rand() * suffixes.length)]}${Math.floor(rand() * 90)}`;
    const score = scoreForSlot(index, rand, playerScore);
    return {
      id: `rival_${seasonKey}_${index}`,
      name: generatedName,
      avatar: avatars[Math.floor(rand() * avatars.length)],
      favoriteSkin: skins[Math.floor(rand() * skins.length)],
      level: Math.max(1, Math.floor(score / 4200) + Math.floor(rand() * 8)),
      score,
      maxPhase: Math.max(1, Math.min(20, Math.floor(score / 18000) + Math.ceil(rand() * 6))),
      bossWins: Math.floor(score / 52000 + rand() * 8),
      division: getDivisionForScore(score),
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
    const score = rival.score + gain;
    return { ...rival, score, division: getDivisionForScore(score), level: Math.max(rival.level, Math.floor(score / 4200)) };
  });
};

export const defaultLeagueSave = (playerId: string, playerScore = 0): LeagueSave => ({
  rivals: createLeagueRivals(playerId, playerScore),
  seasonKey: getSeasonKey(),
  lastDailyProgressKey: getDayKey(),
  claimedDivisionRewards: [],
  history: {
    bestPosition: 201,
    bestDivision: 'Bronze',
    seasonsPlayed: 0,
    firstPlaceFinishes: 0,
    top10Finishes: 0,
    ultimateFirstPlaceFinishes: 0,
    initialFirstPlaceFinishes: 0,
    rankingSkinsObtained: [],
  },
});

export const getRankedLeague = (rivals: LeagueRival[], player: LeagueRival) =>
  [...rivals, player].sort((a, b) => b.score - a.score || a.name.localeCompare(b.name));

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
  if (division === 'Ultimate') return 'league_king_neon';
  if (division === 'Bronze') return 'league_bronze_champion';
  return undefined;
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

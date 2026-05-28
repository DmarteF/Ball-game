import { SkinRarity } from './skins';

export type AchievementCategory = 'progresso' | 'combate' | 'coleção' | 'economia' | 'baús' | 'skins' | 'perfect escape' | 'boss' | 'especiais';
export type AchievementReward =
  | { type: 'coins'; amount: number }
  | { type: 'gems'; amount: number }
  | { type: 'keys'; amount: number }
  | { type: 'legendaryKeys'; amount: number }
  | { type: 'chest'; chestType: 'common' | 'rare' | 'epic' | 'legendary'; amount: number }
  | { type: 'fragments'; skinId?: string; amount: number }
  | { type: 'skin'; skinId: string }
  | { type: 'profileXp'; amount: number };

export interface AchievementDefinition {
  id: string;
  name: string;
  description: string;
  category: AchievementCategory;
  required: number;
  reward: AchievementReward;
  rarity: SkinRarity | 'special';
}

export interface AchievementState {
  progress: number;
  completed: boolean;
  claimed: boolean;
}

export type AchievementProgressSource = {
  runsPlayed: number;
  ringsDestroyed: number;
  perfectEscapes: number;
  diamondsFound: number;
  chestsOpened: number;
  skinsUnlocked: number;
  rareSkinsUnlocked: number;
  epicSkinsUnlocked: number;
  legendarySkinsUnlocked: number;
  highestPhase: number;
  noReviveWins: number;
  bossRuns: number;
  bossWins: number;
  bossBestDifficulty: number;
};

export const BOSS_DIFFICULTY_RANK: Record<string, number> = {
  easy: 1,
  medium: 2,
  hard: 3,
  insane: 4,
};

export const ACHIEVEMENTS: AchievementDefinition[] = [
  { id: 'first_steps', name: 'Primeiros Passos', description: 'Jogue a primeira partida.', category: 'progresso', required: 1, reward: { type: 'coins', amount: 250 }, rarity: 'common' },
  { id: 'first_perfect', name: 'Primeiro Escape', description: 'Faça 1 escape perfeito.', category: 'perfect escape', required: 1, reward: { type: 'gems', amount: 8 }, rarity: 'rare' },
  { id: 'ring_breaker_1', name: 'Quebrador de Anéis I', description: 'Destrua 50 anéis.', category: 'combate', required: 50, reward: { type: 'coins', amount: 500 }, rarity: 'common' },
  { id: 'ring_breaker_2', name: 'Quebrador de Anéis II', description: 'Destrua 250 anéis.', category: 'combate', required: 250, reward: { type: 'keys', amount: 1 }, rarity: 'rare' },
  { id: 'ring_breaker_3', name: 'Quebrador de Anéis III', description: 'Destrua 1000 anéis.', category: 'combate', required: 1000, reward: { type: 'chest', chestType: 'rare', amount: 1 }, rarity: 'epic' },
  { id: 'perfect_hunter', name: 'Caçador de Perfect', description: 'Faça 25 escapes perfeitos.', category: 'perfect escape', required: 25, reward: { type: 'gems', amount: 35 }, rarity: 'epic' },
  { id: 'diamond_miner', name: 'Garimpeiro de Diamantes', description: 'Ganhe 10 diamantes por Perfect Escape.', category: 'economia', required: 10, reward: { type: 'gems', amount: 40 }, rarity: 'rare' },
  { id: 'starter_collector', name: 'Colecionador Iniciante', description: 'Desbloqueie 5 skins.', category: 'coleção', required: 5, reward: { type: 'chest', chestType: 'common', amount: 1 }, rarity: 'rare' },
  { id: 'rare_collector', name: 'Colecionador Raro', description: 'Desbloqueie 5 skins raras.', category: 'skins', required: 5, reward: { type: 'chest', chestType: 'rare', amount: 1 }, rarity: 'epic' },
  { id: 'epic_luck', name: 'Sorte Épica', description: 'Obtenha 1 skin épica.', category: 'skins', required: 1, reward: { type: 'gems', amount: 30 }, rarity: 'epic' },
  { id: 'legend_awake', name: 'Lenda Desperta', description: 'Obtenha 1 skin lendária.', category: 'skins', required: 1, reward: { type: 'chest', chestType: 'epic', amount: 1 }, rarity: 'legendary' },
  { id: 'chest_opener_1', name: 'Abridor de Baús I', description: 'Abra 5 baús.', category: 'baús', required: 5, reward: { type: 'coins', amount: 600 }, rarity: 'common' },
  { id: 'chest_opener_2', name: 'Abridor de Baús II', description: 'Abra 25 baús.', category: 'baús', required: 25, reward: { type: 'keys', amount: 2 }, rarity: 'rare' },
  { id: 'survivor', name: 'Sobrevivente', description: 'Vença uma fase sem usar revive.', category: 'progresso', required: 1, reward: { type: 'gems', amount: 12 }, rarity: 'rare' },
  { id: 'fearless', name: 'Sem Medo', description: 'Vença 5 fases sem usar revive.', category: 'progresso', required: 5, reward: { type: 'chest', chestType: 'epic', amount: 1 }, rarity: 'epic' },
  { id: 'stage_20_champion', name: 'Campeão dos 20 Estágios', description: 'Conclua todas as 20 fases principais.', category: 'especiais', required: 20, reward: { type: 'skin', skinId: 'cosmic_champion' }, rarity: 'special' },
  { id: 'first_duel', name: 'Primeiro Duelo', description: 'Jogue o Boss Mode pela primeira vez.', category: 'boss', required: 1, reward: { type: 'coins', amount: 300 }, rarity: 'common' },
  { id: 'boss_victory', name: 'Vitória Contra o Boss', description: 'Vença o Boss uma vez.', category: 'boss', required: 1, reward: { type: 'gems', amount: 20 }, rarity: 'rare' },
  { id: 'neon_rival', name: 'Rival Neon', description: 'Vença 5 partidas de Boss Mode.', category: 'boss', required: 5, reward: { type: 'chest', chestType: 'rare', amount: 1 }, rarity: 'epic' },
  { id: 'duel_master', name: 'Mestre dos Duelos', description: 'Vença o Boss na dificuldade difícil.', category: 'boss', required: 3, reward: { type: 'chest', chestType: 'epic', amount: 1 }, rarity: 'legendary' },
  { id: 'impossible', name: 'Impossível?', description: 'Vença o Boss na maior dificuldade.', category: 'boss', required: 4, reward: { type: 'legendaryKeys', amount: 1 }, rarity: 'ultimate' },
];

export const getAchievementProgress = (id: string, source: AchievementProgressSource) => {
  switch (id) {
    case 'first_steps': return source.runsPlayed;
    case 'first_perfect': return source.perfectEscapes;
    case 'ring_breaker_1':
    case 'ring_breaker_2':
    case 'ring_breaker_3': return source.ringsDestroyed;
    case 'perfect_hunter': return source.perfectEscapes;
    case 'diamond_miner': return source.diamondsFound;
    case 'starter_collector': return source.skinsUnlocked;
    case 'rare_collector': return source.rareSkinsUnlocked;
    case 'epic_luck': return source.epicSkinsUnlocked;
    case 'legend_awake': return source.legendarySkinsUnlocked;
    case 'chest_opener_1':
    case 'chest_opener_2': return source.chestsOpened;
    case 'survivor':
    case 'fearless': return source.noReviveWins;
    case 'stage_20_champion': return source.highestPhase;
    case 'first_duel': return source.bossRuns;
    case 'boss_victory':
    case 'neon_rival': return source.bossWins;
    case 'duel_master': return source.bossBestDifficulty;
    case 'impossible': return source.bossBestDifficulty;
    default: return 0;
  }
};

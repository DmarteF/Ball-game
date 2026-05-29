import { SkinRarity } from './skins';

export type AchievementCategory = 'progresso' | 'combate' | 'coleção' | 'economia' | 'baús' | 'skins' | 'perfect escape' | 'boss' | 'liga' | 'infinito' | 'especiais';
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
  bossImpossibleWins: number;
  bossImpossibleDays: number;
  leagueTop10Finishes: number;
  leagueFirstPlaceFinishes: number;
  leagueUltimateFirstPlaceFinishes: number;
  leagueInitialCrowns: number;
  leagueCompetitionWins: number;
  leagueCompetitionLosses: number;
  leagueBestWinStreak: number;
  totalTrophiesGained: number;
  leagueDiamondReached: number;
  leagueLegendaryReached: number;
  leagueUltimateReached: number;
  infiniteBestSeconds: number;
  infiniteBestRings: number;
  infiniteBestLevel: number;
  infiniteChallengeCompletions: number;
};

export const BOSS_DIFFICULTY_RANK: Record<string, number> = {
  none: 0,
  easy: 1,
  normal: 1,
  medium: 2,
  forte: 2,
  hard: 3,
  elite: 3,
  lendario: 4,
  insane: 5,
  impossivel: 5,
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
  { id: 'stage_20_champion', name: 'Campeão dos 50 Estágios', description: 'Conclua todas as 50 fases principais.', category: 'especiais', required: 50, reward: { type: 'skin', skinId: 'cosmic_champion' }, rarity: 'special' },
  { id: 'first_duel', name: 'Primeiro Boss', description: 'Enfrente o Boss mensal pela primeira vez.', category: 'boss', required: 1, reward: { type: 'coins', amount: 300 }, rarity: 'common' },
  { id: 'boss_victory', name: 'Vitória Normal', description: 'Vença o Boss mensal no nível Normal.', category: 'boss', required: 1, reward: { type: 'gems', amount: 20 }, rarity: 'rare' },
  { id: 'boss_elite', name: 'Chegou no Elite', description: 'Vença até o nível Elite do Boss mensal.', category: 'boss', required: 3, reward: { type: 'keys', amount: 1 }, rarity: 'epic' },
  { id: 'boss_legendary', name: 'Lendário Derrotado', description: 'Vença o nível Lendário do Boss mensal.', category: 'boss', required: 4, reward: { type: 'chest', chestType: 'epic', amount: 1 }, rarity: 'legendary' },
  { id: 'impossible', name: 'Impossível Vencido', description: 'Vença o Boss mensal no nível Impossível.', category: 'boss', required: 5, reward: { type: 'legendaryKeys', amount: 1 }, rarity: 'ultimate' },
  { id: 'monthly_hunter', name: 'Caçador Mensal', description: 'Vença o Impossível 5 vezes no mesmo mês.', category: 'boss', required: 5, reward: { type: 'fragments', skinId: 'divine_core', amount: 20 }, rarity: 'ultimate' },
  { id: 'month_dominator', name: 'Dominador do Mês', description: 'Vença o Impossível em 10 dias diferentes no mesmo mês.', category: 'boss', required: 10, reward: { type: 'chest', chestType: 'legendary', amount: 1 }, rarity: 'ultimate' },
  { id: 'neon_top_10', name: 'Top 10 Neon', description: 'Finalize uma temporada da Liga Neon no top 10.', category: 'especiais', required: 1, reward: { type: 'gems', amount: 60 }, rarity: 'epic' },
  { id: 'league_champion', name: 'Campeão da Liga', description: 'Termine uma temporada da Liga Neon em #1.', category: 'especiais', required: 1, reward: { type: 'chest', chestType: 'epic', amount: 1 }, rarity: 'legendary' },
  { id: 'supreme_champion', name: 'Campeão Supremo', description: 'Termine em #1 na divisão Ultimate da Liga Neon.', category: 'especiais', required: 1, reward: { type: 'fragments', skinId: 'league_king_neon', amount: 80 }, rarity: 'ultimate' },
  { id: 'back_to_top', name: 'Retorno ao Topo', description: 'Volte ao #1 depois de uma temporada com rebaixamento.', category: 'especiais', required: 2, reward: { type: 'gems', amount: 70 }, rarity: 'legendary' },
  { id: 'first_crown', name: 'Primeira Coroa', description: 'Primeira vez em #1 no rank inicial da Liga Neon.', category: 'especiais', required: 1, reward: { type: 'skin', skinId: 'initial_neon_champion' }, rarity: 'ultimate' },
  { id: 'first_compete', name: 'Primeiro Competir', description: 'Jogue uma competição da Liga Neon.', category: 'liga', required: 1, reward: { type: 'coins', amount: 400 }, rarity: 'common' },
  { id: 'first_compete_win', name: 'Primeira Vitória', description: 'Vença uma competição da Liga Neon.', category: 'liga', required: 1, reward: { type: 'gems', amount: 18 }, rarity: 'rare' },
  { id: 'ranking_up_silver', name: 'Subindo no Ranking', description: 'Alcance a divisão Prata.', category: 'liga', required: 300, reward: { type: 'chest', chestType: 'common', amount: 1 }, rarity: 'rare' },
  { id: 'trophy_hunter', name: 'Caçador de Troféus', description: 'Ganhe 500 troféus totais.', category: 'liga', required: 500, reward: { type: 'keys', amount: 1 }, rarity: 'rare' },
  { id: 'neon_streak', name: 'Sequência Neon', description: 'Vença 5 competições seguidas.', category: 'liga', required: 5, reward: { type: 'chest', chestType: 'rare', amount: 1 }, rarity: 'epic' },
  { id: 'unstoppable', name: 'Imparável', description: 'Vença 10 competições seguidas.', category: 'liga', required: 10, reward: { type: 'chest', chestType: 'epic', amount: 1 }, rarity: 'legendary' },
  { id: 'league_elite', name: 'Elite da Liga', description: 'Alcance Diamante na Liga Neon.', category: 'liga', required: 1, reward: { type: 'chest', chestType: 'rare', amount: 1 }, rarity: 'epic' },
  { id: 'competitive_legend', name: 'Lenda Competitiva', description: 'Alcance Lendário na Liga Neon.', category: 'liga', required: 1, reward: { type: 'legendaryKeys', amount: 1 }, rarity: 'legendary' },
  { id: 'trophy_king', name: 'Rei dos Troféus', description: 'Alcance Ultimate na Liga Neon.', category: 'liga', required: 1, reward: { type: 'fragments', skinId: 'league_king_neon', amount: 70 }, rarity: 'ultimate' },
  { id: 'inf_survive_1', name: 'Pulso Infinito', description: 'Sobreviva 1 minuto no Modo Infinito.', category: 'infinito', required: 60, reward: { type: 'skin', skinId: 'infinite_pulse' }, rarity: 'common' },
  { id: 'inf_survive_3', name: 'Loop Estável', description: 'Sobreviva 3 minutos no Modo Infinito.', category: 'infinito', required: 180, reward: { type: 'skin', skinId: 'loop_flame' }, rarity: 'rare' },
  { id: 'inf_survive_5', name: 'Eclipse Neon', description: 'Sobreviva 5 minutos no Modo Infinito.', category: 'infinito', required: 300, reward: { type: 'skin', skinId: 'neon_eclipse' }, rarity: 'epic' },
  { id: 'inf_survive_10', name: 'Núcleo Eterno', description: 'Sobreviva 10 minutos no Modo Infinito.', category: 'infinito', required: 600, reward: { type: 'skin', skinId: 'cosmic_fragment' }, rarity: 'legendary' },
  { id: 'inf_survive_15', name: 'Vórtice Mítico', description: 'Sobreviva 15 minutos no Modo Infinito.', category: 'infinito', required: 900, reward: { type: 'skin', skinId: 'infinite_vortex_mythic' }, rarity: 'mythic' },
  { id: 'inf_survive_20', name: 'Ômega Infinito', description: 'Sobreviva 20 minutos no Modo Infinito.', category: 'infinito', required: 1200, reward: { type: 'skin', skinId: 'omega_infinity' }, rarity: 'ultimate' },
  { id: 'inf_survive_30', name: 'Meia Hora Sem Fim', description: 'Sobreviva 30 minutos no Modo Infinito.', category: 'infinito', required: 1800, reward: { type: 'legendaryKeys', amount: 1 }, rarity: 'ultimate' },
  { id: 'inf_rings_25', name: 'Vórtice Azul', description: 'Quebre 25 anéis em uma run infinita.', category: 'infinito', required: 25, reward: { type: 'skin', skinId: 'blue_vortex' }, rarity: 'common' },
  { id: 'inf_rings_50', name: 'Cometa Rubro', description: 'Quebre 50 anéis em uma run infinita.', category: 'infinito', required: 50, reward: { type: 'skin', skinId: 'red_comet' }, rarity: 'rare' },
  { id: 'inf_rings_100', name: 'Prisma Sem Fim', description: 'Quebre 100 anéis em uma run infinita.', category: 'infinito', required: 100, reward: { type: 'skin', skinId: 'endless_prism' }, rarity: 'epic' },
  { id: 'inf_rings_150', name: 'Cortador de Loop', description: 'Quebre 150 anéis em uma run infinita.', category: 'infinito', required: 150, reward: { type: 'gems', amount: 80 }, rarity: 'legendary' },
  { id: 'inf_rings_300', name: 'Coroa da Singularidade', description: 'Quebre 300 anéis em uma run infinita.', category: 'infinito', required: 300, reward: { type: 'skin', skinId: 'singularity_crown' }, rarity: 'ultimate' },
  { id: 'inf_challenge_1', name: 'Primeiro Desafio', description: 'Complete 1 seção difícil no Modo Infinito.', category: 'infinito', required: 1, reward: { type: 'keys', amount: 1 }, rarity: 'rare' },
  { id: 'inf_challenge_5', name: 'Núcleo Eterno', description: 'Complete 5 seções difíceis no Modo Infinito.', category: 'infinito', required: 5, reward: { type: 'skin', skinId: 'eternal_core' }, rarity: 'legendary' },
  { id: 'inf_challenge_10', name: 'Loop Cronal', description: 'Complete 10 seções difíceis no Modo Infinito.', category: 'infinito', required: 10, reward: { type: 'skin', skinId: 'chrono_loop_mythic' }, rarity: 'mythic' },
  { id: 'inf_level_5', name: 'Roguelike Neon I', description: 'Alcance nível 5 em uma run infinita.', category: 'infinito', required: 5, reward: { type: 'coins', amount: 1200 }, rarity: 'epic' },
  { id: 'inf_level_10', name: 'Roguelike Neon II', description: 'Alcance nível 10 em uma run infinita.', category: 'infinito', required: 10, reward: { type: 'gems', amount: 100 }, rarity: 'legendary' },
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
    case 'boss_victory': return source.bossBestDifficulty;
    case 'boss_elite': return source.bossBestDifficulty;
    case 'boss_legendary': return source.bossBestDifficulty;
    case 'impossible': return source.bossBestDifficulty;
    case 'monthly_hunter': return source.bossImpossibleWins;
    case 'month_dominator': return source.bossImpossibleDays;
    case 'neon_top_10': return source.leagueTop10Finishes;
    case 'league_champion': return source.leagueFirstPlaceFinishes;
    case 'supreme_champion': return source.leagueUltimateFirstPlaceFinishes;
    case 'back_to_top': return source.leagueFirstPlaceFinishes;
    case 'first_crown': return source.leagueInitialCrowns;
    case 'first_compete': return source.leagueCompetitionWins + source.leagueCompetitionLosses;
    case 'first_compete_win': return source.leagueCompetitionWins;
    case 'ranking_up_silver': return source.totalTrophiesGained;
    case 'trophy_hunter': return source.totalTrophiesGained;
    case 'neon_streak':
    case 'unstoppable': return source.leagueBestWinStreak;
    case 'league_elite': return source.leagueDiamondReached;
    case 'competitive_legend': return source.leagueLegendaryReached;
    case 'trophy_king': return source.leagueUltimateReached;
    case 'inf_survive_1':
    case 'inf_survive_3':
    case 'inf_survive_5':
    case 'inf_survive_10':
    case 'inf_survive_15':
    case 'inf_survive_20':
    case 'inf_survive_30': return source.infiniteBestSeconds;
    case 'inf_rings_25':
    case 'inf_rings_50':
    case 'inf_rings_100':
    case 'inf_rings_150':
    case 'inf_rings_300': return source.infiniteBestRings;
    case 'inf_challenge_1':
    case 'inf_challenge_5':
    case 'inf_challenge_10': return source.infiniteChallengeCompletions;
    case 'inf_level_5':
    case 'inf_level_10': return source.infiniteBestLevel;
    default: return 0;
  }
};

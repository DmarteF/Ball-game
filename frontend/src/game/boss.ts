import { RingConfig } from './rings';

export type BossLevelId = 'normal' | 'forte' | 'elite' | 'lendario' | 'impossivel';

export interface BossRewardPlan {
  coins: number;
  xp: number;
  gems?: number;
  keys?: number;
  fragments?: number;
  chest?: 'common' | 'rare' | 'epic' | 'legendary';
  ultimateFragmentChance?: number;
  bossSkinChance?: number;
}

export interface BossLevelDefinition {
  id: BossLevelId;
  name: string;
  rank: number;
  phase: number;
  playerRings: number;
  bossRings: number;
  baseHp: number;
  closingSpeed: number;
  rotationSpeed: number;
  solidCount: number;
  solidHpMultiplier: number;
  bossSpeedMultiplier: number;
  bossDamageMultiplier: number;
  bossShrinkMultiplier: number;
  aiQuality: number;
  reward: BossRewardPlan;
}

export interface MonthlyBossDefinition {
  id: string;
  monthIndex: number;
  name: string;
  skinId: string;
  icon: string;
  theme: string;
  description: string;
  passive: string;
  colors: string[];
  levels: BossLevelDefinition[];
}

export interface BossHistoryEntry {
  monthKey: string;
  bossId: string;
  bossName: string;
  bestLevelWon: BossLevelId | 'none';
  totalWins: number;
  impossibleWins: number;
  specialRewards: string[];
}

export interface BossProgressSave {
  dayKey: string;
  monthKey: string;
  bossId: string;
  dailyLevelWins: BossLevelId[];
  dailyRewardsClaimed: BossLevelId[];
  monthlyBestLevelWon: BossLevelId | 'none';
  monthlyTotalWins: number;
  monthlyImpossibleWins: number;
  monthlyImpossibleDays: string[];
  specialRewards: string[];
  history: BossHistoryEntry[];
}

const bossLevel = (
  id: BossLevelId,
  name: string,
  rank: number,
  reward: BossRewardPlan,
): BossLevelDefinition => ({
  id,
  name,
  rank,
  phase: 5 + rank * 3,
  playerRings: 10 + rank * 2,
  bossRings: 9 + rank * 3,
  baseHp: 26 + rank * 16,
  closingSpeed: 0.036 + rank * 0.007,
  rotationSpeed: 0.009 + rank * 0.002,
  solidCount: 1 + rank,
  solidHpMultiplier: 1.25 + rank * 0.16,
  bossSpeedMultiplier: 0.9 + rank * 0.1,
  bossDamageMultiplier: 0.95 + rank * 0.16,
  bossShrinkMultiplier: 0.92 + rank * 0.08,
  aiQuality: 0.42 + rank * 0.11,
  reward,
});

export const BOSS_LEVELS: BossLevelDefinition[] = [
  bossLevel('normal', 'Normal', 0, { coins: 180, xp: 80 }),
  bossLevel('forte', 'Forte', 1, { coins: 280, xp: 120, gems: 4 }),
  bossLevel('elite', 'Elite', 2, { coins: 380, xp: 170, gems: 9, keys: 1, fragments: 6 }),
  bossLevel('lendario', 'Lendário', 3, { coins: 560, xp: 240, gems: 14, keys: 1, fragments: 12, chest: 'rare' }),
  bossLevel('impossivel', 'Impossível', 4, { coins: 820, xp: 360, gems: 24, keys: 2, fragments: 22, chest: 'epic', ultimateFragmentChance: 0.22, bossSkinChance: 0.03 }),
];

export const BOSS_LEVEL_RANK: Record<string, number> = {
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

const monthlyBoss = (
  monthIndex: number,
  id: string,
  name: string,
  skinId: string,
  icon: string,
  theme: string,
  description: string,
  passive: string,
  colors: string[],
): MonthlyBossDefinition => ({
  id,
  monthIndex,
  name,
  skinId,
  icon,
  theme,
  description,
  passive,
  colors,
  levels: BOSS_LEVELS,
});

export const MONTHLY_BOSSES: MonthlyBossDefinition[] = [
  monthlyBoss(0, 'divine_core_january', 'Núcleo Divino', 'divine_core', '🔱', 'dourado/celestial', 'Um núcleo celestial que endurece os últimos anéis.', 'Críticos divinos aumentam o dano nos anéis sólidos.', ['#fff7ad', '#22d3ee', '#ffd700']),
  monthlyBoss(1, 'living_singularity_february', 'Singularidade Viva', 'living_singularity', '🕳️', 'buraco negro/neon roxo', 'Uma esfera de gravidade viva e agressiva.', 'A gravidade acelera o fechamento no fim da arena.', ['#7c3aed', '#00f0ff', '#111827']),
  monthlyBoss(2, 'void_devourer_march', 'Devorador do Vazio', 'void_devourer_ultimate', '🌌', 'escuro/vermelho/roxo', 'Uma presença que consome espaço entre anéis.', 'Anéis sólidos recebem vida extra.', ['#ff0055', '#7c3aed', '#050516']),
  monthlyBoss(3, 'neon_league_king_april', 'Rei da Liga Neon', 'league_king_neon', '👑', 'coroa neon/dourado', 'O campeão da Liga entra como Boss mensal.', 'Combos do Boss compram ATK com mais frequência.', ['#ffd700', '#00f0ff', '#8b5cf6']),
  monthlyBoss(4, 'cosmic_champion_may', 'Campeão Cósmico', 'cosmic_champion', '🌟', 'cósmico/dourado', 'Energia cósmica em disputa direta.', 'Dano cresce quando restam poucos anéis.', ['#ffd700', '#7c3aed', '#38bdf8']),
  monthlyBoss(5, 'phoenix_june', 'Fênix Solar', 'neon_phoenix', '🔥', 'solar/vermelho', 'Um Boss que renasce em anéis sólidos.', 'Quebras sólidas dão mais moedas ao Boss.', ['#ff4d00', '#facc15', '#ff0055']),
  monthlyBoss(6, 'astral_dragon_july', 'Dragão Astral', 'astral_dragon', '🐲', 'astral/ciano', 'O dragão atravessa padrões rápidos.', 'Rotação interna mais agressiva.', ['#22d3ee', '#7c3aed', '#ffffff']),
  monthlyBoss(7, 'star_king_august', 'Rei das Estrelas', 'star_king', '🌟', 'estelar/azul', 'Um rei de estrelas em arena compacta.', 'Recebe mais Gold no começo.', ['#fff7ad', '#38bdf8', '#ffd700']),
  monthlyBoss(8, 'astral_crown_september', 'Coroa Astral', 'astral_crown', '👑', 'astral/dourado', 'Uma coroa que pressiona o jogador.', 'Críticos mais frequentes.', ['#ffd700', '#a855f7', '#ffffff']),
  monthlyBoss(9, 'robot_overlord_october', 'Soberano Robô', 'robot', '🤖', 'metal/neon', 'Precisão mecânica contra a sua arena.', 'Compras automáticas acontecem em janelas menores.', ['#94a3b8', '#00f0ff', '#f43f5e']),
  monthlyBoss(10, 'shadow_november', 'Sombra Suprema', 'shadow_orb', '🌑', 'sombrio/roxo', 'Uma sombra que fecha anéis sem pressa.', 'HP extra no último anel sólido.', ['#111827', '#8b5cf6', '#ff0055']),
  monthlyBoss(11, 'aurora_december', 'Aurora Final', 'cosmic_eye', '🌈', 'aurora/neon', 'A última prova anual do Boss Mode.', 'Escala equilibrada em dano e velocidade.', ['#00f0ff', '#ff4fd8', '#00ff88']),
];

export const getBossDayKey = (date = new Date()) =>
  `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
export const getBossMonthKey = (date = new Date()) => `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
export const getMonthlyBoss = (date = new Date()) => MONTHLY_BOSSES[date.getMonth()] || MONTHLY_BOSSES[0];
export const getBossLevel = (id: string) => BOSS_LEVELS.find(level => level.id === id) || BOSS_LEVELS[0];
export const getNextBossLevel = (progress: BossProgressSave) => BOSS_LEVELS[Math.min(progress.dailyLevelWins.length, BOSS_LEVELS.length - 1)];
export const isBossDailyComplete = (progress: BossProgressSave) => progress.dailyLevelWins.includes('impossivel');

export const createBossProgress = (date = new Date()): BossProgressSave => {
  const boss = getMonthlyBoss(date);
  return {
    dayKey: getBossDayKey(date),
    monthKey: getBossMonthKey(date),
    bossId: boss.id,
    dailyLevelWins: [],
    dailyRewardsClaimed: [],
    monthlyBestLevelWon: 'none',
    monthlyTotalWins: 0,
    monthlyImpossibleWins: 0,
    monthlyImpossibleDays: [],
    specialRewards: [],
    history: [],
  };
};

export const normalizeBossProgress = (progress?: Partial<BossProgressSave>, date = new Date()): BossProgressSave => {
  const fallback = createBossProgress(date);
  const current = { ...fallback, ...(progress || {}) };
  const monthKey = getBossMonthKey(date);
  const dayKey = getBossDayKey(date);
  const boss = getMonthlyBoss(date);

  if (current.monthKey !== monthKey || current.bossId !== boss.id) {
    const previousBoss = MONTHLY_BOSSES.find(item => item.id === current.bossId);
    const history = current.bossId
      ? [{
          monthKey: current.monthKey || fallback.monthKey,
          bossId: current.bossId,
          bossName: previousBoss?.name || current.bossId,
          bestLevelWon: current.monthlyBestLevelWon || 'none',
          totalWins: current.monthlyTotalWins || 0,
          impossibleWins: current.monthlyImpossibleWins || 0,
          specialRewards: current.specialRewards || [],
        }, ...(current.history || [])].slice(0, 12)
      : current.history || [];
    return { ...fallback, history };
  }

  if (current.dayKey !== dayKey) {
    return { ...current, dayKey, dailyLevelWins: [], dailyRewardsClaimed: [] };
  }

  return {
    ...current,
    dayKey,
    monthKey,
    bossId: boss.id,
    dailyLevelWins: (current.dailyLevelWins || []).filter(id => BOSS_LEVELS.some(level => level.id === id)),
    dailyRewardsClaimed: (current.dailyRewardsClaimed || []).filter(id => BOSS_LEVELS.some(level => level.id === id)),
    monthlyImpossibleDays: Array.from(new Set(current.monthlyImpossibleDays || [])),
    history: current.history || [],
    specialRewards: current.specialRewards || [],
  };
};

export const createBossRingConfig = (
  level: BossLevelDefinition,
  size: number,
  colors: string[],
  side: 'player' | 'boss',
): RingConfig => ({
  count: side === 'boss' ? level.bossRings : level.playerRings,
  innerRadius: 24,
  outerRadius: size / 2 - 14,
  baseRotationSpeed: level.rotationSpeed * (side === 'boss' ? level.bossSpeedMultiplier : 1),
  baseHp: level.baseHp * (side === 'boss' ? level.bossDamageMultiplier : 1),
  baseGapSize: Math.PI / (side === 'boss' ? 3.35 : 3.15),
  baseThickness: 4,
  closingSpeed: level.closingSpeed * (side === 'boss' ? level.bossShrinkMultiplier : 1),
  colors,
  solidCount: level.solidCount,
  solidHpMultiplier: level.solidHpMultiplier,
});

export const describeBossReward = (reward: BossRewardPlan) => [
  `${reward.coins} moedas`,
  `${reward.xp} XP perfil`,
  reward.gems ? `${reward.gems} gemas` : '',
  reward.keys ? `${reward.keys} chave(s)` : '',
  reward.fragments ? `${reward.fragments} fragmentos` : '',
  reward.chest ? `Baú ${reward.chest}` : '',
  reward.ultimateFragmentChance ? 'chance de fragmento Ultimate' : '',
].filter(Boolean).join(' + ');

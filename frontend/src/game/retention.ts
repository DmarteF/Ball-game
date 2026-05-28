import { ChestType } from './chests';
import { getLocalDayKey, getLocalWeekKey, getWeeklyEventIndex } from '@/src/utils/time';

export type RewardGrant =
  | { type: 'coins'; amount: number }
  | { type: 'gems'; amount: number }
  | { type: 'keys'; amount: number }
  | { type: 'legendaryKeys'; amount: number }
  | { type: 'profileXp'; amount: number }
  | { type: 'fragments'; skinId?: string; amount: number }
  | { type: 'chest'; chestType: ChestType; amount: number };

export type MissionMetric =
  | 'ringsDestroyed' | 'perfectEscapes' | 'runsPlayed' | 'phaseWins' | 'chestsOpened'
  | 'runCoins' | 'gemsEarned' | 'runUpgrades' | 'bestCombo' | 'skinEquips'
  | 'bossRuns' | 'bossWins' | 'offlineClaims' | 'storePurchases' | 'adsWatched'
  | 'criticals' | 'skinEffects' | 'noReviveWins';

export interface MissionDefinition {
  id: string;
  title: string;
  metric: MissionMetric;
  target: number;
  reward: RewardGrant;
  difficulty: 1 | 2 | 3;
}

export interface MissionState {
  id: string;
  progress: number;
  claimed: boolean;
  rerolled?: boolean;
  boosted?: boolean;
}

export interface DailyMissionSave {
  dayKey: string;
  missions: MissionState[];
}

export interface WheelSave {
  dayKey: string;
  freeUsed: boolean;
  adSpinsUsed: number;
}

export interface WeeklyEventSave {
  weekKey: string;
  eventId: string;
  missions: MissionState[];
  grandClaimed: boolean;
}

export interface AdLimitSave {
  dayKey: string;
  total: number;
  byPlacement: Record<string, number>;
}

export const DAILY_MISSIONS: MissionDefinition[] = [
  { id: 'rings_50', title: 'Destruir 50 anéis', metric: 'ringsDestroyed', target: 50, reward: { type: 'coins', amount: 260 }, difficulty: 1 },
  { id: 'rings_150', title: 'Destruir 150 anéis', metric: 'ringsDestroyed', target: 150, reward: { type: 'keys', amount: 1 }, difficulty: 2 },
  { id: 'perfect_3', title: 'Fazer 3 Perfect Escapes', metric: 'perfectEscapes', target: 3, reward: { type: 'gems', amount: 5 }, difficulty: 1 },
  { id: 'perfect_10', title: 'Fazer 10 Perfect Escapes', metric: 'perfectEscapes', target: 10, reward: { type: 'gems', amount: 14 }, difficulty: 2 },
  { id: 'runs_3', title: 'Jogar 3 partidas', metric: 'runsPlayed', target: 3, reward: { type: 'profileXp', amount: 70 }, difficulty: 1 },
  { id: 'runs_5', title: 'Jogar 5 partidas', metric: 'runsPlayed', target: 5, reward: { type: 'coins', amount: 420 }, difficulty: 2 },
  { id: 'win_1', title: 'Vencer 1 fase', metric: 'phaseWins', target: 1, reward: { type: 'gems', amount: 8 }, difficulty: 1 },
  { id: 'win_3', title: 'Vencer 3 fases', metric: 'phaseWins', target: 3, reward: { type: 'chest', chestType: 'rare', amount: 1 }, difficulty: 3 },
  { id: 'chest_1', title: 'Abrir 1 baú', metric: 'chestsOpened', target: 1, reward: { type: 'fragments', amount: 12 }, difficulty: 1 },
  { id: 'chest_3', title: 'Abrir 3 baús', metric: 'chestsOpened', target: 3, reward: { type: 'keys', amount: 1 }, difficulty: 2 },
  { id: 'coins_500', title: 'Ganhar 500 moedas da rodada', metric: 'runCoins', target: 500, reward: { type: 'coins', amount: 320 }, difficulty: 1 },
  { id: 'coins_2000', title: 'Ganhar 2.000 moedas da rodada', metric: 'runCoins', target: 2000, reward: { type: 'gems', amount: 12 }, difficulty: 3 },
  { id: 'gems_5', title: 'Ganhar 5 diamantes', metric: 'gemsEarned', target: 5, reward: { type: 'profileXp', amount: 120 }, difficulty: 2 },
  { id: 'temp_upgrades_3', title: 'Usar 3 upgrades temporários', metric: 'runUpgrades', target: 3, reward: { type: 'coins', amount: 260 }, difficulty: 1 },
  { id: 'combo_5', title: 'Fazer combo x5', metric: 'bestCombo', target: 5, reward: { type: 'gems', amount: 5 }, difficulty: 1 },
  { id: 'combo_10', title: 'Fazer combo x10', metric: 'bestCombo', target: 10, reward: { type: 'keys', amount: 1 }, difficulty: 2 },
  { id: 'equip_skin', title: 'Equipar uma skin diferente', metric: 'skinEquips', target: 1, reward: { type: 'fragments', amount: 10 }, difficulty: 1 },
  { id: 'boss_run', title: 'Jogar Boss Mode 1 vez', metric: 'bossRuns', target: 1, reward: { type: 'coins', amount: 360 }, difficulty: 1 },
  { id: 'boss_win', title: 'Vencer Boss Mode 1 vez', metric: 'bossWins', target: 1, reward: { type: 'gems', amount: 16 }, difficulty: 3 },
  { id: 'offline_claim', title: 'Coletar recompensa offline', metric: 'offlineClaims', target: 1, reward: { type: 'coins', amount: 220 }, difficulty: 1 },
  { id: 'store_buy', title: 'Comprar algo na loja simulada', metric: 'storePurchases', target: 1, reward: { type: 'gems', amount: 6 }, difficulty: 1 },
  { id: 'watch_ad', title: 'Usar anúncio simulado 1 vez', metric: 'adsWatched', target: 1, reward: { type: 'coins', amount: 240 }, difficulty: 1 },
  { id: 'crit_5', title: 'Fazer 5 críticos', metric: 'criticals', target: 5, reward: { type: 'profileXp', amount: 90 }, difficulty: 1 },
  { id: 'skin_effect_10', title: 'Quebrar 10 anéis com efeito de skin', metric: 'skinEffects', target: 10, reward: { type: 'fragments', amount: 18 }, difficulty: 2 },
  { id: 'no_revive', title: 'Concluir uma fase sem revive', metric: 'noReviveWins', target: 1, reward: { type: 'gems', amount: 10 }, difficulty: 2 },
];

export interface WeeklyEventDefinition {
  id: string;
  name: string;
  description: string;
  bonus: string;
  color: string;
  missions: MissionDefinition[];
  grandReward: RewardGrant;
}

const eventMission = (event: string, title: string, metric: MissionMetric, target: number, reward: RewardGrant): MissionDefinition => ({
  id: `${event}_${metric}_${target}`,
  title,
  metric,
  target,
  reward,
  difficulty: target > 100 || metric === 'bossWins' ? 3 : 2,
});

export const WEEKLY_EVENTS: WeeklyEventDefinition[] = [
  { id: 'neon', name: 'Evento Neon', description: 'Ritmo alto, combos e baús brilhantes.', bonus: '+10% moedas da rodada e chance maior de skins elétricas.', color: '#00f0ff', grandReward: { type: 'chest', chestType: 'rare', amount: 1 }, missions: [eventMission('neon', 'Destruir 500 anéis', 'ringsDestroyed', 500, { type: 'coins', amount: 900 }), eventMission('neon', 'Fazer combo x10 cinco vezes', 'bestCombo', 10, { type: 'gems', amount: 18 }), eventMission('neon', 'Abrir 10 baús', 'chestsOpened', 10, { type: 'keys', amount: 2 })] },
  { id: 'frost', name: 'Evento Gelado', description: 'Congelar, desacelerar e coletar fragmentos.', bonus: 'Mais chance de slow/freeze e fragmentos de gelo.', color: '#9be8ff', grandReward: { type: 'fragments', amount: 55 }, missions: [eventMission('frost', 'Fazer 35 Perfect Escapes', 'perfectEscapes', 35, { type: 'gems', amount: 22 }), eventMission('frost', 'Destruir 420 anéis', 'ringsDestroyed', 420, { type: 'fragments', amount: 30 }), eventMission('frost', 'Abrir 6 baús', 'chestsOpened', 6, { type: 'keys', amount: 1 })] },
  { id: 'cosmic', name: 'Evento Cósmico', description: 'Fragmentos raros e chances cósmicas.', bonus: 'Pequena chance extra de fragmentos raros.', color: '#b000ff', grandReward: { type: 'chest', chestType: 'epic', amount: 1 }, missions: [eventMission('cosmic', 'Vencer 5 fases', 'phaseWins', 5, { type: 'gems', amount: 28 }), eventMission('cosmic', 'Ganhar 12 diamantes', 'gemsEarned', 12, { type: 'fragments', amount: 45 }), eventMission('cosmic', 'Jogar 12 partidas', 'runsPlayed', 12, { type: 'profileXp', amount: 260 })] },
  { id: 'flame', name: 'Evento Flamejante', description: 'Dano explosivo e fragmentos de fogo.', bonus: 'Habilidades de fogo causam mais dano.', color: '#ff6b00', grandReward: { type: 'fragments', amount: 60 }, missions: [eventMission('flame', 'Fazer 40 críticos', 'criticals', 40, { type: 'coins', amount: 1200 }), eventMission('flame', 'Quebrar 35 anéis com efeito de skin', 'skinEffects', 35, { type: 'gems', amount: 20 }), eventMission('flame', 'Destruir 600 anéis', 'ringsDestroyed', 600, { type: 'keys', amount: 2 })] },
  { id: 'ghost', name: 'Evento Fantasma', description: 'Sombras, fases e Perfects.', bonus: 'Skins fantasma/sombra melhoradas e bônus em Perfect Escapes.', color: '#dff7ff', grandReward: { type: 'chest', chestType: 'rare', amount: 1 }, missions: [eventMission('ghost', 'Fazer 50 Perfect Escapes', 'perfectEscapes', 50, { type: 'gems', amount: 32 }), eventMission('ghost', 'Vencer 3 fases sem revive', 'noReviveWins', 3, { type: 'legendaryKeys', amount: 1 }), eventMission('ghost', 'Jogar 10 partidas', 'runsPlayed', 10, { type: 'profileXp', amount: 220 })] },
  { id: 'gold', name: 'Evento Dourado', description: 'Economia e ofertas simuladas.', bonus: '+15% moedas gerais no fim da partida.', color: '#ffd700', grandReward: { type: 'coins', amount: 2200 }, missions: [eventMission('gold', 'Ganhar 8.000 moedas da rodada', 'runCoins', 8000, { type: 'gems', amount: 25 }), eventMission('gold', 'Comprar 5 itens na loja', 'storePurchases', 5, { type: 'keys', amount: 2 }), eventMission('gold', 'Usar 4 anúncios simulados', 'adsWatched', 4, { type: 'coins', amount: 900 })] },
  { id: 'chests', name: 'Evento dos Baús', description: 'Chaves, baús e descontos simulados.', bonus: 'Chance maior de ganhar chaves.', color: '#00ff88', grandReward: { type: 'chest', chestType: 'epic', amount: 1 }, missions: [eventMission('chests', 'Abrir 10 baús', 'chestsOpened', 10, { type: 'keys', amount: 3 }), eventMission('chests', 'Coletar 6 chaves', 'storePurchases', 6, { type: 'gems', amount: 20 }), eventMission('chests', 'Destruir 450 anéis', 'ringsDestroyed', 450, { type: 'fragments', amount: 36 })] },
  { id: 'boss_rush', name: 'Evento Boss Rush', description: 'Duelos mais valiosos.', bonus: 'Recompensas melhores no Boss Mode.', color: '#ff0055', grandReward: { type: 'legendaryKeys', amount: 1 }, missions: [eventMission('boss_rush', 'Jogar 5 Boss Modes', 'bossRuns', 5, { type: 'coins', amount: 1400 }), eventMission('boss_rush', 'Vencer 3 Boss Modes', 'bossWins', 3, { type: 'chest', chestType: 'rare', amount: 1 }), eventMission('boss_rush', 'Fazer 25 críticos', 'criticals', 25, { type: 'gems', amount: 18 })] },
  { id: 'perfect', name: 'Evento Perfect', description: 'Aberturas precisas e diamantes.', bonus: '+chance de diamante em Perfect Escape.', color: '#ffffff', grandReward: { type: 'gems', amount: 45 }, missions: [eventMission('perfect', 'Fazer 60 Perfect Escapes', 'perfectEscapes', 60, { type: 'gems', amount: 35 }), eventMission('perfect', 'Fazer combo x20', 'bestCombo', 20, { type: 'keys', amount: 2 }), eventMission('perfect', 'Vencer 4 fases sem revive', 'noReviveWins', 4, { type: 'chest', chestType: 'rare', amount: 1 })] },
  { id: 'collector', name: 'Evento Colecionador', description: 'Fragmentos e coleção em foco.', bonus: 'Mais fragmentos em skins repetidas e bônus ao abrir baús.', color: '#ff4fd8', grandReward: { type: 'chest', chestType: 'epic', amount: 1 }, missions: [eventMission('collector', 'Abrir 12 baús', 'chestsOpened', 12, { type: 'fragments', amount: 70 }), eventMission('collector', 'Equipar 3 skins diferentes', 'skinEquips', 3, { type: 'gems', amount: 18 }), eventMission('collector', 'Ganhar 3 skins ou fragmentos', 'skinEffects', 3, { type: 'profileXp', amount: 260 })] },
];

export const WHEEL_REWARDS: RewardGrant[] = [
  { type: 'coins', amount: 180 },
  { type: 'coins', amount: 420 },
  { type: 'gems', amount: 6 },
  { type: 'gems', amount: 14 },
  { type: 'keys', amount: 1 },
  { type: 'chest', chestType: 'common', amount: 1 },
  { type: 'chest', chestType: 'rare', amount: 1 },
  { type: 'fragments', amount: 20 },
  { type: 'profileXp', amount: 120 },
  { type: 'chest', chestType: 'epic', amount: 1 },
];

const seededIndex = (seed: string, count: number) => {
  let hash = 0;
  for (let i = 0; i < seed.length; i += 1) hash = (hash * 31 + seed.charCodeAt(i)) >>> 0;
  return hash % count;
};

export const createDailyMissions = (date = new Date(), count = 4): DailyMissionSave => {
  const dayKey = getLocalDayKey(date);
  const start = seededIndex(dayKey, DAILY_MISSIONS.length);
  const missions = Array.from({ length: count }, (_, offset) => DAILY_MISSIONS[(start + offset * 7) % DAILY_MISSIONS.length])
    .map(definition => ({ id: definition.id, progress: 0, claimed: false }));
  return { dayKey, missions };
};

export const createWeeklyEvent = (date = new Date()): WeeklyEventSave => {
  const weekKey = getLocalWeekKey(date);
  const event = WEEKLY_EVENTS[getWeeklyEventIndex(WEEKLY_EVENTS.length, date)];
  return {
    weekKey,
    eventId: event.id,
    grandClaimed: false,
    missions: event.missions.map(definition => ({ id: definition.id, progress: 0, claimed: false })),
  };
};

export const getDailyMission = (id: string) => DAILY_MISSIONS.find(item => item.id === id);
export const getWeeklyEvent = (id: string) => WEEKLY_EVENTS.find(item => item.id === id) || WEEKLY_EVENTS[0];
export const getEventMission = (eventId: string, id: string) => getWeeklyEvent(eventId).missions.find(item => item.id === id);

export const createWheelSave = (date = new Date()): WheelSave => ({
  dayKey: getLocalDayKey(date),
  freeUsed: false,
  adSpinsUsed: 0,
});

export const createAdLimits = (date = new Date()): AdLimitSave => ({
  dayKey: getLocalDayKey(date),
  total: 0,
  byPlacement: {},
});

export const describeReward = (reward: RewardGrant) => {
  if (reward.type === 'coins') return `💰 ${reward.amount}`;
  if (reward.type === 'gems') return `💎 ${reward.amount}`;
  if (reward.type === 'keys') return `🔑 ${reward.amount}`;
  if (reward.type === 'legendaryKeys') return `🗝️ ${reward.amount}`;
  if (reward.type === 'profileXp') return `XP ${reward.amount}`;
  if (reward.type === 'fragments') return `🧩 ${reward.amount}`;
  return `🎁 Baú ${reward.chestType}`;
};

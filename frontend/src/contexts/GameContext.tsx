import React, { createContext, useContext, useEffect, useMemo, useRef, useState } from 'react';
import { storage } from '@/src/utils/storage';
import { ChestReward, RewardType } from '@/src/game/chests';
import { SKINS } from '@/src/game/skins';
import { UPGRADES } from '@/src/game/upgrades';
import { ACHIEVEMENTS, AchievementReward, AchievementState, BOSS_DIFFICULTY_RANK, getAchievementProgress } from '@/src/game/achievements';
import { ECONOMY_BALANCE, getGlobalCoinsFromRun } from '@/src/game/economy';
import { PERMANENT_UPGRADE_LIMITS } from '@/src/game/balance';
import {
  AdLimitSave,
  DailyMissionSave,
  MissionMetric,
  RewardGrant,
  WeeklyEventSave,
  WheelSave,
  DAILY_MISSIONS,
  WHEEL_REWARDS,
  createAdLimits,
  createDailyMissions,
  createWeeklyEvent,
  createWheelSave,
  getDailyMission,
  getEventMission,
  getWeeklyEvent,
} from '@/src/game/retention';
import { getLocalDayKey, getLocalWeekKey } from '@/src/utils/time';
import { applyAudioSettings, DEFAULT_AUDIO_SETTINGS, AudioSettings } from '@/src/utils/audio';
import { DEFAULT_LANGUAGE, LanguageCode, normalizeLanguage } from '@/src/i18n';
import {
  LeagueRival,
  LeagueSave,
  LeagueSeasonReward,
  CompetitionMap,
  calculateTrophyDelta,
  calculateRankingScore,
  compareDivision,
  createCompetitionMap,
  createLeagueRivals,
  defaultLeagueSave,
  findMatchmakingRival,
  getDayKey,
  getDivisionForScore,
  getDivisionMinScore,
  getDivisionReward,
  getFirstPlaceSkinForDivision,
  getPreviousDivision,
  getRankedLeague,
  getSeasonKey,
  getSeasonRewards,
  progressRivals,
  rewardToLabel,
} from '@/src/game/league';
import { BossLevelId, BossProgressSave, BOSS_LEVEL_RANK, createBossProgress, getMonthlyBoss, normalizeBossProgress } from '@/src/game/boss';

const SAVE_KEY = 'neon_escape_save_v2';

interface GameStats {
  baseDamage: number;
  baseSpeed: number;
  critChance: number;
  critMultiplier: number;
  coinMultiplier: number;
  xpMultiplier: number;
}

export interface InventoryItem {
  id: string;
  type: RewardType | 'chest';
  label: string;
  icon: string;
  rarity: string;
  amount: number;
}

interface SaveData {
  playerId: string;
  nickname: string;
  avatar: string;
  avatarImageUri?: string;
  favoriteSkin: string;
  coins: number;
  gems: number;
  keys: number;
  legendaryKeys: number;
  level: number;
  profileXp: number;
  currentPhase: number;
  unlockedPhases: number[];
  permanentUpgrades: Record<string, number>;
  unlockedUpgrades: string[];
  ballTransformation: string;
  unlockedSkins: string[];
  skinFragments: Record<string, number>;
  skinLevels: Record<string, number>;
  inventoryItems: InventoryItem[];
  achievements: Record<string, AchievementState>;
  lastAchievementUnlocked?: string;
  stats: GameStats;
  lifetimeStats: {
    runsPlayed: number;
    ringsDestroyed: number;
    perfectEscapes: number;
    diamondsFound: number;
    chestsOpened: number;
    skinsUnlocked: number;
    highestPhase: number;
    highestRunLevel: number;
    noReviveWins: number;
    bossRuns: number;
    bossWins: number;
    bossLosses: number;
    bossBestDifficulty: string;
    phaseWins: number;
    runCoins: number;
    runUpgrades: number;
    skinEquips: number;
    adsWatched: number;
    offlineClaims: number;
    storePurchases: number;
    criticals: number;
    skinEffects: number;
    bestCombo: number;
    dailyRewardsCollected: number;
    infiniteBestSeconds: number;
    infiniteBestRings: number;
    infiniteBestLevel: number;
    infiniteChallengeCompletions: number;
  };
  bossProgress: BossProgressSave;
  language: LanguageCode;
  settings: { sound: boolean; haptics: boolean } & AudioSettings;
  league: LeagueSave;
  dailyMissions: DailyMissionSave;
  weeklyEvent: WeeklyEventSave;
  wheel: WheelSave;
  adLimits: AdLimitSave;
  lastSeenAt: number;
  pendingOfflineReward?: { coins: number; hours: number; eventBonus?: string };
}

interface GameContextType extends SaveData {
  loading: boolean;
  initializePlayer: () => Promise<void>;
  updateCoins: (amount: number) => Promise<void>;
  updateGems: (amount: number) => Promise<void>;
  updateKeys: (amount: number) => Promise<void>;
  updateLegendaryKeys: (amount: number) => Promise<void>;
  addLevel: (amount: number) => Promise<void>;
  unlockPhase: (phaseId: number) => Promise<void>;
  purchaseUpgrade: (upgradeName: string, cost: number) => Promise<boolean>;
  setBallTransformation: (transformationId: string) => Promise<void>;
  grantChestReward: (reward: ChestReward) => Promise<void>;
  unlockSkin: (skinId: string) => Promise<void>;
  saveProgress: (patch?: Partial<SaveData>) => Promise<void>;
  updateProfile: (patch: Partial<Pick<SaveData, 'nickname' | 'avatar' | 'avatarImageUri' | 'favoriteSkin'>>) => Promise<void>;
  addProfileXp: (amount: number) => Promise<void>;
  collectAchievementReward: (achievementId: string) => Promise<boolean>;
  upgradeSkinLevel: (skinId: string) => Promise<boolean>;
  clearAchievementToast: () => Promise<void>;
  recordBossResult: (summary: {
    difficulty: string;
    levelId?: BossLevelId;
    monthlyBossId?: string;
    won: boolean;
    coins: number;
    profileXp: number;
    keys?: number;
    gems?: number;
    fragments?: { skinId: string; amount: number };
    chest?: { label: string; icon: string; rarity: string };
  }) => Promise<void>;
  recordRunRewards: (summary: {
    coins: number;
    profileXp: number;
    gems?: number;
    keys?: number;
    ringsDestroyed?: number;
    perfectEscapes?: number;
    phase?: number;
    runLevel?: number;
    won?: boolean;
    usedRevive?: boolean;
    bestCombo?: number;
    runUpgrades?: number;
    criticals?: number;
    skinEffects?: number;
    infiniteBestSeconds?: number;
    infiniteBestRings?: number;
    infiniteBestLevel?: number;
    infiniteChallengeCompletions?: number;
  }) => Promise<void>;
  grantReward: (reward: RewardGrant) => Promise<void>;
  collectDailyMission: (missionId: string) => Promise<boolean>;
  rerollDailyMission: (missionId: string) => Promise<boolean>;
  boostDailyMission: (missionId: string) => Promise<boolean>;
  collectEventMission: (missionId: string) => Promise<boolean>;
  collectEventGrandReward: () => Promise<boolean>;
  spinDailyWheel: (source: 'free' | 'ad') => Promise<RewardGrant | null>;
  recordAdUse: (placement: string, limit?: number) => Promise<boolean>;
  recordStorePurchase: () => Promise<void>;
  claimOfflineReward: (double?: boolean) => Promise<void>;
  refreshTimedSystems: () => Promise<void>;
  updateLanguage: (language: LanguageCode) => Promise<void>;
  updateAudioSettings: (patch: Partial<AudioSettings>) => Promise<void>;
  getLeaguePlayer: () => LeagueRival;
  getLeagueStandings: () => LeagueRival[];
  collectDivisionReward: (division: string) => Promise<boolean>;
  collectPendingSeasonReward: (equipSkin?: boolean) => Promise<boolean>;
  createLeagueMatch: () => { rival: LeagueRival; map: CompetitionMap };
  recordLeagueCompetitionResult: (summary: {
    rivalId: string;
    won: boolean;
    noRevive?: boolean;
    coins: number;
    profileXp: number;
    gems?: number;
    keys?: number;
    fragments?: { skinId: string; amount: number };
    chest?: { label: string; icon: string; rarity: string };
  }) => Promise<{ trophiesDelta: number; newPosition: number; rewards: RewardGrant[] }>;
}

const defaultStats: GameStats = {
  baseDamage: 10,
  baseSpeed: 100,
  critChance: 5,
  critMultiplier: 2,
  coinMultiplier: 1,
  xpMultiplier: 1,
};

const defaultAchievements = () =>
  ACHIEVEMENTS.reduce<Record<string, AchievementState>>((acc, item) => {
    acc[item.id] = { progress: 0, completed: false, claimed: false };
    return acc;
  }, {});

const defaultSave = (): SaveData => {
  const playerId = `player_${Date.now()}_${Math.random().toString(36).slice(2, 9)}`;
  return {
  playerId,
  nickname: 'Player',
  avatar: '🔵',
  avatarImageUri: undefined,
  favoriteSkin: 'neon_blue',
  coins: 600,
  gems: 60,
  keys: 1,
  legendaryKeys: 0,
  level: 1,
  profileXp: 0,
  currentPhase: 1,
  unlockedPhases: [1],
  permanentUpgrades: {},
  unlockedUpgrades: ['baseDamage', 'baseSpeed', 'coinMultiplier', 'critChance'],
  ballTransformation: 'neon_blue',
  unlockedSkins: ['neon_blue'],
  skinFragments: {},
  skinLevels: { neon_blue: 1 },
  inventoryItems: [],
  achievements: defaultAchievements(),
  stats: defaultStats,
  lifetimeStats: {
    runsPlayed: 0,
    ringsDestroyed: 0,
    perfectEscapes: 0,
    diamondsFound: 0,
    chestsOpened: 0,
    skinsUnlocked: 1,
    highestPhase: 1,
    highestRunLevel: 1,
    noReviveWins: 0,
    bossRuns: 0,
    bossWins: 0,
    bossLosses: 0,
    bossBestDifficulty: 'none',
    phaseWins: 0,
    runCoins: 0,
    runUpgrades: 0,
    skinEquips: 0,
    adsWatched: 0,
    offlineClaims: 0,
    storePurchases: 0,
    criticals: 0,
    skinEffects: 0,
    bestCombo: 0,
    dailyRewardsCollected: 0,
    infiniteBestSeconds: 0,
    infiniteBestRings: 0,
    infiniteBestLevel: 1,
    infiniteChallengeCompletions: 0,
  },
  bossProgress: createBossProgress(),
  language: DEFAULT_LANGUAGE,
  settings: { sound: true, haptics: true, ...DEFAULT_AUDIO_SETTINGS },
  league: defaultLeagueSave(playerId),
  dailyMissions: createDailyMissions(),
  weeklyEvent: createWeeklyEvent(),
  wheel: createWheelSave(),
  adLimits: createAdLimits(),
  lastSeenAt: Date.now(),
  };
};

const safeNumber = (value: unknown, fallback: number) =>
  typeof value === 'number' && Number.isFinite(value) ? value : fallback;

const safeString = (value: unknown, fallback: string) =>
  typeof value === 'string' && value.trim().length > 0 ? value : fallback;

const getSecretUpgradeIds = (save?: SaveData) => {
  if (!save) return [];
  const stats = save.lifetimeStats;
  const history = save.league?.history;
  return [
    stats.perfectEscapes >= 100 ? 'chronoBreak' : '',
    stats.ringsDestroyed >= 1000 ? 'voidPulse' : '',
    stats.diamondsFound >= 50 ? 'diamondInstinct' : '',
    stats.bestCombo >= 25 ? 'comboOverdrive' : '',
    stats.noReviveWins >= 10 ? 'lastShield' : '',
    (history?.top3Finishes || 0) >= 1 ? 'royalBreaker' : '',
    stats.bossWins >= 10 ? 'bossHunter' : '',
    (stats.dailyRewardsCollected || 0) >= 20 ? 'secretMagnet' : '',
    (history?.competitionWins || 0) >= 25 ? 'trophyInstinct' : '',
    (history?.bestWinStreak || 0) >= 10 ? 'rivalCrusher' : '',
  ].filter(Boolean);
};

const getUnlockedUpgradesForProfile = (profileLevel: number, phase: number, save?: SaveData) => {
  const ids = UPGRADES
    .filter(upgrade =>
      (!upgrade.secret && profileLevel >= upgrade.unlockLevel) ||
      (!upgrade.secret && phase >= 5 && upgrade.id === 'perfectChance') ||
      getSecretUpgradeIds(save).includes(upgrade.id)
    )
    .map(upgrade => upgrade.id);
  return Array.from(new Set(['damage', 'speed', 'coinBoost', 'critical', 'baseDamage', 'baseSpeed', 'coinMultiplier', 'critChance', ...ids]));
};

const getSourceFromSave = (save: SaveData) => {
  const ownedSkins = SKINS.filter(skin => save.unlockedSkins.includes(skin.id));
  return {
    runsPlayed: save.lifetimeStats.runsPlayed,
    ringsDestroyed: save.lifetimeStats.ringsDestroyed,
    perfectEscapes: save.lifetimeStats.perfectEscapes,
    diamondsFound: save.lifetimeStats.diamondsFound,
    chestsOpened: save.lifetimeStats.chestsOpened,
    skinsUnlocked: save.unlockedSkins.length,
    rareSkinsUnlocked: ownedSkins.filter(skin => skin.rarity === 'rare').length,
    epicSkinsUnlocked: ownedSkins.filter(skin => skin.rarity === 'epic').length,
    legendarySkinsUnlocked: ownedSkins.filter(skin => skin.rarity === 'legendary').length,
    highestPhase: save.lifetimeStats.highestPhase,
    noReviveWins: save.lifetimeStats.noReviveWins,
    bossRuns: save.lifetimeStats.bossRuns,
    bossWins: save.lifetimeStats.bossWins,
    bossBestDifficulty: BOSS_LEVEL_RANK[save.lifetimeStats.bossBestDifficulty] || BOSS_DIFFICULTY_RANK[save.lifetimeStats.bossBestDifficulty] || 0,
    bossImpossibleWins: save.bossProgress?.monthlyImpossibleWins || 0,
    bossImpossibleDays: save.bossProgress?.monthlyImpossibleDays?.length || 0,
    leagueTop10Finishes: save.league?.history?.top10Finishes || 0,
    leagueFirstPlaceFinishes: save.league?.history?.firstPlaceFinishes || 0,
    leagueUltimateFirstPlaceFinishes: save.league?.history?.ultimateFirstPlaceFinishes || 0,
    leagueInitialCrowns: save.league?.history?.initialFirstPlaceFinishes || 0,
    leagueCompetitionWins: save.league?.history?.competitionWins || 0,
    leagueCompetitionLosses: save.league?.history?.competitionLosses || 0,
    leagueBestWinStreak: save.league?.history?.bestWinStreak || 0,
    totalTrophiesGained: save.league?.history?.totalTrophiesGained || 0,
    leagueDiamondReached: compareDivision(save.league?.history?.bestDivision || 'Bronze', 'Diamante') >= 0 ? 1 : 0,
    leagueLegendaryReached: compareDivision(save.league?.history?.bestDivision || 'Bronze', 'Lendário') >= 0 ? 1 : 0,
    leagueUltimateReached: compareDivision(save.league?.history?.bestDivision || 'Bronze', 'Ultimate') >= 0 ? 1 : 0,
    infiniteBestSeconds: save.lifetimeStats.infiniteBestSeconds || 0,
    infiniteBestRings: save.lifetimeStats.infiniteBestRings || 0,
    infiniteBestLevel: save.lifetimeStats.infiniteBestLevel || 1,
    infiniteChallengeCompletions: save.lifetimeStats.infiniteChallengeCompletions || 0,
  };
};

const getInfiniteMilestoneSkins = (stats: SaveData['lifetimeStats']) => [
  stats.infiniteBestSeconds >= 60 ? 'infinite_pulse' : '',
  stats.infiniteBestRings >= 25 ? 'blue_vortex' : '',
  stats.infiniteBestSeconds >= 180 ? 'loop_flame' : '',
  stats.infiniteBestRings >= 50 ? 'red_comet' : '',
  stats.infiniteBestSeconds >= 300 ? 'neon_eclipse' : '',
  stats.infiniteBestRings >= 100 ? 'endless_prism' : '',
  stats.infiniteBestSeconds >= 600 ? 'cosmic_fragment' : '',
  stats.infiniteChallengeCompletions >= 5 ? 'eternal_core' : '',
  stats.infiniteBestSeconds >= 900 ? 'infinite_vortex_mythic' : '',
  stats.infiniteChallengeCompletions >= 10 ? 'chrono_loop_mythic' : '',
  stats.infiniteBestSeconds >= 1200 ? 'omega_infinity' : '',
  stats.infiniteBestRings >= 300 ? 'singularity_crown' : '',
].filter(Boolean);

const getCompletedAchievementCount = (save: SaveData) =>
  Object.values(save.achievements || {}).filter(item => item.completed).length;

const getPlayerRankingScore = (save: SaveData) =>
  calculateRankingScore({
    highestPhase: save.lifetimeStats.highestPhase,
    profileLevel: save.level,
    ringsDestroyed: save.lifetimeStats.ringsDestroyed,
    perfectEscapes: save.lifetimeStats.perfectEscapes,
    unlockedSkins: save.unlockedSkins.length,
    bossWins: save.lifetimeStats.bossWins,
    completedAchievements: getCompletedAchievementCount(save),
  });

const buildLeaguePlayer = (save: SaveData): LeagueRival => {
  const score = getPlayerRankingScore(save);
  const trophies = Math.max(0, save.league?.playerTrophies ?? Math.max(80, Math.floor(score / 850)));
  const division = save.league?.forcedDivision || getDivisionForScore(trophies);
  return {
    id: save.playerId,
    name: save.nickname || 'Player',
    avatar: save.avatar || '🔵',
    avatarImageUri: save.avatarImageUri,
    favoriteSkin: save.favoriteSkin || save.ballTransformation,
    level: save.level,
    trophies: Math.max(trophies, getDivisionMinScore(division)),
    score,
    secondaryScore: score,
    maxPhase: save.lifetimeStats.highestPhase,
    bossWins: save.lifetimeStats.bossWins,
    competitionWins: save.league?.history?.competitionWins || 0,
    competitionLosses: save.league?.history?.competitionLosses || 0,
    division,
    title: 'Você',
  };
};

const updateLeagueHistory = (save: SaveData): LeagueSave => {
  const fallback = defaultLeagueSave(save.playerId, getPlayerRankingScore(save));
  const league = save.league ? { ...save.league, history: { ...fallback.history, ...(save.league.history || {}) } } : fallback;
  const player = buildLeaguePlayer({ ...save, league });
  const standings = getRankedLeague(league.rivals, player);
  const position = standings.findIndex(item => item.id === save.playerId) + 1 || 201;
  const bestPosition = league.history.bestPosition ? Math.min(league.history.bestPosition, position) : position;
  const bestDivision = compareDivision(player.division, league.history.bestDivision || 'Bronze') > 0 ? player.division : league.history.bestDivision || 'Bronze';
  return { ...league, history: { ...league.history, bestPosition, bestDivision } };
};

const processLeagueSystems = (save: SaveData): SaveData => {
  const fallbackLeague = defaultLeagueSave(save.playerId, getPlayerRankingScore(save));
  let league = save.league ? { ...save.league, history: { ...fallbackLeague.history, ...(save.league.history || {}) } } : fallbackLeague;
  const currentPlayerTrophies = Math.max(0, league.playerTrophies ?? Math.floor(getPlayerRankingScore(save) / 850));
  if (!Array.isArray(league.rivals) || league.rivals.length < 190) {
    league = { ...league, playerTrophies: currentPlayerTrophies, rivals: createLeagueRivals(save.playerId, getPlayerRankingScore(save), getSeasonKey(), currentPlayerTrophies) };
  } else {
    league = {
      ...league,
      playerTrophies: currentPlayerTrophies,
      rivals: league.rivals.map((rival, index) => {
        const trophies = safeNumber((rival as any).trophies, Math.max(20, Math.floor((rival.score || 0) / 850)));
        return {
          ...rival,
          trophies,
          secondaryScore: safeNumber((rival as any).secondaryScore, rival.score || 0),
          competitionWins: safeNumber((rival as any).competitionWins, Math.floor(trophies / 18)),
          competitionLosses: safeNumber((rival as any).competitionLosses, Math.floor(trophies / 34)),
          maxPhase: Math.max(1, Math.min(50, safeNumber(rival.maxPhase, 1))),
          division: getDivisionForScore(trophies),
          favoriteSkin: rival.favoriteSkin || ['neon_blue', 'robot', 'fire', 'ice'][index % 4],
        };
      }),
    };
  }

  const todayKey = getDayKey();
  if (league.lastDailyProgressKey !== todayKey) {
    const last = new Date(`${league.lastDailyProgressKey || todayKey}T00:00:00`).getTime();
    const now = new Date(`${todayKey}T00:00:00`).getTime();
    const days = Math.max(1, Math.min(14, Math.floor((now - last) / 86400000)));
    league = { ...league, rivals: progressRivals(league.rivals, days, `${save.playerId}_${todayKey}`), lastDailyProgressKey: todayKey };
  }

  const currentSeason = getSeasonKey();
  if (league.seasonKey !== currentSeason && !league.pendingSeasonReward) {
    const player = buildLeaguePlayer({ ...save, league });
    const standings = getRankedLeague(league.rivals, player);
    const finalPosition = standings.findIndex(item => item.id === save.playerId) + 1 || 201;
    const finalDivision = player.division;
    const newDivision = getPreviousDivision(finalDivision);
    const skinId = finalPosition === 1
      ? finalDivision === 'Bronze' && !league.history.rankingSkinsObtained.includes('initial_neon_champion')
        ? 'initial_neon_champion'
        : getFirstPlaceSkinForDivision(finalDivision)
      : undefined;
    const firstInitialChampionUltimate = skinId === 'initial_neon_champion';
    const pendingSeasonReward: LeagueSeasonReward = {
      seasonKey: league.seasonKey,
      finalDivision,
      finalPosition,
      newDivision,
      rewards: getSeasonRewards(finalPosition, finalDivision),
      skinId,
      firstInitialChampionUltimate,
      claimed: false,
    };
    league = {
      ...league,
      seasonKey: currentSeason,
      lastDailyProgressKey: todayKey,
      rivals: createLeagueRivals(save.playerId, getPlayerRankingScore(save), currentSeason, getDivisionMinScore(newDivision)),
      pendingSeasonReward,
      forcedDivision: newDivision,
      playerTrophies: getDivisionMinScore(newDivision),
      history: {
        ...league.history,
        bestPosition: league.history.bestPosition ? Math.min(league.history.bestPosition, finalPosition) : finalPosition,
        bestDivision: compareDivision(finalDivision, league.history.bestDivision || 'Bronze') > 0 ? finalDivision : league.history.bestDivision || 'Bronze',
        seasonsPlayed: league.history.seasonsPlayed + 1,
        firstPlaceFinishes: league.history.firstPlaceFinishes + (finalPosition === 1 ? 1 : 0),
        top3Finishes: (league.history.top3Finishes || 0) + (finalPosition <= 3 ? 1 : 0),
        top10Finishes: (league.history.top10Finishes || 0) + (finalPosition <= 10 ? 1 : 0),
        ultimateFirstPlaceFinishes: (league.history.ultimateFirstPlaceFinishes || 0) + (finalPosition === 1 && finalDivision === 'Ultimate' ? 1 : 0),
        initialFirstPlaceFinishes: (league.history.initialFirstPlaceFinishes || 0) + (finalPosition === 1 && finalDivision === 'Bronze' ? 1 : 0),
        lastReward: getSeasonRewards(finalPosition, finalDivision).map(rewardToLabel).join(', '),
      },
    };
  }

  return { ...save, league: updateLeagueHistory({ ...save, league }) };
};

const syncAchievements = (save: SaveData): SaveData => {
  const source = getSourceFromSave(save);
  const current = { ...defaultAchievements(), ...(save.achievements || {}) };
  let lastAchievementUnlocked = save.lastAchievementUnlocked;

  ACHIEVEMENTS.forEach(definition => {
    const previous = current[definition.id] || { progress: 0, completed: false, claimed: false };
    const progress = Math.min(definition.required, getAchievementProgress(definition.id, source));
    const completed = progress >= definition.required;
    if (completed && !previous.completed) lastAchievementUnlocked = definition.name;
    current[definition.id] = { ...previous, progress, completed };
  });

  return { ...save, achievements: current, lastAchievementUnlocked };
};

const normalizeSave = (rawSave: Partial<SaveData> | null | undefined): SaveData => {
  const base = defaultSave();
  const parsed = rawSave || {};
  const currentPhase = safeNumber(parsed.currentPhase, base.currentPhase);
  const profileLevel = safeNumber(parsed.level, base.level);
  const unlockedSkins = Array.from(new Set(['neon_blue', ...((Array.isArray(parsed.unlockedSkins) ? parsed.unlockedSkins : []) as string[])]));
  const selectedSkin = unlockedSkins.includes(parsed.ballTransformation || '') ? parsed.ballTransformation || base.ballTransformation : base.ballTransformation;
  const lifetimeStats = {
    ...base.lifetimeStats,
    ...(parsed.lifetimeStats || {}),
    skinsUnlocked: unlockedSkins.length,
  };
  const dayKey = getLocalDayKey();
  const weekKey = getLocalWeekKey();
  const dailyMissions = parsed.dailyMissions?.dayKey === dayKey ? parsed.dailyMissions : createDailyMissions();
  const weeklyEvent = parsed.weeklyEvent?.weekKey === weekKey ? parsed.weeklyEvent : createWeeklyEvent();
  const wheel = parsed.wheel?.dayKey === dayKey ? parsed.wheel : createWheelSave();
  const adLimits = parsed.adLimits?.dayKey === dayKey ? parsed.adLimits : createAdLimits();

  const normalized = resetTimedSystemsIfNeeded(syncAchievements({
    ...base,
    ...parsed,
    playerId: safeString(parsed.playerId, base.playerId),
    nickname: safeString(parsed.nickname, base.nickname),
    avatar: safeString(parsed.avatar, base.avatar),
    avatarImageUri: typeof parsed.avatarImageUri === 'string' && parsed.avatarImageUri.length > 0 ? parsed.avatarImageUri : undefined,
    favoriteSkin: unlockedSkins.includes(parsed.favoriteSkin || '') ? parsed.favoriteSkin || selectedSkin : selectedSkin,
    coins: safeNumber(parsed.coins, base.coins),
    gems: safeNumber(parsed.gems, base.gems),
    keys: safeNumber(parsed.keys, base.keys),
    legendaryKeys: safeNumber(parsed.legendaryKeys, base.legendaryKeys),
    level: profileLevel,
    profileXp: safeNumber(parsed.profileXp, base.profileXp),
    currentPhase,
    unlockedPhases: Array.isArray(parsed.unlockedPhases) ? Array.from(new Set([1, ...parsed.unlockedPhases])).filter(id => id <= 50) : base.unlockedPhases,
    permanentUpgrades: parsed.permanentUpgrades || base.permanentUpgrades,
    ballTransformation: selectedSkin,
    unlockedSkins,
    skinFragments: parsed.skinFragments || base.skinFragments,
    skinLevels: { ...base.skinLevels, ...(parsed.skinLevels || {}) },
    inventoryItems: Array.isArray(parsed.inventoryItems) ? parsed.inventoryItems : base.inventoryItems,
    achievements: { ...defaultAchievements(), ...(parsed.achievements || {}) },
    stats: { ...defaultStats, ...(parsed.stats || {}) },
    lifetimeStats,
    bossProgress: normalizeBossProgress(parsed.bossProgress),
    language: normalizeLanguage(parsed.language),
    settings: { ...base.settings, ...(parsed.settings || {}) },
    league: parsed.league || defaultLeagueSave(safeString(parsed.playerId, base.playerId), 0),
    unlockedUpgrades: getUnlockedUpgradesForProfile(profileLevel, currentPhase),
    dailyMissions,
    weeklyEvent,
    wheel,
    adLimits,
    lastSeenAt: safeNumber(parsed.lastSeenAt, Date.now()),
    pendingOfflineReward: parsed.pendingOfflineReward,
  }));
  const processed = processLeagueSystems(normalized);
  return { ...processed, unlockedUpgrades: getUnlockedUpgradesForProfile(processed.level, processed.currentPhase, processed) };
};

export const getProfileXpNeeded = (level: number) => Math.floor(220 * Math.pow(level, 1.45));

const applyProfileXp = (save: SaveData, amount: number) => {
  let level = save.level;
  let profileXp = save.profileXp + Math.max(0, Math.floor(amount));

  while (profileXp >= getProfileXpNeeded(level)) {
    profileXp -= getProfileXpNeeded(level);
    level += 1;
  }

  return {
    ...save,
    level,
    profileXp,
    unlockedUpgrades: getUnlockedUpgradesForProfile(level, save.currentPhase, save),
  };
};

const addInventoryItem = (save: SaveData, item: InventoryItem) => {
  const existing = save.inventoryItems.find(entry => entry.id === item.id);
  if (existing) {
    return save.inventoryItems.map(entry => entry.id === item.id ? { ...entry, amount: entry.amount + item.amount } : entry);
  }
  return [...save.inventoryItems, item];
};

const applyReward = (save: SaveData, reward: AchievementReward): SaveData => {
  let next = { ...save };
  if (reward.type === 'coins') next.coins += reward.amount;
  if (reward.type === 'gems') next.gems += reward.amount;
  if (reward.type === 'keys') next.keys += reward.amount;
  if (reward.type === 'legendaryKeys') next.legendaryKeys += reward.amount;
  if (reward.type === 'profileXp') next = applyProfileXp(next, reward.amount);
  if (reward.type === 'fragments') {
    const skinId = reward.skinId || 'universal';
    next.skinFragments = { ...next.skinFragments, [skinId]: (next.skinFragments[skinId] || 0) + reward.amount };
  }
  if (reward.type === 'skin') {
    next.unlockedSkins = Array.from(new Set([...next.unlockedSkins, reward.skinId]));
    next.skinLevels = { ...next.skinLevels, [reward.skinId]: next.skinLevels[reward.skinId] || 1 };
    next.favoriteSkin = reward.skinId;
    next.ballTransformation = reward.skinId;
  }
  if (reward.type === 'chest') {
    const icon = reward.chestType === 'common' ? '📦' : reward.chestType === 'rare' ? '💼' : reward.chestType === 'epic' ? '🏆' : '💎';
    next.inventoryItems = addInventoryItem(next, { id: `chest_${reward.chestType}`, type: 'chest', label: `Baú ${reward.chestType}`, icon, rarity: reward.chestType, amount: reward.amount });
  }
  next.lifetimeStats = { ...next.lifetimeStats, skinsUnlocked: next.unlockedSkins.length };
  return next;
};

const applyGrant = (save: SaveData, reward: RewardGrant): SaveData => {
  let next = { ...save };
  if (reward.type === 'coins') next.coins += reward.amount;
  if (reward.type === 'gems') next.gems += reward.amount;
  if (reward.type === 'keys') next.keys += reward.amount;
  if (reward.type === 'legendaryKeys') next.legendaryKeys += reward.amount;
  if (reward.type === 'profileXp') next = applyProfileXp(next, reward.amount);
  if (reward.type === 'fragments') {
    const skinId = reward.skinId || next.ballTransformation || 'universal';
    next.skinFragments = { ...next.skinFragments, [skinId]: (next.skinFragments[skinId] || 0) + reward.amount };
  }
  if (reward.type === 'chest') {
    const icon = reward.chestType === 'common' ? '📦' : reward.chestType === 'rare' ? '💼' : reward.chestType === 'epic' ? '🏆' : '💎';
    next.inventoryItems = addInventoryItem(next, { id: `chest_${reward.chestType}`, type: 'chest', label: `Baú ${reward.chestType}`, icon, rarity: reward.chestType, amount: reward.amount });
  }
  return next;
};

const progressMissions = (missions: DailyMissionSave, metric: MissionMetric, amount: number) => ({
  ...missions,
  missions: missions.missions.map(mission => {
    const definition = getDailyMission(mission.id);
    if (!definition || definition.metric !== metric || mission.claimed) return mission;
    const nextProgress = metric === 'bestCombo' ? Math.max(mission.progress, amount) : mission.progress + amount;
    return { ...mission, progress: Math.min(definition.target, nextProgress) };
  }),
});

const progressEventMissions = (event: WeeklyEventSave, metric: MissionMetric, amount: number) => ({
  ...event,
  missions: event.missions.map(mission => {
    const definition = getEventMission(event.eventId, mission.id);
    if (!definition || definition.metric !== metric || mission.claimed) return mission;
    const nextProgress = metric === 'bestCombo' ? Math.max(mission.progress, amount) : mission.progress + amount;
    return { ...mission, progress: Math.min(definition.target, nextProgress) };
  }),
});

const progressMetric = (save: SaveData, metric: MissionMetric, amount: number) => ({
  ...save,
  dailyMissions: progressMissions(save.dailyMissions, metric, amount),
  weeklyEvent: progressEventMissions(save.weeklyEvent, metric, amount),
});

const resetTimedSystemsIfNeeded = (save: SaveData) => {
  const dayKey = getLocalDayKey();
  const weekKey = getLocalWeekKey();
  let next = { ...save };
  if (!next.dailyMissions?.dayKey || next.dailyMissions.dayKey !== dayKey) next.dailyMissions = createDailyMissions();
  if (!next.wheel?.dayKey || next.wheel.dayKey !== dayKey) next.wheel = createWheelSave();
  if (!next.adLimits?.dayKey || next.adLimits.dayKey !== dayKey) next.adLimits = createAdLimits();
  if (!next.weeklyEvent?.weekKey || next.weeklyEvent.weekKey !== weekKey || !getWeeklyEvent(next.weeklyEvent.eventId)) next.weeklyEvent = createWeeklyEvent();
  next.bossProgress = normalizeBossProgress(next.bossProgress);
  return next;
};

const GameContext = createContext<GameContextType | undefined>(undefined);

export const GameProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [save, setSave] = useState<SaveData>(defaultSave());
  const [loading, setLoading] = useState(true);
  const saveRef = useRef(save);

  useEffect(() => {
    initializePlayer();
  }, []);

  const persist = async (next: SaveData) => {
    const synced = processLeagueSystems(syncAchievements(resetTimedSystemsIfNeeded({ ...next, lastSeenAt: Date.now() })));
    saveRef.current = synced;
    setSave(synced);
    applyAudioSettings(synced.settings);
    await storage.setItem(SAVE_KEY, JSON.stringify(synced));
    await storage.setItem('playerId', synced.playerId);
  };

  const initializePlayer = async () => {
    try {
      setLoading(true);
      const raw = await storage.getItem(SAVE_KEY, '');
      if (raw) {
        const parsed = typeof raw === 'string' ? JSON.parse(raw) as Partial<SaveData> : raw as Partial<SaveData>;
        const normalized = normalizeSave(parsed);
        const elapsedMs = Math.max(0, Date.now() - safeNumber(normalized.lastSeenAt, Date.now()));
        const hours = Math.min(ECONOMY_BALANCE.offlineMaxHours, elapsedMs / (60 * 60 * 1000));
        const coins = Math.floor(hours * (ECONOMY_BALANCE.offlineCoinsPerHourBase + normalized.level * 6 + normalized.lifetimeStats.highestPhase * 4));
        await persist({
          ...normalized,
          pendingOfflineReward: coins >= 25 ? { coins, hours: Number(hours.toFixed(1)), eventBonus: normalized.weeklyEvent.eventId === 'gold' ? 'Evento Dourado' : undefined } : normalized.pendingOfflineReward,
        });
      } else {
        await persist(defaultSave());
      }
    } catch (error) {
      console.error('Error loading local save:', error);
      await persist(defaultSave());
    } finally {
      setLoading(false);
    }
  };

  const saveProgress = async (patch: Partial<SaveData> = {}) => {
    await persist({ ...saveRef.current, ...patch });
  };

  const updateCoins = async (amount: number) => {
    const current = saveRef.current;
    await persist({ ...current, coins: Math.max(0, current.coins + amount) });
  };

  const updateGems = async (amount: number) => {
    const current = saveRef.current;
    await persist({ ...current, gems: Math.max(0, current.gems + amount) });
  };

  const updateKeys = async (amount: number) => {
    const current = saveRef.current;
    await persist({ ...current, keys: Math.max(0, current.keys + amount) });
  };

  const updateLegendaryKeys = async (amount: number) => {
    const current = saveRef.current;
    await persist({ ...current, legendaryKeys: Math.max(0, current.legendaryKeys + amount) });
  };

  const addLevel = async (amount: number) => {
    const current = saveRef.current;
    const nextLevel = Math.max(1, current.level + amount);
    await persist({ ...current, level: nextLevel, unlockedUpgrades: getUnlockedUpgradesForProfile(nextLevel, current.currentPhase, current) });
  };

  const addProfileXp = async (amount: number) => {
    await persist(applyProfileXp(saveRef.current, amount));
  };

  const unlockPhase = async (phaseId: number) => {
    const current = saveRef.current;
    if (current.unlockedPhases.includes(phaseId) || phaseId > 50) return;
    await persist({
      ...current,
      currentPhase: Math.max(current.currentPhase, phaseId),
      unlockedPhases: [...current.unlockedPhases, phaseId],
      unlockedUpgrades: getUnlockedUpgradesForProfile(current.level, Math.max(current.currentPhase, phaseId), current),
    });
  };

  const purchaseUpgrade = async (upgradeName: string, cost: number): Promise<boolean> => {
    const current = saveRef.current;
    if (!current.unlockedUpgrades.includes(upgradeName) || current.coins < cost) return false;
    const nextLevel = (current.permanentUpgrades[upgradeName] || 0) + 1;
    const maxLevel = PERMANENT_UPGRADE_LIMITS[upgradeName] ?? 10;
    if (nextLevel > maxLevel) return false;
    const nextStats = { ...current.stats };

    switch (upgradeName) {
      case 'baseDamage':
        nextStats.baseDamage = 10 * Math.pow(1.1, nextLevel);
        break;
      case 'baseSpeed':
        nextStats.baseSpeed = 100 * Math.pow(1.08, nextLevel);
        break;
      case 'critChance':
        nextStats.critChance = 5 + nextLevel * 2;
        break;
      case 'coinMultiplier':
        nextStats.coinMultiplier = 1 + nextLevel * 0.15;
        break;
      case 'xpBoost':
        nextStats.xpMultiplier = 1 + nextLevel * 0.2;
        break;
      case 'slowRings':
        nextStats.baseSpeed = Math.max(70, nextStats.baseSpeed * (1 - Math.min(0.35, nextLevel * 0.015)));
        break;
    }

    await persist({
      ...current,
      coins: current.coins - cost,
      permanentUpgrades: { ...current.permanentUpgrades, [upgradeName]: nextLevel },
      stats: nextStats,
    });
    return true;
  };

  const setBallTransformation = async (transformationId: string) => {
    const current = saveRef.current;
    if (!current.unlockedSkins.includes(transformationId)) return;
    await persist(progressMetric({
      ...current,
      ballTransformation: transformationId,
      lifetimeStats: { ...current.lifetimeStats, skinEquips: current.lifetimeStats.skinEquips + (current.ballTransformation === transformationId ? 0 : 1) },
    }, 'skinEquips', current.ballTransformation === transformationId ? 0 : 1));
  };

  const updateProfile = async (patch: Partial<Pick<SaveData, 'nickname' | 'avatar' | 'avatarImageUri' | 'favoriteSkin'>>) => {
    const current = saveRef.current;
    const favoriteSkin = patch.favoriteSkin && current.unlockedSkins.includes(patch.favoriteSkin) ? patch.favoriteSkin : current.favoriteSkin;
    await persist({ ...current, ...patch, favoriteSkin });
  };

  const unlockSkin = async (skinId: string) => {
    const current = saveRef.current;
    const skin = SKINS.find(item => item.id === skinId);
    if (!skin || current.unlockedSkins.includes(skinId)) return;
    await persist({
      ...current,
      unlockedSkins: [...current.unlockedSkins, skinId],
      skinLevels: { ...current.skinLevels, [skinId]: 1 },
      lifetimeStats: { ...current.lifetimeStats, skinsUnlocked: current.unlockedSkins.length + 1 },
    });
  };

  const grantChestReward = async (reward: ChestReward) => {
    let next = { ...saveRef.current };
    next.lifetimeStats = { ...next.lifetimeStats, chestsOpened: next.lifetimeStats.chestsOpened + 1 };

    if (reward.type === 'skin' && reward.skinId) {
      const hadSkin = next.unlockedSkins.includes(reward.skinId);
      next.unlockedSkins = Array.from(new Set([...next.unlockedSkins, reward.skinId]));
      next.ballTransformation = reward.skinId;
      next.favoriteSkin = reward.skinId;
      next.skinLevels = { ...next.skinLevels, [reward.skinId]: next.skinLevels[reward.skinId] || 1 };
      if (!hadSkin) next.lifetimeStats = { ...next.lifetimeStats, skinsUnlocked: next.unlockedSkins.length };
    } else if (reward.type === 'fragments' && reward.skinId) {
      next.skinFragments = {
        ...next.skinFragments,
        [reward.skinId]: (next.skinFragments[reward.skinId] || 0) + (reward.amount || 0),
      };
    } else if (reward.type === 'key') {
      if (reward.rarity === 'mythic' || reward.rarity === 'legendary' || reward.rarity === 'ultimate') next.legendaryKeys += reward.amount || 1;
      else next.keys += reward.amount || 1;
    } else if (reward.type === 'gems') {
      next.gems += reward.amount || 0;
    } else if (reward.type === 'coins') {
      next.coins += reward.amount || 0;
    } else {
      next.inventoryItems = addInventoryItem(next, {
        id: `${reward.type}_${reward.label}`,
        type: reward.type,
        label: reward.label,
        icon: reward.icon,
        rarity: reward.rarity,
        amount: reward.amount || 1,
      });
    }

    next = progressMetric(next, 'chestsOpened', 1);
    await persist(next);
  };

  const collectAchievementReward = async (achievementId: string) => {
    const current = saveRef.current;
    const achievement = ACHIEVEMENTS.find(item => item.id === achievementId);
    const state = current.achievements[achievementId];
    if (!achievement || !state?.completed || state.claimed) return false;
    const next = applyReward(current, achievement.reward);
    next.achievements = {
      ...next.achievements,
      [achievementId]: { ...state, claimed: true },
    };
    await persist(next);
    return true;
  };

  const upgradeSkinLevel = async (skinId: string) => {
    const current = saveRef.current;
    const skin = SKINS.find(item => item.id === skinId);
    const level = current.skinLevels[skinId] || 1;
    if (!skin || !current.unlockedSkins.includes(skinId) || level >= 5) return false;
    const cost = skin.fragmentsRequired;
    const fragments = current.skinFragments[skinId] || 0;
    if (fragments < cost) return false;
    await persist({
      ...current,
      skinFragments: { ...current.skinFragments, [skinId]: fragments - cost },
      skinLevels: { ...current.skinLevels, [skinId]: level + 1 },
    });
    return true;
  };

  const clearAchievementToast = async () => {
    await persist({ ...saveRef.current, lastAchievementUnlocked: undefined });
  };

  const recordRunRewards = async (summary: {
    coins: number;
    profileXp: number;
    gems?: number;
    keys?: number;
    ringsDestroyed?: number;
    perfectEscapes?: number;
    phase?: number;
    runLevel?: number;
    won?: boolean;
    usedRevive?: boolean;
    bestCombo?: number;
    runUpgrades?: number;
    criticals?: number;
    skinEffects?: number;
    infiniteBestSeconds?: number;
    infiniteBestRings?: number;
    infiniteBestLevel?: number;
    infiniteChallengeCompletions?: number;
  }) => {
    const current = saveRef.current;
    const withXp = applyProfileXp(current, summary.profileXp);
    const wonPhase = summary.won ? summary.phase || 1 : 1;
    const globalCoins = getGlobalCoinsFromRun(Math.max(0, Math.floor(summary.coins)), summary.bestCombo || 0, !!summary.won);
    let next: SaveData = {
      ...withXp,
      coins: withXp.coins + globalCoins,
      gems: withXp.gems + Math.max(0, Math.floor(summary.gems || 0)),
      keys: withXp.keys + Math.max(0, Math.floor(summary.keys || 0)),
      currentPhase: Math.max(withXp.currentPhase, summary.phase || withXp.currentPhase),
      lifetimeStats: {
        ...withXp.lifetimeStats,
        runsPlayed: withXp.lifetimeStats.runsPlayed + 1,
        ringsDestroyed: withXp.lifetimeStats.ringsDestroyed + Math.max(0, summary.ringsDestroyed || 0),
        perfectEscapes: withXp.lifetimeStats.perfectEscapes + Math.max(0, summary.perfectEscapes || 0),
        diamondsFound: withXp.lifetimeStats.diamondsFound + Math.max(0, summary.gems || 0),
        skinsUnlocked: withXp.unlockedSkins.length,
        highestPhase: Math.max(withXp.lifetimeStats.highestPhase, wonPhase),
        highestRunLevel: Math.max(withXp.lifetimeStats.highestRunLevel, summary.runLevel || 1),
        noReviveWins: withXp.lifetimeStats.noReviveWins + (summary.won && !summary.usedRevive ? 1 : 0),
        phaseWins: withXp.lifetimeStats.phaseWins + (summary.won ? 1 : 0),
        runCoins: withXp.lifetimeStats.runCoins + Math.max(0, Math.floor(summary.coins)),
        runUpgrades: withXp.lifetimeStats.runUpgrades + Math.max(0, summary.runUpgrades || 0),
        criticals: withXp.lifetimeStats.criticals + Math.max(0, summary.criticals || 0),
        skinEffects: withXp.lifetimeStats.skinEffects + Math.max(0, summary.skinEffects || 0),
        bestCombo: Math.max(withXp.lifetimeStats.bestCombo, summary.bestCombo || 0),
        infiniteBestSeconds: Math.max(withXp.lifetimeStats.infiniteBestSeconds || 0, summary.infiniteBestSeconds || 0),
        infiniteBestRings: Math.max(withXp.lifetimeStats.infiniteBestRings || 0, summary.infiniteBestRings || 0),
        infiniteBestLevel: Math.max(withXp.lifetimeStats.infiniteBestLevel || 1, summary.infiniteBestLevel || summary.runLevel || 1),
        infiniteChallengeCompletions: (withXp.lifetimeStats.infiniteChallengeCompletions || 0) + Math.max(0, summary.infiniteChallengeCompletions || 0),
      },
    };
    const milestoneSkins = getInfiniteMilestoneSkins(next.lifetimeStats);
    if (milestoneSkins.length) {
      next.unlockedSkins = Array.from(new Set([...next.unlockedSkins, ...milestoneSkins]));
      next.skinLevels = milestoneSkins.reduce((levels, skinId) => ({ ...levels, [skinId]: levels[skinId] || 1 }), next.skinLevels);
      next.lifetimeStats = { ...next.lifetimeStats, skinsUnlocked: next.unlockedSkins.length };
    }
    const metrics: [MissionMetric, number][] = [
      ['runsPlayed', 1],
      ['ringsDestroyed', Math.max(0, summary.ringsDestroyed || 0)],
      ['perfectEscapes', Math.max(0, summary.perfectEscapes || 0)],
      ['runCoins', Math.max(0, Math.floor(summary.coins))],
      ['gemsEarned', Math.max(0, Math.floor(summary.gems || 0))],
      ['phaseWins', summary.won ? 1 : 0],
      ['noReviveWins', summary.won && !summary.usedRevive ? 1 : 0],
      ['runUpgrades', Math.max(0, summary.runUpgrades || 0)],
      ['criticals', Math.max(0, summary.criticals || 0)],
      ['skinEffects', Math.max(0, summary.skinEffects || 0)],
      ['bestCombo', Math.max(0, summary.bestCombo || 0)],
    ];
    metrics.forEach(([metric, amount]) => {
      if (amount > 0) next = progressMetric(next, metric, amount);
    });
    next = { ...next, unlockedUpgrades: getUnlockedUpgradesForProfile(next.level, next.currentPhase, next) };
    await persist(next);
  };

  const recordBossResult = async (summary: {
    difficulty: string;
    levelId?: BossLevelId;
    monthlyBossId?: string;
    won: boolean;
    coins: number;
    profileXp: number;
    keys?: number;
    gems?: number;
    fragments?: { skinId: string; amount: number };
    chest?: { label: string; icon: string; rarity: string };
  }) => {
    const current = { ...saveRef.current, bossProgress: normalizeBossProgress(saveRef.current.bossProgress) };
    const withXp = applyProfileXp(current, summary.profileXp);
    const levelId = summary.levelId || (summary.difficulty as BossLevelId);
    const currentRank = BOSS_LEVEL_RANK[withXp.lifetimeStats.bossBestDifficulty] || BOSS_DIFFICULTY_RANK[withXp.lifetimeStats.bossBestDifficulty] || 0;
    const nextRank = BOSS_LEVEL_RANK[levelId] || BOSS_LEVEL_RANK[summary.difficulty] || BOSS_DIFFICULTY_RANK[summary.difficulty] || 0;
    const monthlyBoss = getMonthlyBoss();
    let bossProgress = normalizeBossProgress(withXp.bossProgress);
    const rewardAlreadyClaimed = bossProgress.dailyRewardsClaimed.includes(levelId);
    if (summary.won && !bossProgress.dailyLevelWins.includes(levelId)) {
      bossProgress = { ...bossProgress, dailyLevelWins: [...bossProgress.dailyLevelWins, levelId] };
    }
    if (summary.won && !rewardAlreadyClaimed) {
      bossProgress = { ...bossProgress, dailyRewardsClaimed: [...bossProgress.dailyRewardsClaimed, levelId] };
    }
    if (summary.won) {
      const bestRank = BOSS_LEVEL_RANK[bossProgress.monthlyBestLevelWon] || 0;
      const nextBest = nextRank > bestRank ? levelId : bossProgress.monthlyBestLevelWon;
      bossProgress = {
        ...bossProgress,
        bossId: summary.monthlyBossId || monthlyBoss.id,
        monthlyBestLevelWon: nextBest,
        monthlyTotalWins: bossProgress.monthlyTotalWins + 1,
        monthlyImpossibleWins: bossProgress.monthlyImpossibleWins + (levelId === 'impossivel' ? 1 : 0),
        monthlyImpossibleDays: levelId === 'impossivel' ? Array.from(new Set([...bossProgress.monthlyImpossibleDays, bossProgress.dayKey])) : bossProgress.monthlyImpossibleDays,
      };
    }
    let next: SaveData = {
      ...withXp,
      coins: withXp.coins + summary.coins,
      gems: withXp.gems + Math.max(0, summary.gems || 0),
      keys: withXp.keys + Math.max(0, summary.keys || 0),
      lifetimeStats: {
        ...withXp.lifetimeStats,
        bossRuns: withXp.lifetimeStats.bossRuns + 1,
        bossWins: withXp.lifetimeStats.bossWins + (summary.won ? 1 : 0),
        bossLosses: withXp.lifetimeStats.bossLosses + (summary.won ? 0 : 1),
        bossBestDifficulty: summary.won && nextRank > currentRank ? levelId : withXp.lifetimeStats.bossBestDifficulty,
      },
      bossProgress,
    };

    if (summary.fragments) {
      next.skinFragments = {
        ...next.skinFragments,
        [summary.fragments.skinId]: (next.skinFragments[summary.fragments.skinId] || 0) + summary.fragments.amount,
      };
    }
    if (summary.chest) {
      next.inventoryItems = addInventoryItem(next, { id: `boss_chest_${summary.chest.rarity}`, type: 'chest', label: summary.chest.label, icon: summary.chest.icon, rarity: summary.chest.rarity, amount: 1 });
    }
    next = progressMetric(next, 'bossRuns', 1);
    if (summary.won) next = progressMetric(next, 'bossWins', 1);
    next = { ...next, unlockedUpgrades: getUnlockedUpgradesForProfile(next.level, next.currentPhase, next) };
    await persist(next);
  };

  const grantReward = async (reward: RewardGrant) => {
    await persist(applyGrant(saveRef.current, reward));
  };

  const recordAdUse = async (placement: string, limit = ECONOMY_BALANCE.adDailyLimit) => {
    const current = resetTimedSystemsIfNeeded(saveRef.current);
    const placementCount = current.adLimits.byPlacement[placement] || 0;
    if (current.adLimits.total >= limit || placementCount >= 2) return false;
    let next: SaveData = {
      ...current,
      adLimits: {
        ...current.adLimits,
        total: current.adLimits.total + 1,
        byPlacement: { ...current.adLimits.byPlacement, [placement]: placementCount + 1 },
      },
      lifetimeStats: { ...current.lifetimeStats, adsWatched: current.lifetimeStats.adsWatched + 1 },
    };
    next = progressMetric(next, 'adsWatched', 1);
    await persist(next);
    return true;
  };

  const collectDailyMission = async (missionId: string) => {
    const current = resetTimedSystemsIfNeeded(saveRef.current);
    const mission = current.dailyMissions.missions.find(item => item.id === missionId);
    const definition = getDailyMission(missionId);
    if (!mission || !definition || mission.claimed || mission.progress < definition.target) return false;
    const rewarded = applyGrant(current, definition.reward);
    await persist({
      ...rewarded,
      dailyMissions: {
        ...rewarded.dailyMissions,
        missions: rewarded.dailyMissions.missions.map(item => item.id === missionId ? { ...item, claimed: true } : item),
      },
    });
    return true;
  };

  const rerollDailyMission = async (missionId: string) => {
    const adOk = await recordAdUse(`daily_reroll_${missionId}`);
    if (!adOk) return false;
    const current = resetTimedSystemsIfNeeded(saveRef.current);
    const activeIds = new Set(current.dailyMissions.missions.map(item => item.id));
    const replacement = DAILY_MISSIONS.find(item => !activeIds.has(item.id)) || DAILY_MISSIONS[0];
    await persist({
      ...current,
      dailyMissions: {
        ...current.dailyMissions,
        missions: current.dailyMissions.missions.map(item => item.id === missionId ? { id: replacement.id, progress: 0, claimed: false, rerolled: true } : item),
      },
    });
    return true;
  };

  const boostDailyMission = async (missionId: string) => {
    const adOk = await recordAdUse(`daily_boost_${missionId}`);
    if (!adOk) return false;
    const current = resetTimedSystemsIfNeeded(saveRef.current);
    const definition = getDailyMission(missionId);
    if (!definition) return false;
    await persist({
      ...current,
      dailyMissions: {
        ...current.dailyMissions,
        missions: current.dailyMissions.missions.map(item => {
          if (item.id !== missionId || item.boosted || item.claimed) return item;
          return { ...item, boosted: true, progress: Math.min(definition.target, item.progress + Math.max(1, Math.ceil(definition.target * 0.25))) };
        }),
      },
    });
    return true;
  };

  const collectEventMission = async (missionId: string) => {
    const current = resetTimedSystemsIfNeeded(saveRef.current);
    const mission = current.weeklyEvent.missions.find(item => item.id === missionId);
    const definition = getEventMission(current.weeklyEvent.eventId, missionId);
    if (!mission || !definition || mission.claimed || mission.progress < definition.target) return false;
    const rewarded = applyGrant(current, definition.reward);
    await persist({
      ...rewarded,
      weeklyEvent: {
        ...rewarded.weeklyEvent,
        missions: rewarded.weeklyEvent.missions.map(item => item.id === missionId ? { ...item, claimed: true } : item),
      },
    });
    return true;
  };

  const collectEventGrandReward = async () => {
    const current = resetTimedSystemsIfNeeded(saveRef.current);
    if (current.weeklyEvent.grandClaimed || current.weeklyEvent.missions.some(item => !item.claimed)) return false;
    const event = getWeeklyEvent(current.weeklyEvent.eventId);
    const rewarded = applyGrant(current, event.grandReward);
    await persist({ ...rewarded, weeklyEvent: { ...rewarded.weeklyEvent, grandClaimed: true } });
    return true;
  };

  const spinDailyWheel = async (source: 'free' | 'ad') => {
    let current = resetTimedSystemsIfNeeded(saveRef.current);
    if (source === 'free' && current.wheel.freeUsed) return null;
    if (source === 'ad') {
      if (current.wheel.adSpinsUsed >= 2) return null;
      const adOk = await recordAdUse('wheel_extra');
      if (!adOk) return null;
      current = resetTimedSystemsIfNeeded(saveRef.current);
    }
    const reward = WHEEL_REWARDS[Math.floor(Math.random() * WHEEL_REWARDS.length)];
    const rewarded = applyGrant(current, reward);
    await persist({
      ...rewarded,
      lifetimeStats: {
        ...rewarded.lifetimeStats,
        dailyRewardsCollected: (rewarded.lifetimeStats.dailyRewardsCollected || 0) + 1,
      },
      wheel: {
        ...rewarded.wheel,
        freeUsed: source === 'free' ? true : rewarded.wheel.freeUsed,
        adSpinsUsed: source === 'ad' ? rewarded.wheel.adSpinsUsed + 1 : rewarded.wheel.adSpinsUsed,
      },
    });
    return reward;
  };

  const recordStorePurchase = async () => {
    const current = saveRef.current;
    await persist(progressMetric({
      ...current,
      lifetimeStats: { ...current.lifetimeStats, storePurchases: current.lifetimeStats.storePurchases + 1 },
    }, 'storePurchases', 1));
  };

  const claimOfflineReward = async (double = false) => {
    const current = saveRef.current;
    if (!current.pendingOfflineReward) return;
    const coins = current.pendingOfflineReward.coins * (double ? 2 : 1);
    let next: SaveData = {
      ...current,
      coins: current.coins + coins,
      pendingOfflineReward: undefined,
      lifetimeStats: { ...current.lifetimeStats, offlineClaims: current.lifetimeStats.offlineClaims + 1 },
    };
    next = progressMetric(next, 'offlineClaims', 1);
    await persist(next);
  };

  const refreshTimedSystems = async () => {
    await persist(resetTimedSystemsIfNeeded(saveRef.current));
  };

  const updateLanguage = async (language: LanguageCode) => {
    await persist({ ...saveRef.current, language: normalizeLanguage(language) });
  };

  const updateAudioSettings = async (patch: Partial<AudioSettings>) => {
    const current = saveRef.current;
    const settings = { ...current.settings, ...patch };
    settings.sound = !settings.masterMuted && !settings.sfxMuted;
    applyAudioSettings(settings);
    await persist({ ...current, settings });
  };

  const createLeagueMatch = () => {
    const current = saveRef.current;
    const player = buildLeaguePlayer(current);
    const rival = findMatchmakingRival(current.league.rivals, player, `${current.playerId}_${Date.now()}_${current.league.history.competitionWins}`);
    const map = createCompetitionMap(`${current.playerId}_${rival.id}_${Date.now()}`, player.trophies);
    return { rival, map };
  };

  const recordLeagueCompetitionResult = async (summary: {
    rivalId: string;
    won: boolean;
    noRevive?: boolean;
    coins: number;
    profileXp: number;
    gems?: number;
    keys?: number;
    fragments?: { skinId: string; amount: number };
    chest?: { label: string; icon: string; rarity: string };
  }) => {
    const current = saveRef.current;
    const player = buildLeaguePlayer(current);
    const rival = current.league.rivals.find(item => item.id === summary.rivalId) || current.league.rivals[0] || player;
    const secretBonus = current.unlockedUpgrades.includes('trophyInstinct') && summary.won ? 2 : 0;
    const nextStreak = summary.won ? (current.league.history.currentWinStreak || 0) + 1 : 0;
    const trophiesDelta = calculateTrophyDelta(player, rival, summary.won, nextStreak, summary.noRevive !== false, secretBonus);
    const newTrophies = Math.max(0, player.trophies + trophiesDelta);
    const rewards: RewardGrant[] = [
      { type: 'coins', amount: Math.max(20, Math.floor(summary.coins)) },
      { type: 'profileXp', amount: Math.max(10, Math.floor(summary.profileXp)) },
    ];
    if (summary.gems) rewards.push({ type: 'gems', amount: summary.gems });
    if (summary.keys) rewards.push({ type: 'keys', amount: summary.keys });
    if (summary.fragments) rewards.push({ type: 'fragments', skinId: summary.fragments.skinId, amount: summary.fragments.amount });
    if (summary.chest) rewards.push({ type: 'chest', chestType: summary.chest.rarity as any, amount: 1 });

    let next: SaveData = {
      ...current,
      league: {
        ...current.league,
        forcedDivision: undefined,
        playerTrophies: newTrophies,
        history: {
          ...current.league.history,
          competitionWins: (current.league.history.competitionWins || 0) + (summary.won ? 1 : 0),
          competitionLosses: (current.league.history.competitionLosses || 0) + (summary.won ? 0 : 1),
          currentWinStreak: nextStreak,
          bestWinStreak: Math.max(current.league.history.bestWinStreak || 0, nextStreak),
          totalTrophiesGained: (current.league.history.totalTrophiesGained || 0) + Math.max(0, trophiesDelta),
        },
      },
    };
    rewards.forEach(reward => {
      next = applyGrant(next, reward);
    });
    next = syncAchievements(processLeagueSystems(next));
    const newPosition = getRankedLeague(next.league.rivals, buildLeaguePlayer(next)).findIndex(item => item.id === next.playerId) + 1 || 201;
    await persist(next);
    return { trophiesDelta, newPosition, rewards };
  };

  const getLeaguePlayer = () => buildLeaguePlayer(saveRef.current);

  const getLeagueStandings = () => {
    const current = saveRef.current;
    return getRankedLeague(current.league.rivals, buildLeaguePlayer(current));
  };

  const collectDivisionReward = async (division: string) => {
    const current = saveRef.current;
    const player = buildLeaguePlayer(current);
    if (compareDivision(player.division, division as any) < 0) return false;
    if (current.league.claimedDivisionRewards.includes(division as any)) return false;
    const rewards = getDivisionReward(division as any);
    let next = { ...current, league: { ...current.league, claimedDivisionRewards: [...current.league.claimedDivisionRewards, division as any] } };
    rewards.forEach(reward => {
      next = applyGrant(next, reward);
    });
    await persist(next);
    return true;
  };

  const collectPendingSeasonReward = async (equipSkin = false) => {
    const current = saveRef.current;
    const pending = current.league.pendingSeasonReward;
    if (!pending || pending.claimed) return false;
    let next = { ...current };
    pending.rewards.forEach(reward => {
      next = applyGrant(next, reward);
    });
    if (pending.skinId && !next.unlockedSkins.includes(pending.skinId)) {
      next.unlockedSkins = [...next.unlockedSkins, pending.skinId];
      next.skinLevels = { ...next.skinLevels, [pending.skinId]: 1 };
      next.lifetimeStats = { ...next.lifetimeStats, skinsUnlocked: next.unlockedSkins.length };
      next.league.history.rankingSkinsObtained = Array.from(new Set([...next.league.history.rankingSkinsObtained, pending.skinId]));
      if (equipSkin) {
        next.ballTransformation = pending.skinId;
        next.favoriteSkin = pending.skinId;
      }
    }
    next.league = {
      ...next.league,
      pendingSeasonReward: undefined,
      history: {
        ...next.league.history,
        lastReward: [...pending.rewards.map(rewardToLabel), pending.skinId ? `Skin ${pending.skinId}` : ''].filter(Boolean).join(', '),
      },
    };
    await persist(next);
    return true;
  };

  const value = useMemo<GameContextType>(() => ({
    ...save,
    loading,
    initializePlayer,
    updateCoins,
    updateGems,
    updateKeys,
    updateLegendaryKeys,
    addLevel,
    unlockPhase,
    purchaseUpgrade,
    setBallTransformation,
    grantChestReward,
    unlockSkin,
    saveProgress,
    updateProfile,
    addProfileXp,
    collectAchievementReward,
    upgradeSkinLevel,
    clearAchievementToast,
    recordBossResult,
    recordRunRewards,
    grantReward,
    collectDailyMission,
    rerollDailyMission,
    boostDailyMission,
    collectEventMission,
    collectEventGrandReward,
    spinDailyWheel,
    recordAdUse,
    recordStorePurchase,
    claimOfflineReward,
    refreshTimedSystems,
    updateLanguage,
    updateAudioSettings,
    createLeagueMatch,
    recordLeagueCompetitionResult,
    getLeaguePlayer,
    getLeagueStandings,
    collectDivisionReward,
    collectPendingSeasonReward,
  }), [save, loading]);

  return <GameContext.Provider value={value}>{children}</GameContext.Provider>;
};

export const useGame = () => {
  const context = useContext(GameContext);
  if (!context) throw new Error('useGame must be used within GameProvider');
  return context;
};

import { SkinDefinition } from './skins';
import { UPGRADES } from './upgrades';

export type GameplayStats = {
  baseDamage: number;
  baseSpeed: number;
  coinMultiplier: number;
  xpMultiplier: number;
  critChance?: number;
  critMultiplier?: number;
};

export type FinalGameplayAttributes = {
  attack: number;
  damage: number;
  baseAttack: number;
  damageMultiplier: number;
  coinMultiplier: number;
  goldMultiplier: number;
  xpMultiplier: number;
  speedMultiplier: number;
  ringShrinkMultiplier: number;
  critChance: number;
  critDamage: number;
  ballSpeed: number;
  rewardChance: number;
  displayAtk: number;
  displayGold: number;
  displayXp: number;
};

const getSkinDamageBonus = (skin: SkinDefinition) =>
  ['damage_multiplier', 'cosmic_critical', 'league_king_wave'].includes(skin.passive.type) ? skin.passive.value : 0;

const getSkinCoinBonus = (skin: SkinDefinition) =>
  ['coin_multiplier', 'cosmic_critical', 'league_starter_champion', 'league_king_wave'].includes(skin.passive.type) ? skin.passive.value * 0.6 : 0;

const getSkinXpBonus = (skin: SkinDefinition) =>
  ['xp_multiplier', 'cosmic_critical', 'league_starter_champion', 'league_king_wave'].includes(skin.passive.type) ? skin.passive.value * 0.5 : 0;

const getSkinSpeedBonus = (skin: SkinDefinition) =>
  skin.passive.type === 'speed' ? skin.passive.value : 0;

const getUpgradeEffectValue = (upgradeId: string, effectTypes: string[]) => {
  const upgrade = UPGRADES.find(item => item.id === upgradeId);
  return upgrade?.effects
    .filter(effect => effectTypes.includes(effect.type))
    .reduce((sum, effect) => sum + effect.value, 0) || 0;
};

const getStackedUpgradeBonus = (temporary: Record<string, number>, effectTypes: string[]) =>
  Object.entries(temporary).reduce((sum, [upgradeId, level]) => (
    sum + Math.max(0, level || 0) * getUpgradeEffectValue(upgradeId, effectTypes)
  ), 0);

export const getFinalPlayerStats = (params: {
  stats: GameplayStats;
  skin: SkinDefinition;
  temporaryUpgrades?: Record<string, number>;
  arenaAtk?: number;
  arenaGold?: number;
  permanentUpgrades?: Record<string, number>;
  modeBonus?: Partial<Pick<FinalGameplayAttributes, 'damageMultiplier' | 'coinMultiplier' | 'xpMultiplier' | 'speedMultiplier'>>;
}): FinalGameplayAttributes => {
  const temporary = params.temporaryUpgrades || {};
  const permanent = params.permanentUpgrades || {};
  const arenaAtk = params.arenaAtk || 0;
  const arenaGold = params.arenaGold || 0;
  const modeDamageMultiplier = params.modeBonus?.damageMultiplier || 1;
  const damageMultiplier =
    modeDamageMultiplier *
    (1 + arenaAtk * 0.12 + getSkinDamageBonus(params.skin) + getStackedUpgradeBonus(temporary, ['damage', 'competitiveBoost', 'outerDamage', 'comboBoost']));
  const baseAttack = params.stats.baseDamage;
  const damage = Math.max(1, Math.round(baseAttack * damageMultiplier));
  const temporaryGoldBonus = getStackedUpgradeBonus(temporary, ['coinMultiplier']);
  const temporaryXpBonus = getStackedUpgradeBonus(temporary, ['xpMultiplier', 'competitiveBoost']);
  const temporarySpeedBonus = getStackedUpgradeBonus(temporary, ['speed']);
  const temporaryCritChance = getStackedUpgradeBonus(temporary, ['critChance']);
  const temporaryCritDamage = getStackedUpgradeBonus(temporary, ['critOverload']);
  const temporaryRewardChance = getStackedUpgradeBonus(temporary, ['perfectChance']);
  const goldMultiplier =
    (params.modeBonus?.coinMultiplier || 1) *
    params.stats.coinMultiplier *
    (1 + arenaGold * 0.12 + getSkinCoinBonus(params.skin) + temporaryGoldBonus);
  const xpMultiplier =
    (params.modeBonus?.xpMultiplier || 1) *
    params.stats.xpMultiplier *
    (1 + arenaGold * 0.05 + getSkinXpBonus(params.skin) + temporaryXpBonus);
  const speedMultiplier =
    (params.modeBonus?.speedMultiplier || 1) *
    (1 + params.stats.baseSpeed / 1200 + getSkinSpeedBonus(params.skin) + temporarySpeedBonus + (temporary.ricochet || 0) * 0.025);
  const ringShrinkMultiplier = 1 - Math.min(0.24, (permanent.slowRings || 0) * 0.018);
  const critChance = (params.stats.critChance ?? 5) + temporaryCritChance + (params.skin.passive.type === 'crit_chance' ? params.skin.passive.value : 0);
  const critDamage = (params.stats.critMultiplier ?? 2) + temporaryCritDamage;
  const rewardChance = temporaryRewardChance + (
    params.skin.passive.type === 'perfect_chance' ||
    params.skin.passive.type === 'cosmic_critical' ||
    params.skin.passive.type === 'league_king_wave'
      ? params.skin.passive.value
      : 0
  );

  return {
    attack: damage,
    damage,
    baseAttack,
    damageMultiplier,
    coinMultiplier: goldMultiplier,
    goldMultiplier,
    xpMultiplier,
    speedMultiplier,
    ringShrinkMultiplier,
    critChance,
    critDamage,
    ballSpeed: speedMultiplier,
    rewardChance,
    displayAtk: damage,
    displayGold: Math.round(goldMultiplier * 100),
    displayXp: Math.round(xpMultiplier * 100),
  };
};

export const calculateFinalGameplayAttributes = (params: Parameters<typeof getFinalPlayerStats>[0]): FinalGameplayAttributes => {
  return getFinalPlayerStats(params);
};

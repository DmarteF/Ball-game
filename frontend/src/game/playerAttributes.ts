import { SkinDefinition } from './skins';

export type GameplayStats = {
  baseDamage: number;
  baseSpeed: number;
  coinMultiplier: number;
  xpMultiplier: number;
};

export type FinalGameplayAttributes = {
  damageMultiplier: number;
  coinMultiplier: number;
  xpMultiplier: number;
  speedMultiplier: number;
  ringShrinkMultiplier: number;
  displayAtk: number;
  displayGold: number;
};

const getSkinDamageBonus = (skin: SkinDefinition) =>
  ['damage_multiplier', 'cosmic_critical', 'league_king_wave'].includes(skin.passive.type) ? skin.passive.value : 0;

const getSkinCoinBonus = (skin: SkinDefinition) =>
  ['coin_multiplier', 'cosmic_critical', 'league_starter_champion', 'league_king_wave'].includes(skin.passive.type) ? skin.passive.value * 0.6 : 0;

const getSkinXpBonus = (skin: SkinDefinition) =>
  ['xp_multiplier', 'cosmic_critical', 'league_starter_champion', 'league_king_wave'].includes(skin.passive.type) ? skin.passive.value * 0.5 : 0;

const getSkinSpeedBonus = (skin: SkinDefinition) =>
  skin.passive.type === 'speed' ? skin.passive.value : 0;

export const calculateFinalGameplayAttributes = (params: {
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
  const damageMultiplier =
    (params.modeBonus?.damageMultiplier || 1) *
    (1 + params.stats.baseDamage / 240 + arenaAtk * 0.12 + getSkinDamageBonus(params.skin)) *
    (1 + (temporary.damage || 0) * 0.16 + (temporary.critical || 0) * 0.08 + (temporary.laserCut || 0) * 0.12);
  const coinMultiplier =
    (params.modeBonus?.coinMultiplier || 1) *
    params.stats.coinMultiplier *
    (1 + arenaGold * 0.12 + getSkinCoinBonus(params.skin) + (temporary.coinBoost || 0) * 0.24);
  const xpMultiplier =
    (params.modeBonus?.xpMultiplier || 1) *
    params.stats.xpMultiplier *
    (1 + arenaGold * 0.05 + getSkinXpBonus(params.skin) + (temporary.xpBoost || 0) * 0.2);
  const speedMultiplier =
    (params.modeBonus?.speedMultiplier || 1) *
    (1 + params.stats.baseSpeed / 1200 + getSkinSpeedBonus(params.skin) + (temporary.speed || 0) * 0.04 + (temporary.ricochet || 0) * 0.025);
  const ringShrinkMultiplier = 1 - Math.min(0.24, (permanent.slowRings || 0) * 0.018);

  return {
    damageMultiplier,
    coinMultiplier,
    xpMultiplier,
    speedMultiplier,
    ringShrinkMultiplier,
    displayAtk: Math.round((1 + arenaAtk * 0.12 + getSkinDamageBonus(params.skin)) * 100),
    displayGold: Math.round((params.stats.coinMultiplier * (1 + arenaGold * 0.12 + getSkinCoinBonus(params.skin))) * 100),
  };
};

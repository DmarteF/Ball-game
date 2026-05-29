import { UiIconKey } from '@/src/game/uiIcons';
import { Upgrade } from '@/src/game/upgrades';

const upgradeIconKeys: Record<string, UiIconKey> = {
  baseDamage: 'ui_damage',
  damage: 'ui_damage',
  baseSpeed: 'ui_speed',
  speed: 'ui_speed',
  coinMultiplier: 'ui_coin',
  coinBoost: 'ui_coin',
  magnetCoins: 'ui_coin',
  secretMagnet: 'ui_coin',
  critChance: 'ui_crit',
  critical: 'ui_crit',
  criticalOverload: 'ui_crit',
  xpBoost: 'ui_xp',
  perfectChance: 'ui_perfect',
  diamondInstinct: 'ui_perfect',
  slowRings: 'ui_freeze',
  frost: 'ui_freeze',
  slowField: 'ui_freeze',
  timeFreeze: 'ui_freeze',
  chronoBreak: 'ui_freeze',
  ringRepulse: 'ui_repulse',
  burn: 'ui_burn',
  poison: 'ui_poison',
  penetration: 'ui_pierce',
  shockwave: 'ui_shock',
  chainLightning: 'ui_shock',
  bomb: 'ui_area',
  laser: 'ui_pierce',
  laserCut: 'ui_pierce',
  chainBreak: 'ui_combo',
  voidPulse: 'ui_gravity',
  comboOverdrive: 'ui_combo',
  bounce: 'ui_speed',
  ricochet: 'ui_speed',
  shieldPulse: 'ui_aura',
  lastShield: 'ui_aura',
  royalBreaker: 'ui_achievements',
  bossHunter: 'ui_boss',
  trophyInstinct: 'ui_achievements',
  rivalCrusher: 'ui_league_neon',
  multihit: 'ui_combo',
};

const effectIconKeys: Record<string, UiIconKey> = {
  damage: 'ui_damage',
  speed: 'ui_speed',
  coinMultiplier: 'ui_coin',
  critChance: 'ui_crit',
  xpMultiplier: 'ui_xp',
  perfectChance: 'ui_perfect',
  frost: 'ui_freeze',
  slowField: 'ui_freeze',
  timeFreeze: 'ui_freeze',
  repulse: 'ui_repulse',
  burn: 'ui_burn',
  poison: 'ui_poison',
  chain: 'ui_shock',
  shockwave: 'ui_shock',
  areaDamage: 'ui_area',
  gravity: 'ui_gravity',
  void: 'ui_gravity',
  comboBoost: 'ui_combo',
  pierce: 'ui_pierce',
  penetration: 'ui_pierce',
};

export const getUpgradeIconKey = (upgrade?: Pick<Upgrade, 'id' | 'effects'> | string): UiIconKey => {
  if (!upgrade) return 'ui_upgrades';
  if (typeof upgrade === 'string') return upgradeIconKeys[upgrade] || 'ui_upgrades';
  return upgradeIconKeys[upgrade.id] || effectIconKeys[upgrade.effects?.[0]?.type || ''] || 'ui_upgrades';
};

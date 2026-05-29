import { UiIconKey } from '@/src/game/uiIcons';
import { Upgrade } from '@/src/game/upgrades';

const upgradeIconKeys: Record<string, UiIconKey> = {
  baseDamage: 'ui_upgrades',
  damage: 'ui_upgrades',
  baseSpeed: 'ui_event',
  speed: 'ui_event',
  coinMultiplier: 'ui_coin',
  coinBoost: 'ui_coin',
  magnetCoins: 'ui_coin',
  secretMagnet: 'ui_coin',
  critChance: 'ui_effect',
  critical: 'ui_effect',
  criticalOverload: 'ui_effect',
  xpBoost: 'ui_achievements',
  perfectChance: 'ui_gem',
  diamondInstinct: 'ui_gem',
  slowRings: 'ui_aura',
  frost: 'ui_aura',
  slowField: 'ui_aura',
  timeFreeze: 'ui_aura',
  chronoBreak: 'ui_aura',
  ringRepulse: 'ui_effect',
  burn: 'ui_effect',
  penetration: 'ui_effect',
  shockwave: 'ui_effect',
  chainLightning: 'ui_effect',
  bomb: 'ui_effect',
  laser: 'ui_effect',
  laserCut: 'ui_effect',
  chainBreak: 'ui_effect',
  voidPulse: 'ui_effect',
  comboOverdrive: 'ui_effect',
  bounce: 'ui_event',
  ricochet: 'ui_event',
  shieldPulse: 'ui_aura',
  lastShield: 'ui_aura',
  royalBreaker: 'ui_achievements',
  bossHunter: 'ui_boss',
  trophyInstinct: 'ui_achievements',
  rivalCrusher: 'ui_league_neon',
  multihit: 'ui_effect',
};

const effectIconKeys: Record<string, UiIconKey> = {
  damage: 'ui_upgrades',
  speed: 'ui_event',
  coinMultiplier: 'ui_coin',
  critChance: 'ui_effect',
  xpMultiplier: 'ui_achievements',
  perfectChance: 'ui_gem',
  frost: 'ui_aura',
  slowField: 'ui_aura',
  timeFreeze: 'ui_aura',
  repulse: 'ui_effect',
  burn: 'ui_effect',
  poison: 'ui_effect',
  chain: 'ui_effect',
  shockwave: 'ui_effect',
  areaDamage: 'ui_effect',
  comboBoost: 'ui_effect',
};

export const getUpgradeIconKey = (upgrade?: Pick<Upgrade, 'id' | 'effects'> | string): UiIconKey => {
  if (!upgrade) return 'ui_upgrades';
  if (typeof upgrade === 'string') return upgradeIconKeys[upgrade] || 'ui_upgrades';
  return upgradeIconKeys[upgrade.id] || effectIconKeys[upgrade.effects?.[0]?.type || ''] || 'ui_upgrades';
};

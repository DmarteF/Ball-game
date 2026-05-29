import { useMemo } from 'react';
import { ChestDefinition, ChestReward, ChestType } from '@/src/game/chests';
import { RewardGrant } from '@/src/game/retention';
import { StoreProductConfig, StoreProductId } from '@/src/services/billingConfig';
import { useTranslation } from '@/src/i18n';

const skinNamesEn: Record<string, string> = {
  neon_blue: 'Blue Neon',
  puppy: 'Puppy',
  kitty: 'Kitty',
  piggy: 'Piggy',
  bunny: 'Bunny',
  slime: 'Slime',
  ghost: 'Ghost',
  chick: 'Chick',
  frog: 'Frog',
  monkey: 'Monkey',
  penguin: 'Penguin',
  hamster: 'Hamster',
  bear_common: 'Little Bear',
  panda: 'Panda',
  fox_common: 'Fox',
  tiger_common: 'Tiger',
  cow_common: 'Little Cow',
  octopus_common: 'Octopus',
  fish_common: 'Little Fish',
  bee_common: 'Bee',
  ladybug_common: 'Ladybug',
  robot: 'Robot',
  skull: 'Skull',
  fire: 'Fire',
  ice: 'Ice',
  lightning: 'Lightning',
  star_rare: 'Star',
  moon: 'Moon',
  planet: 'Planet',
  crystal: 'Crystal',
  comet: 'Comet',
  wolf_rare: 'Wolf',
  dragonling_rare: 'Dragonling',
  alien_rare: 'Alien',
  ninja_rare: 'Ninja',
  wizard_rare: 'Wizard',
  satellite_rare: 'Satellite',
  meteor_rare: 'Meteor',
  purple_crystal: 'Purple Crystal',
  neon_heart: 'Neon Heart',
  bomb_rare: 'Bomb',
  red_eye: 'Crimson Eye',
  cosmic_eye: 'Cosmic Eye',
  tiny_dragon: 'Tiny Dragon',
  shadow_orb: 'Shadow Orb',
  solar_orb: 'Solar Orb',
  electric_core: 'Electric Core',
  astral_eye: 'Astral Eye',
  living_plasma: 'Living Plasma',
  radioactive_core: 'Radioactive Core',
  blue_comet: 'Blue Comet',
  neon_spiral: 'Neon Spiral',
  flaming_skull: 'Flaming Skull',
  orbital_blade: 'Orbital Blade',
  neon_dragon: 'Neon Dragon',
  ghost_mask: 'Ghost Mask',
  solar_guardian: 'Solar Guardian',
  ripple_eye: 'Purple Spiral Eye',
  black_hole: 'Black Hole',
  neon_phoenix: 'Neon Phoenix',
  astral_dragon: 'Astral Dragon',
  ghost_king: 'Ghost King',
  collapsed_star: 'Collapsed Star',
  black_sun: 'Black Sun',
  cosmic_emperor: 'Cosmic Emperor',
  galactic_phoenix: 'Galactic Phoenix',
  void_dragon: 'Void Dragon',
  star_king: 'Star King',
  plasma_heart: 'Plasma Heart',
  celestial_core: 'Celestial Core',
  ring_devourer: 'Ring Devourer',
  dimensional_guardian: 'Dimensional Guardian',
  astral_crown: 'Astral Crown',
  infinite_pulse: 'Infinite Pulse',
  blue_vortex: 'Blue Vortex',
  loop_flame: 'Loop Flame',
  red_comet: 'Red Comet',
  neon_eclipse: 'Neon Eclipse',
  endless_prism: 'Endless Prism',
  cosmic_fragment: 'Cosmic Fragment',
  eternal_core: 'Eternal Core',
  infinite_vortex_mythic: 'Infinite Vortex',
  chrono_loop_mythic: 'Chrono Loop',
  omega_infinity: 'Omega Infinity',
  singularity_crown: 'Singularity Crown',
  living_singularity: 'Living Singularity',
  divine_core: 'Divine Core',
  void_devourer_ultimate: 'Void Devourer',
  cosmic_champion: 'Cosmic Champion',
  initial_neon_champion: 'Initial Neon Champion',
  league_bronze_champion: 'Neon Bronze Crown',
  league_king_neon: 'Neon League King',
};

const chestTextEn: Record<ChestType, { name: string; description: string }> = {
  common: { name: 'Common Chest', description: '70% common, 24% rare, 6% epic.' },
  rare: { name: 'Rare Chest', description: '25% common, 55% rare, 17% epic, 3% legendary.' },
  epic: { name: 'Epic Chest', description: '35% rare, 48% epic, 15% legendary, 2% Ultimate.' },
  legendary: { name: 'Legendary Chest', description: '45% epic, 50% legendary, 5% Ultimate.' },
};

const productTextEn: Record<StoreProductId, { title: string; description: string }> = {
  diamonds_small: { title: 'Small Diamond Pack', description: 'Receive 140 diamonds for upgrades, chests, rerolls, and rewards inside Neon Idle Escape.' },
  diamonds_medium: { title: 'Medium Diamond Pack', description: 'Receive 480 diamonds to speed up progress, open chests, reroll options, and enjoy every mode.' },
  diamonds_large: { title: 'Large Diamond Pack', description: 'Receive 1,350 diamonds to unlock more options, rewards, chests, and advantages inside Neon Idle Escape.' },
  daily_offer: { title: 'Daily Offer', description: 'Special daily pack with 90 diamonds, 2 keys, and XP to help your progress.' },
  starter_pack: { title: 'Starter Pack', description: 'Start stronger with 260 diamonds, 2,500 coins, 5 keys, and 1 legendary key.' },
  skin_pack: { title: 'Skin Pack', description: 'Receive 2 rare chests and 2 epic chests for skins, fragments, and special rewards.' },
  fragment_pack: { title: 'Fragment Pack', description: 'Receive 130 fragments for your equipped skin.' },
  event_pack: { title: 'Event Pack', description: 'Receive 1 epic chest, 90 diamonds, 2 keys, and 420 XP for events and challenges.' },
  chest_pack: { title: 'Chest Pack', description: 'Receive 3 common chests, 2 rare chests, and 1 epic chest.' },
};

const missionTextEn: Record<string, string> = {
  rings_50: 'Destroy 50 rings',
  rings_150: 'Destroy 150 rings',
  perfect_3: 'Make 3 Perfect Escapes',
  perfect_10: 'Make 10 Perfect Escapes',
  runs_3: 'Play 3 matches',
  runs_5: 'Play 5 matches',
  win_1: 'Win 1 phase',
  win_3: 'Win 3 phases',
  chest_1: 'Open 1 chest',
  chest_3: 'Open 3 chests',
  coins_500: 'Earn 500 coins in a run',
  coins_2000: 'Earn 2,000 coins in a run',
  gems_5: 'Earn 5 diamonds',
  temp_upgrades_3: 'Use 3 temporary upgrades',
  combo_5: 'Make combo x5',
  combo_10: 'Make combo x10',
  equip_skin: 'Equip a different skin',
  boss_run: 'Play Boss Mode once',
  boss_win: 'Win Boss Mode once',
  offline_claim: 'Collect offline reward',
  store_buy: 'Buy something in the shop',
  watch_ad: 'Use an ad reward once',
  crit_5: 'Make 5 critical hits',
  skin_effect_10: 'Break 10 rings with a skin effect',
  no_revive: 'Complete a phase without revive',
};

const eventTextEn: Record<string, { name: string; description: string; bonus: string }> = {
  neon: { name: 'Neon Event', description: 'High tempo, combos, and bright chests.', bonus: '+10% run coins and a higher chance of electric skins.' },
  frost: { name: 'Frost Event', description: 'Freeze, slow down, and collect fragments.', bonus: 'Higher chance of slow/freeze effects and ice fragments.' },
  cosmic: { name: 'Cosmic Event', description: 'Rare fragments and cosmic chances.', bonus: 'Small extra chance for rare fragments.' },
  flame: { name: 'Flame Event', description: 'Explosive damage and fire fragments.', bonus: 'Fire abilities deal more damage.' },
  ghost: { name: 'Ghost Event', description: 'Shadows, phasing, and Perfects.', bonus: 'Ghost/shadow skins improved and Perfect Escape bonuses.' },
  gold: { name: 'Gold Event', description: 'Economy and shop offers.', bonus: '+15% general coins at the end of the run.' },
  chests: { name: 'Chest Event', description: 'Keys, chests, and offers.', bonus: 'Higher chance to earn keys.' },
  boss_rush: { name: 'Boss Rush Event', description: 'More valuable duels.', bonus: 'Better rewards in Boss Mode.' },
  perfect: { name: 'Perfect Event', description: 'Precise openings and diamonds.', bonus: '+diamond chance on Perfect Escape.' },
  collector: { name: 'Collector Event', description: 'Fragments and collection focus.', bonus: 'More fragments from duplicate skins and chest bonuses.' },
};

const bossTextEn: Record<string, { name: string; theme: string; description: string; passive: string }> = {
  divine_core_january: { name: 'Divine Core', theme: 'golden/celestial', description: 'A celestial core that hardens the final rings.', passive: 'Divine criticals increase damage against solid rings.' },
  living_singularity_february: { name: 'Living Singularity', theme: 'black hole/purple neon', description: 'A living and aggressive gravity sphere.', passive: 'Gravity accelerates the closing speed near the end.' },
  void_devourer_march: { name: 'Void Devourer', theme: 'dark/red/purple', description: 'A presence that consumes the space between rings.', passive: 'Solid rings gain extra health.' },
  neon_league_king_april: { name: 'Neon League King', theme: 'neon crown/gold', description: 'The League champion enters as the monthly Boss.', passive: 'Boss combos buy ATK more often.' },
  cosmic_champion_may: { name: 'Cosmic Champion', theme: 'cosmic/gold', description: 'Cosmic energy in a direct duel.', passive: 'Damage grows when few rings remain.' },
  phoenix_june: { name: 'Solar Phoenix', theme: 'solar/red', description: 'A Boss reborn through solid rings.', passive: 'Breaking solid rings gives the Boss more coins.' },
  astral_dragon_july: { name: 'Astral Dragon', theme: 'astral/cyan', description: 'The dragon crosses fast patterns.', passive: 'More aggressive inner rotation.' },
  star_king_august: { name: 'Star King', theme: 'stellar/blue', description: 'A king of stars in a compact arena.', passive: 'Receives more Gold early.' },
  astral_crown_september: { name: 'Astral Crown', theme: 'astral/gold', description: 'A crown that pressures the player.', passive: 'More frequent criticals.' },
  robot_overlord_october: { name: 'Robot Overlord', theme: 'metal/neon', description: 'Mechanical precision against your arena.', passive: 'Automatic purchases happen in smaller windows.' },
  shadow_november: { name: 'Supreme Shadow', theme: 'shadow/purple', description: 'A shadow that closes rings patiently.', passive: 'Extra HP on the last solid ring.' },
  aurora_december: { name: 'Final Aurora', theme: 'aurora/neon', description: 'The final annual Boss Mode trial.', passive: 'Balanced scaling in damage and speed.' },
};

const bossLevelEn: Record<string, string> = {
  normal: 'Normal',
  forte: 'Strong',
  elite: 'Elite',
  lendario: 'Legendary',
  impossivel: 'Impossible',
};

const upgradeNameEn: Record<string, string> = {
  damage: 'Damage+',
  speed: 'Speed+',
  coinBoost: 'Coin Rain',
  critical: 'Critical+',
  xpBoost: 'XP Boost',
  bounce: 'Bounce',
  perfectChance: 'Perfect Chance',
  burn: 'Burn',
  penetration: 'Poison',
  ricochet: 'Living Ricochet',
  shockwave: 'Shockwave',
  chainLightning: 'Chain Lightning',
  frost: 'Frost',
  bomb: 'Bomb',
  laser: 'Laser Beam',
  multihit: 'Multi-Hit',
  slowField: 'Slow Field',
  ringRepulse: 'Ring Repulse',
  laserCut: 'Laser Cut',
  chainBreak: 'Chain Break',
  shieldPulse: 'Shield Pulse',
};

const eventMissionTextEn: Record<string, string> = {
  neon_ringsDestroyed_500: 'Destroy 500 rings',
  neon_bestCombo_10: 'Make combo x10 five times',
  neon_chestsOpened_10: 'Open 10 chests',
  frost_perfectEscapes_35: 'Make 35 Perfect Escapes',
  frost_ringsDestroyed_420: 'Destroy 420 rings',
  frost_chestsOpened_6: 'Open 6 chests',
  cosmic_phaseWins_5: 'Win 5 phases',
  cosmic_gemsEarned_12: 'Earn 12 diamonds',
  cosmic_runsPlayed_12: 'Play 12 matches',
  flame_criticals_40: 'Make 40 critical hits',
  flame_skinEffects_35: 'Break 35 rings with a skin effect',
  flame_ringsDestroyed_600: 'Destroy 600 rings',
  ghost_perfectEscapes_50: 'Make 50 Perfect Escapes',
  ghost_noReviveWins_3: 'Win 3 phases without revive',
  ghost_runsPlayed_10: 'Play 10 matches',
  gold_runCoins_8000: 'Earn 8,000 coins in a run',
  gold_storePurchases_5: 'Buy 5 shop items',
  gold_adsWatched_4: 'Use 4 ad rewards',
  chests_chestsOpened_10: 'Open 10 chests',
  chests_storePurchases_6: 'Collect 6 keys',
  chests_ringsDestroyed_450: 'Destroy 450 rings',
  boss_rush_bossRuns_5: 'Play 5 Boss Modes',
  boss_rush_bossWins_3: 'Win 3 Boss Modes',
  boss_rush_criticals_25: 'Make 25 critical hits',
  perfect_perfectEscapes_60: 'Make 60 Perfect Escapes',
  perfect_bestCombo_20: 'Make combo x20',
  perfect_noReviveWins_4: 'Win 4 phases without revive',
  collector_chestsOpened_12: 'Open 12 chests',
  collector_skinEquips_3: 'Equip 3 different skins',
  collector_skinEffects_3: 'Earn 3 skins or fragments',
};

const rarityEn: Record<string, string> = {
  common: 'common',
  rare: 'rare',
  epic: 'epic',
  legendary: 'legendary',
  mythic: 'mythic',
  ultimate: 'ultimate',
};

const titleizeId = (id: string) => id.replace(/_/g, ' ').replace(/\b\w/g, letter => letter.toUpperCase());

const categoryEn: Record<string, string> = {
  todas: 'all',
  progresso: 'progress',
  combate: 'combat',
  coleção: 'collection',
  economia: 'economy',
  'baús': 'chests',
  skins: 'skins',
  'perfect escape': 'perfect escape',
  boss: 'boss',
  liga: 'league',
  especiais: 'special',
};

const shouldUsePortuguese = (language: string) => language === 'pt-BR';

export const useGameText = () => {
  const { language, t } = useTranslation();

  return useMemo(() => {
    const skinName = (skin?: { id: string; name: string } | null) => {
      if (!skin) return '';
      if (shouldUsePortuguese(language)) return skin.name;
      return skinNamesEn[skin.id] || skin.name;
    };

    const skinNameById = (skinId: string, fallback = '') => {
      if (shouldUsePortuguese(language)) return fallback || skinId;
      return skinNamesEn[skinId] || fallback || skinId;
    };

    const skinDescription = (skin?: { id: string; name: string; rarity: string; description: string } | null) => {
      if (!skin) return '';
      if (shouldUsePortuguese(language)) return skin.description;
      return `${skinName(skin)} is a ${rarityEn[skin.rarity] || skin.rarity} skin with a unique passive effect.`;
    };

    const chestName = (chest: ChestDefinition | ChestType) => {
      const id = typeof chest === 'string' ? chest : chest.id;
      if (shouldUsePortuguese(language)) return typeof chest === 'string' ? `Baú ${chest}` : chest.name;
      return chestTextEn[id]?.name || (typeof chest === 'string' ? id : chest.name);
    };

    const chestDescription = (chest: ChestDefinition) => (
      shouldUsePortuguese(language) ? chest.description : chestTextEn[chest.id]?.description || chest.description
    );

    const storeProduct = (product: StoreProductConfig) => {
      if (shouldUsePortuguese(language)) return product;
      return { ...product, ...(productTextEn[product.id] || {}) };
    };

    const missionTitle = (mission: { id: string; title: string }) => (
      shouldUsePortuguese(language) ? mission.title : missionTextEn[mission.id] || eventMissionTextEn[mission.id] || mission.title
    );

    const eventMissionTitle = missionTitle;

    const eventText = (event: { id: string; name: string; description: string; bonus: string }) => {
      if (shouldUsePortuguese(language)) return event;
      return { ...event, ...(eventTextEn[event.id] || {}) };
    };

    const bossText = (boss: { id: string; name: string; theme: string; description: string; passive: string; skinId?: string }) => {
      if (shouldUsePortuguese(language)) return boss;
      return { ...boss, ...(bossTextEn[boss.id] || { name: skinNameById(boss.skinId || boss.id, boss.name) }) };
    };

    const bossLevelName = (level: { id: string; name: string } | string) => {
      const id = typeof level === 'string' ? level : level.id;
      if (shouldUsePortuguese(language)) return typeof level === 'string' ? level : level.name;
      return bossLevelEn[id] || (typeof level === 'string' ? level : level.name);
    };

    const upgradeName = (upgrade: { id: string; name: string }) => {
      if (shouldUsePortuguese(language)) return upgrade.name;
      return upgradeNameEn[upgrade.id] || titleizeId(upgrade.id);
    };

    const upgradeDescription = (upgrade: { description: string; effects?: { type: string; value: number }[] }) => {
      if (shouldUsePortuguese(language)) return upgrade.description;
      const effect = upgrade.effects?.[0];
      if (!effect) return 'Improves your run power.';
      const value = Math.abs(effect.value);
      if (effect.type === 'damage') return `+${Math.round(value * 100)}% damage`;
      if (effect.type === 'speed') return `+${Math.round(value * 100)}% speed`;
      if (effect.type === 'coinMultiplier') return `+${Math.round(value * 100)}% coins`;
      if (effect.type === 'critChance') return `+${value}% critical chance`;
      if (effect.type === 'xpMultiplier') return `+${Math.round(value * 100)}% XP`;
      if (effect.type === 'frost') return 'Slows rings';
      if (effect.type === 'burn') return 'Deals fire damage over time';
      if (effect.type === 'chain') return 'Hits nearby targets';
      if (effect.type === 'repulse') return 'Pushes the hit ring outward';
      return 'Improves your run power.';
    };

    const rewardText = (reward: RewardGrant | { type: string; amount?: number; chestType?: ChestType; skinId?: string }) => {
      if (reward.type === 'coins') return `💰 ${reward.amount}`;
      if (reward.type === 'gems') return `💎 ${reward.amount}`;
      if (reward.type === 'keys') return `🔑 ${reward.amount}`;
      if (reward.type === 'legendaryKeys') return `🗝️ ${reward.amount}`;
      if (reward.type === 'profileXp') return `${t('stats.xp')} ${reward.amount}`;
      if (reward.type === 'fragments') return `🧩 ${reward.amount}`;
      if (reward.type === 'skin') return `🌟 ${reward.skinId ? skinNameById(reward.skinId) : t('nav.skins')}`;
      if (reward.type === 'chest' && reward.chestType) return `🎁 ${chestName(reward.chestType)}`;
      return `${reward.amount || ''}`.trim();
    };

    const chestRewardLabel = (reward?: ChestReward | null) => {
      if (!reward) return '';
      if (reward.skinId) return skinNamesEn[reward.skinId] && !shouldUsePortuguese(language) ? skinNamesEn[reward.skinId] : reward.label;
      if (shouldUsePortuguese(language)) return reward.label;
      if (reward.type === 'key') return reward.rarity === 'legendary' || reward.rarity === 'mythic' || reward.rarity === 'ultimate' ? 'Legendary Key' : 'Key';
      if (reward.type === 'coins') return `${t('stats.coins')} ${reward.amount || ''}`.trim();
      if (reward.type === 'gems') return `${t('stats.diamonds')} ${reward.amount || ''}`.trim();
      if (reward.type === 'fragments') return `${reward.amount || ''} Fragments`.trim();
      return reward.label;
    };

    const rarity = (value?: string) => {
      if (!value) return '';
      if (shouldUsePortuguese(language)) return value.toUpperCase();
      return (rarityEn[value] || value).toUpperCase();
    };

    const achievementName = (achievement: { id: string; name: string }) => (
      shouldUsePortuguese(language) ? achievement.name : titleizeId(achievement.id)
    );

    const achievementDescription = (achievement: { description: string }) => (
      shouldUsePortuguese(language) ? achievement.description : 'Complete this objective to claim the reward.'
    );

    const category = (value: string) => shouldUsePortuguese(language) ? value : categoryEn[value] || value;

    return {
      skinName,
      skinNameById,
      skinDescription,
      chestName,
      chestDescription,
      storeProduct,
      missionTitle,
      eventMissionTitle,
      eventText,
      bossText,
      bossLevelName,
      upgradeName,
      upgradeDescription,
      rewardText,
      chestRewardLabel,
      rarity,
      achievementName,
      achievementDescription,
      category,
    };
  }, [language, t]);
};

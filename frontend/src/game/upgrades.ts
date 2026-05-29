export type UpgradeRarity = 'common' | 'rare' | 'epic' | 'legendary';

export interface Upgrade {
  id: string;
  name: string;
  description: string;
  icon: string;
  rarity: UpgradeRarity;
  maxLevel: number;
  unlockLevel: number;
  unlockRequirement?: string;
  secret?: boolean;
  secretCondition?: string;
  effects: {
    type: string;
    value: number;
  }[];
}

export const UPGRADES: Upgrade[] = [
  // === STARTER UPGRADES (Available from Level 1) ===
  {
    id: 'damage',
    name: 'Dano+',
    description: '+15% de dano',
    icon: '⚔️',
    rarity: 'common',
    maxLevel: 10,
    unlockLevel: 1,
    unlockRequirement: 'Perfil nível 1',
    effects: [{ type: 'damage', value: 0.15 }],
  },
  {
    id: 'speed',
    name: 'Velocidade+',
    description: '+20% de velocidade',
    icon: '⚡',
    rarity: 'common',
    maxLevel: 10,
    unlockLevel: 1,
    unlockRequirement: 'Perfil nível 1',
    effects: [{ type: 'speed', value: 0.20 }],
  },
  {
    id: 'coinBoost',
    name: 'Chuva de Moedas',
    description: '+50% de moedas',
    icon: '💰',
    rarity: 'common',
    maxLevel: 10,
    unlockLevel: 1,
    unlockRequirement: 'Perfil nível 1',
    effects: [{ type: 'coinMultiplier', value: 0.5 }],
  },
  {
    id: 'critical',
    name: 'Crítico+',
    description: '+5% chance crítica',
    icon: '💥',
    rarity: 'common',
    maxLevel: 8,
    unlockLevel: 1,
    unlockRequirement: 'Perfil nível 1',
    effects: [{ type: 'critChance', value: 5 }],
  },
  
  // === LEVEL 3+ UPGRADES ===
  {
    id: 'xpBoost',
    name: 'XP Boost',
    description: '+50% de XP',
    icon: '⭐',
    rarity: 'common',
    maxLevel: 10,
    unlockLevel: 3,
    unlockRequirement: 'Perfil nível 3',
    effects: [{ type: 'xpMultiplier', value: 0.5 }],
  },
  {
    id: 'bounce',
    name: 'Ricochete',
    description: '+1 ricochete extra',
    icon: '🎯',
    rarity: 'rare',
    maxLevel: 5,
    unlockLevel: 7,
    unlockRequirement: 'Perfil nível 7',
    effects: [{ type: 'bounce', value: 1 }],
  },
  {
    id: 'perfectChance',
    name: 'Perfect Chance',
    description: '+1% chance de diamante no Perfect',
    icon: '💎',
    rarity: 'rare',
    maxLevel: 7,
    unlockLevel: 5,
    unlockRequirement: 'Perfil nível 5',
    effects: [{ type: 'perfectChance', value: 0.01 }],
  },
  
  // === LEVEL 5+ UPGRADES (Rare) ===
  {
    id: 'burn',
    name: 'Queimar',
    description: 'Causa dano contínuo de fogo',
    icon: '🔥',
    rarity: 'rare',
    maxLevel: 5,
    unlockLevel: 5,
    unlockRequirement: 'Perfil nível 3',
    effects: [{ type: 'burn', value: 10 }],
  },
  {
    id: 'penetration',
    name: 'Veneno',
    description: 'Aplica dano progressivo',
    icon: '🗡️',
    rarity: 'rare',
    maxLevel: 5,
    unlockLevel: 5,
    unlockRequirement: 'Perfil nível 5',
    effects: [{ type: 'poison', value: 1 }],
  },
  {
    id: 'ricochet',
    name: 'Ricochete Vivo',
    description: 'Mais variação e velocidade após impacto',
    icon: '🔁',
    rarity: 'rare',
    maxLevel: 5,
    unlockLevel: 5,
    unlockRequirement: 'Perfil nível 7',
    effects: [{ type: 'ricochet', value: 1 }],
  },
  
  // === LEVEL 8+ UPGRADES (Epic) ===
  {
    id: 'shockwave',
    name: 'Onda de Choque',
    description: 'Dano em área ao impacto',
    icon: '🌊',
    rarity: 'epic',
    maxLevel: 5,
    unlockLevel: 8,
    unlockRequirement: 'Perfil nível 12',
    effects: [{ type: 'shockwave', value: 0.5 }],
  },
  {
    id: 'chainLightning',
    name: 'Raio em Cadeia',
    description: 'Ataca alvos próximos',
    icon: '⚡',
    rarity: 'epic',
    maxLevel: 5,
    unlockLevel: 10,
    unlockRequirement: 'Perfil nível 10',
    effects: [{ type: 'chain', value: 2 }],
  },
  {
    id: 'frost',
    name: 'Congelamento',
    description: 'Desacelera anéis',
    icon: '❄️',
    rarity: 'epic',
    maxLevel: 5,
    unlockLevel: 5,
    unlockRequirement: 'Perfil nível 5',
    effects: [{ type: 'frost', value: 0.3 }],
  },
  
  // === LEVEL 12+ UPGRADES (Epic Advanced) ===
  {
    id: 'bomb',
    name: 'Bomba',
    description: 'Chance de explosão massiva',
    icon: '💣',
    rarity: 'epic',
    maxLevel: 5,
    unlockLevel: 15,
    unlockRequirement: 'Perfil nível 15',
    effects: [{ type: 'bomb', value: 3 }],
  },
  {
    id: 'laser',
    name: 'Raio Laser',
    description: 'Dispara raio laser',
    icon: '🔫',
    rarity: 'epic',
    maxLevel: 5,
    unlockLevel: 12,
    unlockRequirement: 'Perfil nível 12',
    effects: [{ type: 'laser', value: 50 }],
  },
  
  // === LEVEL 15+ UPGRADES (Legendary) ===
  {
    id: 'multihit',
    name: 'Multi-Hit',
    description: 'Múltiplos ataques simultâneos',
    icon: '✨',
    rarity: 'legendary',
    maxLevel: 3,
    unlockLevel: 15,
    unlockRequirement: 'Perfil nível 25',
    effects: [{ type: 'multihit', value: 1 }],
  },
  {
    id: 'slowField',
    name: 'Slow Field',
    description: 'Chance de desacelerar todos os anéis',
    icon: '🌀',
    rarity: 'epic',
    maxLevel: 5,
    unlockLevel: 9,
    unlockRequirement: 'Perfil nível 9',
    effects: [{ type: 'slowField', value: 0.35 }],
  },
  {
    id: 'ringRepulse',
    name: 'Ring Repulse',
    description: 'Empurra o anel atingido para fora',
    icon: '↗️',
    rarity: 'rare',
    maxLevel: 5,
    unlockLevel: 7,
    unlockRequirement: 'Perfil nível 7',
    effects: [{ type: 'repulse', value: 18 }],
  },
  {
    id: 'laserCut',
    name: 'Laser Cut',
    description: 'Chance de dano alto no anel',
    icon: '🔦',
    rarity: 'epic',
    maxLevel: 5,
    unlockLevel: 12,
    unlockRequirement: 'Perfil nível 12',
    effects: [{ type: 'laserCut', value: 2.5 }],
  },
  {
    id: 'chainBreak',
    name: 'Chain Break',
    description: 'Quebrar um anel fere o próximo',
    icon: '⛓️',
    rarity: 'legendary',
    maxLevel: 4,
    unlockLevel: 18,
    unlockRequirement: 'Perfil nível 18',
    effects: [{ type: 'chainBreak', value: 0.35 }],
  },
  {
    id: 'shieldPulse',
    name: 'Shield Pulse',
    description: 'Escudo curto contra esmagamento',
    icon: '🛡️',
    rarity: 'epic',
    maxLevel: 4,
    unlockLevel: 14,
    unlockRequirement: 'Perfil nível 14',
    effects: [{ type: 'shield', value: 2 }],
  },
  {
    id: 'timeFreeze',
    name: 'Time Freeze',
    description: 'Congela todos os anéis por pouco tempo',
    icon: '⏱️',
    rarity: 'legendary',
    maxLevel: 3,
    unlockLevel: 20,
    unlockRequirement: 'Perfil nível 20',
    effects: [{ type: 'timeFreeze', value: 1 }],
  },
  {
    id: 'magnetCoins',
    name: 'Magnet Coins',
    description: 'Aumenta moedas da rodada',
    icon: '🧲',
    rarity: 'rare',
    maxLevel: 8,
    unlockLevel: 6,
    unlockRequirement: 'Perfil nível 6',
    effects: [{ type: 'coinMultiplier', value: 0.25 }],
  },
  {
    id: 'criticalOverload',
    name: 'Critical Overload',
    description: 'Críticos acumulam dano temporário',
    icon: '💢',
    rarity: 'legendary',
    maxLevel: 4,
    unlockLevel: 16,
    unlockRequirement: 'Perfil nível 16',
    effects: [{ type: 'critOverload', value: 0.3 }],
  },
  {
    id: 'chronoBreak',
    name: 'Chrono Break',
    description: 'Pequena chance de congelar todos os anéis por alguns segundos.',
    icon: '⏳',
    rarity: 'legendary',
    maxLevel: 3,
    unlockLevel: 1,
    unlockRequirement: 'Conquista secreta',
    secret: true,
    secretCondition: 'Fazer 100 Perfect Escapes',
    effects: [{ type: 'timeFreeze', value: 1 }],
  },
  {
    id: 'voidPulse',
    name: 'Void Pulse',
    description: 'Chance de causar dano em área ao quebrar um anel.',
    icon: '🌑',
    rarity: 'legendary',
    maxLevel: 4,
    unlockLevel: 1,
    unlockRequirement: 'Conquista secreta',
    secret: true,
    secretCondition: 'Quebrar 1000 anéis',
    effects: [{ type: 'areaDamage', value: 0.45 }],
  },
  {
    id: 'diamondInstinct',
    name: 'Diamond Instinct',
    description: 'Aumenta chance de diamante em Perfect Escape.',
    icon: '💠',
    rarity: 'epic',
    maxLevel: 4,
    unlockLevel: 1,
    unlockRequirement: 'Conquista secreta',
    secret: true,
    secretCondition: 'Ganhar 50 diamantes por Perfect',
    effects: [{ type: 'perfectChance', value: 0.018 }],
  },
  {
    id: 'comboOverdrive',
    name: 'Combo Overdrive',
    description: 'Combos altos aumentam dano e moedas temporariamente.',
    icon: '🚀',
    rarity: 'legendary',
    maxLevel: 3,
    unlockLevel: 1,
    unlockRequirement: 'Conquista secreta',
    secret: true,
    secretCondition: 'Atingir combo x25',
    effects: [{ type: 'comboBoost', value: 0.25 }],
  },
  {
    id: 'lastShield',
    name: 'Last Shield',
    description: 'Uma vez por partida, evita morte por esmagamento.',
    icon: '🛡️',
    rarity: 'legendary',
    maxLevel: 2,
    unlockLevel: 1,
    unlockRequirement: 'Conquista secreta',
    secret: true,
    secretCondition: 'Vencer 10 fases sem revive',
    effects: [{ type: 'lastShield', value: 1 }],
  },
  {
    id: 'royalBreaker',
    name: 'Royal Breaker',
    description: 'Aumenta dano contra anéis externos.',
    icon: '👑',
    rarity: 'legendary',
    maxLevel: 4,
    unlockLevel: 1,
    unlockRequirement: 'Conquista secreta',
    secret: true,
    secretCondition: 'Terminar uma temporada da Liga Neon no top 3',
    effects: [{ type: 'outerDamage', value: 0.22 }],
  },
  {
    id: 'bossHunter',
    name: 'Boss Hunter',
    description: 'Aumenta dano e XP em modos competitivos.',
    icon: '🎯',
    rarity: 'epic',
    maxLevel: 4,
    unlockLevel: 1,
    unlockRequirement: 'Conquista secreta',
    secret: true,
    secretCondition: 'Vencer 10 Boss Modes',
    effects: [{ type: 'competitiveBoost', value: 0.18 }],
  },
  {
    id: 'secretMagnet',
    name: 'Secret Magnet',
    description: 'Aumenta moedas gerais recebidas no final.',
    icon: '🧲',
    rarity: 'epic',
    maxLevel: 5,
    unlockLevel: 1,
    unlockRequirement: 'Conquista secreta',
    secret: true,
    secretCondition: 'Coletar 20 recompensas diárias',
    effects: [{ type: 'coinMultiplier', value: 0.18 }],
  },
  {
    id: 'trophyInstinct',
    name: 'Trophy Instinct',
    description: 'Pequeno bônus de troféus ao vencer competições.',
    icon: '🏆',
    rarity: 'epic',
    maxLevel: 3,
    unlockLevel: 1,
    unlockRequirement: 'Conquista secreta',
    secret: true,
    secretCondition: 'Vencer 25 competições na Liga Neon',
    effects: [{ type: 'trophyBonus', value: 2 }],
  },
  {
    id: 'rivalCrusher',
    name: 'Rival Crusher',
    description: 'Aumenta dano e XP em partidas competitivas.',
    icon: '💢',
    rarity: 'legendary',
    maxLevel: 3,
    unlockLevel: 1,
    unlockRequirement: 'Conquista secreta',
    secret: true,
    secretCondition: 'Vencer 10 competições seguidas',
    effects: [{ type: 'competitiveBoost', value: 0.24 }],
  },
];

export const getRarityColor = (rarity: UpgradeRarity): string => {
  switch (rarity) {
    case 'common': return '#888888';
    case 'rare': return '#0088ff';
    case 'epic': return '#b000ff';
    case 'legendary': return '#ffd700';
    default: return '#ffffff';
  }
};

export const getRarityName = (rarity: UpgradeRarity): string => {
  switch (rarity) {
    case 'common': return 'COMUM';
    case 'rare': return 'RARO';
    case 'epic': return 'ÉPICO';
    case 'legendary': return 'LENDÁRIO';
    default: return '';
  }
};

const STARTER_RUN_UPGRADE_IDS = ['damage', 'speed', 'coinBoost', 'critical'];

const PERMANENT_TO_RUN_UPGRADE_IDS: Record<string, string[]> = {
  baseDamage: ['damage'],
  baseSpeed: ['speed'],
  coinMultiplier: ['coinBoost'],
  critChance: ['critical'],
  xpBoost: ['xpBoost'],
  perfectChance: ['perfectChance'],
  slowRings: ['frost'],
};

const getUnlockedRunUpgradeIds = (unlockedUpgradeIds?: string[]) => {
  const unlockedPermanentIds = unlockedUpgradeIds?.length
    ? unlockedUpgradeIds
    : ['baseDamage', 'baseSpeed', 'coinMultiplier', 'critChance'];
  const runIds = new Set<string>();

  unlockedPermanentIds.forEach(id => {
    if (UPGRADES.some(upgrade => upgrade.id === id)) runIds.add(id);
    PERMANENT_TO_RUN_UPGRADE_IDS[id]?.forEach(runId => runIds.add(runId));
  });

  if (!unlockedUpgradeIds?.length) {
    STARTER_RUN_UPGRADE_IDS.forEach(id => runIds.add(id));
  }

  return runIds;
};

export const getAvailableRunUpgrades = (
  currentUpgrades: Record<string, number> = {},
  _playerLevel: number = 1,
  unlockedUpgradeIds?: string[]
): Upgrade[] => {
  const unlocked = getUnlockedRunUpgradeIds(unlockedUpgradeIds);

  return UPGRADES.filter(upgrade =>
    Boolean(upgrade?.id && upgrade.name && upgrade.description && upgrade.icon) &&
    (currentUpgrades[upgrade.id] || 0) < upgrade.maxLevel &&
    unlocked.has(upgrade.id) &&
    (!upgrade.secret || unlocked.has(upgrade.id))
  );
};

export const getRandomUpgrades = (
  count: number = 3,
  currentUpgrades: Record<string, number> = {},
  playerLevel: number = 1,
  unlockedUpgradeIds?: string[]
): Upgrade[] => {
  const available = getAvailableRunUpgrades(currentUpgrades, playerLevel, unlockedUpgradeIds);
  
  // Apply rarity weighting (common more likely than legendary)
  const weighted: Upgrade[] = [];
  available.forEach(upgrade => {
    let weight = 1;
    switch (upgrade.rarity) {
      case 'common': weight = 10; break;
      case 'rare': weight = 5; break;
      case 'epic': weight = 2; break;
      case 'legendary': weight = 1; break;
    }
    for (let i = 0; i < weight; i++) {
      weighted.push(upgrade);
    }
  });
  
  const shuffled = weighted.sort(() => Math.random() - 0.5);
  const unique: Upgrade[] = [];
  const seen = new Set<string>();
  
  for (const upgrade of shuffled) {
    if (!seen.has(upgrade.id)) {
      seen.add(upgrade.id);
      unique.push(upgrade);
      if (unique.length >= count) break;
    }
  }
  const fallback = available.filter(upgrade => STARTER_RUN_UPGRADE_IDS.includes(upgrade.id));
  for (const upgrade of fallback) {
    if (!seen.has(upgrade.id)) {
      seen.add(upgrade.id);
      unique.push(upgrade);
      if (unique.length >= count) break;
    }
  }

  if (unique.length < count) {
    const safePool = available;
    for (const upgrade of safePool) {
      if (!seen.has(upgrade.id)) {
        seen.add(upgrade.id);
        unique.push(upgrade);
        if (unique.length >= count) break;
      }
    }
  }

  return unique;
};

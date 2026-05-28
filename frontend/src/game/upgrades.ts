export type UpgradeRarity = 'common' | 'rare' | 'epic' | 'legendary';

export interface Upgrade {
  id: string;
  name: string;
  description: string;
  icon: string;
  rarity: UpgradeRarity;
  maxLevel: number;
  unlockLevel: number;
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
    effects: [{ type: 'xpMultiplier', value: 0.5 }],
  },
  {
    id: 'bounce',
    name: 'Ricochete',
    description: '+1 ricochete extra',
    icon: '🎯',
    rarity: 'rare',
    maxLevel: 5,
    unlockLevel: 3,
    effects: [{ type: 'bounce', value: 1 }],
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
    effects: [{ type: 'burn', value: 10 }],
  },
  {
    id: 'penetration',
    name: 'Penetração',
    description: 'Atravessa múltiplos anéis',
    icon: '🗡️',
    rarity: 'rare',
    maxLevel: 5,
    unlockLevel: 5,
    effects: [{ type: 'penetration', value: 1 }],
  },
  {
    id: 'shuriken',
    name: 'Shuriken',
    description: 'Lança shurikens rotatórias',
    icon: '🌟',
    rarity: 'rare',
    maxLevel: 5,
    unlockLevel: 5,
    effects: [{ type: 'shuriken', value: 3 }],
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
    effects: [{ type: 'shockwave', value: 0.5 }],
  },
  {
    id: 'chainLightning',
    name: 'Raio em Cadeia',
    description: 'Ataca alvos próximos',
    icon: '⚡',
    rarity: 'epic',
    maxLevel: 5,
    unlockLevel: 8,
    effects: [{ type: 'chain', value: 2 }],
  },
  {
    id: 'frost',
    name: 'Congelamento',
    description: 'Desacelera anéis',
    icon: '❄️',
    rarity: 'epic',
    maxLevel: 5,
    unlockLevel: 8,
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
    unlockLevel: 12,
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
    effects: [{ type: 'multihit', value: 1 }],
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

export const getRandomUpgrades = (
  count: number = 3,
  currentUpgrades: Record<string, number> = {},
  playerLevel: number = 1
): Upgrade[] => {
  // Filter by: max level not reached AND player has unlocked it
  const available = UPGRADES.filter(
    upgrade =>
      (currentUpgrades[upgrade.id] || 0) < upgrade.maxLevel &&
      playerLevel >= upgrade.unlockLevel
  );
  
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
  
  // Shuffle and pick unique ones
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
  
  return unique;
};

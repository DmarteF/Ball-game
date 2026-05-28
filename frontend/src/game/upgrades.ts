export type UpgradeRarity = 'common' | 'rare' | 'epic' | 'legendary';

export interface Upgrade {
  id: string;
  name: string;
  description: string;
  icon: string;
  rarity: UpgradeRarity;
  maxLevel: number;
  effects: {
    type: string;
    value: number;
  }[];
}

export const UPGRADES: Upgrade[] = [
  {
    id: 'damage',
    name: 'Dano+',
    description: '+15% de dano',
    icon: '⚔️',
    rarity: 'common',
    maxLevel: 10,
    effects: [{ type: 'damage', value: 0.15 }],
  },
  {
    id: 'speed',
    name: 'Velocidade+',
    description: '+20% de velocidade',
    icon: '⚡',
    rarity: 'common',
    maxLevel: 10,
    effects: [{ type: 'speed', value: 0.20 }],
  },
  {
    id: 'critical',
    name: 'Crítico+',
    description: '+5% chance crítica',
    icon: '💥',
    rarity: 'rare',
    maxLevel: 8,
    effects: [{ type: 'critChance', value: 5 }],
  },
  {
    id: 'burn',
    name: 'Queimar',
    description: 'Causa dano contínuo de fogo',
    icon: '🔥',
    rarity: 'rare',
    maxLevel: 5,
    effects: [{ type: 'burn', value: 10 }],
  },
  {
    id: 'bounce',
    name: 'Ricochete',
    description: '+1 ricochete extra',
    icon: '🎯',
    rarity: 'rare',
    maxLevel: 5,
    effects: [{ type: 'bounce', value: 1 }],
  },
  {
    id: 'shockwave',
    name: 'Onda de Choque',
    description: 'Dano em área ao impacto',
    icon: '🌊',
    rarity: 'epic',
    maxLevel: 5,
    effects: [{ type: 'shockwave', value: 0.5 }],
  },
  {
    id: 'chainLightning',
    name: 'Raio em Cadeia',
    description: 'Ataca alvos próximos',
    icon: '⚡',
    rarity: 'epic',
    maxLevel: 5,
    effects: [{ type: 'chain', value: 2 }],
  },
  {
    id: 'bomb',
    name: 'Bomba',
    description: 'Chance de explosão massiva',
    icon: '💣',
    rarity: 'epic',
    maxLevel: 5,
    effects: [{ type: 'bomb', value: 3 }],
  },
  {
    id: 'frost',
    name: 'Congelamento',
    description: 'Desacelera anéis',
    icon: '❄️',
    rarity: 'epic',
    maxLevel: 5,
    effects: [{ type: 'frost', value: 0.3 }],
  },
  {
    id: 'penetration',
    name: 'Penetração',
    description: 'Atravessa múltiplos anéis',
    icon: '🗡️',
    rarity: 'rare',
    maxLevel: 5,
    effects: [{ type: 'penetration', value: 1 }],
  },
  {
    id: 'multihit',
    name: 'Multi-Hit',
    description: 'Múltiplos ataques simultâneos',
    icon: '✨',
    rarity: 'legendary',
    maxLevel: 3,
    effects: [{ type: 'multihit', value: 1 }],
  },
  {
    id: 'coinBoost',
    name: 'Chuva de Moedas',
    description: '+50% de moedas',
    icon: '💰',
    rarity: 'common',
    maxLevel: 10,
    effects: [{ type: 'coinMultiplier', value: 0.5 }],
  },
  {
    id: 'xpBoost',
    name: 'XP Boost',
    description: '+50% de XP',
    icon: '⭐',
    rarity: 'common',
    maxLevel: 10,
    effects: [{ type: 'xpMultiplier', value: 0.5 }],
  },
  {
    id: 'laser',
    name: 'Raio Laser',
    description: 'Dispara raio laser',
    icon: '🔫',
    rarity: 'epic',
    maxLevel: 5,
    effects: [{ type: 'laser', value: 50 }],
  },
  {
    id: 'shuriken',
    name: 'Shuriken',
    description: 'Lança shurikens rotatórias',
    icon: '⭐',
    rarity: 'rare',
    maxLevel: 5,
    effects: [{ type: 'shuriken', value: 3 }],
  },
];

export const getRarityColor = (rarity: UpgradeRarity): string => {
  switch (rarity) {
    case 'common':
      return '#888888';
    case 'rare':
      return '#0088ff';
    case 'epic':
      return '#b000ff';
    case 'legendary':
      return '#ffd700';
    default:
      return '#ffffff';
  }
};

export const getRandomUpgrades = (count: number = 3, currentUpgrades: Record<string, number> = {}): Upgrade[] => {
  const available = UPGRADES.filter(
    upgrade => (currentUpgrades[upgrade.id] || 0) < upgrade.maxLevel
  );
  
  const shuffled = available.sort(() => Math.random() - 0.5);
  return shuffled.slice(0, Math.min(count, shuffled.length));
};

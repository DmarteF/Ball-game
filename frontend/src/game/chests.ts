import { SKINS, SkinRarity } from './skins';

export type ChestType = 'common' | 'rare' | 'epic' | 'legendary';
export type RewardType = 'skin' | 'fragments' | 'trail' | 'aura' | 'effect' | 'card' | 'key' | 'coins' | 'gems';

export interface ChestDefinition {
  id: ChestType;
  name: string;
  icon: string;
  cost: number;
  currency: 'coins' | 'gems' | 'keys' | 'legendaryKeys';
  color: string;
  description: string;
  chances: Partial<Record<SkinRarity, number>>;
}

export interface ChestReward {
  type: RewardType;
  label: string;
  icon: string;
  rarity: SkinRarity;
  skinId?: string;
  amount?: number;
  isDuplicate?: boolean;
}

export const CHESTS: ChestDefinition[] = [
  { id: 'common', name: 'Baú Comum', icon: '📦', cost: 180, currency: 'coins', color: '#9ca3af', description: '80% comum, 18% rara, 2% épica.', chances: { common: 0.8, rare: 0.18, epic: 0.02 } },
  { id: 'rare', name: 'Baú Raro', icon: '💼', cost: 1, currency: 'keys', color: '#00aaff', description: '45% comum, 45% rara, 9% épica, 1% lendária.', chances: { common: 0.45, rare: 0.45, epic: 0.09, legendary: 0.01 } },
  { id: 'epic', name: 'Baú Épico', icon: '🏆', cost: 120, currency: 'gems', color: '#b000ff', description: '55% rara, 35% épica, 9.5% lendária, 0.5% Ultimate.', chances: { rare: 0.55, epic: 0.35, legendary: 0.095, ultimate: 0.005 } },
  { id: 'legendary', name: 'Baú Lendário', icon: '💎', cost: 1, currency: 'legendaryKeys', color: '#ffd700', description: '65% épica, 33% lendária, 2% Ultimate.', chances: { epic: 0.65, legendary: 0.33, ultimate: 0.02 } },
];

const rarityOrder: SkinRarity[] = ['common', 'rare', 'epic', 'legendary', 'mythic', 'ultimate'];

const pickRarity = (chest: ChestDefinition): SkinRarity => {
  const roll = Math.random();
  let acc = 0;
  for (const rarity of rarityOrder) {
    acc += chest.chances[rarity] || 0;
    if (roll <= acc) return rarity;
  }
  return chest.id === 'common' ? 'common' : chest.id === 'rare' ? 'rare' : chest.id === 'epic' ? 'epic' : 'legendary';
};

export const rollChestReward = (chest: ChestDefinition, unlockedSkins: string[]): ChestReward => {
  const rarity = pickRarity(chest);
  const utilityRoll = Math.random();

  if (utilityRoll < 0.1) {
    const amount = rarity === 'legendary' || rarity === 'mythic' || rarity === 'ultimate' ? 2 : 1;
    return { type: 'key', label: rarity === 'mythic' ? 'Chave Lendária' : 'Chave', icon: '🔑', rarity, amount };
  }

  if (utilityRoll < 0.2) {
    const itemType = utilityRoll < 0.23 ? 'trail' : utilityRoll < 0.285 ? 'aura' : 'effect';
    return {
      type: itemType,
      label: itemType === 'trail' ? `Trail ${rarity}` : itemType === 'aura' ? `Aura ${rarity}` : `Efeito ${rarity}`,
      icon: itemType === 'trail' ? '✨' : itemType === 'aura' ? '🌀' : '💥',
      rarity,
      amount: 1,
    };
  }

  const candidates = SKINS.filter(skin => skin.rarity === rarity && !skin.exclusive);
  const skin = candidates[Math.floor(Math.random() * candidates.length)] || SKINS[0];
  const isDuplicate = unlockedSkins.includes(skin.id);

  if (isDuplicate) {
    const amount = rarity === 'common' ? 8 : rarity === 'rare' ? 12 : rarity === 'epic' ? 22 : rarity === 'legendary' ? 36 : rarity === 'ultimate' ? 90 : 48;
    return {
      type: 'fragments',
      label: `Fragmentos: ${skin.name}`,
      icon: skin.icon,
      rarity,
      skinId: skin.id,
      amount,
      isDuplicate: true,
    };
  }

  return {
    type: 'skin',
    label: skin.name,
    icon: skin.icon,
    rarity,
    skinId: skin.id,
    amount: 1,
  };
};

export const getChestById = (id: ChestType) => CHESTS.find(chest => chest.id === id) || CHESTS[0];

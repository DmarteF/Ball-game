export type StoreProductId =
  | 'diamonds_small'
  | 'diamonds_medium'
  | 'diamonds_large'
  | 'daily_offer'
  | 'starter_pack'
  | 'skin_pack'
  | 'fragment_pack'
  | 'event_pack'
  | 'chest_pack';

export type StoreProductRewards = {
  gems?: number;
  coins?: number;
  keys?: number;
  legendaryKeys?: number;
  profileXp?: number;
  rareChests?: number;
  epicChests?: number;
  rareChestsToOpen?: number;
  commonChestsToOpen?: number;
  epicChestsToOpen?: number;
  equippedSkinFragments?: number;
};

export type StoreProductConfig = {
  id: StoreProductId;
  title: string;
  description: string;
  fallbackPrice: string;
  rewards: StoreProductRewards;
};

export const STORE_PRODUCTS: Record<StoreProductId, StoreProductConfig> = {
  diamonds_small: {
    id: 'diamonds_small',
    title: 'Pacote Pequeno de Diamantes',
    description: 'Receba 140 diamantes para usar em upgrades, baús, trocas de opções e recompensas dentro do Neon Idle Escape.',
    fallbackPrice: '1.99',
    rewards: { gems: 140 },
  },
  diamonds_medium: {
    id: 'diamonds_medium',
    title: 'Pacote Médio de Diamantes',
    description: 'Receba 480 diamantes para acelerar seu progresso, abrir baús, trocar opções e aproveitar melhor os modos do Neon Idle Escape.',
    fallbackPrice: '4.99',
    rewards: { gems: 480 },
  },
  diamonds_large: {
    id: 'diamonds_large',
    title: 'Pacote Grande de Diamantes',
    description: 'Receba 1.350 diamantes para desbloquear mais opções, recompensas, baús e vantagens dentro do Neon Idle Escape.',
    fallbackPrice: '9.99',
    rewards: { gems: 1350 },
  },
  daily_offer: {
    id: 'daily_offer',
    title: 'Oferta Diária',
    description: 'Pacote especial diário com 90 diamantes, 2 chaves e XP para ajudar no seu progresso.',
    fallbackPrice: '2.99',
    rewards: { gems: 90, keys: 2, profileXp: 180 },
  },
  starter_pack: {
    id: 'starter_pack',
    title: 'Pacote Inicial',
    description: 'Comece melhor no Neon Idle Escape com 260 diamantes, 2.500 moedas, 5 chaves e 1 chave lendária.',
    fallbackPrice: '4.99',
    rewards: { gems: 260, coins: 2500, keys: 5, legendaryKeys: 1 },
  },
  skin_pack: {
    id: 'skin_pack',
    title: 'Pacote de Skins',
    description: 'Receba 2 baús raros e 2 baús épicos para tentar desbloquear skins, fragmentos e recompensas especiais.',
    fallbackPrice: '5.99',
    rewards: { rareChestsToOpen: 2, epicChestsToOpen: 2 },
  },
  fragment_pack: {
    id: 'fragment_pack',
    title: 'Pacote de Fragmentos',
    description: 'Receba 130 fragmentos para avançar no desbloqueio e evolução da skin equipada.',
    fallbackPrice: '3.99',
    rewards: { equippedSkinFragments: 130 },
  },
  event_pack: {
    id: 'event_pack',
    title: 'Pacote de Evento',
    description: 'Receba 1 baú épico, 90 diamantes, 2 chaves e 420 XP para aproveitar melhor os eventos e desafios do jogo.',
    fallbackPrice: '4.99',
    rewards: { epicChests: 1, gems: 90, keys: 2, profileXp: 420 },
  },
  chest_pack: {
    id: 'chest_pack',
    title: 'Pacote de Baús',
    description: 'Receba 3 baús comuns, 2 baús raros e 1 baú épico com chances de moedas, diamantes, fragmentos, skins e outras recompensas.',
    fallbackPrice: '6.99',
    rewards: { commonChestsToOpen: 3, rareChestsToOpen: 2, epicChestsToOpen: 1 },
  },
};

export const STORE_PRODUCT_IDS = Object.keys(STORE_PRODUCTS) as StoreProductId[];

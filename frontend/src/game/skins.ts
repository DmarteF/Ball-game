export type SkinRarity = 'common' | 'rare' | 'epic' | 'legendary' | 'mythic' | 'ultimate';
export type SkinPassiveType =
  | 'coin_on_hit'
  | 'crit_chance'
  | 'coin_multiplier'
  | 'xp_multiplier'
  | 'damage_multiplier'
  | 'speed'
  | 'slime_bounce'
  | 'phase_solid'
  | 'slow_ring'
  | 'repel_ring'
  | 'mega_crit'
  | 'area_damage'
  | 'chain_damage'
  | 'freeze_ring'
  | 'burn'
  | 'perfect_chance'
  | 'cosmic_critical'
  | 'league_starter_champion'
  | 'league_king_wave';

export interface SkinDefinition {
  id: string;
  name: string;
  rarity: SkinRarity;
  description: string;
  icon: string;
  primaryColor: string;
  secondaryColor: string;
  trail: string;
  impactEffect: string;
  passive: { type: SkinPassiveType; chance?: number; value: number; durationMs?: number };
  fragmentsRequired: number;
  exclusive?: boolean;
}

export function getSkinEvolutionCost(rarity: SkinRarity, nextLevel: number) {
  const table: Record<SkinRarity, number[]> = {
    common: [10, 20, 40, 80],
    rare: [15, 30, 60, 120],
    epic: [25, 50, 100, 200],
    legendary: [40, 80, 160, 320],
    mythic: [60, 120, 240, 480],
    ultimate: [100, 200, 400, 800],
  };
  return table[rarity][Math.max(0, Math.min(3, nextLevel - 1))] || table[rarity][3];
}

const skin = (
  id: string,
  name: string,
  rarity: SkinRarity,
  icon: string,
  primaryColor: string,
  secondaryColor: string,
  description: string,
  passive: SkinDefinition['passive'],
  trail = 'Neon',
  impactEffect = 'Pulso'
): SkinDefinition => ({
  id,
  name,
  rarity,
  icon,
  primaryColor,
  secondaryColor,
  description,
  passive,
  trail,
  impactEffect,
  fragmentsRequired: getSkinEvolutionCost(rarity, 1),
});

export const SKINS: SkinDefinition[] = [
  skin('neon_blue', 'Neon Azul', 'common', '🔵', '#00f0ff', '#0088ff', 'Esfera inicial equilibrada.', { type: 'perfect_chance', value: 0.005 }),
  skin('puppy', 'Cachorrinho', 'common', '🐶', '#ffcc88', '#8a5a32', 'Chance de moedas extras no impacto.', { type: 'coin_on_hit', chance: 0.18, value: 4 }, 'Patinhas', 'Moedas'),
  skin('kitty', 'Gatinho', 'common', '🐱', '#ff99cc', '#ffeeaa', 'Aumenta chance crítica.', { type: 'crit_chance', value: 4 }, 'Arranhão', 'Crítico'),
  skin('piggy', 'Porquinho', 'common', '🐷', '#ff86aa', '#ffd1dc', 'Aumenta moedas ganhas.', { type: 'coin_multiplier', value: 0.12 }, 'Moedas', 'Cofrinho'),
  skin('bunny', 'Coelho', 'common', '🐰', '#ffffff', '#a7f3ff', 'Aumenta velocidade da bolinha.', { type: 'speed', value: 0.08 }, 'Saltos', 'Estalo'),
  skin('slime', 'Slime', 'common', '🟢', '#3dff8f', '#00995a', 'Chance de ricochete sem perder velocidade.', { type: 'slime_bounce', chance: 0.14, value: 0.14 }, 'Gosma', 'Quicar'),
  skin('ghost', 'Fantasma', 'common', '👻', '#dff7ff', '#8a7cff', 'Chance de atravessar parte sólida.', { type: 'phase_solid', chance: 0.06, value: 1 }, 'Névoa', 'Fase'),
  skin('chick', 'Pintinho', 'common', '🐥', '#ffe66d', '#ffb703', 'Moedas extras em quebras rápidas.', { type: 'coin_on_hit', chance: 0.16, value: 5 }, 'Plumas', 'Piu neon'),
  skin('frog', 'Sapo', 'common', '🐸', '#7cff6b', '#0f8f45', 'Pequeno bônus de ricochete.', { type: 'slime_bounce', chance: 0.12, value: 0.12 }, 'Pulos', 'Salto'),
  skin('monkey', 'Macaquinho', 'common', '🐵', '#c08457', '#ffcf8a', 'Bônus leve de XP.', { type: 'xp_multiplier', value: 0.08 }, 'Faíscas', 'Combo'),
  skin('penguin', 'Pinguim', 'common', '🐧', '#111827', '#dff7ff', 'Pequena chance de desacelerar anéis.', { type: 'slow_ring', chance: 0.1, value: 0.75, durationMs: 1500 }, 'Gelo fino', 'Escorregar'),

  skin('robot', 'Robô', 'rare', '🤖', '#94a3b8', '#00f0ff', 'Calcula ricochetes eficientes.', { type: 'slime_bounce', chance: 0.15, value: 0.16 }, 'Circuito', 'Pulso digital'),
  skin('skull', 'Caveira', 'rare', '💀', '#f8fafc', '#ff0055', 'Chance de crítico pesado.', { type: 'mega_crit', chance: 0.08, value: 2.7 }, 'Ossos neon', 'Rachadura'),
  skin('fire', 'Fogo', 'rare', '🔥', '#ff6b00', '#ffdd55', 'Aplica dano contínuo.', { type: 'burn', chance: 0.17, value: 4, durationMs: 2600 }, 'Fagulhas', 'Burn'),
  skin('ice', 'Gelo', 'rare', '❄️', '#b8f3ff', '#3b82f6', 'Congela ou desacelera anéis.', { type: 'freeze_ring', chance: 0.16, value: 0.4, durationMs: 2200 }, 'Cristais', 'Gelo'),
  skin('lightning', 'Raio', 'rare', '⚡', '#faff00', '#00e5ff', 'Corrente elétrica atinge outro anel.', { type: 'chain_damage', chance: 0.15, value: 0.45 }, 'Raios', 'Corrente'),
  skin('star_rare', 'Estrela', 'rare', '⭐', '#fff7ad', '#ff8a00', 'Melhora perfect escapes.', { type: 'perfect_chance', value: 0.018 }, 'Estelar', 'Brilho'),
  skin('moon', 'Lua', 'rare', '🌙', '#e5e7eb', '#818cf8', 'Bônus leve de dano.', { type: 'damage_multiplier', value: 0.1 }, 'Luar', 'Meia-lua'),
  skin('planet', 'Planeta', 'rare', '🪐', '#34d399', '#fbbf24', 'Melhora moedas e perfects.', { type: 'perfect_chance', value: 0.02 }, 'Órbita', 'Anel orbital'),
  skin('crystal', 'Cristal', 'rare', '💎', '#67e8f9', '#a855f7', 'Bônus de gemas por perfect.', { type: 'perfect_chance', value: 0.025 }, 'Lapidação', 'Cristal'),
  skin('comet', 'Cometa', 'rare', '☄️', '#ff8a00', '#60a5fa', 'Mais velocidade e impacto.', { type: 'speed', value: 0.12 }, 'Cauda', 'Impacto'),

  skin('red_eye', 'Olho Carmesim', 'epic', '👁️', '#ff183f', '#111111', 'Pode desacelerar o anel atingido.', { type: 'slow_ring', chance: 0.2, value: 0.52, durationMs: 2600 }, 'Foco carmesim', 'Olhar lento'),
  skin('cosmic_eye', 'Olho Cósmico', 'epic', '🌌', '#7c3aed', '#22d3ee', 'Aumenta a chance de diamante por perfect.', { type: 'perfect_chance', value: 0.04 }, 'Galáxia', 'Constelação'),
  skin('tiny_dragon', 'Dragão Pequeno', 'epic', '🐉', '#22c55e', '#ff6b00', 'Chamas extras no impacto.', { type: 'burn', chance: 0.22, value: 5, durationMs: 3200 }, 'Escamas neon', 'Sopro flamejante'),
  skin('shadow_orb', 'Esfera Sombria', 'epic', '⚫', '#20113f', '#8b5cf6', 'Dano extra em impactos críticos.', { type: 'mega_crit', chance: 0.13, value: 3.2 }, 'Sombra', 'Vazio'),
  skin('solar_orb', 'Esfera Solar', 'epic', '☀️', '#fff176', '#ff4d00', 'Dano em área em explosões solares.', { type: 'area_damage', chance: 0.16, value: 0.48 }, 'Solar', 'Explosão'),
  skin('electric_core', 'Núcleo Elétrico', 'epic', '🔆', '#faff00', '#00e5ff', 'Corrente mais forte entre anéis.', { type: 'chain_damage', chance: 0.22, value: 0.6 }, 'Bobina', 'Descarga'),

  skin('ripple_eye', 'Olho Espiral Roxo', 'legendary', '🌀', '#b88cff', '#4c1d95', 'Pode repelir anéis para fora.', { type: 'repel_ring', chance: 0.2, value: 20 }, 'Ondas roxas', 'Repulsão'),
  skin('black_hole', 'Buraco Negro', 'legendary', '🕳️', '#0b0018', '#a855f7', 'Pode causar dano em área gravitacional.', { type: 'area_damage', chance: 0.22, value: 0.62 }, 'Gravidade', 'Singularidade'),
  skin('neon_phoenix', 'Fênix Neon', 'legendary', '🪽', '#ff4fd8', '#ffb000', 'Críticos queimam anéis próximos.', { type: 'burn', chance: 0.28, value: 7, durationMs: 3600 }, 'Plumas neon', 'Renascimento'),
  skin('astral_dragon', 'Dragão Astral', 'legendary', '🐲', '#22d3ee', '#7c3aed', 'Dano e XP superiores.', { type: 'damage_multiplier', value: 0.22 }, 'Astral', 'Sopro astral'),
  skin('ghost_king', 'Rei Fantasma', 'legendary', '👑', '#dff7ff', '#8a7cff', 'Atravessa sólidos com mais frequência.', { type: 'phase_solid', chance: 0.12, value: 1 }, 'Coroa espectral', 'Fase real'),
  skin('collapsed_star', 'Estrela Colapsada', 'legendary', '🌠', '#ffd700', '#7c2d12', 'Área crítica devastadora.', { type: 'area_damage', chance: 0.25, value: 0.72 }, 'Supernova', 'Colapso'),

  skin('living_singularity', 'Singularidade Viva', 'ultimate', '🕳️', '#050015', '#ff4fd8', 'Ultimate raríssima com dano gravitacional extremo.', { type: 'area_damage', chance: 0.32, value: 0.95 }, 'Horizonte vivo', 'Gravidade total'),
  skin('divine_core', 'Núcleo Divino', 'ultimate', '🔱', '#fff7ad', '#22d3ee', 'Ultimate com bônus de dano, XP e controle.', { type: 'cosmic_critical', chance: 0.22, value: 0.34 }, 'Aura divina', 'Julgamento'),
  {
    ...skin('cosmic_champion', 'Campeão Cósmico', 'ultimate', '🌟', '#ffd700', '#7c3aed', 'Exclusiva por concluir os 20 estágios. Aumenta dano, moedas, XP, diamantes e pode repelir anéis em crítico.', { type: 'cosmic_critical', chance: 0.28, value: 0.4 }, 'Aura cósmica dourada', 'Repulsão crítica'),
    exclusive: true,
  },
  {
    ...skin('initial_neon_champion', 'Campeão Neon Inicial', 'ultimate', '🏅', '#ffd700', '#00aaff', 'Ultimate exclusiva da primeira coroa na Liga Neon Bronze. Amplifica moedas, XP, combo e proteção.', { type: 'league_starter_champion', chance: 0.08, value: 0.24 }, 'Trilha de campeão', 'Escudo de ranking'),
    exclusive: true,
  },
  {
    ...skin('league_bronze_champion', 'Coroa Bronze Neon', 'legendary', '🥉', '#cd7f32', '#00f0ff', 'Skin exclusiva por terminar em primeiro na divisão Bronze da Liga Neon.', { type: 'coin_multiplier', value: 0.18 }, 'Bronze neon', 'Coroa inicial'),
    exclusive: true,
  },
  {
    ...skin('league_king_neon', 'Rei da Liga Neon', 'ultimate', '👑', '#ffd700', '#8b5cf6', 'Ultimate máxima de ranking. Aumenta dano, moedas, XP, perfect diamonds e libera onda em combo alto.', { type: 'league_king_wave', chance: 0.18, value: 0.38 }, 'Coroas estelares', 'Onda real'),
    exclusive: true,
  },
];

export const HIDDEN_RARITIES: SkinRarity[] = ['epic', 'legendary', 'mythic', 'ultimate'];

export const getSkinById = (id: string) => SKINS.find(skinItem => skinItem.id === id) || SKINS[0];

export const getSkinRarityColor = (rarity: SkinRarity) => {
  switch (rarity) {
    case 'common': return '#9ca3af';
    case 'rare': return '#00aaff';
    case 'epic': return '#b000ff';
    case 'legendary': return '#ffd700';
    case 'mythic': return '#ff4fd8';
    case 'ultimate': return '#ffffff';
    default: return '#ffffff';
  }
};

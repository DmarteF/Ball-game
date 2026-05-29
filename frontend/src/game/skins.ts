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

export type SkinSpecialEffectType =
  | 'basic'
  | 'coin'
  | 'critical'
  | 'burn'
  | 'freeze'
  | 'chain'
  | 'area'
  | 'phase'
  | 'repulse'
  | 'speed'
  | 'gravity'
  | 'ultimate';

export interface SkinSpecialEffect {
  id: string;
  type: SkinSpecialEffectType;
  label: string;
  description: string;
  chance?: number;
  value?: number;
  durationMs?: number;
  cooldownMs: number;
  maxTargets: number;
  visual: string;
  sound: string;
  minSkinLevel?: number;
}

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
  specialEffects: SkinSpecialEffect[];
  fragmentsRequired: number;
  exclusive?: boolean;
  origin?: string;
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
  specialEffects: createSkinSpecialEffects({ id, name, rarity, passive, trail, impactEffect }),
  trail,
  impactEffect,
  fragmentsRequired: getSkinEvolutionCost(rarity, 1),
});

const passiveEffectMap: Record<SkinPassiveType, Pick<SkinSpecialEffect, 'type' | 'label' | 'description' | 'maxTargets'>> = {
  coin_on_hit: { type: 'coin', label: 'Moedas', description: 'Pode soltar moedas extras no impacto.', maxTargets: 1 },
  crit_chance: { type: 'critical', label: 'Crítico', description: 'Aumenta chance de impacto crítico.', maxTargets: 1 },
  coin_multiplier: { type: 'coin', label: 'Tesouro', description: 'Amplifica moedas recebidas na rodada.', maxTargets: 1 },
  xp_multiplier: { type: 'basic', label: 'XP', description: 'Gera brilho de aprendizado e mais XP.', maxTargets: 1 },
  damage_multiplier: { type: 'critical', label: 'Impacto', description: 'Reforça o dano real da bolinha.', maxTargets: 1 },
  speed: { type: 'speed', label: 'Velocidade', description: 'Deixa a trilha mais rápida e agressiva.', maxTargets: 1 },
  slime_bounce: { type: 'basic', label: 'Ricochete', description: 'Pode recuperar impulso após bater.', maxTargets: 1 },
  phase_solid: { type: 'phase', label: 'Fase', description: 'Chance de atravessar parte sólida.', maxTargets: 1 },
  slow_ring: { type: 'freeze', label: 'Lentidão', description: 'Desacelera o anel atingido por pouco tempo.', maxTargets: 1 },
  repel_ring: { type: 'repulse', label: 'Repulsão', description: 'Empurra o anel perigoso para fora.', maxTargets: 1 },
  mega_crit: { type: 'critical', label: 'Mega Crítico', description: 'Pode causar impacto crítico pesado.', maxTargets: 1 },
  area_damage: { type: 'area', label: 'Área', description: 'Espalha dano controlado em anéis próximos.', maxTargets: 3 },
  chain_damage: { type: 'chain', label: 'Corrente', description: 'Encadeia dano para outro anel.', maxTargets: 2 },
  freeze_ring: { type: 'freeze', label: 'Congela', description: 'Congela ou desacelera anéis por curto tempo.', maxTargets: 1 },
  burn: { type: 'burn', label: 'Queima', description: 'Aplica dano contínuo temporário.', maxTargets: 1 },
  perfect_chance: { type: 'basic', label: 'Perfect', description: 'Melhora escapes perfeitos.', maxTargets: 1 },
  cosmic_critical: { type: 'gravity', label: 'Cósmico', description: 'Mistura crítico, bônus e pulso gravitacional.', maxTargets: 3 },
  league_starter_champion: { type: 'repulse', label: 'Campeão', description: 'Aura de ranking com proteção e bônus.', maxTargets: 2 },
  league_king_wave: { type: 'ultimate', label: 'Onda Real', description: 'Onda de campeão em combos altos.', maxTargets: 4 },
};

const rarityEffectPlan: Record<SkinRarity, { count: number; cooldown: number; labels: string[] }> = {
  common: { count: 1, cooldown: 3600, labels: ['Trilha'] },
  rare: { count: 1, cooldown: 3000, labels: ['Efeito Top'] },
  epic: { count: 2, cooldown: 2600, labels: ['Efeito Legal', 'Trilha'] },
  legendary: { count: 3, cooldown: 2200, labels: ['Efeito Legal', 'Trilha', 'Efeito Top'] },
  mythic: { count: 3, cooldown: 1900, labels: ['Efeito Legal', 'Efeito Top', 'Trilha'] },
  ultimate: { count: 4, cooldown: 1600, labels: ['Ultimate', 'Efeito Legal', 'Efeito Top', 'Efeito Muito Legal'] },
};

const createSkinSpecialEffects = (params: {
  id: string;
  name: string;
  rarity: SkinRarity;
  passive: SkinDefinition['passive'];
  trail: string;
  impactEffect: string;
}): SkinSpecialEffect[] => {
  const base = passiveEffectMap[params.passive.type];
  const plan = rarityEffectPlan[params.rarity];
  const chance = params.passive.chance ?? (params.rarity === 'common' ? 0.1 : params.rarity === 'rare' ? 0.14 : params.rarity === 'ultimate' ? 0.28 : 0.18);
  const effects: SkinSpecialEffect[] = [{
    id: `${params.id}_${base.type}`,
    type: base.type,
    label: base.label,
    description: base.description,
    chance,
    value: params.passive.value,
    durationMs: params.passive.durationMs,
    cooldownMs: plan.cooldown,
    maxTargets: base.maxTargets,
    visual: params.impactEffect,
    sound: base.type,
  }];

  while (effects.length < plan.count) {
    const index = effects.length;
    const label = plan.labels[index] || params.trail;
    effects.push({
      id: `${params.id}_extra_${index}`,
      type: index === 1 && params.rarity !== 'common' ? 'basic' : params.rarity === 'ultimate' ? 'ultimate' : base.type,
      label,
      description: `${label} próprio da skin ${params.name}.`,
      chance: Math.max(0.06, chance - index * 0.035),
      value: Math.max(0.04, (params.passive.value || 0.1) * (0.45 + index * 0.12)),
      durationMs: params.passive.durationMs,
      cooldownMs: plan.cooldown + index * 450,
      maxTargets: Math.min(4, Math.max(1, base.maxTargets + (params.rarity === 'ultimate' ? 1 : 0))),
      visual: index === 1 ? params.trail : params.impactEffect,
      sound: `${base.type}_${index}`,
      minSkinLevel: index >= 2 ? 2 : undefined,
    });
  }

  return effects;
};

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
  skin('hamster', 'Hamster', 'common', '🐹', '#d8a45f', '#fff0c2', 'Moedas extras em impactos rápidos.', { type: 'coin_on_hit', chance: 0.14, value: 5 }, 'Sementes neon', 'Rodinha'),
  skin('bear_common', 'Ursinho', 'common', '🐻', '#9b5f2e', '#ffd29a', 'Um pouco mais de dano.', { type: 'damage_multiplier', value: 0.06 }, 'Pelúcia', 'Patada'),
  skin('panda', 'Panda', 'common', '🐼', '#f8fafc', '#111827', 'Bônus leve de XP.', { type: 'xp_multiplier', value: 0.07 }, 'Bambu', 'Pancada'),
  skin('fox_common', 'Raposa', 'common', '🦊', '#ff8a00', '#fff3b0', 'Velocidade levemente maior.', { type: 'speed', value: 0.07 }, 'Cauda', 'Sprint'),
  skin('tiger_common', 'Tigre', 'common', '🐯', '#ffb000', '#111111', 'Pequeno bônus crítico.', { type: 'crit_chance', value: 3 }, 'Listras', 'Garra'),
  skin('cow_common', 'Vaquinha', 'common', '🐮', '#ffffff', '#64748b', 'Mais moedas ao final.', { type: 'coin_multiplier', value: 0.08 }, 'Sininho', 'Mugido'),
  skin('octopus_common', 'Polvo', 'common', '🐙', '#ff4fd8', '#7c3aed', 'Chance baixa de ricochete.', { type: 'slime_bounce', chance: 0.1, value: 0.12 }, 'Tentáculos', 'Tinta'),
  skin('fish_common', 'Peixinho', 'common', '🐟', '#60a5fa', '#00f0ff', 'Aumenta a velocidade.', { type: 'speed', value: 0.06 }, 'Bolhas', 'Nado'),
  skin('bee_common', 'Abelha', 'common', '🐝', '#ffd700', '#111827', 'Crítico leve.', { type: 'crit_chance', value: 3 }, 'Ferrão neon', 'Zumbido'),
  skin('ladybug_common', 'Joaninha', 'common', '🐞', '#ef4444', '#111827', 'Pequeno bônus de moedas.', { type: 'coin_multiplier', value: 0.07 }, 'Pontinhos', 'Sorte'),

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
  skin('wolf_rare', 'Lobo', 'rare', '🐺', '#94a3b8', '#38bdf8', 'Dano e crítico estáveis.', { type: 'damage_multiplier', value: 0.1 }, 'Uivo', 'Mordida'),
  skin('dragonling_rare', 'Dragãozinho', 'rare', '🐲', '#22c55e', '#ff8a00', 'Chance de queimar anéis.', { type: 'burn', chance: 0.15, value: 4, durationMs: 2400 }, 'Fumaça', 'Sopro'),
  skin('alien_rare', 'Alien', 'rare', '👽', '#a3ff12', '#00f0ff', 'Melhora perfect escapes.', { type: 'perfect_chance', value: 0.02 }, 'Órbita alien', 'Abdução'),
  skin('ninja_rare', 'Ninja', 'rare', '🥷', '#111827', '#7dd3fc', 'Mais velocidade e crítico.', { type: 'speed', value: 0.11 }, 'Sombras', 'Corte'),
  skin('wizard_rare', 'Mago', 'rare', '🧙', '#7c3aed', '#fbbf24', 'Chance de desacelerar anéis.', { type: 'slow_ring', chance: 0.12, value: 0.7, durationMs: 1800 }, 'Runas', 'Feitiço'),
  skin('satellite_rare', 'Satélite', 'rare', '🛰️', '#9ca3af', '#22d3ee', 'Corrente leve entre anéis.', { type: 'chain_damage', chance: 0.11, value: 0.32 }, 'Sinal', 'Laser orbital'),
  skin('meteor_rare', 'Meteoro', 'rare', '☄️', '#f97316', '#7f1d1d', 'Impacto mais forte.', { type: 'damage_multiplier', value: 0.12 }, 'Fogo espacial', 'Cratera'),
  skin('purple_crystal', 'Cristal Roxo', 'rare', '🔮', '#a855f7', '#22d3ee', 'Aumenta chance de diamante em perfect.', { type: 'perfect_chance', value: 0.026 }, 'Cristais', 'Oráculo'),
  skin('neon_heart', 'Coração Neon', 'rare', '💙', '#38bdf8', '#ec4899', 'Mais XP ao final.', { type: 'xp_multiplier', value: 0.12 }, 'Batimentos', 'Pulso'),
  skin('bomb_rare', 'Bomba', 'rare', '💣', '#111827', '#facc15', 'Chance de dano em área.', { type: 'area_damage', chance: 0.1, value: 0.34 }, 'Fumaça', 'Explosão'),

  skin('red_eye', 'Olho Carmesim', 'epic', '👁️', '#ff183f', '#111111', 'Pode desacelerar o anel atingido.', { type: 'slow_ring', chance: 0.2, value: 0.52, durationMs: 2600 }, 'Foco carmesim', 'Olhar lento'),
  skin('cosmic_eye', 'Olho Cósmico', 'epic', '🌌', '#7c3aed', '#22d3ee', 'Aumenta a chance de diamante por perfect.', { type: 'perfect_chance', value: 0.04 }, 'Galáxia', 'Constelação'),
  skin('tiny_dragon', 'Dragão Pequeno', 'epic', '🐉', '#22c55e', '#ff6b00', 'Chamas extras no impacto.', { type: 'burn', chance: 0.22, value: 5, durationMs: 3200 }, 'Escamas neon', 'Sopro flamejante'),
  skin('shadow_orb', 'Esfera Sombria', 'epic', '⚫', '#20113f', '#8b5cf6', 'Dano extra em impactos críticos.', { type: 'mega_crit', chance: 0.13, value: 3.2 }, 'Sombra', 'Vazio'),
  skin('solar_orb', 'Esfera Solar', 'epic', '☀️', '#fff176', '#ff4d00', 'Dano em área em explosões solares.', { type: 'area_damage', chance: 0.16, value: 0.48 }, 'Solar', 'Explosão'),
  skin('electric_core', 'Núcleo Elétrico', 'epic', '🔆', '#faff00', '#00e5ff', 'Corrente mais forte entre anéis.', { type: 'chain_damage', chance: 0.22, value: 0.6 }, 'Bobina', 'Descarga'),
  skin('astral_eye', 'Olho Astral', 'epic', '👁️', '#22d3ee', '#7c3aed', 'Perfects melhores e brilho astral.', { type: 'perfect_chance', value: 0.04 }, 'Olhar astral', 'Foco'),
  skin('living_plasma', 'Plasma Vivo', 'epic', '🧬', '#ff4fd8', '#00f0ff', 'Dano em cadeia orgânico.', { type: 'chain_damage', chance: 0.18, value: 0.52 }, 'Plasma', 'Mutação'),
  skin('radioactive_core', 'Núcleo Radioativo', 'epic', '☢️', '#39ff14', '#111827', 'Queima e enfraquece anéis.', { type: 'burn', chance: 0.2, value: 5, durationMs: 3300 }, 'Radiação', 'Contágio'),
  skin('blue_comet', 'Cometa Azul', 'epic', '☄️', '#60a5fa', '#00f0ff', 'Velocidade com dano superior.', { type: 'speed', value: 0.16 }, 'Cauda azul', 'Impacto azul'),
  skin('neon_spiral', 'Espiral Neon', 'epic', '🌀', '#00f0ff', '#ff4fd8', 'Desacelera anéis em espiral.', { type: 'slow_ring', chance: 0.18, value: 0.58, durationMs: 2400 }, 'Espiral', 'Turbilhão'),
  skin('flaming_skull', 'Caveira Flamejante', 'epic', '💀', '#ff4500', '#111827', 'Críticos queimam.', { type: 'mega_crit', chance: 0.12, value: 3 }, 'Chamas', 'Riso flamejante'),
  skin('orbital_blade', 'Lâmina Orbital', 'epic', '🗡️', '#c0f2ff', '#7c3aed', 'Cortes em cadeia.', { type: 'chain_damage', chance: 0.19, value: 0.5 }, 'Lâminas', 'Corte orbital'),
  skin('neon_dragon', 'Dragão Neon', 'epic', '🐉', '#00f0ff', '#ff00aa', 'Fogo neon em anéis resistentes.', { type: 'burn', chance: 0.24, value: 5, durationMs: 3200 }, 'Escamas neon', 'Sopro neon'),
  skin('ghost_mask', 'Máscara Fantasma', 'epic', '🎭', '#dff7ff', '#8b5cf6', 'Pode atravessar sólidos.', { type: 'phase_solid', chance: 0.09, value: 1 }, 'Máscara', 'Assombro'),
  skin('solar_guardian', 'Guardião Solar', 'epic', '🛡️', '#ffd700', '#ff4500', 'Dano em área solar.', { type: 'area_damage', chance: 0.18, value: 0.5 }, 'Escudo solar', 'Erupção'),

  skin('ripple_eye', 'Olho Espiral Roxo', 'legendary', '🌀', '#b88cff', '#4c1d95', 'Pode repelir anéis para fora.', { type: 'repel_ring', chance: 0.2, value: 20 }, 'Ondas roxas', 'Repulsão'),
  skin('black_hole', 'Buraco Negro', 'legendary', '🕳️', '#0b0018', '#a855f7', 'Pode causar dano em área gravitacional.', { type: 'area_damage', chance: 0.22, value: 0.62 }, 'Gravidade', 'Singularidade'),
  skin('neon_phoenix', 'Fênix Neon', 'legendary', '🪽', '#ff4fd8', '#ffb000', 'Críticos queimam anéis próximos.', { type: 'burn', chance: 0.28, value: 7, durationMs: 3600 }, 'Plumas neon', 'Renascimento'),
  skin('astral_dragon', 'Dragão Astral', 'legendary', '🐲', '#22d3ee', '#7c3aed', 'Dano e XP superiores.', { type: 'damage_multiplier', value: 0.22 }, 'Astral', 'Sopro astral'),
  skin('ghost_king', 'Rei Fantasma', 'legendary', '👑', '#dff7ff', '#8a7cff', 'Atravessa sólidos com mais frequência.', { type: 'phase_solid', chance: 0.12, value: 1 }, 'Coroa espectral', 'Fase real'),
  skin('collapsed_star', 'Estrela Colapsada', 'legendary', '🌠', '#ffd700', '#7c2d12', 'Área crítica devastadora.', { type: 'area_damage', chance: 0.25, value: 0.72 }, 'Supernova', 'Colapso'),
  skin('black_sun', 'Sol Negro', 'legendary', '☀️', '#050505', '#ff4fd8', 'Gravidade e dano em área.', { type: 'area_damage', chance: 0.24, value: 0.7 }, 'Eclipse', 'Corona negra'),
  skin('cosmic_emperor', 'Imperador Cósmico', 'legendary', '🤴', '#ffd700', '#7c3aed', 'Dano e moedas de elite.', { type: 'coin_multiplier', value: 0.24 }, 'Manto cósmico', 'Decreto'),
  skin('galactic_phoenix', 'Fênix Galáctica', 'legendary', '🔥', '#ff4fd8', '#ffd700', 'Queima anéis próximos.', { type: 'burn', chance: 0.3, value: 7, durationMs: 3800 }, 'Plumas galácticas', 'Renascimento'),
  skin('void_dragon', 'Dragão do Vazio', 'legendary', '🐉', '#111827', '#8b5cf6', 'Crítico cósmico poderoso.', { type: 'cosmic_critical', chance: 0.18, value: 0.28 }, 'Vazio', 'Sopro vazio'),
  skin('star_king', 'Rei das Estrelas', 'legendary', '🌟', '#fff7ad', '#38bdf8', 'Mais XP e perfects.', { type: 'xp_multiplier', value: 0.22 }, 'Constelação real', 'Estrela guia'),
  skin('plasma_heart', 'Coração de Plasma', 'legendary', '💜', '#ff4fd8', '#00f0ff', 'Pulsos de área.', { type: 'area_damage', chance: 0.23, value: 0.68 }, 'Batimento plasma', 'Pulso'),
  skin('celestial_core', 'Núcleo Celestial', 'legendary', '🔱', '#fef3c7', '#22d3ee', 'Dano e controle celeste.', { type: 'slow_ring', chance: 0.22, value: 0.48, durationMs: 2800 }, 'Aura celestial', 'Julgamento'),
  skin('ring_devourer', 'Devorador de Anéis', 'legendary', '🕳️', '#0f172a', '#f97316', 'Dano forte contra anéis externos.', { type: 'damage_multiplier', value: 0.25 }, 'Fome orbital', 'Devorar'),
  skin('dimensional_guardian', 'Guardião Dimensional', 'legendary', '🛡️', '#a855f7', '#22d3ee', 'Repulsa anéis perigosos.', { type: 'repel_ring', chance: 0.21, value: 24 }, 'Dimensão', 'Barreira'),
  skin('astral_crown', 'Coroa Astral', 'legendary', '👑', '#ffd700', '#a855f7', 'Críticos e XP melhores.', { type: 'crit_chance', value: 9 }, 'Coroa astral', 'Realeza'),

  { ...skin('infinite_pulse', 'Pulso Infinito', 'common', '∞', '#00ff88', '#00f0ff', 'Recompensa por sobreviver 1 minuto no Infinito. Melhora moedas.', { type: 'coin_multiplier', value: 0.08 }, 'Pulso infinito', 'Eco'), exclusive: true, origin: 'Modo Infinito: sobreviva 1 minuto' },
  { ...skin('blue_vortex', 'Vórtice Azul', 'common', '🌀', '#38bdf8', '#1d4ed8', 'Recompensa por quebrar 25 anéis no Infinito. Melhora velocidade.', { type: 'speed', value: 0.06 }, 'Vórtice', 'Giro'), exclusive: true, origin: 'Modo Infinito: quebre 25 anéis' },
  { ...skin('loop_flame', 'Chama de Loop', 'rare', '🔥', '#ff6b00', '#ffd166', 'Recompensa por sobreviver 3 minutos no Infinito. Queima anéis.', { type: 'burn', chance: 0.14, value: 4, durationMs: 2400 }, 'Chama circular', 'Loop ardente'), exclusive: true, origin: 'Modo Infinito: sobreviva 3 minutos' },
  { ...skin('red_comet', 'Cometa Rubro', 'rare', '☄️', '#ef4444', '#f97316', 'Recompensa por quebrar 50 anéis no Infinito. Aumenta dano.', { type: 'damage_multiplier', value: 0.11 }, 'Cauda rubra', 'Impacto rubro'), exclusive: true, origin: 'Modo Infinito: quebre 50 anéis' },
  { ...skin('neon_eclipse', 'Eclipse Neon', 'epic', '🌘', '#7c3aed', '#00f0ff', 'Recompensa por sobreviver 5 minutos no Infinito. Melhora perfects.', { type: 'perfect_chance', value: 0.04 }, 'Eclipse', 'Sombra neon'), exclusive: true, origin: 'Modo Infinito: sobreviva 5 minutos' },
  { ...skin('endless_prism', 'Prisma Sem Fim', 'epic', '🔷', '#22d3ee', '#ff4fd8', 'Recompensa por quebrar 100 anéis no Infinito. Aumenta XP.', { type: 'xp_multiplier', value: 0.18 }, 'Prisma', 'Refração'), exclusive: true, origin: 'Modo Infinito: quebre 100 anéis' },
  { ...skin('cosmic_fragment', 'Fragmento Cósmico', 'legendary', '💠', '#a855f7', '#facc15', 'Recompensa por sobreviver 10 minutos no Infinito. Aumenta dano.', { type: 'damage_multiplier', value: 0.23 }, 'Fragmentos', 'Ruptura cósmica'), exclusive: true, origin: 'Modo Infinito: sobreviva 10 minutos' },
  { ...skin('eternal_core', 'Núcleo Eterno', 'legendary', '🔆', '#00f0ff', '#ffd700', 'Recompensa por completar 5 desafios no Infinito. Melhora moedas.', { type: 'coin_multiplier', value: 0.24 }, 'Núcleo eterno', 'Pulso eterno'), exclusive: true, origin: 'Modo Infinito: complete 5 desafios' },
  { ...skin('infinite_vortex_mythic', 'Vórtice Infinito', 'mythic', '🌀', '#ff4fd8', '#00f0ff', 'Recompensa por sobreviver 15 minutos no Infinito. Dano e XP elevados.', { type: 'cosmic_critical', chance: 0.16, value: 0.28 }, 'Espiral mítica', 'Colapso'), exclusive: true, origin: 'Modo Infinito: sobreviva 15 minutos' },
  { ...skin('chrono_loop_mythic', 'Loop Cronal', 'mythic', '⏳', '#f59e0b', '#8b5cf6', 'Recompensa por completar 10 desafios no Infinito. Controla anéis.', { type: 'slow_ring', chance: 0.23, value: 0.46, durationMs: 3000 }, 'Tempo quebrado', 'Crono pulso'), exclusive: true, origin: 'Modo Infinito: complete 10 desafios' },
  { ...skin('omega_infinity', 'Ômega Infinito', 'ultimate', '♾️', '#ffffff', '#00ff88', 'Recompensa por sobreviver 20 minutos no Infinito. Bônus completo.', { type: 'cosmic_critical', chance: 0.24, value: 0.38 }, 'Ômega', 'Ressonância final'), exclusive: true, origin: 'Modo Infinito: sobreviva 20 minutos' },
  { ...skin('singularity_crown', 'Coroa da Singularidade', 'ultimate', '👑', '#020617', '#ffd700', 'Recompensa por quebrar 300 anéis no Infinito. Área extrema.', { type: 'area_damage', chance: 0.32, value: 0.98 }, 'Coroa singular', 'Gravidade real'), exclusive: true, origin: 'Modo Infinito: quebre 300 anéis' },

  skin('living_singularity', 'Singularidade Viva', 'ultimate', '🕳️', '#050015', '#ff4fd8', 'Ultimate raríssima com dano gravitacional extremo.', { type: 'area_damage', chance: 0.32, value: 0.95 }, 'Horizonte vivo', 'Gravidade total'),
  skin('divine_core', 'Núcleo Divino', 'ultimate', '🔱', '#fff7ad', '#22d3ee', 'Ultimate com bônus de dano, XP e controle.', { type: 'cosmic_critical', chance: 0.22, value: 0.34 }, 'Aura divina', 'Julgamento'),
  skin('void_devourer_ultimate', 'Devorador do Vazio', 'ultimate', '🌑', '#020617', '#8b5cf6', 'Ultimate oculta que devora anéis com ondas gravitacionais.', { type: 'area_damage', chance: 0.34, value: 1.02 }, 'Abismo', 'Devorar vazio'),
  {
    ...skin('cosmic_champion', 'Campeão Cósmico', 'ultimate', '🌟', '#ffd700', '#7c3aed', 'Exclusiva por concluir os 50 estágios. Aumenta dano, moedas, XP, diamantes e pode repelir anéis em crítico.', { type: 'cosmic_critical', chance: 0.28, value: 0.4 }, 'Aura cósmica dourada', 'Repulsão crítica'),
    exclusive: true,
    origin: 'Conclusão das fases principais',
  },
  {
    ...skin('initial_neon_champion', 'Campeão Neon Inicial', 'ultimate', '🏅', '#ffd700', '#00aaff', 'Ultimate exclusiva da primeira coroa na Liga Neon Bronze. Amplifica moedas, XP, combo e proteção.', { type: 'league_starter_champion', chance: 0.08, value: 0.24 }, 'Trilha de campeão', 'Escudo de ranking'),
    exclusive: true,
    origin: 'Primeira temporada #1 na divisão Bronze da Liga Neon',
  },
  {
    ...skin('league_bronze_champion', 'Coroa Bronze Neon', 'legendary', '🥉', '#cd7f32', '#00f0ff', 'Skin exclusiva por terminar em primeiro na divisão Bronze da Liga Neon.', { type: 'coin_multiplier', value: 0.18 }, 'Bronze neon', 'Coroa inicial'),
    exclusive: true,
    origin: 'Primeiro lugar mensal na Liga Neon Bronze',
  },
  {
    ...skin('league_king_neon', 'Rei da Liga Neon', 'ultimate', '👑', '#ffd700', '#8b5cf6', 'Ultimate máxima de ranking. Aumenta dano, moedas, XP, perfect diamonds e libera onda em combo alto.', { type: 'league_king_wave', chance: 0.18, value: 0.38 }, 'Coroas estelares', 'Onda real'),
    exclusive: true,
    origin: 'Primeiro lugar mensal na Liga Neon Ultimate',
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

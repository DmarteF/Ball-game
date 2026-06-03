extends Node

# Dados mecanicamente portados da branch main (frontend/src/game).

const SKINS := [
	{ "id": "neon_blue", "name": "Neon Azul", "rarity": "common", "primary": "#00f0ff", "secondary": "#0088ff", "desc": "Esfera inicial equilibrada.", "passive": { "type": "perfect_chance", "value": 0.005 }, "trail": "Trail", "impact": "Impacto" },
	{ "id": "puppy", "name": "Cachorrinho", "rarity": "common", "primary": "#ffcc88", "secondary": "#8a5a32", "desc": "Chance de moedas extras no impacto.", "passive": { "type": "coin_on_hit", "chance": 0.18, "value": 4 }, "trail": "Patinhas", "impact": "Moedas" },
	{ "id": "kitty", "name": "Gatinho", "rarity": "common", "primary": "#ff99cc", "secondary": "#ffeeaa", "desc": "Aumenta chance crítica.", "passive": { "type": "crit_chance", "value": 4 }, "trail": "Arranhão", "impact": "Crítico" },
	{ "id": "piggy", "name": "Porquinho", "rarity": "common", "primary": "#ff86aa", "secondary": "#ffd1dc", "desc": "Aumenta moedas ganhas.", "passive": { "type": "coin_multiplier", "value": 0.12 }, "trail": "Moedas", "impact": "Cofrinho" },
	{ "id": "bunny", "name": "Coelho", "rarity": "common", "primary": "#ffffff", "secondary": "#a7f3ff", "desc": "Aumenta velocidade da bolinha.", "passive": { "type": "speed", "value": 0.08 }, "trail": "Saltos", "impact": "Estalo" },
	{ "id": "slime", "name": "Slime", "rarity": "common", "primary": "#3dff8f", "secondary": "#00995a", "desc": "Chance de ricochete sem perder velocidade.", "passive": { "type": "slime_bounce", "chance": 0.14, "value": 0.14 }, "trail": "Gosma", "impact": "Quicar" },
	{ "id": "ghost", "name": "Fantasma", "rarity": "common", "primary": "#dff7ff", "secondary": "#8a7cff", "desc": "Chance de atravessar parte sólida.", "passive": { "type": "phase_solid", "chance": 0.06, "value": 1 }, "trail": "Névoa", "impact": "Fase" },
	{ "id": "chick", "name": "Pintinho", "rarity": "common", "primary": "#ffe66d", "secondary": "#ffb703", "desc": "Moedas extras em quebras rápidas.", "passive": { "type": "coin_on_hit", "chance": 0.16, "value": 5 }, "trail": "Plumas", "impact": "Piu neon" },
	{ "id": "frog", "name": "Sapo", "rarity": "common", "primary": "#7cff6b", "secondary": "#0f8f45", "desc": "Pequeno bônus de ricochete.", "passive": { "type": "slime_bounce", "chance": 0.12, "value": 0.12 }, "trail": "Pulos", "impact": "Salto" },
	{ "id": "monkey", "name": "Macaquinho", "rarity": "common", "primary": "#c08457", "secondary": "#ffcf8a", "desc": "Bônus leve de XP.", "passive": { "type": "xp_multiplier", "value": 0.08 }, "trail": "Faíscas", "impact": "Combo" },
	{ "id": "penguin", "name": "Pinguim", "rarity": "common", "primary": "#111827", "secondary": "#dff7ff", "desc": "Pequena chance de desacelerar anéis.", "passive": { "type": "slow_ring", "chance": 0.1, "value": 0.75, "durationMs": 1500 }, "trail": "Gelo fino", "impact": "Escorregar" },
	{ "id": "hamster", "name": "Hamster", "rarity": "common", "primary": "#d8a45f", "secondary": "#fff0c2", "desc": "Moedas extras em impactos rápidos.", "passive": { "type": "coin_on_hit", "chance": 0.14, "value": 5 }, "trail": "Sementes neon", "impact": "Rodinha" },
	{ "id": "bear_common", "name": "Ursinho", "rarity": "common", "primary": "#9b5f2e", "secondary": "#ffd29a", "desc": "Um pouco mais de dano.", "passive": { "type": "damage_multiplier", "value": 0.06 }, "trail": "Pelúcia", "impact": "Patada" },
	{ "id": "panda", "name": "Panda", "rarity": "common", "primary": "#f8fafc", "secondary": "#111827", "desc": "Bônus leve de XP.", "passive": { "type": "xp_multiplier", "value": 0.07 }, "trail": "Bambu", "impact": "Pancada" },
	{ "id": "fox_common", "name": "Raposa", "rarity": "common", "primary": "#ff8a00", "secondary": "#fff3b0", "desc": "Velocidade levemente maior.", "passive": { "type": "speed", "value": 0.07 }, "trail": "Cauda", "impact": "Sprint" },
	{ "id": "tiger_common", "name": "Tigre", "rarity": "common", "primary": "#ffb000", "secondary": "#111111", "desc": "Pequeno bônus crítico.", "passive": { "type": "crit_chance", "value": 3 }, "trail": "Listras", "impact": "Garra" },
	{ "id": "cow_common", "name": "Vaquinha", "rarity": "common", "primary": "#ffffff", "secondary": "#64748b", "desc": "Mais moedas ao final.", "passive": { "type": "coin_multiplier", "value": 0.08 }, "trail": "Sininho", "impact": "Mugido" },
	{ "id": "octopus_common", "name": "Polvo", "rarity": "common", "primary": "#ff4fd8", "secondary": "#7c3aed", "desc": "Chance baixa de ricochete.", "passive": { "type": "slime_bounce", "chance": 0.1, "value": 0.12 }, "trail": "Tentáculos", "impact": "Tinta" },
	{ "id": "fish_common", "name": "Peixinho", "rarity": "common", "primary": "#60a5fa", "secondary": "#00f0ff", "desc": "Aumenta a velocidade.", "passive": { "type": "speed", "value": 0.06 }, "trail": "Bolhas", "impact": "Nado" },
	{ "id": "bee_common", "name": "Abelha", "rarity": "common", "primary": "#ffd700", "secondary": "#111827", "desc": "Crítico leve.", "passive": { "type": "crit_chance", "value": 3 }, "trail": "Ferrão neon", "impact": "Zumbido" },
	{ "id": "ladybug_common", "name": "Joaninha", "rarity": "common", "primary": "#ef4444", "secondary": "#111827", "desc": "Pequeno bônus de moedas.", "passive": { "type": "coin_multiplier", "value": 0.07 }, "trail": "Pontinhos", "impact": "Sorte" },
	{ "id": "robot", "name": "Robô", "rarity": "rare", "primary": "#94a3b8", "secondary": "#00f0ff", "desc": "Calcula ricochetes eficientes.", "passive": { "type": "slime_bounce", "chance": 0.15, "value": 0.16 }, "trail": "Circuito", "impact": "Pulso digital" },
	{ "id": "skull", "name": "Caveira", "rarity": "rare", "primary": "#f8fafc", "secondary": "#ff0055", "desc": "Chance de crítico pesado.", "passive": { "type": "mega_crit", "chance": 0.08, "value": 2.7 }, "trail": "Ossos neon", "impact": "Rachadura" },
	{ "id": "fire", "name": "Fogo", "rarity": "rare", "primary": "#ff6b00", "secondary": "#ffdd55", "desc": "Aplica dano contínuo.", "passive": { "type": "burn", "chance": 0.17, "value": 4, "durationMs": 2600 }, "trail": "Fagulhas", "impact": "Burn" },
	{ "id": "ice", "name": "Gelo", "rarity": "rare", "primary": "#b8f3ff", "secondary": "#3b82f6", "desc": "Congela ou desacelera anéis.", "passive": { "type": "freeze_ring", "chance": 0.16, "value": 0.4, "durationMs": 2200 }, "trail": "Cristais", "impact": "Gelo" },
	{ "id": "lightning", "name": "Raio", "rarity": "rare", "primary": "#faff00", "secondary": "#00e5ff", "desc": "Corrente elétrica atinge outro anel.", "passive": { "type": "chain_damage", "chance": 0.15, "value": 0.45 }, "trail": "Raios", "impact": "Corrente" },
	{ "id": "star_rare", "name": "Estrela", "rarity": "rare", "primary": "#fff7ad", "secondary": "#ff8a00", "desc": "Melhora perfect escapes.", "passive": { "type": "perfect_chance", "value": 0.018 }, "trail": "Estelar", "impact": "Brilho" },
	{ "id": "moon", "name": "Lua", "rarity": "rare", "primary": "#e5e7eb", "secondary": "#818cf8", "desc": "Bônus leve de dano.", "passive": { "type": "damage_multiplier", "value": 0.1 }, "trail": "Luar", "impact": "Meia-lua" },
	{ "id": "planet", "name": "Planeta", "rarity": "rare", "primary": "#34d399", "secondary": "#fbbf24", "desc": "Melhora moedas e perfects.", "passive": { "type": "perfect_chance", "value": 0.02 }, "trail": "Órbita", "impact": "Anel orbital" },
	{ "id": "crystal", "name": "Cristal", "rarity": "rare", "primary": "#67e8f9", "secondary": "#a855f7", "desc": "Bônus de gemas por perfect.", "passive": { "type": "perfect_chance", "value": 0.025 }, "trail": "Lapidação", "impact": "Cristal" },
	{ "id": "comet", "name": "Cometa", "rarity": "rare", "primary": "#ff8a00", "secondary": "#60a5fa", "desc": "Mais velocidade e impacto.", "passive": { "type": "speed", "value": 0.12 }, "trail": "Cauda", "impact": "Impacto" },
	{ "id": "wolf_rare", "name": "Lobo", "rarity": "rare", "primary": "#94a3b8", "secondary": "#38bdf8", "desc": "Dano e crítico estáveis.", "passive": { "type": "damage_multiplier", "value": 0.1 }, "trail": "Uivo", "impact": "Mordida" },
	{ "id": "dragonling_rare", "name": "Dragãozinho", "rarity": "rare", "primary": "#22c55e", "secondary": "#ff8a00", "desc": "Chance de queimar anéis.", "passive": { "type": "burn", "chance": 0.15, "value": 4, "durationMs": 2400 }, "trail": "Fumaça", "impact": "Sopro" },
	{ "id": "alien_rare", "name": "Alien", "rarity": "rare", "primary": "#a3ff12", "secondary": "#00f0ff", "desc": "Melhora perfect escapes.", "passive": { "type": "perfect_chance", "value": 0.02 }, "trail": "Órbita alien", "impact": "Abdução" },
	{ "id": "ninja_rare", "name": "Ninja", "rarity": "rare", "primary": "#111827", "secondary": "#7dd3fc", "desc": "Mais velocidade e crítico.", "passive": { "type": "speed", "value": 0.11 }, "trail": "Sombras", "impact": "Corte" },
	{ "id": "wizard_rare", "name": "Mago", "rarity": "rare", "primary": "#7c3aed", "secondary": "#fbbf24", "desc": "Chance de desacelerar anéis.", "passive": { "type": "slow_ring", "chance": 0.12, "value": 0.7, "durationMs": 1800 }, "trail": "Runas", "impact": "Feitiço" },
	{ "id": "satellite_rare", "name": "Satélite", "rarity": "rare", "primary": "#9ca3af", "secondary": "#22d3ee", "desc": "Corrente leve entre anéis.", "passive": { "type": "chain_damage", "chance": 0.11, "value": 0.32 }, "trail": "Sinal", "impact": "Laser orbital" },
	{ "id": "meteor_rare", "name": "Meteoro", "rarity": "rare", "primary": "#f97316", "secondary": "#7f1d1d", "desc": "Impacto mais forte.", "passive": { "type": "damage_multiplier", "value": 0.12 }, "trail": "Fogo espacial", "impact": "Cratera" },
	{ "id": "purple_crystal", "name": "Cristal Roxo", "rarity": "rare", "primary": "#a855f7", "secondary": "#22d3ee", "desc": "Aumenta chance de diamante em perfect.", "passive": { "type": "perfect_chance", "value": 0.026 }, "trail": "Cristais", "impact": "Oráculo" },
	{ "id": "neon_heart", "name": "Coração Neon", "rarity": "rare", "primary": "#38bdf8", "secondary": "#ec4899", "desc": "Mais XP ao final.", "passive": { "type": "xp_multiplier", "value": 0.12 }, "trail": "Batimentos", "impact": "Pulso" },
	{ "id": "bomb_rare", "name": "Bomba", "rarity": "rare", "primary": "#111827", "secondary": "#facc15", "desc": "Chance de dano em área.", "passive": { "type": "area_damage", "chance": 0.1, "value": 0.34 }, "trail": "Fumaça", "impact": "Explosão" },
	{ "id": "red_eye", "name": "Olho Carmesim", "rarity": "epic", "primary": "#ff183f", "secondary": "#111111", "desc": "Pode desacelerar o anel atingido.", "passive": { "type": "slow_ring", "chance": 0.2, "value": 0.52, "durationMs": 2600 }, "trail": "Foco carmesim", "impact": "Olhar lento" },
	{ "id": "cosmic_eye", "name": "Olho Cósmico", "rarity": "epic", "primary": "#7c3aed", "secondary": "#22d3ee", "desc": "Aumenta a chance de diamante por perfect.", "passive": { "type": "perfect_chance", "value": 0.04 }, "trail": "Galáxia", "impact": "Constelação" },
	{ "id": "tiny_dragon", "name": "Dragão Pequeno", "rarity": "epic", "primary": "#22c55e", "secondary": "#ff6b00", "desc": "Chamas extras no impacto.", "passive": { "type": "burn", "chance": 0.22, "value": 5, "durationMs": 3200 }, "trail": "Escamas neon", "impact": "Sopro flamejante" },
	{ "id": "shadow_orb", "name": "Esfera Sombria", "rarity": "epic", "primary": "#20113f", "secondary": "#8b5cf6", "desc": "Dano extra em impactos críticos.", "passive": { "type": "mega_crit", "chance": 0.13, "value": 3.2 }, "trail": "Sombra", "impact": "Vazio" },
	{ "id": "solar_orb", "name": "Esfera Solar", "rarity": "epic", "primary": "#fff176", "secondary": "#ff4d00", "desc": "Dano em área em explosões solares.", "passive": { "type": "area_damage", "chance": 0.16, "value": 0.48 }, "trail": "Solar", "impact": "Explosão" },
	{ "id": "electric_core", "name": "Núcleo Elétrico", "rarity": "epic", "primary": "#faff00", "secondary": "#00e5ff", "desc": "Corrente mais forte entre anéis.", "passive": { "type": "chain_damage", "chance": 0.22, "value": 0.6 }, "trail": "Bobina", "impact": "Descarga" },
	{ "id": "astral_eye", "name": "Olho Astral", "rarity": "epic", "primary": "#22d3ee", "secondary": "#7c3aed", "desc": "Perfects melhores e brilho astral.", "passive": { "type": "perfect_chance", "value": 0.04 }, "trail": "Olhar astral", "impact": "Foco" },
	{ "id": "living_plasma", "name": "Plasma Vivo", "rarity": "epic", "primary": "#ff4fd8", "secondary": "#00f0ff", "desc": "Dano em cadeia orgânico.", "passive": { "type": "chain_damage", "chance": 0.18, "value": 0.52 }, "trail": "Plasma", "impact": "Mutação" },
	{ "id": "radioactive_core", "name": "Núcleo Radioativo", "rarity": "epic", "primary": "#39ff14", "secondary": "#111827", "desc": "Queima e enfraquece anéis.", "passive": { "type": "burn", "chance": 0.2, "value": 5, "durationMs": 3300 }, "trail": "Radiação", "impact": "Contágio" },
	{ "id": "blue_comet", "name": "Cometa Azul", "rarity": "epic", "primary": "#60a5fa", "secondary": "#00f0ff", "desc": "Velocidade com dano superior.", "passive": { "type": "speed", "value": 0.16 }, "trail": "Cauda azul", "impact": "Impacto azul" },
	{ "id": "neon_spiral", "name": "Espiral Neon", "rarity": "epic", "primary": "#00f0ff", "secondary": "#ff4fd8", "desc": "Desacelera anéis em espiral.", "passive": { "type": "slow_ring", "chance": 0.18, "value": 0.58, "durationMs": 2400 }, "trail": "Espiral", "impact": "Turbilhão" },
	{ "id": "flaming_skull", "name": "Caveira Flamejante", "rarity": "epic", "primary": "#ff4500", "secondary": "#111827", "desc": "Críticos queimam.", "passive": { "type": "mega_crit", "chance": 0.12, "value": 3 }, "trail": "Chamas", "impact": "Riso flamejante" },
	{ "id": "orbital_blade", "name": "Lâmina Orbital", "rarity": "epic", "primary": "#c0f2ff", "secondary": "#7c3aed", "desc": "Cortes em cadeia.", "passive": { "type": "chain_damage", "chance": 0.19, "value": 0.5 }, "trail": "Lâminas", "impact": "Corte orbital" },
	{ "id": "neon_dragon", "name": "Dragão Neon", "rarity": "epic", "primary": "#00f0ff", "secondary": "#ff00aa", "desc": "Fogo neon em anéis resistentes.", "passive": { "type": "burn", "chance": 0.24, "value": 5, "durationMs": 3200 }, "trail": "Escamas neon", "impact": "Sopro neon" },
	{ "id": "ghost_mask", "name": "Máscara Fantasma", "rarity": "epic", "primary": "#dff7ff", "secondary": "#8b5cf6", "desc": "Pode atravessar sólidos.", "passive": { "type": "phase_solid", "chance": 0.09, "value": 1 }, "trail": "Máscara", "impact": "Assombro" },
	{ "id": "solar_guardian", "name": "Guardião Solar", "rarity": "epic", "primary": "#ffd700", "secondary": "#ff4500", "desc": "Dano em área solar.", "passive": { "type": "area_damage", "chance": 0.18, "value": 0.5 }, "trail": "Escudo solar", "impact": "Erupção" },
	{ "id": "ripple_eye", "name": "Olho Espiral Roxo", "rarity": "legendary", "primary": "#b88cff", "secondary": "#4c1d95", "desc": "Pode repelir anéis para fora.", "passive": { "type": "repel_ring", "chance": 0.2, "value": 20 }, "trail": "Ondas roxas", "impact": "Repulsão" },
	{ "id": "black_hole", "name": "Buraco Negro", "rarity": "legendary", "primary": "#0b0018", "secondary": "#a855f7", "desc": "Pode causar dano em área gravitacional.", "passive": { "type": "area_damage", "chance": 0.22, "value": 0.62 }, "trail": "Gravidade", "impact": "Singularidade" },
	{ "id": "neon_phoenix", "name": "Fênix Neon", "rarity": "legendary", "primary": "#ff4fd8", "secondary": "#ffb000", "desc": "Críticos queimam anéis próximos.", "passive": { "type": "burn", "chance": 0.28, "value": 7, "durationMs": 3600 }, "trail": "Plumas neon", "impact": "Renascimento" },
	{ "id": "astral_dragon", "name": "Dragão Astral", "rarity": "legendary", "primary": "#22d3ee", "secondary": "#7c3aed", "desc": "Dano e XP superiores.", "passive": { "type": "damage_multiplier", "value": 0.22 }, "trail": "Astral", "impact": "Sopro astral" },
	{ "id": "ghost_king", "name": "Rei Fantasma", "rarity": "legendary", "primary": "#dff7ff", "secondary": "#8a7cff", "desc": "Atravessa sólidos com mais frequência.", "passive": { "type": "phase_solid", "chance": 0.12, "value": 1 }, "trail": "Coroa espectral", "impact": "Fase real" },
	{ "id": "collapsed_star", "name": "Estrela Colapsada", "rarity": "legendary", "primary": "#ffd700", "secondary": "#7c2d12", "desc": "Área crítica devastadora.", "passive": { "type": "area_damage", "chance": 0.25, "value": 0.72 }, "trail": "Supernova", "impact": "Colapso" },
	{ "id": "black_sun", "name": "Sol Negro", "rarity": "legendary", "primary": "#050505", "secondary": "#ff4fd8", "desc": "Gravidade e dano em área.", "passive": { "type": "area_damage", "chance": 0.24, "value": 0.7 }, "trail": "Eclipse", "impact": "Corona negra" },
	{ "id": "cosmic_emperor", "name": "Imperador Cósmico", "rarity": "legendary", "primary": "#ffd700", "secondary": "#7c3aed", "desc": "Dano e moedas de elite.", "passive": { "type": "coin_multiplier", "value": 0.24 }, "trail": "Manto cósmico", "impact": "Decreto" },
	{ "id": "galactic_phoenix", "name": "Fênix Galáctica", "rarity": "legendary", "primary": "#ff4fd8", "secondary": "#ffd700", "desc": "Queima anéis próximos.", "passive": { "type": "burn", "chance": 0.3, "value": 7, "durationMs": 3800 }, "trail": "Plumas galácticas", "impact": "Renascimento" },
	{ "id": "void_dragon", "name": "Dragão do Vazio", "rarity": "legendary", "primary": "#111827", "secondary": "#8b5cf6", "desc": "Crítico cósmico poderoso.", "passive": { "type": "cosmic_critical", "chance": 0.18, "value": 0.28 }, "trail": "Vazio", "impact": "Sopro vazio" },
	{ "id": "star_king", "name": "Rei das Estrelas", "rarity": "legendary", "primary": "#fff7ad", "secondary": "#38bdf8", "desc": "Mais XP e perfects.", "passive": { "type": "xp_multiplier", "value": 0.22 }, "trail": "Constelação real", "impact": "Estrela guia" },
	{ "id": "plasma_heart", "name": "Coração de Plasma", "rarity": "legendary", "primary": "#ff4fd8", "secondary": "#00f0ff", "desc": "Pulsos de área.", "passive": { "type": "area_damage", "chance": 0.23, "value": 0.68 }, "trail": "Batimento plasma", "impact": "Pulso" },
	{ "id": "celestial_core", "name": "Núcleo Celestial", "rarity": "legendary", "primary": "#fef3c7", "secondary": "#22d3ee", "desc": "Dano e controle celeste.", "passive": { "type": "slow_ring", "chance": 0.22, "value": 0.48, "durationMs": 2800 }, "trail": "Aura celestial", "impact": "Julgamento" },
	{ "id": "ring_devourer", "name": "Devorador de Anéis", "rarity": "legendary", "primary": "#0f172a", "secondary": "#f97316", "desc": "Dano forte contra anéis externos.", "passive": { "type": "damage_multiplier", "value": 0.25 }, "trail": "Fome orbital", "impact": "Devorar" },
	{ "id": "dimensional_guardian", "name": "Guardião Dimensional", "rarity": "legendary", "primary": "#a855f7", "secondary": "#22d3ee", "desc": "Repulsa anéis perigosos.", "passive": { "type": "repel_ring", "chance": 0.21, "value": 24 }, "trail": "Dimensão", "impact": "Barreira" },
	{ "id": "astral_crown", "name": "Coroa Astral", "rarity": "legendary", "primary": "#ffd700", "secondary": "#a855f7", "desc": "Críticos e XP melhores.", "passive": { "type": "crit_chance", "value": 9 }, "trail": "Coroa astral", "impact": "Realeza" },
	{ "id": "infinite_pulse", "name": "Pulso Infinito", "rarity": "common", "primary": "#00ff88", "secondary": "#00f0ff", "desc": "Recompensa por sobreviver 1 minuto no Infinito. Melhora moedas.", "passive": { "type": "coin_multiplier", "value": 0.08 }, "trail": "Pulso infinito", "impact": "Eco" },
	{ "id": "blue_vortex", "name": "Vórtice Azul", "rarity": "common", "primary": "#38bdf8", "secondary": "#1d4ed8", "desc": "Recompensa por quebrar 25 anéis no Infinito. Melhora velocidade.", "passive": { "type": "speed", "value": 0.06 }, "trail": "Vórtice", "impact": "Giro" },
	{ "id": "loop_flame", "name": "Chama de Loop", "rarity": "rare", "primary": "#ff6b00", "secondary": "#ffd166", "desc": "Recompensa por sobreviver 3 minutos no Infinito. Queima anéis.", "passive": { "type": "burn", "chance": 0.14, "value": 4, "durationMs": 2400 }, "trail": "Chama circular", "impact": "Loop ardente" },
	{ "id": "red_comet", "name": "Cometa Rubro", "rarity": "rare", "primary": "#ef4444", "secondary": "#f97316", "desc": "Recompensa por quebrar 50 anéis no Infinito. Aumenta dano.", "passive": { "type": "damage_multiplier", "value": 0.11 }, "trail": "Cauda rubra", "impact": "Impacto rubro" },
	{ "id": "neon_eclipse", "name": "Eclipse Neon", "rarity": "epic", "primary": "#7c3aed", "secondary": "#00f0ff", "desc": "Recompensa por sobreviver 5 minutos no Infinito. Melhora perfects.", "passive": { "type": "perfect_chance", "value": 0.04 }, "trail": "Eclipse", "impact": "Sombra neon" },
	{ "id": "endless_prism", "name": "Prisma Sem Fim", "rarity": "epic", "primary": "#22d3ee", "secondary": "#ff4fd8", "desc": "Recompensa por quebrar 100 anéis no Infinito. Aumenta XP.", "passive": { "type": "xp_multiplier", "value": 0.18 }, "trail": "Prisma", "impact": "Refração" },
	{ "id": "cosmic_fragment", "name": "Fragmento Cósmico", "rarity": "legendary", "primary": "#a855f7", "secondary": "#facc15", "desc": "Recompensa por sobreviver 10 minutos no Infinito. Aumenta dano.", "passive": { "type": "damage_multiplier", "value": 0.23 }, "trail": "Fragmentos", "impact": "Ruptura cósmica" },
	{ "id": "eternal_core", "name": "Núcleo Eterno", "rarity": "legendary", "primary": "#00f0ff", "secondary": "#ffd700", "desc": "Recompensa por completar 5 desafios no Infinito. Melhora moedas.", "passive": { "type": "coin_multiplier", "value": 0.24 }, "trail": "Núcleo eterno", "impact": "Pulso eterno" },
	{ "id": "infinite_vortex_mythic", "name": "Vórtice Infinito", "rarity": "mythic", "primary": "#ff4fd8", "secondary": "#00f0ff", "desc": "Recompensa por sobreviver 15 minutos no Infinito. Dano e XP elevados.", "passive": { "type": "cosmic_critical", "chance": 0.16, "value": 0.28 }, "trail": "Espiral mítica", "impact": "Colapso" },
	{ "id": "chrono_loop_mythic", "name": "Loop Cronal", "rarity": "mythic", "primary": "#f59e0b", "secondary": "#8b5cf6", "desc": "Recompensa por completar 10 desafios no Infinito. Controla anéis.", "passive": { "type": "slow_ring", "chance": 0.23, "value": 0.46, "durationMs": 3000 }, "trail": "Tempo quebrado", "impact": "Crono pulso" },
	{ "id": "omega_infinity", "name": "Ômega Infinito", "rarity": "ultimate", "primary": "#ffffff", "secondary": "#00ff88", "desc": "Recompensa por sobreviver 20 minutos no Infinito. Bônus completo.", "passive": { "type": "cosmic_critical", "chance": 0.24, "value": 0.38 }, "trail": "Ômega", "impact": "Ressonância final" },
	{ "id": "singularity_crown", "name": "Coroa da Singularidade", "rarity": "ultimate", "primary": "#020617", "secondary": "#ffd700", "desc": "Recompensa por quebrar 300 anéis no Infinito. Área extrema.", "passive": { "type": "area_damage", "chance": 0.32, "value": 0.98 }, "trail": "Coroa singular", "impact": "Gravidade real" },
	{ "id": "living_singularity", "name": "Singularidade Viva", "rarity": "ultimate", "primary": "#050015", "secondary": "#ff4fd8", "desc": "Ultimate raríssima com dano gravitacional extremo.", "passive": { "type": "area_damage", "chance": 0.32, "value": 0.95 }, "trail": "Horizonte vivo", "impact": "Gravidade total" },
	{ "id": "divine_core", "name": "Núcleo Divino", "rarity": "ultimate", "primary": "#fff7ad", "secondary": "#22d3ee", "desc": "Ultimate com bônus de dano, XP e controle.", "passive": { "type": "cosmic_critical", "chance": 0.22, "value": 0.34 }, "trail": "Aura divina", "impact": "Julgamento" },
	{ "id": "void_devourer_ultimate", "name": "Devorador do Vazio", "rarity": "ultimate", "primary": "#020617", "secondary": "#8b5cf6", "desc": "Ultimate oculta que devora anéis com ondas gravitacionais.", "passive": { "type": "area_damage", "chance": 0.34, "value": 1.02 }, "trail": "Abismo", "impact": "Devorar vazio" },
	{ "id": "cosmic_champion", "name": "Campeão Cósmico", "rarity": "ultimate", "primary": "#ffd700", "secondary": "#7c3aed", "desc": "Exclusiva por concluir os 50 estágios. Aumenta dano, moedas, XP, diamantes e pode repelir anéis em crítico.", "passive": { "type": "cosmic_critical", "chance": 0.28, "value": 0.4 }, "trail": "Aura cósmica dourada", "impact": "Repulsão crítica" },
	{ "id": "initial_neon_champion", "name": "Campeão Neon Inicial", "rarity": "ultimate", "primary": "#ffd700", "secondary": "#00aaff", "desc": "Ultimate exclusiva da primeira coroa na Liga Neon Bronze. Amplifica moedas, XP, combo e proteção.", "passive": { "type": "league_starter_champion", "chance": 0.08, "value": 0.24 }, "trail": "Trilha de campeão", "impact": "Escudo de ranking" },
	{ "id": "league_bronze_champion", "name": "Coroa Bronze Neon", "rarity": "legendary", "primary": "#cd7f32", "secondary": "#00f0ff", "desc": "Skin exclusiva por terminar em primeiro na divisão Bronze da Liga Neon.", "passive": { "type": "coin_multiplier", "value": 0.18 }, "trail": "Bronze neon", "impact": "Coroa inicial" },
	{ "id": "league_king_neon", "name": "Rei da Liga Neon", "rarity": "ultimate", "primary": "#ffd700", "secondary": "#8b5cf6", "desc": "Ultimate máxima de ranking. Aumenta dano, moedas, XP, perfect diamonds e libera onda em combo alto.", "passive": { "type": "league_king_wave", "chance": 0.18, "value": 0.38 }, "trail": "Coroas estelares", "impact": "Onda real" },
]

const RUN_UPGRADES := [
	{ "id": "damage", "name": "Dano+", "description": "+15% de dano", "icon": "⚔️", "rarity": "common", "maxLevel": 10, "unlockLevel": 1, "unlockRequirement": "Perfil nível 1", "secret": false, "effects": [{ "type": "damage", "value": 0.15 }] },
	{ "id": "speed", "name": "Velocidade+", "description": "+20% de velocidade", "icon": "⚡", "rarity": "common", "maxLevel": 10, "unlockLevel": 1, "unlockRequirement": "Perfil nível 1", "secret": false, "effects": [{ "type": "speed", "value": 0.2 }] },
	{ "id": "coinBoost", "name": "Chuva de Moedas", "description": "+50% de moedas", "icon": "💰", "rarity": "common", "maxLevel": 10, "unlockLevel": 1, "unlockRequirement": "Perfil nível 1", "secret": false, "effects": [{ "type": "coinMultiplier", "value": 0.5 }] },
	{ "id": "critical", "name": "Crítico+", "description": "+5% chance crítica", "icon": "💥", "rarity": "common", "maxLevel": 8, "unlockLevel": 1, "unlockRequirement": "Perfil nível 1", "secret": false, "effects": [{ "type": "critChance", "value": 5 }] },
	{ "id": "xpBoost", "name": "XP Boost", "description": "+50% de XP", "icon": "⭐", "rarity": "common", "maxLevel": 10, "unlockLevel": 3, "unlockRequirement": "Perfil nível 3", "secret": false, "effects": [{ "type": "xpMultiplier", "value": 0.5 }] },
	{ "id": "bounce", "name": "Ricochete", "description": "+1 ricochete extra", "icon": "🎯", "rarity": "rare", "maxLevel": 5, "unlockLevel": 7, "unlockRequirement": "Perfil nível 7", "secret": false, "effects": [{ "type": "bounce", "value": 1 }] },
	{ "id": "perfectChance", "name": "Perfect Chance", "description": "+1% chance de diamante no Perfect", "icon": "💎", "rarity": "rare", "maxLevel": 7, "unlockLevel": 5, "unlockRequirement": "Perfil nível 5", "secret": false, "effects": [{ "type": "perfectChance", "value": 0.01 }] },
	{ "id": "burn", "name": "Queimar", "description": "Causa dano contínuo de fogo", "icon": "🔥", "rarity": "rare", "maxLevel": 5, "unlockLevel": 5, "unlockRequirement": "Perfil nível 3", "secret": false, "effects": [{ "type": "burn", "value": 10 }] },
	{ "id": "penetration", "name": "Veneno", "description": "Aplica dano progressivo", "icon": "🗡️", "rarity": "rare", "maxLevel": 5, "unlockLevel": 5, "unlockRequirement": "Perfil nível 5", "secret": false, "effects": [{ "type": "poison", "value": 1 }] },
	{ "id": "ricochet", "name": "Ricochete Vivo", "description": "Mais variação e velocidade após impacto", "icon": "🔁", "rarity": "rare", "maxLevel": 5, "unlockLevel": 5, "unlockRequirement": "Perfil nível 7", "secret": false, "effects": [{ "type": "ricochet", "value": 1 }] },
	{ "id": "shockwave", "name": "Onda de Choque", "description": "Dano em área ao impacto", "icon": "🌊", "rarity": "epic", "maxLevel": 5, "unlockLevel": 8, "unlockRequirement": "Perfil nível 12", "secret": false, "effects": [{ "type": "shockwave", "value": 0.5 }] },
	{ "id": "chainLightning", "name": "Raio em Cadeia", "description": "Ataca alvos próximos", "icon": "⚡", "rarity": "epic", "maxLevel": 5, "unlockLevel": 10, "unlockRequirement": "Perfil nível 10", "secret": false, "effects": [{ "type": "chain", "value": 2 }] },
	{ "id": "frost", "name": "Congelamento", "description": "Desacelera anéis", "icon": "❄️", "rarity": "epic", "maxLevel": 5, "unlockLevel": 5, "unlockRequirement": "Perfil nível 5", "secret": false, "effects": [{ "type": "frost", "value": 0.3 }] },
	{ "id": "bomb", "name": "Bomba", "description": "Chance de explosão massiva", "icon": "💣", "rarity": "epic", "maxLevel": 5, "unlockLevel": 15, "unlockRequirement": "Perfil nível 15", "secret": false, "effects": [{ "type": "bomb", "value": 3 }] },
	{ "id": "laser", "name": "Raio Laser", "description": "Dispara raio laser", "icon": "🔫", "rarity": "epic", "maxLevel": 5, "unlockLevel": 12, "unlockRequirement": "Perfil nível 12", "secret": false, "effects": [{ "type": "laser", "value": 50 }] },
	{ "id": "multihit", "name": "Multi-Hit", "description": "Múltiplos ataques simultâneos", "icon": "✨", "rarity": "legendary", "maxLevel": 3, "unlockLevel": 15, "unlockRequirement": "Perfil nível 25", "secret": false, "effects": [{ "type": "multihit", "value": 1 }] },
	{ "id": "slowField", "name": "Slow Field", "description": "Chance de desacelerar todos os anéis", "icon": "🌀", "rarity": "epic", "maxLevel": 5, "unlockLevel": 9, "unlockRequirement": "Perfil nível 9", "secret": false, "effects": [{ "type": "slowField", "value": 0.35 }] },
	{ "id": "ringRepulse", "name": "Ring Repulse", "description": "Empurra o anel atingido para fora", "icon": "↗️", "rarity": "rare", "maxLevel": 5, "unlockLevel": 7, "unlockRequirement": "Perfil nível 7", "secret": false, "effects": [{ "type": "repulse", "value": 18 }] },
	{ "id": "laserCut", "name": "Laser Cut", "description": "Chance de dano alto no anel", "icon": "🔦", "rarity": "epic", "maxLevel": 5, "unlockLevel": 12, "unlockRequirement": "Perfil nível 12", "secret": false, "effects": [{ "type": "laserCut", "value": 2.5 }] },
	{ "id": "chainBreak", "name": "Chain Break", "description": "Quebrar um anel fere o próximo", "icon": "⛓️", "rarity": "legendary", "maxLevel": 4, "unlockLevel": 18, "unlockRequirement": "Perfil nível 18", "secret": false, "effects": [{ "type": "chainBreak", "value": 0.35 }] },
	{ "id": "shieldPulse", "name": "Shield Pulse", "description": "Escudo curto contra esmagamento", "icon": "🛡️", "rarity": "epic", "maxLevel": 4, "unlockLevel": 14, "unlockRequirement": "Perfil nível 14", "secret": false, "effects": [{ "type": "shield", "value": 2 }] },
	{ "id": "timeFreeze", "name": "Time Freeze", "description": "Congela todos os anéis por pouco tempo", "icon": "⏱️", "rarity": "legendary", "maxLevel": 3, "unlockLevel": 20, "unlockRequirement": "Perfil nível 20", "secret": false, "effects": [{ "type": "timeFreeze", "value": 1 }] },
	{ "id": "magnetCoins", "name": "Magnet Coins", "description": "Aumenta moedas da rodada", "icon": "🧲", "rarity": "rare", "maxLevel": 8, "unlockLevel": 6, "unlockRequirement": "Perfil nível 6", "secret": false, "effects": [{ "type": "coinMultiplier", "value": 0.25 }] },
	{ "id": "criticalOverload", "name": "Critical Overload", "description": "Críticos acumulam dano temporário", "icon": "💢", "rarity": "legendary", "maxLevel": 4, "unlockLevel": 16, "unlockRequirement": "Perfil nível 16", "secret": false, "effects": [{ "type": "critOverload", "value": 0.3 }] },
	{ "id": "chronoBreak", "name": "Chrono Break", "description": "Pequena chance de congelar todos os anéis por alguns segundos.", "icon": "⏳", "rarity": "legendary", "maxLevel": 3, "unlockLevel": 1, "unlockRequirement": "Conquista secreta", "secret": true, "effects": [{ "type": "timeFreeze", "value": 1 }] },
	{ "id": "voidPulse", "name": "Void Pulse", "description": "Chance de causar dano em área ao quebrar um anel.", "icon": "🌑", "rarity": "legendary", "maxLevel": 4, "unlockLevel": 1, "unlockRequirement": "Conquista secreta", "secret": true, "effects": [{ "type": "areaDamage", "value": 0.45 }] },
	{ "id": "diamondInstinct", "name": "Diamond Instinct", "description": "Aumenta chance de diamante em Perfect Escape.", "icon": "💠", "rarity": "epic", "maxLevel": 4, "unlockLevel": 1, "unlockRequirement": "Conquista secreta", "secret": true, "effects": [{ "type": "perfectChance", "value": 0.018 }] },
	{ "id": "comboOverdrive", "name": "Combo Overdrive", "description": "Combos altos aumentam dano e moedas temporariamente.", "icon": "🚀", "rarity": "legendary", "maxLevel": 3, "unlockLevel": 1, "unlockRequirement": "Conquista secreta", "secret": true, "effects": [{ "type": "comboBoost", "value": 0.25 }] },
	{ "id": "lastShield", "name": "Last Shield", "description": "Uma vez por partida, evita morte por esmagamento.", "icon": "🛡️", "rarity": "legendary", "maxLevel": 2, "unlockLevel": 1, "unlockRequirement": "Conquista secreta", "secret": true, "effects": [{ "type": "lastShield", "value": 1 }] },
	{ "id": "royalBreaker", "name": "Royal Breaker", "description": "Aumenta dano contra anéis externos.", "icon": "👑", "rarity": "legendary", "maxLevel": 4, "unlockLevel": 1, "unlockRequirement": "Conquista secreta", "secret": true, "effects": [{ "type": "outerDamage", "value": 0.22 }] },
	{ "id": "bossHunter", "name": "Boss Hunter", "description": "Aumenta dano e XP em modos competitivos.", "icon": "🎯", "rarity": "epic", "maxLevel": 4, "unlockLevel": 1, "unlockRequirement": "Conquista secreta", "secret": true, "effects": [{ "type": "competitiveBoost", "value": 0.18 }] },
	{ "id": "secretMagnet", "name": "Secret Magnet", "description": "Aumenta moedas gerais recebidas no final.", "icon": "🧲", "rarity": "epic", "maxLevel": 5, "unlockLevel": 1, "unlockRequirement": "Conquista secreta", "secret": true, "effects": [{ "type": "coinMultiplier", "value": 0.18 }] },
	{ "id": "trophyInstinct", "name": "Trophy Instinct", "description": "Pequeno bônus de troféus ao vencer competições.", "icon": "🏆", "rarity": "epic", "maxLevel": 3, "unlockLevel": 1, "unlockRequirement": "Conquista secreta", "secret": true, "effects": [{ "type": "trophyBonus", "value": 2 }] },
	{ "id": "rivalCrusher", "name": "Rival Crusher", "description": "Aumenta dano e XP em partidas competitivas.", "icon": "💢", "rarity": "legendary", "maxLevel": 3, "unlockLevel": 1, "unlockRequirement": "Conquista secreta", "secret": true, "effects": [{ "type": "competitiveBoost", "value": 0.24 }] },
]

const AUTO_RUN_UPGRADE_IDS := [
	"damage",
	"speed",
	"coinBoost",
	"critical",
	"xpBoost",
	"perfectChance",
]

const LEAGUE_RANKS := [
	{ "id": "bronze", "name": "Bronze", "min": 0, "reward": { "type": "coins", "amount": 300 } },
	{ "id": "silver", "name": "Silver", "min": 300, "reward": { "type": "diamonds", "amount": 18 } },
	{ "id": "gold", "name": "Gold", "min": 700, "reward": { "type": "keys", "amount": 1 } },
	{ "id": "diamond", "name": "Diamond", "min": 1200, "reward": { "type": "chest", "chest_type": "rare", "amount": 1 } },
	{ "id": "legendary", "name": "Legendary", "min": 1900, "reward": { "type": "legendaryKeys", "amount": 1 } },
	{ "id": "ultimate", "name": "Ultimate", "min": 2800, "reward": { "type": "skin", "skin_id": "league_king_neon" } },
]

func skin_by_id(id: String) -> Dictionary:
	for skin in SKINS:
		if String(skin.get("id", "")) == id:
			return skin
	return {}

func upgrade_by_id(id: String) -> Dictionary:
	for upgrade in RUN_UPGRADES:
		if String(upgrade.get("id", "")) == id:
			return upgrade
	return {}

func run_upgrades() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for upgrade in RUN_UPGRADES:
		result.append(Dictionary(upgrade).duplicate(true))
	return result

func released_run_upgrade_ids() -> Array[String]:
	var result: Array[String] = []
	for upgrade in RUN_UPGRADES:
		var id := String(upgrade.get("id", ""))
		if not id.is_empty() and not bool(upgrade.get("secret", false)):
			result.append(id)
	return result

func auto_run_upgrade_ids() -> Array[String]:
	var result: Array[String] = []
	for id in AUTO_RUN_UPGRADE_IDS:
		result.append(String(id))
	return result

func is_released_run_upgrade(id: String) -> bool:
	return released_run_upgrade_ids().has(id)

func released_run_upgrades() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in released_run_upgrade_ids():
		var upgrade := upgrade_by_id(id)
		if not upgrade.is_empty():
			result.append(upgrade)
	return result

func rank_for_trophies(trophies: int) -> Dictionary:
	var current := LEAGUE_RANKS[0]
	for rank in LEAGUE_RANKS:
		if trophies >= int(rank.get("min", 0)):
			current = rank
	return current

func opponent_name(index: int, rank_id: String) -> String:
	var prefixes: Array[String] = ["Nova", "Pixel", "Orbit", "Cyber", "Vortex", "Pulse", "Chrome", "Solar", "Astral", "Rift"]
	var suffixes: Array[String] = ["Runner", "Breaker", "Drifter", "Spark", "Core", "Pilot", "Blade", "Rush", "Echo", "Flux", "Unit", "Zero", "Prime", "Wave", "Byte", "Nova", "Ray", "Loop", "Shift", "Dash"]
	return "%s %s #%03d" % [prefixes[index % prefixes.size()], suffixes[(index / prefixes.size()) % suffixes.size()], index + 1]

func opponent_for(trophies: int) -> Dictionary:
	var rank: Dictionary = rank_for_trophies(trophies)
	var seed: int = int(Time.get_unix_time_from_system() / 60) + trophies * 17
	var idx: int = abs(seed) % 200
	var rank_index: int = LEAGUE_RANKS.find(rank)
	return { "id": "%s_%03d" % [String(rank.get("id", "bronze")), idx], "name": opponent_name(idx, String(rank.get("id", "bronze"))), "rank": rank, "quality": clampf(0.32 + float(rank_index) * 0.1 + float(idx % 17) / 100.0, 0.32, 0.92), "skin": SKINS[(idx + rank_index * 13) % SKINS.size()] }

extends Node

const TAU_VALUE = PI * 2.0

const RARITY_ORDER = ["common", "rare", "epic", "legendary", "mythic", "ultimate"]
const RARITY_COLORS = {
	"common": "#9ca3af",
	"rare": "#00aaff",
	"epic": "#b000ff",
	"legendary": "#ffd700",
	"mythic": "#ff4fd8",
	"ultimate": "#ffffff"
}

const RARITY_SKINS = {
	"common": [
		"neon_blue", "puppy", "kitty", "piggy", "bunny", "slime", "ghost", "chick", "frog", "monkey",
		"penguin", "hamster", "bear_common", "panda", "fox_common", "tiger_common", "cow_common",
		"octopus_common", "fish_common", "bee_common", "ladybug_common", "infinite_pulse", "blue_vortex"
	],
	"rare": [
		"robot", "skull", "fire", "ice", "lightning", "star_rare", "moon", "planet", "crystal", "comet",
		"wolf_rare", "dragonling_rare", "alien_rare", "ninja_rare", "wizard_rare", "satellite_rare",
		"meteor_rare", "purple_crystal", "neon_heart", "bomb_rare", "loop_flame", "red_comet"
	],
	"epic": [
		"red_eye", "cosmic_eye", "tiny_dragon", "shadow_orb", "solar_orb", "electric_core", "astral_eye",
		"living_plasma", "radioactive_core", "blue_comet", "neon_spiral", "flaming_skull", "orbital_blade",
		"neon_dragon", "ghost_mask", "solar_guardian", "neon_eclipse", "endless_prism"
	],
	"legendary": [
		"ripple_eye", "black_hole", "neon_phoenix", "astral_dragon", "ghost_king", "collapsed_star",
		"black_sun", "cosmic_emperor", "galactic_phoenix", "void_dragon", "star_king", "plasma_heart",
		"celestial_core", "ring_devourer", "dimensional_guardian", "astral_crown", "cosmic_fragment",
		"eternal_core", "league_bronze_champion"
	],
	"mythic": ["infinite_vortex_mythic", "chrono_loop_mythic"],
	"ultimate": [
		"omega_infinity", "singularity_crown", "living_singularity", "divine_core", "void_devourer_ultimate",
		"cosmic_champion", "initial_neon_champion", "league_king_neon"
	]
}

const SKIN_NAME_OVERRIDES = {
	"neon_blue": "Neon Azul",
	"puppy": "Cachorrinho",
	"kitty": "Gatinho",
	"piggy": "Porquinho",
	"bunny": "Coelho",
	"slime": "Slime",
	"ghost": "Fantasma",
	"chick": "Pintinho",
	"frog": "Sapo",
	"monkey": "Macaquinho",
	"penguin": "Pinguim",
	"hamster": "Hamster",
	"bear_common": "Ursinho",
	"panda": "Panda",
	"fox_common": "Raposa",
	"tiger_common": "Tigre",
	"cow_common": "Vaquinha",
	"octopus_common": "Polvo",
	"fish_common": "Peixinho",
	"bee_common": "Abelha",
	"ladybug_common": "Joaninha",
	"robot": "Robô",
	"skull": "Caveira",
	"fire": "Fogo",
	"ice": "Gelo",
	"lightning": "Raio",
	"star_rare": "Estrela",
	"moon": "Lua",
	"planet": "Planeta",
	"crystal": "Cristal",
	"comet": "Cometa",
	"wolf_rare": "Lobo",
	"dragonling_rare": "Dragãozinho",
	"alien_rare": "Alien",
	"ninja_rare": "Ninja",
	"wizard_rare": "Mago",
	"satellite_rare": "Satélite",
	"meteor_rare": "Meteoro",
	"purple_crystal": "Cristal Roxo",
	"neon_heart": "Coração Neon",
	"bomb_rare": "Bomba",
	"red_eye": "Olho Carmesim",
	"cosmic_eye": "Olho Cósmico",
	"tiny_dragon": "Dragão Pequeno",
	"shadow_orb": "Esfera Sombria",
	"solar_orb": "Esfera Solar",
	"electric_core": "Núcleo Elétrico",
	"astral_eye": "Olho Astral",
	"living_plasma": "Plasma Vivo",
	"radioactive_core": "Núcleo Radioativo",
	"blue_comet": "Cometa Azul",
	"neon_spiral": "Espiral Neon",
	"flaming_skull": "Caveira Flamejante",
	"orbital_blade": "Lâmina Orbital",
	"neon_dragon": "Dragão Neon",
	"ghost_mask": "Máscara Fantasma",
	"solar_guardian": "Guardião Solar",
	"ripple_eye": "Olho Espiral Roxo",
	"black_hole": "Buraco Negro",
	"neon_phoenix": "Fênix Neon",
	"astral_dragon": "Dragão Astral",
	"ghost_king": "Rei Fantasma",
	"collapsed_star": "Estrela Colapsada",
	"black_sun": "Sol Negro",
	"cosmic_emperor": "Imperador Cósmico",
	"galactic_phoenix": "Fênix Galáctica",
	"void_dragon": "Dragão do Vazio",
	"star_king": "Rei das Estrelas",
	"plasma_heart": "Coração de Plasma",
	"celestial_core": "Núcleo Celestial",
	"ring_devourer": "Devorador de Anéis",
	"dimensional_guardian": "Guardião Dimensional",
	"astral_crown": "Coroa Astral",
	"infinite_pulse": "Pulso Infinito",
	"blue_vortex": "Vórtice Azul",
	"loop_flame": "Chama de Loop",
	"red_comet": "Cometa Rubro",
	"neon_eclipse": "Eclipse Neon",
	"endless_prism": "Prisma Sem Fim",
	"cosmic_fragment": "Fragmento Cósmico",
	"eternal_core": "Núcleo Eterno",
	"infinite_vortex_mythic": "Vórtice Infinito",
	"chrono_loop_mythic": "Loop Cronal",
	"omega_infinity": "Ômega Infinito",
	"singularity_crown": "Coroa da Singularidade",
	"living_singularity": "Singularidade Viva",
	"divine_core": "Núcleo Divino",
	"void_devourer_ultimate": "Devorador do Vazio",
	"cosmic_champion": "Campeão Cósmico",
	"initial_neon_champion": "Campeão Neon Inicial",
	"league_bronze_champion": "Coroa Bronze Neon",
	"league_king_neon": "Rei da Liga Neon"
}

const SKIN_DESCRIPTION_OVERRIDES = {
	"neon_blue": "Esfera inicial equilibrada.",
	"puppy": "Chance de moedas extras no impacto.",
	"kitty": "Aumenta chance crítica.",
	"piggy": "Aumenta moedas ganhas.",
	"bunny": "Aumenta velocidade da bolinha.",
	"slime": "Chance de ricochete sem perder velocidade.",
	"ghost": "Chance de atravessar parte sólida.",
	"chick": "Moedas extras em quebras rápidas.",
	"frog": "Pequeno bônus de ricochete.",
	"monkey": "Bônus leve de XP.",
	"penguin": "Pequena chance de desacelerar anéis.",
	"hamster": "Moedas extras em impactos rápidos.",
	"bear_common": "Um pouco mais de dano.",
	"panda": "Bônus leve de XP.",
	"fox_common": "Velocidade levemente maior.",
	"tiger_common": "Pequeno bônus crítico.",
	"cow_common": "Mais moedas ao final.",
	"octopus_common": "Chance baixa de ricochete.",
	"fish_common": "Aumenta a velocidade.",
	"bee_common": "Crítico leve.",
	"ladybug_common": "Pequeno bônus de moedas.",
	"robot": "Calcula ricochetes eficientes.",
	"skull": "Chance de crítico pesado.",
	"fire": "Aplica dano contínuo.",
	"ice": "Congela ou desacelera anéis.",
	"lightning": "Corrente elétrica atinge outro anel.",
	"star_rare": "Melhora perfect escapes.",
	"moon": "Bônus leve de dano.",
	"planet": "Melhora moedas e perfects.",
	"crystal": "Bônus de gemas por perfect.",
	"comet": "Mais velocidade e impacto.",
	"wolf_rare": "Dano e crítico estáveis.",
	"dragonling_rare": "Chance de queimar anéis.",
	"alien_rare": "Melhora perfect escapes.",
	"ninja_rare": "Mais velocidade e crítico.",
	"wizard_rare": "Chance de desacelerar anéis.",
	"satellite_rare": "Corrente leve entre anéis.",
	"meteor_rare": "Impacto mais forte.",
	"purple_crystal": "Aumenta chance de diamante em perfect.",
	"neon_heart": "Mais XP ao final.",
	"bomb_rare": "Chance de dano em área.",
	"red_eye": "Pode desacelerar o anel atingido.",
	"cosmic_eye": "Aumenta a chance de diamante por perfect.",
	"tiny_dragon": "Chamas extras no impacto.",
	"shadow_orb": "Dano extra em impactos críticos.",
	"solar_orb": "Dano em área em explosões solares.",
	"electric_core": "Corrente mais forte entre anéis.",
	"astral_eye": "Perfects melhores e brilho astral.",
	"living_plasma": "Dano em cadeia orgânico.",
	"radioactive_core": "Queima e enfraquece anéis.",
	"blue_comet": "Velocidade com dano superior.",
	"neon_spiral": "Desacelera anéis em espiral.",
	"flaming_skull": "Críticos queimam.",
	"orbital_blade": "Cortes em cadeia.",
	"neon_dragon": "Fogo neon em anéis resistentes.",
	"ghost_mask": "Pode atravessar sólidos.",
	"solar_guardian": "Dano em área solar.",
	"ripple_eye": "Pode repelir anéis para fora.",
	"black_hole": "Pode causar dano em área gravitacional.",
	"neon_phoenix": "Críticos queimam anéis próximos.",
	"astral_dragon": "Dano e XP superiores.",
	"ghost_king": "Atravessa sólidos com mais frequência.",
	"collapsed_star": "Área crítica devastadora.",
	"black_sun": "Gravidade e dano em área.",
	"cosmic_emperor": "Dano e moedas de elite.",
	"galactic_phoenix": "Queima anéis próximos.",
	"void_dragon": "Crítico cósmico poderoso.",
	"star_king": "Mais XP e perfects.",
	"plasma_heart": "Pulsos de área.",
	"celestial_core": "Dano e controle celeste.",
	"ring_devourer": "Dano forte contra anéis externos.",
	"dimensional_guardian": "Repulsa anéis perigosos.",
	"astral_crown": "Críticos e XP melhores.",
	"infinite_pulse": "Recompensa por sobreviver 1 minuto no Infinito. Melhora moedas.",
	"blue_vortex": "Recompensa por quebrar 25 anéis no Infinito. Melhora velocidade.",
	"loop_flame": "Recompensa por sobreviver 3 minutos no Infinito. Queima anéis.",
	"red_comet": "Recompensa por quebrar 50 anéis no Infinito. Aumenta dano.",
	"neon_eclipse": "Recompensa por sobreviver 5 minutos no Infinito. Melhora perfects.",
	"endless_prism": "Recompensa por quebrar 100 anéis no Infinito. Aumenta XP.",
	"cosmic_fragment": "Recompensa por sobreviver 10 minutos no Infinito. Aumenta dano.",
	"eternal_core": "Recompensa por completar 5 desafios no Infinito. Melhora moedas.",
	"infinite_vortex_mythic": "Recompensa por sobreviver 15 minutos no Infinito. Dano e XP elevados.",
	"chrono_loop_mythic": "Recompensa por completar 10 desafios no Infinito. Controla anéis.",
	"omega_infinity": "Recompensa por sobreviver 20 minutos no Infinito. Bônus completo.",
	"singularity_crown": "Recompensa por quebrar 300 anéis no Infinito. Área extrema.",
	"living_singularity": "Ultimate raríssima com dano gravitacional extremo.",
	"divine_core": "Ultimate com bônus de dano, XP e controle.",
	"void_devourer_ultimate": "Ultimate oculta que devora anéis com ondas gravitacionais.",
	"cosmic_champion": "Exclusiva por concluir os 50 estágios. Aumenta dano, moedas, XP, diamantes e pode repelir anéis em crítico.",
	"initial_neon_champion": "Ultimate exclusiva da primeira coroa na Liga Neon Bronze. Amplifica moedas, XP, combo e proteção.",
	"league_bronze_champion": "Skin exclusiva por terminar em primeiro na divisão Bronze da Liga Neon.",
	"league_king_neon": "Ultimate máxima de ranking. Aumenta dano, moedas, XP, perfect diamonds e libera onda em combo alto."
}

const CHESTS = [
	{
		"id": "common",
		"name": "Baú Comum",
		"icon_path": "res://assets/ui/ui_chest_common.png",
		"cost": 180,
		"currency": "coins",
		"color": "#9ca3af",
		"description": "70% comum, 24% rara, 6% épica.",
		"chances": {"common": 0.70, "rare": 0.24, "epic": 0.06}
	},
	{
		"id": "rare",
		"name": "Baú Raro",
		"icon_path": "res://assets/ui/ui_chest_rare.png",
		"cost": 1,
		"currency": "keys",
		"color": "#00aaff",
		"description": "25% comum, 55% rara, 17% épica, 3% lendária.",
		"chances": {"common": 0.25, "rare": 0.55, "epic": 0.17, "legendary": 0.03}
	},
	{
		"id": "epic",
		"name": "Baú Épico",
		"icon_path": "res://assets/ui/ui_chest_epic.png",
		"cost": 120,
		"currency": "gems",
		"color": "#b000ff",
		"description": "35% rara, 48% épica, 15% lendária, 2% Ultimate.",
		"chances": {"rare": 0.35, "epic": 0.48, "legendary": 0.15, "ultimate": 0.02}
	},
	{
		"id": "legendary",
		"name": "Baú Lendário",
		"icon_path": "res://assets/ui/ui_chest_legendary.png",
		"cost": 1,
		"currency": "legendary_keys",
		"color": "#ffd700",
		"description": "45% épica, 50% lendária, 5% Ultimate.",
		"chances": {"epic": 0.45, "legendary": 0.50, "ultimate": 0.05}
	}
]

const PERMANENT_UPGRADES = [
	{"id": "baseDamage", "name": "Damage", "description": "+10% dano por nível", "icon_path": "res://assets/ui/ui_damage.png", "base_cost": 100, "max_level": 30, "unlock": "start", "unlock_text": "Disponível desde o início", "currency": "coins"},
	{"id": "baseSpeed", "name": "Speed", "description": "+8% velocidade por nível", "icon_path": "res://assets/ui/ui_speed.png", "base_cost": 120, "max_level": 18, "unlock": "start", "unlock_text": "Disponível desde o início", "currency": "coins"},
	{"id": "coinMultiplier", "name": "Cash Gain", "description": "+15% moedas por nível", "icon_path": "res://assets/ui/ui_coin.png", "base_cost": 200, "max_level": 25, "unlock": "start", "unlock_text": "Disponível desde o início", "currency": "coins"},
	{"id": "critChance", "name": "Crit Chance", "description": "+2% crítico por nível", "icon_path": "res://assets/ui/ui_crit.png", "base_cost": 150, "max_level": 20, "unlock": "start", "unlock_text": "Disponível desde o início", "currency": "coins"},
	{"id": "xpBoost", "name": "XP Boost", "description": "+20% XP por nível", "icon_path": "res://assets/ui/ui_xp.png", "base_cost": 180, "max_level": 25, "unlock": "phase_3", "unlock_text": "Desbloqueia ao alcançar a fase 3", "currency": "coins"},
	{"id": "perfectChance", "name": "Perfect Chance", "description": "+1% chance de diamante no perfect", "icon_path": "res://assets/ui/ui_perfect.png", "base_cost": 450, "max_level": 12, "unlock": "phase_5_or_chest", "unlock_text": "Desbloqueia por baús raros ou fase 5", "currency": "coins"},
	{"id": "slowRings", "name": "Slow Rings", "description": "Anéis fecham mais devagar", "icon_path": "res://assets/ui/ui_freeze.png", "base_cost": 600, "max_level": 10, "unlock": "chest", "unlock_text": "Desbloqueia por rank ou recompensas especiais", "currency": "gems"}
]

const RUN_UPGRADES = [
	{"id": "damage", "name": "Dano+", "description": "+15% de dano", "icon_path": "res://assets/ui/ui_damage.png", "rarity": "common", "max_level": 10, "effects": [{"type": "damage", "value": 0.15}]},
	{"id": "speed", "name": "Velocidade+", "description": "+20% de velocidade", "icon_path": "res://assets/ui/ui_speed.png", "rarity": "common", "max_level": 10, "effects": [{"type": "speed", "value": 0.20}]},
	{"id": "coinBoost", "name": "Chuva de Moedas", "description": "+50% de moedas", "icon_path": "res://assets/ui/ui_coin.png", "rarity": "common", "max_level": 10, "effects": [{"type": "coinMultiplier", "value": 0.50}]},
	{"id": "critical", "name": "Critico+", "description": "+5% chance critica", "icon_path": "res://assets/ui/ui_crit.png", "rarity": "common", "max_level": 8, "effects": [{"type": "critChance", "value": 5.0}]},
	{"id": "xpBoost", "name": "XP Boost", "description": "+50% de XP", "icon_path": "res://assets/ui/ui_xp.png", "rarity": "common", "max_level": 10, "effects": [{"type": "xpMultiplier", "value": 0.50}]},
	{"id": "bounce", "name": "Ricochete", "description": "+1 ricochete extra", "icon_path": "res://assets/ui/ui_combo.png", "rarity": "rare", "max_level": 5, "effects": [{"type": "bounce", "value": 1.0}]},
	{"id": "perfectChance", "name": "Perfect Chance", "description": "+1% chance de diamante", "icon_path": "res://assets/ui/ui_perfect.png", "rarity": "rare", "max_level": 7, "effects": [{"type": "perfectChance", "value": 0.01}]},
	{"id": "burn", "name": "Queimar", "description": "Causa dano continuo", "icon_path": "res://assets/ui/ui_burn.png", "rarity": "rare", "max_level": 5, "effects": [{"type": "burn", "value": 10.0}]},
	{"id": "penetration", "name": "Veneno", "description": "Aplica dano progressivo", "icon_path": "res://assets/ui/ui_poison.png", "rarity": "rare", "max_level": 5, "effects": [{"type": "poison", "value": 1.0}]},
	{"id": "ricochet", "name": "Ricochete Vivo", "description": "Mais variacao e velocidade apos impacto", "icon_path": "res://assets/ui/ui_combo.png", "rarity": "rare", "max_level": 5, "effects": [{"type": "ricochet", "value": 1.0}]},
	{"id": "frost", "name": "Congelamento", "description": "Desacelera aneis", "icon_path": "res://assets/ui/ui_freeze.png", "rarity": "epic", "max_level": 5, "effects": [{"type": "frost", "value": 0.30}]},
	{"id": "bomb", "name": "Bomba", "description": "Chance de explosao massiva", "icon_path": "res://assets/ui/ui_area.png", "rarity": "epic", "max_level": 5, "effects": [{"type": "bomb", "value": 3.0}]},
	{"id": "laser", "name": "Raio Laser", "description": "Dispara raio laser", "icon_path": "res://assets/ui/ui_shock.png", "rarity": "epic", "max_level": 5, "effects": [{"type": "laser", "value": 50.0}]},
	{"id": "multihit", "name": "Multi-Hit", "description": "Multiplos ataques simultaneos", "icon_path": "res://assets/ui/ui_effect.png", "rarity": "legendary", "max_level": 3, "effects": [{"type": "multihit", "value": 1.0}]},
	{"id": "ringRepulse", "name": "Ring Repulse", "description": "Empurra aneis para fora", "icon_path": "res://assets/ui/ui_repulse.png", "rarity": "rare", "max_level": 5, "effects": [{"type": "repulse", "value": 18.0}]},
	{"id": "shockwave", "name": "Onda de Choque", "description": "Dano em area ao impacto", "icon_path": "res://assets/ui/ui_area.png", "rarity": "epic", "max_level": 5, "effects": [{"type": "shockwave", "value": 0.50}]},
	{"id": "chainLightning", "name": "Raio em Cadeia", "description": "Ataca aneis proximos", "icon_path": "res://assets/ui/ui_shock.png", "rarity": "epic", "max_level": 5, "effects": [{"type": "chain", "value": 2.0}]},
	{"id": "slowField", "name": "Slow Field", "description": "Chance de desacelerar todos", "icon_path": "res://assets/ui/ui_freeze.png", "rarity": "epic", "max_level": 5, "effects": [{"type": "slowField", "value": 0.35}]},
	{"id": "laserCut", "name": "Laser Cut", "description": "Chance de dano alto no anel", "icon_path": "res://assets/ui/ui_shock.png", "rarity": "epic", "max_level": 5, "effects": [{"type": "laserCut", "value": 2.5}]},
	{"id": "chainBreak", "name": "Chain Break", "description": "Quebrar um anel fere o proximo", "icon_path": "res://assets/ui/ui_combo.png", "rarity": "legendary", "max_level": 4, "effects": [{"type": "chainBreak", "value": 0.35}]},
	{"id": "shieldPulse", "name": "Shield Pulse", "description": "Escudo curto contra esmagamento", "icon_path": "res://assets/ui/ui_aura.png", "rarity": "epic", "max_level": 4, "effects": [{"type": "shield", "value": 2.0}]},
	{"id": "timeFreeze", "name": "Time Freeze", "description": "Congela todos os aneis por pouco tempo", "icon_path": "res://assets/ui/ui_freeze.png", "rarity": "legendary", "max_level": 3, "effects": [{"type": "timeFreeze", "value": 1.0}]},
	{"id": "magnetCoins", "name": "Magnet Coins", "description": "Aumenta moedas da rodada", "icon_path": "res://assets/ui/ui_coin.png", "rarity": "rare", "max_level": 8, "effects": [{"type": "coinMultiplier", "value": 0.25}]},
	{"id": "criticalOverload", "name": "Critical Overload", "description": "Criticos acumulam dano temporario", "icon_path": "res://assets/ui/ui_crit.png", "rarity": "legendary", "max_level": 4, "effects": [{"type": "critOverload", "value": 0.30}]},
	{"id": "chronoBreak", "name": "Chrono Break", "description": "Pequena chance de congelar todos os aneis.", "icon_path": "res://assets/ui/ui_freeze.png", "rarity": "legendary", "max_level": 3, "secret": true, "effects": [{"type": "timeFreeze", "value": 1.0}]},
	{"id": "voidPulse", "name": "Void Pulse", "description": "Chance de causar dano em area ao quebrar um anel.", "icon_path": "res://assets/ui/ui_gravity.png", "rarity": "legendary", "max_level": 4, "secret": true, "effects": [{"type": "areaDamage", "value": 0.45}]},
	{"id": "diamondInstinct", "name": "Diamond Instinct", "description": "Aumenta chance de diamante em Perfect Escape.", "icon_path": "res://assets/ui/ui_gem.png", "rarity": "epic", "max_level": 4, "secret": true, "effects": [{"type": "perfectChance", "value": 0.018}]},
	{"id": "comboOverdrive", "name": "Combo Overdrive", "description": "Combos altos aumentam dano e moedas.", "icon_path": "res://assets/ui/ui_combo.png", "rarity": "legendary", "max_level": 3, "secret": true, "effects": [{"type": "comboBoost", "value": 0.25}]},
	{"id": "lastShield", "name": "Last Shield", "description": "Uma vez por partida, evita morte por esmagamento.", "icon_path": "res://assets/ui/ui_aura.png", "rarity": "legendary", "max_level": 2, "secret": true, "effects": [{"type": "lastShield", "value": 1.0}]},
	{"id": "royalBreaker", "name": "Royal Breaker", "description": "Aumenta dano contra aneis externos.", "icon_path": "res://assets/ui/ui_achievements.png", "rarity": "legendary", "max_level": 4, "secret": true, "effects": [{"type": "outerDamage", "value": 0.22}]},
	{"id": "bossHunter", "name": "Boss Hunter", "description": "Aumenta dano e XP em modos competitivos.", "icon_path": "res://assets/ui/ui_boss.png", "rarity": "epic", "max_level": 4, "secret": true, "effects": [{"type": "competitiveBoost", "value": 0.18}]},
	{"id": "secretMagnet", "name": "Secret Magnet", "description": "Aumenta moedas gerais recebidas no final.", "icon_path": "res://assets/ui/ui_coin.png", "rarity": "epic", "max_level": 5, "secret": true, "effects": [{"type": "coinMultiplier", "value": 0.18}]},
	{"id": "trophyInstinct", "name": "Trophy Instinct", "description": "Pequeno bonus de trofeus ao vencer competicoes.", "icon_path": "res://assets/ui/ui_achievements.png", "rarity": "epic", "max_level": 3, "secret": true, "effects": [{"type": "trophyBonus", "value": 2.0}]},
	{"id": "rivalCrusher", "name": "Rival Crusher", "description": "Aumenta dano e XP em partidas competitivas.", "icon_path": "res://assets/ui/ui_crit.png", "rarity": "legendary", "max_level": 3, "secret": true, "effects": [{"type": "competitiveBoost", "value": 0.24}]}
]

const PERMANENT_TO_RUN = {
	"baseDamage": ["damage"],
	"baseSpeed": ["speed"],
	"coinMultiplier": ["coinBoost"],
	"critChance": ["critical"],
	"xpBoost": ["xpBoost"],
	"perfectChance": ["perfectChance"],
	"slowRings": ["frost"]
}

var _skins_cache = []
var _skins_by_id = {}

func _ready():
	randomize()
	get_skins()

func get_skins():
	if _skins_cache.is_empty():
		_build_skins()
	return _skins_cache

func get_skin(id):
	get_skins()
	return _skins_by_id.get(id, _skins_by_id.get("neon_blue", {}))

func get_skin_rarity_color(rarity):
	return RARITY_COLORS.get(rarity, "#ffffff")

func get_chests():
	return CHESTS.duplicate(true)

func get_chest(id):
	for chest in CHESTS:
		if chest.id == id:
			return chest.duplicate(true)
	return CHESTS[0].duplicate(true)

func get_permanent_upgrades():
	return PERMANENT_UPGRADES.duplicate(true)

func get_permanent_upgrade(id):
	for upgrade in PERMANENT_UPGRADES:
		if upgrade.id == id:
			return upgrade.duplicate(true)
	return {}

func get_permanent_upgrade_cost(id, level):
	var upgrade = get_permanent_upgrade(id)
	if upgrade.is_empty():
		return 0
	return int(floor(float(upgrade.base_cost) * pow(1.5, max(0, level))))

func get_run_upgrade(id):
	for upgrade in RUN_UPGRADES:
		if upgrade.id == id:
			return upgrade.duplicate(true)
	return {}

func get_phase_config(phase_id):
	var id = clampi(int(phase_id), 1, 50)
	var tier = _tier_for_phase(id)
	var tier_start = 1
	var tier_end = 5
	if id > 40:
		tier_start = 41
		tier_end = 50
	elif id > 30:
		tier_start = 31
		tier_end = 40
	elif id > 20:
		tier_start = 21
		tier_end = 30
	elif id > 10:
		tier_start = 11
		tier_end = 20
	elif id > 5:
		tier_start = 6
		tier_end = 10
	var t = float(id - tier_start) / max(1.0, float(tier_end - tier_start))
	var ring_min = int(round(tier.min + (tier.max - tier.min) * t * 0.72))
	var ring_max = int(round(tier.min + (tier.max - tier.min) * min(1.0, t + 0.22)))
	var colors = ["#00f0ff", "#b000ff", "#ff0055", "#00ff88", "#ffd700", "#ff8800", "#ff4fd8", "#60a5fa"]
	return {
		"id": id,
		"name": "Fase %d" % id,
		"description": "Primeira arena neon com aberturas grandes." if id == 1 else tier.desc,
		"difficulty": tier.name,
		"ring_min": ring_min,
		"ring_max": max(ring_min + 2, ring_max),
		"base_hp": int(round(tier.hp + id * 6 + pow(id, 1.32) * 5.2)),
		"closing_speed": min(0.18, tier.close + t * 0.025 + id * 0.0011),
		"rotation_speed": min(0.048, tier.rotate + t * 0.0065 + id * 0.00034),
		"gap_size": max(PI / 9.5, PI / (tier.gap + t * 0.82)),
		"reward_coins": int(round(70 + id * 36 + pow(id, 1.18) * 6)),
		"reward_xp": int(round(45 + id * 22 + pow(id, 1.12) * 4)),
		"key_chance": min(0.34, 0.025 + id * 0.0058),
		"chest_chance": min(0.25, 0.015 + id * 0.0044),
		"color": colors[(id - 1) % colors.size()]
	}

func get_profile_xp_needed(level):
	return int(floor(220.0 * pow(max(1, level), 1.45)))

func get_run_xp_needed(level):
	return int(floor(150.0 * pow(max(1, level), 1.55)))

func get_combo_multiplier(combo):
	if combo >= 20:
		return {"coins": 1.28, "xp": 1.24, "label": "Ring Rush!"}
	if combo >= 10:
		return {"coins": 1.20, "xp": 1.20, "label": "Perfect Chain!"}
	if combo >= 5:
		return {"coins": 1.10, "xp": 1.10, "label": "Great!"}
	if combo >= 2:
		return {"coins": 1.05, "xp": 1.03, "label": "Combo!"}
	return {"coins": 1.0, "xp": 1.0, "label": ""}

func get_run_profile_xp(xp, rings_broken, perfect_escapes, best_combo):
	return max(8, int(floor((xp * 0.42 + rings_broken * 3.6 + perfect_escapes * 5.0 + best_combo * 1.2) * 0.95)))

func get_global_coins_from_run(run_coins, best_combo = 0, won = false):
	var combo_bonus = 1.0
	if best_combo >= 20:
		combo_bonus = 1.18
	elif best_combo >= 10:
		combo_bonus = 1.10
	elif best_combo >= 5:
		combo_bonus = 1.05
	var win_bonus = 1.08 if won else 1.0
	return max(0, int(floor(run_coins * 0.72 * combo_bonus * win_bonus)))

func is_permanent_upgrade_unlocked(id, save):
	var unlocked = save.get("unlocked_upgrades", [])
	if id in unlocked:
		return true
	if id in ["baseDamage", "baseSpeed", "coinMultiplier", "critChance"]:
		return true
	if id == "xpBoost":
		return int(save.get("current_phase", 1)) >= 3 or int(save.get("profile_level", 1)) >= 3
	if id == "perfectChance":
		return int(save.get("current_phase", 1)) >= 5 or int(save.get("profile_level", 1)) >= 5
	return false

func get_locked_permanent_upgrade_ids(save):
	var locked = []
	for upgrade in PERMANENT_UPGRADES:
		if not is_permanent_upgrade_unlocked(upgrade.id, save):
			locked.append(upgrade.id)
	return locked

func get_available_run_upgrades(save, current_levels):
	var run_ids = {}
	for starter in ["damage", "speed", "coinBoost", "critical"]:
		run_ids[starter] = true
	for permanent_id in save.get("unlocked_upgrades", []):
		for run_id in PERMANENT_TO_RUN.get(permanent_id, []):
			run_ids[run_id] = true
	var available = []
	for upgrade in RUN_UPGRADES:
		if run_ids.has(upgrade.id) and int(current_levels.get(upgrade.id, 0)) < int(upgrade.max_level):
			available.append(upgrade.duplicate(true))
	return available

func get_random_run_upgrades(count, save, current_levels):
	var available = get_available_run_upgrades(save, current_levels)
	var weighted = []
	for upgrade in available:
		var weight = 1
		if upgrade.rarity == "common":
			weight = 10
		elif upgrade.rarity == "rare":
			weight = 5
		elif upgrade.rarity == "epic":
			weight = 2
		for _i in range(weight):
			weighted.append(upgrade)
	weighted.shuffle()
	var unique = []
	var seen = {}
	for upgrade in weighted:
		if not seen.has(upgrade.id):
			seen[upgrade.id] = true
			unique.append(upgrade.duplicate(true))
			if unique.size() >= count:
				break
	for upgrade in available:
		if unique.size() >= count:
			break
		if not seen.has(upgrade.id):
			seen[upgrade.id] = true
			unique.append(upgrade.duplicate(true))
	return unique

func roll_chest_reward(chest_id, save):
	var chest = get_chest(chest_id)
	var rarity = _pick_rarity(chest)
	var utility_roll = randf()
	if utility_roll < 0.10:
		var amount = 2 if rarity in ["legendary", "mythic", "ultimate"] else 1
		return {"type": "key", "label": "Chave Lendária" if rarity in ["mythic", "ultimate"] else "Chave", "rarity": rarity, "amount": amount}
	if utility_roll < 0.20:
		var item_type = "trail" if utility_roll < 0.23 else "aura" if utility_roll < 0.285 else "effect"
		var label = "Trail %s" % rarity
		if item_type == "aura":
			label = "Aura %s" % rarity
		elif item_type == "effect":
			label = "Efeito %s" % rarity
		return {"type": item_type, "label": label, "rarity": rarity, "amount": 1}
	var candidates = []
	for skin in get_skins():
		if skin.rarity == rarity and not skin.exclusive:
			candidates.append(skin)
	if candidates.is_empty():
		candidates = get_skins()
	var selected = candidates[randi() % candidates.size()]
	if selected.id in save.get("unlocked_skins", []):
		return {
			"type": "fragments",
			"label": "Fragmentos: %s" % selected.name,
			"rarity": rarity,
			"skin_id": selected.id,
			"amount": _fragments_for_rarity(rarity),
			"is_duplicate": true
		}
	return {"type": "skin", "label": selected.name, "rarity": rarity, "skin_id": selected.id, "amount": 1}

func _build_skins():
	_skins_cache.clear()
	_skins_by_id.clear()
	for rarity in RARITY_ORDER:
		for id in RARITY_SKINS.get(rarity, []):
			var passive = _passive_for_skin(id, rarity)
			var colors = _colors_for_skin(id, rarity, passive)
			var skin = {
				"id": id,
				"name": _skin_name(id),
				"rarity": rarity,
				"description": _skin_description(id, passive),
				"path": "res://assets/images/skins/%s.png" % id,
				"primary_color": colors[0],
				"secondary_color": colors[1],
				"trail": _trail_for_passive(passive.type),
				"impact_effect": _impact_for_passive(passive.type),
				"passive": passive,
				"fragments_required": _fragments_required_for_rarity(rarity),
				"exclusive": _is_exclusive_skin(id),
				"origin": _origin_for_skin(id)
			}
			_skins_cache.append(skin)
			_skins_by_id[id] = skin

func _tier_for_phase(id):
	if id <= 5:
		return {"min": 8, "max": 16, "hp": 12, "close": 0.018, "rotate": 0.0045, "gap": 2.4, "name": "Normal", "desc": "Arena inicial com aberturas grandes e pressão baixa."}
	if id <= 10:
		return {"min": 16, "max": 24, "hp": 34, "close": 0.030, "rotate": 0.0070, "gap": 2.75, "name": "Difícil", "desc": "Rotação alternada e anéis um pouco mais resistentes."}
	if id <= 20:
		return {"min": 24, "max": 36, "hp": 68, "close": 0.045, "rotate": 0.0100, "gap": 3.15, "name": "Avançado", "desc": "Mais padrões, aberturas menores e anéis resistentes."}
	if id <= 30:
		return {"min": 36, "max": 50, "hp": 128, "close": 0.067, "rotate": 0.0140, "gap": 3.55, "name": "Extremo", "desc": "Arena exigente para skins e upgrades mais fortes."}
	if id <= 40:
		return {"min": 50, "max": 65, "hp": 220, "close": 0.092, "rotate": 0.0190, "gap": 4.05, "name": "Insano", "desc": "Padrões complexos, fechamento perigoso e melhores baús."}
	return {"min": 65, "max": 80, "hp": 340, "close": 0.120, "rotate": 0.0250, "gap": 4.60, "name": "Ultimate", "desc": "Arena premium com rotação intensa, justa e recompensas altas."}

func _pick_rarity(chest):
	var roll = randf()
	var acc = 0.0
	for rarity in RARITY_ORDER:
		acc += float(chest.chances.get(rarity, 0.0))
		if roll <= acc:
			return rarity
	return "common"

func _rarity_amount(rarity, base, step):
	var index = RARITY_ORDER.find(rarity)
	return int(base + max(0, index) * step)

func _fragments_for_rarity(rarity):
	if rarity == "common":
		return 8
	if rarity == "rare":
		return 12
	if rarity == "epic":
		return 22
	if rarity == "legendary":
		return 36
	if rarity == "mythic":
		return 48
	return 90

func _fragments_required_for_rarity(rarity):
	if rarity == "common":
		return 10
	if rarity == "rare":
		return 15
	if rarity == "epic":
		return 25
	if rarity == "legendary":
		return 40
	if rarity == "mythic":
		return 60
	return 100

func _skin_name(id):
	if SKIN_NAME_OVERRIDES.has(id):
		return SKIN_NAME_OVERRIDES[id]
	var text = id.replace("_common", "").replace("_rare", "").replace("_mythic", "").replace("_ultimate", "")
	return text.replace("_", " ").capitalize()

func _skin_description(id, passive):
	if SKIN_DESCRIPTION_OVERRIDES.has(id):
		return SKIN_DESCRIPTION_OVERRIDES[id]
	var labels = {
		"coin_on_hit": "Pode soltar moedas extras no impacto.",
		"crit_chance": "Aumenta chance critica.",
		"coin_multiplier": "Amplifica moedas recebidas.",
		"xp_multiplier": "Gera brilho de aprendizado e mais XP.",
		"damage_multiplier": "Reforca o dano da bolinha.",
		"speed": "Deixa o movimento mais agressivo.",
		"slime_bounce": "Pode recuperar impulso apos bater.",
		"phase_solid": "Chance de atravessar parte solida.",
		"slow_ring": "Desacelera aneis atingidos.",
		"repel_ring": "Empurra aneis perigosos para fora.",
		"mega_crit": "Pode causar impacto critico pesado.",
		"area_damage": "Espalha dano em aneis proximos.",
		"chain_damage": "Encadeia dano para outro anel.",
		"freeze_ring": "Congela ou desacelera aneis.",
		"burn": "Aplica dano continuo temporario.",
		"perfect_chance": "Melhora escapes perfeitos e diamantes.",
		"cosmic_critical": "Mistura critico, bonus e pulso gravitacional.",
		"league_starter_champion": "Aura de ranking com protecao e bonus.",
		"league_king_wave": "Onda de campeao em combos altos."
	}
	return labels.get(passive.type, "Skin reaproveitada da versao original.")

func _passive_for_skin(id, rarity):
	var index = max(0, RARITY_ORDER.find(rarity))
	var chance = [0.10, 0.14, 0.18, 0.22, 0.24, 0.28][index]
	if _has_any(id, ["piggy", "cow", "ladybug", "coin", "cash", "emperor", "eternal"]):
		return {"type": "coin_multiplier", "chance": 0.0, "value": 0.07 + index * 0.035}
	if _has_any(id, ["puppy", "chick", "hamster", "bee"]):
		return {"type": "coin_on_hit", "chance": chance, "value": 4 + index * 3}
	if _has_any(id, ["kitty", "tiger", "eye", "skull", "astral_crown"]):
		return {"type": "crit_chance", "chance": 0.0, "value": 3 + index * 2}
	if _has_any(id, ["fire", "flame", "phoenix", "dragon", "radioactive"]):
		return {"type": "burn", "chance": chance, "value": 4 + index * 1.5, "duration_ms": 2400 + index * 260}
	if _has_any(id, ["ice", "penguin", "frost", "chrono", "wizard"]):
		return {"type": "freeze_ring", "chance": chance, "value": 0.50, "duration_ms": 1800 + index * 260}
	if _has_any(id, ["lightning", "electric", "plasma", "orbital", "satellite"]):
		return {"type": "chain_damage", "chance": chance, "value": 0.34 + index * 0.08}
	if _has_any(id, ["black_hole", "singularity", "void", "solar", "bomb", "collapsed", "devourer"]):
		return {"type": "area_damage", "chance": chance, "value": 0.42 + index * 0.10}
	if _has_any(id, ["ripple", "guardian", "repulse"]):
		return {"type": "repel_ring", "chance": chance, "value": 18 + index * 3}
	if _has_any(id, ["bunny", "fox", "fish", "comet", "ninja", "vortex"]):
		return {"type": "speed", "chance": 0.0, "value": 0.06 + index * 0.025}
	if _has_any(id, ["monkey", "panda", "heart", "star", "prism"]):
		return {"type": "xp_multiplier", "chance": 0.0, "value": 0.07 + index * 0.035}
	if _has_any(id, ["ghost", "mask"]):
		return {"type": "phase_solid", "chance": chance * 0.55, "value": 1.0}
	if _has_any(id, ["slime", "frog", "octopus", "robot"]):
		return {"type": "slime_bounce", "chance": chance, "value": 0.12 + index * 0.02}
	if _has_any(id, ["cosmic", "omega", "divine"]):
		return {"type": "cosmic_critical", "chance": chance, "value": 0.18 + index * 0.04}
	if id == "initial_neon_champion":
		return {"type": "league_starter_champion", "chance": 0.12, "value": 0.24}
	if id == "league_king_neon":
		return {"type": "league_king_wave", "chance": 0.18, "value": 0.38}
	return {"type": "perfect_chance", "chance": 0.0, "value": 0.005 + index * 0.008}

func _colors_for_skin(id, rarity, passive):
	var palettes = {
		"coin_multiplier": ["#ffd700", "#ff8800"],
		"coin_on_hit": ["#ffcc88", "#ffd700"],
		"crit_chance": ["#ff0055", "#ffffff"],
		"burn": ["#ff6b00", "#ffdd55"],
		"freeze_ring": ["#b8f3ff", "#3b82f6"],
		"chain_damage": ["#faff00", "#00e5ff"],
		"area_damage": ["#7c3aed", "#ff4fd8"],
		"repel_ring": ["#c084fc", "#00f0ff"],
		"speed": ["#00f0ff", "#0088ff"],
		"xp_multiplier": ["#fff7ad", "#38bdf8"],
		"phase_solid": ["#dff7ff", "#8a7cff"],
		"slime_bounce": ["#3dff8f", "#00995a"],
		"cosmic_critical": ["#ffd700", "#7c3aed"],
		"league_starter_champion": ["#ffd700", "#00aaff"],
		"league_king_wave": ["#ffd700", "#8b5cf6"],
		"perfect_chance": ["#00f0ff", "#b000ff"]
	}
	return palettes.get(passive.type, [get_skin_rarity_color(rarity), "#ffffff"])

func _trail_for_passive(passive_type):
	var names = {
		"burn": "Fagulhas",
		"freeze_ring": "Cristais",
		"chain_damage": "Raios",
		"area_damage": "Pulso",
		"speed": "Cauda",
		"coin_on_hit": "Moedas",
		"coin_multiplier": "Tesouro",
		"cosmic_critical": "Cosmico"
	}
	return names.get(passive_type, "Neon")

func _impact_for_passive(passive_type):
	var names = {
		"burn": "Burn",
		"freeze_ring": "Gelo",
		"chain_damage": "Corrente",
		"area_damage": "Explosao",
		"repel_ring": "Repulsao",
		"speed": "Impacto",
		"phase_solid": "Fase"
	}
	return names.get(passive_type, "Pulso")

func _is_exclusive_skin(id):
	return _has_any(id, ["infinite", "chrono", "omega", "singularity_crown", "cosmic_fragment", "eternal_core", "cosmic_champion", "league_", "initial_neon_champion"])

func _origin_for_skin(id):
	if _has_any(id, ["infinite", "chrono", "omega", "singularity_crown", "cosmic_fragment", "eternal_core"]):
		return "Modo Infinito / marcos futuros"
	if id == "cosmic_champion":
		return "Conclusao das fases principais"
	if _has_any(id, ["league_", "initial_neon_champion"]):
		return "Liga Neon futura"
	return "Baús e loja"

func _has_any(text, needles):
	for needle in needles:
		if text.find(needle) >= 0:
			return true
	return false

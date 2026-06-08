extends Node

signal changed

const LevelData := preload("res://scripts/LevelData.gd")

const MAX_PHASE := 100
const TARGET_ACHIEVEMENT_COUNT := 100
const SAVE_EXPORT_VERSION := 1
const SAVE_EXPORT_FORMAT := "neon_idle_escape_godot_save"
const STARTER_UPGRADE_IDS := ["damage", "speed", "coinBoost", "critical"]
const NEON_PASS_MAX_LEVEL := 40
const NEON_PASS_LEVELS_PER_WEEK := 10
const NEON_PASS_SEASONS := [
	{ "id": "neon_pass_s1", "name": "Neon Awakening", "name_pt": "Despertar Neon" },
	{ "id": "neon_pass_s2", "name": "Circuit Break", "name_pt": "Ruptura de Circuito" },
	{ "id": "neon_pass_s3", "name": "Cosmic Pulse", "name_pt": "Pulso Cósmico" },
]
const NEON_PASS_SOURCE_XP := {
	"normal_level_played": 20,
	"normal_level_win": 50,
	"infinite_played": 20,
	"boss_attempt": 40,
	"boss_win": 100,
	"league_battle": 40,
	"league_win": 80,
	"daily_challenge": 60,
	"event_mission": 75,
	"first_win_of_day": 100,
}
const NEON_PASS_SKIN_REWARDS := {
	"neon_pass_s1": {
		10: "neon_pass_initial",
		40: "neon_pass_guardian",
	},
	"neon_pass_s2": {
		10: "weekly_circuit",
		40: "neon_commander",
	},
	"neon_pass_s3": {
		10: "pass_avatar",
		40: "neon_sovereign",
	},
}
const UPGRADE_MAX_LEVEL_OVERRIDES := {
	"damage": 50,
	"speed": 40,
	"coinBoost": 50,
	"critical": 40,
	"xpBoost": 45,
	"perfectChance": 30,
	"magnetCoins": 35,
	"burn": 30,
	"penetration": 30,
	"ricochet": 28,
	"bounce": 25,
	"ringRepulse": 25,
	"frost": 30,
	"shockwave": 25,
	"chainLightning": 24,
	"slowField": 24,
	"bomb": 20,
	"laser": 20,
	"laserCut": 20,
	"shieldPulse": 18,
	"bossHunter": 25,
	"secretMagnet": 30,
	"diamondInstinct": 24,
	"trophyInstinct": 20,
	"multihit": 12,
	"chainBreak": 16,
	"criticalOverload": 16,
	"timeFreeze": 12,
	"chronoBreak": 10,
	"voidPulse": 14,
	"comboOverdrive": 14,
	"lastShield": 5,
	"royalBreaker": 18,
	"rivalCrusher": 16,
}
const UPGRADE_EFFECT_CAPS := {
	"damage": 3.6,
	"speed": 1.65,
	"coinBoost": 3.5,
	"critical": 0.35,
	"xpBoost": 3.0,
	"perfectChance": 0.08,
	"diamondInstinct": 0.08,
	"frost": 0.48,
	"timeFreeze": 0.42,
	"chronoBreak": 0.38,
	"slowField": 0.45,
	"ringRepulse": 0.42,
	"chainLightning": 0.50,
	"chainBreak": 0.48,
	"shockwave": 0.44,
	"voidPulse": 0.44,
	"bomb": 0.42,
	"burn": 1.55,
	"penetration": 1.45,
	"laser": 1.60,
	"laserCut": 1.55,
	"multihit": 0.72,
	"criticalOverload": 0.33,
	"royalBreaker": 1.20,
	"bossHunter": 1.05,
	"trophyInstinct": 0.42,
	"comboOverdrive": 0.62,
	"magnetCoins": 2.10,
	"secretMagnet": 1.65,
	"ricochet": 1.15,
	"bounce": 1.00,
}
const UPGRADE_RUN_BONUS_CAPS := {
	"damage": 20,
	"speed": 20,
	"coinBoost": 20,
	"critical": 20,
	"xpBoost": 20,
	"perfectChance": 15,
	"magnetCoins": 15,
	"burn": 15,
	"penetration": 15,
	"ricochet": 15,
	"bounce": 12,
	"ringRepulse": 12,
	"frost": 12,
	"shockwave": 10,
	"chainLightning": 10,
	"slowField": 10,
	"bomb": 8,
	"laser": 8,
	"laserCut": 8,
	"shieldPulse": 6,
	"bossHunter": 10,
	"secretMagnet": 10,
	"diamondInstinct": 8,
	"trophyInstinct": 8,
	"multihit": 5,
	"chainBreak": 6,
	"criticalOverload": 6,
	"timeFreeze": 4,
	"chronoBreak": 4,
	"voidPulse": 5,
	"comboOverdrive": 6,
	"lastShield": 2,
	"royalBreaker": 6,
	"rivalCrusher": 6,
}
const UPGRADE_RUN_EXTRA_EFFECT_CAPS := {
	"damage": 0.90,
	"speed": 0.32,
	"coinBoost": 0.85,
	"critical": 0.07,
	"xpBoost": 0.75,
	"perfectChance": 0.018,
	"diamondInstinct": 0.018,
	"frost": 0.08,
	"timeFreeze": 0.05,
	"chronoBreak": 0.04,
	"slowField": 0.06,
	"ringRepulse": 0.06,
	"chainLightning": 0.08,
	"chainBreak": 0.07,
	"shockwave": 0.07,
	"voidPulse": 0.06,
	"bomb": 0.06,
	"burn": 0.32,
	"penetration": 0.28,
	"laser": 0.30,
	"laserCut": 0.30,
	"multihit": 0.12,
	"criticalOverload": 0.05,
	"royalBreaker": 0.22,
	"bossHunter": 0.20,
	"trophyInstinct": 0.08,
	"comboOverdrive": 0.12,
	"magnetCoins": 0.42,
	"secretMagnet": 0.32,
	"ricochet": 0.16,
	"bounce": 0.12,
}
const SKIN_MAX_LEVEL_BY_RARITY := {
	"common": 5,
	"rare": 6,
	"epic": 7,
	"legendary": 8,
	"mythic": 9,
	"ultimate": 10,
}
const SKIN_UPGRADE_BASE_COSTS := {
	"common": { "coins": 150, "diamonds": 2 },
	"rare": { "coins": 400, "diamonds": 5 },
	"epic": { "coins": 900, "diamonds": 10 },
	"legendary": { "coins": 1800, "diamonds": 20 },
	"mythic": { "coins": 3600, "diamonds": 40 },
	"ultimate": { "coins": 8000, "diamonds": 90 },
}
const SKIN_UPGRADE_GROWTH := {
	"common": 1.82,
	"rare": 1.68,
	"epic": 1.55,
	"legendary": 1.48,
	"mythic": 1.42,
	"ultimate": 1.36,
}

const PERMANENT_UPGRADE_DEFS := {
	"baseDamage": { "base_cost": 70, "max": 50, "phase": 1, "level": 1 },
	"baseSpeed": { "base_cost": 85, "max": 40, "phase": 1, "level": 1 },
	"coinMultiplier": { "base_cost": 120, "max": 50, "phase": 1, "level": 1 },
	"critChance": { "base_cost": 110, "max": 40, "phase": 1, "level": 1 },
	"xpBoost": { "base_cost": 135, "max": 45, "phase": 3, "level": 3 },
	"perfectChance": { "base_cost": 320, "max": 30, "phase": 5, "level": 5 },
	"slowRings": { "base_cost": 440, "max": 30, "phase": 8, "level": 9 },
}

const TEMP_UPGRADE_UNLOCKS := {
	"damage": { "phase": 1, "level": 1 },
	"speed": { "phase": 1, "level": 1 },
	"coinBoost": { "phase": 1, "level": 1 },
	"critical": { "phase": 1, "level": 1 },
	"xpBoost": { "phase": 3, "level": 3 },
	"perfectChance": { "phase": 5, "level": 5 },
	"burn": { "phase": 5, "level": 5 },
	"ricochet": { "phase": 7, "level": 7 },
	"ringRepulse": { "phase": 7, "level": 7 },
	"frost": { "phase": 8, "level": 8 },
	"shockwave": { "phase": 10, "level": 12 },
	"chainLightning": { "phase": 10, "level": 10 },
}

const SKIN_UNLOCK_MILESTONES := {
	"neon_blue": { "phase": 1, "level": 1, "source": "Inicial" },
	"puppy": { "phase": 2, "level": 1, "source": "Marco de fase temporario" },
	"kitty": { "phase": 3, "level": 2, "source": "Marco de fase temporario" },
	"piggy": { "phase": 4, "level": 2, "source": "Marco de fase temporario" },
	"bunny": { "phase": 5, "level": 3, "source": "Marco de fase temporario" },
	"slime": { "phase": 6, "level": 3, "source": "Marco de fase temporario" },
	"ghost": { "phase": 7, "level": 4, "source": "Marco de fase temporario" },
	"robot": { "phase": 9, "level": 5, "source": "Marco de fase temporario" },
	"crystal": { "phase": 12, "level": 7, "source": "Marco de fase temporario" },
	"comet": { "phase": 15, "level": 9, "source": "Marco de fase temporario" },
}

const SKIN_RARITY_ORDER := ["common", "rare", "epic", "legendary", "mythic", "ultimate"]
const SKIN_COLLECTION_TOTAL_MILESTONES := [5, 10, 25, 50, 75, 100]
const SKIN_EFFECT_ACHIEVEMENTS := [
	{ "id": "control", "label": "Control", "label_pt": "Controle", "metric": "skinEffectControlUnlocked", "required": 3, "reward": { "type": "diamonds", "amount": 22 }, "rarity": "rare" },
	{ "id": "fire", "label": "Fire", "label_pt": "Fogo", "metric": "skinEffectFireUnlocked", "required": 5, "reward": { "type": "coins", "amount": 1800 }, "rarity": "rare" },
	{ "id": "ice", "label": "Ice", "label_pt": "Gelo", "metric": "skinEffectIceUnlocked", "required": 5, "reward": { "type": "diamonds", "amount": 28 }, "rarity": "epic" },
	{ "id": "critical", "label": "Critical", "label_pt": "Critico", "metric": "skinEffectCriticalUnlocked", "required": 5, "reward": { "type": "keys", "amount": 1 }, "rarity": "epic" },
	{ "id": "coins", "label": "Coins", "label_pt": "Moedas", "metric": "skinEffectCoinsUnlocked", "required": 5, "reward": { "type": "coins", "amount": 2500 }, "rarity": "rare" },
	{ "id": "xp", "label": "XP", "label_pt": "XP", "metric": "skinEffectXPUnlocked", "required": 5, "reward": { "type": "xp", "amount": 450 }, "rarity": "rare" },
	{ "id": "speed", "label": "Speed", "label_pt": "Velocidade", "metric": "skinEffectSpeedUnlocked", "required": 5, "reward": { "type": "diamonds", "amount": 24 }, "rarity": "epic" },
	{ "id": "chain", "label": "Chain", "label_pt": "Corrente", "metric": "skinEffectChainUnlocked", "required": 5, "reward": { "type": "chest", "chest_type": "rare", "amount": 1 }, "rarity": "epic" },
	{ "id": "area", "label": "Area", "label_pt": "Area", "metric": "skinEffectAreaUnlocked", "required": 5, "reward": { "type": "chest", "chest_type": "rare", "amount": 1 }, "rarity": "epic" },
	{ "id": "phase", "label": "Phase", "label_pt": "Fase", "metric": "skinEffectPhaseUnlocked", "required": 3, "reward": { "type": "diamonds", "amount": 35 }, "rarity": "epic" },
	{ "id": "gravity", "label": "Gravity", "label_pt": "Gravidade", "metric": "skinEffectGravityUnlocked", "required": 3, "reward": { "type": "keys", "amount": 2 }, "rarity": "legendary" },
]

const ACHIEVEMENTS := [
	{ "id": "first_steps", "name": "First Steps", "name_pt": "Primeiros Passos", "desc": "Play your first run.", "desc_pt": "Jogue a primeira partida.", "metric": "runsPlayed", "required": 1, "reward": { "type": "coins", "amount": 250 }, "rarity": "common" },
	{ "id": "first_perfect", "name": "First Perfect", "name_pt": "Primeiro Escape", "desc": "Make 1 Perfect Escape.", "desc_pt": "Faça 1 escape perfeito.", "metric": "perfectEscapes", "required": 1, "reward": { "type": "diamonds", "amount": 8 }, "rarity": "rare" },
	{ "id": "ring_breaker_1", "name": "Ring Breaker I", "name_pt": "Quebrador de Aneis I", "desc": "Destroy 50 rings.", "desc_pt": "Destrua 50 aneis.", "metric": "ringsDestroyed", "required": 50, "reward": { "type": "coins", "amount": 500 }, "rarity": "common" },
	{ "id": "ring_breaker_2", "name": "Ring Breaker II", "name_pt": "Quebrador de Aneis II", "desc": "Destroy 250 rings.", "desc_pt": "Destrua 250 aneis.", "metric": "ringsDestroyed", "required": 250, "reward": { "type": "keys", "amount": 1 }, "rarity": "rare" },
	{ "id": "ring_breaker_3", "name": "Ring Breaker III", "name_pt": "Quebrador de Aneis III", "desc": "Destroy 1000 rings.", "desc_pt": "Destrua 1000 aneis.", "metric": "ringsDestroyed", "required": 1000, "reward": { "type": "chest", "chest_type": "rare", "amount": 1 }, "rarity": "epic" },
	{ "id": "perfect_hunter", "name": "Perfect Hunter", "name_pt": "Cacador de Perfect", "desc": "Make 25 Perfect Escapes.", "desc_pt": "Faca 25 Perfect Escapes.", "metric": "perfectEscapes", "required": 25, "reward": { "type": "diamonds", "amount": 35 }, "rarity": "epic" },
	{ "id": "diamond_miner", "name": "Diamond Miner", "name_pt": "Garimpeiro de Diamantes", "desc": "Find 10 diamonds.", "desc_pt": "Ganhe 10 diamantes.", "metric": "diamondsFound", "required": 10, "reward": { "type": "diamonds", "amount": 40 }, "rarity": "rare" },
	{ "id": "infinite_first", "name": "Endless Glow", "name_pt": "Brilho Infinito", "desc": "Play Infinite Mode once.", "desc_pt": "Jogue o Modo Infinito uma vez.", "metric": "infiniteRuns", "required": 1, "reward": { "type": "coins", "amount": 400 }, "rarity": "common" },
	{ "id": "infinite_survivor", "name": "Neon Survivor", "name_pt": "Sobrevivente Neon", "desc": "Survive 60 seconds in Infinite Mode.", "desc_pt": "Sobreviva 60 segundos no Modo Infinito.", "metric": "bestInfiniteSeconds", "required": 60, "reward": { "type": "diamonds", "amount": 18 }, "rarity": "rare" },
	{ "id": "inf_survive_3", "name": "Stable Loop", "name_pt": "Loop Estavel", "desc": "Survive 3 minutes in Infinite Mode.", "desc_pt": "Sobreviva 3 minutos no Modo Infinito.", "metric": "bestInfiniteSeconds", "required": 180, "reward": { "type": "skin", "skin_id": "loop_flame" }, "rarity": "rare" },
	{ "id": "inf_survive_5", "name": "Neon Eclipse", "name_pt": "Eclipse Neon", "desc": "Survive 5 minutes in Infinite Mode.", "desc_pt": "Sobreviva 5 minutos no Modo Infinito.", "metric": "bestInfiniteSeconds", "required": 300, "reward": { "type": "skin", "skin_id": "neon_eclipse" }, "rarity": "epic" },
	{ "id": "infinite_breaker", "name": "Endless Breaker", "name_pt": "Quebrador Infinito", "desc": "Destroy 25 rings in one Infinite Mode run.", "desc_pt": "Destrua 25 aneis em uma partida infinita.", "metric": "bestInfiniteRings", "required": 25, "reward": { "type": "skin", "skin_id": "blue_vortex" }, "rarity": "epic" },
	{ "id": "inf_rings_50", "name": "Red Comet", "name_pt": "Cometa Rubro", "desc": "Destroy 50 rings in one Infinite Mode run.", "desc_pt": "Destrua 50 aneis em uma partida infinita.", "metric": "bestInfiniteRings", "required": 50, "reward": { "type": "skin", "skin_id": "red_comet" }, "rarity": "rare" },
	{ "id": "inf_rings_100", "name": "Endless Prism", "name_pt": "Prisma Sem Fim", "desc": "Destroy 100 rings in one Infinite Mode run.", "desc_pt": "Destrua 100 aneis em uma partida infinita.", "metric": "bestInfiniteRings", "required": 100, "reward": { "type": "skin", "skin_id": "endless_prism" }, "rarity": "epic" },
	{ "id": "inf_level_5", "name": "Neon Roguelike I", "name_pt": "Roguelike Neon I", "desc": "Reach run level 5 in Infinite Mode.", "desc_pt": "Alcance nivel 5 em uma run infinita.", "metric": "infiniteBestLevel", "required": 5, "reward": { "type": "coins", "amount": 1200 }, "rarity": "epic" },
	{ "id": "inf_level_10", "name": "Neon Roguelike II", "name_pt": "Roguelike Neon II", "desc": "Reach run level 10 in Infinite Mode.", "desc_pt": "Alcance nivel 10 em uma run infinita.", "metric": "infiniteBestLevel", "required": 10, "reward": { "type": "diamonds", "amount": 100 }, "rarity": "legendary" },
	{ "id": "combo_starter", "name": "Combo Starter", "name_pt": "Inicio de Combo", "desc": "Reach combo 5.", "desc_pt": "Alcance combo 5.", "metric": "bestCombo", "required": 5, "reward": { "type": "coins", "amount": 350 }, "rarity": "common" },
	{ "id": "combo_10", "name": "Neon Combo", "name_pt": "Combo Neon", "desc": "Reach combo 10.", "desc_pt": "Alcance combo 10.", "metric": "bestCombo", "required": 10, "reward": { "type": "keys", "amount": 1 }, "rarity": "rare" },
	{ "id": "skin_effect_10", "name": "Skin Spark", "name_pt": "Centelha de Skin", "desc": "Trigger 10 skin effects.", "desc_pt": "Ative 10 efeitos de skin.", "metric": "skinEffects", "required": 10, "reward": { "type": "diamonds", "amount": 12 }, "rarity": "rare" },
	{ "id": "critical_5", "name": "Critical Glow", "name_pt": "Brilho Critico", "desc": "Make 5 critical hits.", "desc_pt": "Faca 5 criticos.", "metric": "criticals", "required": 5, "reward": { "type": "xp", "amount": 90 }, "rarity": "common" },
	{ "id": "skin_equipped", "name": "Fresh Glow", "name_pt": "Brilho Novo", "desc": "Equip a skin.", "desc_pt": "Equipe uma skin.", "metric": "skinEquips", "required": 1, "reward": { "type": "diamonds", "amount": 5 }, "rarity": "common" },
	{ "id": "upgrade_stack", "name": "Power Stack", "name_pt": "Pilha de Poder", "desc": "Buy 5 permanent upgrades.", "desc_pt": "Compre 5 melhorias permanentes.", "metric": "upgradesBought", "required": 5, "reward": { "type": "chest", "chest_type": "rare", "amount": 1 }, "rarity": "rare" },
	{ "id": "stage_champion", "name": "Neon Champion", "name_pt": "Campeao Neon", "desc": "Unlock 50 phases.", "desc_pt": "Libere 50 fases.", "metric": "highestPhase", "required": 50, "reward": { "type": "skin", "skin_id": "cosmic_champion" }, "rarity": "special" },
	{ "id": "collector", "name": "Starter Collector", "name_pt": "Colecionador Inicial", "desc": "Unlock 5 skins.", "desc_pt": "Desbloqueie 5 skins.", "metric": "skinsUnlocked", "required": 5, "reward": { "type": "chest", "chest_type": "common", "amount": 1 }, "rarity": "rare" },
	{ "id": "rare_collector", "name": "Rare Collector", "name_pt": "Colecionador Raro", "desc": "Unlock 5 rare skins.", "desc_pt": "Desbloqueie 5 skins raras.", "metric": "rareSkinsUnlocked", "required": 5, "reward": { "type": "chest", "chest_type": "rare", "amount": 1 }, "rarity": "epic" },
	{ "id": "epic_luck", "name": "Epic Luck", "name_pt": "Sorte Epica", "desc": "Unlock 1 epic skin.", "desc_pt": "Obtenha 1 skin epica.", "metric": "epicSkinsUnlocked", "required": 1, "reward": { "type": "diamonds", "amount": 30 }, "rarity": "epic" },
	{ "id": "legend_awake", "name": "Legend Awake", "name_pt": "Lenda Desperta", "desc": "Unlock 1 legendary skin.", "desc_pt": "Obtenha 1 skin lendaria.", "metric": "legendarySkinsUnlocked", "required": 1, "reward": { "type": "chest", "chest_type": "epic", "amount": 1 }, "rarity": "legendary" },
	{ "id": "chest_opener_1", "name": "Chest Opener I", "name_pt": "Abridor de Baus I", "desc": "Open 5 chests.", "desc_pt": "Abra 5 baus.", "metric": "chestsOpened", "required": 5, "reward": { "type": "coins", "amount": 600 }, "rarity": "common" },
	{ "id": "daily_claim", "name": "Daily Glow", "name_pt": "Brilho Diario", "desc": "Claim a daily reward.", "desc_pt": "Colete uma recompensa diaria.", "metric": "dailyRewardsCollected", "required": 1, "reward": { "type": "diamonds", "amount": 10 }, "rarity": "rare" },
	{ "id": "wheel_spin", "name": "Lucky Spin", "name_pt": "Giro da Sorte", "desc": "Spin the wheel once.", "desc_pt": "Gire a roleta uma vez.", "metric": "wheelSpins", "required": 1, "reward": { "type": "coins", "amount": 300 }, "rarity": "common" },
	{ "id": "upgrade_buyer", "name": "Power Buyer", "name_pt": "Comprador de Poder", "desc": "Buy one permanent upgrade.", "desc_pt": "Compre uma melhoria permanente.", "metric": "upgradesBought", "required": 1, "reward": { "type": "diamonds", "amount": 6 }, "rarity": "common" },
	{ "id": "store_buyer", "name": "Neon Shopper", "name_pt": "Comprador Neon", "desc": "Buy or claim something in the shop.", "desc_pt": "Compre ou resgate algo na loja.", "metric": "storePurchases", "required": 1, "reward": { "type": "diamonds", "amount": 6 }, "rarity": "common" },
]

const MODE_REWARD_ACHIEVEMENTS := [
	{ "id": "daily_challenge_first", "name": "Daily Challenger", "name_pt": "Desafiante Diário", "desc": "Play one Daily Challenge.", "desc_pt": "Jogue um Desafio Diário.", "metric": "dailyChallengeRuns", "required": 1, "reward": { "type": "coins", "amount": 500 }, "rarity": "common" },
	{ "id": "daily_challenge_clear", "name": "Daily Clear", "name_pt": "Diário Concluído", "desc": "Complete one Daily Challenge.", "desc_pt": "Conclua um Desafio Diário.", "metric": "dailyChallengeCompletions", "required": 1, "reward": { "type": "diamonds", "amount": 16 }, "rarity": "rare" },
	{ "id": "daily_challenge_score", "name": "Seed Breaker", "name_pt": "Quebrador de Seed", "desc": "Reach 3500 score in Daily Challenge.", "desc_pt": "Alcance 3500 pontos no Desafio Diário.", "metric": "dailyChallengeBestScore", "required": 3500, "reward": { "type": "chest", "chest_type": "rare", "amount": 1 }, "rarity": "epic" },
	{ "id": "league_match_3", "name": "League Regular", "name_pt": "Frequente da Liga", "desc": "Play 3 Neon League matches.", "desc_pt": "Jogue 3 partidas da Liga Neon.", "metric": "leagueMatches", "required": 3, "reward": { "type": "coins", "amount": 750 }, "rarity": "common" },
	{ "id": "league_win_3", "name": "League Spark", "name_pt": "Faísca da Liga", "desc": "Win 3 Neon League matches.", "desc_pt": "Vença 3 partidas da Liga Neon.", "metric": "leagueWins", "required": 3, "reward": { "type": "diamonds", "amount": 22 }, "rarity": "rare" },
	{ "id": "league_gold_reward", "name": "Gold Division", "name_pt": "Divisão Ouro", "desc": "Reach Gold in Neon League.", "desc_pt": "Alcance a Liga Ouro.", "metric": "leagueGoldReached", "required": 1, "reward": { "type": "chest", "chest_type": "rare", "amount": 1 }, "rarity": "epic" },
	{ "id": "league_legend_reward", "name": "Legend Division", "name_pt": "Divisão Lendária", "desc": "Reach Legendary in Neon League.", "desc_pt": "Alcance a Liga Lendária.", "metric": "leagueLegendaryReached", "required": 1, "reward": { "type": "legendaryKeys", "amount": 1 }, "rarity": "legendary" },
	{ "id": "boss_first_win", "name": "Boss Breaker", "name_pt": "Quebra-Boss", "desc": "Defeat any boss.", "desc_pt": "Derrote qualquer boss.", "metric": "bossWins", "required": 1, "reward": { "type": "coins", "amount": 900 }, "rarity": "rare" },
	{ "id": "boss_three_wins", "name": "Boss Hunter II", "name_pt": "Caçador de Boss II", "desc": "Defeat 3 bosses.", "desc_pt": "Derrote 3 bosses.", "metric": "bossWins", "required": 3, "reward": { "type": "diamonds", "amount": 45 }, "rarity": "epic" },
	{ "id": "boss_elite_reward", "name": "Elite Boss Clear", "name_pt": "Boss Elite Limpo", "desc": "Defeat an Elite Boss.", "desc_pt": "Derrote o Boss Elite.", "metric": "bossEliteWins", "required": 1, "reward": { "type": "chest", "chest_type": "rare", "amount": 1 }, "rarity": "epic" },
	{ "id": "boss_impossible_reward", "name": "Impossible Boss Clear", "name_pt": "Boss Impossível Limpo", "desc": "Defeat the Impossible Boss.", "desc_pt": "Derrote o Boss Impossível.", "metric": "bossImpossibleWins", "required": 1, "reward": { "type": "chest", "chest_type": "epic", "amount": 1 }, "rarity": "legendary" },
]

const SKIN_REWARD_ACHIEVEMENTS := [
	{ "id": "skin_reward_mini_ruby", "name": "Ruby Start", "name_pt": "Inicio Rubi", "desc": "Make 3 critical hits.", "desc_pt": "Faça 3 criticos.", "metric": "criticals", "required": 3, "reward": { "type": "skin", "skin_id": "mini_ruby_orb" }, "rarity": "common" },
	{ "id": "skin_reward_prism_drop", "name": "Prism Perfect", "name_pt": "Perfect Prismático", "desc": "Make 12 Perfect Escapes.", "desc_pt": "Faça 12 Perfect Escapes.", "metric": "perfectEscapes", "required": 12, "reward": { "type": "skin", "skin_id": "prism_drop" }, "rarity": "rare" },
	{ "id": "skin_reward_frost_guardian", "name": "Cold Perfects", "name_pt": "Perfects Gelados", "desc": "Make 40 Perfect Escapes.", "desc_pt": "Faça 40 Perfect Escapes.", "metric": "perfectEscapes", "required": 40, "reward": { "type": "skin", "skin_id": "frost_guardian" }, "rarity": "epic" },
	{ "id": "skin_reward_astral_mirror", "name": "Phase Mirror", "name_pt": "Espelho de Fase", "desc": "Unlock phase 35.", "desc_pt": "Libere a fase 35.", "metric": "highestPhase", "required": 35, "reward": { "type": "skin", "skin_id": "astral_mirror" }, "rarity": "epic" },
	{ "id": "skin_reward_cosmic_serpent", "name": "Serpent Combo", "name_pt": "Combo Serpente", "desc": "Reach combo 30.", "desc_pt": "Alcance combo 30.", "metric": "bestCombo", "required": 30, "reward": { "type": "skin", "skin_id": "cosmic_serpent" }, "rarity": "legendary" },
	{ "id": "skin_reward_chronal_orb", "name": "Chronal Survivor", "name_pt": "Sobrevivente Cronal", "desc": "Survive 8 minutes in Infinite Mode.", "desc_pt": "Sobreviva 8 minutos no Modo Infinito.", "metric": "bestInfiniteSeconds", "required": 480, "reward": { "type": "skin", "skin_id": "chronal_orb" }, "rarity": "mythic" },
	{ "id": "skin_reward_living_star", "name": "Living Star Run", "name_pt": "Run da Estrela Viva", "desc": "Survive 12 minutes in Infinite Mode.", "desc_pt": "Sobreviva 12 minutos no Modo Infinito.", "metric": "bestInfiniteSeconds", "required": 720, "reward": { "type": "skin", "skin_id": "living_star" }, "rarity": "mythic" },
	{ "id": "skin_reward_void_eye", "name": "Void League", "name_pt": "Liga do Vazio", "desc": "Reach Diamond in Neon League.", "desc_pt": "Alcance a Liga Diamante.", "metric": "leagueDiamondReached", "required": 1, "reward": { "type": "skin", "skin_id": "void_eye" }, "rarity": "mythic" },
	{ "id": "skin_reward_ether_guardian", "name": "Ether League", "name_pt": "Liga de Eter", "desc": "Reach Legendary in Neon League.", "desc_pt": "Alcance a Liga Lendária.", "metric": "leagueLegendaryReached", "required": 1, "reward": { "type": "skin", "skin_id": "ether_guardian" }, "rarity": "mythic" },
	{ "id": "skin_reward_eclipse_god", "name": "Eclipse God", "name_pt": "Deus do Eclipse", "desc": "Unlock phase 50.", "desc_pt": "Libere a fase 50.", "metric": "highestPhase", "required": 50, "reward": { "type": "skin", "skin_id": "eclipse_god" }, "rarity": "ultimate" },
	{ "id": "skin_reward_genesis_core", "name": "Genesis Core", "name_pt": "Nucleo Genesis", "desc": "Unlock phase 75.", "desc_pt": "Libere a fase 75.", "metric": "highestPhase", "required": 75, "reward": { "type": "skin", "skin_id": "genesis_core" }, "rarity": "ultimate" },
	{ "id": "skin_reward_prismatic_omega", "name": "Prismatic Omega", "name_pt": "Omega Prismatico", "desc": "Unlock phase 100.", "desc_pt": "Libere a fase 100.", "metric": "highestPhase", "required": 100, "reward": { "type": "skin", "skin_id": "prismatic_omega" }, "rarity": "ultimate" },
	{ "id": "skin_reward_multiverse_heart", "name": "Multiverse Marathon", "name_pt": "Maratona Multiverso", "desc": "Survive 25 minutes in Infinite Mode.", "desc_pt": "Sobreviva 25 minutos no Modo Infinito.", "metric": "bestInfiniteSeconds", "required": 1500, "reward": { "type": "skin", "skin_id": "multiverse_heart" }, "rarity": "ultimate" },
	{ "id": "skin_reward_neon_emperor", "name": "Neon Emperor", "name_pt": "Imperador Neon", "desc": "Reach Ultimate in Neon League.", "desc_pt": "Alcance a Liga Ultimate.", "metric": "leagueUltimateReached", "required": 1, "reward": { "type": "skin", "skin_id": "neon_emperor" }, "rarity": "ultimate" },
]

const RUN_UPGRADE_UNLOCK_ACHIEVEMENTS := [
	{ "id": "unlock_burn_phase_5", "name": "Fire Circuit", "name_pt": "Circuito de Fogo", "desc": "Unlock phase 5.", "desc_pt": "Libere a fase 5.", "metric": "highestPhase", "required": 5, "reward": { "type": "upgrade", "upgrade_id": "burn" }, "rarity": "rare" },
	{ "id": "unlock_magnet_coins_1500", "name": "Coin Magnet", "name_pt": "Ima de Moedas", "desc": "Earn 1500 run coins.", "desc_pt": "Ganhe 1500 moedas em partidas.", "metric": "runCoins", "required": 1500, "reward": { "type": "upgrade", "upgrade_id": "magnetCoins" }, "rarity": "rare" },
	{ "id": "unlock_bounce_combo_5", "name": "Bounce Line", "name_pt": "Linha de Ricochete", "desc": "Reach combo 5.", "desc_pt": "Alcance combo 5.", "metric": "bestCombo", "required": 5, "reward": { "type": "upgrade", "upgrade_id": "bounce" }, "rarity": "rare" },
	{ "id": "unlock_ricochet_phase_7", "name": "Living Ricochet", "name_pt": "Ricochete Vivo", "desc": "Unlock phase 7.", "desc_pt": "Libere a fase 7.", "metric": "highestPhase", "required": 7, "reward": { "type": "upgrade", "upgrade_id": "ricochet" }, "rarity": "rare" },
	{ "id": "unlock_penetration_rings_250", "name": "Toxic Cut", "name_pt": "Corte Toxico", "desc": "Destroy 250 rings.", "desc_pt": "Destrua 250 aneis.", "metric": "ringsDestroyed", "required": 250, "reward": { "type": "upgrade", "upgrade_id": "penetration" }, "rarity": "rare" },
	{ "id": "unlock_frost_infinite_60", "name": "Frozen Minute", "name_pt": "Minuto Congelado", "desc": "Survive 60 seconds in Infinite Mode.", "desc_pt": "Sobreviva 60 segundos no Modo Infinito.", "metric": "bestInfiniteSeconds", "required": 60, "reward": { "type": "upgrade", "upgrade_id": "frost" }, "rarity": "epic" },
	{ "id": "unlock_ring_repulse_silver", "name": "Silver Pulse", "name_pt": "Pulso de Prata", "desc": "Reach Silver in Neon League.", "desc_pt": "Alcance a Liga Prata.", "metric": "leagueSilverReached", "required": 1, "reward": { "type": "upgrade", "upgrade_id": "ringRepulse" }, "rarity": "rare" },
	{ "id": "unlock_shockwave_boss_normal", "name": "Boss Shock", "name_pt": "Choque no Boss", "desc": "Defeat a Normal Boss.", "desc_pt": "Derrote o Boss Normal.", "metric": "bossNormalWins", "required": 1, "reward": { "type": "upgrade", "upgrade_id": "shockwave" }, "rarity": "epic" },
	{ "id": "unlock_chain_lightning_infinite_50", "name": "Endless Spark", "name_pt": "Faísca Infinita", "desc": "Destroy 50 rings in one Infinite run.", "desc_pt": "Destrua 50 aneis em uma partida infinita.", "metric": "bestInfiniteRings", "required": 50, "reward": { "type": "upgrade", "upgrade_id": "chainLightning" }, "rarity": "epic" },
	{ "id": "unlock_slow_field_infinite_180", "name": "Slow Orbit", "name_pt": "Orbita Lenta", "desc": "Survive 180 seconds in Infinite Mode.", "desc_pt": "Sobreviva 180 segundos no Modo Infinito.", "metric": "bestInfiniteSeconds", "required": 180, "reward": { "type": "upgrade", "upgrade_id": "slowField" }, "rarity": "epic" },
	{ "id": "unlock_bomb_boss_strong", "name": "Explosive Rival", "name_pt": "Rival Explosivo", "desc": "Defeat a Strong Boss.", "desc_pt": "Derrote o Boss Forte.", "metric": "bossStrongWins", "required": 1, "reward": { "type": "upgrade", "upgrade_id": "bomb" }, "rarity": "epic" },
	{ "id": "unlock_laser_phase_25", "name": "Phase Laser", "name_pt": "Laser de Fase", "desc": "Unlock phase 25.", "desc_pt": "Libere a fase 25.", "metric": "highestPhase", "required": 25, "reward": { "type": "upgrade", "upgrade_id": "laser" }, "rarity": "epic" },
	{ "id": "unlock_laser_cut_boss_elite", "name": "Elite Cut", "name_pt": "Corte Elite", "desc": "Defeat an Elite Boss.", "desc_pt": "Derrote o Boss Elite.", "metric": "bossEliteWins", "required": 1, "reward": { "type": "upgrade", "upgrade_id": "laserCut" }, "rarity": "epic" },
	{ "id": "unlock_multihit_gold", "name": "Golden Multi-Hit", "name_pt": "Multi-Hit Dourado", "desc": "Reach Gold in Neon League.", "desc_pt": "Alcance a Liga Ouro.", "metric": "leagueGoldReached", "required": 1, "reward": { "type": "upgrade", "upgrade_id": "multihit" }, "rarity": "legendary" },
	{ "id": "unlock_chain_break_infinite_100", "name": "Chain Breaker", "name_pt": "Quebra-Corrente", "desc": "Destroy 100 rings in one Infinite run.", "desc_pt": "Destrua 100 aneis em uma partida infinita.", "metric": "bestInfiniteRings", "required": 100, "reward": { "type": "upgrade", "upgrade_id": "chainBreak" }, "rarity": "legendary" },
	{ "id": "unlock_shield_pulse_boss_legendary", "name": "Legend Shield", "name_pt": "Escudo Lendario", "desc": "Defeat a Legendary Boss.", "desc_pt": "Derrote o Boss Lendario.", "metric": "bossLegendaryWins", "required": 1, "reward": { "type": "upgrade", "upgrade_id": "shieldPulse" }, "rarity": "epic" },
	{ "id": "unlock_time_freeze_boss_impossible", "name": "Impossible Freeze", "name_pt": "Congelamento Impossivel", "desc": "Defeat an Impossible Boss.", "desc_pt": "Derrote o Boss Impossivel.", "metric": "bossImpossibleWins", "required": 1, "reward": { "type": "upgrade", "upgrade_id": "timeFreeze" }, "rarity": "legendary" },
	{ "id": "unlock_critical_overload_diamond", "name": "Diamond Overload", "name_pt": "Sobrecarga Diamante", "desc": "Reach Diamond in Neon League.", "desc_pt": "Alcance a Liga Diamante.", "metric": "leagueDiamondReached", "required": 1, "reward": { "type": "upgrade", "upgrade_id": "criticalOverload" }, "rarity": "legendary" },
	{ "id": "unlock_chrono_break_infinite_300", "name": "Chrono Break", "name_pt": "Ruptura Cronal", "desc": "Survive 300 seconds in Infinite Mode.", "desc_pt": "Sobreviva 300 segundos no Modo Infinito.", "metric": "bestInfiniteSeconds", "required": 300, "reward": { "type": "upgrade", "upgrade_id": "chronoBreak" }, "rarity": "legendary" },
	{ "id": "unlock_void_pulse_rings_1000", "name": "Void Pulse", "name_pt": "Pulso do Vazio", "desc": "Destroy 1000 rings.", "desc_pt": "Destrua 1000 aneis.", "metric": "ringsDestroyed", "required": 1000, "reward": { "type": "upgrade", "upgrade_id": "voidPulse" }, "rarity": "legendary" },
	{ "id": "unlock_diamond_instinct_perfect_25", "name": "Diamond Instinct", "name_pt": "Instinto de Diamante", "desc": "Make 25 Perfect Escapes.", "desc_pt": "Faca 25 Perfect Escapes.", "metric": "perfectEscapes", "required": 25, "reward": { "type": "upgrade", "upgrade_id": "diamondInstinct" }, "rarity": "epic" },
	{ "id": "unlock_combo_overdrive_combo_20", "name": "Combo Overdrive", "name_pt": "Sobrecarga de Combo", "desc": "Reach combo 20.", "desc_pt": "Alcance combo 20.", "metric": "bestCombo", "required": 20, "reward": { "type": "upgrade", "upgrade_id": "comboOverdrive" }, "rarity": "legendary" },
	{ "id": "unlock_last_shield_phase_50", "name": "Last Shield", "name_pt": "Ultimo Escudo", "desc": "Unlock phase 50.", "desc_pt": "Libere a fase 50.", "metric": "highestPhase", "required": 50, "reward": { "type": "upgrade", "upgrade_id": "lastShield" }, "rarity": "legendary" },
	{ "id": "unlock_royal_breaker_phase_75", "name": "Royal Breaker", "name_pt": "Quebrador Real", "desc": "Unlock phase 75.", "desc_pt": "Libere a fase 75.", "metric": "highestPhase", "required": 75, "reward": { "type": "upgrade", "upgrade_id": "royalBreaker" }, "rarity": "legendary" },
	{ "id": "unlock_boss_hunter_boss_3", "name": "Boss Hunter", "name_pt": "Cacador de Boss", "desc": "Defeat 3 bosses.", "desc_pt": "Derrote 3 bosses.", "metric": "bossWins", "required": 3, "reward": { "type": "upgrade", "upgrade_id": "bossHunter" }, "rarity": "epic" },
	{ "id": "unlock_secret_magnet_run_coins_5000", "name": "Secret Magnet", "name_pt": "Ima Secreto", "desc": "Earn 5000 run coins.", "desc_pt": "Ganhe 5000 moedas em partidas.", "metric": "runCoins", "required": 5000, "reward": { "type": "upgrade", "upgrade_id": "secretMagnet" }, "rarity": "epic" },
	{ "id": "unlock_trophy_instinct_legendary", "name": "Trophy Instinct", "name_pt": "Instinto de Trofeu", "desc": "Reach Legendary in Neon League.", "desc_pt": "Alcance a Liga Lendaria.", "metric": "leagueLegendaryReached", "required": 1, "reward": { "type": "upgrade", "upgrade_id": "trophyInstinct" }, "rarity": "epic" },
	{ "id": "unlock_rival_crusher_ultimate", "name": "Rival Crusher", "name_pt": "Esmagador de Rivais", "desc": "Reach Ultimate in Neon League.", "desc_pt": "Alcance a Liga Ultimate.", "metric": "leagueUltimateReached", "required": 1, "reward": { "type": "upgrade", "upgrade_id": "rivalCrusher" }, "rarity": "legendary" },
]


func get_achievements() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for achievement in ACHIEVEMENTS:
		_append_unique_achievement(result, Dictionary(achievement).duplicate(true))
	for achievement in MODE_REWARD_ACHIEVEMENTS:
		_append_unique_achievement(result, Dictionary(achievement).duplicate(true))
	for achievement in SKIN_REWARD_ACHIEVEMENTS:
		_append_unique_achievement(result, Dictionary(achievement).duplicate(true))
	for achievement in RUN_UPGRADE_UNLOCK_ACHIEVEMENTS:
		_append_unique_achievement(result, Dictionary(achievement).duplicate(true))
	_append_skin_collection_achievements(result)
	_append_phase_achievements(result)
	_append_infinite_achievements(result)
	_append_progress_achievements(result)
	for i in range(result.size()):
		result[i] = _normalize_achievement_metadata(Dictionary(result[i]))
	return result


func get_achievement_summary() -> Dictionary:
	_update_achievements(false)
	var achievements: Dictionary = data.get("achievements", {})
	var summary := {
		"total": 0,
		"completed": 0,
		"claimed": 0,
		"claimable": 0,
		"by_category": {},
	}
	for achievement in get_achievements():
		var id := String(achievement.get("id", ""))
		if id.is_empty():
			continue
		var category := String(achievement.get("category", "progress"))
		var state: Dictionary = achievements.get(id, {})
		var completed := bool(state.get("completed", false))
		var claimed := bool(state.get("claimed", false))
		var claimable := completed and not claimed
		summary["total"] = int(summary.get("total", 0)) + 1
		if completed:
			summary["completed"] = int(summary.get("completed", 0)) + 1
		if claimed:
			summary["claimed"] = int(summary.get("claimed", 0)) + 1
		if claimable:
			summary["claimable"] = int(summary.get("claimable", 0)) + 1
		var by_category: Dictionary = summary.get("by_category", {})
		var category_summary: Dictionary = by_category.get(category, {
			"total": 0,
			"completed": 0,
			"claimed": 0,
			"claimable": 0,
		})
		category_summary["total"] = int(category_summary.get("total", 0)) + 1
		if completed:
			category_summary["completed"] = int(category_summary.get("completed", 0)) + 1
		if claimed:
			category_summary["claimed"] = int(category_summary.get("claimed", 0)) + 1
		if claimable:
			category_summary["claimable"] = int(category_summary.get("claimable", 0)) + 1
		by_category[category] = category_summary
		summary["by_category"] = by_category
	return summary


func _normalize_achievement_metadata(achievement: Dictionary) -> Dictionary:
	var category := String(achievement.get("category", ""))
	if category == "collection":
		category = "skins"
	if category.is_empty():
		category = _infer_achievement_category(achievement)
	achievement["category"] = category
	if not achievement.has("subtype") or String(achievement.get("subtype", "")).is_empty():
		achievement["subtype"] = category
	return achievement


func _infer_achievement_category(achievement: Dictionary) -> String:
	var id := String(achievement.get("id", "")).to_lower()
	var metric := String(achievement.get("metric", "")).to_lower()
	var reward: Dictionary = Dictionary(achievement.get("reward", {}))
	var reward_type := String(reward.get("type", "")).to_lower()
	if id.begins_with("skin_") or metric.begins_with("skin") or reward_type == "skin":
		return "skins"
	if id.begins_with("unlock_") or reward_type in ["upgrade", "run_upgrade", "upgrade_unlock"] or metric.contains("upgrade"):
		return "upgrades"
	if id.begins_with("phase_") or metric in ["highestphase", "phasewins", "phasecompletions"]:
		return "phases"
	if id.begins_with("infinite_") or metric.contains("infinite"):
		return "infinite"
	if id.contains("boss") or metric.contains("boss"):
		return "boss"
	if id.contains("league") or metric.contains("league"):
		return "league"
	if id.contains("daily") or id.contains("wheel") or id.contains("event") or metric.contains("daily") or metric.contains("wheel") or metric.contains("event"):
		return "daily"
	if metric.contains("ring") or metric.contains("perfect") or metric.contains("coin") or metric.contains("chest") or metric.contains("diamond") or metric.contains("combo") or metric.contains("critical"):
		return "progress"
	return "progress"


func _append_skin_collection_achievements(result: Array[Dictionary]) -> void:
	var total_skins := _skin_total_available()
	for target in SKIN_COLLECTION_TOTAL_MILESTONES:
		if target > total_skins:
			continue
		_append_unique_achievement(result, {
			"id": "skin_collection_total_%s" % target,
			"name": "Collect %s Skins" % target,
			"name_pt": "Colete %s Skins" % target,
			"desc": "Collect %s skins." % target,
			"desc_pt": "Colete %s skins." % target,
			"metric": "skinsUnlocked",
			"required": target,
			"reward": _skin_collection_reward(target),
			"rarity": _milestone_rarity(target),
			"category": "collection",
			"subtype": "skin_total",
		})
	if total_skins > 0:
		_append_unique_achievement(result, {
			"id": "skin_collection_all_available",
			"name": "Complete Skin Collection",
			"name_pt": "Colecao de Skins Completa",
			"desc": "Collect every available skin.",
			"desc_pt": "Colete todas as skins disponiveis.",
			"metric": "skinsUnlocked",
			"required": total_skins,
			"reward": { "type": "skin", "skin_id": "prismatic_omega" },
			"rarity": "ultimate",
			"category": "collection",
			"subtype": "skin_total",
		})
	_append_skin_rarity_achievements(result)
	_append_skin_effect_achievements(result)
	_append_skin_evolution_achievements(result)
	_append_skin_usage_achievements(result)


func _append_skin_rarity_achievements(result: Array[Dictionary]) -> void:
	var milestones := {
		"common": [10, 20],
		"rare": [10, 20],
		"epic": [5, 15],
		"legendary": [3, 10],
		"mythic": [1, 5, 10],
		"ultimate": [1, 3, 5],
	}
	for rarity in SKIN_RARITY_ORDER:
		var total := _skin_rarity_total(rarity)
		var metric := "%sSkinsUnlocked" % rarity
		for target in Array(milestones.get(rarity, [])):
			if target > total:
				continue
			_append_unique_achievement(result, _skin_metric_achievement(
				"skin_rarity_%s_%s" % [rarity, target],
				"Collect %s %s skins" % [target, _rarity_label(rarity).to_lower()],
				"Colete %s skins %s" % [target, _rarity_label_pt(rarity).to_lower()],
				"Collect %s %s skins." % [target, _rarity_label(rarity).to_lower()],
				"Colete %s skins %s." % [target, _rarity_label_pt(rarity).to_lower()],
				metric,
				target,
				_skin_rarity_reward(rarity, target),
				rarity,
				"collection",
				"skin_rarity"
			))
		if total > 0:
			_append_unique_achievement(result, _skin_metric_achievement(
				"skin_rarity_%s_all" % rarity,
				"All %s Skins" % _rarity_label(rarity),
				"Todas as Skins %s" % _rarity_label_pt(rarity),
				"Collect every %s skin." % _rarity_label(rarity).to_lower(),
				"Colete todas as skins %s." % _rarity_label_pt(rarity).to_lower(),
				metric,
				total,
				_skin_rarity_all_reward(rarity),
				rarity,
				"collection",
				"skin_rarity_all"
			))


func _append_skin_effect_achievements(result: Array[Dictionary]) -> void:
	for meta in SKIN_EFFECT_ACHIEVEMENTS:
		var effect_id := String(meta.get("id", ""))
		var total := _skin_effect_total(effect_id)
		var required := int(meta.get("required", 1))
		if total <= 0:
			continue
		required = min(required, total)
		_append_unique_achievement(result, _skin_metric_achievement(
			"skin_effect_%s_%s" % [effect_id, required],
			"%s Skin Collector" % String(meta.get("label", effect_id)).capitalize(),
			"Colecionador de %s" % String(meta.get("label_pt", effect_id)),
			"Collect %s skins with %s effects." % [required, String(meta.get("label", effect_id)).to_lower()],
			"Colete %s skins com efeito %s." % [required, String(meta.get("label_pt", effect_id)).to_lower()],
			String(meta.get("metric", "")),
			required,
			Dictionary(meta.get("reward", {})).duplicate(true),
			String(meta.get("rarity", "rare")),
			"skins",
			"skin_effect"
		))


func _append_skin_evolution_achievements(result: Array[Dictionary]) -> void:
	var definitions := [
		{ "id": "skin_evolution_level_2", "name": "First Polish", "name_pt": "Primeiro Polimento", "desc": "Upgrade any skin to level 2.", "desc_pt": "Melhore uma skin ate o nivel 2.", "metric": "skinAnyLevel2", "required": 1, "reward": { "type": "coins", "amount": 900 }, "rarity": "common" },
		{ "id": "skin_evolution_first_max", "name": "Max Glow", "name_pt": "Brilho Maximo", "desc": "Upgrade any skin to max level.", "desc_pt": "Melhore uma skin ate o nivel maximo.", "metric": "skinMaxedCount", "required": 1, "reward": { "type": "diamonds", "amount": 45 }, "rarity": "epic" },
		{ "id": "skin_evolution_upgrade_5", "name": "Skin Workshop I", "name_pt": "Oficina de Skins I", "desc": "Upgrade 5 different skins.", "desc_pt": "Melhore 5 skins diferentes.", "metric": "skinsUpgradedCount", "required": 5, "reward": { "type": "keys", "amount": 1 }, "rarity": "rare" },
		{ "id": "skin_evolution_upgrade_10", "name": "Skin Workshop II", "name_pt": "Oficina de Skins II", "desc": "Upgrade 10 different skins.", "desc_pt": "Melhore 10 skins diferentes.", "metric": "skinsUpgradedCount", "required": 10, "reward": { "type": "chest", "chest_type": "rare", "amount": 1 }, "rarity": "epic" },
	]
	for definition in definitions:
		var achievement := Dictionary(definition).duplicate(true)
		achievement["category"] = "skins"
		achievement["subtype"] = "skin_evolution"
		_append_unique_achievement(result, achievement)
	for rarity in SKIN_RARITY_ORDER:
		_append_unique_achievement(result, _skin_metric_achievement(
			"skin_evolution_max_%s" % rarity,
			"Max %s Skin" % _rarity_label(rarity),
			"Skin %s Maxima" % _rarity_label_pt(rarity),
			"Upgrade one %s skin to max level." % _rarity_label(rarity).to_lower(),
			"Melhore uma skin %s ate o nivel maximo." % _rarity_label_pt(rarity).to_lower(),
			"skin%sMaxed" % rarity.capitalize(),
			1,
			_skin_rarity_all_reward(rarity),
			rarity,
			"skins",
			"skin_evolution"
		))


func _append_skin_usage_achievements(result: Array[Dictionary]) -> void:
	var definitions := [
		{ "id": "skin_usage_common_phase_10", "name": "Common Champion", "name_pt": "Campeao Comum", "desc": "Win 10 phases with a common skin equipped.", "desc_pt": "Venca 10 fases com uma skin comum equipada.", "metric": "skinCommonPhaseWins", "required": 10, "reward": { "type": "coins", "amount": 1600 }, "rarity": "common" },
		{ "id": "skin_usage_rare_phase_10", "name": "Rare Champion", "name_pt": "Campeao Raro", "desc": "Win 10 phases with a rare skin equipped.", "desc_pt": "Venca 10 fases com uma skin rara equipada.", "metric": "skinRarePhaseWins", "required": 10, "reward": { "type": "diamonds", "amount": 22 }, "rarity": "rare" },
		{ "id": "skin_usage_epic_phase_10", "name": "Epic Champion", "name_pt": "Campeao Epico", "desc": "Win 10 phases with an epic skin equipped.", "desc_pt": "Venca 10 fases com uma skin epica equipada.", "metric": "skinEpicPhaseWins", "required": 10, "reward": { "type": "chest", "chest_type": "rare", "amount": 1 }, "rarity": "epic" },
		{ "id": "skin_usage_control_infinite_5m", "name": "Controlled Survival", "name_pt": "Sobrevivencia Controlada", "desc": "Survive 5 minutes in Infinite Mode with a Control skin.", "desc_pt": "Sobreviva 5 minutos no Modo Infinito com uma skin de Controle.", "metric": "skinControlInfiniteSeconds", "required": 300, "reward": { "type": "diamonds", "amount": 50 }, "rarity": "epic" },
		{ "id": "skin_usage_fire_boss_win", "name": "Fire Boss Breaker", "name_pt": "Quebra-Boss de Fogo", "desc": "Defeat a boss with a Fire skin.", "desc_pt": "Derrote um boss com uma skin de Fogo.", "metric": "skinFireBossWins", "required": 1, "reward": { "type": "chest", "chest_type": "rare", "amount": 1 }, "rarity": "epic" },
		{ "id": "skin_usage_ultimate_league_win", "name": "Ultimate League Glow", "name_pt": "Brilho Ultimate da Liga", "desc": "Win a Neon League match with an Ultimate skin.", "desc_pt": "Venca uma partida da Liga Neon com uma skin Ultimate.", "metric": "skinUltimateLeagueWins", "required": 1, "reward": { "type": "diamonds", "amount": 90 }, "rarity": "ultimate" },
		{ "id": "skin_usage_ice_control_perfects_50", "name": "Precision Chill", "name_pt": "Precisao Gelada", "desc": "Make 50 Perfect Escapes with Ice or Control skins.", "desc_pt": "Faca 50 Perfect Escapes com skins de Gelo ou Controle.", "metric": "skinIceControlPerfects", "required": 50, "reward": { "type": "keys", "amount": 3 }, "rarity": "legendary" },
		{ "id": "skin_usage_legendary_rings_1000", "name": "Legendary Breaker", "name_pt": "Quebrador Lendario", "desc": "Destroy 1000 rings with legendary or better skins.", "desc_pt": "Destrua 1000 aneis com skins lendarias ou superiores.", "metric": "skinLegendaryPlusRings", "required": 1000, "reward": { "type": "chest", "chest_type": "epic", "amount": 1 }, "rarity": "legendary" },
	]
	for definition in definitions:
		var achievement := Dictionary(definition).duplicate(true)
		achievement["category"] = "skins"
		achievement["subtype"] = "skin_usage"
		_append_unique_achievement(result, achievement)


func _skin_metric_achievement(id: String, name: String, name_pt: String, desc: String, desc_pt: String, metric: String, required: int, reward: Dictionary, rarity: String, category: String, subtype: String) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"name_pt": name_pt,
		"desc": desc,
		"desc_pt": desc_pt,
		"metric": metric,
		"required": required,
		"reward": reward,
		"rarity": rarity,
		"category": category,
		"subtype": subtype,
	}


func get_next_skin_collection_goal() -> Dictionary:
	_update_skin_collection_stats()
	var stats: Dictionary = data.get("stats", {})
	for achievement in get_achievements():
		if String(achievement.get("subtype", "")) != "skin_total":
			continue
		var progress := int(stats.get(String(achievement.get("metric", "")), 0))
		if progress < int(achievement.get("required", 1)):
			var result := achievement.duplicate(true)
			result["progress"] = progress
			return result
	return {}


func _append_phase_achievements(result: Array[Dictionary]) -> void:
	for milestone in [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100]:
		_append_unique_achievement(result, {
			"id": "phase_unlock_%s" % milestone,
			"name": "Phase %s Glow" % milestone,
			"name_pt": "Brilho da Fase %s" % milestone,
			"desc": "Unlock phase %s." % milestone,
			"desc_pt": "Libere a fase %s." % milestone,
			"metric": "highestPhase",
			"required": milestone,
			"reward": _milestone_reward(milestone, "phase"),
			"rarity": _milestone_rarity(milestone),
		})
	for wins in [3, 5, 10, 20, 35, 50, 75, 100]:
		_append_unique_achievement(result, {
			"id": "phase_wins_%s" % wins,
			"name": "%s Phase Wins" % wins,
			"name_pt": "%s Vitorias de Fase" % wins,
			"desc": "Complete %s phase runs." % wins,
			"desc_pt": "Conclua %s partidas de fase." % wins,
			"metric": "phaseWins",
			"required": wins,
			"reward": _milestone_reward(wins, "wins"),
			"rarity": _milestone_rarity(wins),
		})


func _append_infinite_achievements(result: Array[Dictionary]) -> void:
	for seconds in [30, 60, 120, 180, 300, 480, 600, 900, 1200, 1800, 2400, 3600]:
		_append_unique_achievement(result, {
			"id": "infinite_survive_%s" % seconds,
			"name": "Survive %ss" % seconds,
			"name_pt": "Sobreviver %ss" % seconds,
			"desc": "Reach %s seconds in Infinite Mode." % seconds,
			"desc_pt": "Alcance %s segundos no Modo Infinito." % seconds,
			"metric": "bestInfiniteSeconds",
			"required": seconds,
			"reward": _milestone_reward(seconds, "time"),
			"rarity": _milestone_rarity(floori(float(seconds) / 12.0)),
		})
	for rings in [10, 25, 50, 75, 100, 150, 250, 400, 600, 900, 1200]:
		_append_unique_achievement(result, {
			"id": "infinite_rings_%s" % rings,
			"name": "%s Endless Rings" % rings,
			"name_pt": "%s Aneis Infinitos" % rings,
			"desc": "Break %s rings in one Infinite Mode run." % rings,
			"desc_pt": "Quebre %s aneis em uma partida infinita." % rings,
			"metric": "bestInfiniteRings",
			"required": rings,
			"reward": _milestone_reward(rings, "infinite_rings"),
			"rarity": _milestone_rarity(rings),
		})
	for level in [3, 5, 8, 10, 14, 18, 24, 30]:
		_append_unique_achievement(result, {
			"id": "infinite_level_%s" % level,
			"name": "Infinite Level %s" % level,
			"name_pt": "Nivel Infinito %s" % level,
			"desc": "Reach run level %s in Infinite Mode." % level,
			"desc_pt": "Alcance nivel %s em uma run infinita." % level,
			"metric": "infiniteBestLevel",
			"required": level,
			"reward": _milestone_reward(level * 30, "level"),
			"rarity": _milestone_rarity(level * 8),
		})


func _append_progress_achievements(result: Array[Dictionary]) -> void:
	for rings in [100, 250, 500, 1000, 2000, 3500, 5000, 7500, 10000, 15000]:
		_append_unique_achievement(result, _metric_achievement("rings_total_%s" % rings, "%s Total Rings" % rings, "%s Aneis Totais" % rings, "Break %s rings total." % rings, "Quebre %s aneis no total." % rings, "ringsDestroyed", rings, _milestone_reward(rings, "rings"), _milestone_rarity(floori(float(rings) / 8.0))))
	for perfects in [5, 10, 25, 50, 100, 200, 350]:
		_append_unique_achievement(result, _metric_achievement("perfect_total_%s" % perfects, "%s Perfects" % perfects, "%s Perfects" % perfects, "Make %s Perfect Escapes." % perfects, "Faça %s Perfect Escapes." % perfects, "perfectEscapes", perfects, _milestone_reward(perfects, "perfect"), _milestone_rarity(perfects)))
	for coins in [500, 1500, 5000, 15000, 50000, 100000]:
		_append_unique_achievement(result, _metric_achievement("coins_total_%s" % coins, "%s Run Coins" % coins, "%s Moedas de Run" % coins, "Earn %s run coins." % coins, "Ganhe %s moedas em runs." % coins, "runCoins", coins, _milestone_reward(floori(float(coins) / 10.0), "coins"), _milestone_rarity(floori(float(coins) / 500.0))))
	for upgrades in [1, 5, 10, 20, 35, 50]:
		_append_unique_achievement(result, _metric_achievement("upgrades_total_%s" % upgrades, "%s Upgrades" % upgrades, "%s Melhorias" % upgrades, "Buy %s permanent upgrades." % upgrades, "Compre %s melhorias permanentes." % upgrades, "upgradesBought", upgrades, _milestone_reward(upgrades * 30, "upgrades"), _milestone_rarity(upgrades * 3)))
	for skins in [3, 5, 10, 20, 35, 50]:
		_append_unique_achievement(result, _metric_achievement("skins_total_%s" % skins, "%s Skins" % skins, "%s Skins" % skins, "Unlock %s skins." % skins, "Desbloqueie %s skins." % skins, "skinsUnlocked", skins, _milestone_reward(skins * 40, "skins"), _milestone_rarity(skins * 4)))
	for chests in [1, 5, 15, 30, 60]:
		_append_unique_achievement(result, _metric_achievement("chests_total_%s" % chests, "%s Chests" % chests, "%s Baus" % chests, "Open %s chests." % chests, "Abra %s baus." % chests, "chestsOpened", chests, _milestone_reward(chests * 35, "chests"), _milestone_rarity(chests * 5)))
	for daily in [1, 3, 7, 14, 30]:
		_append_unique_achievement(result, _metric_achievement("daily_total_%s" % daily, "%s Daily Rewards" % daily, "%s Recompensas Diarias" % daily, "Claim %s daily rewards." % daily, "Colete %s recompensas diarias." % daily, "dailyRewardsCollected", daily, _milestone_reward(daily * 25, "daily"), _milestone_rarity(daily * 4)))
	for spins in [1, 5, 15, 35]:
		_append_unique_achievement(result, _metric_achievement("wheel_total_%s" % spins, "%s Wheel Spins" % spins, "%s Giros da Roleta" % spins, "Spin the wheel %s times." % spins, "Gire a roleta %s vezes." % spins, "wheelSpins", spins, _milestone_reward(spins * 30, "wheel"), _milestone_rarity(spins * 4)))
	for wins in [1, 5, 10, 25]:
		_append_unique_achievement(result, _metric_achievement("league_wins_%s" % wins, "%s League Wins" % wins, "%s Vitorias na Liga" % wins, "Win %s Neon League matches." % wins, "Venca %s partidas da Liga Neon." % wins, "leagueWins", wins, _milestone_reward(wins * 50, "league"), _milestone_rarity(wins * 6)))


func _metric_achievement(id: String, name: String, name_pt: String, desc: String, desc_pt: String, metric: String, required: int, reward: Dictionary, rarity: String) -> Dictionary:
	return { "id": id, "name": name, "name_pt": name_pt, "desc": desc, "desc_pt": desc_pt, "metric": metric, "required": required, "reward": reward, "rarity": rarity }


func _append_unique_achievement(result: Array[Dictionary], achievement: Dictionary) -> void:
	var id := String(achievement.get("id", ""))
	if id.is_empty():
		return
	for existing in result:
		if String(existing.get("id", "")) == id:
			return
	result.append(achievement)


func _milestone_rarity(value: int) -> String:
	if value >= 180:
		return "legendary"
	if value >= 80:
		return "epic"
	if value >= 25:
		return "rare"
	return "common"


func _milestone_reward(value: int, category: String) -> Dictionary:
	if category == "phase" and value >= 100:
		return { "type": "chest", "chest_type": "epic", "amount": 1 }
	if value >= 600 and category in ["phase", "time", "infinite_rings", "skins"]:
		return { "type": "chest", "chest_type": "epic", "amount": 1 }
	if value >= 250 and category in ["phase", "rings", "chests", "league"]:
		return { "type": "chest", "chest_type": "rare", "amount": 1 }
	if value >= 180 and category in ["perfect", "time", "level", "wheel"]:
		return { "type": "diamonds", "amount": min(180, 24 + floori(float(value) / 5.0)) }
	if category in ["chests", "daily", "league"] and value >= 120:
		return { "type": "keys", "amount": 1 }
	if category in ["phase", "wins", "rings", "coins", "upgrades"]:
		return { "type": "coins", "amount": max(220, value * 12) }
	if category in ["perfect", "time", "skins", "wheel"]:
		return { "type": "diamonds", "amount": max(8, floori(float(value) / 4.0)) }
	return { "type": "xp", "amount": max(70, value * 4) }


const DAILY_REWARDS := [
	{ "type": "coins", "amount": 300 },
	{ "type": "diamonds", "amount": 18 },
	{ "type": "keys", "amount": 1 },
	{ "type": "chest", "chest_type": "common", "amount": 1 },
	{ "type": "chest", "chest_type": "rare", "amount": 1 },
	{ "type": "diamonds", "amount": 55 },
	{ "type": "chest", "chest_type": "epic", "amount": 1 },
]

const WHEEL_REWARDS := [
	{ "type": "coins", "amount": 280 },
	{ "type": "coins", "amount": 650 },
	{ "type": "diamonds", "amount": 8 },
	{ "type": "diamonds", "amount": 18 },
	{ "type": "keys", "amount": 1 },
	{ "type": "chest", "chest_type": "common", "amount": 1 },
	{ "type": "chest", "chest_type": "rare", "amount": 1 },
	{ "type": "xp", "amount": 250 },
	{ "type": "chest", "chest_type": "epic", "amount": 1 },
]

const DAILY_MISSION_DEFS := [
	{ "id": "runs_3", "title": "Play 3 runs", "title_pt": "Jogar 3 partidas", "metric": "runsPlayed", "target": 3, "reward": { "type": "xp", "amount": 180 } },
	{ "id": "win_1", "title": "Win 1 phase", "title_pt": "Vencer 1 fase", "metric": "phaseWins", "target": 1, "reward": { "type": "diamonds", "amount": 10 } },
	{ "id": "rings_50", "title": "Destroy 50 rings", "title_pt": "Destruir 50 aneis", "metric": "ringsDestroyed", "target": 50, "reward": { "type": "coins", "amount": 420 } },
	{ "id": "perfect_3", "title": "Make 3 Perfect Escapes", "title_pt": "Fazer 3 Perfect Escapes", "metric": "perfectEscapes", "target": 3, "reward": { "type": "diamonds", "amount": 8 } },
	{ "id": "store_buy", "title": "Buy or claim in the shop", "title_pt": "Comprar ou resgatar na loja", "metric": "storePurchases", "target": 1, "reward": { "type": "diamonds", "amount": 8 } },
	{ "id": "wheel_spin", "title": "Spin the wheel", "title_pt": "Girar a roleta", "metric": "wheelSpins", "target": 1, "reward": { "type": "coins", "amount": 380 } },
]

var data: Dictionary = {}
var _save_timer: Timer
var _save_pending := false


func _ready() -> void:
	_ensure_save_timer()
	load_game()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		data["last_exit_at"] = TimeManager.get_now_timestamp()
		flush_save()


func default_save() -> Dictionary:
	var now := int(Time.get_unix_time_from_system())
	return {
		"player_id": "player_%s" % now,
		"nickname": "Player",
		"avatar": "blue",
		"avatar_image_path": "",
		"coins": 600,
		"diamonds": 60,
		"keys": 1,
		"legendary_keys": 0,
		"inventory": {},
		"last_reward_text": "",
		"xp": 0,
		"level": 1,
		"profile_xp": 0,
		"current_phase": 1,
		"selected_phase": 1,
		"selected_mode": "phase",
		"max_unlocked_phase": 1,
		"unlocked_phases": [1],
		"unlocked_skins": ["neon_blue"],
		"equipped_skin": "neon_blue",
		"favorite_skin": "neon_blue",
		"skin_levels": { "neon_blue": 1 },
		"skin_fragments": {},
		"unlocked_upgrade_ids": ["damage", "speed", "coinBoost", "critical"],
		"unlocked_upgrades": ["damage", "speed", "coinBoost", "critical"],
		"explicit_unlocked_run_upgrades": [],
		"upgrade_levels": {},
		"permanent_upgrades": {},
		"settings": {
			"audio_muted": false,
			"music_muted": false,
			"sfx_muted": false,
			"master_muted": false,
			"language": "en",
			"debug_enabled": false,
		},
		"tutorial": {
			"seen": false,
			"dont_show_again": false,
			"completed_at": 0,
			"debug_reset_available": true,
			"guided_hints": {
				"open_upgrades": false,
				"open_skins": false,
				"modes": false,
			},
		},
		"last_exit_at": now,
			"last_login_at": now,
			"last_daily_reward_at": 0,
			"first_win_claimed_date": "",
			"first_win_completed_today": false,
			"last_first_win_reward": {},
			"last_afk_claim_timestamp": 0,
			"daily_streak": 0,
		"pending_afk_rewards": {},
		"events": {},
		"boss": { "last_attempt_at": 0 },
		"league": {
			"trophies": 0,
			"season_key": TimeManager.get_month_key(),
			"last_season_key": "",
			"last_season_summary": {},
			"bronze_promotion_skin_claimed": false,
			"highest_rank_id": "bronze",
			"season_reward_claimed": false,
			"wins": 0,
			"losses": 0,
			"quits": 0,
			"win_streak": 0,
			"best_streak": 0,
			"matches": 0,
			"last_opponent_id": "",
		},
		"wheel": { "day_key": "", "free_used": false, "ad_spins_used": 0, "last_reward": {} },
		"daily_challenge": {
			"day_key": "",
			"seed_override": "",
			"records": {},
			"days": {},
			"last_result": {},
		},
		"neon_pass_season_id": "neon_pass_s1",
		"neon_pass_level": 1,
		"neon_pass_xp": 0,
		"neon_pass_week_index": 1,
		"neon_pass_weekly_level_cap": NEON_PASS_LEVELS_PER_WEEK,
		"neon_pass_total_xp": 0,
		"neon_pass_last_updated_at": now,
		"neon_pass_last_first_win_day_key": "",
		"neon_pass_season_progress": {},
		"neon_pass_claimed_rewards": {},
		"neon_pass_reward_history": [],
		"neon_pass_debug_week_offset": 0,
		"neon_pass_debug_season_offset": 0,
		"ads": {
			"mock_enabled": true,
			"completed": {},
			"failed": {},
			"cooldowns": {},
			"last_completed": "",
			"last_completed_at": 0,
			"last_failed": "",
			"last_failed_at": 0,
		},
		"daily_missions": { "day_key": "", "missions": [] },
		"achievements": {},
		"skin_usage": {},
		"stats": {
			"totalPlayTimeSeconds": 0,
			"totalMatches": 0,
			"wins": 0,
			"losses": 0,
			"phaseCompletions": 0,
			"totalXpEarned": 0,
			"totalCoinsEarned": 0,
			"totalDiamondsEarned": 0,
			"totalKeysEarned": 0,
			"runs_played": 0,
			"rings_destroyed": 0,
			"perfect_escapes": 0,
			"diamonds_found": 0,
			"chests_opened": 0,
			"chestsOpened": 0,
			"chestsEarned": 0,
			"skins_unlocked": 1,
			"skinsMaxed": 0,
			"rareSkinsUnlocked": 0,
			"epicSkinsUnlocked": 0,
			"legendarySkinsUnlocked": 0,
			"highest_phase": 1,
			"highest_run_level": 1,
			"infinite_runs": 0,
			"infiniteRuns": 0,
			"best_infinite_seconds": 0,
			"bestInfiniteSeconds": 0,
			"best_infinite_rings": 0,
			"bestInfiniteRings": 0,
			"best_infinite_score": 0,
			"bestInfiniteScore": 0,
			"infiniteBestLevel": 0,
			"bestCombo": 0,
			"runCoins": 0,
			"runUpgrades": 0,
			"criticals": 0,
			"skinEffects": 0,
			"noReviveWins": 0,
			"boss_runs": 0,
			"boss_wins": 0,
			"boss_losses": 0,
			"bossRuns": 0,
			"bossWins": 0,
			"bossLosses": 0,
			"bossDamageTotal": 0,
			"bossBestTime": 0,
			"bossNormalWins": 0,
			"bossStrongWins": 0,
			"bossEliteWins": 0,
			"bossLegendaryWins": 0,
			"bossImpossibleWins": 0,
			"bossBestLevelIndex": 0,
			"daily_rewards_collected": 0,
			"dailyChallengeRuns": 0,
			"dailyChallengeCompletions": 0,
			"dailyChallengeBestScore": 0,
			"dailyChallengeBestRings": 0,
			"phaseWins": 0,
			"wheelSpins": 0,
			"storePurchases": 0,
			"upgradesBought": 0,
			"upgradesUnlocked": 4,
			"upgradesMaxed": 0,
			"skinEquips": 0,
			"leagueMatches": 0,
			"leagueWins": 0,
			"leagueLosses": 0,
			"leagueQuits": 0,
			"leagueTrophies": 0,
			"highestLeagueTrophies": 0,
			"leagueTrophiesTotal": 0,
			"leagueWinStreak": 0,
			"leagueRankIndex": 0,
			"leagueSilverReached": 0,
			"leagueGoldReached": 0,
			"leagueDiamondReached": 0,
			"leagueLegendaryReached": 0,
			"leagueUltimateReached": 0,
			"neonPassXpEarned": 0,
			"neonPassRewardsClaimed": 0,
			"eventsCompleted": 0,
			"eventMissionsCompleted": 0,
			"eventRewardsClaimed": 0,
			"bestInfiniteReward": 0,
		},
	}


func load_game() -> void:
	var loaded := SaveManager.load_save()
	data = _merge_defaults(default_save(), loaded)
	_migrate_legacy_settings()
	_ensure_live_systems()
	_sanitize_persistent_unlocks()
	refresh_unlocks(false)
	var now := TimeManager.get_now_timestamp()
	_prepare_afk_rewards_on_login(now)
	data["last_login_at"] = now
	save_game(false)
	changed.emit()


func _prepare_afk_rewards_on_login(now: int) -> void:
	var existing: Dictionary = data.get("pending_afk_rewards", {})
	if not existing.is_empty() and not bool(existing.get("claimed", false)):
		return
	var last_exit: int = int(data.get("last_exit_at", 0))
	if last_exit <= 0 or now <= last_exit:
		data["pending_afk_rewards"] = {}
		return
	var offline_seconds: int = max(0, now - last_exit)
	var rewards: Dictionary = TimeManager.calculate_afk_rewards(offline_seconds)
	if bool(rewards.get("valid", false)):
		rewards["id"] = "afk_%s_%s" % [last_exit, now]
		rewards["created_at"] = now
		rewards["last_exit_at"] = last_exit
		rewards["claimed"] = false
		rewards["doubled"] = false
		data["pending_afk_rewards"] = rewards
	else:
		data["pending_afk_rewards"] = {}


func has_pending_afk_rewards() -> bool:
	var rewards: Dictionary = data.get("pending_afk_rewards", {})
	return not rewards.is_empty() and bool(rewards.get("valid", false)) and not bool(rewards.get("claimed", false))


func get_pending_afk_rewards() -> Dictionary:
	return Dictionary(data.get("pending_afk_rewards", {})).duplicate(true)


func claim_afk_rewards(double_reward := false) -> Dictionary:
	var rewards: Dictionary = data.get("pending_afk_rewards", {})
	if rewards.is_empty() or bool(rewards.get("claimed", false)) or not bool(rewards.get("valid", false)):
		return { "ok": false, "reason": "no_afk" }
	var multiplier := 2 if double_reward and not bool(rewards.get("doubled", false)) else 1
	rewards["claimed"] = true
	rewards["doubled"] = multiplier > 1
	data["pending_afk_rewards"] = rewards
	var coins := int(rewards.get("coins", 0)) * multiplier
	var xp := int(rewards.get("xp", 0)) * multiplier
	var pass_xp := int(rewards.get("pass_xp", 0)) * multiplier
	var diamonds := int(rewards.get("diamonds", 0)) * multiplier
	var keys := int(rewards.get("keys", 0)) * multiplier
	var chests := int(rewards.get("chests", 0))
	var chest_type := String(rewards.get("chest_type", "common"))
	if coins > 0:
		apply_reward({ "type": "coins", "amount": coins }, false)
		_increment_stat("runCoins", coins, false)
	if xp > 0:
		apply_reward({ "type": "xp", "amount": xp }, false)
	if pass_xp > 0:
		add_neon_pass_xp(pass_xp, "offline_rewards")
	if diamonds > 0:
		apply_reward({ "type": "diamonds", "amount": diamonds }, false)
	if keys > 0:
		apply_reward({ "type": "keys", "amount": keys }, false)
	if chests > 0 and not chest_type.is_empty():
		apply_reward({ "type": "chest", "chest_type": chest_type, "amount": chests }, false)
	var now := TimeManager.get_now_timestamp()
	data["pending_afk_rewards"] = {}
	data["last_afk_claim_timestamp"] = now
	data["last_exit_at"] = now
	data["last_reward_text"] = _afk_reward_text(coins, xp, pass_xp, diamonds, keys, chests, chest_type)
	refresh_unlocks(false)
	_update_achievements(false)
	save_game()
	return {
		"ok": true,
		"reward": {
			"coins": coins,
			"xp": xp,
			"pass_xp": pass_xp,
			"diamonds": diamonds,
			"keys": keys,
			"chests": chests,
			"chest_type": chest_type,
		},
		"text": String(data.get("last_reward_text", "")),
		"doubled": multiplier > 1,
	}


func _afk_reward_text(coins: int, xp: int, pass_xp: int, diamonds: int, keys: int, chests: int, chest_type: String) -> String:
	var parts: Array[String] = []
	if coins > 0:
		parts.append("+%s coins" % coins)
	if xp > 0:
		parts.append("+%s XP" % xp)
	if pass_xp > 0:
		parts.append("+%s Pass XP" % pass_xp)
	if diamonds > 0:
		parts.append("+%s diamonds" % diamonds)
	if keys > 0:
		parts.append("+%s keys" % keys)
	if chests > 0:
		parts.append("+%s %s chest" % [chests, chest_type])
	return "Offline rewards: %s" % ", ".join(parts)


func debug_simulate_afk(seconds: int) -> void:
	var now := TimeManager.get_now_timestamp()
	data["last_exit_at"] = max(0, now - max(0, seconds))
	data["pending_afk_rewards"] = {}
	_prepare_afk_rewards_on_login(now)
	save_game()


func debug_clear_pending_afk() -> void:
	data["pending_afk_rewards"] = {}
	data["last_afk_claim_timestamp"] = TimeManager.get_now_timestamp()
	save_game()


func debug_force_show_afk_modal() -> void:
	if not has_pending_afk_rewards():
		debug_simulate_afk(60 * 60)
	data["force_show_afk_modal"] = true
	save_game()


func save_game(emit_signal := true, immediate := false) -> void:
	if not data.is_empty() and data.has("neon_pass_season_id"):
		_save_neon_pass_season_progress()
	if emit_signal:
		changed.emit()
	if immediate:
		_write_save_now()
	else:
		_queue_save_write()


func flush_save() -> void:
	if data.is_empty():
		return
	if data.has("neon_pass_season_id"):
		_save_neon_pass_season_progress()
	_write_save_now(true)


func _queue_save_write() -> void:
	if data.is_empty():
		return
	_save_pending = true
	_ensure_save_timer()
	if _save_timer.is_stopped():
		_save_timer.start()


func _write_save_now(force_backup := false) -> void:
	if data.is_empty():
		return
	_save_pending = false
	if _save_timer and not _save_timer.is_stopped():
		_save_timer.stop()
	SaveManager.save_game(data, force_backup)


func _ensure_save_timer() -> void:
	if _save_timer:
		return
	_save_timer = Timer.new()
	_save_timer.one_shot = true
	_save_timer.wait_time = 0.55
	_save_timer.timeout.connect(_on_save_timer_timeout)
	add_child(_save_timer)


func _on_save_timer_timeout() -> void:
	if _save_pending:
		_write_save_now()


func export_save_text() -> String:
	var payload := {
		"format": SAVE_EXPORT_FORMAT,
		"version": SAVE_EXPORT_VERSION,
		"exported_at": TimeManager.get_now_timestamp(),
		"exported_at_iso": Time.get_datetime_string_from_system(false, true),
		"game": "Neon Idle Escape",
		"engine": "Godot 4",
		"save_data": data.duplicate(true),
	}
	return JSON.stringify(payload, "\t")


func validate_import_save_text(text: String) -> Dictionary:
	var trimmed := text.strip_edges()
	if trimmed.is_empty():
		return { "ok": false, "reason": "empty" }
	var parsed = JSON.parse_string(trimmed)
	if typeof(parsed) != TYPE_DICTIONARY:
		return { "ok": false, "reason": "json" }
	var payload: Dictionary = parsed
	var incoming: Dictionary = {}
	if payload.has("save_data"):
		if typeof(payload.get("save_data")) != TYPE_DICTIONARY:
			return { "ok": false, "reason": "data" }
		if String(payload.get("format", "")) != SAVE_EXPORT_FORMAT:
			return { "ok": false, "reason": "format" }
		if int(payload.get("version", 0)) > SAVE_EXPORT_VERSION:
			return { "ok": false, "reason": "version" }
		incoming = Dictionary(payload.get("save_data", {})).duplicate(true)
	else:
		incoming = payload.duplicate(true)
	if not _looks_like_save_data(incoming):
		return { "ok": false, "reason": "structure" }
	var preview := {
		"coins": int(incoming.get("coins", 0)),
		"diamonds": int(incoming.get("diamonds", 0)),
		"level": int(incoming.get("level", 1)),
		"max_phase": int(incoming.get("max_unlocked_phase", 1)),
		"skins": Array(incoming.get("unlocked_skins", [])).size(),
		"achievements": Dictionary(incoming.get("achievements", {})).size(),
	}
	return { "ok": true, "data": incoming, "preview": preview }


func import_save_text(text: String) -> Dictionary:
	var validation := validate_import_save_text(text)
	if not bool(validation.get("ok", false)):
		return validation
	SaveManager.create_import_backup()
	data = _merge_defaults(default_save(), Dictionary(validation.get("data", {})).duplicate(true))
	_migrate_legacy_settings()
	_ensure_live_systems()
	_sanitize_persistent_unlocks()
	refresh_unlocks(false)
	save_game()
	return { "ok": true, "preview": validation.get("preview", {}) }


func reset_progress() -> void:
	SaveManager.create_import_backup()
	data = default_save()
	_ensure_live_systems()
	_sanitize_persistent_unlocks()
	refresh_unlocks(false)
	save_game()


func make_debug_save() -> void:
	data["coins"] = int(data.get("coins", 0)) + 25000
	data["diamonds"] = int(data.get("diamonds", 0)) + 1000
	data["keys"] = int(data.get("keys", 0)) + 20
	data["legendary_keys"] = int(data.get("legendary_keys", 0)) + 3
	data["xp"] = int(data.get("xp", 0)) + 5000
	data["profile_xp"] = int(data.get("profile_xp", 0)) + 5000
	data["level"] = max(20, int(data.get("level", 1)))
	unlock_level(25)
	save_game()


func debug_unlock_all() -> void:
	data["max_unlocked_phase"] = MAX_PHASE
	var phases: Array = []
	for phase in range(1, MAX_PHASE + 1):
		phases.append(phase)
	data["unlocked_phases"] = phases
	debug_unlock_all_upgrades()
	var skins: Array = _all_known_skin_ids()
	data["unlocked_skins"] = skins
	data["new_skins"] = skins.duplicate()
	refresh_unlocks(false)
	migrate_save_to_skin_levels()
	_update_skin_collection_stats()
	_update_achievements(false)
	save_game()


func debug_add_levels(amount: int) -> void:
	amount = max(1, amount)
	data["level"] = max(1, int(data.get("level", 1)) + amount)
	refresh_unlocks(false)
	save_game()


func debug_unlock_all_levels() -> void:
	unlock_level(MAX_PHASE)


func debug_unlock_all_upgrades() -> void:
	var upgrades: Array = []
	for id in MainPortData.all_run_upgrade_ids():
		upgrades.append(String(id))
	data["unlocked_upgrade_ids"] = upgrades
	data["unlocked_upgrades"] = upgrades.duplicate()
	data["explicit_unlocked_run_upgrades"] = upgrades.duplicate()
	refresh_unlocks(false)
	save_game()


func debug_lock_all_except_starter_upgrades() -> void:
	var starters := _starter_upgrade_ids()
	data["unlocked_upgrade_ids"] = starters.duplicate()
	data["unlocked_upgrades"] = starters.duplicate()
	data["explicit_unlocked_run_upgrades"] = []
	save_game()


func debug_unlock_next_upgrade() -> Dictionary:
	for upgrade in MainPortData.run_upgrades():
		var id := String(upgrade.get("id", ""))
		if not is_upgrade_unlocked(id):
			unlock_upgrade(id)
			return { "ok": true, "id": id, "name": String(upgrade.get("name", id)) }
	return { "ok": false, "reason": "all_unlocked" }


func debug_reset_upgrade_levels() -> void:
	data["upgrade_levels"] = {}
	data["permanent_upgrades"] = {}
	save_game()


func debug_max_all_upgrade_levels() -> void:
	_ensure_upgrade_state()
	for upgrade in MainPortData.run_upgrades():
		var id := String(upgrade.get("id", ""))
		if is_upgrade_unlocked(id):
			_set_upgrade_level(id, get_upgrade_max_level(id))
	save_game()


func debug_unlock_all_skins() -> void:
	var skins: Array = _all_known_skin_ids()
	data["unlocked_skins"] = skins
	data["new_skins"] = skins.duplicate()
	migrate_save_to_skin_levels()
	refresh_unlocks(false)
	_update_skin_collection_stats()
	_update_achievements(false)
	save_game()


func debug_unlock_random_skin() -> Dictionary:
	var locked: Array = []
	for skin_id in _all_known_skin_ids():
		if not Array(data.get("unlocked_skins", [])).has(skin_id):
			locked.append(String(skin_id))
	if locked.is_empty():
		return { "ok": false, "reason": "all_unlocked", "count": 0 }
	var chosen := String(locked[randi() % locked.size()])
	unlock_skin(chosen)
	return { "ok": true, "id": chosen, "name": _skin_display_name(chosen), "count": 1 }


func debug_unlock_skin_batch(amount: int = 10) -> Dictionary:
	var unlocked_count := 0
	var names: Array = []
	for i in range(max(1, amount)):
		var result := debug_unlock_random_skin()
		if not bool(result.get("ok", false)):
			break
		unlocked_count += 1
		names.append(String(result.get("name", result.get("id", ""))))
	return { "ok": unlocked_count > 0, "count": unlocked_count, "names": names }


func debug_max_collection_achievements() -> void:
	debug_unlock_all_skins()
	debug_max_all_skins()
	var stats: Dictionary = data.get("stats", {})
	stats["skinCommonPhaseWins"] = max(int(stats.get("skinCommonPhaseWins", 0)), 10)
	stats["skinRarePhaseWins"] = max(int(stats.get("skinRarePhaseWins", 0)), 10)
	stats["skinEpicPhaseWins"] = max(int(stats.get("skinEpicPhaseWins", 0)), 10)
	stats["skinControlInfiniteSeconds"] = max(int(stats.get("skinControlInfiniteSeconds", 0)), 300)
	stats["skinFireBossWins"] = max(int(stats.get("skinFireBossWins", 0)), 1)
	stats["skinUltimateLeagueWins"] = max(int(stats.get("skinUltimateLeagueWins", 0)), 1)
	stats["skinIceControlPerfects"] = max(int(stats.get("skinIceControlPerfects", 0)), 50)
	stats["skinLegendaryPlusRings"] = max(int(stats.get("skinLegendaryPlusRings", 0)), 1000)
	data["stats"] = stats
	_update_skin_collection_stats()
	_update_achievements(false)
	save_game()


func debug_reset_skin_achievements() -> void:
	var achievements: Dictionary = data.get("achievements", {})
	for achievement in get_achievements():
		if _is_skin_achievement(achievement):
			achievements.erase(String(achievement.get("id", "")))
	data["achievements"] = achievements
	var stats: Dictionary = data.get("stats", {})
	for key in _skin_usage_stat_keys():
		stats[key] = 0
	data["stats"] = stats
	_update_skin_collection_stats()
	_update_achievements(false)
	save_game()


func _all_known_skin_ids() -> Array:
	var skins: Array = []
	for skin in MainPortData.SKINS:
		var skin_id := String(Dictionary(skin).get("id", ""))
		if not skin_id.is_empty() and not skins.has(skin_id):
			skins.append(skin_id)
	_append_skin_ids_from_dir(skins, "res://assets/skins")
	_append_skin_ids_from_dir(skins, "res://assets/skins/generated")
	if not skins.has("neon_blue"):
		skins.push_front("neon_blue")
	return skins


func _skin_display_name(id: String) -> String:
	var skin := MainPortData.skin_by_id(id)
	if skin.is_empty():
		return id.capitalize()
	return String(skin.get("name", skin.get("name_en", id)))


func _is_skin_achievement(achievement: Dictionary) -> bool:
	var category := String(achievement.get("category", ""))
	var id := String(achievement.get("id", ""))
	var metric := String(achievement.get("metric", ""))
	var reward: Dictionary = Dictionary(achievement.get("reward", {}))
	return category in ["skins", "collection"] or id.begins_with("skin_") or metric.begins_with("skin") or String(reward.get("type", "")) == "skin"


func _skin_usage_stat_keys() -> Array:
	return [
		"skinCommonPhaseWins",
		"skinRarePhaseWins",
		"skinEpicPhaseWins",
		"skinControlInfiniteSeconds",
		"skinFireBossWins",
		"skinUltimateLeagueWins",
		"skinIceControlPerfects",
		"skinLegendaryPlusRings",
	]


func _append_skin_ids_from_dir(skins: Array, path: String) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		return
	directory.list_dir_begin()
	var file_name := directory.get_next()
	while file_name != "":
		if not directory.current_is_dir() and file_name.ends_with(".png"):
			var skin_id := file_name.trim_suffix(".png")
			if not skin_id.is_empty() and not skins.has(skin_id):
				skins.append(skin_id)
		file_name = directory.get_next()
	directory.list_dir_end()


func debug_reset_daily_reward() -> void:
	data["last_daily_reward_at"] = 0
	data["daily_streak"] = 0
	save_game()


func debug_reset_first_win_of_day() -> void:
	data["first_win_claimed_date"] = ""
	data["first_win_completed_today"] = false
	data["last_first_win_reward"] = {}
	data["neon_pass_last_first_win_day_key"] = ""
	save_game()


func debug_complete_first_win_of_day() -> Dictionary:
	return claim_first_win_of_day("debug_complete")


func debug_claim_first_win_reward() -> Dictionary:
	return claim_first_win_of_day("debug_claim")


func debug_reset_wheel_timer() -> void:
	data["wheel"] = { "day_key": "", "free_used": false, "ad_spins_used": 0, "last_reward": {} }
	_ensure_live_systems()
	save_game()


func debug_force_event_index(index: int) -> void:
	data["debug_event_index_override"] = posmod(index, TimeManager.WEEKLY_EVENT_CYCLE_SIZE)
	get_weekly_event()
	save_game()


func debug_next_weekly_event() -> void:
	var current := TimeManager.get_weekly_event_index()
	debug_force_event_index(current + 1)


func debug_previous_weekly_event() -> void:
	var current := TimeManager.get_weekly_event_index()
	debug_force_event_index(current - 1)


func debug_reset_event_override() -> void:
	data.erase("debug_event_index_override")
	save_game()


func debug_complete_current_event() -> void:
	var event := get_weekly_event()
	var event_id := String(event.get("id", ""))
	if event_id.is_empty():
		return
	var events: Dictionary = data.get("events", {})
	var state: Dictionary = events.get(event_id, {})
	var progress: Dictionary = state.get("progress", {})
	for raw_task in Array(event.get("tasks", [])):
		var task: Dictionary = raw_task
		var metric := String(task.get("metric", ""))
		progress[metric] = int(task.get("target", 1))
	state["progress"] = progress
	events[event_id] = state
	data["events"] = events
	save_game()


func debug_reset_current_event() -> void:
	var event := get_weekly_event()
	var event_id := String(event.get("id", ""))
	if event_id.is_empty():
		return
	var events: Dictionary = data.get("events", {})
	events.erase(event_id)
	data["events"] = events
	get_weekly_event()
	save_game()


func debug_claim_current_event_reward() -> Dictionary:
	debug_complete_current_event()
	return claim_weekly_event_reward("final_reward")


func debug_weekly_event_state() -> Dictionary:
	var event := get_weekly_event()
	var event_id := String(event.get("id", ""))
	var state: Dictionary = data.get("events", {}).get(event_id, {})
	return {
		"event_id": event_id,
		"event_index": int(event.get("event_index", 0)),
		"title": String(event.get("title", "")),
		"status": String(event.get("status", "")),
		"claimed": Array(state.get("claimed", [])).duplicate(),
		"progress": Dictionary(state.get("progress", {})).duplicate(true),
		"baseline": Dictionary(state.get("baseline", {})).duplicate(true),
	}


func _neon_pass_effective_timestamp() -> int:
	var week_offset := int(data.get("neon_pass_debug_week_offset", 0))
	var season_offset := int(data.get("neon_pass_debug_season_offset", 0))
	var offset_weeks := week_offset + season_offset * TimeManager.NEON_PASS_WEEKS_PER_SEASON
	return TimeManager.get_now_timestamp() + offset_weeks * TimeManager.SECONDS_PER_WEEK


func _neon_pass_season_for_timestamp(timestamp: int) -> Dictionary:
	var index := TimeManager.get_neon_pass_season_index(timestamp)
	return Dictionary(NEON_PASS_SEASONS[index]).duplicate(true)


func _neon_pass_context() -> Dictionary:
	var timestamp := _neon_pass_effective_timestamp()
	var season := _neon_pass_season_for_timestamp(timestamp)
	var week_index := TimeManager.get_neon_pass_week_index(timestamp)
	return {
		"timestamp": timestamp,
		"season": season,
		"season_id": String(season.get("id", "neon_pass_s1")),
		"week_index": week_index,
		"weekly_level_cap": TimeManager.get_neon_pass_weekly_level_cap(timestamp),
		"seconds_until_week_end": TimeManager.get_seconds_until_neon_pass_week_end(timestamp),
		"seconds_until_season_end": TimeManager.get_seconds_until_neon_pass_season_end(timestamp),
	}


func _neon_pass_progress_snapshot() -> Dictionary:
	return {
		"level": int(data.get("neon_pass_level", 1)),
		"xp": int(data.get("neon_pass_xp", 0)),
		"total_xp": int(data.get("neon_pass_total_xp", 0)),
		"last_updated_at": int(data.get("neon_pass_last_updated_at", 0)),
		"last_first_win_day_key": String(data.get("neon_pass_last_first_win_day_key", "")),
	}


func _save_neon_pass_season_progress() -> void:
	var season_id := String(data.get("neon_pass_season_id", ""))
	if season_id.is_empty():
		return
	var progress: Dictionary = data.get("neon_pass_season_progress", {})
	if typeof(progress) != TYPE_DICTIONARY:
		progress = {}
	progress[season_id] = _neon_pass_progress_snapshot()
	data["neon_pass_season_progress"] = progress


func _restore_neon_pass_progress(season_id: String, progress: Dictionary) -> void:
	var saved: Dictionary = Dictionary(progress.get(season_id, {}))
	data["neon_pass_level"] = clampi(int(saved.get("level", 1)), 1, NEON_PASS_MAX_LEVEL)
	data["neon_pass_xp"] = max(0, int(saved.get("xp", 0)))
	data["neon_pass_total_xp"] = max(0, int(saved.get("total_xp", 0)))
	data["neon_pass_last_updated_at"] = int(saved.get("last_updated_at", TimeManager.get_now_timestamp()))
	data["neon_pass_last_first_win_day_key"] = String(saved.get("last_first_win_day_key", ""))


func _ensure_neon_pass_state() -> void:
	var context := _neon_pass_context()
	var season_id := String(context.get("season_id", "neon_pass_s1"))
	var progress: Dictionary = data.get("neon_pass_season_progress", {})
	if typeof(progress) != TYPE_DICTIONARY:
		progress = {}
	var claimed_rewards: Dictionary = data.get("neon_pass_claimed_rewards", {})
	if typeof(claimed_rewards) != TYPE_DICTIONARY:
		claimed_rewards = {}
	if typeof(claimed_rewards.get(season_id, [])) != TYPE_ARRAY:
		claimed_rewards[season_id] = []
	if typeof(data.get("neon_pass_reward_history", [])) != TYPE_ARRAY:
		data["neon_pass_reward_history"] = []
	var current_id := String(data.get("neon_pass_season_id", season_id))
	if current_id != season_id:
		if not current_id.is_empty():
			progress[current_id] = _neon_pass_progress_snapshot()
		_restore_neon_pass_progress(season_id, progress)
	data["neon_pass_season_id"] = season_id
	data["neon_pass_week_index"] = int(context.get("week_index", 1))
	data["neon_pass_weekly_level_cap"] = int(context.get("weekly_level_cap", NEON_PASS_LEVELS_PER_WEEK))
	data["neon_pass_last_updated_at"] = TimeManager.get_now_timestamp()
	data["neon_pass_season_progress"] = progress
	data["neon_pass_claimed_rewards"] = claimed_rewards
	_normalize_neon_pass_progress()
	_save_neon_pass_season_progress()


func _normalize_neon_pass_progress() -> void:
	var cap := clampi(int(data.get("neon_pass_weekly_level_cap", NEON_PASS_LEVELS_PER_WEEK)), 1, NEON_PASS_MAX_LEVEL)
	var level := clampi(int(data.get("neon_pass_level", 1)), 1, NEON_PASS_MAX_LEVEL)
	var xp: int = max(0, int(data.get("neon_pass_xp", 0)))
	level = min(level, cap)
	while level < cap and level < NEON_PASS_MAX_LEVEL and xp >= get_neon_pass_xp_needed_for_level(level):
		xp -= get_neon_pass_xp_needed_for_level(level)
		level += 1
	if level >= cap or level >= NEON_PASS_MAX_LEVEL:
		xp = 0
	else:
		xp = min(xp, max(0, get_neon_pass_xp_needed_for_level(level) - 1))
	data["neon_pass_level"] = level
	data["neon_pass_xp"] = xp


func get_neon_pass_xp_needed_for_level(level: int) -> int:
	if level <= 10:
		return 100
	if level <= 20:
		return 150
	if level <= 30:
		return 220
	return 300


func _neon_pass_skin_for_level(season_id: String, level: int) -> String:
	var season_skins: Dictionary = Dictionary(NEON_PASS_SKIN_REWARDS.get(season_id, {}))
	return String(season_skins.get(level, ""))


func _neon_pass_reward_for_level(season_id: String, level: int) -> Dictionary:
	var skin_id := _neon_pass_skin_for_level(season_id, level)
	if not skin_id.is_empty():
		return {
			"type": "skin",
			"skin_id": skin_id,
			"amount": 1,
		}
	if level == 38:
		return { "type": "chest", "chest_type": "legendary", "amount": 1 }
	if level == 35:
		return { "type": "legendary_keys", "amount": 1 }
	if level == 30:
		return { "type": "chest", "chest_type": "epic", "amount": 1 }
	if level == 20:
		return { "type": "chest", "chest_type": "rare", "amount": 1 }
	if level % 9 == 0:
		return { "type": "diamonds", "amount": 10 + level / 3 }
	if level % 8 == 0:
		return { "type": "fragments", "skin_id": "neon_blue", "amount": 12 + level }
	if level % 6 == 0:
		return { "type": "keys", "amount": 1 + int(level >= 24) }
	if level % 5 == 0:
		var chest_type := "rare" if level >= 15 else "common"
		return { "type": "chest", "chest_type": chest_type, "amount": 1 }
	if level % 3 == 0:
		return { "type": "xp", "amount": 120 + level * 18 }
	return { "type": "coins", "amount": 300 + level * 85 + int(level / 10) * 250 }


func _neon_pass_reward_icon(reward: Dictionary) -> String:
	match String(reward.get("type", "")):
		"coins":
			return "coin"
		"diamonds", "gems":
			return "gem"
		"keys":
			return "key"
		"legendaryKeys", "legendary_keys":
			return "legendary_key"
		"xp", "profileXp", "profile_xp":
			return "xp"
		"fragments":
			return "fragments"
		"skin":
			return "skins"
		"chest":
			return "chest_%s" % String(reward.get("chest_type", reward.get("chestType", "common")))
	return "coin"


func _neon_pass_reward_rarity(reward: Dictionary) -> String:
	match String(reward.get("type", "")):
		"skin":
			return _skin_rarity_from_id(String(reward.get("skin_id", reward.get("skinId", ""))))
		"chest":
			return String(reward.get("chest_type", reward.get("chestType", "common"))).to_lower()
		"legendaryKeys", "legendary_keys":
			return "legendary"
	return "common"


func _neon_pass_reward_title(reward: Dictionary) -> Dictionary:
	var amount := int(reward.get("amount", 1))
	match String(reward.get("type", "")):
		"coins":
			return { "en": "%s Coins" % amount, "pt": "%s Moedas" % amount }
		"diamonds", "gems":
			return { "en": "%s Diamonds" % amount, "pt": "%s Diamantes" % amount }
		"keys":
			return { "en": "%s Keys" % amount, "pt": "%s Chaves" % amount }
		"legendaryKeys", "legendary_keys":
			return { "en": "%s Legendary Key" % amount, "pt": "%s Chave Lendaria" % amount }
		"xp", "profileXp", "profile_xp":
			return { "en": "%s XP" % amount, "pt": "%s XP" % amount }
		"fragments":
			return { "en": "%s Fragments" % amount, "pt": "%s Fragmentos" % amount }
		"skin":
			var skin_id := String(reward.get("skin_id", reward.get("skinId", "")))
			var skin := MainPortData.skin_by_id(skin_id)
			var en_name := String(skin.get("name_en", skin.get("name", skin_id.capitalize()))) if not skin.is_empty() else skin_id.capitalize()
			var pt_name := String(skin.get("name_pt", skin.get("name", en_name))) if not skin.is_empty() else en_name
			return { "en": en_name, "pt": pt_name }
		"chest":
			var chest_type := String(reward.get("chest_type", reward.get("chestType", "common"))).capitalize()
			return { "en": "%s Chest" % chest_type, "pt": "Bau %s" % chest_type }
	return { "en": "Reward", "pt": "Recompensa" }


func get_neon_pass_rewards(season_id := "") -> Array:
	_ensure_neon_pass_state()
	var active_season_id := String(data.get("neon_pass_season_id", "neon_pass_s1"))
	var target_season_id := active_season_id if String(season_id).is_empty() else String(season_id)
	var current_level := int(data.get("neon_pass_level", 1)) if target_season_id == active_season_id else 0
	var weekly_cap := int(data.get("neon_pass_weekly_level_cap", NEON_PASS_LEVELS_PER_WEEK)) if target_season_id == active_season_id else NEON_PASS_MAX_LEVEL
	var claimed_by_season: Dictionary = data.get("neon_pass_claimed_rewards", {})
	var claimed_ids: Array = claimed_by_season.get(target_season_id, [])
	var rewards: Array = []
	for level in range(1, NEON_PASS_MAX_LEVEL + 1):
		var reward := _neon_pass_reward_for_level(target_season_id, level)
		var reward_id := "%s_l%02d" % [target_season_id, level]
		var title := _neon_pass_reward_title(reward)
		var reached := level <= current_level
		var claimed := claimed_ids.has(reward_id)
		rewards.append({
			"id": reward_id,
			"season_id": target_season_id,
			"level": level,
			"reward": reward,
			"title": String(title.get("en", "Reward")),
			"title_pt": String(title.get("pt", title.get("en", "Reward"))),
			"icon": _neon_pass_reward_icon(reward),
			"rarity": _neon_pass_reward_rarity(reward),
			"reached": reached,
			"claimed": claimed,
			"available": reached and not claimed,
			"capped": level > weekly_cap,
		})
	return rewards


func _neon_pass_reward_entry(level: int) -> Dictionary:
	for entry in get_neon_pass_rewards():
		if int(Dictionary(entry).get("level", 0)) == level:
			return Dictionary(entry)
	return {}


func get_neon_pass_claimed_rewards(season_id := "") -> Array:
	_ensure_neon_pass_state()
	var target_season_id := String(data.get("neon_pass_season_id", "neon_pass_s1")) if String(season_id).is_empty() else String(season_id)
	var claimed_by_season: Dictionary = data.get("neon_pass_claimed_rewards", {})
	return Array(claimed_by_season.get(target_season_id, [])).duplicate()


func can_claim_neon_pass_reward(level: int) -> bool:
	var entry := _neon_pass_reward_entry(level)
	return bool(entry.get("available", false))


func _mark_neon_pass_reward_claimed(season_id: String, reward_id: String) -> void:
	var claimed_by_season: Dictionary = data.get("neon_pass_claimed_rewards", {})
	if typeof(claimed_by_season) != TYPE_DICTIONARY:
		claimed_by_season = {}
	var claimed_ids: Array = claimed_by_season.get(season_id, [])
	if not claimed_ids.has(reward_id):
		claimed_ids.append(reward_id)
	claimed_by_season[season_id] = claimed_ids
	data["neon_pass_claimed_rewards"] = claimed_by_season


func claim_neon_pass_reward(level: int) -> Dictionary:
	_ensure_neon_pass_state()
	var entry := _neon_pass_reward_entry(level)
	if entry.is_empty():
		return { "ok": false, "reason": "missing" }
	if bool(entry.get("claimed", false)):
		return { "ok": false, "reason": "claimed" }
	if not bool(entry.get("reached", false)):
		return { "ok": false, "reason": "locked" }
	var reward: Dictionary = Dictionary(entry.get("reward", {})).duplicate(true)
	var season_id := String(entry.get("season_id", data.get("neon_pass_season_id", "neon_pass_s1")))
	var reward_id := String(entry.get("id", ""))
	_mark_neon_pass_reward_claimed(season_id, reward_id)
	var text := apply_reward(reward, false)
	var history: Array = data.get("neon_pass_reward_history", [])
	history.append({
		"id": reward_id,
		"season_id": season_id,
		"level": level,
		"reward": reward.duplicate(true),
		"claimed_at": TimeManager.get_now_timestamp(),
	})
	data["neon_pass_reward_history"] = history.slice(max(0, history.size() - 80), history.size())
	data["last_reward_text"] = text
	_increment_stat("neonPassRewardsClaimed", 1, false)
	save_game()
	entry["reward"] = reward
	entry["claimed"] = true
	entry["available"] = false
	return {
		"ok": true,
		"reward": reward,
		"entry": entry,
		"text": text,
		"claimed": 1,
	}


func claim_all_neon_pass_rewards() -> Dictionary:
	_ensure_neon_pass_state()
	var claimed_count := 0
	var applied_rewards: Array = []
	var reward_summary := {
		"coins": 0,
		"diamonds": 0,
		"keys": 0,
		"legendary_keys": 0,
		"xp": 0,
		"fragments": 0,
		"chests": 0,
		"skins": 0,
	}
	var history: Array = data.get("neon_pass_reward_history", [])
	for entry in get_neon_pass_rewards():
		var row: Dictionary = Dictionary(entry)
		if not bool(row.get("available", false)):
			continue
		var reward: Dictionary = Dictionary(row.get("reward", {})).duplicate(true)
		_mark_neon_pass_reward_claimed(String(row.get("season_id", data.get("neon_pass_season_id", "neon_pass_s1"))), String(row.get("id", "")))
		apply_reward(reward, false)
		_accumulate_neon_pass_reward_summary(reward_summary, reward)
		applied_rewards.append({
			"entry": row,
			"reward": reward,
		})
		history.append({
			"id": String(row.get("id", "")),
			"season_id": String(row.get("season_id", data.get("neon_pass_season_id", "neon_pass_s1"))),
			"level": int(row.get("level", 0)),
			"reward": reward.duplicate(true),
			"claimed_at": TimeManager.get_now_timestamp(),
		})
		claimed_count += 1
	if claimed_count <= 0:
		return { "ok": false, "reason": "not_ready" }
	data["neon_pass_reward_history"] = history.slice(max(0, history.size() - 80), history.size())
	var text := _neon_pass_reward_summary_text(reward_summary, claimed_count)
	data["last_reward_text"] = text
	_increment_stat("neonPassRewardsClaimed", claimed_count, false)
	save_game()
	return {
		"ok": true,
		"reward": reward_summary,
		"rewards": applied_rewards,
		"text": text,
		"claimed": claimed_count,
	}


func _accumulate_neon_pass_reward_summary(summary: Dictionary, reward: Dictionary) -> void:
	var amount := int(reward.get("amount", 1))
	match String(reward.get("type", "")):
		"coins":
			summary["coins"] = int(summary.get("coins", 0)) + amount
		"diamonds", "gems":
			summary["diamonds"] = int(summary.get("diamonds", 0)) + amount
		"keys":
			summary["keys"] = int(summary.get("keys", 0)) + amount
		"legendaryKeys", "legendary_keys":
			summary["legendary_keys"] = int(summary.get("legendary_keys", 0)) + amount
		"xp", "profileXp", "profile_xp":
			summary["xp"] = int(summary.get("xp", 0)) + amount
		"fragments":
			summary["fragments"] = int(summary.get("fragments", 0)) + amount
		"chest":
			summary["chests"] = int(summary.get("chests", 0)) + amount
		"skin":
			summary["skins"] = int(summary.get("skins", 0)) + 1


func _neon_pass_reward_summary_text(summary: Dictionary, claimed_count: int) -> String:
	var parts: Array[String] = ["%s recompensas" % claimed_count]
	if int(summary.get("coins", 0)) > 0:
		parts.append("+%s moedas" % int(summary.get("coins", 0)))
	if int(summary.get("diamonds", 0)) > 0:
		parts.append("+%s diamantes" % int(summary.get("diamonds", 0)))
	if int(summary.get("keys", 0)) > 0:
		parts.append("+%s chaves" % int(summary.get("keys", 0)))
	if int(summary.get("legendary_keys", 0)) > 0:
		parts.append("+%s chaves lendarias" % int(summary.get("legendary_keys", 0)))
	if int(summary.get("xp", 0)) > 0:
		parts.append("+%s XP" % int(summary.get("xp", 0)))
	if int(summary.get("fragments", 0)) > 0:
		parts.append("+%s fragmentos" % int(summary.get("fragments", 0)))
	if int(summary.get("chests", 0)) > 0:
		parts.append("+%s baus" % int(summary.get("chests", 0)))
	if int(summary.get("skins", 0)) > 0:
		parts.append("+%s skins" % int(summary.get("skins", 0)))
	return "Passe Neon: %s" % ", ".join(parts)


func get_neon_pass_state() -> Dictionary:
	_ensure_neon_pass_state()
	var context := _neon_pass_context()
	var season: Dictionary = context.get("season", {})
	var level := int(data.get("neon_pass_level", 1))
	var cap := int(data.get("neon_pass_weekly_level_cap", NEON_PASS_LEVELS_PER_WEEK))
	var xp_needed := get_neon_pass_xp_needed_for_level(level)
	var rewards := get_neon_pass_rewards()
	var claimable_count := 0
	for reward_entry in rewards:
		if bool(Dictionary(reward_entry).get("available", false)):
			claimable_count += 1
	return {
		"season_id": String(data.get("neon_pass_season_id", "neon_pass_s1")),
		"season_name": String(season.get("name", "Neon Awakening")),
		"season_name_pt": String(season.get("name_pt", "Despertar Neon")),
		"week_index": int(data.get("neon_pass_week_index", 1)),
		"weekly_level_cap": cap,
		"level": level,
		"xp": int(data.get("neon_pass_xp", 0)),
		"xp_needed": xp_needed,
		"total_xp": int(data.get("neon_pass_total_xp", 0)),
		"max_level": NEON_PASS_MAX_LEVEL,
		"levels_per_week": NEON_PASS_LEVELS_PER_WEEK,
		"cap_reached": level >= cap or level >= NEON_PASS_MAX_LEVEL,
		"seconds_until_week_end": int(context.get("seconds_until_week_end", 0)),
		"seconds_until_season_end": int(context.get("seconds_until_season_end", 0)),
		"last_updated_at": int(data.get("neon_pass_last_updated_at", 0)),
		"rewards": rewards,
		"claimed_rewards": get_neon_pass_claimed_rewards(),
		"claimable_count": claimable_count,
	}


func add_neon_pass_xp(amount: int, source: String) -> Dictionary:
	_ensure_neon_pass_state()
	var incoming: int = max(0, amount)
	var cap := int(data.get("neon_pass_weekly_level_cap", NEON_PASS_LEVELS_PER_WEEK))
	var level := int(data.get("neon_pass_level", 1))
	if incoming <= 0:
		return { "ok": false, "reason": "empty", "xp_added": 0, "source": source, "state": get_neon_pass_state() }
	if level >= cap or level >= NEON_PASS_MAX_LEVEL:
		data["neon_pass_xp"] = 0
		data["neon_pass_last_updated_at"] = TimeManager.get_now_timestamp()
		save_game(false)
		return { "ok": false, "reason": "weekly_cap", "xp_added": 0, "source": source, "state": get_neon_pass_state() }
	var xp: int = int(data.get("neon_pass_xp", 0)) + incoming
	var levels_gained := 0
	var discarded := 0
	while level < cap and level < NEON_PASS_MAX_LEVEL:
		var needed := get_neon_pass_xp_needed_for_level(level)
		if xp < needed:
			break
		xp -= needed
		level += 1
		levels_gained += 1
		if level >= cap or level >= NEON_PASS_MAX_LEVEL:
			discarded = xp
			xp = 0
			break
	var accepted: int = max(0, incoming - discarded)
	data["neon_pass_level"] = level
	data["neon_pass_xp"] = xp
	data["neon_pass_total_xp"] = max(0, int(data.get("neon_pass_total_xp", 0)) + accepted)
	_increment_stat("neonPassXpEarned", accepted, false)
	data["neon_pass_last_updated_at"] = TimeManager.get_now_timestamp()
	data["neon_pass_last_xp_source"] = source
	data["neon_pass_last_xp_added"] = accepted
	save_game(false)
	return {
		"ok": accepted > 0,
		"reason": "weekly_cap" if discarded > 0 else "ok",
		"xp_added": accepted,
		"source": source,
		"levels_gained": levels_gained,
		"discarded_xp": discarded,
		"state": get_neon_pass_state(),
	}


func add_neon_pass_source_xp(source: String, amount := -1) -> Dictionary:
	var value := amount if amount >= 0 else int(NEON_PASS_SOURCE_XP.get(source, 0))
	return add_neon_pass_xp(value, source)


func _add_neon_pass_first_win_bonus(source := "eligible_win") -> Dictionary:
	return claim_first_win_of_day(source)


func _ensure_first_win_state() -> void:
	var legacy_day := String(data.get("neon_pass_last_first_win_day_key", ""))
	if String(data.get("first_win_claimed_date", "")).is_empty() and not legacy_day.is_empty():
		data["first_win_claimed_date"] = legacy_day
	var today := TimeManager.get_day_key()
	var claimed_date := String(data.get("first_win_claimed_date", ""))
	data["first_win_completed_today"] = claimed_date == today
	if typeof(data.get("last_first_win_reward", {})) != TYPE_DICTIONARY:
		data["last_first_win_reward"] = {}


func _first_win_reward_for_today() -> Dictionary:
	var player_level: int = max(1, int(data.get("level", 1)))
	var diamonds: int = 1
	if player_level >= 10:
		diamonds += 1
	if player_level >= 25:
		diamonds += 1
	var key_chance: float = 0.10
	if player_level >= 20:
		key_chance = 0.16
	return {
		"type": "bundle",
		"source": "first_win_of_day",
		"coins": 260 + player_level * 55,
		"xp": 120 + player_level * 22,
		"pass_xp": int(NEON_PASS_SOURCE_XP.get("first_win_of_day", 100)),
		"diamonds": diamonds,
		"keys": 0,
		"key_chance": key_chance,
	}


func _finalize_first_win_reward(reward: Dictionary) -> Dictionary:
	var result := reward.duplicate(true)
	var key_chance := float(result.get("key_chance", 0.0))
	if key_chance > 0.0 and randf() < key_chance:
		result["keys"] = int(result.get("keys", 0)) + 1
	return result


func _apply_first_win_reward(reward: Dictionary) -> Dictionary:
	var coins := int(reward.get("coins", 0))
	var xp := int(reward.get("xp", 0))
	var pass_xp := int(reward.get("pass_xp", 0))
	var diamonds := int(reward.get("diamonds", 0))
	var keys := int(reward.get("keys", 0))
	if coins > 0:
		data["coins"] = max(0, int(data.get("coins", 0)) + coins)
		_add_earning_stats(coins, 0, 0, 0)
	if diamonds > 0:
		data["diamonds"] = max(0, int(data.get("diamonds", 0)) + diamonds)
		_increment_stat("diamondsFound", diamonds, false)
		_increment_stat("diamonds_found", diamonds, false)
		_add_earning_stats(0, 0, diamonds, 0)
	if keys > 0:
		data["keys"] = max(0, int(data.get("keys", 0)) + keys)
		_add_earning_stats(0, 0, 0, keys)
	if xp > 0:
		add_profile_xp(xp)
	var pass_result := {}
	if pass_xp > 0:
		pass_result = add_neon_pass_xp(pass_xp, "first_win_of_day")
	return pass_result


func _first_win_reward_text(reward: Dictionary, show_chance := false) -> String:
	var parts: Array[String] = []
	if int(reward.get("coins", 0)) > 0:
		parts.append("+%s gold" % int(reward.get("coins", 0)))
	if int(reward.get("xp", 0)) > 0:
		parts.append("+%s XP" % int(reward.get("xp", 0)))
	if int(reward.get("pass_xp", 0)) > 0:
		parts.append("+%s Pass XP" % int(reward.get("pass_xp", 0)))
	if int(reward.get("diamonds", 0)) > 0:
		parts.append("+%s diamonds" % int(reward.get("diamonds", 0)))
	if int(reward.get("keys", 0)) > 0:
		parts.append("+%s keys" % int(reward.get("keys", 0)))
	elif show_chance and float(reward.get("key_chance", 0.0)) > 0.0:
		parts.append("%s%% key chance" % int(round(float(reward.get("key_chance", 0.0)) * 100.0)))
	return " • ".join(parts)


func get_first_win_of_day_state() -> Dictionary:
	_ensure_first_win_state()
	var completed := bool(data.get("first_win_completed_today", false))
	var preview_reward := _first_win_reward_for_today()
	var last_reward: Dictionary = Dictionary(data.get("last_first_win_reward", {})).duplicate(true)
	return {
		"day_key": TimeManager.get_day_key(),
		"completed_today": completed,
		"claimed": completed,
		"available": not completed,
		"reward": last_reward if completed and not last_reward.is_empty() else preview_reward,
		"preview_reward": preview_reward,
		"last_reward": last_reward,
		"reward_text": _first_win_reward_text(preview_reward, true),
		"last_reward_text": _first_win_reward_text(last_reward, false) if not last_reward.is_empty() else "",
		"seconds_until_reset": TimeManager.get_seconds_until_next_day(),
	}


func claim_first_win_of_day(source := "eligible_win") -> Dictionary:
	_ensure_first_win_state()
	var today := TimeManager.get_day_key()
	if String(data.get("first_win_claimed_date", "")) == today:
		return {
			"ok": false,
			"reason": "already_claimed",
			"reward": Dictionary(data.get("last_first_win_reward", {})).duplicate(true),
			"text": String(data.get("last_reward_text", "")),
		}
	var reward := _finalize_first_win_reward(_first_win_reward_for_today())
	data["first_win_claimed_date"] = today
	data["first_win_completed_today"] = true
	data["neon_pass_last_first_win_day_key"] = today
	data["last_first_win_reward"] = reward.duplicate(true)
	var pass_result := _apply_first_win_reward(reward)
	var text := _first_win_reward_text(reward, false)
	data["last_reward_text"] = text
	_increment_stat("firstWinBonuses", 1, false)
	_progress_missions("firstWinBonuses", 1)
	_update_achievements(false)
	save_game()
	return {
		"ok": true,
		"source": source,
		"reward": reward,
		"text": text,
		"pass_result": pass_result,
	}


func _add_neon_pass_infinite_xp(seconds: int, rings: int) -> void:
	add_neon_pass_source_xp("infinite_played")
	var survival_xp: int = max(0, floori(float(max(0, seconds)) / 60.0) * 10 + min(120, max(0, rings) * 2))
	if survival_xp > 0:
		add_neon_pass_xp(survival_xp, "infinite_survival_time")


func debug_neon_pass_state() -> Dictionary:
	return get_neon_pass_state()


func debug_add_neon_pass_xp(amount := 500) -> Dictionary:
	return add_neon_pass_xp(amount, "debug")


func debug_set_neon_pass_level(level: int) -> void:
	_ensure_neon_pass_state()
	var cap := int(data.get("neon_pass_weekly_level_cap", NEON_PASS_LEVELS_PER_WEEK))
	data["neon_pass_level"] = clampi(level, 1, min(cap, NEON_PASS_MAX_LEVEL))
	data["neon_pass_xp"] = 0
	data["neon_pass_last_updated_at"] = TimeManager.get_now_timestamp()
	save_game()


func debug_reset_neon_pass() -> void:
	var context := _neon_pass_context()
	data["neon_pass_season_id"] = String(context.get("season_id", "neon_pass_s1"))
	data["neon_pass_level"] = 1
	data["neon_pass_xp"] = 0
	data["neon_pass_week_index"] = int(context.get("week_index", 1))
	data["neon_pass_weekly_level_cap"] = int(context.get("weekly_level_cap", NEON_PASS_LEVELS_PER_WEEK))
	data["neon_pass_total_xp"] = 0
	data["neon_pass_last_updated_at"] = TimeManager.get_now_timestamp()
	data["neon_pass_last_first_win_day_key"] = ""
	_save_neon_pass_season_progress()
	save_game()


func debug_simulate_next_neon_pass_week() -> void:
	data["neon_pass_debug_week_offset"] = int(data.get("neon_pass_debug_week_offset", 0)) + 1
	_ensure_neon_pass_state()
	save_game()


func debug_simulate_next_neon_pass_season() -> void:
	data["neon_pass_debug_season_offset"] = int(data.get("neon_pass_debug_season_offset", 0)) + 1
	data["neon_pass_debug_week_offset"] = 0
	_ensure_neon_pass_state()
	save_game()


func debug_unlock_all_neon_pass_rewards() -> void:
	_ensure_neon_pass_state()
	var missing_weeks: int = max(0, TimeManager.NEON_PASS_WEEKS_PER_SEASON - int(data.get("neon_pass_week_index", 1)))
	if missing_weeks > 0:
		data["neon_pass_debug_week_offset"] = int(data.get("neon_pass_debug_week_offset", 0)) + missing_weeks
		_ensure_neon_pass_state()
	data["neon_pass_level"] = NEON_PASS_MAX_LEVEL
	data["neon_pass_xp"] = 0
	data["neon_pass_weekly_level_cap"] = NEON_PASS_MAX_LEVEL
	data["neon_pass_last_updated_at"] = TimeManager.get_now_timestamp()
	save_game()


func debug_claim_all_neon_pass_rewards() -> Dictionary:
	debug_unlock_all_neon_pass_rewards()
	return claim_all_neon_pass_rewards()


func debug_reset_claimed_neon_pass_rewards() -> void:
	_ensure_neon_pass_state()
	var season_id := String(data.get("neon_pass_season_id", "neon_pass_s1"))
	var claimed_by_season: Dictionary = data.get("neon_pass_claimed_rewards", {})
	claimed_by_season[season_id] = []
	data["neon_pass_claimed_rewards"] = claimed_by_season
	data["neon_pass_reward_history"] = []
	save_game()


func set_debug_enabled(enabled: bool) -> void:
	data["settings"]["debug_enabled"] = enabled
	save_game()


func is_debug_enabled() -> bool:
	return bool(data.get("settings", {}).get("debug_enabled", false))


func update_runtime_debug(info: Dictionary) -> void:
	data["runtime_debug"] = info


func debug_upgrade_state() -> Dictionary:
	_ensure_upgrade_state()
	var unlocked := get_unlocked_upgrade_ids()
	var pool_ids: Array[String] = []
	for upgrade in get_gameplay_upgrade_pool():
		pool_ids.append(String(upgrade.get("id", "")))
	return {
		"total_upgrades": MainPortData.all_run_upgrade_ids().size(),
		"unlocked_count": unlocked.size(),
		"locked_count": get_locked_upgrades().size(),
		"unlocked_upgrade_ids": unlocked,
		"gameplay_pool_ids": pool_ids,
		"upgrade_levels": Dictionary(data.get("upgrade_levels", {})).duplicate(true),
	}


func debug_add_profile_stats_test_data() -> void:
	_ensure_profile_stats_state()
	var stats: Dictionary = data.get("stats", {})
	stats["totalPlayTimeSeconds"] = int(stats.get("totalPlayTimeSeconds", 0)) + 5400
	stats["runsPlayed"] = int(stats.get("runsPlayed", 0)) + 18
	stats["runs_played"] = int(stats.get("runs_played", 0)) + 18
	stats["phaseWins"] = int(stats.get("phaseWins", 0)) + 9
	stats["wins"] = int(stats.get("wins", 0)) + 9
	stats["losses"] = int(stats.get("losses", 0)) + 3
	stats["ringsDestroyed"] = int(stats.get("ringsDestroyed", 0)) + 360
	stats["rings_destroyed"] = int(stats.get("rings_destroyed", 0)) + 360
	stats["perfectEscapes"] = int(stats.get("perfectEscapes", 0)) + 42
	stats["perfect_escapes"] = int(stats.get("perfect_escapes", 0)) + 42
	stats["bestCombo"] = max(int(stats.get("bestCombo", 0)), 12)
	stats["totalCoinsEarned"] = int(stats.get("totalCoinsEarned", 0)) + 9200
	stats["totalXpEarned"] = int(stats.get("totalXpEarned", 0)) + 2100
	stats["totalDiamondsEarned"] = int(stats.get("totalDiamondsEarned", 0)) + 35
	stats["totalKeysEarned"] = int(stats.get("totalKeysEarned", 0)) + 4
	stats["chestsOpened"] = int(stats.get("chestsOpened", 0)) + 3
	stats["bossWins"] = int(stats.get("bossWins", 0)) + 1
	stats["boss_wins"] = int(stats.get("boss_wins", 0)) + 1
	stats["bossDamageTotal"] = int(stats.get("bossDamageTotal", 0)) + 15000
	stats["bestInfiniteSeconds"] = max(int(stats.get("bestInfiniteSeconds", 0)), 210)
	stats["bestInfiniteRings"] = max(int(stats.get("bestInfiniteRings", 0)), 58)
	stats["leagueMatches"] = int(stats.get("leagueMatches", 0)) + 5
	stats["leagueWins"] = int(stats.get("leagueWins", 0)) + 3
	stats["neonPassXpEarned"] = int(stats.get("neonPassXpEarned", 0)) + 700
	stats["eventMissionsCompleted"] = int(stats.get("eventMissionsCompleted", 0)) + 2
	data["stats"] = stats
	var usage: Dictionary = data.get("skin_usage", {})
	var equipped := String(data.get("equipped_skin", "neon_blue"))
	usage[equipped] = int(usage.get(equipped, 0)) + 12
	data["skin_usage"] = usage
	_ensure_profile_stats_state()
	save_game()


func debug_reset_profile_stats() -> void:
	data["stats"] = _profile_stat_defaults()
	data["skin_usage"] = {}
	_update_skin_collection_stats()
	_ensure_profile_stats_state()
	save_game()


func debug_profile_stats_snapshot() -> Dictionary:
	return get_profile_stats_snapshot()


func _looks_like_save_data(candidate: Dictionary) -> bool:
	if not candidate.has("coins") or not candidate.has("diamonds"):
		return false
	if not candidate.has("unlocked_skins") or typeof(candidate.get("unlocked_skins")) != TYPE_ARRAY:
		return false
	if not candidate.has("settings") or typeof(candidate.get("settings")) != TYPE_DICTIONARY:
		return false
	if not candidate.has("stats") or typeof(candidate.get("stats")) != TYPE_DICTIONARY:
		return false
	return true


func refresh_unlocks(emit_signal := true) -> void:
	_ensure_upgrade_state()

	var skins: Array = data.get("unlocked_skins", [])
	var new_skins: Array = data.get("new_skins", [])
	var max_phase := int(data.get("max_unlocked_phase", data.get("current_phase", 1)))
	var profile_level := int(data.get("level", 1))
	for id in SKIN_UNLOCK_MILESTONES.keys():
		if _meets_unlock(SKIN_UNLOCK_MILESTONES[id], max_phase, profile_level) and not skins.has(id):
			skins.append(id)
			if not new_skins.has(id):
				new_skins.append(id)
	data["unlocked_skins"] = skins
	data["new_skins"] = new_skins
	data["stats"]["skins_unlocked"] = skins.size()
	_update_skin_collection_stats()
	if not skins.has(String(data.get("equipped_skin", "neon_blue"))):
		data["equipped_skin"] = "neon_blue"
	if emit_signal:
		save_game()


func _clean_released_upgrade_unlocks(unlocked: Array) -> Array:
	var cleaned: Array = []
	for value in unlocked:
		var id := String(value)
		if cleaned.has(id):
			continue
		if MainPortData.is_run_upgrade_defined(id):
			cleaned.append(id)
	return cleaned


func _starter_upgrade_ids() -> Array:
	var result: Array = []
	for id in STARTER_UPGRADE_IDS:
		if MainPortData.is_run_upgrade_defined(String(id)) and not result.has(String(id)):
			result.append(String(id))
	return result


func _ensure_upgrade_state() -> void:
	var cleaned := _starter_upgrade_ids()
	var source: Array = []
	if data.has("unlocked_upgrade_ids"):
		source = Array(data.get("unlocked_upgrade_ids", []))
	else:
		source = Array(data.get("explicit_unlocked_run_upgrades", []))
		if source.is_empty():
			source = _starter_upgrade_ids()
	for value in source:
		var id := String(value)
		if MainPortData.is_run_upgrade_defined(id) and not cleaned.has(id):
			cleaned.append(id)
	data["unlocked_upgrade_ids"] = cleaned
	data["unlocked_upgrades"] = cleaned.duplicate()
	var explicit: Array = []
	for value in Array(data.get("explicit_unlocked_run_upgrades", [])):
		var id := String(value)
		if MainPortData.is_run_upgrade_defined(id) and not STARTER_UPGRADE_IDS.has(id) and not explicit.has(id):
			explicit.append(id)
	data["explicit_unlocked_run_upgrades"] = explicit

	var levels: Dictionary = data.get("upgrade_levels", {})
	var legacy: Dictionary = data.get("permanent_upgrades", {})
	var migrated := {
		"damage": int(legacy.get("baseDamage", 0)),
		"speed": int(legacy.get("baseSpeed", 0)),
		"coinBoost": int(legacy.get("coinMultiplier", 0)),
		"critical": int(legacy.get("critChance", 0)),
		"xpBoost": int(legacy.get("xpBoost", 0)),
		"perfectChance": int(legacy.get("perfectChance", 0)),
		"frost": int(legacy.get("slowRings", 0)),
	}
	for id in migrated.keys():
		if int(migrated[id]) > 0 and int(levels.get(id, 0)) <= 0:
			levels[id] = int(migrated[id])
	var cleaned_levels := {}
	for upgrade in MainPortData.run_upgrades():
		var id := String(upgrade.get("id", ""))
		var max_level := get_upgrade_max_level(id)
		var level := clampi(int(levels.get(id, 0)), 0, max_level)
		if level > 0:
			cleaned_levels[id] = level
	data["upgrade_levels"] = cleaned_levels
	data["permanent_upgrades"] = {
		"baseDamage": int(cleaned_levels.get("damage", 0)),
		"baseSpeed": int(cleaned_levels.get("speed", 0)),
		"coinMultiplier": int(cleaned_levels.get("coinBoost", 0)),
		"critChance": int(cleaned_levels.get("critical", 0)),
		"xpBoost": int(cleaned_levels.get("xpBoost", 0)),
		"perfectChance": int(cleaned_levels.get("perfectChance", 0)),
		"slowRings": int(cleaned_levels.get("frost", 0)),
	}


func _ensure_live_systems() -> void:
	var day_key := _day_key()
	if String(data.get("wheel", {}).get("day_key", "")) != day_key:
		data["wheel"] = { "day_key": day_key, "free_used": false, "ad_spins_used": 0, "last_reward": {} }
	if String(data.get("daily_missions", {}).get("day_key", "")) != day_key:
		data["daily_missions"] = _create_daily_missions(day_key)
	_ensure_upgrade_state()
	_ensure_daily_challenge_state()
	_ensure_boss_state()
	_ensure_league_season()
	_ensure_neon_pass_state()
	_ensure_first_win_state()
	_ensure_profile_stats_state()
	var achievements: Dictionary = data.get("achievements", {})
	for achievement in get_achievements():
		var id := String(achievement["id"])
		if not achievements.has(id):
			achievements[id] = { "progress": 0, "completed": false, "claimed": false }
	data["achievements"] = achievements
	_ensure_tutorial_state()
	_update_achievements(false)


func _profile_stat_defaults() -> Dictionary:
	return {
		"totalPlayTimeSeconds": 0,
		"totalMatches": 0,
		"wins": 0,
		"losses": 0,
		"phaseCompletions": 0,
		"totalXpEarned": 0,
		"totalCoinsEarned": 0,
		"totalDiamondsEarned": 0,
		"totalKeysEarned": 0,
		"runs_played": 0,
		"runsPlayed": 0,
		"rings_destroyed": 0,
		"ringsDestroyed": 0,
		"perfect_escapes": 0,
		"perfectEscapes": 0,
		"diamonds_found": 0,
		"diamondsFound": 0,
		"chests_opened": 0,
		"chestsOpened": 0,
		"chestsEarned": 0,
		"skins_unlocked": 1,
		"skinsUnlocked": 1,
		"skinsMaxed": 0,
		"skinMaxedCount": 0,
		"skinsUpgradedCount": 0,
		"highest_phase": 1,
		"highestPhase": 1,
		"highest_run_level": 1,
		"infinite_runs": 0,
		"infiniteRuns": 0,
		"best_infinite_seconds": 0,
		"bestInfiniteSeconds": 0,
		"best_infinite_rings": 0,
		"bestInfiniteRings": 0,
		"best_infinite_score": 0,
		"bestInfiniteScore": 0,
		"infiniteBestLevel": 0,
		"bestInfiniteReward": 0,
		"bestCombo": 0,
		"runCoins": 0,
		"runUpgrades": 0,
		"criticals": 0,
		"skinEffects": 0,
		"boss_runs": 0,
		"boss_wins": 0,
		"boss_losses": 0,
		"bossRuns": 0,
		"bossWins": 0,
		"bossLosses": 0,
		"bossDamageTotal": 0,
		"bossBestTime": 0,
		"dailyChallengeRuns": 0,
		"dailyChallengeCompletions": 0,
		"phaseWins": 0,
		"wheelSpins": 0,
		"storePurchases": 0,
		"upgradesBought": 0,
		"upgradesUnlocked": STARTER_UPGRADE_IDS.size(),
		"upgradesMaxed": 0,
		"skinEquips": 0,
		"leagueMatches": 0,
		"leagueWins": 0,
		"leagueLosses": 0,
		"leagueQuits": 0,
		"leagueTrophies": 0,
		"highestLeagueTrophies": 0,
		"leagueTrophiesTotal": 0,
		"leagueWinStreak": 0,
		"leagueRankIndex": 0,
		"neonPassXpEarned": 0,
		"neonPassRewardsClaimed": 0,
		"eventsCompleted": 0,
		"eventMissionsCompleted": 0,
		"eventRewardsClaimed": 0,
	}


func _ensure_profile_stats_state() -> void:
	var stats: Dictionary = data.get("stats", {})
	if typeof(stats) != TYPE_DICTIONARY:
		stats = {}
	for key in _profile_stat_defaults().keys():
		if not stats.has(key):
			stats[key] = _profile_stat_defaults()[key]
	data["stats"] = stats
	if not data.has("skin_usage") or typeof(data.get("skin_usage")) != TYPE_DICTIONARY:
		data["skin_usage"] = {}
	_update_skin_collection_stats()
	stats = data.get("stats", {})
	var runs: int = max(int(stats.get("runsPlayed", 0)), int(stats.get("runs_played", 0)))
	var league_matches: int = int(stats.get("leagueMatches", 0))
	var boss_matches: int = max(int(stats.get("bossRuns", 0)), int(stats.get("boss_runs", 0)))
	var wins: int = int(stats.get("phaseWins", 0)) + max(int(stats.get("bossWins", 0)), int(stats.get("boss_wins", 0))) + int(stats.get("leagueWins", 0)) + int(stats.get("dailyChallengeCompletions", 0))
	var losses: int = max(int(stats.get("bossLosses", 0)), int(stats.get("boss_losses", 0))) + int(stats.get("leagueLosses", 0)) + int(stats.get("leagueQuits", 0))
	stats["runsPlayed"] = runs
	stats["runs_played"] = runs
	stats["totalMatches"] = max(int(stats.get("totalMatches", 0)), runs + league_matches + boss_matches)
	stats["wins"] = max(int(stats.get("wins", 0)), wins)
	stats["losses"] = max(int(stats.get("losses", 0)), losses)
	stats["phaseCompletions"] = max(int(stats.get("phaseCompletions", 0)), int(stats.get("phaseWins", 0)))
	stats["ringsDestroyed"] = max(int(stats.get("ringsDestroyed", 0)), int(stats.get("rings_destroyed", 0)))
	stats["perfectEscapes"] = max(int(stats.get("perfectEscapes", 0)), int(stats.get("perfect_escapes", 0)))
	stats["diamondsFound"] = max(int(stats.get("diamondsFound", 0)), int(stats.get("diamonds_found", 0)))
	stats["chestsOpened"] = max(int(stats.get("chestsOpened", 0)), int(stats.get("chests_opened", 0)))
	stats["skinsUnlocked"] = Array(data.get("unlocked_skins", [])).size()
	stats["skins_unlocked"] = stats["skinsUnlocked"]
	stats["skinsMaxed"] = max(int(stats.get("skinsMaxed", 0)), int(stats.get("skinMaxedCount", 0)))
	stats["highestPhase"] = max(max(int(stats.get("highestPhase", 1)), int(stats.get("highest_phase", 1))), int(data.get("max_unlocked_phase", 1)))
	stats["highest_phase"] = stats["highestPhase"]
	stats["totalCoinsEarned"] = max(int(stats.get("totalCoinsEarned", 0)), int(stats.get("runCoins", 0)))
	stats["totalDiamondsEarned"] = max(int(stats.get("totalDiamondsEarned", 0)), int(stats.get("diamondsFound", 0)))
	stats["upgradesUnlocked"] = get_unlocked_upgrade_ids().size()
	stats["upgradesMaxed"] = _profile_maxed_upgrade_count()
	var league: Dictionary = data.get("league", {})
	var trophies := int(league.get("trophies", stats.get("leagueTrophies", 0)))
	stats["leagueTrophies"] = trophies
	stats["highestLeagueTrophies"] = max(int(stats.get("highestLeagueTrophies", 0)), trophies)
	stats["neonPassXpEarned"] = max(int(stats.get("neonPassXpEarned", 0)), int(data.get("neon_pass_total_xp", 0)))
	stats["neonPassRewardsClaimed"] = max(int(stats.get("neonPassRewardsClaimed", 0)), _profile_neon_pass_claimed_count())
	data["stats"] = stats


func _profile_neon_pass_claimed_count() -> int:
	var claimed_by_season: Dictionary = data.get("neon_pass_claimed_rewards", {})
	var count := 0
	for key in claimed_by_season.keys():
		count += Array(claimed_by_season.get(key, [])).size()
	return count


func _profile_maxed_upgrade_count() -> int:
	var count := 0
	for upgrade in get_unlocked_upgrades():
		var id := String(upgrade.get("id", ""))
		if not id.is_empty() and get_upgrade_level(id) >= get_upgrade_max_level(id):
			count += 1
	return count


func _profile_most_used_skin_id() -> String:
	var usage: Dictionary = data.get("skin_usage", {})
	var best_id := String(data.get("equipped_skin", "neon_blue"))
	var best_count := -1
	for key in usage.keys():
		var id := String(key)
		var count := int(usage.get(key, 0))
		if count > best_count:
			best_count = count
			best_id = id
	return best_id


func get_profile_stats_snapshot() -> Dictionary:
	_ensure_profile_stats_state()
	var stats: Dictionary = data.get("stats", {})
	var pass_state := get_neon_pass_state()
	var league: Dictionary = data.get("league", {})
	var trophies := int(league.get("trophies", stats.get("leagueTrophies", 0)))
	var rank := MainPortData.rank_for_trophies(trophies)
	return {
		"stats": stats.duplicate(true),
		"equipped_skin_id": String(data.get("equipped_skin", "neon_blue")),
		"most_used_skin_id": _profile_most_used_skin_id(),
		"skin_usage": Dictionary(data.get("skin_usage", {})).duplicate(true),
		"unlocked_skins": Array(data.get("unlocked_skins", [])).duplicate(),
		"unlocked_upgrades": get_unlocked_upgrade_ids(),
		"league_rank_id": String(rank.get("id", "bronze")),
		"league_rank_name": String(rank.get("name", "Bronze")),
		"league_trophies": trophies,
		"neon_pass": pass_state,
		"events": Dictionary(data.get("events", {})).duplicate(true),
	}


func _ensure_tutorial_state() -> void:
	var tutorial: Dictionary = data.get("tutorial", {})
	if tutorial.is_empty():
		tutorial = {
			"seen": false,
			"dont_show_again": false,
			"completed_at": 0,
			"debug_reset_available": true,
			"guided_hints": {},
		}
	var hints: Dictionary = tutorial.get("guided_hints", {})
	for id in ["open_upgrades", "open_skins", "modes"]:
		if not hints.has(id):
			hints[id] = false
	tutorial["guided_hints"] = hints
	tutorial["seen"] = bool(tutorial.get("seen", false))
	tutorial["dont_show_again"] = bool(tutorial.get("dont_show_again", false))
	tutorial["completed_at"] = int(tutorial.get("completed_at", 0))
	tutorial["debug_reset_available"] = bool(tutorial.get("debug_reset_available", true))
	data["tutorial"] = tutorial


func _sanitize_persistent_unlocks() -> void:
	_ensure_upgrade_state()

	var cleaned_skins: Array = []
	for value in Array(data.get("unlocked_skins", [])):
		var skin_id := String(value)
		if not MainPortData.skin_by_id(skin_id).is_empty() and not cleaned_skins.has(skin_id):
			cleaned_skins.append(skin_id)
	if not cleaned_skins.has("neon_blue"):
		cleaned_skins.push_front("neon_blue")
	data["unlocked_skins"] = cleaned_skins
	var cleaned_new_skins: Array = []
	for value in Array(data.get("new_skins", [])):
		var skin_id := String(value)
		if cleaned_skins.has(skin_id) and not cleaned_new_skins.has(skin_id):
			cleaned_new_skins.append(skin_id)
	data["new_skins"] = cleaned_new_skins
	if not cleaned_skins.has(String(data.get("equipped_skin", "neon_blue"))):
		data["equipped_skin"] = "neon_blue"
	if not cleaned_skins.has(String(data.get("favorite_skin", data.get("equipped_skin", "neon_blue")))):
		data["favorite_skin"] = String(data.get("equipped_skin", "neon_blue"))
	migrate_save_to_skin_levels()


func migrate_save_to_skin_levels() -> void:
	var levels: Dictionary = data.get("skin_levels", {})
	if typeof(levels) != TYPE_DICTIONARY:
		levels = {}
	var cleaned_levels := {}
	for skin_id in Array(data.get("unlocked_skins", [])):
		var id := String(skin_id)
		var max_level := get_skin_max_level(id)
		cleaned_levels[id] = clampi(int(levels.get(id, 1)), 1, max_level)
	data["skin_levels"] = cleaned_levels


func _ensure_league_season() -> void:
	var league: Dictionary = data.get("league", {})
	var current_key := TimeManager.get_month_key()
	var season_key := String(league.get("season_key", current_key))
	if season_key.is_empty():
		league["season_key"] = current_key
		data["league"] = league
		return
	if season_key == current_key:
		data["league"] = league
		return
	var trophies := int(league.get("trophies", 0))
	var final_rank := MainPortData.rank_for_trophies(trophies)
	var demoted_rank := _previous_league_rank(final_rank)
	league["last_season_key"] = season_key
	league["last_season_summary"] = {
		"season_key": season_key,
		"final_rank_id": String(final_rank.get("id", "bronze")),
		"final_rank_name": String(final_rank.get("name", "Bronze")),
		"new_rank_id": String(demoted_rank.get("id", "bronze")),
		"new_rank_name": String(demoted_rank.get("name", "Bronze")),
		"final_trophies": trophies,
		"ended_at": TimeManager.get_now_timestamp(),
	}
	league["season_key"] = current_key
	league["season_reward_claimed"] = false
	league["trophies"] = int(demoted_rank.get("min", 0))
	league["wins"] = 0
	league["losses"] = 0
	league["quits"] = 0
	league["matches"] = 0
	league["win_streak"] = 0
	data["league"] = league


func _previous_league_rank(rank: Dictionary) -> Dictionary:
	var ranks: Array = MainPortData.LEAGUE_RANKS
	var index := 0
	for i in range(ranks.size()):
		if String(Dictionary(ranks[i]).get("id", "")) == String(rank.get("id", "bronze")):
			index = i
			break
	return Dictionary(ranks[max(0, index - 1)])


func _league_rank_index(rank_id: String) -> int:
	var ranks: Array = MainPortData.LEAGUE_RANKS
	for i in range(ranks.size()):
		if String(Dictionary(ranks[i]).get("id", "")) == rank_id:
			return i
	return 0


func _day_key() -> String:
	var now := Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d" % [int(now["year"]), int(now["month"]), int(now["day"])]


func _create_daily_missions(day_key: String) -> Dictionary:
	var start: int = abs(hash(day_key)) % DAILY_MISSION_DEFS.size()
	var missions: Array = []
	for i in range(4):
		var definition: Dictionary = DAILY_MISSION_DEFS[(start + i * 2) % DAILY_MISSION_DEFS.size()]
		missions.append({ "id": definition["id"], "progress": 0, "claimed": false })
	return { "day_key": day_key, "missions": missions }


func _meets_unlock(rule: Dictionary, max_phase: int, profile_level: int) -> bool:
	return max_phase >= int(rule.get("phase", 999)) or profile_level >= int(rule.get("level", 999))


func migrate_save_to_upgrade_levels() -> void:
	_ensure_upgrade_state()


func get_upgrade_cost(id: String, current_level := -1, currency := "coins") -> int:
	var definition: Dictionary = MainPortData.upgrade_by_id(id)
	if definition.is_empty():
		return 0
	var level := get_upgrade_level(id) if current_level < 0 else current_level
	var rarity := String(definition.get("rarity", "common"))
	var rarity_multiplier := 1.0
	var growth := 1.135
	match rarity:
		"rare":
			rarity_multiplier = 1.55
			growth = 1.15
		"epic":
			rarity_multiplier = 2.25
			growth = 1.165
		"legendary":
			rarity_multiplier = 3.25
			growth = 1.18
	var cap: int = max(1, get_upgrade_max_level(id))
	if cap <= 12:
		growth += 0.035
	elif cap <= 20:
		growth += 0.018
	elif cap >= 40:
		growth -= 0.012
	var base_cost := 80 + int(definition.get("unlockLevel", 1)) * 24
	var progress := clampf(float(level) / float(cap), 0.0, 1.0)
	var late_tax: float = 1.0 + progress * (0.65 + rarity_multiplier * 0.12)
	var coin_cost := floori(float(base_cost) * rarity_multiplier * pow(growth, level) * late_tax)
	if currency == "diamonds":
		var diamond_multiplier := 1.15
		match rarity:
			"rare":
				diamond_multiplier = 1.25
			"epic":
				diamond_multiplier = 1.38
			"legendary":
				diamond_multiplier = 1.55
		return max(1, ceili(float(coin_cost) / 120.0 * diamond_multiplier))
	return max(1, int(ceil(float(coin_cost) / 10.0) * 10.0))


func get_upgrade_effect_value(id: String, level := -1) -> Dictionary:
	var data_source: Dictionary = MainPortData.upgrade_by_id(id)
	if data_source.is_empty():
		return { "id": id, "level": 0, "value": 0.0, "label": "Lv.0" }
	var actual_level := get_upgrade_level(id) if level < 0 else clampi(level, 0, get_upgrade_max_level(id))
	var scaled := apply_upgrade_level_scaling(data_source, actual_level)
	scaled["id"] = id
	scaled["level"] = actual_level
	scaled["max_level"] = get_upgrade_max_level(id)
	return scaled


func apply_upgrade_level_scaling(upgrade_data: Dictionary, level: int) -> Dictionary:
	var id := String(upgrade_data.get("id", ""))
	var value := 0.0
	match id:
		"damage":
			value = _scaled_upgrade_effect(id, level, 3.6)
			return { "type": "damage", "value": value, "label": "+%s%% dano" % roundi(value * 100.0) }
		"speed":
			value = _scaled_upgrade_effect(id, level, 1.65)
			return { "type": "speed", "value": value, "label": "+%s%% velocidade" % roundi(value * 100.0) }
		"coinBoost":
			value = _scaled_upgrade_effect(id, level, 3.5)
			return { "type": "coins", "value": value, "label": "+%s%% moedas" % roundi(value * 100.0) }
		"critical":
			value = _scaled_upgrade_effect(id, level, 0.35)
			return { "type": "critical", "value": value, "label": "+%s%% critico" % roundi(value * 100.0) }
		"xpBoost":
			value = _scaled_upgrade_effect(id, level, 3.0)
			return { "type": "xp", "value": value, "label": "+%s%% XP" % roundi(value * 100.0) }
		"perfectChance", "diamondInstinct":
			value = _scaled_upgrade_effect(id, level, 0.08)
			return { "type": "perfect", "value": value, "label": "+%.1f%% diamante/perfect" % (value * 100.0) }
		"frost":
			value = _scaled_upgrade_effect(id, level, 0.48)
			return { "type": "freeze", "value": value, "label": "%.1f%% chance gelo" % (value * 100.0) }
		"timeFreeze", "chronoBreak", "slowField":
			value = _scaled_upgrade_effect(id, level, float(UPGRADE_EFFECT_CAPS.get(id, 0.42)))
			return { "type": "slow", "value": value, "label": "%.1f%% chance lentidao" % (value * 100.0) }
		"ringRepulse":
			value = _scaled_upgrade_effect(id, level, 0.42)
			return { "type": "repulse", "value": value, "label": "%.1f%% chance repulsao" % (value * 100.0) }
		"chainLightning", "chainBreak":
			value = _scaled_upgrade_effect(id, level, float(UPGRADE_EFFECT_CAPS.get(id, 0.48)))
			return { "type": "chain", "value": value, "label": "%.1f%% corrente" % (value * 100.0) }
		"shockwave", "voidPulse", "bomb":
			value = _scaled_upgrade_effect(id, level, float(UPGRADE_EFFECT_CAPS.get(id, 0.42)))
			return { "type": "area", "value": value, "label": "%.1f%% area" % (value * 100.0) }
		"burn", "penetration", "laser", "laserCut", "multihit", "criticalOverload", "royalBreaker", "bossHunter", "trophyInstinct", "comboOverdrive", "magnetCoins", "secretMagnet", "ricochet", "bounce":
			value = _scaled_upgrade_effect(id, level, float(UPGRADE_EFFECT_CAPS.get(id, 1.0)))
			return { "type": "bonus", "value": value, "label": "+%s%% bonus" % roundi(value * 100.0) }
	value = _scaled_upgrade_effect(id, level, float(UPGRADE_EFFECT_CAPS.get(id, 1.0)))
	return { "type": "upgrade", "value": value, "label": "Lv.%s" % level }


func _scaled_upgrade_effect(id: String, level: int, maximum: float) -> float:
	if level <= 0:
		return 0.0
	var max_level: int = max(1, get_upgrade_max_level(id))
	var progress := clampf(float(level) / float(max_level), 0.0, 1.0)
	var eased := pow(progress, 0.72)
	return clamp_upgrade_effect(id, maximum * eased)


func clamp_upgrade_effect(id: String, effect_value: float) -> float:
	match id:
		"speed", "ricochet", "bounce":
			return clampf(effect_value, 0.0, 1.95)
		"critical", "criticalOverload":
			return clampf(effect_value, 0.0, 0.42)
		"perfectChance", "diamondInstinct":
			return clampf(effect_value, 0.0, 0.10)
		"frost", "timeFreeze", "chronoBreak", "slowField":
			return clampf(effect_value, 0.0, 0.58)
		"coinBoost", "magnetCoins", "secretMagnet":
			return clampf(effect_value, 0.0, 4.35)
		"xpBoost":
			return clampf(effect_value, 0.0, 3.8)
		"chainLightning", "chainBreak", "shockwave", "voidPulse", "bomb", "ringRepulse":
			return clampf(effect_value, 0.0, 0.65)
	return clampf(effect_value, 0.0, 5.2)


func get_upgrade_upgrade_preview(id: String) -> Dictionary:
	var level := get_upgrade_level(id)
	var max_level := get_upgrade_max_level(id)
	return {
		"level": level,
		"max_level": max_level,
		"current": get_upgrade_effect_value(id, level),
		"next": get_upgrade_effect_value(id, min(level + 1, max_level)),
		"coins": get_upgrade_cost(id, level, "coins"),
		"diamonds": get_upgrade_cost(id, level, "diamonds"),
	}


func get_upgrade_preview(id: String) -> Dictionary:
	return get_upgrade_upgrade_preview(id)


func get_upgrade_max_level(id: String) -> int:
	if UPGRADE_MAX_LEVEL_OVERRIDES.has(id):
		return int(UPGRADE_MAX_LEVEL_OVERRIDES[id])
	return int(MainPortData.upgrade_by_id(id).get("maxLevel", 0))


func get_upgrade_run_bonus_cap(id: String) -> int:
	if UPGRADE_RUN_BONUS_CAPS.has(id):
		return int(UPGRADE_RUN_BONUS_CAPS[id])
	var rarity := String(MainPortData.upgrade_by_id(id).get("rarity", "common"))
	match rarity:
		"common":
			return 18
		"rare":
			return 12
		"epic":
			return 8
		"legendary":
			return 5
	return 6


func get_upgrade_run_max_level(id: String) -> int:
	return get_upgrade_max_level(id) + get_upgrade_run_bonus_cap(id)


func get_upgrade_run_total_level(id: String, temporary_level := 0) -> int:
	var permanent_level := clampi(get_upgrade_level(id), 0, get_upgrade_max_level(id))
	var temp_level := clampi(temporary_level, 0, get_upgrade_run_bonus_cap(id))
	return clampi(permanent_level + temp_level, 0, get_upgrade_run_max_level(id))


func get_upgrade_run_effect_value(id: String, temporary_level := 0) -> Dictionary:
	var permanent_level := clampi(get_upgrade_level(id), 0, get_upgrade_max_level(id))
	var temp_level := clampi(temporary_level, 0, get_upgrade_run_bonus_cap(id))
	var permanent_effect := get_upgrade_effect_value(id, permanent_level)
	var result: Dictionary = permanent_effect.duplicate(true)
	var base_value := float(permanent_effect.get("value", 0.0))
	var bonus_cap: int = max(1, get_upgrade_run_bonus_cap(id))
	var extra_max := float(UPGRADE_RUN_EXTRA_EFFECT_CAPS.get(id, float(UPGRADE_EFFECT_CAPS.get(id, 0.18)) * 0.22))
	var extra_value := 0.0
	if temp_level > 0:
		extra_value = extra_max * pow(clampf(float(temp_level) / float(bonus_cap), 0.0, 1.0), 0.78)
	var total_level := permanent_level + temp_level
	var total_value := clamp_upgrade_effect(id, base_value + extra_value)
	result["value"] = total_value
	result["level"] = total_level
	result["permanent_level"] = permanent_level
	result["temporary_level"] = temp_level
	result["max_level"] = get_upgrade_run_max_level(id)
	result["label"] = _upgrade_effect_label(id, String(result.get("type", "upgrade")), total_value, total_level)
	return result


func _upgrade_effect_label(id: String, effect_type: String, value: float, level: int) -> String:
	match id:
		"damage":
			return "+%s%% dano" % roundi(value * 100.0)
		"speed":
			return "+%s%% velocidade" % roundi(value * 100.0)
		"coinBoost", "magnetCoins", "secretMagnet":
			return "+%s%% moedas" % roundi(value * 100.0)
		"critical", "criticalOverload":
			return "+%s%% critico" % roundi(value * 100.0)
		"xpBoost":
			return "+%s%% XP" % roundi(value * 100.0)
		"perfectChance", "diamondInstinct":
			return "+%.1f%% diamante/perfect" % (value * 100.0)
		"frost":
			return "%.1f%% chance gelo" % (value * 100.0)
		"timeFreeze", "chronoBreak", "slowField":
			return "%.1f%% chance lentidao" % (value * 100.0)
		"ringRepulse":
			return "%.1f%% chance repulsao" % (value * 100.0)
		"chainLightning", "chainBreak":
			return "%.1f%% corrente" % (value * 100.0)
		"shockwave", "voidPulse", "bomb":
			return "%.1f%% area" % (value * 100.0)
	if effect_type == "bonus":
		return "+%s%% bonus" % roundi(value * 100.0)
	return "Lv.%s" % level


func get_upgrade_level(id: String) -> int:
	_ensure_upgrade_state()
	return int(data.get("upgrade_levels", {}).get(id, 0))


func is_upgrade_unlocked(id: String) -> bool:
	_ensure_upgrade_state()
	return Array(data.get("unlocked_upgrade_ids", [])).has(id)


func _balanced_upgrade_data(upgrade: Dictionary) -> Dictionary:
	var copy: Dictionary = Dictionary(upgrade).duplicate(true)
	var id := String(copy.get("id", ""))
	if not id.is_empty():
		copy["maxLevel"] = get_upgrade_max_level(id)
	return copy


func get_all_upgrades() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for upgrade in MainPortData.run_upgrades():
		result.append(_balanced_upgrade_data(upgrade))
	return result


func get_unlocked_upgrade_ids() -> Array[String]:
	_ensure_upgrade_state()
	var result: Array[String] = []
	for value in Array(data.get("unlocked_upgrade_ids", [])):
		var id := String(value)
		if MainPortData.is_run_upgrade_defined(id) and not result.has(id):
			result.append(id)
	return result


func get_unlocked_upgrades() -> Array[Dictionary]:
	var ids := get_unlocked_upgrade_ids()
	var result: Array[Dictionary] = []
	for upgrade in MainPortData.run_upgrades():
		var id := String(upgrade.get("id", ""))
		if ids.has(id):
			result.append(_balanced_upgrade_data(upgrade))
	return result


func get_locked_upgrades() -> Array[Dictionary]:
	var unlocked := get_unlocked_upgrade_ids()
	var result: Array[Dictionary] = []
	for upgrade in MainPortData.run_upgrades():
		var id := String(upgrade.get("id", ""))
		if not unlocked.has(id):
			result.append(_balanced_upgrade_data(upgrade))
	return result


func get_gameplay_upgrade_pool() -> Array[Dictionary]:
	return get_unlocked_upgrades()


func available_run_upgrade_ids() -> Array[String]:
	return get_unlocked_upgrade_ids()


func available_run_upgrades() -> Array[Dictionary]:
	return get_gameplay_upgrade_pool()


func purchase_permanent_upgrade(id: String) -> Dictionary:
	return upgrade_with_coins(id)


func upgrade_with_coins(id: String) -> Dictionary:
	_ensure_upgrade_state()
	if not MainPortData.is_run_upgrade_defined(id):
		return { "ok": false, "reason": "invalid" }
	if not is_upgrade_unlocked(id):
		return { "ok": false, "reason": "locked" }
	var levels: Dictionary = data.get("upgrade_levels", {})
	var level := int(levels.get(id, 0))
	var max_level := get_upgrade_max_level(id)
	if level >= max_level:
		return { "ok": false, "reason": "max" }
	var cost := get_upgrade_cost(id, level, "coins")
	if int(data.get("coins", 0)) < cost:
		return { "ok": false, "reason": "coins", "cost": cost }
	data["coins"] = max(0, int(data.get("coins", 0)) - cost)
	_set_upgrade_level(id, level + 1)
	_increment_stat("upgradesBought", 1, false)
	_progress_missions("upgradesBought", 1)
	_update_achievements(false)
	save_game()
	return { "ok": true, "level": level + 1, "cost": cost, "currency": "coins" }


func upgrade_with_diamonds(id: String) -> Dictionary:
	_ensure_upgrade_state()
	if not MainPortData.is_run_upgrade_defined(id):
		return { "ok": false, "reason": "invalid" }
	if not is_upgrade_unlocked(id):
		return { "ok": false, "reason": "locked" }
	var level := get_upgrade_level(id)
	var max_level := get_upgrade_max_level(id)
	if level >= max_level:
		return { "ok": false, "reason": "max" }
	var cost := get_upgrade_cost(id, level, "diamonds")
	if int(data.get("diamonds", 0)) < cost:
		return { "ok": false, "reason": "diamonds", "cost": cost }
	data["diamonds"] = max(0, int(data.get("diamonds", 0)) - cost)
	_set_upgrade_level(id, level + 1)
	_increment_stat("upgradesBought", 1, false)
	_progress_missions("upgradesBought", 1)
	_update_achievements(false)
	save_game()
	return { "ok": true, "level": level + 1, "cost": cost, "currency": "diamonds" }


func apply_reward(reward: Dictionary, save_after := false) -> String:
	var reward_type := String(reward.get("type", ""))
	var amount := int(reward.get("amount", 1))
	var text := "Reward"
	match reward_type:
		"coins":
			data["coins"] = max(0, int(data.get("coins", 0)) + amount)
			_add_earning_stats(amount, 0, 0, 0)
			text = "+%s coins" % amount
		"diamonds", "gems":
			data["diamonds"] = max(0, int(data.get("diamonds", 0)) + amount)
			_increment_stat("diamondsFound", amount, false)
			_increment_stat("diamonds_found", amount, false)
			_add_earning_stats(0, 0, amount, 0)
			text = "+%s diamonds" % amount
		"keys":
			data["keys"] = max(0, int(data.get("keys", 0)) + amount)
			_add_earning_stats(0, 0, 0, amount)
			text = "+%s keys" % amount
		"legendaryKeys", "legendary_keys":
			data["legendary_keys"] = max(0, int(data.get("legendary_keys", 0)) + amount)
			_add_earning_stats(0, 0, 0, amount)
			text = "+%s legendary keys" % amount
		"xp":
			add_profile_xp(amount)
			text = "+%s XP" % amount
		"profileXp", "profile_xp":
			add_profile_xp(amount)
			text = "+%s profile XP" % amount
		"fragments":
			var skin_id := String(reward.get("skin_id", reward.get("skinId", "generic")))
			var fragments: Dictionary = data.get("skin_fragments", {})
			fragments[skin_id] = int(fragments.get(skin_id, 0)) + amount
			data["skin_fragments"] = fragments
			text = "+%s fragments" % amount
		"skin":
			var skin_id := String(reward.get("skin_id", reward.get("skinId", "")))
			if Array(data.get("unlocked_skins", [])).has(skin_id):
				var compensation := _duplicate_skin_compensation(skin_id)
				data["diamonds"] = max(0, int(data.get("diamonds", 0)) + compensation)
				_increment_stat("diamondsFound", compensation, false)
				_increment_stat("diamonds_found", compensation, false)
				_add_earning_stats(0, 0, compensation, 0)
				reward["converted_from_skin"] = skin_id
				reward["type"] = "diamonds"
				reward["amount"] = compensation
				reward["duplicate_skin"] = true
				text = "Duplicate skin converted to +%s diamonds" % compensation
			else:
				unlock_skin(skin_id)
				reward["new_skin"] = true
				reward["rarity"] = _skin_rarity_from_id(skin_id)
				text = "Skin unlocked"
		"upgrade", "run_upgrade", "upgrade_unlock":
			var upgrade_id := String(reward.get("upgrade_id", reward.get("upgradeId", reward.get("id", ""))))
			if unlock_upgrade(upgrade_id):
				reward["new_upgrade"] = true
				text = "Upgrade unlocked"
			else:
				text = "Upgrade already unlocked"
		"chest":
			var chest_type := String(reward.get("chest_type", reward.get("chestType", "common")))
			add_inventory_item("chest_%s" % chest_type, "chest", "Chest %s" % chest_type.capitalize(), chest_type, amount)
			text = "+%s %s chest" % [amount, chest_type]
	if save_after:
		save_game()
	return text


func add_inventory_item(id: String, item_type: String, label: String, icon: String, amount: int) -> void:
	var inventory: Dictionary = data.get("inventory", {})
	var item: Dictionary = inventory.get(id, { "id": id, "type": item_type, "label": label, "icon": icon, "amount": 0 })
	item["amount"] = int(item.get("amount", 0)) + amount
	inventory[id] = item
	data["inventory"] = inventory
	save_game()


func unlock_upgrade(id: String) -> bool:
	_ensure_upgrade_state()
	if id.is_empty():
		return false
	if not MainPortData.is_run_upgrade_defined(id):
		return false
	var unlocked: Array = data.get("unlocked_upgrade_ids", [])
	if unlocked.has(id):
		return false
	unlocked.append(id)
	data["unlocked_upgrade_ids"] = unlocked
	data["unlocked_upgrades"] = unlocked.duplicate()
	var explicit: Array = data.get("explicit_unlocked_run_upgrades", [])
	if not STARTER_UPGRADE_IDS.has(id) and not explicit.has(id):
		explicit.append(id)
	data["explicit_unlocked_run_upgrades"] = explicit
	save_game()
	return true


func _set_upgrade_level(id: String, level: int) -> void:
	var levels: Dictionary = data.get("upgrade_levels", {})
	var max_level := get_upgrade_max_level(id)
	level = clampi(level, 0, max_level)
	if level <= 0:
		levels.erase(id)
	else:
		levels[id] = level
	data["upgrade_levels"] = levels
	data["permanent_upgrades"] = {
		"baseDamage": int(levels.get("damage", 0)),
		"baseSpeed": int(levels.get("speed", 0)),
		"coinMultiplier": int(levels.get("coinBoost", 0)),
		"critChance": int(levels.get("critical", 0)),
		"xpBoost": int(levels.get("xpBoost", 0)),
		"perfectChance": int(levels.get("perfectChance", 0)),
		"slowRings": int(levels.get("frost", 0)),
	}


func open_chest(chest_id: String) -> Dictionary:
	var inventory: Dictionary = data.get("inventory", {})
	if not inventory.has(chest_id) or int(inventory[chest_id].get("amount", 0)) <= 0:
		return { "ok": false, "reason": "empty" }
	var item: Dictionary = inventory[chest_id]
	item["amount"] = int(item.get("amount", 0)) - 1
	if int(item["amount"]) <= 0:
		inventory.erase(chest_id)
	else:
		inventory[chest_id] = item
	data["inventory"] = inventory
	var reward := _random_chest_reward(chest_id)
	var text := apply_reward(reward)
	_increment_stat("chests_opened", 1, false)
	_increment_stat("chestsOpened", 1, false)
	_progress_missions("chestsOpened", 1)
	_update_achievements(false)
	data["last_reward_text"] = text
	save_game()
	return { "ok": true, "reward": reward, "text": text }


func _random_chest_reward(chest_id: String) -> Dictionary:
	if chest_id.contains("legendary"):
		return { "type": "skin", "skin_id": _weighted_skin(["common", "rare", "epic", "legendary", "mythic", "ultimate"], [2.0, 8.0, 24.0, 50.0, 14.0, 2.0]) } if randf() < 0.42 else { "type": "diamonds", "amount": 110 }
	if chest_id.contains("epic"):
		return { "type": "skin", "skin_id": _weighted_skin(["common", "rare", "epic", "legendary", "mythic", "ultimate"], [8.0, 24.0, 55.0, 10.0, 2.6, 0.4]) } if randf() < 0.30 else { "type": "diamonds", "amount": 55 }
	if chest_id.contains("rare"):
		return { "type": "skin", "skin_id": _weighted_skin(["common", "rare", "epic", "legendary", "mythic", "ultimate"], [20.0, 63.0, 13.0, 3.0, 0.8, 0.2]) } if randf() < 0.20 else ({ "type": "keys", "amount": 1 } if randf() < 0.68 else { "type": "diamonds", "amount": 26 })
	return { "type": "skin", "skin_id": _weighted_skin(["common", "rare", "epic", "legendary", "mythic", "ultimate"], [82.0, 14.0, 3.0, 0.8, 0.18, 0.02]) } if randf() < 0.14 else { "type": "coins", "amount": 260 }


func claim_daily_reward() -> Dictionary:
	_ensure_live_systems()
	if not TimeManager.can_claim_daily_reward():
		return { "ok": false, "reason": "already_claimed" }
	var streak := TimeManager.update_daily_streak()
	var day_index := clampi(streak - 1, 0, DAILY_REWARDS.size() - 1)
	var reward: Dictionary = DAILY_REWARDS[day_index]
	var text := apply_reward(reward)
	TimeManager.mark_daily_reward_claimed()
	data["daily_streak"] = TimeManager.get_daily_streak()
	_increment_stat("daily_rewards_collected", 1, false)
	_increment_stat("dailyRewardsCollected", 1, false)
	_progress_missions("dailyRewardsCollected", 1)
	_update_achievements(false)
	data["last_reward_text"] = text
	save_game()
	return { "ok": true, "day": day_index + 1, "reward": reward, "text": text }


func spin_wheel(source := "free") -> Dictionary:
	_ensure_live_systems()
	var wheel: Dictionary = data.get("wheel", {})
	if source == "free" and bool(wheel.get("free_used", false)):
		return { "ok": false, "reason": "free_used" }
	if source == "ad" and int(wheel.get("ad_spins_used", 0)) >= 2:
		return { "ok": false, "reason": "ad_limit" }
	var rewards := _current_wheel_rewards()
	var reward: Dictionary = rewards[randi() % rewards.size()].duplicate(true)
	var text := apply_reward(reward)
	wheel["free_used"] = true if source == "free" else bool(wheel.get("free_used", false))
	wheel["ad_spins_used"] = int(wheel.get("ad_spins_used", 0)) + (1 if source == "ad" else 0)
	wheel["last_reward"] = reward
	data["wheel"] = wheel
	_increment_stat("wheelSpins", 1, false)
	_progress_missions("wheelSpins", 1)
	_update_achievements(false)
	data["last_reward_text"] = text
	save_game()
	return { "ok": true, "reward": reward, "text": text }


func _current_wheel_rewards() -> Array:
	var rewards := WHEEL_REWARDS.duplicate(true)
	rewards.append({ "type": "skin", "skin_id": _rotating_skin("common"), "wheel_slot": "weekly_common" })
	rewards.append({ "type": "skin", "skin_id": _rotating_skin("rare"), "wheel_slot": "weekly_rare" })
	rewards.append({ "type": "skin", "skin_id": _rotating_skin("epic"), "wheel_slot": "weekly_epic" })
	rewards.append({ "type": "skin", "skin_id": _rotating_skin("legendary"), "wheel_slot": "monthly_legendary" })
	if randf() < 0.18:
		rewards.append({ "type": "skin", "skin_id": _rotating_skin("mythic"), "wheel_slot": "monthly_mythic" })
	return rewards


func _weighted_skin(rarities: Array, weights: Array) -> String:
	var total := 0.0
	for weight in weights:
		total += max(0.0, float(weight))
	var roll: float = randf() * max(total, 0.001)
	var cursor := 0.0
	for i in range(min(rarities.size(), weights.size())):
		cursor += max(0.0, float(weights[i]))
		if roll <= cursor:
			return _rotating_skin(String(rarities[i]))
	return _rotating_skin(String(rarities[0])) if not rarities.is_empty() else "neon_blue"


func _rotating_skin(rarity: String) -> String:
	var candidates: Array = []
	for skin in MainPortData.SKINS:
		if String(skin.get("rarity", "common")) == rarity:
			candidates.append(String(skin.get("id", "")))
	if candidates.is_empty():
		return "neon_blue"
	var key: String = TimeManager.get_month_key() if rarity == "legendary" else TimeManager.get_week_key()
	var index: int = abs(hash("%s_%s" % [rarity, key])) % candidates.size()
	return String(candidates[index])


func _duplicate_skin_compensation(skin_id: String) -> int:
	match _skin_rarity_from_id(skin_id):
		"rare":
			return 18
		"epic":
			return 40
		"legendary":
			return 85
		"mythic":
			return 130
		"ultimate":
			return 180
	return 8


func show_mock_rewarded_ad(callback: Callable) -> void:
	if has_node("/root/AdManager"):
		AdManager.show_rewarded_ad("daily_bonus", callback)
	else:
		call_deferred("_complete_mock_rewarded_ad", callback)


func show_rewarded_ad(reason: String, callback: Callable) -> void:
	if has_node("/root/AdManager"):
		AdManager.show_rewarded_ad(reason, callback)
	else:
		call_deferred("_complete_mock_rewarded_ad", callback)


func _complete_mock_rewarded_ad(callback: Callable) -> void:
	if callback.is_valid():
		callback.call(true)


func shop_claim(action_id: String) -> Dictionary:
	var result := { "ok": true, "text": "" }
	match action_id:
		"common_chest":
			if not spend_coins(100):
				return { "ok": false, "reason": "coins" }
			add_inventory_item("chest_common", "chest", "Common Chest", "common", 1)
			result["reward"] = { "type": "chest", "chest_type": "common", "amount": 1 }
			result["text"] = "+1 common chest"
		"rare_chest":
			if not spend_diamonds(40):
				return { "ok": false, "reason": "diamonds" }
			add_inventory_item("chest_rare", "chest", "Rare Chest", "rare", 1)
			result["reward"] = { "type": "chest", "chest_type": "rare", "amount": 1 }
			result["text"] = "+1 rare chest"
		"epic_chest":
			if not spend_diamonds(120):
				return { "ok": false, "reason": "diamonds" }
			add_inventory_item("chest_epic", "chest", "Epic Chest", "epic", 1)
			result["reward"] = { "type": "chest", "chest_type": "epic", "amount": 1 }
			result["text"] = "+1 epic chest"
		"legendary_chest":
			if int(data.get("legendary_keys", 0)) < 1:
				return { "ok": false, "reason": "legendary_key" }
			data["legendary_keys"] = int(data.get("legendary_keys", 0)) - 1
			add_inventory_item("chest_legendary", "chest", "Legendary Chest", "legendary", 1)
			result["reward"] = { "type": "chest", "chest_type": "legendary", "amount": 1 }
			result["text"] = "+1 legendary chest"
		"keys_pack":
			if not spend_diamonds(80):
				return { "ok": false, "reason": "diamonds" }
			data["keys"] = int(data.get("keys", 0)) + 6
			_add_earning_stats(0, 0, 0, 6)
			result["reward"] = { "type": "keys", "amount": 6 }
			result["text"] = "+6 keys"
		"legendary_keys_pack":
			if not spend_diamonds(180):
				return { "ok": false, "reason": "diamonds" }
			data["legendary_keys"] = int(data.get("legendary_keys", 0)) + 2
			_add_earning_stats(0, 0, 0, 2)
			result["reward"] = { "type": "legendary_keys", "amount": 2 }
			result["text"] = "+2 legendary keys"
		"ad_gems":
			data["diamonds"] = int(data.get("diamonds", 0)) + 12
			_add_earning_stats(0, 0, 12, 0)
			result["reward"] = { "type": "diamonds", "amount": 12 }
			result["text"] = "+12 diamonds"
		"ad_coins":
			data["coins"] = int(data.get("coins", 0)) + 300
			_add_earning_stats(300, 0, 0, 0)
			result["reward"] = { "type": "coins", "amount": 300 }
			result["text"] = "+300 coins"
		"ad_key":
			data["keys"] = int(data.get("keys", 0)) + 1
			_add_earning_stats(0, 0, 0, 1)
			result["reward"] = { "type": "keys", "amount": 1 }
			result["text"] = "+1 key"
		"ad_chest":
			add_inventory_item("chest_common", "chest", "Common Chest", "common", 1)
			result["reward"] = { "type": "chest", "chest_type": "common", "amount": 1 }
			result["text"] = "+1 common chest"
		_:
			data["diamonds"] = int(data.get("diamonds", 0)) + 10
			_add_earning_stats(0, 0, 10, 0)
			result["reward"] = { "type": "diamonds", "amount": 10 }
			result["text"] = "Mock purchase +10 diamonds"
	_increment_stat("storePurchases", 1, false)
	_progress_missions("storePurchases", 1)
	_update_achievements(false)
	data["last_reward_text"] = String(result["text"])
	save_game()
	return result


func get_weekly_event(offset := 0) -> Dictionary:
	return _build_weekly_event(offset, offset == 0)


func get_next_weekly_event_preview() -> Dictionary:
	return _build_weekly_event(1, false)


func get_active_event_bonus() -> Dictionary:
	var event := get_weekly_event()
	if String(event.get("status", "")) != "active":
		return {}
	return Dictionary(event.get("bonus", {})).duplicate(true)


func get_active_event_bonus_value(bonus_type: String) -> float:
	var bonus := get_active_event_bonus()
	if String(bonus.get("type", "")) == bonus_type:
		return float(bonus.get("value", 0.0))
	return 0.0


func _build_weekly_event(offset: int, persist_state: bool) -> Dictionary:
	var definitions := _weekly_event_definitions()
	if definitions.is_empty():
		return {}
	var now := TimeManager.get_now_timestamp()
	var base_week_index := TimeManager.get_week_index(now)
	var absolute_week_index := base_week_index + offset
	var cycle_index := posmod(TimeManager.get_weekly_event_index(now) + offset, definitions.size())
	var starts_at := TimeManager.get_week_start_timestamp(now) + offset * TimeManager.SECONDS_PER_WEEK
	var ends_at := starts_at + TimeManager.SECONDS_PER_WEEK
	var definition: Dictionary = definitions[cycle_index]
	var event_id := "%s_%s" % [String(definition.get("id", "weekly_event")), TimeManager.get_week_key(starts_at)]
	var state := _weekly_event_state(event_id, definition, starts_at, ends_at) if persist_state else {}
	var tasks: Array[Dictionary] = []
	var claimed: Array = state.get("claimed", [])
	for raw_task in Array(definition.get("tasks", [])):
		var task: Dictionary = raw_task.duplicate(true)
		var metric := String(task.get("metric", ""))
		var progress := 0
		if persist_state:
			progress = _weekly_event_task_progress(metric, state)
		task["title"] = _localized_weekly_field(task, "title")
		task["desc"] = _localized_weekly_field(task, "desc")
		task["progress"] = progress
		task["completed"] = progress >= int(task.get("target", 1))
		task["claimed"] = claimed.has(String(task.get("id", "")))
		tasks.append(task)
	var completed_count := 0
	for task in tasks:
		if bool(task.get("completed", false)):
			completed_count += 1
	var final: Dictionary = Dictionary(definition.get("final", {})).duplicate(true)
	var final_id := String(final.get("id", "final_reward"))
	final["title"] = _localized_weekly_field(final, "title")
	final["desc"] = _localized_weekly_field(final, "desc")
	final["progress"] = completed_count
	final["target"] = tasks.size()
	final["completed"] = completed_count >= tasks.size()
	final["claimed"] = claimed.has(final_id)
	var status := "active"
	if now < starts_at:
		status = "future"
	elif now >= ends_at:
		status = "ended"
	elif bool(final.get("claimed", false)):
		status = "completed"
	return {
		"id": event_id,
		"base_id": String(definition.get("id", "")),
		"event_index": cycle_index,
		"week_index": absolute_week_index,
		"title": _localized_weekly_field(definition, "title"),
		"desc": _localized_weekly_field(definition, "desc"),
		"theme": String(definition.get("theme", "")),
		"color": String(definition.get("color", "#00f0ff")),
		"icon": String(definition.get("icon", "event")),
		"bonus": Dictionary(definition.get("bonus", {})).duplicate(true),
		"bonus_text": _localized_weekly_field(definition, "bonus"),
		"starts_at": starts_at,
		"ends_at": ends_at,
		"seconds_remaining": max(0, ends_at - now),
		"tasks": tasks,
		"final": final,
		"status": status,
	}


func _weekly_event_definitions() -> Array[Dictionary]:
	return [
		_weekly_event("neon_week", "Neon Week", "Semana Neon", "A bright start focused on rings, phases and coins.", "Um inicio brilhante focado em aneis, fases e moedas.", "neon", "#00f0ff", { "type": "coins", "value": 0.20 }, "+20% coins focus.", "+20% foco em moedas.", [
			_weekly_task("rings_120", "Break 120 rings", "Quebrar 120 aneis", "Destroy rings in any mode.", "Destrua aneis em qualquer modo.", "ringsDestroyed", 120, { "type": "coins", "amount": 900 }, "event", "#00f0ff"),
			_weekly_task("phases_5", "Complete 5 phases", "Concluir 5 fases", "Win normal phases.", "Venca fases normais.", "phaseWins", 5, { "type": "xp", "amount": 260 }, "play", "#00ff88"),
			_weekly_task("coins_3500", "Earn 3500 run coins", "Ganhar 3500 moedas de run", "Collect coins from gameplay.", "Colete moedas jogando.", "runCoins", 3500, { "type": "diamonds", "amount": 18 }, "coin", "#ffd700"),
		], _weekly_final({ "type": "chest", "chest_type": "rare", "amount": 1 }, "Rare Neon Chest", "Bau Neon Raro", "Complete every Neon Week goal.", "Conclua todos os objetivos da Semana Neon.", "chest_rare", "#00f0ff")),
		_weekly_event("chest_week", "Chest Week", "Semana dos Baus", "Keys, chests and phase wins are highlighted.", "Chaves, baus e vitorias de fase ficam em destaque.", "chests", "#ffd700", { "type": "chest_chance", "value": 0.08 }, "Higher chest chance.", "Chance maior de bau.", [
			_weekly_task("open_2", "Open 2 chests", "Abrir 2 baus", "Open any stored chest.", "Abra qualquer bau guardado.", "chestsOpened", 2, { "type": "keys", "amount": 1 }, "chest_rare", "#ffd700"),
			_weekly_task("wheel_2", "Spin the wheel 2 times", "Girar a roleta 2 vezes", "Use free or rewarded spins.", "Use giros gratis ou recompensados.", "wheelSpins", 2, { "type": "coins", "amount": 850 }, "wheel", "#00f0ff"),
			_weekly_task("phases_4", "Complete 4 phases", "Concluir 4 fases", "Win normal phases.", "Venca fases normais.", "phaseWins", 4, { "type": "diamonds", "amount": 15 }, "play", "#00ff88"),
		], _weekly_final({ "type": "chest", "chest_type": "epic", "amount": 1 }, "Epic Chest", "Bau Epico", "Complete every chest goal.", "Conclua todos os objetivos de baus.", "chest_epic", "#b000ff")),
		_weekly_event("diamond_week", "Diamond Week", "Semana dos Diamantes", "Perfect escapes and diamond drops shine brighter.", "Perfect Escapes e diamantes brilham mais.", "diamonds", "#67e8f9", { "type": "diamond_perfect", "value": 0.03 }, "Extra diamond chance on Perfect.", "Chance extra de diamante no Perfect.", [
			_weekly_task("perfect_8", "Make 8 Perfect Escapes", "Fazer 8 Perfect Escapes", "Hit ring openings cleanly.", "Acerte aberturas com precisao.", "perfectEscapes", 8, { "type": "diamonds", "amount": 20 }, "gem", "#67e8f9"),
			_weekly_task("diamonds_8", "Find 8 diamonds", "Encontrar 8 diamantes", "Earn diamonds from any source.", "Ganhe diamantes de qualquer fonte.", "diamondsFound", 8, { "type": "coins", "amount": 1000 }, "gem", "#00f0ff"),
			_weekly_task("wheel_2", "Spin the wheel 2 times", "Girar a roleta 2 vezes", "Try your luck this week.", "Teste sua sorte nesta semana.", "wheelSpins", 2, { "type": "keys", "amount": 1 }, "wheel", "#ffd700"),
		], _weekly_final({ "type": "diamonds", "amount": 55 }, "Diamond Cache", "Reserva de Diamantes", "Complete every diamond goal.", "Conclua todos os objetivos de diamantes.", "gem", "#67e8f9")),
		_weekly_event("fire_week", "Fire Week", "Semana de Fogo", "Fire and critical impacts get the spotlight.", "Fogo e impactos criticos ficam em destaque.", "fire", "#ff6b00", { "type": "fire_effect", "value": 0.15 }, "Fire effects are stronger.", "Efeitos de fogo ficam mais fortes.", [
			_weekly_task("skin_effects_8", "Trigger 8 skin effects", "Ativar 8 efeitos de skin", "Use skins with active effects.", "Use skins com efeitos ativos.", "skinEffects", 8, { "type": "coins", "amount": 950 }, "skins", "#ff6b00"),
			_weekly_task("crit_12", "Make 12 critical hits", "Fazer 12 criticos", "Critical hits count in all modes.", "Criticos contam em todos os modos.", "criticals", 12, { "type": "diamonds", "amount": 18 }, "crit", "#ff0055"),
			_weekly_task("boss_1", "Defeat 1 boss", "Derrotar 1 boss", "Win any boss difficulty.", "Venca qualquer dificuldade de boss.", "bossWins", 1, { "type": "keys", "amount": 1 }, "boss", "#ff6b00"),
		], _weekly_final({ "type": "skin", "skin_id": "fire", "amount": 1 }, "Fire Skin", "Skin de Fogo", "Complete every fire goal.", "Conclua todos os objetivos de fogo.", "skins", "#ff6b00")),
		_weekly_event("ice_week", "Ice Week", "Semana de Gelo", "Slow, freeze and clean phase progress.", "Lentidao, gelo e progresso limpo em fases.", "ice", "#8eeaff", { "type": "ice_duration", "value": 0.15 }, "Ice effects last longer.", "Efeitos de gelo duram mais.", [
			_weekly_task("perfect_10", "Make 10 Perfect Escapes", "Fazer 10 Perfect Escapes", "Clean openings feed the freeze core.", "Aberturas limpas alimentam o nucleo gelado.", "perfectEscapes", 10, { "type": "diamonds", "amount": 22 }, "perfect", "#8eeaff"),
			_weekly_task("rings_180", "Break 180 rings", "Quebrar 180 aneis", "Destroy rings in any mode.", "Destrua aneis em qualquer modo.", "ringsDestroyed", 180, { "type": "coins", "amount": 1200 }, "event", "#00f0ff"),
			_weekly_task("phases_6", "Complete 6 phases", "Concluir 6 fases", "Normal phases count.", "Fases normais contam.", "phaseWins", 6, { "type": "xp", "amount": 360 }, "play", "#00ff88"),
		], _weekly_final({ "type": "chest", "chest_type": "epic", "amount": 1 }, "Frozen Epic Chest", "Bau Epico Congelado", "Complete every ice goal.", "Conclua todos os objetivos de gelo.", "chest_epic", "#8eeaff")),
		_weekly_event("control_week", "Control Week", "Semana de Controle", "Directional skins and precise openings matter.", "Skins de controle e aberturas precisas importam.", "control", "#00ff88", { "type": "control_charge", "value": 1.0 }, "+1 safe temporary control charge.", "+1 carga temporaria segura de controle.", [
			_weekly_task("perfect_12", "Hit 12 openings", "Acertar 12 aberturas", "Perfect Escapes count as control mastery.", "Perfect Escapes contam como dominio de controle.", "perfectEscapes", 12, { "type": "diamonds", "amount": 24 }, "perfect", "#00ff88"),
			_weekly_task("infinite_90", "Survive 90s in Infinite", "Sobreviver 90s no Infinito", "Set or improve your Infinite time.", "Marque ou melhore seu tempo no Infinito.", "bestInfiniteSeconds", 90, { "type": "coins", "amount": 1100 }, "infinite", "#00f0ff"),
			_weekly_task("skin_equips_1", "Equip 1 skin", "Equipar 1 skin", "Try a useful control skin.", "Teste uma skin util.", "skinEquips", 1, { "type": "fragments", "skin_id": "control_orb", "amount": 8 }, "skins", "#ff00aa"),
		], _weekly_final({ "type": "diamonds", "amount": 45 }, "Control Cache", "Reserva de Controle", "Complete every control goal.", "Conclua todos os objetivos de controle.", "gem", "#00ff88")),
		_weekly_event("league_week", "Neon League Week", "Semana da Liga Neon", "Ranked battles pay extra attention to wins.", "Batalhas ranqueadas valorizam vitorias.", "league", "#ffd700", { "type": "league_trophies", "value": 0.10 }, "+10% trophies on wins.", "+10% trofeus em vitorias.", [
			_weekly_task("league_matches_3", "Play 3 League matches", "Jogar 3 partidas da Liga", "Fight ranked rivals.", "Enfrente rivais ranqueados.", "leagueMatches", 3, { "type": "coins", "amount": 1200 }, "league", "#ffd700"),
			_weekly_task("league_wins_2", "Win 2 League matches", "Vencer 2 partidas da Liga", "Win ranked fights.", "Venca lutas ranqueadas.", "leagueWins", 2, { "type": "diamonds", "amount": 28 }, "league", "#00ff88"),
			_weekly_task("rings_180", "Break 180 battle rings", "Quebrar 180 aneis de batalha", "League and boss rings count too.", "Aneis de Liga e boss tambem contam.", "ringsDestroyed", 180, { "type": "keys", "amount": 1 }, "event", "#00f0ff"),
		], _weekly_final({ "type": "chest", "chest_type": "rare", "amount": 2 }, "League Chest Pair", "Par de Baus da Liga", "Complete every League goal.", "Conclua todos os objetivos da Liga.", "chest_rare", "#ffd700")),
		_weekly_event("boss_week", "Boss Week", "Semana do Boss", "Boss fights grant focused weekly progress.", "Lutas contra boss geram progresso semanal.", "boss", "#ff0055", { "type": "boss_damage", "value": 0.15 }, "+15% boss damage focus.", "+15% foco de dano contra boss.", [
			_weekly_task("boss_matches_2", "Fight bosses 2 times", "Lutar contra bosses 2 vezes", "Any boss difficulty counts.", "Qualquer dificuldade de boss conta.", "bossMatches", 2, { "type": "coins", "amount": 1300 }, "boss", "#ff0055"),
			_weekly_task("boss_win_1", "Defeat 1 boss", "Derrotar 1 boss", "Win a boss fight.", "Venca uma luta contra boss.", "bossWins", 1, { "type": "diamonds", "amount": 35 }, "boss", "#ffd700"),
			_weekly_task("crit_18", "Make 18 critical hits", "Fazer 18 criticos", "Critical impacts count anywhere.", "Impactos criticos contam em qualquer modo.", "criticals", 18, { "type": "keys", "amount": 1 }, "crit", "#ff6b00"),
		], _weekly_final({ "type": "chest", "chest_type": "epic", "amount": 1 }, "Boss Epic Chest", "Bau Epico do Boss", "Complete every boss goal.", "Conclua todos os objetivos de boss.", "chest_epic", "#ff0055")),
		_weekly_event("infinite_week", "Infinite Week", "Semana do Infinito", "Endless survival and ring destruction rule.", "Sobrevivencia sem fim e destruicao de aneis dominam.", "infinite", "#00ffcc", { "type": "infinite_rewards", "value": 0.20 }, "+20% Infinite reward focus.", "+20% foco em recompensa do Infinito.", [
			_weekly_task("infinite_runs_3", "Play Infinite 3 times", "Jogar Infinito 3 vezes", "Start Infinite runs.", "Inicie partidas infinitas.", "infiniteRuns", 3, { "type": "coins", "amount": 1100 }, "infinite", "#00ffcc"),
			_weekly_task("infinite_150", "Survive 150s in Infinite", "Sobreviver 150s no Infinito", "Improve your best time.", "Melhore seu melhor tempo.", "bestInfiniteSeconds", 150, { "type": "diamonds", "amount": 30 }, "infinite", "#00f0ff"),
			_weekly_task("infinite_rings_35", "Break 35 Infinite rings", "Quebrar 35 aneis no Infinito", "Best Infinite ring count.", "Melhor quantidade de aneis no Infinito.", "bestInfiniteRings", 35, { "type": "xp", "amount": 420 }, "event", "#ffd700"),
		], _weekly_final({ "type": "skin", "skin_id": "infinite_pulse", "amount": 1 }, "Infinite Pulse", "Pulso Infinito", "Complete every Infinite goal.", "Conclua todos os objetivos do Infinito.", "skins", "#00ffcc")),
		_weekly_event("critical_week", "Critical Week", "Semana dos Criticos", "Critical impacts bring faster weekly rewards.", "Impactos criticos trazem recompensas semanais.", "critical", "#ff2d75", { "type": "crit_chance", "value": 0.05 }, "+5% critical chance focus.", "+5% foco em chance critica.", [
			_weekly_task("crit_25", "Make 25 critical hits", "Fazer 25 criticos", "Criticals count in all modes.", "Criticos contam em todos os modos.", "criticals", 25, { "type": "diamonds", "amount": 28 }, "crit", "#ff2d75"),
			_weekly_task("rings_220", "Break 220 rings", "Quebrar 220 aneis", "Break rings after critical boosts.", "Quebre aneis com bonus critico.", "ringsDestroyed", 220, { "type": "coins", "amount": 1500 }, "event", "#00f0ff"),
			_weekly_task("phases_7", "Complete 7 phases", "Concluir 7 fases", "Win normal phases.", "Venca fases normais.", "phaseWins", 7, { "type": "xp", "amount": 460 }, "play", "#00ff88"),
		], _weekly_final({ "type": "diamonds", "amount": 70 }, "Critical Diamonds", "Diamantes Criticos", "Complete every critical goal.", "Conclua todos os objetivos criticos.", "gem", "#ff2d75")),
		_weekly_event("cosmic_week", "Cosmic Week", "Semana Cosmica", "Epic skins, XP and Infinite runs glow brighter.", "Skins epicas, XP e Infinito brilham mais.", "cosmic", "#8b5cf6", { "type": "cosmic_reward", "value": 0.10 }, "Small cosmic reward focus.", "Pequeno foco de recompensa cosmica.", [
			_weekly_task("xp_coins_4500", "Earn 4500 run coins", "Ganhar 4500 moedas de run", "Farm gameplay resources.", "Farme recursos jogando.", "runCoins", 4500, { "type": "xp", "amount": 500 }, "coin", "#ffd700"),
			_weekly_task("infinite_runs_2", "Play Infinite 2 times", "Jogar Infinito 2 vezes", "Cosmic loops count.", "Loops cosmicos contam.", "infiniteRuns", 2, { "type": "diamonds", "amount": 25 }, "infinite", "#8b5cf6"),
			_weekly_task("skin_effects_12", "Trigger 12 skin effects", "Ativar 12 efeitos de skin", "Let special skins shine.", "Deixe skins especiais brilharem.", "skinEffects", 12, { "type": "coins", "amount": 1300 }, "skins", "#ff00aa"),
		], _weekly_final({ "type": "chest", "chest_type": "epic", "amount": 1 }, "Cosmic Epic Chest", "Bau Epico Cosmico", "Complete every cosmic goal.", "Conclua todos os objetivos cosmicos.", "chest_epic", "#8b5cf6")),
		_weekly_event("key_week", "Key Week", "Semana das Chaves", "Wheel, chests and phases focus on key rewards.", "Roleta, baus e fases focam em chaves.", "keys", "#facc15", { "type": "key_chance", "value": 0.08 }, "Better key chance focus.", "Foco em chance melhor de chaves.", [
			_weekly_task("wheel_3", "Spin the wheel 3 times", "Girar a roleta 3 vezes", "Look for keys and bonus prizes.", "Procure chaves e premios bonus.", "wheelSpins", 3, { "type": "keys", "amount": 1 }, "wheel", "#facc15"),
			_weekly_task("chests_2", "Open 2 chests", "Abrir 2 baus", "Use your stored chests.", "Use seus baus guardados.", "chestsOpened", 2, { "type": "diamonds", "amount": 22 }, "chest_rare", "#00f0ff"),
			_weekly_task("phases_6", "Complete 6 phases", "Concluir 6 fases", "Win normal phases.", "Venca fases normais.", "phaseWins", 6, { "type": "coins", "amount": 1250 }, "play", "#00ff88"),
		], _weekly_final({ "type": "keys", "amount": 3 }, "Key Bundle", "Pacote de Chaves", "Complete every key goal.", "Conclua todos os objetivos de chaves.", "key", "#facc15")),
		_weekly_event("golden_week", "Golden Week", "Semana Dourada", "Coins, upgrades and skin growth are the focus.", "Moedas, melhorias e evolucao de skin sao o foco.", "gold", "#ffd700", { "type": "coins", "value": 0.30 }, "+30% coin focus.", "+30% foco em moedas.", [
			_weekly_task("coins_6000", "Earn 6000 run coins", "Ganhar 6000 moedas de run", "Farm coins in any mode.", "Farme moedas em qualquer modo.", "runCoins", 6000, { "type": "coins", "amount": 1800 }, "coin", "#ffd700"),
			_weekly_task("upgrades_2", "Buy 2 upgrades", "Comprar 2 melhorias", "Permanent upgrades count.", "Melhorias permanentes contam.", "upgradesBought", 2, { "type": "diamonds", "amount": 24 }, "upgrades", "#00f0ff"),
			_weekly_task("phase_8", "Complete 8 phases", "Concluir 8 fases", "Win normal phases.", "Venca fases normais.", "phaseWins", 8, { "type": "xp", "amount": 520 }, "play", "#00ff88"),
		], _weekly_final({ "type": "coins", "amount": 4500 }, "Golden Vault", "Cofre Dourado", "Complete every golden goal.", "Conclua todos os objetivos dourados.", "coin", "#ffd700")),
		_weekly_event("skins_week", "Skins Week", "Semana das Skins", "Chests and skin collection take center stage.", "Baus e colecao de skins ficam no centro.", "skins", "#ff4fd8", { "type": "skin_chance", "value": 0.06 }, "Better skin chance in chests.", "Chance melhor de skin em baus.", [
			_weekly_task("chests_3", "Open 3 chests", "Abrir 3 baus", "Open stored chests.", "Abra baus guardados.", "chestsOpened", 3, { "type": "diamonds", "amount": 30 }, "chest_rare", "#ff4fd8"),
			_weekly_task("equip_2", "Equip 2 skins", "Equipar 2 skins", "Try different skins.", "Teste skins diferentes.", "skinEquips", 2, { "type": "coins", "amount": 1400 }, "skins", "#00f0ff"),
			_weekly_task("effects_14", "Trigger 14 skin effects", "Ativar 14 efeitos de skin", "Use skins with passives.", "Use skins com passivas.", "skinEffects", 14, { "type": "keys", "amount": 1 }, "skins", "#00ff88"),
		], _weekly_final({ "type": "skin", "skin_id": "star_rare", "amount": 1 }, "Guaranteed Rare Skin", "Skin Rara Garantida", "Complete every skins goal.", "Conclua todos os objetivos de skins.", "skins", "#ff4fd8")),
		_weekly_event("mythic_week", "Mythic Week", "Semana das Miticas", "Advanced phases, bosses and Infinite goals matter.", "Fases avancadas, bosses e Infinito importam.", "mythic", "#b000ff", { "type": "mythic_fragments", "value": 0.04 }, "Small rare+ fragment focus.", "Pequeno foco em fragmentos raros+.", [
			_weekly_task("phase_10", "Complete 10 phases", "Concluir 10 fases", "Normal phase wins count.", "Vitorias em fases normais contam.", "phaseWins", 10, { "type": "diamonds", "amount": 35 }, "play", "#00ff88"),
			_weekly_task("boss_1", "Defeat 1 boss", "Derrotar 1 boss", "Win any boss fight.", "Venca qualquer boss.", "bossWins", 1, { "type": "keys", "amount": 1 }, "boss", "#ff0055"),
			_weekly_task("infinite_210", "Survive 210s in Infinite", "Sobreviver 210s no Infinito", "Push your endless record.", "Empurre seu recorde infinito.", "bestInfiniteSeconds", 210, { "type": "coins", "amount": 1800 }, "infinite", "#00f0ff"),
		], _weekly_final({ "type": "chest", "chest_type": "rare", "amount": 2 }, "Mythic Prep Chests", "Baus de Preparo Mitico", "Complete every mythic goal.", "Conclua todos os objetivos miticos.", "chest_rare", "#b000ff")),
		_weekly_event("ultimate_week", "Ultimate Week", "Semana Ultimate", "Hard goals with premium resources.", "Objetivos dificeis com recursos premium.", "ultimate", "#ffffff", { "type": "hard_progress", "value": 0.10 }, "Extra difficult progress focus.", "Foco extra em progresso dificil.", [
			_weekly_task("rings_420", "Break 420 rings", "Quebrar 420 aneis", "All modes count.", "Todos os modos contam.", "ringsDestroyed", 420, { "type": "diamonds", "amount": 45 }, "event", "#ffffff"),
			_weekly_task("league_wins_3", "Win 3 League matches", "Vencer 3 partidas da Liga", "Ranked wins count.", "Vitorias ranqueadas contam.", "leagueWins", 3, { "type": "coins", "amount": 2200 }, "league", "#ffd700"),
			_weekly_task("boss_2", "Defeat 2 bosses", "Derrotar 2 bosses", "Daily bosses count.", "Bosses diarios contam.", "bossWins", 2, { "type": "keys", "amount": 2 }, "boss", "#ff0055"),
		], _weekly_final({ "type": "chest", "chest_type": "rare", "amount": 3 }, "Ultimate Supply", "Suprimento Ultimate", "Complete every ultimate goal.", "Conclua todos os objetivos ultimate.", "chest_rare", "#ffffff")),
		_weekly_event("lightning_week", "Lightning Week", "Semana Relampago", "Fast runs, combos and perfects gain focus.", "Runs rapidas, combos e perfects ganham foco.", "lightning", "#faff00", { "type": "xp", "value": 0.18 }, "More XP focus.", "Mais foco em XP.", [
			_weekly_task("combo_12", "Reach combo 12", "Alcancar combo 12", "Best combo counts.", "Melhor combo conta.", "bestCombo", 12, { "type": "xp", "amount": 520 }, "combo", "#faff00"),
			_weekly_task("perfect_14", "Make 14 Perfect Escapes", "Fazer 14 Perfect Escapes", "Precise breaks count.", "Quebras precisas contam.", "perfectEscapes", 14, { "type": "diamonds", "amount": 30 }, "perfect", "#00f0ff"),
			_weekly_task("phase_8", "Complete 8 phases", "Concluir 8 fases", "Win normal phases.", "Venca fases normais.", "phaseWins", 8, { "type": "coins", "amount": 1500 }, "play", "#00ff88"),
		], _weekly_final({ "type": "chest", "chest_type": "rare", "amount": 1 }, "Lightning Rare Chest", "Bau Raro Relampago", "Complete every lightning goal.", "Conclua todos os objetivos relampago.", "chest_rare", "#faff00")),
		_weekly_event("shadow_week", "Shadow Week", "Semana Sombria", "Hard modes and darker rewards.", "Modos dificeis e recompensas sombrias.", "shadow", "#7c3aed", { "type": "hard_rewards", "value": 0.12 }, "Better hard-mode reward focus.", "Foco em recompensas melhores em modos dificeis.", [
			_weekly_task("phase_12", "Complete 12 phases", "Concluir 12 fases", "Normal phases count.", "Fases normais contam.", "phaseWins", 12, { "type": "coins", "amount": 2000 }, "play", "#7c3aed"),
			_weekly_task("boss_1", "Defeat 1 boss", "Derrotar 1 boss", "Boss victory counts.", "Vitoria contra boss conta.", "bossWins", 1, { "type": "diamonds", "amount": 35 }, "boss", "#ff0055"),
			_weekly_task("league_2", "Win 2 League matches", "Vencer 2 partidas da Liga", "League wins count.", "Vitorias da Liga contam.", "leagueWins", 2, { "type": "keys", "amount": 1 }, "league", "#ffd700"),
		], _weekly_final({ "type": "chest", "chest_type": "epic", "amount": 1 }, "Shadow Epic Chest", "Bau Epico Sombrio", "Complete every shadow goal.", "Conclua todos os objetivos sombrios.", "chest_epic", "#7c3aed")),
		_weekly_event("prism_week", "Prismatic Week", "Semana Prismatica", "Wheel spins and mixed resource gains.", "Giros da roleta e ganhos mistos de recursos.", "prism", "#ff4fd8", { "type": "wheel_luck", "value": 0.08 }, "Better wheel focus.", "Foco em roleta melhorada.", [
			_weekly_task("wheel_4", "Spin the wheel 4 times", "Girar a roleta 4 vezes", "Use all spin options.", "Use todas as opcoes de giro.", "wheelSpins", 4, { "type": "diamonds", "amount": 32 }, "wheel", "#ff4fd8"),
			_weekly_task("coins_5200", "Earn 5200 run coins", "Ganhar 5200 moedas de run", "Collect gameplay coins.", "Colete moedas jogando.", "runCoins", 5200, { "type": "coins", "amount": 1600 }, "coin", "#ffd700"),
			_weekly_task("daily_2", "Play 2 Daily Challenges", "Jogar 2 Desafios Diarios", "Daily Challenge runs count.", "Partidas do Desafio Diario contam.", "dailyChallengeRuns", 2, { "type": "keys", "amount": 1 }, "event", "#00ff88"),
		], _weekly_final({ "type": "diamonds", "amount": 80 }, "Prismatic Diamonds", "Diamantes Prismaticos", "Complete every prism goal.", "Conclua todos os objetivos prismaticos.", "gem", "#ff4fd8")),
		_weekly_event("upgrades_week", "Upgrades Week", "Semana dos Upgrades", "Permanent upgrades cost less in spirit and progress faster.", "Melhorias permanentes ficam em foco.", "upgrades", "#00f0ff", { "type": "upgrade_discount", "value": 0.08 }, "Small permanent upgrade discount focus.", "Pequeno foco em desconto de melhorias permanentes.", [
			_weekly_task("buy_3", "Buy 3 upgrades", "Comprar 3 melhorias", "Permanent upgrade purchases count.", "Compras de melhoria permanente contam.", "upgradesBought", 3, { "type": "diamonds", "amount": 35 }, "upgrades", "#00f0ff"),
			_weekly_task("phase_8", "Complete 8 phases", "Concluir 8 fases", "Normal phases count.", "Fases normais contam.", "phaseWins", 8, { "type": "coins", "amount": 1900 }, "play", "#00ff88"),
			_weekly_task("coins_5000", "Earn 5000 run coins", "Ganhar 5000 moedas de run", "Fund your upgrades.", "Financie suas melhorias.", "runCoins", 5000, { "type": "xp", "amount": 500 }, "coin", "#ffd700"),
		], _weekly_final({ "type": "diamonds", "amount": 70 }, "Upgrade Fund", "Fundo de Melhorias", "Complete every upgrade goal.", "Conclua todos os objetivos de melhoria.", "gem", "#00f0ff")),
		_weekly_event("evolution_week", "Evolution Week", "Semana da Evolucao", "Skin upgrades and wins push progression.", "Upgrades de skin e vitorias empurram progresso.", "evolution", "#00ff88", { "type": "skin_upgrade_discount", "value": 0.08 }, "Small skin upgrade discount focus.", "Pequeno foco em desconto para upar skins.", [
			_weekly_task("skin_equips_2", "Equip 2 skins", "Equipar 2 skins", "Try evolved skins.", "Teste skins evoluidas.", "skinEquips", 2, { "type": "coins", "amount": 1500 }, "skins", "#00ff88"),
			_weekly_task("phase_9", "Complete 9 phases", "Concluir 9 fases", "Normal phases count.", "Fases normais contam.", "phaseWins", 9, { "type": "diamonds", "amount": 30 }, "play", "#00f0ff"),
			_weekly_task("effects_18", "Trigger 18 skin effects", "Ativar 18 efeitos de skin", "Skin effects count in gameplay.", "Efeitos de skin contam na gameplay.", "skinEffects", 18, { "type": "fragments", "skin_id": "neon_blue", "amount": 20 }, "skins", "#ff4fd8"),
		], _weekly_final({ "type": "diamonds", "amount": 65 }, "Evolution Crystals", "Cristais de Evolucao", "Complete every evolution goal.", "Conclua todos os objetivos de evolucao.", "gem", "#00ff88")),
		_weekly_event("perfect_week", "Perfect Week", "Semana dos Perfects", "Perfects grant more weekly XP and diamonds.", "Perfects rendem mais XP e diamantes semanais.", "perfect", "#ffffff", { "type": "perfect_xp", "value": 0.20 }, "Perfect grants more XP focus.", "Perfect da mais foco em XP.", [
			_weekly_task("perfect_22", "Make 22 Perfect Escapes", "Fazer 22 Perfect Escapes", "Clean openings count.", "Aberturas limpas contam.", "perfectEscapes", 22, { "type": "diamonds", "amount": 45 }, "perfect", "#ffffff"),
			_weekly_task("combo_15", "Reach combo 15", "Alcancar combo 15", "Best combo counts.", "Melhor combo conta.", "bestCombo", 15, { "type": "coins", "amount": 1800 }, "combo", "#ffd700"),
			_weekly_task("diamonds_12", "Find 12 diamonds", "Encontrar 12 diamantes", "Diamonds from all sources count.", "Diamantes de todas as fontes contam.", "diamondsFound", 12, { "type": "xp", "amount": 600 }, "gem", "#00f0ff"),
		], _weekly_final({ "type": "chest", "chest_type": "epic", "amount": 1 }, "Perfect Epic Chest", "Bau Epico Perfect", "Complete every perfect goal.", "Conclua todos os objetivos perfect.", "chest_epic", "#ffffff")),
		_weekly_event("combo_week", "Combo Week", "Semana dos Combos", "Long streaks bring coin-heavy rewards.", "Sequencias longas trazem recompensas de moedas.", "combo", "#ffb000", { "type": "combo_coins", "value": 0.12 }, "Combo gives extra coin focus.", "Combo da foco em moedas extras.", [
			_weekly_task("combo_10", "Reach combo 10", "Alcancar combo 10", "Any mode counts.", "Qualquer modo conta.", "bestCombo", 10, { "type": "coins", "amount": 1300 }, "combo", "#ffb000"),
			_weekly_task("combo_20", "Reach combo 20", "Alcancar combo 20", "Push the streak further.", "Leve a sequencia mais longe.", "bestCombo", 20, { "type": "diamonds", "amount": 35 }, "combo", "#ff6b00"),
			_weekly_task("rings_260", "Break 260 rings", "Quebrar 260 aneis", "Ring clears support combo week.", "Quebras de aneis apoiam a semana.", "ringsDestroyed", 260, { "type": "keys", "amount": 1 }, "event", "#00f0ff"),
		], _weekly_final({ "type": "coins", "amount": 5000 }, "Combo Treasury", "Tesouro de Combo", "Complete every combo goal.", "Conclua todos os objetivos de combo.", "coin", "#ffb000")),
		_weekly_event("champions_week", "Champions Week", "Semana dos Campeoes", "Play every major mode for a legendary finish.", "Jogue todos os modos principais para um final lendario.", "champions", "#ffd700", { "type": "all_modes_reward", "value": 0.12 }, "League/Boss/Infinite reward focus.", "Foco em recompensas de Liga/Boss/Infinito.", [
			_weekly_task("league_win_2", "Win 2 League matches", "Vencer 2 partidas da Liga", "Ranked wins count.", "Vitorias ranqueadas contam.", "leagueWins", 2, { "type": "diamonds", "amount": 35 }, "league", "#ffd700"),
			_weekly_task("boss_win_1", "Defeat 1 boss", "Derrotar 1 boss", "Boss victory counts.", "Vitoria contra boss conta.", "bossWins", 1, { "type": "keys", "amount": 1 }, "boss", "#ff0055"),
			_weekly_task("infinite_240", "Survive 240s in Infinite", "Sobreviver 240s no Infinito", "Endless survival counts.", "Sobrevivencia infinita conta.", "bestInfiniteSeconds", 240, { "type": "coins", "amount": 2200 }, "infinite", "#00f0ff"),
		], _weekly_final({ "type": "chest", "chest_type": "rare", "amount": 3 }, "Champion Chests", "Baus dos Campeoes", "Complete every champion goal.", "Conclua todos os objetivos de campeao.", "chest_rare", "#ffd700")),
		_weekly_event("eclipse_week", "Eclipse Week", "Semana do Eclipse", "High pressure goals near the end of the cycle.", "Objetivos de alta pressao perto do fim do ciclo.", "eclipse", "#111111", { "type": "eclipse_reward", "value": 0.12 }, "Hard event reward focus.", "Foco em recompensa de evento dificil.", [
			_weekly_task("phase_14", "Complete 14 phases", "Concluir 14 fases", "Normal phase wins count.", "Vitorias em fases normais contam.", "phaseWins", 14, { "type": "diamonds", "amount": 45 }, "play", "#00ff88"),
			_weekly_task("boss_2", "Defeat 2 bosses", "Derrotar 2 bosses", "Boss wins count.", "Vitorias contra boss contam.", "bossWins", 2, { "type": "keys", "amount": 2 }, "boss", "#ff0055"),
			_weekly_task("infinite_rings_60", "Break 60 Infinite rings", "Quebrar 60 aneis no Infinito", "Best Infinite ring count.", "Melhor contagem de aneis no Infinito.", "bestInfiniteRings", 60, { "type": "coins", "amount": 2600 }, "infinite", "#00f0ff"),
		], _weekly_final({ "type": "skin", "skin_id": "black_sun", "amount": 1 }, "Eclipse Skin", "Skin do Eclipse", "Complete every eclipse goal.", "Conclua todos os objetivos do eclipse.", "skins", "#111111")),
		_weekly_event("singularity_week", "Singularity Week", "Semana da Singularidade", "The cycle closes with the biggest weekly goals.", "O ciclo fecha com os maiores objetivos semanais.", "singularity", "#ff2d75", { "type": "cycle_finale", "value": 0.15 }, "Final cycle reward focus.", "Foco em recompensa final do ciclo.", [
			_weekly_task("rings_520", "Break 520 rings", "Quebrar 520 aneis", "All rings count.", "Todos os aneis contam.", "ringsDestroyed", 520, { "type": "diamonds", "amount": 60 }, "event", "#ff2d75"),
			_weekly_task("all_modes_6", "Play 6 runs", "Jogar 6 partidas", "Any mode counts.", "Qualquer modo conta.", "runsPlayed", 6, { "type": "coins", "amount": 3200 }, "play", "#00f0ff"),
			_weekly_task("league_boss", "Win League and Boss", "Vencer Liga e Boss", "Earn 2 League wins this week.", "Ganhe 2 vitorias na Liga nesta semana.", "leagueWins", 2, { "type": "keys", "amount": 2 }, "league", "#ffd700"),
		], _weekly_final({ "type": "diamonds", "amount": 120 }, "Singularity Reward", "Recompensa da Singularidade", "Complete every singularity goal.", "Conclua todos os objetivos da singularidade.", "gem", "#ff2d75")),
	]


func _weekly_event(id: String, title_en: String, title_pt: String, desc_en: String, desc_pt: String, theme: String, color: String, bonus: Dictionary, bonus_en: String, bonus_pt: String, tasks: Array, final: Dictionary) -> Dictionary:
	return {
		"id": id,
		"title_en": title_en,
		"title_pt": title_pt,
		"desc_en": desc_en,
		"desc_pt": desc_pt,
		"theme": theme,
		"color": color,
		"icon": "event",
		"bonus": bonus,
		"bonus_en": bonus_en,
		"bonus_pt": bonus_pt,
		"tasks": tasks,
		"final": final,
	}


func _weekly_task(id: String, title_en: String, title_pt: String, desc_en: String, desc_pt: String, metric: String, target: int, reward: Dictionary, icon: String, tone: String) -> Dictionary:
	return {
		"id": id,
		"title_en": title_en,
		"title_pt": title_pt,
		"desc_en": desc_en,
		"desc_pt": desc_pt,
		"metric": metric,
		"target": target,
		"reward": reward,
		"icon": icon,
		"tone": tone,
	}


func _weekly_final(reward: Dictionary, title_en: String, title_pt: String, desc_en: String, desc_pt: String, icon: String, tone: String) -> Dictionary:
	return {
		"id": "final_reward",
		"title_en": title_en,
		"title_pt": title_pt,
		"desc_en": desc_en,
		"desc_pt": desc_pt,
		"reward": reward,
		"icon": icon,
		"tone": tone,
	}


func _localized_weekly_field(source: Dictionary, field: String) -> String:
	var language := String(data.get("settings", {}).get("language", "en"))
	if has_node("/root/LocalizationManager"):
		language = LocalizationManager.current_language()
	if language.begins_with("pt"):
		return String(source.get("%s_pt" % field, source.get("%s_en" % field, source.get(field, ""))))
	return String(source.get("%s_en" % field, source.get(field, "")))


func _weekly_event_task_progress(metric: String, state: Dictionary) -> int:
	var progress: Dictionary = state.get("progress", {})
	var baseline: Dictionary = state.get("baseline", {})
	var current: int = _event_metric_value(metric)
	var delta: int = max(0, current - int(baseline.get(metric, current)))
	return max(delta, int(progress.get(metric, 0)))


func claim_weekly_event_reward(reward_id: String) -> Dictionary:
	var event := get_weekly_event()
	var event_id := String(event.get("id", ""))
	var state: Dictionary = data.get("events", {}).get(event_id, {})
	var claimed: Array = state.get("claimed", [])
	if claimed.has(reward_id):
		return { "ok": false, "reason": "already_claimed" }
	var reward: Dictionary = {}
	var ready := false
	var final: Dictionary = event.get("final", {})
	if reward_id == String(final.get("id", "final_reward")):
		ready = bool(final.get("completed", false))
		reward = Dictionary(final.get("reward", {})).duplicate(true)
	else:
		for task in Array(event.get("tasks", [])):
			var item: Dictionary = task
			if String(item.get("id", "")) == reward_id:
				ready = bool(item.get("completed", false))
				reward = Dictionary(item.get("reward", {})).duplicate(true)
				break
	if not ready or reward.is_empty():
		return { "ok": false, "reason": "not_ready" }
	var text := apply_reward(reward)
	claimed.append(reward_id)
	state["claimed"] = claimed
	var events: Dictionary = data.get("events", {})
	events[event_id] = state
	data["events"] = events
	data["last_reward_text"] = text
	_increment_stat("eventRewardsClaimed", 1, false)
	if reward_id == String(final.get("id", "final_reward")):
		_increment_stat("eventsCompleted", 1, false)
	else:
		_increment_stat("eventMissionsCompleted", 1, false)
	add_neon_pass_xp(150 if reward_id == String(final.get("id", "final_reward")) else int(NEON_PASS_SOURCE_XP.get("event_mission", 75)), "event_mission")
	save_game()
	return { "ok": true, "reward": reward, "text": text }


func get_daily_challenge() -> Dictionary:
	_ensure_daily_challenge_state()
	var now := TimeManager.get_now_timestamp()
	var day_key := TimeManager.get_day_key(now)
	var daily: Dictionary = data.get("daily_challenge", {})
	var seed_text := String(daily.get("seed_override", ""))
	var seed := _stable_daily_seed(day_key if seed_text.is_empty() else seed_text)
	var difficulty := 1 + int(seed % 5)
	var objective_rings := 22 + difficulty * 2 + int((seed / 7) % 5)
	var duration := 90
	var reward := {
		"type": "bundle",
		"coins": 420 + difficulty * 120,
		"xp": 180 + difficulty * 70,
		"diamonds": 2 + difficulty,
		"keys": 1 if difficulty >= 4 else 0,
	}
	if difficulty >= 5:
		reward["chest_type"] = "rare"
	var days: Dictionary = daily.get("days", {})
	var day_state: Dictionary = days.get(day_key, {})
	var records: Dictionary = daily.get("records", {})
	var record: Dictionary = records.get(day_key, {})
	return {
		"id": "daily_challenge_%s" % day_key,
		"day_key": day_key,
		"title": "Desafio Diário",
		"title_en": "Daily Challenge",
		"date": day_key,
		"seed": seed,
		"difficulty": difficulty,
		"difficulty_label": _daily_challenge_difficulty_label(difficulty),
		"duration": duration,
		"objective_rings": objective_rings,
		"best_score": int(record.get("score", 0)),
		"best_rings": int(record.get("rings", 0)),
		"best_seconds": int(record.get("seconds", 0)),
		"completed": bool(day_state.get("completed", false)),
		"claimed": bool(day_state.get("claimed", false)),
		"reward": reward,
		"seconds_until_reset": TimeManager.get_seconds_until_next_day(now),
	}


func start_daily_challenge() -> Dictionary:
	var challenge := get_daily_challenge()
	data["selected_mode"] = "daily_challenge"
	data["selected_phase"] = 1
	data["pending_daily_challenge"] = challenge
	save_game()
	return { "ok": true, "text": "Desafio iniciado", "scene": "game" }


func record_daily_challenge_run(summary: Dictionary) -> Dictionary:
	_ensure_daily_challenge_state()
	var challenge := get_daily_challenge()
	var day_key := String(challenge.get("day_key", TimeManager.get_day_key()))
	var completed := bool(summary.get("completed", false))
	var rings_value := int(summary.get("rings", 0))
	var seconds := int(summary.get("seconds", 0))
	var score := int(summary.get("score", 0))
	var perfect_value := int(summary.get("perfects", 0))
	var coins: int = max(25, int(summary.get("coins", 0)) + rings_value * 8 + seconds * 2)
	var xp: int = max(20, int(summary.get("xp", 0)) + rings_value * 4 + seconds)
	data["coins"] = int(data.get("coins", 0)) + coins
	_add_earning_stats(coins, 0, 0, 0)
	add_profile_xp(xp)
	var daily: Dictionary = data.get("daily_challenge", {})
	var records: Dictionary = daily.get("records", {})
	var previous: Dictionary = records.get(day_key, {})
	if score > int(previous.get("score", 0)):
		records[day_key] = { "score": score, "rings": rings_value, "seconds": seconds, "completed": completed }
	daily["records"] = records
	var days: Dictionary = daily.get("days", {})
	var day_state: Dictionary = days.get(day_key, {})
	if completed:
		day_state["completed"] = true
		if not day_state.has("claimed"):
			day_state["claimed"] = false
	days[day_key] = day_state
	daily["days"] = days
	daily["last_result"] = summary.duplicate(true)
	data["daily_challenge"] = daily
	var stats: Dictionary = data.get("stats", {})
	stats["runs_played"] = int(stats.get("runs_played", 0)) + 1
	stats["runsPlayed"] = int(stats.get("runsPlayed", 0)) + 1
	stats["dailyChallengeRuns"] = int(stats.get("dailyChallengeRuns", 0)) + 1
	stats["dailyChallengeCompletions"] = int(stats.get("dailyChallengeCompletions", 0)) + (1 if completed else 0)
	stats["dailyChallengeBestScore"] = max(int(stats.get("dailyChallengeBestScore", 0)), score)
	stats["dailyChallengeBestRings"] = max(int(stats.get("dailyChallengeBestRings", 0)), rings_value)
	stats["totalPlayTimeSeconds"] = int(stats.get("totalPlayTimeSeconds", 0)) + seconds
	stats["rings_destroyed"] = int(stats.get("rings_destroyed", 0)) + rings_value
	stats["ringsDestroyed"] = int(stats.get("ringsDestroyed", 0)) + rings_value
	stats["perfect_escapes"] = int(stats.get("perfect_escapes", 0)) + perfect_value
	stats["perfectEscapes"] = int(stats.get("perfectEscapes", 0)) + perfect_value
	stats["runCoins"] = int(stats.get("runCoins", 0)) + coins
	data["stats"] = stats
	_track_skin_mode_usage("daily_challenge", completed, seconds, rings_value, perfect_value)
	_progress_missions("runsPlayed", 1)
	_progress_missions("dailyChallengeRuns", 1)
	if completed:
		_progress_missions("dailyChallengeCompletions", 1)
	_progress_missions("dailyChallengeBestScore", score)
	_progress_missions("dailyChallengeBestRings", rings_value)
	_progress_missions("ringsDestroyed", rings_value)
	_progress_missions("perfectEscapes", perfect_value)
	_progress_missions("runCoins", coins)
	add_neon_pass_source_xp("daily_challenge")
	var first_win := {}
	if completed:
		first_win = _add_neon_pass_first_win_bonus("daily_challenge")
	_update_achievements(false)
	save_game()
	return { "coins": coins, "xp": xp, "completed": completed, "reward_available": completed and not bool(day_state.get("claimed", false)), "first_win_bonus": first_win }


func claim_daily_challenge_reward(double_reward := false) -> Dictionary:
	var challenge := get_daily_challenge()
	var day_key := String(challenge.get("day_key", TimeManager.get_day_key()))
	var daily: Dictionary = data.get("daily_challenge", {})
	var days: Dictionary = daily.get("days", {})
	var day_state: Dictionary = days.get(day_key, {})
	if not bool(day_state.get("completed", false)):
		return { "ok": false, "reason": "not_ready" }
	if bool(day_state.get("claimed", false)):
		return { "ok": false, "reason": "already_claimed" }
	var reward := Dictionary(challenge.get("reward", {})).duplicate(true)
	var multiplier := 2 if double_reward else 1
	var summary := _apply_daily_challenge_bundle(reward, multiplier)
	day_state["claimed"] = true
	day_state["claimed_at"] = TimeManager.get_now_timestamp()
	day_state["doubled"] = double_reward
	days[day_key] = day_state
	daily["days"] = days
	data["daily_challenge"] = daily
	data["last_reward_text"] = summary
	_update_achievements(false)
	save_game()
	return { "ok": true, "reward": reward, "text": summary, "doubled": double_reward }


func debug_reset_daily_challenge() -> void:
	_ensure_daily_challenge_state()
	var daily: Dictionary = data.get("daily_challenge", {})
	var day_key := TimeManager.get_day_key()
	var days: Dictionary = daily.get("days", {})
	days.erase(day_key)
	daily["days"] = days
	daily["last_result"] = {}
	data["daily_challenge"] = daily
	save_game()


func debug_randomize_daily_challenge_seed() -> void:
	_ensure_daily_challenge_state()
	var daily: Dictionary = data.get("daily_challenge", {})
	daily["seed_override"] = "debug_%s_%s" % [TimeManager.get_day_key(), randi()]
	data["daily_challenge"] = daily
	save_game()


func debug_simulate_next_daily_challenge_day() -> void:
	_ensure_daily_challenge_state()
	var daily: Dictionary = data.get("daily_challenge", {})
	daily["seed_override"] = "debug_next_day_%s" % randi()
	daily["last_result"] = {}
	data["daily_challenge"] = daily
	save_game()


func _weekly_event_state(event_id: String, definition: Dictionary = {}, starts_at := 0, ends_at := 0) -> Dictionary:
	var events: Dictionary = data.get("events", {})
	var state: Dictionary = events.get(event_id, {})
	if state.is_empty():
		state = { "claimed": [], "started_at": TimeManager.get_now_timestamp(), "progress": {}, "baseline": {} }
	var baseline: Dictionary = state.get("baseline", {})
	for raw_task in Array(definition.get("tasks", [])):
		var task: Dictionary = raw_task
		var metric := String(task.get("metric", ""))
		if metric.is_empty():
			continue
		if not baseline.has(metric):
			baseline[metric] = _event_metric_value(metric)
	state["baseline"] = baseline
	state["starts_at"] = starts_at
	state["ends_at"] = ends_at
	state["definition_id"] = String(definition.get("id", event_id))
	events[event_id] = state
	data["events"] = events
	return state


func _ensure_daily_challenge_state() -> void:
	var daily: Dictionary = data.get("daily_challenge", {})
	if daily.is_empty():
		daily = { "day_key": "", "seed_override": "", "records": {}, "days": {}, "last_result": {} }
	if not daily.has("seed_override"):
		daily["seed_override"] = ""
	if not daily.has("records"):
		daily["records"] = {}
	if not daily.has("days"):
		daily["days"] = {}
	if not daily.has("last_result"):
		daily["last_result"] = {}
	daily["day_key"] = TimeManager.get_day_key()
	data["daily_challenge"] = daily


func _daily_challenge_difficulty_label(difficulty: int) -> String:
	match clampi(difficulty, 1, 5):
		1:
			return "Fácil"
		2:
			return "Normal"
		3:
			return "Médio"
		4:
			return "Difícil"
	return "Elite"


func _stable_daily_seed(text: String) -> int:
	var value := 2166136261
	for i in range(text.length()):
		value = int((value ^ text.unicode_at(i)) * 16777619) & 0x7fffffff
	return max(1, value)


func _apply_daily_challenge_bundle(reward: Dictionary, multiplier: int) -> String:
	var coins := int(reward.get("coins", 0)) * multiplier
	var xp := int(reward.get("xp", 0)) * multiplier
	var diamonds := int(reward.get("diamonds", 0)) * multiplier
	var keys := int(reward.get("keys", 0)) * multiplier
	var parts: Array[String] = []
	if coins > 0:
		data["coins"] = int(data.get("coins", 0)) + coins
		_add_earning_stats(coins, 0, 0, 0)
		parts.append("+%s moedas" % coins)
	if xp > 0:
		add_profile_xp(xp)
		parts.append("+%s XP" % xp)
	if diamonds > 0:
		data["diamonds"] = int(data.get("diamonds", 0)) + diamonds
		_increment_stat("diamondsFound", diamonds, false)
		_increment_stat("diamonds_found", diamonds, false)
		_add_earning_stats(0, 0, diamonds, 0)
		parts.append("+%s diamantes" % diamonds)
	if keys > 0:
		data["keys"] = int(data.get("keys", 0)) + keys
		_add_earning_stats(0, 0, 0, keys)
		parts.append("+%s chaves" % keys)
	if reward.has("chest_type"):
		var chest_type := String(reward.get("chest_type", "rare"))
		add_inventory_item("chest_%s" % chest_type, "chest", "Chest %s" % chest_type.capitalize(), chest_type, multiplier)
		parts.append("+%s baú %s" % [multiplier, chest_type])
	return "Recompensa diária: %s" % ", ".join(parts)


func _event_metric_value(metric: String) -> int:
	var stats: Dictionary = data.get("stats", {})
	match metric:
		"phaseWins":
			return int(stats.get("phaseWins", 0))
		"bestInfiniteSeconds":
			return int(stats.get("bestInfiniteSeconds", data.get("infinite_best_seconds", 0)))
		"leagueWins":
			return int(stats.get("leagueWins", 0))
		"coins":
			return int(data.get("coins", 0))
		"diamonds":
			return int(data.get("diamonds", 0))
		"keys":
			return int(data.get("keys", 0))
	return int(stats.get(metric, 0))


func _progress_weekly_event_metric(metric: String, amount: int) -> void:
	var event := get_weekly_event()
	var event_id := String(event.get("id", ""))
	if event_id.is_empty() or not (String(event.get("status", "")) in ["active", "completed"]):
		return
	var events: Dictionary = data.get("events", {})
	var state: Dictionary = events.get(event_id, {})
	if state.is_empty():
		return
	var matches_event := false
	for raw_task in Array(event.get("tasks", [])):
		var task: Dictionary = raw_task
		if String(task.get("metric", "")) == metric:
			matches_event = true
			break
	if not matches_event:
		return
	var progress: Dictionary = state.get("progress", {})
	if metric in ["bestCombo", "bestInfiniteSeconds", "bestInfiniteRings", "dailyChallengeBestScore", "dailyChallengeBestRings", "leagueWinStreak"]:
		progress[metric] = max(int(progress.get(metric, 0)), amount)
	else:
		progress[metric] = int(progress.get(metric, 0)) + amount
	state["progress"] = progress
	events[event_id] = state
	data["events"] = events


func can_start_boss_level(level_id: String) -> bool:
	_ensure_boss_state()
	var boss: Dictionary = data.get("boss", {})
	var attempts: Dictionary = boss.get("daily_attempts", {})
	var day_attempts: Dictionary = attempts.get(_day_key(), {})
	return not bool(day_attempts.get(level_id, false))


func start_boss_battle(level_id: String) -> Dictionary:
	_ensure_boss_state()
	var definition := boss_level_definition(level_id)
	if definition.is_empty():
		return { "ok": false, "reason": "missing" }
	if not can_start_boss_level(level_id):
		return { "ok": false, "reason": "used" }
	var boss: Dictionary = data.get("boss", {})
	var attempts: Dictionary = boss.get("daily_attempts", {})
	var day_attempts: Dictionary = attempts.get(_day_key(), {})
	day_attempts[level_id] = true
	attempts[_day_key()] = day_attempts
	boss["daily_attempts"] = attempts
	boss["last_attempt_at"] = TimeManager.get_now_timestamp()
	data["boss"] = boss
	data["pending_boss_battle"] = {
		"id": "boss_%s_%s" % [TimeManager.get_month_key(), level_id],
		"level_id": level_id,
		"name": String(_current_boss_definition().get("name", "Boss Neon")),
		"skin": String(_current_boss_definition().get("skin", "neon_phoenix")),
		"quality": float(definition.get("quality", 0.55)),
		"reward": Dictionary(definition.get("reward", {})).duplicate(true),
	}
	save_game()
	return { "ok": true, "text": "Boss iniciado", "scene": "battle" }


func record_boss_match(level_id: String, result: String, summary: Dictionary) -> Dictionary:
	_ensure_boss_state()
	var definition := boss_level_definition(level_id)
	var reward: Dictionary = Dictionary(definition.get("reward", { "type": "coins", "amount": 80 })).duplicate(true)
	if result != "win":
		reward = { "type": "coins", "amount": max(25, floori(float(int(reward.get("amount", 100))) * 0.35)) }
	var boss_phase_reward := LevelData.get_phase_config(_boss_equivalent_phase(level_id))
	var boss_outcome_multiplier := 1.0 if result == "win" else 0.35
	var coins_bonus: int = int(summary.get("coins", 0)) + floori(float(int(boss_phase_reward.get("reward_coins", 120))) * boss_outcome_multiplier)
	var run_upgrade_levels: Dictionary = summary.get("run_upgrade_levels", {})
	var xp_bonus: int = maxi(30, int(summary.get("xp", 0)) + floori(float(int(boss_phase_reward.get("reward_xp", 90))) * boss_outcome_multiplier) + int(run_upgrade_levels.get("bossHunter", 0)) * 6)
	if String(reward.get("type", "")) == "coins":
		reward["amount"] = floori(float(int(boss_phase_reward.get("reward_coins", 120))) * boss_outcome_multiplier)
	var diamonds_bonus := 0
	if coins_bonus > 0:
		data["coins"] = int(data.get("coins", 0)) + coins_bonus
		_add_earning_stats(coins_bonus, xp_bonus, 0, 0)
	if String(reward.get("type", "")) != "coins":
		apply_reward(reward)
	if result == "win":
		diamonds_bonus = int(definition.get("diamonds", 0))
		if diamonds_bonus > 0:
			data["diamonds"] = int(data.get("diamonds", 0)) + diamonds_bonus
			_increment_stat("diamondsFound", diamonds_bonus, false)
			_increment_stat("diamonds_found", diamonds_bonus, false)
			_add_earning_stats(0, 0, diamonds_bonus, 0)
	add_profile_xp(xp_bonus)
	add_neon_pass_source_xp("boss_attempt")
	var first_win := {}
	if result == "win":
		add_neon_pass_source_xp("boss_win")
		first_win = _add_neon_pass_first_win_bonus("boss_win")
	var stats: Dictionary = data.get("stats", {})
	stats["boss_runs"] = int(stats.get("boss_runs", 0)) + 1
	stats["boss_wins"] = int(stats.get("boss_wins", 0)) + (1 if result == "win" else 0)
	stats["boss_losses"] = int(stats.get("boss_losses", 0)) + (1 if result == "loss" else 0)
	stats["bossRuns"] = int(stats.get("bossRuns", 0)) + 1
	stats["bossWins"] = int(stats.get("bossWins", 0)) + (1 if result == "win" else 0)
	stats["bossLosses"] = int(stats.get("bossLosses", 0)) + (1 if result == "loss" else 0)
	if result == "win":
		var difficulty_metric := "boss%sWins" % level_id.capitalize()
		stats[difficulty_metric] = int(stats.get(difficulty_metric, 0)) + 1
		stats["bossBestLevelIndex"] = max(int(stats.get("bossBestLevelIndex", 0)), _boss_level_index(level_id) + 1)
	stats["ringsDestroyed"] = int(stats.get("ringsDestroyed", 0)) + int(summary.get("rings", 0))
	stats["rings_destroyed"] = int(stats.get("rings_destroyed", 0)) + int(summary.get("rings", 0))
	stats["perfectEscapes"] = int(stats.get("perfectEscapes", 0)) + int(summary.get("perfects", 0))
	stats["perfect_escapes"] = int(stats.get("perfect_escapes", 0)) + int(summary.get("perfects", 0))
	stats["runCoins"] = int(stats.get("runCoins", 0)) + coins_bonus
	stats["runUpgrades"] = int(stats.get("runUpgrades", 0)) + int(summary.get("run_upgrades", 0))
	stats["diamondsFound"] = int(stats.get("diamondsFound", 0)) + diamonds_bonus
	stats["diamonds_found"] = int(stats.get("diamonds_found", 0)) + diamonds_bonus
	stats["totalPlayTimeSeconds"] = int(stats.get("totalPlayTimeSeconds", 0)) + int(summary.get("seconds", 0))
	var boss_damage: int = max(max(int(summary.get("damage", 0)), int(summary.get("score", 0))), int(summary.get("rings", 0)) * int(definition.get("base_hp", 100)))
	stats["bossDamageTotal"] = int(stats.get("bossDamageTotal", 0)) + max(0, boss_damage)
	if result == "win":
		var boss_seconds := int(summary.get("seconds", 0))
		if boss_seconds > 0:
			var previous_best := int(stats.get("bossBestTime", 0))
			stats["bossBestTime"] = boss_seconds if previous_best <= 0 else min(previous_best, boss_seconds)
	data["stats"] = stats
	_track_skin_mode_usage("boss", result == "win", int(summary.get("seconds", 0)), int(summary.get("rings", 0)), int(summary.get("perfects", 0)))
	_progress_missions("bossMatches", 1)
	if result == "win":
		_progress_missions("bossWins", 1)
	_progress_missions("ringsDestroyed", int(summary.get("rings", 0)))
	_progress_missions("perfectEscapes", int(summary.get("perfects", 0)))
	_progress_missions("runCoins", coins_bonus)
	_update_achievements(false)
	save_game()
	return {
		"coins": coins_bonus,
		"xp": xp_bonus,
		"diamonds": diamonds_bonus,
		"reward": reward,
		"boss_level": level_id,
		"first_win_bonus": first_win,
	}


func _boss_level_index(level_id: String) -> int:
	var levels := boss_level_definitions()
	for i in range(levels.size()):
		if String(Dictionary(levels[i]).get("id", "")) == level_id:
			return i
	return 0


func _boss_equivalent_phase(level_id: String) -> int:
	match level_id:
		"strong":
			return 25
		"elite":
			return 45
		"legendary":
			return 70
		"impossible":
			return 95
		_:
			return 12


func boss_level_definition(level_id: String) -> Dictionary:
	for definition in boss_level_definitions():
		if String(definition.get("id", "")) == level_id:
			return definition
	return {}


func boss_level_definitions() -> Array[Dictionary]:
	return [
		{ "id": "normal", "title": "Normal", "quality": 0.45, "xp": 160, "diamonds": 2, "reward": { "type": "coins", "amount": 520 } },
		{ "id": "strong", "title": "Forte", "quality": 0.58, "xp": 240, "diamonds": 8, "reward": { "type": "diamonds", "amount": 10 } },
		{ "id": "elite", "title": "Elite", "quality": 0.72, "xp": 340, "diamonds": 12, "reward": { "type": "keys", "amount": 1 } },
		{ "id": "legendary", "title": "Lendário", "quality": 0.86, "xp": 480, "diamonds": 18, "reward": { "type": "chest", "chest_type": "rare", "amount": 1 } },
		{ "id": "impossible", "title": "Impossível", "quality": 1.0, "xp": 680, "diamonds": 28, "reward": { "type": "chest", "chest_type": "epic", "amount": 1 } },
	]


func _ensure_boss_state() -> void:
	var boss: Dictionary = data.get("boss", {})
	if not boss.has("daily_attempts"):
		boss["daily_attempts"] = {}
	data["boss"] = boss


func _current_boss_definition() -> Dictionary:
	var month := int(Time.get_datetime_dict_from_system().get("month", 6))
	match month:
		6:
			return { "name": "Fênix Solar", "skin": "neon_phoenix" }
		7:
			return { "name": "Dragão Astral", "skin": "astral_dragon" }
		8:
			return { "name": "Guardião Dimensional", "skin": "dimensional_guardian" }
	return { "name": "Fênix Solar", "skin": "neon_phoenix" }


func get_daily_mission_def(id: String) -> Dictionary:
	for definition in DAILY_MISSION_DEFS:
		if String(definition["id"]) == id:
			return definition
	return {}


func claim_daily_mission(id: String) -> Dictionary:
	_ensure_live_systems()
	var daily: Dictionary = data.get("daily_missions", {})
	var missions: Array = daily.get("missions", [])
	for i in range(missions.size()):
		var mission: Dictionary = missions[i]
		if String(mission.get("id", "")) != id:
			continue
		var definition := get_daily_mission_def(id)
		if definition.is_empty() or bool(mission.get("claimed", false)) or int(mission.get("progress", 0)) < int(definition["target"]):
			return { "ok": false, "reason": "not_ready" }
		var text := apply_reward(definition["reward"])
		mission["claimed"] = true
		missions[i] = mission
		daily["missions"] = missions
		data["daily_missions"] = daily
		data["last_reward_text"] = text
		save_game()
		return { "ok": true, "reward": definition["reward"], "text": text }
	return { "ok": false, "reason": "missing" }


func claim_achievement(id: String) -> Dictionary:
	_update_achievements(false)
	var achievements: Dictionary = data.get("achievements", {})
	if not achievements.has(id):
		return { "ok": false, "reason": "missing" }
	var state: Dictionary = achievements[id]
	if not bool(state.get("completed", false)) or bool(state.get("claimed", false)):
		return { "ok": false, "reason": "not_ready" }
	var definition := _achievement_def(id)
	var text := apply_reward(definition.get("reward", {}))
	state["claimed"] = true
	achievements[id] = state
	data["achievements"] = achievements
	data["last_reward_text"] = text
	save_game()
	return { "ok": true, "reward": definition.get("reward", {}), "text": text }


func claim_all_achievements() -> Dictionary:
	_update_achievements(false)
	var achievements: Dictionary = data.get("achievements", {})
	var claimed_count := 0
	var reward_summary := {
		"coins": 0,
		"diamonds": 0,
		"keys": 0,
		"legendary_keys": 0,
		"xp": 0,
		"chests": 0,
		"skins": 0,
		"upgrades": 0,
	}
	for achievement in get_achievements():
		var id := String(achievement.get("id", ""))
		var state: Dictionary = achievements.get(id, {})
		if id.is_empty() or not bool(state.get("completed", false)) or bool(state.get("claimed", false)):
			continue
		var reward: Dictionary = achievement.get("reward", {})
		_accumulate_reward_summary(reward_summary, reward)
		apply_reward(reward, false)
		state["claimed"] = true
		achievements[id] = state
		claimed_count += 1
	if claimed_count <= 0:
		return { "ok": false, "reason": "not_ready" }
	data["achievements"] = achievements
	var text := _reward_summary_text(reward_summary, claimed_count)
	data["last_reward_text"] = text
	save_game()
	return {
		"ok": true,
		"reward": reward_summary,
		"text": text,
		"claimed": claimed_count,
	}


func _accumulate_reward_summary(summary: Dictionary, reward: Dictionary) -> void:
	var amount := int(reward.get("amount", 1))
	match String(reward.get("type", "")):
		"coins":
			summary["coins"] = int(summary.get("coins", 0)) + amount
		"diamonds", "gems":
			summary["diamonds"] = int(summary.get("diamonds", 0)) + amount
		"keys":
			summary["keys"] = int(summary.get("keys", 0)) + amount
		"legendaryKeys":
			summary["legendary_keys"] = int(summary.get("legendary_keys", 0)) + amount
		"xp":
			summary["xp"] = int(summary.get("xp", 0)) + amount
		"chest":
			summary["chests"] = int(summary.get("chests", 0)) + amount
		"skin":
			summary["skins"] = int(summary.get("skins", 0)) + 1
		"upgrade", "run_upgrade", "upgrade_unlock":
			summary["upgrades"] = int(summary.get("upgrades", 0)) + 1


func _reward_summary_text(summary: Dictionary, claimed_count: int) -> String:
	var parts: Array[String] = ["%s conquistas" % claimed_count]
	if int(summary.get("coins", 0)) > 0:
		parts.append("+%s moedas" % int(summary.get("coins", 0)))
	if int(summary.get("diamonds", 0)) > 0:
		parts.append("+%s diamantes" % int(summary.get("diamonds", 0)))
	if int(summary.get("keys", 0)) > 0:
		parts.append("+%s chaves" % int(summary.get("keys", 0)))
	if int(summary.get("legendary_keys", 0)) > 0:
		parts.append("+%s chaves lendarias" % int(summary.get("legendary_keys", 0)))
	if int(summary.get("xp", 0)) > 0:
		parts.append("+%s XP" % int(summary.get("xp", 0)))
	if int(summary.get("chests", 0)) > 0:
		parts.append("+%s baus" % int(summary.get("chests", 0)))
	if int(summary.get("skins", 0)) > 0:
		parts.append("+%s skins" % int(summary.get("skins", 0)))
	if int(summary.get("upgrades", 0)) > 0:
		parts.append("+%s upgrades" % int(summary.get("upgrades", 0)))
	return "Coletado: %s" % ", ".join(parts)


func _achievement_def(id: String) -> Dictionary:
	for achievement in get_achievements():
		if String(achievement["id"]) == id:
			return achievement
	return {}


func _update_skin_collection_stats() -> void:
	var stats: Dictionary = data.get("stats", {})
	var rarity_counts := {}
	for rarity in SKIN_RARITY_ORDER:
		rarity_counts[rarity] = 0
	var effect_counts := {
		"control": 0,
		"fire": 0,
		"ice": 0,
		"critical": 0,
		"coins": 0,
		"xp": 0,
		"speed": 0,
		"chain": 0,
		"area": 0,
		"phase": 0,
		"gravity": 0,
	}
	var skin_levels: Dictionary = data.get("skin_levels", {})
	var upgraded_count := 0
	var any_level_2 := 0
	var maxed_count := 0
	var maxed_by_rarity := {}
	for rarity in SKIN_RARITY_ORDER:
		maxed_by_rarity[rarity] = 0
	for skin_id in Array(data.get("unlocked_skins", [])):
		var id := String(skin_id)
		var rarity := _skin_rarity_from_id(id)
		rarity_counts[rarity] = int(rarity_counts.get(rarity, 0)) + 1
		for effect_id in _skin_effect_ids_from_id(id):
			if effect_counts.has(effect_id):
				effect_counts[effect_id] = int(effect_counts.get(effect_id, 0)) + 1
		var level := int(skin_levels.get(id, 1))
		if level >= 2:
			any_level_2 = 1
			upgraded_count += 1
		if level >= get_skin_max_level(id):
			maxed_count += 1
			maxed_by_rarity[rarity] = int(maxed_by_rarity.get(rarity, 0)) + 1
	var unlocked_count := Array(data.get("unlocked_skins", [])).size()
	stats["totalSkinsAvailable"] = _skin_total_available()
	stats["skinsUnlocked"] = unlocked_count
	stats["skins_unlocked"] = unlocked_count
	for rarity in SKIN_RARITY_ORDER:
		stats["%sSkinsUnlocked" % rarity] = int(rarity_counts.get(rarity, 0))
		stats["skin%sMaxed" % rarity.capitalize()] = int(maxed_by_rarity.get(rarity, 0))
	stats["legendaryPlusSkinsUnlocked"] = int(rarity_counts.get("legendary", 0)) + int(rarity_counts.get("mythic", 0)) + int(rarity_counts.get("ultimate", 0))
	stats["skinEffectControlUnlocked"] = int(effect_counts.get("control", 0))
	stats["skinEffectFireUnlocked"] = int(effect_counts.get("fire", 0))
	stats["skinEffectIceUnlocked"] = int(effect_counts.get("ice", 0))
	stats["skinEffectCriticalUnlocked"] = int(effect_counts.get("critical", 0))
	stats["skinEffectCoinsUnlocked"] = int(effect_counts.get("coins", 0))
	stats["skinEffectXPUnlocked"] = int(effect_counts.get("xp", 0))
	stats["skinEffectSpeedUnlocked"] = int(effect_counts.get("speed", 0))
	stats["skinEffectChainUnlocked"] = int(effect_counts.get("chain", 0))
	stats["skinEffectAreaUnlocked"] = int(effect_counts.get("area", 0))
	stats["skinEffectPhaseUnlocked"] = int(effect_counts.get("phase", 0))
	stats["skinEffectGravityUnlocked"] = int(effect_counts.get("gravity", 0))
	stats["skinAnyLevel2"] = any_level_2
	stats["skinsUpgradedCount"] = upgraded_count
	stats["skinMaxedCount"] = maxed_count
	data["stats"] = stats


func _skin_rarity_from_id(id: String) -> String:
	var skin := MainPortData.skin_by_id(id)
	if not skin.is_empty():
		var rarity := String(skin.get("rarity", "common")).to_lower()
		if SKIN_RARITY_ORDER.has(rarity):
			return rarity
	if id.contains("ultimate") or id in ["omega_infinity", "singularity_crown", "divine_core", "cosmic_champion", "league_king_neon", "initial_neon_champion"]:
		return "ultimate"
	if id.contains("mythic") or id.contains("chrono_loop"):
		return "mythic"
	if id.contains("legendary") or id.contains("king") or id.contains("emperor") or id.contains("guardian") or id.contains("phoenix") or id.contains("dragon") or id.contains("singularity") or id.contains("devourer") or id.contains("crown") or id.contains("champion"):
		return "legendary"
	if id.contains("epic") or id.contains("core") or id.contains("eye") or id.contains("orb") or id.contains("plasma") or id.contains("spiral") or id.contains("eclipse") or id.contains("prism"):
		return "epic"
	if id.contains("rare") or id.contains("comet") or id.contains("crystal") or id.contains("meteor") or id.contains("wizard") or id.contains("ninja") or id.contains("flame"):
		return "rare"
	return "common"


func _skin_total_available() -> int:
	return _all_known_skin_ids().size()


func _skin_rarity_total(rarity: String) -> int:
	var count := 0
	for skin_id in _all_known_skin_ids():
		if _skin_rarity_from_id(String(skin_id)) == rarity:
			count += 1
	return count


func _skin_effect_total(effect_id: String) -> int:
	var count := 0
	for skin_id in _all_known_skin_ids():
		if _skin_effect_ids_from_id(String(skin_id)).has(effect_id):
			count += 1
	return count


func _skin_effect_ids_from_id(id: String) -> Array:
	var effects: Array = []
	var tokens: Array = [id]
	var skin := MainPortData.skin_by_id(id)
	if not skin.is_empty():
		tokens.append(String(skin.get("name", "")))
		tokens.append(String(skin.get("name_pt", "")))
		tokens.append(String(skin.get("name_en", "")))
		tokens.append(String(skin.get("desc", "")))
		tokens.append(String(skin.get("desc_pt", "")))
		tokens.append(String(skin.get("desc_en", "")))
		var passive: Dictionary = Dictionary(skin.get("passive", {}))
		tokens.append(String(passive.get("type", "")))
		for raw_effect in Array(skin.get("effects", [])):
			tokens.append(String(raw_effect))
	if MainPortData.skin_has_control(id):
		_append_unique_string(effects, "control")
	var text := " ".join(tokens).to_lower()
	if text.contains("control") or text.contains("controle"):
		_append_unique_string(effects, "control")
	if text.contains("burn") or text.contains("fire") or text.contains("flame") or text.contains("fogo") or text.contains("phoenix") or text.contains("dragon") or text.contains("solar"):
		_append_unique_string(effects, "fire")
	if text.contains("freeze") or text.contains("slow_ring") or text.contains("slow ring") or text.contains("ice") or text.contains("frost") or text.contains("gelo") or text.contains("chill"):
		_append_unique_string(effects, "ice")
	if text.contains("crit") or text.contains("critical") or text.contains("mega_crit") or text.contains("cosmic_critical") or text.contains("critico"):
		_append_unique_string(effects, "critical")
	if text.contains("coin") or text.contains("moeda") or text.contains("gold") or text.contains("piggy") or text.contains("emperor"):
		_append_unique_string(effects, "coins")
	if text.contains("xp") or text.contains("experience") or text.contains("experiencia"):
		_append_unique_string(effects, "xp")
	if text.contains("speed") or text.contains("veloc") or text.contains("comet") or text.contains("dash"):
		_append_unique_string(effects, "speed")
	if text.contains("chain") or text.contains("corrente") or text.contains("lightning") or text.contains("electric") or text.contains("plasma") or text.contains("orbital_blade"):
		_append_unique_string(effects, "chain")
	if text.contains("area_damage") or text.contains("area") or text.contains("shockwave") or text.contains("explos") or text.contains("all_bonus") or text.contains("league_king_wave"):
		_append_unique_string(effects, "area")
	if text.contains("phase_solid") or text.contains("phase") or text.contains("fase") or text.contains("ghost") or text.contains("phantom") or text.contains("void"):
		_append_unique_string(effects, "phase")
	if text.contains("gravity") or text.contains("gravidade") or text.contains("black_hole") or text.contains("singularity") or text.contains("collapsed") or text.contains("black sun") or text.contains("void"):
		_append_unique_string(effects, "gravity")
	return effects


func _append_unique_string(values: Array, value: String) -> void:
	if not values.has(value):
		values.append(value)


func _rarity_label(rarity: String) -> String:
	match rarity:
		"common":
			return "Common"
		"rare":
			return "Rare"
		"epic":
			return "Epic"
		"legendary":
			return "Legendary"
		"mythic":
			return "Mythic"
		"ultimate":
			return "Ultimate"
	return rarity.capitalize()


func _rarity_label_pt(rarity: String) -> String:
	match rarity:
		"common":
			return "Comuns"
		"rare":
			return "Raras"
		"epic":
			return "Epicas"
		"legendary":
			return "Lendarias"
		"mythic":
			return "Miticas"
		"ultimate":
			return "Ultimate"
	return rarity.capitalize()


func _skin_collection_reward(target: int) -> Dictionary:
	if target >= 100:
		return { "type": "skin", "skin_id": "genesis_core" }
	if target >= 75:
		return { "type": "chest", "chest_type": "epic", "amount": 1 }
	if target >= 50:
		return { "type": "diamonds", "amount": 120 }
	if target >= 25:
		return { "type": "keys", "amount": 3 }
	if target >= 10:
		return { "type": "diamonds", "amount": 30 }
	return { "type": "coins", "amount": 900 }


func _skin_rarity_reward(rarity: String, target: int) -> Dictionary:
	match rarity:
		"common":
			return { "type": "coins", "amount": 700 + target * 60 }
		"rare":
			return { "type": "diamonds", "amount": 18 + target }
		"epic":
			return { "type": "keys", "amount": 1 + (1 if target >= 15 else 0) }
		"legendary":
			return { "type": "chest", "chest_type": "rare", "amount": 1 }
		"mythic":
			return { "type": "diamonds", "amount": 80 + target * 8 }
		"ultimate":
			return { "type": "chest", "chest_type": "epic", "amount": 1 }
	return { "type": "coins", "amount": 1000 }


func _skin_rarity_all_reward(rarity: String) -> Dictionary:
	match rarity:
		"common":
			return { "type": "chest", "chest_type": "common", "amount": 2 }
		"rare":
			return { "type": "chest", "chest_type": "rare", "amount": 1 }
		"epic":
			return { "type": "diamonds", "amount": 160 }
		"legendary":
			return { "type": "chest", "chest_type": "epic", "amount": 1 }
		"mythic":
			return { "type": "skin", "skin_id": "genesis_core" }
		"ultimate":
			return { "type": "skin", "skin_id": "prismatic_omega" }
	return { "type": "coins", "amount": 1200 }


func _update_achievements(save_after := true) -> void:
	var achievements: Dictionary = data.get("achievements", {})
	var stats: Dictionary = data.get("stats", {})
	stats["skinsUnlocked"] = Array(data.get("unlocked_skins", [])).size()
	_update_skin_collection_stats()
	_ensure_profile_stats_state()
	stats = data.get("stats", {})
	stats["highestPhase"] = max(int(stats.get("highestPhase", 1)), int(data.get("max_unlocked_phase", 1)))
	stats["runsPlayed"] = max(int(stats.get("runsPlayed", 0)), int(stats.get("runs_played", 0)))
	stats["ringsDestroyed"] = max(int(stats.get("ringsDestroyed", 0)), int(stats.get("rings_destroyed", 0)))
	stats["perfectEscapes"] = max(int(stats.get("perfectEscapes", 0)), int(stats.get("perfect_escapes", 0)))
	stats["diamondsFound"] = max(int(stats.get("diamondsFound", 0)), int(stats.get("diamonds_found", 0)))
	stats["infiniteRuns"] = max(int(stats.get("infiniteRuns", 0)), int(stats.get("infinite_runs", 0)))
	stats["bestInfiniteSeconds"] = max(int(stats.get("bestInfiniteSeconds", 0)), int(stats.get("best_infinite_seconds", 0)))
	stats["bestInfiniteRings"] = max(int(stats.get("bestInfiniteRings", 0)), int(stats.get("best_infinite_rings", 0)))
	stats["bestInfiniteScore"] = max(int(stats.get("bestInfiniteScore", 0)), int(stats.get("best_infinite_score", 0)))
	stats["bossRuns"] = max(int(stats.get("bossRuns", 0)), int(stats.get("boss_runs", 0)))
	stats["bossWins"] = max(int(stats.get("bossWins", 0)), int(stats.get("boss_wins", 0)))
	stats["bossLosses"] = max(int(stats.get("bossLosses", 0)), int(stats.get("boss_losses", 0)))
	var league: Dictionary = data.get("league", {})
	var highest_rank_id := String(league.get("highest_rank_id", "bronze"))
	var rank_index := _league_rank_index(highest_rank_id)
	stats["leagueRankIndex"] = max(int(stats.get("leagueRankIndex", 0)), rank_index)
	stats["leagueSilverReached"] = max(int(stats.get("leagueSilverReached", 0)), 1 if rank_index >= _league_rank_index("silver") else 0)
	stats["leagueGoldReached"] = max(int(stats.get("leagueGoldReached", 0)), 1 if rank_index >= _league_rank_index("gold") else 0)
	stats["leagueDiamondReached"] = max(int(stats.get("leagueDiamondReached", 0)), 1 if rank_index >= _league_rank_index("diamond") else 0)
	stats["leagueLegendaryReached"] = max(int(stats.get("leagueLegendaryReached", 0)), 1 if rank_index >= _league_rank_index("legendary") else 0)
	stats["leagueUltimateReached"] = max(int(stats.get("leagueUltimateReached", 0)), 1 if rank_index >= _league_rank_index("ultimate") else 0)
	for achievement in get_achievements():
		var id := String(achievement["id"])
		var state: Dictionary = achievements.get(id, { "progress": 0, "completed": false, "claimed": false })
		var progress := int(stats.get(String(achievement["metric"]), 0))
		state["progress"] = min(progress, int(achievement["required"]))
		if progress >= int(achievement["required"]):
			state["completed"] = true
		achievements[id] = state
	data["stats"] = stats
	data["achievements"] = achievements
	if save_after:
		save_game()


func _progress_missions(metric: String, amount: int) -> void:
	if amount <= 0:
		return
	_ensure_live_systems()
	_progress_weekly_event_metric(metric, amount)
	var daily: Dictionary = data.get("daily_missions", {})
	var missions: Array = daily.get("missions", [])
	for i in range(missions.size()):
		var mission: Dictionary = missions[i]
		if bool(mission.get("claimed", false)):
			continue
		var definition := get_daily_mission_def(String(mission.get("id", "")))
		if definition.is_empty() or String(definition.get("metric", "")) != metric:
			continue
		var next_progress: int = max(int(mission.get("progress", 0)), amount) if metric == "bestCombo" else int(mission.get("progress", 0)) + amount
		mission["progress"] = min(int(definition["target"]), next_progress)
		missions[i] = mission
	daily["missions"] = missions
	data["daily_missions"] = daily


func _increment_stat(metric: String, amount: int, save_after := true) -> void:
	var stats: Dictionary = data.get("stats", {})
	stats[metric] = int(stats.get(metric, 0)) + amount
	data["stats"] = stats
	if save_after:
		save_game()


func _add_earning_stats(coins := 0, xp := 0, diamonds := 0, keys := 0) -> void:
	var stats: Dictionary = data.get("stats", {})
	if coins > 0:
		stats["totalCoinsEarned"] = int(stats.get("totalCoinsEarned", 0)) + coins
	if xp > 0:
		stats["totalXpEarned"] = int(stats.get("totalXpEarned", 0)) + xp
	if diamonds > 0:
		stats["totalDiamondsEarned"] = int(stats.get("totalDiamondsEarned", 0)) + diamonds
	if keys > 0:
		stats["totalKeysEarned"] = int(stats.get("totalKeysEarned", 0)) + keys
	data["stats"] = stats


func add_coins(amount: int) -> void:
	if amount > 0:
		_add_earning_stats(amount, 0, 0, 0)
	data["coins"] = max(0, int(data.get("coins", 0)) + amount)
	save_game()


func spend_coins(amount: int) -> bool:
	if int(data.get("coins", 0)) < amount:
		return false
	add_coins(-amount)
	return true


func add_diamonds(amount: int) -> void:
	if amount > 0:
		_add_earning_stats(0, 0, amount, 0)
	data["diamonds"] = max(0, int(data.get("diamonds", 0)) + amount)
	save_game()


func spend_diamonds(amount: int) -> bool:
	if int(data.get("diamonds", 0)) < amount:
		return false
	add_diamonds(-amount)
	return true


func add_keys(amount: int) -> void:
	if amount > 0:
		_add_earning_stats(0, 0, 0, amount)
	data["keys"] = max(0, int(data.get("keys", 0)) + amount)
	save_game()


func spend_keys(amount: int) -> bool:
	if int(data.get("keys", 0)) < amount:
		return false
	add_keys(-amount)
	return true


func unlock_skin(id: String) -> void:
	if id.is_empty():
		return
	var skins: Array = data.get("unlocked_skins", [])
	if not skins.has(id):
		skins.append(id)
		var new_skins: Array = data.get("new_skins", [])
		if not new_skins.has(id):
			new_skins.append(id)
		data["new_skins"] = new_skins
	var skin_levels: Dictionary = data.get("skin_levels", {})
	skin_levels[id] = clampi(int(skin_levels.get(id, 1)), 1, get_skin_max_level(id))
	data["skin_levels"] = skin_levels
	data["unlocked_skins"] = skins
	data["stats"]["skins_unlocked"] = skins.size()
	data["stats"]["skinsUnlocked"] = skins.size()
	_update_skin_collection_stats()
	_update_achievements(false)
	save_game()


func equip_skin(id: String) -> bool:
	if not Array(data.get("unlocked_skins", [])).has(id):
		return false
	data["equipped_skin"] = id
	_increment_stat("skinEquips", 1, false)
	_progress_missions("skinEquips", 1)
	_update_achievements(false)
	save_game()
	return true


func is_new_skin(id: String) -> bool:
	return Array(data.get("new_skins", [])).has(id)


func mark_skin_seen(id: String) -> void:
	var new_skins: Array = data.get("new_skins", [])
	if new_skins.has(id):
		new_skins.erase(id)
		data["new_skins"] = new_skins
		save_game()


func clear_new_skins() -> void:
	data["new_skins"] = []
	save_game()


func get_skin_level(id: String) -> int:
	migrate_save_to_skin_levels()
	return clampi(int(Dictionary(data.get("skin_levels", {})).get(id, 1)), 1, get_skin_max_level(id))


func get_skin_max_level(id: String) -> int:
	var rarity := _skin_rarity_from_id(id)
	return int(SKIN_MAX_LEVEL_BY_RARITY.get(rarity, 5))


func is_skin_max_level(id: String) -> bool:
	return get_skin_level(id) >= get_skin_max_level(id)


func get_skin_upgrade_cost(rarity: String, current_level: int, currency: String) -> int:
	var normalized_rarity := rarity if SKIN_UPGRADE_BASE_COSTS.has(rarity) else "common"
	var normalized_currency := "diamonds" if currency == "diamonds" else "coins"
	var base: Dictionary = SKIN_UPGRADE_BASE_COSTS.get(normalized_rarity, SKIN_UPGRADE_BASE_COSTS["common"])
	var growth := float(SKIN_UPGRADE_GROWTH.get(normalized_rarity, 1.75))
	var raw := float(base.get(normalized_currency, 100)) * pow(growth, max(0, current_level - 1))
	var rounded := int(ceil(raw / 10.0) * 10.0) if normalized_currency == "coins" else int(ceil(raw))
	return max(1, rounded)


func get_skin_upgrade_cost_for_id(id: String, currency: String) -> int:
	if is_skin_max_level(id):
		return 0
	return get_skin_upgrade_cost(_skin_rarity_from_id(id), get_skin_level(id), currency)


func upgrade_skin_with_coins(id: String) -> Dictionary:
	return _upgrade_skin(id, "coins")


func upgrade_skin_with_diamonds(id: String) -> Dictionary:
	return _upgrade_skin(id, "diamonds")


func _upgrade_skin(id: String, currency: String) -> Dictionary:
	if not Array(data.get("unlocked_skins", [])).has(id):
		return { "ok": false, "reason": "locked" }
	var level := get_skin_level(id)
	var max_level := get_skin_max_level(id)
	if level >= max_level:
		return { "ok": false, "reason": "max" }
	var cost := get_skin_upgrade_cost_for_id(id, currency)
	if currency == "diamonds":
		if int(data.get("diamonds", 0)) < cost:
			return { "ok": false, "reason": "diamonds" }
		data["diamonds"] = max(0, int(data.get("diamonds", 0)) - cost)
	else:
		if int(data.get("coins", 0)) < cost:
			return { "ok": false, "reason": "coins" }
		data["coins"] = max(0, int(data.get("coins", 0)) - cost)
	var levels: Dictionary = data.get("skin_levels", {})
	levels[id] = level + 1
	data["skin_levels"] = levels
	_update_skin_collection_stats()
	_update_achievements(false)
	save_game()
	return { "ok": true, "level": level + 1, "max_level": max_level, "cost": cost, "currency": currency }


func apply_skin_level_scaling(base_effect: Dictionary, level: int, rarity: String) -> Dictionary:
	var scaled := base_effect.duplicate(true)
	var max_level := int(SKIN_MAX_LEVEL_BY_RARITY.get(rarity, 5))
	var progress := 0.0 if max_level <= 1 else float(clampi(level, 1, max_level) - 1) / float(max_level - 1)
	var effect_type := String(scaled.get("effect", scaled.get("type", "trail")))
	var chance := float(scaled.get("chance", 0.0))
	var value := float(scaled.get("value", 0.0))
	if chance > 0.0:
		scaled["chance"] = clamp_skin_effect(effect_type + "_chance", chance * (1.0 + progress * 0.55))
	if value != 0.0:
		scaled["value"] = clamp_skin_effect(effect_type, value * (1.0 + progress * 0.70))
	if scaled.has("control_strength"):
		scaled["control_strength"] = clamp_skin_effect("control", float(scaled.get("control_strength", 0.0)) * (1.0 + progress * 0.45))
	scaled["level_progress"] = progress
	return scaled


func clamp_skin_effect(effect_type: String, value: float) -> float:
	match effect_type:
		"crit", "crit_chance", "critical", "cosmic_critical":
			return clampf(value, 0.0, 35.0)
		"crit_chance_chance", "mega_crit_chance", "cosmic_critical_chance":
			return clampf(value, 0.0, 0.35)
		"phase", "phase_solid", "phase_chance":
			return clampf(value, 0.0, 0.15)
		"perfect", "perfect_chance":
			return clampf(value, 0.0, 0.08)
		"freeze", "freeze_ring", "slow_ring":
			return clampf(value, 0.0, 0.68)
		"freeze_chance", "freeze_ring_chance", "slow_ring_chance":
			return clampf(value, 0.0, 0.34)
		"speed":
			return clampf(value, 0.0, 0.28)
		"control":
			return clampf(value, 0.0, 0.78)
		"coin", "coin_on_hit":
			return clampf(value, 0.0, 34.0)
		"coin_multiplier":
			return clampf(value, 0.0, 0.75)
		"xp", "xp_multiplier":
			return clampf(value, 0.0, 0.80)
		"burn":
			return clampf(value, 0.0, 1.35)
		"chain", "chain_damage", "area", "area_damage", "repulse", "repel_ring":
			return clampf(value, 0.0, 1.40 if not effect_type.contains("repulse") and not effect_type.contains("repel") else 40.0)
	return value


func get_skin_effect_value(skin_id: String, level := -1) -> Dictionary:
	var skin := MainPortData.skin_by_id(skin_id)
	if skin.is_empty():
		return { "type": "trail", "chance": 0.0, "value": 0.0, "level": 1, "max_level": 5 }
	var rarity := String(skin.get("rarity", "common"))
	var actual_level := get_skin_level(skin_id) if level <= 0 else clampi(level, 1, get_skin_max_level(skin_id))
	var passive: Dictionary = Dictionary(skin.get("passive", {})).duplicate(true)
	passive["effect"] = String(passive.get("type", "trail"))
	var scaled := apply_skin_level_scaling(passive, actual_level, rarity)
	scaled["level"] = actual_level
	scaled["max_level"] = get_skin_max_level(skin_id)
	scaled["rarity"] = rarity
	return scaled


func get_skin_upgrade_preview(id: String) -> Dictionary:
	var level := get_skin_level(id)
	return {
		"level": level,
		"max_level": get_skin_max_level(id),
		"current": get_skin_effect_value(id, level),
		"next": get_skin_effect_value(id, min(level + 1, get_skin_max_level(id))),
		"coins": get_skin_upgrade_cost_for_id(id, "coins"),
		"diamonds": get_skin_upgrade_cost_for_id(id, "diamonds"),
	}


func debug_level_up_equipped_skin() -> void:
	var id := String(data.get("equipped_skin", "neon_blue"))
	var levels: Dictionary = data.get("skin_levels", {})
	levels[id] = min(get_skin_max_level(id), get_skin_level(id) + 1)
	data["skin_levels"] = levels
	_update_skin_collection_stats()
	_update_achievements(false)
	save_game()


func debug_max_equipped_skin() -> void:
	var id := String(data.get("equipped_skin", "neon_blue"))
	var levels: Dictionary = data.get("skin_levels", {})
	levels[id] = get_skin_max_level(id)
	data["skin_levels"] = levels
	_update_skin_collection_stats()
	_update_achievements(false)
	save_game()


func debug_max_all_skins() -> void:
	var levels: Dictionary = data.get("skin_levels", {})
	for id in Array(data.get("unlocked_skins", [])):
		levels[String(id)] = get_skin_max_level(String(id))
	data["skin_levels"] = levels
	_update_skin_collection_stats()
	_update_achievements(false)
	save_game()


func debug_reset_skin_levels() -> void:
	var levels := {}
	for id in Array(data.get("unlocked_skins", [])):
		levels[String(id)] = 1
	data["skin_levels"] = levels
	_update_skin_collection_stats()
	_update_achievements(false)
	save_game()


func should_show_tutorial() -> bool:
	_ensure_tutorial_state()
	var tutorial: Dictionary = data.get("tutorial", {})
	return not bool(tutorial.get("seen", false)) and not bool(tutorial.get("dont_show_again", false))


func mark_tutorial_seen(dont_show_again := false) -> void:
	_ensure_tutorial_state()
	var tutorial: Dictionary = data.get("tutorial", {})
	tutorial["seen"] = true
	if dont_show_again:
		tutorial["dont_show_again"] = true
	tutorial["completed_at"] = TimeManager.get_now_timestamp() if has_node("/root/TimeManager") else int(Time.get_unix_time_from_system())
	data["tutorial"] = tutorial
	save_game()


func set_tutorial_dont_show_again(enabled: bool) -> void:
	_ensure_tutorial_state()
	var tutorial: Dictionary = data.get("tutorial", {})
	tutorial["dont_show_again"] = enabled
	if enabled:
		tutorial["seen"] = true
		tutorial["completed_at"] = TimeManager.get_now_timestamp() if has_node("/root/TimeManager") else int(Time.get_unix_time_from_system())
	data["tutorial"] = tutorial
	save_game()


func reset_tutorial_for_debug() -> void:
	_ensure_tutorial_state()
	data["tutorial"] = {
		"seen": false,
		"dont_show_again": false,
		"completed_at": 0,
		"debug_reset_available": true,
		"guided_hints": {
			"open_upgrades": false,
			"open_skins": false,
			"modes": false,
		},
	}
	save_game()


func get_guided_hint_id() -> String:
	_ensure_tutorial_state()
	var hints: Dictionary = data.get("tutorial", {}).get("guided_hints", {})
	var stats: Dictionary = data.get("stats", {})
	if int(data.get("max_unlocked_phase", 1)) >= 2 and not bool(hints.get("open_upgrades", false)):
		return "open_upgrades"
	if int(stats.get("upgradesBought", 0)) >= 1 and not bool(hints.get("open_skins", false)):
		return "open_skins"
	if int(stats.get("skinEquips", 0)) >= 1 and not bool(hints.get("modes", false)):
		return "modes"
	return ""


func mark_guided_hint_done(id: String) -> void:
	if id.is_empty():
		return
	_ensure_tutorial_state()
	var tutorial: Dictionary = data.get("tutorial", {})
	var hints: Dictionary = tutorial.get("guided_hints", {})
	hints[id] = true
	tutorial["guided_hints"] = hints
	data["tutorial"] = tutorial
	save_game()


func upgrade_permanent(id: String) -> void:
	var upgrades: Dictionary = data.get("permanent_upgrades", {})
	upgrades[id] = int(upgrades.get(id, 0)) + 1
	data["permanent_upgrades"] = upgrades
	save_game()


func unlock_level(level: int) -> void:
	level = clampi(level, 1, MAX_PHASE)
	var phases: Array = data.get("unlocked_phases", [])
	for phase in range(1, level + 1):
		if not phases.has(phase):
			phases.append(phase)
	data["unlocked_phases"] = phases
	data["max_unlocked_phase"] = max(int(data.get("max_unlocked_phase", 1)), level)
	data["stats"]["highest_phase"] = max(int(data["stats"].get("highest_phase", 1)), level)
	refresh_unlocks(false)
	save_game()


func select_phase(level: int) -> bool:
	var unlocked := int(data.get("max_unlocked_phase", 1))
	if level < 1 or level > MAX_PHASE or level > unlocked:
		return false
	data["selected_phase"] = level
	data["selected_mode"] = "phase"
	data["current_phase"] = max(int(data.get("current_phase", 1)), level)
	save_game()
	return true


func select_infinite() -> bool:
	if int(data.get("max_unlocked_phase", 1)) < 5:
		return false
	data["selected_mode"] = "infinite"
	data["selected_phase"] = 1
	save_game()
	return true


func _track_skin_mode_usage(mode: String, won: bool, seconds: int, rings: int, perfects: int) -> void:
	var skin_id := String(data.get("equipped_skin", "neon_blue"))
	if not Array(data.get("unlocked_skins", [])).has(skin_id):
		skin_id = "neon_blue"
	var usage: Dictionary = data.get("skin_usage", {})
	usage[skin_id] = int(usage.get(skin_id, 0)) + 1
	data["skin_usage"] = usage
	var rarity := _skin_rarity_from_id(skin_id)
	var effects := _skin_effect_ids_from_id(skin_id)
	var stats: Dictionary = data.get("stats", {})
	if won and mode == "phase":
		match rarity:
			"common":
				stats["skinCommonPhaseWins"] = int(stats.get("skinCommonPhaseWins", 0)) + 1
			"rare":
				stats["skinRarePhaseWins"] = int(stats.get("skinRarePhaseWins", 0)) + 1
			"epic":
				stats["skinEpicPhaseWins"] = int(stats.get("skinEpicPhaseWins", 0)) + 1
	if mode == "infinite" and effects.has("control"):
		stats["skinControlInfiniteSeconds"] = max(int(stats.get("skinControlInfiniteSeconds", 0)), seconds)
	if won and mode == "boss" and effects.has("fire"):
		stats["skinFireBossWins"] = int(stats.get("skinFireBossWins", 0)) + 1
	if won and mode == "league" and rarity == "ultimate":
		stats["skinUltimateLeagueWins"] = int(stats.get("skinUltimateLeagueWins", 0)) + 1
	if perfects > 0 and (effects.has("ice") or effects.has("control")):
		stats["skinIceControlPerfects"] = int(stats.get("skinIceControlPerfects", 0)) + perfects
	if rings > 0 and _skin_rarity_rank(rarity) >= _skin_rarity_rank("legendary"):
		stats["skinLegendaryPlusRings"] = int(stats.get("skinLegendaryPlusRings", 0)) + rings
	data["stats"] = stats


func _skin_rarity_rank(rarity: String) -> int:
	var index := SKIN_RARITY_ORDER.find(rarity)
	return index if index >= 0 else 0


func add_profile_xp(amount: int) -> void:
	if amount > 0:
		_add_earning_stats(0, amount, 0, 0)
	data["profile_xp"] = max(0, int(data.get("profile_xp", 0)) + amount)
	data["xp"] = max(0, int(data.get("xp", 0)) + amount)
	while int(data.get("profile_xp", 0)) >= _xp_needed_for_level(int(data.get("level", 1))):
		data["profile_xp"] = int(data.get("profile_xp", 0)) - _xp_needed_for_level(int(data.get("level", 1)))
		data["level"] = int(data.get("level", 1)) + 1
	refresh_unlocks(false)
	save_game()


func record_phase_complete(phase: int, coins: int, xp: int, rings_destroyed: int, perfect_escapes: int, diamonds: int = 0, best_combo: int = 0, criticals: int = 0, skin_effects: int = 0, run_upgrades: int = 0, seconds: int = 0) -> Dictionary:
	var phase_config := LevelData.get_phase_config(phase)
	var bonus_coins := int(phase_config.get("reward_coins", 0))
	var bonus_xp := int(phase_config.get("reward_xp", 0))
	var bonus_diamonds := diamonds
	if randf() < float(phase_config.get("diamond_chance", 0.0)):
		bonus_diamonds += 1
	var reward_drops := _roll_phase_reward_drops(phase)
	data["coins"] = max(0, int(data.get("coins", 0)) + coins + bonus_coins)
	data["diamonds"] = max(0, int(data.get("diamonds", 0)) + bonus_diamonds)
	data["profile_xp"] = max(0, int(data.get("profile_xp", 0)) + xp + bonus_xp)
	data["xp"] = max(0, int(data.get("xp", 0)) + xp + bonus_xp)
	_add_earning_stats(coins + bonus_coins, xp + bonus_xp, bonus_diamonds, 0)
	while int(data.get("profile_xp", 0)) >= _xp_needed_for_level(int(data.get("level", 1))):
		data["profile_xp"] = int(data.get("profile_xp", 0)) - _xp_needed_for_level(int(data.get("level", 1)))
		data["level"] = int(data.get("level", 1)) + 1
	unlock_level(min(MAX_PHASE, phase + 1))
	var stats: Dictionary = data.get("stats", {})
	stats["runs_played"] = int(stats.get("runs_played", 0)) + 1
	stats["runsPlayed"] = int(stats.get("runsPlayed", 0)) + 1
	stats["phaseWins"] = int(stats.get("phaseWins", 0)) + 1
	stats["rings_destroyed"] = int(stats.get("rings_destroyed", 0)) + rings_destroyed
	stats["ringsDestroyed"] = int(stats.get("ringsDestroyed", 0)) + rings_destroyed
	stats["perfect_escapes"] = int(stats.get("perfect_escapes", 0)) + perfect_escapes
	stats["perfectEscapes"] = int(stats.get("perfectEscapes", 0)) + perfect_escapes
	stats["diamonds_found"] = int(stats.get("diamonds_found", 0)) + bonus_diamonds
	stats["diamondsFound"] = int(stats.get("diamondsFound", 0)) + bonus_diamonds
	stats["runCoins"] = int(stats.get("runCoins", 0)) + coins + bonus_coins
	stats["totalPlayTimeSeconds"] = int(stats.get("totalPlayTimeSeconds", 0)) + max(0, seconds)
	stats["bestCombo"] = max(int(stats.get("bestCombo", 0)), best_combo)
	stats["criticals"] = int(stats.get("criticals", 0)) + criticals
	stats["skinEffects"] = int(stats.get("skinEffects", 0)) + skin_effects
	stats["runUpgrades"] = int(stats.get("runUpgrades", 0)) + run_upgrades
	stats["noReviveWins"] = int(stats.get("noReviveWins", 0)) + 1
	stats["highest_phase"] = max(int(stats.get("highest_phase", 1)), min(MAX_PHASE, phase + 1))
	stats["highestPhase"] = max(int(stats.get("highestPhase", 1)), min(MAX_PHASE, phase + 1))
	data["current_phase"] = max(int(data.get("current_phase", 1)), min(MAX_PHASE, phase + 1))
	data["stats"] = stats
	_grant_reward_drops(reward_drops, "phase")
	_track_skin_mode_usage("phase", true, max(0, seconds), rings_destroyed, perfect_escapes)
	_progress_missions("runsPlayed", 1)
	_progress_missions("phaseWins", 1)
	_progress_missions("ringsDestroyed", rings_destroyed)
	_progress_missions("perfectEscapes", perfect_escapes)
	_progress_missions("runCoins", coins + bonus_coins)
	_progress_missions("bestCombo", best_combo)
	_progress_missions("criticals", criticals)
	_progress_missions("skinEffects", skin_effects)
	_progress_missions("runUpgrades", run_upgrades)
	_progress_missions("noReviveWins", 1)
	add_neon_pass_source_xp("normal_level_played")
	add_neon_pass_source_xp("normal_level_win")
	var first_win := _add_neon_pass_first_win_bonus("normal_level_win")
	refresh_unlocks(false)
	_update_achievements(false)
	save_game()
	return {
		"coins": coins + bonus_coins,
		"xp": xp + bonus_xp,
		"diamonds": bonus_diamonds,
		"keys": int(reward_drops.get("keys", 0)),
		"chest_rewarded": int(reward_drops.get("chests", 0)) > 0,
		"reward_drops": reward_drops,
		"first_win_bonus": first_win,
	}


func record_infinite_run(summary: Dictionary) -> Dictionary:
	var coins := int(summary.get("coins", 0))
	var xp := int(summary.get("xp", 0))
	var diamonds := int(summary.get("diamonds", 0))
	var rings_value := int(summary.get("rings", 0))
	var seconds := int(summary.get("seconds", 0))
	var score := int(summary.get("score", 0))
	var combo_value := int(summary.get("best_combo", 0))
	var critical_value := int(summary.get("criticals", 0))
	var skin_effect_value := int(summary.get("skin_effects", 0))
	var run_upgrade_value := int(summary.get("run_upgrades", 0))
	var run_level_value := int(summary.get("run_level", 1))
	var perfect_value := int(summary.get("perfects", 0))
	data["coins"] = max(0, int(data.get("coins", 0)) + coins)
	data["diamonds"] = max(0, int(data.get("diamonds", 0)) + diamonds)
	data["profile_xp"] = max(0, int(data.get("profile_xp", 0)) + xp)
	data["xp"] = max(0, int(data.get("xp", 0)) + xp)
	_add_earning_stats(coins, xp, diamonds, 0)
	while int(data.get("profile_xp", 0)) >= _xp_needed_for_level(int(data.get("level", 1))):
		data["profile_xp"] = int(data.get("profile_xp", 0)) - _xp_needed_for_level(int(data.get("level", 1)))
		data["level"] = int(data.get("level", 1)) + 1
	var stats: Dictionary = data.get("stats", {})
	stats["runs_played"] = int(stats.get("runs_played", 0)) + 1
	stats["runsPlayed"] = int(stats.get("runsPlayed", 0)) + 1
	stats["infinite_runs"] = int(stats.get("infinite_runs", 0)) + 1
	stats["infiniteRuns"] = int(stats.get("infiniteRuns", 0)) + 1
	stats["rings_destroyed"] = int(stats.get("rings_destroyed", 0)) + rings_value
	stats["ringsDestroyed"] = int(stats.get("ringsDestroyed", 0)) + rings_value
	stats["diamonds_found"] = int(stats.get("diamonds_found", 0)) + diamonds
	stats["diamondsFound"] = int(stats.get("diamondsFound", 0)) + diamonds
	stats["runCoins"] = int(stats.get("runCoins", 0)) + coins
	stats["perfect_escapes"] = int(stats.get("perfect_escapes", 0)) + perfect_value
	stats["perfectEscapes"] = int(stats.get("perfectEscapes", 0)) + perfect_value
	stats["bestCombo"] = max(int(stats.get("bestCombo", 0)), combo_value)
	stats["best_infinite_seconds"] = max(int(stats.get("best_infinite_seconds", 0)), seconds)
	stats["bestInfiniteSeconds"] = max(int(stats.get("bestInfiniteSeconds", 0)), seconds)
	stats["best_infinite_rings"] = max(int(stats.get("best_infinite_rings", 0)), rings_value)
	stats["bestInfiniteRings"] = max(int(stats.get("bestInfiniteRings", 0)), rings_value)
	stats["best_infinite_score"] = max(int(stats.get("best_infinite_score", 0)), score)
	stats["bestInfiniteScore"] = max(int(stats.get("bestInfiniteScore", 0)), score)
	stats["bestInfiniteReward"] = max(int(stats.get("bestInfiniteReward", 0)), coins + diamonds * 80 + xp)
	stats["totalPlayTimeSeconds"] = int(stats.get("totalPlayTimeSeconds", 0)) + seconds
	stats["infiniteBestLevel"] = max(int(stats.get("infiniteBestLevel", 0)), run_level_value)
	stats["criticals"] = int(stats.get("criticals", 0)) + critical_value
	stats["skinEffects"] = int(stats.get("skinEffects", 0)) + skin_effect_value
	stats["runUpgrades"] = int(stats.get("runUpgrades", 0)) + run_upgrade_value
	data["stats"] = stats
	var reward_drops := _roll_infinite_reward_drops(summary)
	_grant_reward_drops(reward_drops, "infinite")
	_track_skin_mode_usage("infinite", false, seconds, rings_value, perfect_value)
	_progress_missions("runsPlayed", 1)
	_progress_missions("infiniteRuns", 1)
	_progress_missions("bestInfiniteSeconds", seconds)
	_progress_missions("bestInfiniteRings", rings_value)
	_progress_missions("ringsDestroyed", rings_value)
	_progress_missions("perfectEscapes", perfect_value)
	_progress_missions("runCoins", coins)
	_progress_missions("bestCombo", combo_value)
	_progress_missions("criticals", critical_value)
	_progress_missions("skinEffects", skin_effect_value)
	_progress_missions("runUpgrades", run_upgrade_value)
	_add_neon_pass_infinite_xp(seconds, rings_value)
	var first_win := {}
	if seconds >= 20 or rings_value >= 3 or score > 0:
		first_win = _add_neon_pass_first_win_bonus("infinite_valid_result")
	refresh_unlocks(false)
	_update_achievements(false)
	save_game()
	return {
		"coins": coins,
		"xp": xp,
		"diamonds": diamonds,
		"rings": rings_value,
		"seconds": seconds,
		"reward_drops": reward_drops,
		"first_win_bonus": first_win,
	}


func on_ring_destroyed(amount := 1) -> void:
	_increment_stat("ringsDestroyed", amount, false)
	_increment_stat("rings_destroyed", amount, false)
	_progress_missions("ringsDestroyed", amount)
	_update_achievements(false)


func on_level_completed(level_id: int, summary: Dictionary = {}) -> void:
	record_phase_complete(
		level_id,
		int(summary.get("coins", 0)),
		int(summary.get("xp", 0)),
		int(summary.get("rings", 0)),
		int(summary.get("perfects", 0)),
		int(summary.get("diamonds", 0)),
		int(summary.get("best_combo", 0)),
		int(summary.get("criticals", 0)),
		int(summary.get("skin_effects", 0)),
		int(summary.get("run_upgrades", 0)),
		int(summary.get("seconds", 0))
	)


func on_infinite_run_finished(summary: Dictionary) -> void:
	record_infinite_run(summary)


func on_coins_earned(amount: int) -> void:
	_increment_stat("runCoins", amount, false)
	_progress_missions("runCoins", amount)
	_update_achievements(false)


func on_skin_equipped(skin_id: String) -> void:
	equip_skin(skin_id)


func on_skin_unlocked(skin_id: String) -> void:
	unlock_skin(skin_id)


func on_upgrade_bought(upgrade_id: String) -> void:
	_increment_stat("upgradesBought", 1, false)
	_progress_missions("upgradesBought", 1)
	_update_achievements(false)


func on_daily_reward_claimed() -> void:
	_increment_stat("dailyRewardsCollected", 1, false)
	_progress_missions("dailyRewardsCollected", 1)
	_update_achievements(false)


func on_wheel_spun() -> void:
	_increment_stat("wheelSpins", 1, false)
	_progress_missions("wheelSpins", 1)
	_update_achievements(false)


func on_chest_opened() -> void:
	_increment_stat("chestsOpened", 1, false)
	_increment_stat("chests_opened", 1, false)
	_progress_missions("chestsOpened", 1)
	_update_achievements(false)


func on_mission_completed() -> void:
	_increment_stat("missionsCompleted", 1, false)
	_update_achievements(false)


func record_mode_quit(mode: String, summary: Dictionary) -> void:
	var coins: int = max(0, int(summary.get("coins", 0)))
	var xp: int = max(0, int(summary.get("xp", 0)))
	var diamonds: int = max(0, int(summary.get("diamonds", 0)))
	data["coins"] = int(data.get("coins", 0)) + coins
	data["diamonds"] = int(data.get("diamonds", 0)) + diamonds
	_add_earning_stats(coins, xp, diamonds, 0)
	add_profile_xp(xp)
	var stats: Dictionary = data.get("stats", {})
	stats["runsPlayed"] = int(stats.get("runsPlayed", 0)) + 1
	stats["runs_played"] = int(stats.get("runs_played", 0)) + 1
	stats["ringsDestroyed"] = int(stats.get("ringsDestroyed", 0)) + int(summary.get("rings", 0))
	stats["rings_destroyed"] = int(stats.get("rings_destroyed", 0)) + int(summary.get("rings", 0))
	stats["perfectEscapes"] = int(stats.get("perfectEscapes", 0)) + int(summary.get("perfects", 0))
	stats["perfect_escapes"] = int(stats.get("perfect_escapes", 0)) + int(summary.get("perfects", 0))
	stats["runCoins"] = int(stats.get("runCoins", 0)) + coins
	stats["totalPlayTimeSeconds"] = int(stats.get("totalPlayTimeSeconds", 0)) + int(summary.get("seconds", 0))
	stats["bestCombo"] = max(int(stats.get("bestCombo", 0)), int(summary.get("best_combo", 0)))
	stats["criticals"] = int(stats.get("criticals", 0)) + int(summary.get("criticals", 0))
	stats["skinEffects"] = int(stats.get("skinEffects", 0)) + int(summary.get("skin_effects", 0))
	stats["runUpgrades"] = int(stats.get("runUpgrades", 0)) + int(summary.get("run_upgrades", 0))
	if mode == "infinite":
		stats["infiniteRuns"] = int(stats.get("infiniteRuns", 0)) + 1
		stats["infinite_runs"] = int(stats.get("infinite_runs", 0)) + 1
		stats["bestInfiniteSeconds"] = max(int(stats.get("bestInfiniteSeconds", 0)), int(summary.get("seconds", 0)))
		stats["best_infinite_seconds"] = max(int(stats.get("best_infinite_seconds", 0)), int(summary.get("seconds", 0)))
		stats["bestInfiniteRings"] = max(int(stats.get("bestInfiniteRings", 0)), int(summary.get("rings", 0)))
		stats["best_infinite_rings"] = max(int(stats.get("best_infinite_rings", 0)), int(summary.get("rings", 0)))
		stats["bestInfiniteScore"] = max(int(stats.get("bestInfiniteScore", 0)), int(summary.get("score", 0)))
		stats["best_infinite_score"] = max(int(stats.get("best_infinite_score", 0)), int(summary.get("score", 0)))
		stats["infiniteBestLevel"] = max(int(stats.get("infiniteBestLevel", 0)), int(summary.get("run_level", 1)))
	data["stats"] = stats
	_track_skin_mode_usage(mode, false, int(summary.get("seconds", 0)), int(summary.get("rings", 0)), int(summary.get("perfects", 0)))
	_progress_missions("runsPlayed", 1)
	_progress_missions("ringsDestroyed", int(summary.get("rings", 0)))
	_progress_missions("perfectEscapes", int(summary.get("perfects", 0)))
	_progress_missions("runCoins", coins)
	_progress_missions("bestCombo", int(summary.get("best_combo", 0)))
	_progress_missions("criticals", int(summary.get("criticals", 0)))
	_progress_missions("skinEffects", int(summary.get("skin_effects", 0)))
	_progress_missions("runUpgrades", int(summary.get("run_upgrades", 0)))
	if mode == "infinite":
		_add_neon_pass_infinite_xp(int(summary.get("seconds", 0)), int(summary.get("rings", 0)))
	elif mode == "phase":
		add_neon_pass_source_xp("normal_level_played")
	refresh_unlocks(false)
	_update_achievements(false)
	save_game()


func record_neon_league_match(result: String, summary: Dictionary) -> Dictionary:
	_ensure_league_season()
	var league: Dictionary = data.get("league", {})
	var trophies := int(league.get("trophies", 0))
	var previous_rank := MainPortData.rank_for_trophies(trophies)
	var base_delta := 34 if result == "win" else -14 if result == "loss" else -10
	var rings_value := int(summary.get("rings", 0))
	var seconds := int(summary.get("seconds", 0))
	var trophy_delta := base_delta
	var run_upgrade_levels: Dictionary = summary.get("run_upgrade_levels", {})
	if result == "win":
		trophy_delta += min(12, rings_value / 4) + min(6, seconds / 45)
		trophy_delta += int(run_upgrade_levels.get("trophyInstinct", 0)) * 2
	else:
		trophy_delta += min(6, rings_value / 10)
	trophies = max(0, trophies + trophy_delta)
	league["trophies"] = trophies
	league["season_key"] = String(league.get("season_key", TimeManager.get_month_key()))
	league["matches"] = int(league.get("matches", 0)) + 1
	league["wins"] = int(league.get("wins", 0)) + (1 if result == "win" else 0)
	league["losses"] = int(league.get("losses", 0)) + (1 if result == "loss" else 0)
	league["quits"] = int(league.get("quits", 0)) + (1 if result == "quit" else 0)
	league["win_streak"] = int(league.get("win_streak", 0)) + 1 if result == "win" else 0
	league["best_streak"] = max(int(league.get("best_streak", 0)), int(league.get("win_streak", 0)))
	league["last_opponent_id"] = String(summary.get("opponent_id", ""))
	var rank := MainPortData.rank_for_trophies(trophies)
	var rank_id := String(rank.get("id", "bronze"))
	var previous_rank_id := String(previous_rank.get("id", "bronze"))
	if _league_rank_index(rank_id) > _league_rank_index(String(league.get("highest_rank_id", "bronze"))):
		league["highest_rank_id"] = rank_id
	var promotion_skin_id := ""
	if previous_rank_id == "bronze" and rank_id != "bronze" and not bool(league.get("bronze_promotion_skin_claimed", false)):
		promotion_skin_id = "initial_neon_champion"
		league["bronze_promotion_skin_claimed"] = true
		league["last_reward"] = "initial_neon_champion"
	data["league"] = league

	var league_phase_reward := LevelData.get_phase_config(_league_equivalent_phase(rank_id))
	var league_outcome_multiplier := 1.0 if result == "win" else 0.42 if result == "loss" else 0.18
	var coins: int = max(10, int(summary.get("coins", 0)) + floori(float(int(league_phase_reward.get("reward_coins", 120))) * league_outcome_multiplier))
	var xp: int = max(8, int(summary.get("xp", 0)) + floori(float(int(league_phase_reward.get("reward_xp", 90))) * league_outcome_multiplier))
	var diamonds: int = max(0, int(summary.get("diamonds", 0)))
	if result == "win" and randf() < 0.35:
		diamonds += 4
	if result == "win" and randf() < 0.08:
		add_inventory_item("chest_rare", "chest", "Chest Rare", "rare", 1)
	data["coins"] = int(data.get("coins", 0)) + coins
	data["diamonds"] = int(data.get("diamonds", 0)) + diamonds
	_add_earning_stats(coins, xp, diamonds, 0)
	add_profile_xp(xp)
	add_neon_pass_source_xp("league_battle")
	var first_win := {}
	if result == "win":
		add_neon_pass_source_xp("league_win")
		first_win = _add_neon_pass_first_win_bonus("league_win")

	var stats: Dictionary = data.get("stats", {})
	stats["leagueMatches"] = int(stats.get("leagueMatches", 0)) + 1
	stats["leagueWins"] = int(stats.get("leagueWins", 0)) + (1 if result == "win" else 0)
	stats["leagueLosses"] = int(stats.get("leagueLosses", 0)) + (1 if result == "loss" else 0)
	stats["leagueQuits"] = int(stats.get("leagueQuits", 0)) + (1 if result == "quit" else 0)
	stats["leagueTrophies"] = trophies
	stats["highestLeagueTrophies"] = max(int(stats.get("highestLeagueTrophies", 0)), trophies)
	stats["leagueTrophiesTotal"] = int(stats.get("leagueTrophiesTotal", 0)) + max(0, trophy_delta)
	stats["leagueWinStreak"] = max(int(stats.get("leagueWinStreak", 0)), int(league.get("best_streak", 0)))
	stats["leagueRankIndex"] = max(int(stats.get("leagueRankIndex", 0)), _league_rank_index(rank_id))
	stats["ringsDestroyed"] = int(stats.get("ringsDestroyed", 0)) + rings_value
	stats["rings_destroyed"] = int(stats.get("rings_destroyed", 0)) + rings_value
	stats["perfectEscapes"] = int(stats.get("perfectEscapes", 0)) + int(summary.get("perfects", 0))
	stats["perfect_escapes"] = int(stats.get("perfect_escapes", 0)) + int(summary.get("perfects", 0))
	stats["runCoins"] = int(stats.get("runCoins", 0)) + coins
	stats["diamondsFound"] = int(stats.get("diamondsFound", 0)) + diamonds
	stats["diamonds_found"] = int(stats.get("diamonds_found", 0)) + diamonds
	stats["totalPlayTimeSeconds"] = int(stats.get("totalPlayTimeSeconds", 0)) + seconds
	if not promotion_skin_id.is_empty():
		var skins: Array = data.get("unlocked_skins", [])
		if not skins.has(promotion_skin_id):
			skins.append(promotion_skin_id)
			data["unlocked_skins"] = skins
			var skin_levels: Dictionary = data.get("skin_levels", {})
			skin_levels[promotion_skin_id] = max(1, int(skin_levels.get(promotion_skin_id, 1)))
			data["skin_levels"] = skin_levels
			stats["skins_unlocked"] = skins.size()
			stats["skinsUnlocked"] = skins.size()
	if rank_id in ["silver", "gold", "diamond", "legendary", "ultimate"]:
		stats["leagueSilverReached"] = 1
	if rank_id in ["gold", "diamond", "legendary", "ultimate"]:
		stats["leagueGoldReached"] = 1
	if rank_id in ["diamond", "legendary", "ultimate"]:
		stats["leagueDiamondReached"] = 1
	if rank_id in ["legendary", "ultimate"]:
		stats["leagueLegendaryReached"] = 1
	if rank_id == "ultimate":
		stats["leagueUltimateReached"] = 1
	data["stats"] = stats
	_track_skin_mode_usage("league", result == "win", seconds, rings_value, int(summary.get("perfects", 0)))
	_progress_missions("leagueMatches", 1)
	if result == "win":
		_progress_missions("leagueWins", 1)
	_progress_missions("ringsDestroyed", rings_value)
	_progress_missions("perfectEscapes", int(summary.get("perfects", 0)))
	_progress_missions("runCoins", coins)
	if not promotion_skin_id.is_empty():
		_update_skin_collection_stats()
	_update_achievements(false)
	save_game()
	return { "coins": coins, "xp": xp, "diamonds": diamonds, "trophy_delta": trophy_delta, "trophies": trophies, "rank": rank, "promotion_skin": promotion_skin_id, "first_win_bonus": first_win }


func _league_equivalent_phase(rank_id: String) -> int:
	match rank_id:
		"silver":
			return 16
		"gold":
			return 30
		"diamond":
			return 55
		"legendary":
			return 75
		"ultimate":
			return 92
		_:
			return 8


func set_audio_muted(muted: bool) -> void:
	data["settings"]["audio_muted"] = muted
	data["settings"]["master_muted"] = muted
	data["settings"]["music_muted"] = muted
	data["settings"]["sfx_muted"] = muted
	save_game()


func set_music_muted(muted: bool) -> void:
	data["settings"]["music_muted"] = muted
	data["settings"]["audio_muted"] = bool(data["settings"].get("music_muted", false)) and bool(data["settings"].get("sfx_muted", false))
	data["settings"]["master_muted"] = data["settings"]["audio_muted"]
	save_game()


func set_sfx_muted(muted: bool) -> void:
	data["settings"]["sfx_muted"] = muted
	data["settings"]["audio_muted"] = bool(data["settings"].get("music_muted", false)) and bool(data["settings"].get("sfx_muted", false))
	data["settings"]["master_muted"] = data["settings"]["audio_muted"]
	save_game()


func set_language(language: String) -> void:
	data["settings"]["language"] = language
	save_game()


func get_setting(key: String, fallback = null):
	return data.get("settings", {}).get(key, fallback)


func debug_force_chest_drop_next_win() -> void:
	data["debug_force_chest_drop_next_win"] = true
	save_game()


func debug_force_key_drop_next_win() -> void:
	data["debug_force_key_drop_next_win"] = true
	save_game()


func debug_reward_drop_chances() -> Dictionary:
	var phase := clampi(int(data.get("current_phase", 1)), 1, MAX_PHASE)
	var phase_config := LevelData.get_phase_config(phase)
	var infinite_sample := {
		"seconds": 180,
		"rings": 30,
	}
	return {
		"phase": phase,
		"phase_key_chance": float(phase_config.get("key_chance", 0.0)),
		"phase_chest_chance": float(phase_config.get("chest_chance", 0.0)),
		"phase_chest_type_preview": _phase_chest_type_preview(phase),
		"infinite_sample_seconds": int(infinite_sample["seconds"]),
		"infinite_sample_rings": int(infinite_sample["rings"]),
		"infinite_key_chance": _infinite_key_drop_chance(infinite_sample),
		"infinite_chest_chance": _infinite_chest_drop_chance(infinite_sample),
		"forced_chest_next_win": bool(data.get("debug_force_chest_drop_next_win", false)),
		"forced_key_next_win": bool(data.get("debug_force_key_drop_next_win", false)),
	}


func _xp_needed_for_level(player_level: int) -> int:
	return floori(130.0 * pow(max(1, player_level), 1.50))


func _empty_reward_drops(source: String, chances: Dictionary = {}) -> Dictionary:
	return {
		"source": source,
		"keys": 0,
		"chests": 0,
		"chest_types": {},
		"chances": chances,
	}


func _roll_phase_reward_drops(phase: int) -> Dictionary:
	var phase_config := LevelData.get_phase_config(phase)
	var key_chance := clampf(float(phase_config.get("key_chance", 0.0)), 0.0, 1.0)
	var chest_chance := clampf(float(phase_config.get("chest_chance", 0.0)), 0.0, 1.0)
	var result := _empty_reward_drops("phase", {
		"key": key_chance,
		"chest": chest_chance,
	})
	var force_key := bool(data.get("debug_force_key_drop_next_win", false))
	var force_chest := bool(data.get("debug_force_chest_drop_next_win", false))
	if force_key:
		data["debug_force_key_drop_next_win"] = false
	if force_chest:
		data["debug_force_chest_drop_next_win"] = false
	if force_key or randf() < key_chance:
		result["keys"] = 1
	if force_chest or randf() < chest_chance:
		var chest_type := _phase_chest_type(phase)
		result["chests"] = 1
		result["chest_types"] = { chest_type: 1 }
	return result


func _roll_infinite_reward_drops(summary: Dictionary) -> Dictionary:
	var seconds: int = maxi(0, int(summary.get("seconds", 0)))
	var rings: int = maxi(0, int(summary.get("rings", 0)))
	var key_chance: float = _infinite_key_drop_chance(summary)
	var chest_chance: float = _infinite_chest_drop_chance(summary)
	var result: Dictionary = _empty_reward_drops("infinite", {
		"key": key_chance,
		"chest": chest_chance,
	})
	if seconds < 30 and rings < 10:
		return result
	var force_key: bool = bool(data.get("debug_force_key_drop_next_win", false))
	var force_chest: bool = bool(data.get("debug_force_chest_drop_next_win", false))
	if force_key:
		data["debug_force_key_drop_next_win"] = false
	if force_chest:
		data["debug_force_chest_drop_next_win"] = false
	if force_key or randf() < key_chance:
		result["keys"] = 1
	if force_chest or randf() < chest_chance:
		var chest_type := _infinite_chest_type(seconds, rings)
		result["chests"] = 1
		result["chest_types"] = { chest_type: 1 }
	return result


func _grant_reward_drops(drops: Dictionary, source: String) -> void:
	var keys := int(drops.get("keys", 0))
	if keys > 0:
		apply_reward({ "type": "keys", "amount": keys }, false)
		_increment_stat("keysEarned", keys, false)
		_progress_missions("keysEarned", keys)
		_progress_missions("keysFound", keys)
	var chest_count := 0
	var chest_types: Dictionary = Dictionary(drops.get("chest_types", {}))
	for chest_type in chest_types.keys():
		var amount := int(chest_types[chest_type])
		if amount <= 0:
			continue
		apply_reward({ "type": "chest", "chest_type": String(chest_type), "amount": amount }, false)
		chest_count += amount
	if chest_count > 0:
		_increment_stat("chestsEarned", chest_count, false)
		_progress_missions("chestsEarned", chest_count)
		_progress_missions("chestsFound", chest_count)
	if keys > 0 or chest_count > 0:
		_increment_stat("rewardDrops", 1, false)
		_increment_stat("%sRewardDrops" % source, 1, false)


func _infinite_key_drop_chance(summary: Dictionary) -> float:
	var seconds: int = maxi(0, int(summary.get("seconds", 0)))
	var rings: int = maxi(0, int(summary.get("rings", 0)))
	if seconds < 30 and rings < 10:
		return 0.0
	var minutes := float(seconds) / 60.0
	return clampf(0.010 + minutes * 0.008 + float(rings) * 0.00035, 0.0, 0.18)


func _infinite_chest_drop_chance(summary: Dictionary) -> float:
	var seconds: int = maxi(0, int(summary.get("seconds", 0)))
	var rings: int = maxi(0, int(summary.get("rings", 0)))
	if seconds < 30 and rings < 10:
		return 0.0
	var minutes := float(seconds) / 60.0
	return clampf(0.006 + minutes * 0.006 + float(rings) * 0.00025, 0.0, 0.16)


func _infinite_chest_type(seconds: int, rings: int) -> String:
	if (seconds >= 1800 or rings >= 300) and randf() < 0.06:
		return "legendary"
	if (seconds >= 900 or rings >= 160) and randf() < 0.24:
		return "epic"
	if (seconds >= 240 or rings >= 50) and randf() < 0.55:
		return "rare"
	return "common"


func _phase_chest_type(phase: int) -> String:
	if phase >= 90 and randf() < 0.12:
		return "legendary"
	if phase >= 60 and randf() < 0.22:
		return "epic"
	if phase >= 20 and randf() < 0.42:
		return "rare"
	return "common"


func _phase_chest_type_preview(phase: int) -> String:
	if phase >= 90:
		return "rare/epic/legendary"
	if phase >= 60:
		return "rare/epic"
	if phase >= 20:
		return "common/rare"
	return "common"


func _merge_defaults(defaults: Dictionary, loaded: Dictionary) -> Dictionary:
	var result := defaults.duplicate(true)
	for key in loaded.keys():
		if typeof(result.get(key)) == TYPE_DICTIONARY and typeof(loaded[key]) == TYPE_DICTIONARY:
			result[key] = _merge_defaults(result[key], loaded[key])
		else:
			result[key] = loaded[key]
	return result


func _migrate_legacy_settings() -> void:
	var legacy := SaveManager.load_legacy_settings()
	if legacy.is_empty():
		return
	var settings: Dictionary = data.get("settings", {})
	if legacy.has("language"):
		settings["language"] = legacy["language"]
	if legacy.has("audio_muted"):
		settings["audio_muted"] = legacy["audio_muted"]
		settings["master_muted"] = legacy["audio_muted"]
	data["settings"] = settings

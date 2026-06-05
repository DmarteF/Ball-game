extends Node

signal changed

const LevelData := preload("res://scripts/LevelData.gd")

const MAX_PHASE := 100
const TARGET_ACHIEVEMENT_COUNT := 100
const SAVE_EXPORT_VERSION := 1
const SAVE_EXPORT_FORMAT := "neon_idle_escape_godot_save"
const STARTER_UPGRADE_IDS := ["damage", "speed", "coinBoost", "critical"]

const PERMANENT_UPGRADE_DEFS := {
	"baseDamage": { "base_cost": 70, "max": 40, "phase": 1, "level": 1 },
	"baseSpeed": { "base_cost": 85, "max": 28, "phase": 1, "level": 1 },
	"coinMultiplier": { "base_cost": 120, "max": 34, "phase": 1, "level": 1 },
	"critChance": { "base_cost": 110, "max": 28, "phase": 1, "level": 1 },
	"xpBoost": { "base_cost": 135, "max": 32, "phase": 3, "level": 3 },
	"perfectChance": { "base_cost": 320, "max": 18, "phase": 5, "level": 5 },
	"slowRings": { "base_cost": 440, "max": 18, "phase": 8, "level": 9 },
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
	_append_phase_achievements(result)
	_append_infinite_achievements(result)
	_append_progress_achievements(result)
	return result.slice(0, min(TARGET_ACHIEVEMENT_COUNT, result.size()))


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


func _ready() -> void:
	load_game()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		data["last_exit_at"] = TimeManager.get_now_timestamp()
		save_game()


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
		"stats": {
			"runs_played": 0,
			"rings_destroyed": 0,
			"perfect_escapes": 0,
			"diamonds_found": 0,
			"chests_opened": 0,
			"skins_unlocked": 1,
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
			"skinEquips": 0,
			"leagueMatches": 0,
			"leagueWins": 0,
			"leagueLosses": 0,
			"leagueQuits": 0,
			"leagueTrophies": 0,
			"leagueTrophiesTotal": 0,
			"leagueWinStreak": 0,
			"leagueRankIndex": 0,
			"leagueSilverReached": 0,
			"leagueGoldReached": 0,
			"leagueDiamondReached": 0,
			"leagueLegendaryReached": 0,
			"leagueUltimateReached": 0,
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
	var offline_seconds := TimeManager.get_offline_seconds()
	var rewards := TimeManager.calculate_afk_rewards(offline_seconds)
	data["pending_afk_rewards"] = rewards if int(rewards.get("coins", 0)) >= 25 else {}
	data["last_login_at"] = now
	save_game(false)
	changed.emit()


func save_game(emit_signal := true) -> void:
	SaveManager.save_game(data)
	if emit_signal:
		changed.emit()


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
	var skins: Array = []
	for skin in MainPortData.skins():
		var skin_id := String(Dictionary(skin).get("id", ""))
		if not skin_id.is_empty():
			skins.append(skin_id)
	data["unlocked_skins"] = skins
	data["new_skins"] = skins.duplicate()
	refresh_unlocks(false)
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


func debug_unlock_all_skins() -> void:
	var skins: Array = []
	for skin in MainPortData.skins():
		var skin_id := String(Dictionary(skin).get("id", ""))
		if not skin_id.is_empty() and not skins.has(skin_id):
			skins.append(skin_id)
	data["unlocked_skins"] = skins
	data["new_skins"] = skins.duplicate()
	refresh_unlocks(false)
	save_game()


func debug_reset_daily_reward() -> void:
	data["last_daily_reward_at"] = 0
	data["daily_streak"] = 0
	save_game()


func debug_reset_wheel_timer() -> void:
	data["wheel"] = { "day_key": "", "free_used": false, "ad_spins_used": 0, "last_reward": {} }
	_ensure_live_systems()
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
		var max_level := int(upgrade.get("maxLevel", 1))
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
	var achievements: Dictionary = data.get("achievements", {})
	for achievement in get_achievements():
		var id := String(achievement["id"])
		if not achievements.has(id):
			achievements[id] = { "progress": 0, "completed": false, "claimed": false }
	data["achievements"] = achievements
	_ensure_tutorial_state()
	_update_achievements(false)


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


func get_upgrade_cost(id: String) -> int:
	var definition: Dictionary = MainPortData.upgrade_by_id(id)
	if definition.is_empty():
		return 0
	var level := get_upgrade_level(id)
	var rarity := String(definition.get("rarity", "common"))
	var rarity_multiplier := 1.0
	match rarity:
		"rare":
			rarity_multiplier = 1.55
		"epic":
			rarity_multiplier = 2.25
		"legendary":
			rarity_multiplier = 3.25
	var base_cost := 80 + int(definition.get("unlockLevel", 1)) * 24
	var late_tax: float = 1.0 + max(0.0, float(level - 10)) * 0.025
	return floori(float(base_cost) * rarity_multiplier * pow(1.32, level) * late_tax)


func get_upgrade_max_level(id: String) -> int:
	return int(MainPortData.upgrade_by_id(id).get("maxLevel", 0))


func get_upgrade_level(id: String) -> int:
	_ensure_upgrade_state()
	return int(data.get("upgrade_levels", {}).get(id, 0))


func is_upgrade_unlocked(id: String) -> bool:
	_ensure_upgrade_state()
	return Array(data.get("unlocked_upgrade_ids", [])).has(id)


func get_all_upgrades() -> Array[Dictionary]:
	return MainPortData.run_upgrades()


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
			result.append(Dictionary(upgrade).duplicate(true))
	return result


func get_locked_upgrades() -> Array[Dictionary]:
	var unlocked := get_unlocked_upgrade_ids()
	var result: Array[Dictionary] = []
	for upgrade in MainPortData.run_upgrades():
		var id := String(upgrade.get("id", ""))
		if not unlocked.has(id):
			result.append(Dictionary(upgrade).duplicate(true))
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
	var cost := get_upgrade_cost(id)
	if int(data.get("coins", 0)) < cost:
		return { "ok": false, "reason": "coins", "cost": cost }
	data["coins"] = max(0, int(data.get("coins", 0)) - cost)
	_set_upgrade_level(id, level + 1)
	_increment_stat("upgradesBought", 1, false)
	_progress_missions("upgradesBought", 1)
	_update_achievements(false)
	save_game()
	return { "ok": true, "level": level + 1, "cost": cost }


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
	var cost: int = max(1, ceili(float(get_upgrade_cost(id)) / 120.0))
	if int(data.get("diamonds", 0)) < cost:
		return { "ok": false, "reason": "diamonds", "cost": cost }
	data["diamonds"] = max(0, int(data.get("diamonds", 0)) - cost)
	_set_upgrade_level(id, level + 1)
	_increment_stat("upgradesBought", 1, false)
	_progress_missions("upgradesBought", 1)
	_update_achievements(false)
	save_game()
	return { "ok": true, "level": level + 1, "cost": cost }


func apply_reward(reward: Dictionary, save_after := false) -> String:
	var reward_type := String(reward.get("type", ""))
	var amount := int(reward.get("amount", 1))
	match reward_type:
		"coins":
			data["coins"] = max(0, int(data.get("coins", 0)) + amount)
			return "+%s coins" % amount
		"diamonds", "gems":
			data["diamonds"] = max(0, int(data.get("diamonds", 0)) + amount)
			_increment_stat("diamondsFound", amount, false)
			return "+%s diamonds" % amount
		"keys":
			data["keys"] = max(0, int(data.get("keys", 0)) + amount)
			return "+%s keys" % amount
		"legendaryKeys", "legendary_keys":
			data["legendary_keys"] = max(0, int(data.get("legendary_keys", 0)) + amount)
			return "+%s legendary keys" % amount
		"xp":
			add_profile_xp(amount)
			return "+%s XP" % amount
		"profileXp", "profile_xp":
			add_profile_xp(amount)
			return "+%s profile XP" % amount
		"fragments":
			var skin_id := String(reward.get("skin_id", reward.get("skinId", "generic")))
			var fragments: Dictionary = data.get("skin_fragments", {})
			fragments[skin_id] = int(fragments.get(skin_id, 0)) + amount
			data["skin_fragments"] = fragments
			return "+%s fragments" % amount
		"skin":
			var skin_id := String(reward.get("skin_id", reward.get("skinId", "")))
			if Array(data.get("unlocked_skins", [])).has(skin_id):
				var compensation := _duplicate_skin_compensation(skin_id)
				data["diamonds"] = max(0, int(data.get("diamonds", 0)) + compensation)
				_increment_stat("diamondsFound", compensation, false)
				reward["converted_from_skin"] = skin_id
				reward["type"] = "diamonds"
				reward["amount"] = compensation
				reward["duplicate_skin"] = true
				return "Duplicate skin converted to +%s diamonds" % compensation
			unlock_skin(skin_id)
			reward["new_skin"] = true
			reward["rarity"] = _skin_rarity_from_id(skin_id)
			return "Skin unlocked"
		"upgrade", "run_upgrade", "upgrade_unlock":
			var upgrade_id := String(reward.get("upgrade_id", reward.get("upgradeId", reward.get("id", ""))))
			if unlock_upgrade(upgrade_id):
				reward["new_upgrade"] = true
				return "Upgrade unlocked"
			return "Upgrade already unlocked"
		"chest":
			var chest_type := String(reward.get("chest_type", reward.get("chestType", "common")))
			add_inventory_item("chest_%s" % chest_type, "chest", "Chest %s" % chest_type.capitalize(), chest_type, amount)
			return "+%s %s chest" % [amount, chest_type]
	if save_after:
		save_game()
	return "Reward"


func add_inventory_item(id: String, item_type: String, label: String, icon: String, amount: int) -> void:
	var inventory: Dictionary = data.get("inventory", {})
	var item: Dictionary = inventory.get(id, { "id": id, "type": item_type, "label": label, "icon": icon, "amount": 0 })
	item["amount"] = int(item.get("amount", 0)) + amount
	inventory[id] = item
	data["inventory"] = inventory


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
			result["reward"] = { "type": "keys", "amount": 6 }
			result["text"] = "+6 keys"
		"legendary_keys_pack":
			if not spend_diamonds(180):
				return { "ok": false, "reason": "diamonds" }
			data["legendary_keys"] = int(data.get("legendary_keys", 0)) + 2
			result["reward"] = { "type": "legendary_keys", "amount": 2 }
			result["text"] = "+2 legendary keys"
		"ad_gems":
			data["diamonds"] = int(data.get("diamonds", 0)) + 12
			result["reward"] = { "type": "diamonds", "amount": 12 }
			result["text"] = "+12 diamonds"
		"ad_coins":
			data["coins"] = int(data.get("coins", 0)) + 300
			result["reward"] = { "type": "coins", "amount": 300 }
			result["text"] = "+300 coins"
		"ad_key":
			data["keys"] = int(data.get("keys", 0)) + 1
			result["reward"] = { "type": "keys", "amount": 1 }
			result["text"] = "+1 key"
		"ad_chest":
			add_inventory_item("chest_common", "chest", "Common Chest", "common", 1)
			result["reward"] = { "type": "chest", "chest_type": "common", "amount": 1 }
			result["text"] = "+1 common chest"
		_:
			data["diamonds"] = int(data.get("diamonds", 0)) + 10
			result["reward"] = { "type": "diamonds", "amount": 10 }
			result["text"] = "Mock purchase +10 diamonds"
	_increment_stat("storePurchases", 1, false)
	_progress_missions("storePurchases", 1)
	_update_achievements(false)
	data["last_reward_text"] = String(result["text"])
	save_game()
	return result


func get_weekly_event() -> Dictionary:
	var now := TimeManager.get_now_timestamp()
	var week_index := floori(float(now) / float(7 * 86400))
	var starts_at := week_index * 7 * 86400
	var ends_at := starts_at + 7 * 86400
	var event_id := "codex_neon_week_%s" % week_index
	var event_state := _weekly_event_state(event_id)
	var tasks: Array[Dictionary] = [
		{ "id": "phases_10", "title": "Complete 10 fases", "desc": "Avance nas fases normais durante a semana Codex.", "metric": "phaseWins", "target": 10, "reward": { "type": "coins", "amount": 900 }, "icon": "event", "tone": "#00f0ff" },
		{ "id": "infinite_120", "title": "Sobreviva 2 minutos no Infinito", "desc": "Bata 120 segundos no Modo Infinito.", "metric": "bestInfiniteSeconds", "target": 120, "reward": { "type": "diamonds", "amount": 45 }, "icon": "gem", "tone": "#00ff88" },
		{ "id": "league_2", "title": "Vença 2 lutas da Liga Neon", "desc": "Ganhe lutas de ranking nesta semana.", "metric": "leagueWins", "target": 2, "reward": { "type": "chest", "chest_type": "rare", "amount": 1 }, "icon": "league", "tone": "#ffd700" },
	]
	for i in range(tasks.size()):
		var task: Dictionary = tasks[i]
		var progress := _event_metric_value(String(task.get("metric", "")))
		task["progress"] = progress
		task["completed"] = progress >= int(task.get("target", 1))
		task["claimed"] = Array(event_state.get("claimed", [])).has(String(task.get("id", "")))
		tasks[i] = task
	var completed_count := 0
	for task in tasks:
		if bool(task.get("completed", false)):
			completed_count += 1
	var final_claimed := Array(event_state.get("claimed", [])).has("final_skin")
	return {
		"id": event_id,
		"base_id": "codex_neon_week",
		"title": "Evento Codex Neon",
		"desc": "Evento semanal de fases, infinito e Liga Neon. Dura uma semana e fica na aba Eventos.",
		"starts_at": starts_at,
		"ends_at": ends_at,
		"seconds_remaining": max(0, ends_at - now),
		"tasks": tasks,
		"final": {
			"id": "final_skin",
			"title": "Recompensa final",
			"desc": "Conclua os 3 objetivos para liberar uma skin especial.",
			"progress": completed_count,
			"target": tasks.size(),
			"completed": completed_count >= tasks.size(),
			"claimed": final_claimed,
			"reward": { "type": "skin", "skin_id": "infinite_vortex_mythic", "amount": 1 },
			"icon": "skins",
			"tone": "#ff00aa",
		},
	}


func claim_weekly_event_reward(reward_id: String) -> Dictionary:
	var event := get_weekly_event()
	var event_id := String(event.get("id", ""))
	var state := _weekly_event_state(event_id)
	var claimed: Array = state.get("claimed", [])
	if claimed.has(reward_id):
		return { "ok": false, "reason": "already_claimed" }
	var reward: Dictionary = {}
	var ready := false
	if reward_id == "final_skin":
		var final: Dictionary = event.get("final", {})
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
	var coins: int = max(25, int(summary.get("coins", 0)) + rings_value * 8 + seconds * 2)
	var xp: int = max(20, int(summary.get("xp", 0)) + rings_value * 4 + seconds)
	data["coins"] = int(data.get("coins", 0)) + coins
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
	stats["rings_destroyed"] = int(stats.get("rings_destroyed", 0)) + rings_value
	stats["ringsDestroyed"] = int(stats.get("ringsDestroyed", 0)) + rings_value
	stats["runCoins"] = int(stats.get("runCoins", 0)) + coins
	data["stats"] = stats
	_progress_missions("runsPlayed", 1)
	_progress_missions("ringsDestroyed", rings_value)
	_progress_missions("runCoins", coins)
	_update_achievements(false)
	save_game()
	return { "coins": coins, "xp": xp, "completed": completed, "reward_available": completed and not bool(day_state.get("claimed", false)) }


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


func _weekly_event_state(event_id: String) -> Dictionary:
	var events: Dictionary = data.get("events", {})
	var state: Dictionary = events.get(event_id, {})
	if state.is_empty():
		state = { "claimed": [] }
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
		parts.append("+%s moedas" % coins)
	if xp > 0:
		add_profile_xp(xp)
		parts.append("+%s XP" % xp)
	if diamonds > 0:
		data["diamonds"] = int(data.get("diamonds", 0)) + diamonds
		_increment_stat("diamondsFound", diamonds, false)
		parts.append("+%s diamantes" % diamonds)
	if keys > 0:
		data["keys"] = int(data.get("keys", 0)) + keys
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
	return int(stats.get(metric, 0))


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
	var coins_bonus: int = int(summary.get("coins", 0)) + (int(reward.get("amount", 0)) if String(reward.get("type", "")) == "coins" else 0)
	var run_upgrade_levels: Dictionary = summary.get("run_upgrade_levels", {})
	var xp_bonus: int = maxi(30, int(summary.get("xp", 0)) + int(definition.get("xp", 60)) + int(run_upgrade_levels.get("bossHunter", 0)) * 20)
	var diamonds_bonus := 0
	if coins_bonus > 0:
		data["coins"] = int(data.get("coins", 0)) + coins_bonus
	if String(reward.get("type", "")) != "coins":
		apply_reward(reward)
	if result == "win":
		diamonds_bonus = int(definition.get("diamonds", 0))
		if diamonds_bonus > 0:
			data["diamonds"] = int(data.get("diamonds", 0)) + diamonds_bonus
			_increment_stat("diamondsFound", diamonds_bonus, false)
	add_profile_xp(xp_bonus)
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
	stats["runCoins"] = int(stats.get("runCoins", 0)) + coins_bonus
	stats["runUpgrades"] = int(stats.get("runUpgrades", 0)) + int(summary.get("run_upgrades", 0))
	stats["diamondsFound"] = int(stats.get("diamondsFound", 0)) + diamonds_bonus
	stats["diamonds_found"] = int(stats.get("diamonds_found", 0)) + diamonds_bonus
	data["stats"] = stats
	_progress_missions("ringsDestroyed", int(summary.get("rings", 0)))
	_progress_missions("runCoins", coins_bonus)
	_update_achievements(false)
	save_game()
	return {
		"coins": coins_bonus,
		"xp": xp_bonus,
		"diamonds": diamonds_bonus,
		"reward": reward,
		"boss_level": level_id,
	}


func _boss_level_index(level_id: String) -> int:
	var levels := boss_level_definitions()
	for i in range(levels.size()):
		if String(Dictionary(levels[i]).get("id", "")) == level_id:
			return i
	return 0


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
	var rare_count := 0
	var epic_count := 0
	var legendary_count := 0
	for skin_id in Array(data.get("unlocked_skins", [])):
		match _skin_rarity_from_id(String(skin_id)):
			"rare":
				rare_count += 1
			"epic":
				epic_count += 1
			"legendary", "mythic", "ultimate":
				legendary_count += 1
	stats["skinsUnlocked"] = Array(data.get("unlocked_skins", [])).size()
	stats["skins_unlocked"] = Array(data.get("unlocked_skins", [])).size()
	stats["rareSkinsUnlocked"] = rare_count
	stats["epicSkinsUnlocked"] = epic_count
	stats["legendarySkinsUnlocked"] = legendary_count
	data["stats"] = stats


func _skin_rarity_from_id(id: String) -> String:
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


func _update_achievements(save_after := true) -> void:
	var achievements: Dictionary = data.get("achievements", {})
	var stats: Dictionary = data.get("stats", {})
	stats["skinsUnlocked"] = Array(data.get("unlocked_skins", [])).size()
	_update_skin_collection_stats()
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


func add_coins(amount: int) -> void:
	data["coins"] = max(0, int(data.get("coins", 0)) + amount)
	save_game()


func spend_coins(amount: int) -> bool:
	if int(data.get("coins", 0)) < amount:
		return false
	add_coins(-amount)
	return true


func add_diamonds(amount: int) -> void:
	data["diamonds"] = max(0, int(data.get("diamonds", 0)) + amount)
	save_game()


func spend_diamonds(amount: int) -> bool:
	if int(data.get("diamonds", 0)) < amount:
		return false
	add_diamonds(-amount)
	return true


func add_keys(amount: int) -> void:
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


func add_profile_xp(amount: int) -> void:
	data["profile_xp"] = max(0, int(data.get("profile_xp", 0)) + amount)
	data["xp"] = max(0, int(data.get("xp", 0)) + amount)
	while int(data.get("profile_xp", 0)) >= _xp_needed_for_level(int(data.get("level", 1))):
		data["profile_xp"] = int(data.get("profile_xp", 0)) - _xp_needed_for_level(int(data.get("level", 1)))
		data["level"] = int(data.get("level", 1)) + 1
	refresh_unlocks(false)
	save_game()


func record_phase_complete(phase: int, coins: int, xp: int, rings_destroyed: int, perfect_escapes: int, diamonds: int = 0, best_combo: int = 0, criticals: int = 0, skin_effects: int = 0, run_upgrades: int = 0) -> void:
	var phase_config := LevelData.get_phase_config(phase)
	var bonus_coins := int(phase_config.get("reward_coins", 0))
	var bonus_xp := int(phase_config.get("reward_xp", 0))
	var bonus_diamonds := diamonds
	if randf() < float(phase_config.get("diamond_chance", 0.0)):
		bonus_diamonds += 1
	var bonus_keys := 0
	if randf() < float(phase_config.get("key_chance", 0.0)):
		bonus_keys = 1
	var chest_rewarded := false
	if randf() < float(phase_config.get("chest_chance", 0.0)):
		chest_rewarded = true
		var chest_type := _phase_chest_type(phase)
		add_inventory_item("chest_%s" % chest_type, "chest", "Chest %s" % chest_type.capitalize(), chest_type, 1)
	data["coins"] = max(0, int(data.get("coins", 0)) + coins + bonus_coins)
	data["diamonds"] = max(0, int(data.get("diamonds", 0)) + bonus_diamonds)
	data["keys"] = max(0, int(data.get("keys", 0)) + bonus_keys)
	data["profile_xp"] = max(0, int(data.get("profile_xp", 0)) + xp + bonus_xp)
	data["xp"] = max(0, int(data.get("xp", 0)) + xp + bonus_xp)
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
	if chest_rewarded:
		stats["chestsEarned"] = int(stats.get("chestsEarned", 0)) + 1
	stats["bestCombo"] = max(int(stats.get("bestCombo", 0)), best_combo)
	stats["criticals"] = int(stats.get("criticals", 0)) + criticals
	stats["skinEffects"] = int(stats.get("skinEffects", 0)) + skin_effects
	stats["runUpgrades"] = int(stats.get("runUpgrades", 0)) + run_upgrades
	stats["noReviveWins"] = int(stats.get("noReviveWins", 0)) + 1
	stats["highest_phase"] = max(int(stats.get("highest_phase", 1)), min(MAX_PHASE, phase + 1))
	stats["highestPhase"] = max(int(stats.get("highestPhase", 1)), min(MAX_PHASE, phase + 1))
	data["current_phase"] = max(int(data.get("current_phase", 1)), min(MAX_PHASE, phase + 1))
	data["stats"] = stats
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
	refresh_unlocks(false)
	_update_achievements(false)
	save_game()


func record_infinite_run(summary: Dictionary) -> void:
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
	data["coins"] = max(0, int(data.get("coins", 0)) + coins)
	data["diamonds"] = max(0, int(data.get("diamonds", 0)) + diamonds)
	data["profile_xp"] = max(0, int(data.get("profile_xp", 0)) + xp)
	data["xp"] = max(0, int(data.get("xp", 0)) + xp)
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
	stats["bestCombo"] = max(int(stats.get("bestCombo", 0)), combo_value)
	stats["best_infinite_seconds"] = max(int(stats.get("best_infinite_seconds", 0)), seconds)
	stats["bestInfiniteSeconds"] = max(int(stats.get("bestInfiniteSeconds", 0)), seconds)
	stats["best_infinite_rings"] = max(int(stats.get("best_infinite_rings", 0)), rings_value)
	stats["bestInfiniteRings"] = max(int(stats.get("bestInfiniteRings", 0)), rings_value)
	stats["best_infinite_score"] = max(int(stats.get("best_infinite_score", 0)), score)
	stats["bestInfiniteScore"] = max(int(stats.get("bestInfiniteScore", 0)), score)
	stats["infiniteBestLevel"] = max(int(stats.get("infiniteBestLevel", 0)), run_level_value)
	stats["criticals"] = int(stats.get("criticals", 0)) + critical_value
	stats["skinEffects"] = int(stats.get("skinEffects", 0)) + skin_effect_value
	stats["runUpgrades"] = int(stats.get("runUpgrades", 0)) + run_upgrade_value
	data["stats"] = stats
	_progress_missions("runsPlayed", 1)
	_progress_missions("ringsDestroyed", rings_value)
	_progress_missions("runCoins", coins)
	_progress_missions("bestCombo", combo_value)
	_progress_missions("criticals", critical_value)
	_progress_missions("skinEffects", skin_effect_value)
	_progress_missions("runUpgrades", run_upgrade_value)
	refresh_unlocks(false)
	_update_achievements(false)
	save_game()


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
		int(summary.get("run_upgrades", 0))
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
	add_profile_xp(xp)
	var stats: Dictionary = data.get("stats", {})
	stats["runsPlayed"] = int(stats.get("runsPlayed", 0)) + 1
	stats["runs_played"] = int(stats.get("runs_played", 0)) + 1
	stats["ringsDestroyed"] = int(stats.get("ringsDestroyed", 0)) + int(summary.get("rings", 0))
	stats["rings_destroyed"] = int(stats.get("rings_destroyed", 0)) + int(summary.get("rings", 0))
	stats["runCoins"] = int(stats.get("runCoins", 0)) + coins
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
	_progress_missions("runsPlayed", 1)
	_progress_missions("ringsDestroyed", int(summary.get("rings", 0)))
	_progress_missions("runCoins", coins)
	_progress_missions("bestCombo", int(summary.get("best_combo", 0)))
	_progress_missions("criticals", int(summary.get("criticals", 0)))
	_progress_missions("skinEffects", int(summary.get("skin_effects", 0)))
	_progress_missions("runUpgrades", int(summary.get("run_upgrades", 0)))
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

	var coins: int = max(10, int(summary.get("coins", 0)) + (360 if result == "win" else 95 if result == "loss" else 25))
	var xp: int = max(8, int(summary.get("xp", 0)) + (180 if result == "win" else 65 if result == "loss" else 12))
	var diamonds: int = max(0, int(summary.get("diamonds", 0)))
	if result == "win" and randf() < 0.35:
		diamonds += 4
	if result == "win" and randf() < 0.08:
		add_inventory_item("chest_rare", "chest", "Chest Rare", "rare", 1)
	data["coins"] = int(data.get("coins", 0)) + coins
	data["diamonds"] = int(data.get("diamonds", 0)) + diamonds
	add_profile_xp(xp)

	var stats: Dictionary = data.get("stats", {})
	stats["leagueMatches"] = int(stats.get("leagueMatches", 0)) + 1
	stats["leagueWins"] = int(stats.get("leagueWins", 0)) + (1 if result == "win" else 0)
	stats["leagueLosses"] = int(stats.get("leagueLosses", 0)) + (1 if result == "loss" else 0)
	stats["leagueQuits"] = int(stats.get("leagueQuits", 0)) + (1 if result == "quit" else 0)
	stats["leagueTrophies"] = trophies
	stats["leagueTrophiesTotal"] = int(stats.get("leagueTrophiesTotal", 0)) + max(0, trophy_delta)
	stats["leagueWinStreak"] = max(int(stats.get("leagueWinStreak", 0)), int(league.get("best_streak", 0)))
	stats["leagueRankIndex"] = max(int(stats.get("leagueRankIndex", 0)), _league_rank_index(rank_id))
	stats["ringsDestroyed"] = int(stats.get("ringsDestroyed", 0)) + rings_value
	stats["rings_destroyed"] = int(stats.get("rings_destroyed", 0)) + rings_value
	stats["runCoins"] = int(stats.get("runCoins", 0)) + coins
	stats["diamondsFound"] = int(stats.get("diamondsFound", 0)) + diamonds
	stats["diamonds_found"] = int(stats.get("diamonds_found", 0)) + diamonds
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
	_progress_missions("ringsDestroyed", rings_value)
	_progress_missions("runCoins", coins)
	if not promotion_skin_id.is_empty():
		_update_skin_collection_stats()
	_update_achievements(false)
	save_game()
	return { "coins": coins, "xp": xp, "diamonds": diamonds, "trophy_delta": trophy_delta, "trophies": trophies, "rank": rank, "promotion_skin": promotion_skin_id }


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


func _xp_needed_for_level(player_level: int) -> int:
	return floori(130.0 * pow(max(1, player_level), 1.50))


func _phase_chest_type(phase: int) -> String:
	if phase >= 90 and randf() < 0.12:
		return "legendary"
	if phase >= 60 and randf() < 0.22:
		return "epic"
	if phase >= 20 and randf() < 0.42:
		return "rare"
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

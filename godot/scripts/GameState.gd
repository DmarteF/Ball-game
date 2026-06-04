extends Node

signal changed

const MAX_PHASE := 100
const TARGET_ACHIEVEMENT_COUNT := 100

const PERMANENT_UPGRADE_DEFS := {
	"baseDamage": { "base_cost": 90, "max": 36, "phase": 1, "level": 1 },
	"baseSpeed": { "base_cost": 115, "max": 24, "phase": 1, "level": 1 },
	"coinMultiplier": { "base_cost": 180, "max": 30, "phase": 1, "level": 1 },
	"critChance": { "base_cost": 145, "max": 24, "phase": 1, "level": 1 },
	"xpBoost": { "base_cost": 175, "max": 30, "phase": 3, "level": 3 },
	"perfectChance": { "base_cost": 420, "max": 15, "phase": 5, "level": 5 },
	"slowRings": { "base_cost": 560, "max": 14, "phase": 8, "level": 9 },
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


func get_achievements() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for achievement in ACHIEVEMENTS:
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
	{ "type": "coins", "amount": 120 },
	{ "type": "diamonds", "amount": 20 },
	{ "type": "keys", "amount": 1 },
	{ "type": "chest", "chest_type": "common", "amount": 1 },
	{ "type": "chest", "chest_type": "rare", "amount": 1 },
	{ "type": "diamonds", "amount": 75 },
	{ "type": "chest", "chest_type": "epic", "amount": 1 },
]

const WHEEL_REWARDS := [
	{ "type": "coins", "amount": 180 },
	{ "type": "coins", "amount": 420 },
	{ "type": "diamonds", "amount": 6 },
	{ "type": "diamonds", "amount": 14 },
	{ "type": "keys", "amount": 1 },
	{ "type": "chest", "chest_type": "common", "amount": 1 },
	{ "type": "chest", "chest_type": "rare", "amount": 1 },
	{ "type": "xp", "amount": 120 },
	{ "type": "chest", "chest_type": "epic", "amount": 1 },
]

const DAILY_MISSION_DEFS := [
	{ "id": "runs_3", "title": "Play 3 runs", "title_pt": "Jogar 3 partidas", "metric": "runsPlayed", "target": 3, "reward": { "type": "xp", "amount": 70 } },
	{ "id": "win_1", "title": "Win 1 phase", "title_pt": "Vencer 1 fase", "metric": "phaseWins", "target": 1, "reward": { "type": "diamonds", "amount": 8 } },
	{ "id": "rings_50", "title": "Destroy 50 rings", "title_pt": "Destruir 50 aneis", "metric": "ringsDestroyed", "target": 50, "reward": { "type": "coins", "amount": 260 } },
	{ "id": "perfect_3", "title": "Make 3 Perfect Escapes", "title_pt": "Fazer 3 Perfect Escapes", "metric": "perfectEscapes", "target": 3, "reward": { "type": "diamonds", "amount": 5 } },
	{ "id": "store_buy", "title": "Buy or claim in the shop", "title_pt": "Comprar ou resgatar na loja", "metric": "storePurchases", "target": 1, "reward": { "type": "diamonds", "amount": 6 } },
	{ "id": "wheel_spin", "title": "Spin the wheel", "title_pt": "Girar a roleta", "metric": "wheelSpins", "target": 1, "reward": { "type": "coins", "amount": 240 } },
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
		"unlocked_upgrades": ["baseDamage", "baseSpeed", "coinMultiplier", "critChance", "damage", "speed", "coinBoost", "critical", "xpBoost", "perfectChance"],
		"explicit_unlocked_run_upgrades": [],
		"permanent_upgrades": {},
		"settings": {
			"audio_muted": false,
			"music_muted": false,
			"sfx_muted": false,
			"master_muted": false,
			"language": "en",
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
			"daily_rewards_collected": 0,
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
			"leagueSilverReached": 0,
			"leagueDiamondReached": 0,
			"leagueLegendaryReached": 0,
		},
	}


func load_game() -> void:
	var loaded := SaveManager.load_save()
	data = _merge_defaults(default_save(), loaded)
	_migrate_legacy_settings()
	_ensure_live_systems()
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


func refresh_unlocks(emit_signal := true) -> void:
	var unlocked: Array = data.get("unlocked_upgrades", [])
	unlocked = _clean_released_upgrade_unlocks(unlocked)
	var max_phase := int(data.get("max_unlocked_phase", data.get("current_phase", 1)))
	var profile_level := int(data.get("level", 1))
	for id in PERMANENT_UPGRADE_DEFS.keys():
		if _meets_unlock(PERMANENT_UPGRADE_DEFS[id], max_phase, profile_level) and not unlocked.has(id):
			unlocked.append(id)
	var explicit_temp_ids: Array = data.get("explicit_unlocked_run_upgrades", [])
	for id in MainPortData.auto_run_upgrade_ids():
		if MainPortData.is_released_run_upgrade(String(id)) and not unlocked.has(id):
			unlocked.append(id)
	for id in explicit_temp_ids:
		if MainPortData.is_released_run_upgrade(String(id)) and not unlocked.has(id):
			unlocked.append(id)
	data["unlocked_upgrades"] = unlocked

	var skins: Array = data.get("unlocked_skins", [])
	for id in SKIN_UNLOCK_MILESTONES.keys():
		if _meets_unlock(SKIN_UNLOCK_MILESTONES[id], max_phase, profile_level) and not skins.has(id):
			skins.append(id)
	data["unlocked_skins"] = skins
	data["stats"]["skins_unlocked"] = skins.size()
	_update_skin_collection_stats()
	if not skins.has(String(data.get("equipped_skin", "neon_blue"))):
		data["equipped_skin"] = "neon_blue"
	if emit_signal:
		save_game()


func _clean_released_upgrade_unlocks(unlocked: Array) -> Array:
	var released_temp_ids := MainPortData.released_run_upgrade_ids()
	var auto_temp_ids := MainPortData.auto_run_upgrade_ids()
	var explicit_temp_ids: Array = data.get("explicit_unlocked_run_upgrades", [])
	var cleaned: Array = []
	for value in unlocked:
		var id := String(value)
		if cleaned.has(id):
			continue
		if PERMANENT_UPGRADE_DEFS.has(id):
			cleaned.append(id)
		elif released_temp_ids.has(id) and explicit_temp_ids.has(id):
			cleaned.append(id)
		elif released_temp_ids.has(id) and auto_temp_ids.has(id):
			cleaned.append(id)
	return cleaned


func _ensure_live_systems() -> void:
	var day_key := _day_key()
	if String(data.get("wheel", {}).get("day_key", "")) != day_key:
		data["wheel"] = { "day_key": day_key, "free_used": false, "ad_spins_used": 0, "last_reward": {} }
	if String(data.get("daily_missions", {}).get("day_key", "")) != day_key:
		data["daily_missions"] = _create_daily_missions(day_key)
	_ensure_league_season()
	var achievements: Dictionary = data.get("achievements", {})
	for achievement in get_achievements():
		var id := String(achievement["id"])
		if not achievements.has(id):
			achievements[id] = { "progress": 0, "completed": false, "claimed": false }
	data["achievements"] = achievements
	_update_achievements(false)


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
	var definition: Dictionary = PERMANENT_UPGRADE_DEFS.get(id, {})
	if definition.is_empty():
		return 0
	var level := int(data.get("permanent_upgrades", {}).get(id, 0))
	return floori(float(definition["base_cost"]) * pow(1.5, level))


func get_upgrade_max_level(id: String) -> int:
	return int(PERMANENT_UPGRADE_DEFS.get(id, {}).get("max", 10))


func is_upgrade_unlocked(id: String) -> bool:
	return Array(data.get("unlocked_upgrades", [])).has(id)


func purchase_permanent_upgrade(id: String) -> Dictionary:
	refresh_unlocks(false)
	if not PERMANENT_UPGRADE_DEFS.has(id):
		return { "ok": false, "reason": "invalid" }
	if not is_upgrade_unlocked(id):
		return { "ok": false, "reason": "locked" }
	var upgrades: Dictionary = data.get("permanent_upgrades", {})
	var level := int(upgrades.get(id, 0))
	var max_level := get_upgrade_max_level(id)
	if level >= max_level:
		return { "ok": false, "reason": "max" }
	var cost := get_upgrade_cost(id)
	if int(data.get("coins", 0)) < cost:
		return { "ok": false, "reason": "coins", "cost": cost }
	data["coins"] = max(0, int(data.get("coins", 0)) - cost)
	upgrades[id] = level + 1
	data["permanent_upgrades"] = upgrades
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
	if id.is_empty():
		return false
	if not MainPortData.is_released_run_upgrade(id) and not PERMANENT_UPGRADE_DEFS.has(id):
		return false
	if MainPortData.is_released_run_upgrade(id):
		var explicit: Array = data.get("explicit_unlocked_run_upgrades", [])
		if not explicit.has(id):
			explicit.append(id)
			data["explicit_unlocked_run_upgrades"] = explicit
	var unlocked: Array = data.get("unlocked_upgrades", [])
	if unlocked.has(id):
		return false
	unlocked.append(id)
	data["unlocked_upgrades"] = unlocked
	save_game()
	return true


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
		return { "type": "skin", "skin_id": _rotating_skin("legendary") } if randf() < 0.35 else { "type": "diamonds", "amount": 95 }
	if chest_id.contains("epic"):
		return { "type": "skin", "skin_id": _rotating_skin("rare") } if randf() < 0.22 else { "type": "diamonds", "amount": 45 }
	if chest_id.contains("rare"):
		return { "type": "skin", "skin_id": _rotating_skin("rare") } if randf() < 0.14 else { "type": "keys", "amount": 1 }
	return { "type": "skin", "skin_id": _rotating_skin("common") } if randf() < 0.10 else { "type": "coins", "amount": 220 }


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
	rewards.append({ "type": "skin", "skin_id": _rotating_skin("legendary"), "wheel_slot": "monthly_legendary" })
	return rewards


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


func _weekly_event_state(event_id: String) -> Dictionary:
	var events: Dictionary = data.get("events", {})
	var state: Dictionary = events.get(event_id, {})
	if state.is_empty():
		state = { "claimed": [] }
		events[event_id] = state
		data["events"] = events
	return state


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
	data["coins"] = max(0, int(data.get("coins", 0)) + coins)
	data["diamonds"] = max(0, int(data.get("diamonds", 0)) + diamonds)
	data["profile_xp"] = max(0, int(data.get("profile_xp", 0)) + xp)
	data["xp"] = max(0, int(data.get("xp", 0)) + xp)
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
	stats["diamonds_found"] = int(stats.get("diamonds_found", 0)) + diamonds
	stats["diamondsFound"] = int(stats.get("diamondsFound", 0)) + diamonds
	stats["runCoins"] = int(stats.get("runCoins", 0)) + coins
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
	_progress_missions("runCoins", coins)
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
	var base_delta := 36 if result == "win" else -18 if result == "loss" else -24
	var rings_value := int(summary.get("rings", 0))
	var seconds := int(summary.get("seconds", 0))
	var trophy_delta := base_delta
	if result == "win":
		trophy_delta += min(14, rings_value / 3) + min(6, seconds / 45)
	else:
		trophy_delta += min(8, rings_value / 8)
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

	var coins: int = max(10, int(summary.get("coins", 0)) + (180 if result == "win" else 65 if result == "loss" else 35))
	var xp: int = max(8, int(summary.get("xp", 0)) + (80 if result == "win" else 30 if result == "loss" else 16))
	var diamonds: int = max(0, int(summary.get("diamonds", 0)))
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
	if rank_id in ["diamond", "legendary", "ultimate"]:
		stats["leagueDiamondReached"] = 1
	if rank_id in ["legendary", "ultimate"]:
		stats["leagueLegendaryReached"] = 1
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
	return floori(150.0 * pow(max(1, player_level), 1.55))


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

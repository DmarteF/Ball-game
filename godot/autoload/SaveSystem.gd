extends Node

signal save_changed(save)

const SAVE_PATH = "user://neon_idle_escape_godot_save.json"

var save = {}

func _ready():
	load_game()

func default_save():
	return {
		"player_id": "player_%d" % Time.get_unix_time_from_system(),
		"nickname": "Player",
		"coins": 600,
		"gems": 60,
		"keys": 1,
		"legendary_keys": 0,
		"profile_level": 1,
		"profile_xp": 0,
		"current_phase": 1,
		"unlocked_phases": [1],
		"permanent_upgrades": {},
		"unlocked_upgrades": ["baseDamage", "baseSpeed", "coinMultiplier", "critChance", "damage", "speed", "coinBoost", "critical"],
		"equipped_skin": "neon_blue",
		"favorite_skin": "neon_blue",
		"unlocked_skins": ["neon_blue"],
		"skin_fragments": {},
		"skin_levels": {"neon_blue": 1},
		"inventory_chests": {"common": 0, "rare": 0, "epic": 0, "legendary": 0},
		"unlocked_effects": [],
		"settings": {"sound": true, "music": true, "haptics": true},
		"timed": {
			"last_seen_at": Time.get_unix_time_from_system(),
			"last_day_key": TimeSystem.day_key(),
			"last_week_key": TimeSystem.week_key(),
			"daily_reward_claimed_day": "",
			"wheel_day_key": TimeSystem.day_key(),
			"wheel_free_used": false,
			"wheel_ad_spins_used": 0,
			"event_week_key": TimeSystem.week_key(),
			"event_points": 0,
			"boss_day_key": TimeSystem.day_key(),
			"boss_attempts": 0,
			"pending_offline_reward": {"available": false, "coins": 0, "hours": 0.0}
		},
		"lifetime_stats": {
			"runs_played": 0,
			"rings_destroyed": 0,
			"perfect_escapes": 0,
			"diamonds_found": 0,
			"chests_opened": 0,
			"skins_unlocked": 1,
			"highest_phase": 1,
			"highest_run_level": 1,
			"phase_wins": 0,
			"run_coins": 0,
			"run_upgrades": 0,
			"criticals": 0,
			"skin_effects": 0,
			"best_combo": 0,
			"ads_watched": 0,
			"store_purchases": 0
		},
		"last_seen_at": Time.get_unix_time_from_system()
	}

func load_game():
	var loaded = {}
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var parsed = JSON.parse_string(file.get_as_text())
			if typeof(parsed) == TYPE_DICTIONARY:
				loaded = parsed
	save = normalize_save(loaded)
	_update_timed_on_load(int(save.get("last_seen_at", TimeSystem.now())))
	save_game()
	return save

func save_game():
	save.last_seen_at = TimeSystem.now()
	save.timed.last_seen_at = save.last_seen_at
	save.timed.last_day_key = TimeSystem.day_key()
	save.timed.last_week_key = TimeSystem.week_key()
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save, "\t"))
	AudioManager.set_settings(save.settings.get("sound", true), save.settings.get("music", true))
	save_changed.emit(save)

func normalize_save(raw):
	var base = default_save()
	var next = base.duplicate(true)
	if typeof(raw) == TYPE_DICTIONARY:
		for key in raw.keys():
			next[key] = raw[key]
	for key in base.keys():
		if not next.has(key) or typeof(next[key]) != typeof(base[key]):
			next[key] = base[key]
	for key in base.lifetime_stats.keys():
		if not next.lifetime_stats.has(key):
			next.lifetime_stats[key] = base.lifetime_stats[key]
	for key in base.settings.keys():
		if not next.settings.has(key):
			next.settings[key] = base.settings[key]
	for key in base.timed.keys():
		if not next.timed.has(key) or typeof(next.timed[key]) != typeof(base.timed[key]):
			next.timed[key] = base.timed[key]
	for key in base.timed.pending_offline_reward.keys():
		if not next.timed.pending_offline_reward.has(key):
			next.timed.pending_offline_reward[key] = base.timed.pending_offline_reward[key]
	for chest_id in ["common", "rare", "epic", "legendary"]:
		if not next.inventory_chests.has(chest_id):
			next.inventory_chests[chest_id] = 0
	if not ("neon_blue" in next.unlocked_skins):
		next.unlocked_skins.append("neon_blue")
	if not next.skin_levels.has("neon_blue"):
		next.skin_levels.neon_blue = 1
	if not (next.equipped_skin in next.unlocked_skins):
		next.equipped_skin = "neon_blue"
	next.unlocked_phases = _unique_ints([1] + next.unlocked_phases)
	next.unlocked_skins = _unique_strings(next.unlocked_skins)
	next.unlocked_effects = _unique_strings(next.unlocked_effects)
	next = _sync_unlocks(next)
	next.lifetime_stats.skins_unlocked = next.unlocked_skins.size()
	return next

func get_save():
	return save

func refresh():
	save = _sync_unlocks(save)
	save_game()

func set_setting(key, value):
	save.settings[key] = value
	save_game()

func add_resource(currency, amount):
	if not save.has(currency):
		return
	save[currency] = max(0, int(save.get(currency, 0)) + int(amount))
	save_game()

func get_timed_status():
	return {
		"day_key": TimeSystem.day_key(),
		"week_key": TimeSystem.week_key(),
		"daily_available": daily_reward_available(),
		"wheel_available": wheel_available(),
		"boss_available": int(save.timed.get("boss_attempts", 0)) < 3,
		"event_id": TimeSystem.event_id_for_week(),
		"boss_id": TimeSystem.boss_id_for_day(),
		"seconds_until_next_day": TimeSystem.seconds_until_next_day(),
		"offline": save.timed.pending_offline_reward.duplicate(true)
	}

func claim_offline_reward(double_reward = false):
	var pending = save.timed.pending_offline_reward
	if not bool(pending.get("available", false)):
		return {"ok": false, "message": "Nenhuma recompensa AFK disponivel."}
	var coins = int(pending.get("coins", 0))
	if double_reward:
		coins *= 2
		record_ad_use()
	save.coins += coins
	save.timed.pending_offline_reward = {"available": false, "coins": 0, "hours": 0.0}
	save_game()
	return {"ok": true, "coins": coins, "message": "+%d moedas AFK" % coins}

func daily_reward_available():
	return String(save.timed.get("daily_reward_claimed_day", "")) != TimeSystem.day_key()

func claim_daily_reward():
	if not daily_reward_available():
		return {"ok": false, "message": "Recompensa diaria ja coletada."}
	save.coins += 350
	save.gems += 18
	save.keys += 1
	save.timed.daily_reward_claimed_day = TimeSystem.day_key()
	save_game()
	return {"ok": true, "message": "+350 moedas, +18 diamantes, +1 chave", "coins": 350, "gems": 18, "keys": 1}

func wheel_available():
	_reset_daily_timers_if_needed()
	return not bool(save.timed.get("wheel_free_used", false)) or int(save.timed.get("wheel_ad_spins_used", 0)) < 2

func spin_wheel(use_ad = false):
	_reset_daily_timers_if_needed()
	if use_ad:
		if int(save.timed.get("wheel_ad_spins_used", 0)) >= 2:
			return {"ok": false, "message": "Giros com anuncio esgotados hoje."}
		record_ad_use()
		save.timed.wheel_ad_spins_used = int(save.timed.get("wheel_ad_spins_used", 0)) + 1
	else:
		if bool(save.timed.get("wheel_free_used", false)):
			return {"ok": false, "message": "Giro gratis ja usado hoje."}
		save.timed.wheel_free_used = true
	var rewards = [
		{"type": "coins", "amount": 180, "label": "+180 moedas"},
		{"type": "coins", "amount": 420, "label": "+420 moedas"},
		{"type": "gems", "amount": 6, "label": "+6 diamantes"},
		{"type": "gems", "amount": 14, "label": "+14 diamantes"},
		{"type": "key", "amount": 1, "label": "+1 chave"},
		{"type": "chest", "chest": "common", "amount": 1, "label": "+1 bau comum"},
		{"type": "chest", "chest": "rare", "amount": 1, "label": "+1 bau raro"},
		{"type": "fragments", "amount": 20, "label": "+20 fragmentos"},
		{"type": "profile_xp", "amount": 120, "label": "+120 XP"},
		{"type": "chest", "chest": "epic", "amount": 1, "label": "+1 bau epico"}
	]
	var reward = rewards[randi() % rewards.size()]
	match reward.type:
		"coins":
			save.coins += int(reward.amount)
		"gems":
			save.gems += int(reward.amount)
		"key":
			save.keys += int(reward.amount)
		"chest":
			add_chest(reward.chest, int(reward.amount))
			return {"ok": true, "reward": reward, "message": reward.label}
		"fragments":
			var skin_id = save.equipped_skin
			save.skin_fragments[skin_id] = int(save.skin_fragments.get(skin_id, 0)) + int(reward.amount)
		"profile_xp":
			_apply_profile_xp(int(reward.amount))
	save_game()
	return {"ok": true, "reward": reward, "message": reward.label}

func can_pay(currency, cost):
	return int(save.get(currency, 0)) >= int(cost)

func pay(currency, cost):
	if not can_pay(currency, cost):
		return false
	save[currency] = int(save.get(currency, 0)) - int(cost)
	save_game()
	return true

func purchase_permanent_upgrade(upgrade_id):
	var upgrade = GameData.get_permanent_upgrade(upgrade_id)
	if upgrade.is_empty():
		return {"ok": false, "message": "Upgrade inexistente."}
	if not GameData.is_permanent_upgrade_unlocked(upgrade_id, save):
		return {"ok": false, "message": "Upgrade bloqueado."}
	var level = int(save.permanent_upgrades.get(upgrade_id, 0))
	if level >= int(upgrade.max_level):
		return {"ok": false, "message": "Nivel maximo."}
	var cost = GameData.get_permanent_upgrade_cost(upgrade_id, level)
	var currency = upgrade.get("currency", "coins")
	if not can_pay(currency, cost):
		return {"ok": false, "message": "Saldo insuficiente."}
	save[currency] = int(save.get(currency, 0)) - cost
	save.permanent_upgrades[upgrade_id] = level + 1
	save.lifetime_stats.store_purchases += 1
	save = _sync_unlocks(save)
	save_game()
	return {"ok": true, "message": "Comprado.", "cost": cost}

func unlock_upgrade(upgrade_id):
	if upgrade_id == "":
		return
	if not (upgrade_id in save.unlocked_upgrades):
		save.unlocked_upgrades.append(upgrade_id)
	save_game()

func equip_skin(skin_id):
	if not (skin_id in save.unlocked_skins):
		return false
	save.equipped_skin = skin_id
	save.favorite_skin = skin_id
	save_game()
	return true

func unlock_skin(skin_id):
	if skin_id == "":
		return false
	if not (skin_id in save.unlocked_skins):
		save.unlocked_skins.append(skin_id)
		save.skin_levels[skin_id] = max(1, int(save.skin_levels.get(skin_id, 1)))
		save.lifetime_stats.skins_unlocked = save.unlocked_skins.size()
		save.equipped_skin = skin_id
		save.favorite_skin = skin_id
		save_game()
		return true
	return false

func get_skin_evolution_cost(skin_id):
	var skin = GameData.get_skin(skin_id)
	var base = int(skin.get("fragments_required", 10))
	var level = int(save.skin_levels.get(skin_id, 1))
	return int(base * pow(2.0, max(0, level - 1)))

func upgrade_skin_level(skin_id):
	if not (skin_id in save.unlocked_skins):
		return false
	var level = int(save.skin_levels.get(skin_id, 1))
	if level >= 5:
		return false
	var cost = get_skin_evolution_cost(skin_id)
	var current = int(save.skin_fragments.get(skin_id, 0))
	if current < cost:
		return false
	save.skin_fragments[skin_id] = current - cost
	save.skin_levels[skin_id] = level + 1
	save_game()
	return true

func craft_skin(skin_id):
	if skin_id in save.unlocked_skins:
		return false
	var skin = GameData.get_skin(skin_id)
	if skin.is_empty():
		return false
	var cost = int(skin.get("fragments_required", 10))
	var current = int(save.skin_fragments.get(skin_id, 0))
	if current < cost:
		return false
	save.skin_fragments[skin_id] = current - cost
	save.unlocked_skins.append(skin_id)
	save.skin_levels[skin_id] = 1
	save.equipped_skin = skin_id
	save.favorite_skin = skin_id
	save.lifetime_stats.skins_unlocked = save.unlocked_skins.size()
	save_game()
	return true

func add_chest(chest_id, amount = 1):
	if not save.inventory_chests.has(chest_id):
		save.inventory_chests[chest_id] = 0
	save.inventory_chests[chest_id] += int(amount)
	save_game()

func open_inventory_chest(chest_id):
	if int(save.inventory_chests.get(chest_id, 0)) <= 0:
		return {}
	save.inventory_chests[chest_id] -= 1
	var reward = GameData.roll_chest_reward(chest_id, save)
	grant_chest_reward(reward)
	return reward

func buy_and_open_chest(chest_id):
	var chest = GameData.get_chest(chest_id)
	var currency = chest.currency
	var cost = int(chest.cost)
	if not can_pay(currency, cost):
		return {"ok": false, "reward": {}, "message": "Saldo insuficiente."}
	save[currency] = int(save.get(currency, 0)) - cost
	var reward = GameData.roll_chest_reward(chest_id, save)
	grant_chest_reward(reward, false)
	save_game()
	return {"ok": true, "reward": reward, "message": "Aberto."}

func grant_chest_reward(reward, autosave = true):
	if reward.is_empty():
		return
	save.lifetime_stats.chests_opened += 1
	match reward.get("type", ""):
		"skin":
			unlock_skin(reward.get("skin_id", ""))
		"fragments":
			var skin_id = reward.get("skin_id", save.equipped_skin)
			save.skin_fragments[skin_id] = int(save.skin_fragments.get(skin_id, 0)) + int(reward.get("amount", 1))
		"key":
			if reward.get("rarity", "") in ["mythic", "ultimate"] or String(reward.get("label", "")).find("Lendaria") >= 0:
				save.legendary_keys += int(reward.get("amount", 1))
			else:
				save.keys += int(reward.get("amount", 1))
		"trail", "aura", "effect", "card":
			var label = reward.get("label", "Efeito")
			if not (label in save.unlocked_effects):
				save.unlocked_effects.append(label)
	save = _sync_unlocks(save)
	if autosave:
		save_game()

func record_ad_use():
	save.lifetime_stats.ads_watched += 1
	save_game()

func grant_ad_reward(kind):
	record_ad_use()
	if kind == "gems":
		save.gems += 12
	elif kind == "coins":
		save.coins += 300
	elif kind == "key":
		save.keys += 1
	elif kind == "chest":
		add_chest("common", 1)
		return
	save_game()

func record_run(summary, multiplier = 1):
	var won = bool(summary.get("won", false))
	var phase = int(summary.get("phase", save.current_phase))
	var run_coins = int(summary.get("coins", 0)) * int(multiplier)
	var gems = int(summary.get("gems", 0)) * int(multiplier)
	var best_combo = int(summary.get("best_combo", 0))
	var profile_xp = int(summary.get("profile_xp", GameData.get_run_profile_xp(summary.get("xp", 0), summary.get("rings_broken", 0), summary.get("perfect_escapes", 0), best_combo))) * int(multiplier)
	var global_coins = GameData.get_global_coins_from_run(run_coins, best_combo, won)
	save.coins += global_coins
	save.gems += gems
	save.timed.event_points = int(save.timed.get("event_points", 0)) + max(1, int(summary.get("rings_broken", 0)))
	_apply_profile_xp(profile_xp)
	save.lifetime_stats.runs_played += 1
	save.lifetime_stats.rings_destroyed += int(summary.get("rings_broken", 0))
	save.lifetime_stats.perfect_escapes += int(summary.get("perfect_escapes", 0))
	save.lifetime_stats.diamonds_found += gems
	save.lifetime_stats.highest_phase = max(int(save.lifetime_stats.highest_phase), phase)
	save.lifetime_stats.highest_run_level = max(int(save.lifetime_stats.highest_run_level), int(summary.get("run_level", 1)))
	save.lifetime_stats.run_coins += run_coins
	save.lifetime_stats.run_upgrades += int(summary.get("run_upgrades", 0))
	save.lifetime_stats.criticals += int(summary.get("criticals", 0))
	save.lifetime_stats.skin_effects += int(summary.get("skin_effects", 0))
	save.lifetime_stats.best_combo = max(int(save.lifetime_stats.best_combo), best_combo)
	var bonus_text = []
	if won:
		save.lifetime_stats.phase_wins += 1
		var next_phase = min(50, phase + 1)
		if not (next_phase in save.unlocked_phases):
			save.unlocked_phases.append(next_phase)
			bonus_text.append("Fase %d liberada" % next_phase)
		save.current_phase = max(int(save.current_phase), next_phase)
		if phase >= 50:
			unlock_skin("cosmic_champion")
			bonus_text.append("Campeao Cosmico liberado")
		var phase_config = GameData.get_phase_config(phase)
		if randf() < float(phase_config.key_chance):
			save.keys += 1
			bonus_text.append("+1 chave")
		if randf() < float(phase_config.chest_chance):
			add_chest("rare" if phase >= 12 else "common", 1)
			bonus_text.append("+1 bau")
	save.unlocked_phases.sort()
	save = _sync_unlocks(save)
	save_game()
	return {"coins": global_coins, "gems": gems, "profile_xp": profile_xp, "bonuses": bonus_text}

func _apply_profile_xp(amount):
	save.profile_xp += max(0, int(amount))
	while int(save.profile_xp) >= GameData.get_profile_xp_needed(int(save.profile_level)):
		save.profile_xp -= GameData.get_profile_xp_needed(int(save.profile_level))
		save.profile_level += 1
	save = _sync_unlocks(save)

func _update_timed_on_load(previous_seen_at):
	_reset_daily_timers_if_needed()
	var hours = min(12.0, TimeSystem.hours_since(previous_seen_at))
	var coins_per_hour = 42 + int(save.profile_level) * 6 + int(save.lifetime_stats.highest_phase) * 4
	var coins = int(floor(hours * coins_per_hour))
	if hours >= 0.12 and coins >= 25:
		save.timed.pending_offline_reward = {"available": true, "coins": coins, "hours": hours}

func _reset_daily_timers_if_needed():
	var today = TimeSystem.day_key()
	var week = TimeSystem.week_key()
	if String(save.timed.get("wheel_day_key", "")) != today:
		save.timed.wheel_day_key = today
		save.timed.wheel_free_used = false
		save.timed.wheel_ad_spins_used = 0
	if String(save.timed.get("boss_day_key", "")) != today:
		save.timed.boss_day_key = today
		save.timed.boss_attempts = 0
	if String(save.timed.get("event_week_key", "")) != week:
		save.timed.event_week_key = week
		save.timed.event_points = 0

func _sync_unlocks(next):
	var unlocked = _unique_strings(next.unlocked_upgrades)
	for starter in ["baseDamage", "baseSpeed", "coinMultiplier", "critChance", "damage", "speed", "coinBoost", "critical"]:
		if not (starter in unlocked):
			unlocked.append(starter)
	for upgrade in GameData.get_permanent_upgrades():
		if GameData.is_permanent_upgrade_unlocked(upgrade.id, next) and not (upgrade.id in unlocked):
			unlocked.append(upgrade.id)
		for run_id in GameData.PERMANENT_TO_RUN.get(upgrade.id, []):
			if upgrade.id in unlocked and not (run_id in unlocked):
				unlocked.append(run_id)
	next.unlocked_upgrades = unlocked
	return next

func _unique_strings(values):
	var seen = {}
	var output = []
	for value in values:
		var text = String(value)
		if text != "" and not seen.has(text):
			seen[text] = true
			output.append(text)
	return output

func _unique_ints(values):
	var seen = {}
	var output = []
	for value in values:
		var number = int(value)
		if number > 0 and not seen.has(number):
			seen[number] = true
			output.append(number)
	output.sort()
	return output

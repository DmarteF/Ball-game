extends Node

signal changed

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
		"coins": 600,
		"diamonds": 60,
		"keys": 1,
		"legendary_keys": 0,
		"xp": 0,
		"level": 1,
		"profile_xp": 0,
		"current_phase": 1,
		"max_unlocked_phase": 1,
		"unlocked_phases": [1],
		"unlocked_skins": ["neon_blue"],
		"equipped_skin": "neon_blue",
		"favorite_skin": "neon_blue",
		"skin_levels": { "neon_blue": 1 },
		"skin_fragments": {},
		"unlocked_upgrades": ["baseDamage", "baseSpeed", "coinMultiplier", "critChance"],
		"permanent_upgrades": {},
		"settings": {
			"audio_muted": false,
			"music_muted": false,
			"sfx_muted": false,
			"master_muted": false,
			"language": "pt",
		},
		"last_exit_at": now,
		"last_login_at": now,
		"last_daily_reward_at": 0,
		"daily_streak": 0,
		"pending_afk_rewards": {},
		"events": {},
		"boss": { "last_attempt_at": 0 },
		"stats": {
			"runs_played": 0,
			"rings_destroyed": 0,
			"perfect_escapes": 0,
			"diamonds_found": 0,
			"chests_opened": 0,
			"skins_unlocked": 1,
			"highest_phase": 1,
			"highest_run_level": 1,
			"boss_runs": 0,
			"boss_wins": 0,
			"boss_losses": 0,
			"daily_rewards_collected": 0,
		},
	}


func load_game() -> void:
	var loaded := SaveManager.load_save()
	data = _merge_defaults(default_save(), loaded)
	_migrate_legacy_settings()
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
	var skins: Array = data.get("unlocked_skins", [])
	if not skins.has(id):
		skins.append(id)
	data["unlocked_skins"] = skins
	data["stats"]["skins_unlocked"] = skins.size()
	save_game()


func equip_skin(id: String) -> bool:
	if not Array(data.get("unlocked_skins", [])).has(id):
		return false
	data["equipped_skin"] = id
	save_game()
	return true


func upgrade_permanent(id: String) -> void:
	var upgrades: Dictionary = data.get("permanent_upgrades", {})
	upgrades[id] = int(upgrades.get(id, 0)) + 1
	data["permanent_upgrades"] = upgrades
	save_game()


func unlock_level(level: int) -> void:
	var phases: Array = data.get("unlocked_phases", [])
	for phase in range(1, level + 1):
		if not phases.has(phase):
			phases.append(phase)
	data["unlocked_phases"] = phases
	data["max_unlocked_phase"] = max(int(data.get("max_unlocked_phase", 1)), level)
	data["stats"]["highest_phase"] = max(int(data["stats"].get("highest_phase", 1)), level)
	save_game()


func set_audio_muted(muted: bool) -> void:
	data["settings"]["audio_muted"] = muted
	data["settings"]["master_muted"] = muted
	data["settings"]["music_muted"] = muted
	data["settings"]["sfx_muted"] = muted
	save_game()


func set_language(language: String) -> void:
	data["settings"]["language"] = language
	save_game()


func get_setting(key: String, fallback = null):
	return data.get("settings", {}).get(key, fallback)


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

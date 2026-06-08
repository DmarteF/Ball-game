extends Node

const SECONDS_PER_DAY := 86400
const SECONDS_PER_WEEK := SECONDS_PER_DAY * 7
const WEEKLY_EVENT_CYCLE_SIZE := 26
const AFK_MAX_SECONDS := 8 * 60 * 60
const AFK_MIN_SECONDS := 5 * 60
const BOSS_COOLDOWN_SECONDS := 20 * 60 * 60
const NEON_PASS_SEASON_COUNT := 3
const NEON_PASS_WEEKS_PER_SEASON := 4
const NEON_PASS_LEVELS_PER_WEEK := 10


func get_now_timestamp() -> int:
	return int(Time.get_unix_time_from_system())


func get_month_key(timestamp: int = get_now_timestamp()) -> String:
	var date := Time.get_datetime_dict_from_unix_time(timestamp)
	return "%04d-%02d" % [int(date.year), int(date.month)]


func get_week_key(timestamp: int = get_now_timestamp()) -> String:
	var days := floori(float(timestamp) / float(SECONDS_PER_DAY))
	var week := floori(float(days) / 7.0)
	return "week_%s" % week


func get_week_index(timestamp: int = get_now_timestamp()) -> int:
	return floori(float(timestamp) / float(SECONDS_PER_WEEK))


func get_week_start_timestamp(timestamp: int = get_now_timestamp()) -> int:
	return get_week_index(timestamp) * SECONDS_PER_WEEK


func get_week_end_timestamp(timestamp: int = get_now_timestamp()) -> int:
	return get_week_start_timestamp(timestamp) + SECONDS_PER_WEEK


func get_weekly_event_index(timestamp: int = get_now_timestamp()) -> int:
	var override := int(GameState.data.get("debug_event_index_override", -1))
	if bool(GameState.get_setting("debug_enabled", false)) and override >= 0:
		return posmod(override, WEEKLY_EVENT_CYCLE_SIZE)
	return posmod(get_week_index(timestamp), WEEKLY_EVENT_CYCLE_SIZE)


func get_neon_pass_season_index(timestamp: int = get_now_timestamp()) -> int:
	var date := Time.get_datetime_dict_from_unix_time(timestamp)
	return posmod(int(date.month) - 1, NEON_PASS_SEASON_COUNT)


func get_neon_pass_week_index(timestamp: int = get_now_timestamp()) -> int:
	var date := Time.get_datetime_dict_from_unix_time(timestamp)
	return clampi(floori(float(int(date.day) - 1) / 7.0) + 1, 1, NEON_PASS_WEEKS_PER_SEASON)


func get_neon_pass_weekly_level_cap(timestamp: int = get_now_timestamp()) -> int:
	return min(NEON_PASS_WEEKS_PER_SEASON * NEON_PASS_LEVELS_PER_WEEK, get_neon_pass_week_index(timestamp) * NEON_PASS_LEVELS_PER_WEEK)


func get_seconds_until_neon_pass_week_end(timestamp: int = get_now_timestamp()) -> int:
	var date := Time.get_datetime_dict_from_unix_time(timestamp)
	var week_index: int = get_neon_pass_week_index(timestamp)
	if week_index >= NEON_PASS_WEEKS_PER_SEASON:
		return get_seconds_until_neon_pass_season_end(timestamp)
	var end_day: int = min(1 + week_index * 7, _days_in_month(int(date.year), int(date.month)) + 1)
	var end_timestamp := int(Time.get_unix_time_from_datetime_dict({
		"year": int(date.year),
		"month": int(date.month),
		"day": end_day,
		"hour": 0,
		"minute": 0,
		"second": 0,
	}))
	return max(0, end_timestamp - timestamp)


func get_seconds_until_neon_pass_season_end(timestamp: int = get_now_timestamp()) -> int:
	var date := Time.get_datetime_dict_from_unix_time(timestamp)
	var next_year := int(date.year)
	var next_month := int(date.month) + 1
	if next_month > 12:
		next_month = 1
		next_year += 1
	var end_timestamp := int(Time.get_unix_time_from_datetime_dict({
		"year": next_year,
		"month": next_month,
		"day": 1,
		"hour": 0,
		"minute": 0,
		"second": 0,
	}))
	return max(0, end_timestamp - timestamp)


func _days_in_month(year: int, month: int) -> int:
	match month:
		1, 3, 5, 7, 8, 10, 12:
			return 31
		4, 6, 9, 11:
			return 30
		2:
			var leap := year % 400 == 0 or (year % 4 == 0 and year % 100 != 0)
			return 29 if leap else 28
	return 30


func get_day_key(timestamp: int = get_now_timestamp()) -> String:
	var date := Time.get_datetime_dict_from_unix_time(timestamp)
	return "%04d-%02d-%02d" % [int(date.year), int(date.month), int(date.day)]


func get_seconds_until_next_day(timestamp: int = get_now_timestamp()) -> int:
	var date := Time.get_datetime_dict_from_unix_time(timestamp)
	var start_date := {
		"year": int(date.year),
		"month": int(date.month),
		"day": int(date.day),
		"hour": 0,
		"minute": 0,
		"second": 0,
	}
	var start := int(Time.get_unix_time_from_datetime_dict(start_date))
	return max(0, start + SECONDS_PER_DAY - timestamp)


func get_last_login_timestamp() -> int:
	return int(GameState.data.get("last_login_at", 0))


func get_last_exit_timestamp() -> int:
	return int(GameState.data.get("last_exit_at", 0))


func get_offline_seconds() -> int:
	var last_exit := get_last_exit_timestamp()
	if last_exit <= 0:
		return 0
	return max(0, get_now_timestamp() - last_exit)


func get_offline_minutes() -> float:
	return float(get_offline_seconds()) / 60.0


func get_offline_hours() -> float:
	return float(get_offline_seconds()) / 3600.0


func is_new_day(timestamp_a: int = get_last_login_timestamp(), timestamp_b: int = get_now_timestamp()) -> bool:
	if timestamp_a <= 0:
		return true
	var date_a := Time.get_datetime_dict_from_unix_time(timestamp_a)
	var date_b := Time.get_datetime_dict_from_unix_time(timestamp_b)
	return date_a.year != date_b.year or date_a.month != date_b.month or date_a.day != date_b.day


func can_claim_daily_reward() -> bool:
	return is_new_day(int(GameState.data.get("last_daily_reward_at", 0)), get_now_timestamp())


func mark_daily_reward_claimed() -> void:
	GameState.data["last_daily_reward_at"] = get_now_timestamp()
	GameState.save_game()


func get_daily_streak() -> int:
	return int(GameState.data.get("daily_streak", 0))


func update_daily_streak() -> int:
	var now := get_now_timestamp()
	var last_claim := int(GameState.data.get("last_daily_reward_at", 0))
	if last_claim <= 0:
		GameState.data["daily_streak"] = 1
		return 1
	var elapsed := now - last_claim
	if elapsed >= SECONDS_PER_DAY * 2:
		GameState.data["daily_streak"] = 1
	elif elapsed >= SECONDS_PER_DAY:
		GameState.data["daily_streak"] = min(7, int(GameState.data.get("daily_streak", 0)) + 1)
	return int(GameState.data.get("daily_streak", 0))


func calculate_afk_rewards(offline_seconds: int) -> Dictionary:
	if offline_seconds <= 0:
		return { "valid": false, "reason": "negative_time", "offline_seconds": max(0, offline_seconds) }
	var cap_seconds: int = _afk_cap_seconds()
	var capped_seconds: int = min(max(0, offline_seconds), cap_seconds)
	if capped_seconds < AFK_MIN_SECONDS:
		return { "valid": false, "reason": "too_short", "offline_seconds": capped_seconds, "minimum_seconds": AFK_MIN_SECONDS }
	var minutes: int = floori(float(capped_seconds) / 60.0)
	var hours: float = float(capped_seconds) / 3600.0
	var level: int = max(1, int(GameState.data.get("level", 1)))
	var max_phase: int = max(1, int(GameState.data.get("max_unlocked_phase", 1)))
	var coin_multiplier: float = _afk_coin_multiplier()
	var xp_multiplier: float = _afk_xp_multiplier()
	var coins_per_minute: float = 4.0 + float(level) * 0.85 + float(max_phase) * 0.22
	var xp_per_minute: float = 1.6 + float(level) * 0.34 + float(max_phase) * 0.09
	var coins: int = max(20, floori(float(minutes) * coins_per_minute * coin_multiplier))
	var xp: int = max(8, floori(float(minutes) * xp_per_minute * xp_multiplier))
	var pass_xp: int = max(0, floori(float(minutes) * (0.8 + float(level) * 0.08)))
	var diamonds := 0
	if capped_seconds >= 30 * 60 and _afk_roll("diamonds", min(0.28, 0.06 + hours * 0.035 + _afk_diamond_bonus())):
		diamonds = max(1, floori(hours * 1.35))
	var keys := 0
	if capped_seconds >= 2 * 60 * 60 and _afk_roll("keys", min(0.16, 0.035 + hours * 0.018)):
		keys = 1
	var chest_type := ""
	var chests := 0
	if capped_seconds >= 4 * 60 * 60 and _afk_roll("chest", min(0.12, 0.025 + hours * 0.012)):
		chest_type = "rare" if capped_seconds >= 7 * 60 * 60 and _afk_roll("rare_chest", 0.18) else "common"
		chests = 1
	return {
		"valid": true,
		"offline_seconds": max(0, offline_seconds),
		"capped_seconds": capped_seconds,
		"cap_seconds": cap_seconds,
		"max_reached": offline_seconds > cap_seconds,
		"minutes": minutes,
		"hours": snapped(hours, 0.1),
		"coins": coins,
		"xp": xp,
		"pass_xp": pass_xp,
		"diamonds": diamonds,
		"keys": keys,
		"chests": chests,
		"chest_type": chest_type,
		"coin_multiplier": coin_multiplier,
		"xp_multiplier": xp_multiplier,
	}


func get_pending_afk_rewards() -> Dictionary:
	return GameState.data.get("pending_afk_rewards", {})


func claim_afk_rewards() -> Dictionary:
	return GameState.claim_afk_rewards(false)


func _afk_cap_seconds() -> int:
	var cap := AFK_MAX_SECONDS
	var event_bonus: float = GameState.get_active_event_bonus_value("afk_limit") if GameState.has_method("get_active_event_bonus_value") else 0.0
	if event_bonus > 0.0:
		cap = min(12 * 60 * 60, floori(float(cap) * (1.0 + event_bonus)))
	return cap


func _afk_coin_multiplier() -> float:
	var multiplier := 1.0
	var coin_boost: Dictionary = GameState.get_upgrade_effect_value("coinBoost")
	if String(coin_boost.get("type", "")) in ["coins", "coinMultiplier"]:
		multiplier += min(0.75, float(coin_boost.get("value", 0.0)) * 0.18)
	var secret_magnet: Dictionary = GameState.get_upgrade_effect_value("secretMagnet")
	if String(secret_magnet.get("type", "")) in ["coins", "coinMultiplier"]:
		multiplier += min(0.35, float(secret_magnet.get("value", 0.0)) * 0.12)
	var skin_effect: Dictionary = GameState.get_skin_effect_value(String(GameState.data.get("equipped_skin", "neon_blue")))
	if String(skin_effect.get("type", skin_effect.get("effect", ""))) in ["coin_multiplier", "coin_on_hit", "coins"]:
		multiplier += min(0.30, float(skin_effect.get("value", 0.0)) * 0.12)
	var event_bonus: float = GameState.get_active_event_bonus_value("afk_rewards") if GameState.has_method("get_active_event_bonus_value") else 0.0
	if event_bonus <= 0.0:
		event_bonus = GameState.get_active_event_bonus_value("coins") if GameState.has_method("get_active_event_bonus_value") else 0.0
	multiplier += min(0.30, event_bonus)
	return clampf(multiplier, 1.0, 2.4)


func _afk_xp_multiplier() -> float:
	var multiplier := 1.0
	var xp_boost: Dictionary = GameState.get_upgrade_effect_value("xpBoost")
	if String(xp_boost.get("type", "")) == "xp":
		multiplier += min(0.65, float(xp_boost.get("value", 0.0)) * 0.18)
	var skin_effect: Dictionary = GameState.get_skin_effect_value(String(GameState.data.get("equipped_skin", "neon_blue")))
	if String(skin_effect.get("type", skin_effect.get("effect", ""))) in ["xp_multiplier", "xp"]:
		multiplier += min(0.28, float(skin_effect.get("value", 0.0)) * 0.12)
	var event_bonus: float = GameState.get_active_event_bonus_value("xp") if GameState.has_method("get_active_event_bonus_value") else 0.0
	multiplier += min(0.25, event_bonus)
	return clampf(multiplier, 1.0, 2.0)


func _afk_diamond_bonus() -> float:
	var perfect: Dictionary = GameState.get_upgrade_effect_value("perfectChance")
	var instinct: Dictionary = GameState.get_upgrade_effect_value("diamondInstinct")
	return min(0.05, float(perfect.get("value", 0.0)) * 0.12 + float(instinct.get("value", 0.0)) * 0.16)


func _afk_roll(salt: String, chance: float) -> bool:
	var seed_text := "%s:%s:%s" % [int(GameState.data.get("last_exit_at", 0)), int(GameState.data.get("last_login_at", 0)), salt]
	var roll := float(posmod(seed_text.hash(), 10000)) / 10000.0
	return roll < clampf(chance, 0.0, 1.0)


func get_event_time_remaining(event_id: String) -> int:
	var events: Dictionary = GameState.data.get("events", {})
	var event: Dictionary = events.get(event_id, {})
	if event.is_empty():
		return 0
	return max(0, int(event.get("ends_at", 0)) - get_now_timestamp())


func is_event_active(event_id: String) -> bool:
	return get_event_time_remaining(event_id) > 0


func is_boss_available() -> bool:
	var last_attempt := int(GameState.data.get("boss", {}).get("last_attempt_at", 0))
	return last_attempt <= 0 or get_now_timestamp() - last_attempt >= BOSS_COOLDOWN_SECONDS


func mark_boss_attempt() -> void:
	var boss: Dictionary = GameState.data.get("boss", {})
	boss["last_attempt_at"] = get_now_timestamp()
	GameState.data["boss"] = boss
	GameState.save_game()


func save_time_state() -> void:
	GameState.data["last_exit_at"] = get_now_timestamp()
	GameState.save_game()

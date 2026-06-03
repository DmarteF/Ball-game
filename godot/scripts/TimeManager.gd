extends Node

const SECONDS_PER_DAY := 86400
const AFK_MAX_SECONDS := 8 * 60 * 60
const BOSS_COOLDOWN_SECONDS := 20 * 60 * 60


func get_now_timestamp() -> int:
	return int(Time.get_unix_time_from_system())


func get_month_key(timestamp: int = get_now_timestamp()) -> String:
	var date := Time.get_datetime_dict_from_unix_time(timestamp)
	return "%04d-%02d" % [int(date.year), int(date.month)]


func get_week_key(timestamp: int = get_now_timestamp()) -> String:
	var days := floori(float(timestamp) / 86400.0)
	var week := floori(float(days) / 7.0)
	return "week_%s" % week


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
	var capped_seconds: int = min(max(0, offline_seconds), AFK_MAX_SECONDS)
	var hours: float = float(capped_seconds) / 3600.0
	var coins: int = floori(hours * (80 + int(GameState.data.get("level", 1)) * 6 + int(GameState.data.get("max_unlocked_phase", 1)) * 4))
	return { "coins": coins, "hours": snapped(hours, 0.1) }


func get_pending_afk_rewards() -> Dictionary:
	return GameState.data.get("pending_afk_rewards", {})


func claim_afk_rewards() -> Dictionary:
	var rewards := get_pending_afk_rewards()
	if rewards.is_empty():
		return {}
	GameState.add_coins(int(rewards.get("coins", 0)))
	GameState.data["pending_afk_rewards"] = {}
	GameState.save_game()
	return rewards


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

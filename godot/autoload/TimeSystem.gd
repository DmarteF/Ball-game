extends Node

const DAY_SECONDS = 86400
const WEEK_SECONDS = DAY_SECONDS * 7

func now() -> int:
	return int(Time.get_unix_time_from_system())

func day_key(timestamp = -1) -> String:
	var value = now() if int(timestamp) < 0 else int(timestamp)
	var date = Time.get_datetime_dict_from_unix_time(value)
	return "%04d-%02d-%02d" % [date.year, date.month, date.day]

func week_key(timestamp = -1) -> String:
	var value = now() if int(timestamp) < 0 else int(timestamp)
	var date = Time.get_datetime_dict_from_unix_time(value)
	return "%04d-W%02d" % [date.year, int(floor(float(value) / float(WEEK_SECONDS))) % 53 + 1]

func seconds_since(timestamp) -> int:
	return max(0, now() - int(timestamp))

func hours_since(timestamp) -> float:
	return float(seconds_since(timestamp)) / 3600.0

func seconds_until_next_day() -> int:
	var date = Time.get_datetime_dict_from_system()
	var today_start = Time.get_unix_time_from_datetime_dict({
		"year": date.year,
		"month": date.month,
		"day": date.day,
		"hour": 0,
		"minute": 0,
		"second": 0
	})
	return max(0, int(today_start + DAY_SECONDS - now()))

func format_timer(seconds) -> String:
	var value = max(0, int(seconds))
	var hours = int(floor(value / 3600.0))
	var minutes = int(floor((value % 3600) / 60.0))
	var secs = value % 60
	return "%02d:%02d:%02d" % [hours, minutes, secs]

func event_id_for_week(timestamp = -1) -> String:
	return "rift_%s" % week_key(timestamp).replace("-", "_")

func boss_id_for_day(timestamp = -1) -> String:
	return "boss_%s" % day_key(timestamp).replace("-", "_")

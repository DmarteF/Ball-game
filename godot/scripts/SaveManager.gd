extends Node

const SAVE_PATH := "user://neon_idle_escape_save.json"
const SETTINGS_LEGACY_PATH := "user://settings.json"


func load_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


func save_game(data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data))


func load_legacy_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS_LEGACY_PATH):
		return {}
	var file := FileAccess.open(SETTINGS_LEGACY_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed

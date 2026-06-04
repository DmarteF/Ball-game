extends Node

const SAVE_PATH := "user://neon_idle_escape_save.json"
const BACKUP_SAVE_PATH := "user://neon_idle_escape_save_backup.json"
const SETTINGS_LEGACY_PATH := "user://settings.json"


func load_save() -> Dictionary:
	var data := _load_json_file(SAVE_PATH)
	if not data.is_empty():
		return data
	return _load_json_file(BACKUP_SAVE_PATH)


func _load_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
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
	var payload := JSON.stringify(data)
	file.store_string(payload)
	var backup := FileAccess.open(BACKUP_SAVE_PATH, FileAccess.WRITE)
	if backup != null:
		backup.store_string(payload)


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

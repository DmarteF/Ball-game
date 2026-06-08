extends Node

const SAVE_PATH := "user://neon_idle_escape_save.json"
const BACKUP_SAVE_PATH := "user://neon_idle_escape_save_backup.json"
const IMPORT_BACKUP_SAVE_PATH := "user://neon_idle_escape_save_before_import.json"
const SETTINGS_LEGACY_PATH := "user://settings.json"
const BACKUP_INTERVAL_MSEC := 15000

var _last_backup_msec := 0


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


func save_game(data: Dictionary, force_backup := false) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	var payload := JSON.stringify(data)
	file.store_string(payload)
	var now := Time.get_ticks_msec()
	if not force_backup and _last_backup_msec > 0 and now - _last_backup_msec < BACKUP_INTERVAL_MSEC:
		return
	var backup := FileAccess.open(BACKUP_SAVE_PATH, FileAccess.WRITE)
	if backup != null:
		backup.store_string(payload)
		_last_backup_msec = now


func create_import_backup() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var current := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if current == null:
		return false
	var backup := FileAccess.open(IMPORT_BACKUP_SAVE_PATH, FileAccess.WRITE)
	if backup == null:
		return false
	backup.store_string(current.get_as_text())
	return true


func read_current_save_text() -> String:
	if not FileAccess.file_exists(SAVE_PATH):
		return ""
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()


func write_export_file(text: String) -> String:
	var path := "user://neon_idle_escape_save_export.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_string(text)
	return ProjectSettings.globalize_path(path)


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

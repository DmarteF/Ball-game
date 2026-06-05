extends Node

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"

var _history: Array[String] = []


func navigate_to(scene_path: String) -> void:
	if scene_path.is_empty():
		return
	var current := _current_scene_path()
	if not current.is_empty() and current != scene_path:
		if _history.is_empty() or _history[_history.size() - 1] != current:
			_history.append(current)
			if _history.size() > 16:
				_history.pop_front()
	get_tree().change_scene_to_file(scene_path)


func go_back(fallback_scene := MAIN_MENU_SCENE) -> void:
	var current := _current_scene_path()
	while not _history.is_empty():
		var target: String = String(_history.pop_back())
		if target.is_empty() or target == current:
			continue
		get_tree().change_scene_to_file(target)
		return
	get_tree().change_scene_to_file(fallback_scene)


func clear_history() -> void:
	_history.clear()


func _current_scene_path() -> String:
	var scene := get_tree().current_scene
	if scene == null:
		return ""
	return String(scene.scene_file_path)

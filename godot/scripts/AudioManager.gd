extends Node

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _current_music := ""


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	add_child(_music_player)


func play_music(path: String, volume_db := -13.0) -> void:
	if _is_muted():
		stop_music()
		return
	if _current_music == path and _music_player.playing:
		return
	if not ResourceLoader.exists(path):
		return
	_current_music = path
	_music_player.stream = load(path)
	_music_player.volume_db = volume_db
	_music_player.play()


func stop_music() -> void:
	if _music_player and _music_player.playing:
		_music_player.stop()
	_current_music = ""


func ensure_music() -> void:
	if _is_muted():
		stop_music()
		return
	if _current_music != "" and _music_player and not _music_player.playing:
		_music_player.play()


func play_sfx(path: String, volume_db := -5.0) -> void:
	ensure_music()
	if _is_muted() or not ResourceLoader.exists(path):
		return
	var player := AudioStreamPlayer.new()
	player.stream = load(path)
	player.volume_db = volume_db
	player.bus = "Master"
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()
	_sfx_players.append(player)
	_trim_sfx_players()


func _trim_sfx_players() -> void:
	for i in range(_sfx_players.size() - 1, -1, -1):
		if not is_instance_valid(_sfx_players[i]):
			_sfx_players.remove_at(i)
	while _sfx_players.size() > 12:
		var old: AudioStreamPlayer = _sfx_players.pop_front()
		if is_instance_valid(old):
			old.queue_free()


func _is_muted() -> bool:
	if not Engine.has_singleton("GameState") and not has_node("/root/GameState"):
		return false
	var state = get_node_or_null("/root/GameState")
	if not state:
		return false
	var settings: Dictionary = state.data.get("settings", {})
	return bool(settings.get("audio_muted", false)) or bool(settings.get("master_muted", false))

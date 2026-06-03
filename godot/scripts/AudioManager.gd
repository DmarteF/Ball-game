extends Node

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _current_music := ""
var _current_context := ""
var _last_volume_db := -13.0


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	add_child(_music_player)


func play_music(path: String, volume_db := -13.0, force_restart := false, context := "") -> void:
	if _is_muted():
		if _music_player and _music_player.playing:
			_music_player.stop()
		_current_music = path
		_current_context = context
		_last_volume_db = volume_db
		return
	if _current_music == path and _music_player.playing and not force_restart:
		return
	if not ResourceLoader.exists(path):
		return
	_current_music = path
	_current_context = context
	_last_volume_db = volume_db
	var stream: AudioStream = load(path)
	if stream is AudioStreamMP3:
		stream.loop = true
	_music_player.stream = stream
	_music_player.volume_db = volume_db
	_music_player.play()


func play_context(context: String, force_restart := false) -> void:
	if context == "league":
		play_music("res://assets/music/gameplay2.mp3", -12.0, force_restart, context)
	elif context == "gameplay":
		play_music("res://assets/music/gameplay.mp3", -13.0, force_restart, context)
	elif context == "boss":
		play_music("res://assets/music/boss1.wav", -12.0, force_restart, context)
	else:
		play_music("res://assets/music/menu.mp3", -16.0, force_restart, "menu")


func stop_music() -> void:
	if _music_player and _music_player.playing:
		_music_player.stop()
	_current_music = ""
	_current_context = ""


func ensure_music() -> void:
	if _is_muted():
		if _music_player and _music_player.playing:
			_music_player.stop()
		return
	if _current_music != "" and _music_player and not _music_player.playing:
		_music_player.play()


func apply_audio_settings() -> void:
	if _is_muted():
		if _music_player and _music_player.playing:
			_music_player.stop()
		return
	if _current_music != "":
		play_music(_current_music, _last_volume_db, false, _current_context)


func play_sfx(path: String, volume_db := -5.0) -> void:
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

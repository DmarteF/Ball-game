extends Node

var sound_enabled = true
var music_enabled = true
var music_player
var sfx_players = []
var current_music = ""

const MUSIC = {
	"menu": "res://assets/music/menu.mp3",
	"menu2": "res://assets/music/menu2.mp3",
	"gameplay": "res://assets/music/gameplay.mp3",
	"gameplay2": "res://assets/music/gameplay2.mp3",
	"boss1": "res://assets/music/boss1.wav",
	"boss2": "res://assets/music/boss2.wav"
}

const SFX = {
	"button_click": "res://assets/sounds/button_click.mp3",
	"button_confirm": "res://assets/sounds/button_confirm.mp3",
	"button_error": "res://assets/sounds/button_error.mp3",
	"chest_open": "res://assets/sounds/chest_open.mp3",
	"coin_gain": "res://assets/sounds/coin_gain.mp3",
	"combo": "res://assets/sounds/combo.mp3",
	"defeat": "res://assets/sounds/defeat.mp3",
	"diamond_gain": "res://assets/sounds/diamond_gain.mp3",
	"hit_heavy": "res://assets/sounds/hit_heavy.mp3",
	"hit_light": "res://assets/sounds/hit_light.mp3",
	"legendary_drop": "res://assets/sounds/legendary_drop.mp3",
	"level_up": "res://assets/sounds/level_up.mp3",
	"perfect": "res://assets/sounds/perfect.mp3",
	"rare_drop": "res://assets/sounds/rare_drop.mp3",
	"revive": "res://assets/sounds/revive.mp3",
	"ring_break": "res://assets/sounds/ring_break.mp3",
	"say_perfect": "res://assets/sounds/say_perfect.mp3",
	"victory": "res://assets/sounds/victory.mp3",
	"xp_gain": "res://assets/sounds/xp_gain.mp3"
}

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.finished.connect(_on_music_finished)
	for index in range(8):
		var player = AudioStreamPlayer.new()
		add_child(player)
		sfx_players.append(player)

func set_settings(sound_on, music_on):
	sound_enabled = sound_on
	music_enabled = music_on
	if not music_enabled and music_player:
		music_player.stop()
	elif music_enabled and current_music != "":
		play_music(current_music)

func play_music(key):
	current_music = key
	if not music_enabled:
		return
	var path = MUSIC.get(key, "")
	if path == "" or not ResourceLoader.exists(path):
		return
	var stream = load(path)
	music_player.stream = stream
	music_player.volume_db = -8
	music_player.play()

func play_sfx(key):
	if not sound_enabled:
		return
	var path = SFX.get(key, "")
	if path == "" or not ResourceLoader.exists(path):
		return
	for player in sfx_players:
		if not player.playing:
			player.stream = load(path)
			player.volume_db = -2
			player.play()
			return

func _on_music_finished():
	if current_music != "" and music_enabled:
		music_player.play()


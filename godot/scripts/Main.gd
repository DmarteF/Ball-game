extends Control

const SCENES = {
	"menu": "res://scenes/MainMenu.tscn",
	"phases": "res://scenes/PhaseSelect.tscn",
	"game": "res://scenes/Game.tscn",
	"game_over": "res://scenes/GameOver.tscn",
	"shop": "res://scenes/Shop.tscn",
	"upgrades": "res://scenes/Upgrades.tscn",
	"skins": "res://scenes/Skins.tscn",
	"chests": "res://scenes/Chests.tscn"
}

@onready var screen_host = $ScreenHost

var current_screen

func _ready():
	AudioManager.play_music("menu")
	go_to("menu")

func go_to(key, payload = {}):
	if not SCENES.has(key):
		push_warning("Unknown screen: %s" % key)
		return
	for child in screen_host.get_children():
		child.queue_free()
	var packed = load(SCENES[key])
	current_screen = packed.instantiate()
	screen_host.add_child(current_screen)
	current_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	if current_screen.has_method("setup"):
		current_screen.setup(payload)
	if key == "game":
		AudioManager.play_music("gameplay")
	elif key != "game_over":
		AudioManager.play_music("menu")

func get_active_payload():
	if current_screen and current_screen.has_method("get_payload"):
		return current_screen.get_payload()
	return {}


extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

var wallet_label
var profile_label

func _ready():
	SaveSystem.save_changed.connect(_on_save_changed)
	_build_ui()
	_refresh()

func _build_ui():
	var bg = ColorRect.new()
	bg.color = Color("#080818")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 42)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)

	var top = HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	box.add_child(top)
	profile_label = NeonUI.label("", 14, Color.WHITE)
	profile_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(profile_label)
	wallet_label = NeonUI.label("", 13, Color("#ffd700"), HORIZONTAL_ALIGNMENT_RIGHT)
	wallet_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(wallet_label)

	var title = VBoxContainer.new()
	title.add_theme_constant_override("separation", 0)
	box.add_child(title)
	title.add_child(NeonUI.label("NEON", 62, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_CENTER))
	title.add_child(NeonUI.label("IDLE ESCAPE", 20, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))

	var skin_preview = TextureRect.new()
	skin_preview.custom_minimum_size = Vector2(96, 96)
	skin_preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	skin_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var skin = GameData.get_skin(SaveSystem.get_save().equipped_skin)
	if ResourceLoader.exists(skin.path):
		skin_preview.texture = load(skin.path)
	var preview_center = CenterContainer.new()
	preview_center.add_child(skin_preview)
	box.add_child(preview_center)

	var play = NeonUI.button("JOGAR", Color("#00f0ff"), 76)
	play.add_theme_font_size_override("font_size", 28)
	play.pressed.connect(func(): _go("phases"))
	box.add_child(play)

	var primary = HBoxContainer.new()
	primary.add_theme_constant_override("separation", 10)
	box.add_child(primary)
	_add_nav_button(primary, "UPGRADES", "upgrades", "res://assets/ui/ui_upgrades.png", Color("#b000ff"))
	_add_nav_button(primary, "SKINS", "skins", "res://assets/ui/ui_skins.png", Color("#ff4fd8"))

	var second = HBoxContainer.new()
	second.add_theme_constant_override("separation", 10)
	box.add_child(second)
	_add_nav_button(second, "LOJA", "shop", "res://assets/ui/ui_store.png", Color("#00aaff"))
	_add_nav_button(second, "BAUS", "chests", "res://assets/ui/ui_chest_epic.png", Color("#ffd700"))

	var info = PanelContainer.new()
	info.add_theme_stylebox_override("panel", NeonUI.flat(Color(1, 1, 1, 0.07), Color("#00f0ff44"), 1, 10))
	box.add_child(info)
	var info_box = VBoxContainer.new()
	info_box.add_theme_constant_override("separation", 5)
	info.add_child(info_box)
	info_box.add_child(NeonUI.label("Godot 4 rebuild", 16, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_CENTER))
	info_box.add_child(NeonUI.label("Fases, aneis, loja, baus, skins, upgrades, anuncios mockados e progresso local.", 13, Color("#ffffffbb"), HORIZONTAL_ALIGNMENT_CENTER))

func _add_nav_button(parent, text, route, icon_path, color):
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 92)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_stylebox_override("normal", NeonUI.flat(Color(color, 0.30), Color(color, 0.72), 1, 12))
	button.add_theme_stylebox_override("hover", NeonUI.flat(Color(color, 0.42), Color(color), 1, 12))
	button.add_theme_color_override("font_color", Color.WHITE)
	button.text = text
	button.icon = load(icon_path) if ResourceLoader.exists(icon_path) else null
	button.expand_icon = true
	button.pressed.connect(func(): _go(route))
	parent.add_child(button)

func _refresh():
	var save = SaveSystem.get_save()
	profile_label.text = "%s  Lv.%d  Fase %d" % [save.nickname, save.profile_level, save.current_phase]
	wallet_label.text = "Moedas %d  Diam. %d  Chaves %d" % [save.coins, save.gems, save.keys]

func _on_save_changed(_save):
	_refresh()

func _go(route):
	AudioManager.play_sfx("button_click")
	get_tree().current_scene.go_to(route)

extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

var wallet_label
var profile_label
var skin_preview
var offline_panel
var offline_label
var menu_overlay

func _ready():
	SaveSystem.save_changed.connect(_on_save_changed)
	_build_ui()
	_refresh()

func _build_ui():
	var bg = ColorRect.new()
	bg.color = Color("#080818")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var glow_top = ColorRect.new()
	glow_top.color = Color("#1b0a3d")
	glow_top.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow_top.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(glow_top)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 34)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 13)
	margin.add_child(box)

	var top = PanelContainer.new()
	top.add_theme_stylebox_override("panel", NeonUI.flat(Color("#121228dd"), Color("#00f0ff55"), 1, 14))
	box.add_child(top)
	var top_row = HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 8)
	top.add_child(top_row)
	var profile_icon = NeonUI.icon("res://assets/ui/ui_profile.png", 34)
	top_row.add_child(profile_icon)
	profile_label = NeonUI.label("", 13, Color.WHITE)
	profile_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(profile_label)
	wallet_label = NeonUI.label("", 12, Color("#ffd700"), HORIZONTAL_ALIGNMENT_RIGHT)
	wallet_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(wallet_label)

	var title = VBoxContainer.new()
	title.add_theme_constant_override("separation", -4)
	box.add_child(title)
	title.add_child(NeonUI.label("NEON", 64, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_CENTER))
	title.add_child(NeonUI.label("IDLE ESCAPE", 22, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))

	var preview_panel = PanelContainer.new()
	preview_panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#09091fcc"), Color("#b000ff66"), 1, 18))
	box.add_child(preview_panel)
	var preview_box = VBoxContainer.new()
	preview_box.add_theme_constant_override("separation", 8)
	preview_panel.add_child(preview_box)
	var center = CenterContainer.new()
	preview_box.add_child(center)
	skin_preview = TextureRect.new()
	skin_preview.custom_minimum_size = Vector2(118, 118)
	skin_preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	skin_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	center.add_child(skin_preview)
	preview_box.add_child(NeonUI.label("Toque, evolua, escape dos aneis neon.", 13, Color("#ffffffbb"), HORIZONTAL_ALIGNMENT_CENTER))

	offline_panel = PanelContainer.new()
	offline_panel.visible = false
	offline_panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#10221bdd"), Color("#00ff8888"), 1, 12))
	box.add_child(offline_panel)
	var offline_box = VBoxContainer.new()
	offline_box.add_theme_constant_override("separation", 7)
	offline_panel.add_child(offline_box)
	offline_label = NeonUI.label("", 14, Color("#00ff88"), HORIZONTAL_ALIGNMENT_CENTER)
	offline_box.add_child(offline_label)
	var collect_row = HBoxContainer.new()
	collect_row.add_theme_constant_override("separation", 8)
	offline_box.add_child(collect_row)
	var collect = NeonUI.button("COLETAR AFK", Color("#00ff88"), 42)
	collect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	collect.pressed.connect(_claim_offline.bind(false))
	collect_row.add_child(collect)
	var double = NeonUI.ghost_button("2X ANUNCIO", Color("#ffd700"), 42)
	double.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	double.pressed.connect(_claim_offline.bind(true))
	collect_row.add_child(double)

	var primary = HBoxContainer.new()
	primary.add_theme_constant_override("separation", 10)
	box.add_child(primary)
	_add_nav_button(primary, "MELHORIAS", "upgrades", "res://assets/ui/ui_upgrades.png", Color("#b000ff"))
	_add_nav_button(primary, "SKINS", "skins", "res://assets/ui/ui_skins.png", Color("#ff4fd8"))

	var play = NeonUI.button("JOGAR", Color("#00f0ff"), 78)
	play.add_theme_font_size_override("font_size", 28)
	play.icon = load("res://assets/ui/ui_play.png") if ResourceLoader.exists("res://assets/ui/ui_play.png") else null
	play.expand_icon = true
	play.pressed.connect(func(): _go("phases"))
	box.add_child(play)

	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)

	var more_row = HBoxContainer.new()
	box.add_child(more_row)
	var hint = NeonUI.label("Eventos e recompensas atualizam pelo relogio local.", 12, Color("#ffffff77"))
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	more_row.add_child(hint)
	var more = NeonUI.ghost_button("MENU", Color("#00f0ff"), 46)
	more.custom_minimum_size = Vector2(118, 46)
	more.pressed.connect(_open_menu)
	more_row.add_child(more)

	_build_menu_overlay()

func _add_nav_button(parent, text, route, icon_path, color):
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 94)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_stylebox_override("normal", NeonUI.flat(Color(color, 0.28), Color(color, 0.76), 1, 14))
	button.add_theme_stylebox_override("hover", NeonUI.flat(Color(color, 0.42), Color(color), 1, 14))
	button.add_theme_stylebox_override("pressed", NeonUI.flat(Color(color, 0.18), Color(color), 1, 14))
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_font_size_override("font_size", 14)
	button.text = text
	button.icon = load(icon_path) if ResourceLoader.exists(icon_path) else null
	button.expand_icon = true
	button.pressed.connect(func(): _go(route))
	parent.add_child(button)

func _build_menu_overlay():
	menu_overlay = PanelContainer.new()
	menu_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_overlay.visible = false
	menu_overlay.add_theme_stylebox_override("panel", NeonUI.flat(Color(0, 0, 0, 0.78), Color("#00f0ff44"), 1, 0))
	add_child(menu_overlay)
	var center = CenterContainer.new()
	menu_overlay.add_child(center)
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(372, 0)
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#101027f4"), Color("#00f0ff88"), 1, 18))
	center.add_child(panel)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	var header = HBoxContainer.new()
	box.add_child(header)
	header.add_child(NeonUI.label("MENU", 28, Color("#00f0ff")))
	var fill = Control.new()
	fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(fill)
	var close = NeonUI.ghost_button("X", Color("#ff4fd8"), 38)
	close.custom_minimum_size = Vector2(48, 38)
	close.pressed.connect(_close_menu)
	header.add_child(close)
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)
	var items = [
		["Loja", "shop", "res://assets/ui/ui_store.png", "#00aaff"],
		["Inventario", "inventory", "res://assets/ui/ui_inventory.png", "#ffd700"],
		["Missoes", "missions", "res://assets/ui/ui_missions.png", "#00ff88"],
		["Evento", "event", "res://assets/ui/ui_event.png", "#ff4fd8"],
		["Roleta", "wheel", "res://assets/ui/ui_wheel.png", "#b000ff"],
		["Recompensa diaria", "daily_reward", "res://assets/ui/ui_daily_reward.png", "#ffd700"],
		["Boss", "boss", "res://assets/ui/ui_boss.png", "#ff0055"],
		["Liga Neon", "league", "res://assets/ui/ui_league_neon.png", "#00f0ff"],
		["Conquistas", "achievements", "res://assets/ui/ui_achievements.png", "#ffffff"],
		["Configuracoes", "settings", "res://assets/ui/ui_settings.png", "#9ca3af"]
	]
	for item in items:
		_add_menu_button(grid, item[0], item[1], item[2], Color(item[3]))

func _add_menu_button(parent, text, route, icon_path, color):
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 64)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text = text
	button.icon = load(icon_path) if ResourceLoader.exists(icon_path) else null
	button.expand_icon = true
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", NeonUI.flat(Color(color, 0.18), Color(color, 0.64), 1, 12))
	button.add_theme_stylebox_override("hover", NeonUI.flat(Color(color, 0.30), Color(color), 1, 12))
	button.pressed.connect(func():
		_close_menu()
		_go(route)
	)
	parent.add_child(button)

func _refresh():
	var save = SaveSystem.get_save()
	profile_label.text = "%s  Lv.%d  Fase %d" % [save.nickname, save.profile_level, save.current_phase]
	wallet_label.text = "%d moedas\n%d diamantes  %d chaves" % [save.coins, save.gems, save.keys]
	var skin = GameData.get_skin(save.equipped_skin)
	if ResourceLoader.exists(skin.path):
		skin_preview.texture = load(skin.path)
	var offline = save.timed.pending_offline_reward
	offline_panel.visible = bool(offline.get("available", false))
	if offline_panel.visible:
		offline_label.text = "Voce ficou %.1fh AFK: %d moedas prontas." % [float(offline.get("hours", 0.0)), int(offline.get("coins", 0))]

func _claim_offline(double_reward):
	var result = SaveSystem.claim_offline_reward(double_reward)
	AudioManager.play_sfx("coin_gain" if result.get("ok", false) else "button_error")
	_refresh()

func _on_save_changed(_save):
	_refresh()

func _open_menu():
	AudioManager.play_sfx("button_click")
	menu_overlay.visible = true

func _close_menu():
	AudioManager.play_sfx("button_click")
	menu_overlay.visible = false

func _go(route):
	AudioManager.play_sfx("button_click")
	get_tree().current_scene.go_to(route)

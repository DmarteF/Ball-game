extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

var resources_row
var profile_name
var profile_level
var menu_overlay
var offline_overlay
var offline_reward_label

func _ready():
	SaveSystem.save_changed.connect(_on_save_changed)
	_build_ui()
	_refresh()

func _build_ui():
	NeonUI.add_main_background(self)

	var top_bar = VBoxContainer.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_top = 50
	top_bar.offset_left = 18
	top_bar.offset_right = -18
	top_bar.add_theme_constant_override("separation", 10)
	add_child(top_bar)

	var profile_badge = Button.new()
	profile_badge.custom_minimum_size = Vector2(0, 50)
	profile_badge.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	profile_badge.add_theme_stylebox_override("normal", NeonUI.flat(Color("#ffffff12"), Color("#ffffff22"), 1, 14))
	profile_badge.add_theme_stylebox_override("hover", NeonUI.flat(Color("#ffffff18"), Color("#00f0ff55"), 1, 14))
	profile_badge.add_theme_stylebox_override("pressed", NeonUI.flat(Color("#ffffff10"), Color("#00f0ff88"), 1, 14))
	profile_badge.add_theme_color_override("font_color", Color.WHITE)
	profile_badge.pressed.connect(func(): _go("settings"))
	top_bar.add_child(profile_badge)
	var profile_row = HBoxContainer.new()
	profile_row.add_theme_constant_override("separation", 10)
	profile_badge.add_child(profile_row)
	var avatar = NeonUI.icon("res://assets/ui/ui_profile.png", 34)
	profile_row.add_child(avatar)
	var profile_text = VBoxContainer.new()
	profile_text.add_theme_constant_override("separation", -2)
	profile_row.add_child(profile_text)
	profile_name = NeonUI.label("", 14, Color.WHITE)
	profile_level = NeonUI.label("", 12, Color("#00f0ff"))
	profile_text.add_child(profile_name)
	profile_text.add_child(profile_level)

	resources_row = HBoxContainer.new()
	resources_row.add_theme_constant_override("separation", 8)
	top_bar.add_child(resources_row)

	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 118
	scroll.offset_left = 20
	scroll.offset_right = -20
	scroll.offset_bottom = -96
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	add_child(scroll)

	var content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)

	var top_spacer = Control.new()
	top_spacer.custom_minimum_size = Vector2(0, 22)
	content.add_child(top_spacer)

	var title_box = VBoxContainer.new()
	title_box.add_theme_constant_override("separation", -2)
	content.add_child(title_box)
	title_box.add_child(NeonUI.title_label("NEON", 60))
	var subtitle = NeonUI.label("IDLE ESCAPE", 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	title_box.add_child(subtitle)

	var title_gap = Control.new()
	title_gap.custom_minimum_size = Vector2(0, 14)
	content.add_child(title_gap)

	_add_play_button(content)

	var primary_row = HBoxContainer.new()
	primary_row.add_theme_constant_override("separation", 12)
	content.add_child(primary_row)
	_add_primary_card(primary_row, "MELHORIAS", "upgrades", "res://assets/ui/ui_upgrades.png", Color("#b000ff"), Color("#6600cc"))
	_add_primary_card(primary_row, "SKINS", "skins", "res://assets/ui/ui_skins.png", Color("#ff0088"), Color("#cc0066"))

	var more_button = Button.new()
	more_button.custom_minimum_size = Vector2(64, 64)
	more_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	more_button.offset_left = -82
	more_button.offset_top = -88
	more_button.offset_right = -18
	more_button.offset_bottom = -24
	more_button.text = "MAIS"
	more_button.icon = load("res://assets/ui/ui_menu.png") if ResourceLoader.exists("res://assets/ui/ui_menu.png") else null
	more_button.expand_icon = true
	more_button.add_theme_font_size_override("font_size", 11)
	more_button.add_theme_color_override("font_color", Color("#001018"))
	more_button.add_theme_stylebox_override("normal", NeonUI.neon_box(Color("#00f0ff"), Color("#00f0ff"), 1, 18, 0.9))
	more_button.add_theme_stylebox_override("hover", NeonUI.neon_box(Color("#28f5ff"), Color("#00f0ff"), 1, 18, 0.95))
	more_button.add_theme_stylebox_override("pressed", NeonUI.neon_box(Color("#00bfe6"), Color("#00f0ff"), 1, 18, 0.6))
	more_button.pressed.connect(_open_menu)
	add_child(more_button)

	_build_menu_overlay()
	_build_offline_overlay()

func _add_play_button(parent):
	var root = Control.new()
	root.custom_minimum_size = Vector2(0, 78)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(root)

	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", NeonUI.neon_box(Color("#00f0ff"), Color("#00f0ff"), 1, 16, 0.82))
	root.add_child(panel)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	center.add_child(row)
	row.add_child(NeonUI.icon("res://assets/ui/ui_play.png", 32))
	var label = NeonUI.label("JOGAR", 30, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	label.add_theme_constant_override("shadow_outline_size", 10)
	label.add_theme_color_override("font_shadow_color", Color("#0088ff"))
	row.add_child(label)

	var button = Button.new()
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.text = ""
	button.add_theme_stylebox_override("normal", NeonUI.flat(Color.TRANSPARENT, Color.TRANSPARENT, 0, 16))
	button.add_theme_stylebox_override("hover", NeonUI.flat(Color("#ffffff18"), Color.TRANSPARENT, 0, 16))
	button.add_theme_stylebox_override("pressed", NeonUI.flat(Color("#00000022"), Color.TRANSPARENT, 0, 16))
	button.pressed.connect(func(): _go("phases"))
	root.add_child(button)

func _add_primary_card(parent, text, route, icon_path, color_a, color_b):
	var root = Control.new()
	root.custom_minimum_size = Vector2(0, 92)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(root)

	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", NeonUI.neon_box(Color(color_a, 0.40), Color("#ffffff24"), 1, 14, 0.22))
	root.add_child(panel)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var box = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 6)
	center.add_child(box)
	box.add_child(NeonUI.icon(icon_path, 42))
	var label = NeonUI.label(text, 13, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	label.add_theme_constant_override("outline_size", 0)
	box.add_child(label)

	var button = Button.new()
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.text = ""
	button.add_theme_stylebox_override("normal", NeonUI.flat(Color.TRANSPARENT, Color.TRANSPARENT, 0, 14))
	button.add_theme_stylebox_override("hover", NeonUI.neon_box(Color(color_a, 0.16), Color(color_a, 0.92), 1, 14, 0.36))
	button.add_theme_stylebox_override("pressed", NeonUI.neon_box(Color(color_b, 0.24), Color(color_a), 1, 14, 0.18))
	button.pressed.connect(func(): _go(route))
	root.add_child(button)

func _build_menu_overlay():
	menu_overlay = PanelContainer.new()
	menu_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_overlay.visible = false
	menu_overlay.add_theme_stylebox_override("panel", NeonUI.flat(Color("#000000cc"), Color.TRANSPARENT, 0, 0))
	add_child(menu_overlay)

	var center = CenterContainer.new()
	center.add_theme_constant_override("margin_left", 18)
	center.add_theme_constant_override("margin_right", 18)
	menu_overlay.add_child(center)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 0)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", NeonUI.neon_box(Color("#1a0a2e"), Color("#00f0ff66"), 1, 18, 0.34))
	center.add_child(panel)

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)

	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)
	header.add_child(NeonUI.label("MENU", 24, Color("#00f0ff")))
	var fill = Control.new()
	fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(fill)
	var close = NeonUI.ghost_button("FECHAR", Color("#ffffffaa"), 38)
	close.pressed.connect(_close_menu)
	header.add_child(close)

	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	box.add_child(grid)

	var items = [
		["Loja", "shop", "res://assets/ui/ui_store.png", "#00aaff"],
		["Inventário", "inventory", "res://assets/ui/ui_inventory.png", "#ffd700"],
		["Missões", "missions", "res://assets/ui/ui_missions.png", "#ff8800"],
		["Evento", "event", "res://assets/ui/ui_event.png", "#ff4fd8"],
		["Roleta", "wheel", "res://assets/ui/ui_wheel.png", "#00ff88"],
		["Recompensa diária", "daily_reward", "res://assets/ui/ui_daily_reward.png", "#ffd700"],
		["Boss", "boss", "res://assets/ui/ui_boss.png", "#ff0055"],
		["Liga Neon", "league", "res://assets/ui/ui_league_neon.png", "#00ff88"],
		["Conquistas", "achievements", "res://assets/ui/ui_achievements.png", "#ffd700"],
		["Configurações", "settings", "res://assets/ui/ui_settings.png", "#b8f3ff"]
	]
	for item in items:
		_add_menu_button(grid, item[0], item[1], item[2], Color(item[3]))

func _add_menu_button(parent, text, route, icon_path, color):
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 76)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text = text
	button.icon = load(icon_path) if ResourceLoader.exists(icon_path) else null
	button.expand_icon = true
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", NeonUI.flat(Color("#ffffff12"), Color(color, 0.54), 1, 12))
	button.add_theme_stylebox_override("hover", NeonUI.flat(Color(color, 0.18), Color(color), 1, 12))
	button.pressed.connect(func():
		_close_menu()
		_go(route)
	)
	parent.add_child(button)

func _build_offline_overlay():
	offline_overlay = PanelContainer.new()
	offline_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	offline_overlay.visible = false
	offline_overlay.add_theme_stylebox_override("panel", NeonUI.flat(Color("#000000cc"), Color.TRANSPARENT, 0, 0))
	add_child(offline_overlay)

	var center = CenterContainer.new()
	center.add_theme_constant_override("margin_left", 18)
	center.add_theme_constant_override("margin_right", 18)
	offline_overlay.add_child(center)
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 0)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", NeonUI.neon_box(Color("#1a0a2e"), Color("#00f0ff66"), 1, 16, 0.34))
	center.add_child(panel)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	box.add_child(NeonUI.label("RECOMPENSA AFK", 24, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_CENTER))
	offline_reward_label = NeonUI.label("", 15, Color("#ffffffaa"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(offline_reward_label)
	var reward_row = HBoxContainer.new()
	reward_row.alignment = BoxContainer.ALIGNMENT_CENTER
	reward_row.add_theme_constant_override("separation", 8)
	box.add_child(reward_row)
	reward_row.add_child(NeonUI.icon("res://assets/ui/ui_coin.png", 34))
	var coin_value = NeonUI.label("", 30, Color("#ffd700"))
	coin_value.name = "CoinValue"
	reward_row.add_child(coin_value)
	var collect = NeonUI.button("COLETAR", Color("#00f0ff"), 48)
	collect.pressed.connect(_claim_offline.bind(false))
	box.add_child(collect)
	var double = NeonUI.button("DOBRAR - ANÚNCIO", Color("#ffd700"), 48)
	double.pressed.connect(_claim_offline.bind(true))
	box.add_child(double)

func _refresh():
	var save = SaveSystem.get_save()
	profile_name.text = String(save.get("nickname", "Player"))
	profile_level.text = "Lv.%d" % int(save.get("profile_level", 1))
	NeonUI.clear_children(resources_row)
	resources_row.add_child(NeonUI.resource_badge("res://assets/ui/ui_coin.png", str(save.get("coins", 0))))
	resources_row.add_child(NeonUI.resource_badge("res://assets/ui/ui_gem.png", str(save.get("gems", 0))))
	resources_row.add_child(NeonUI.resource_badge("res://assets/ui/ui_key.png", str(save.get("keys", 0))))
	var offline = save.timed.pending_offline_reward
	var has_offline = bool(offline.get("available", false))
	offline_overlay.visible = has_offline
	if has_offline:
		offline_reward_label.text = "Você ficou fora por %.1fh." % float(offline.get("hours", 0.0))
		var coin_value = offline_overlay.find_child("CoinValue", true, false)
		if coin_value:
			coin_value.text = str(int(offline.get("coins", 0)))

func _claim_offline(double_reward):
	var result = SaveSystem.claim_offline_reward(double_reward)
	AudioManager.play_sfx("coin_gain" if result.get("ok", false) else "button_error")
	offline_overlay.visible = false
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

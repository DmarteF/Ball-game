extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

var resources_row: HBoxContainer
var profile_name: Label
var profile_level: Label
var menu_overlay: PanelContainer
var offline_overlay: PanelContainer
var offline_reward_label: Label

func _ready():
	SaveSystem.save_changed.connect(_on_save_changed)
	_build_ui()
	_refresh()

func _build_ui():
	NeonUI.add_main_background(self)
	_add_top_bar()
	_add_content()
	_add_more_button()
	_build_menu_overlay()
	_build_offline_overlay()

func _add_top_bar():
	var profile = Control.new()
	profile.set_anchors_preset(Control.PRESET_TOP_LEFT)
	profile.offset_left = 18
	profile.offset_top = 50
	profile.offset_right = 154
	profile.offset_bottom = 100
	add_child(profile)

	var profile_panel = PanelContainer.new()
	profile_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	profile_panel.add_theme_stylebox_override("panel", _box(Color("#ffffff12"), Color("#ffffff22"), 1, 14, Vector4(12, 8, 12, 8)))
	profile.add_child(profile_panel)

	var avatar = Control.new()
	avatar.set_anchors_preset(Control.PRESET_TOP_LEFT)
	avatar.offset_left = 12
	avatar.offset_top = 8
	avatar.offset_right = 46
	avatar.offset_bottom = 42
	profile.add_child(avatar)

	var avatar_panel = PanelContainer.new()
	avatar_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	avatar_panel.add_theme_stylebox_override("panel", _box(Color("#ffffff14"), Color("#ffffff55"), 1, 17, Vector4.ZERO, Color("#00f0ff"), 8, 0.35))
	avatar.add_child(avatar_panel)
	var avatar_text = _label("🔵", 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	avatar_text.set_anchors_preset(Control.PRESET_FULL_RECT)
	avatar_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avatar.add_child(avatar_text)

	var profile_text = Control.new()
	profile_text.set_anchors_preset(Control.PRESET_TOP_LEFT)
	profile_text.offset_left = 56
	profile_text.offset_top = 8
	profile_text.offset_right = 128
	profile_text.offset_bottom = 42
	profile.add_child(profile_text)

	profile_name = _label("", 14, Color.WHITE)
	_bold(profile_name, Color.WHITE)
	profile_name.set_anchors_preset(Control.PRESET_TOP_WIDE)
	profile_name.offset_top = 0
	profile_name.offset_bottom = 18
	profile_text.add_child(profile_name)

	profile_level = _label("", 12, Color("#00f0ff"))
	_bold(profile_level, Color("#00f0ff"))
	profile_level.set_anchors_preset(Control.PRESET_TOP_WIDE)
	profile_level.offset_top = 17
	profile_level.offset_bottom = 34
	profile_text.add_child(profile_level)

	_add_touch(profile, func(): _go("settings"))

	resources_row = HBoxContainer.new()
	resources_row.set_anchors_preset(Control.PRESET_TOP_WIDE)
	resources_row.offset_left = 18
	resources_row.offset_top = 110
	resources_row.offset_right = -18
	resources_row.offset_bottom = 144
	resources_row.add_theme_constant_override("separation", 8)
	add_child(resources_row)

func _add_content():
	var title = _label("NEON", 60, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_CENTER)
	_bold(title, Color("#00f0ff"))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_left = 20
	title.offset_top = 174
	title.offset_right = -20
	title.offset_bottom = 246
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_shadow_color", Color("#00f0ff"))
	title.add_theme_constant_override("shadow_offset_x", 0)
	title.add_theme_constant_override("shadow_offset_y", 0)
	title.add_theme_constant_override("shadow_outline_size", 18)
	add_child(title)

	var subtitle = _label("IDLE ESCAPE", 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	subtitle.set_anchors_preset(Control.PRESET_TOP_WIDE)
	subtitle.offset_left = 20
	subtitle.offset_top = 246
	subtitle.offset_right = -20
	subtitle.offset_bottom = 270
	subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(subtitle)

	_add_play_button()
	_add_primary_row()

func _add_play_button():
	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_TOP_WIDE)
	root.offset_left = 20
	root.offset_top = 296
	root.offset_right = -20
	root.offset_bottom = 374
	root.clip_contents = true
	add_child(root)

	NeonUI.gradient_rect(root, [Color("#00f0ff"), Color("#0088ff")], PackedFloat32Array([0.0, 1.0]), Vector2(0, 0), Vector2(1, 1))
	var glow = PanelContainer.new()
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.add_theme_stylebox_override("panel", _box(Color.TRANSPARENT, Color.TRANSPARENT, 0, 16, Vector4.ZERO, Color("#00f0ff"), 18, 0.8))
	root.add_child(glow)

	var row = HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_CENTER)
	row.offset_left = -72
	row.offset_top = -19
	row.offset_right = 72
	row.offset_bottom = 19
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	root.add_child(row)

	var icon = NeonUI.icon("res://assets/ui/ui_play.png", 32)
	icon.modulate = Color.WHITE
	row.add_child(icon)
	var text = _label("JOGAR", 30, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_bold(text, Color.WHITE)
	text.custom_minimum_size = Vector2(100, 38)
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(text)

	_add_touch(root, func(): _go("phases"))

func _add_primary_row():
	var row = HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_TOP_WIDE)
	row.offset_left = 20
	row.offset_top = 386
	row.offset_right = -20
	row.offset_bottom = 478
	row.add_theme_constant_override("separation", 12)
	add_child(row)
	_add_primary_card(row, "MELHORIAS", "upgrades", "res://assets/ui/ui_upgrades.png", Color("#b000ff66"), Color("#6600cc33"))
	_add_primary_card(row, "SKINS", "skins", "res://assets/ui/ui_skins.png", Color("#ff008866"), Color("#cc006633"))

func _add_primary_card(parent: HBoxContainer, text: String, route: String, icon_path: String, color_a: Color, color_b: Color):
	var root = Control.new()
	root.custom_minimum_size = Vector2(0, 92)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.clip_contents = true
	parent.add_child(root)

	NeonUI.gradient_rect(root, [color_a, color_b], PackedFloat32Array([0.0, 1.0]), Vector2(0, 0), Vector2(0, 1))
	var border = PanelContainer.new()
	border.set_anchors_preset(Control.PRESET_FULL_RECT)
	border.add_theme_stylebox_override("panel", _box(Color.TRANSPARENT, Color("#ffffff24"), 1, 14))
	root.add_child(border)

	var box = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -72
	box.offset_top = -34
	box.offset_right = 72
	box.offset_bottom = 34
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 6)
	root.add_child(box)

	var icon = NeonUI.icon(icon_path, 42)
	box.add_child(icon)
	var label = _label(text, 13, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_bold(label, Color.WHITE)
	label.custom_minimum_size = Vector2(144, 18)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	box.add_child(label)

	_add_touch(root, func(): _go(route))

func _add_more_button():
	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	root.offset_left = -82
	root.offset_top = -88
	root.offset_right = -18
	root.offset_bottom = -24
	root.clip_contents = true
	add_child(root)

	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", _box(Color("#00f0ff"), Color.TRANSPARENT, 0, 18, Vector4.ZERO, Color("#00f0ff"), 14, 0.9))
	root.add_child(panel)

	var box = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -28
	box.offset_top = -22
	box.offset_right = 28
	box.offset_bottom = 22
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 0)
	root.add_child(box)

	var icon = NeonUI.icon("res://assets/ui/ui_menu.png", 26)
	icon.modulate = Color("#001018")
	box.add_child(icon)
	var label = _label("MAIS", 11, Color("#001018"), HORIZONTAL_ALIGNMENT_CENTER)
	_bold(label, Color("#001018"))
	label.custom_minimum_size = Vector2(56, 15)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	box.add_child(label)

	_add_touch(root, _open_menu)

func _build_menu_overlay():
	menu_overlay = PanelContainer.new()
	menu_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_overlay.visible = false
	menu_overlay.add_theme_stylebox_override("panel", _box(Color("#000000cc"), Color.TRANSPARENT, 0, 0))
	add_child(menu_overlay)

	var panel = Control.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -195
	panel.offset_top = -235
	panel.offset_right = 195
	panel.offset_bottom = 235
	menu_overlay.add_child(panel)

	var panel_bg = PanelContainer.new()
	panel_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_bg.add_theme_stylebox_override("panel", _box(Color("#1a0a2e"), Color("#00f0ff66"), 1, 18, Vector4(16, 16, 16, 16)))
	panel.add_child(panel_bg)

	var title = _label("MENU", 24, Color("#00f0ff"))
	_bold(title, Color("#00f0ff"))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_left = 16
	title.offset_top = 16
	title.offset_right = -96
	title.offset_bottom = 48
	panel.add_child(title)

	var close = _label("FECHAR", 14, Color("#ffffffaa"), HORIZONTAL_ALIGNMENT_RIGHT)
	_bold(close, Color("#ffffffaa"))
	close.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	close.offset_left = -92
	close.offset_top = 16
	close.offset_right = -16
	close.offset_bottom = 48
	close.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(close)
	_add_touch(close, _close_menu)

	var grid = GridContainer.new()
	grid.columns = 2
	grid.set_anchors_preset(Control.PRESET_FULL_RECT)
	grid.offset_left = 16
	grid.offset_top = 60
	grid.offset_right = -16
	grid.offset_bottom = -16
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	panel.add_child(grid)

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
		_add_menu_item(grid, item[0], item[1], item[2], Color(item[3]))

func _add_menu_item(parent: GridContainer, text: String, route: String, icon_path: String, color: Color):
	var root = Control.new()
	root.custom_minimum_size = Vector2(178, 76)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(root)

	var bg = PanelContainer.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.add_theme_stylebox_override("panel", _box(Color("#ffffff12"), Color(color, 0.54), 1, 12, Vector4(10, 10, 10, 10)))
	root.add_child(bg)

	var box = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -78
	box.offset_top = -30
	box.offset_right = 78
	box.offset_bottom = 30
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 5)
	root.add_child(box)
	box.add_child(NeonUI.icon(icon_path, 34))
	var label = _label(text, 12, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_bold(label, Color.WHITE)
	label.custom_minimum_size = Vector2(156, 18)
	box.add_child(label)

	_add_touch(root, func():
		_close_menu()
		_go(route)
	)

func _build_offline_overlay():
	offline_overlay = PanelContainer.new()
	offline_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	offline_overlay.visible = false
	offline_overlay.add_theme_stylebox_override("panel", _box(Color("#000000cc"), Color.TRANSPARENT, 0, 0))
	add_child(offline_overlay)

	var box = Control.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -190
	box.offset_top = -145
	box.offset_right = 190
	box.offset_bottom = 145
	offline_overlay.add_child(box)

	var bg = PanelContainer.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.add_theme_stylebox_override("panel", _box(Color("#1a0a2e"), Color("#00f0ff66"), 1, 16, Vector4(22, 22, 22, 22)))
	box.add_child(bg)

	var title = _label("RECOMPENSA OFFLINE", 24, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_CENTER)
	_bold(title, Color("#00f0ff"))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_left = 22
	title.offset_top = 22
	title.offset_right = -22
	title.offset_bottom = 54
	box.add_child(title)

	offline_reward_label = _label("", 14, Color("#ffffffaa"), HORIZONTAL_ALIGNMENT_CENTER)
	offline_reward_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	offline_reward_label.offset_left = 22
	offline_reward_label.offset_top = 62
	offline_reward_label.offset_right = -22
	offline_reward_label.offset_bottom = 88
	box.add_child(offline_reward_label)

	var reward_row = HBoxContainer.new()
	reward_row.set_anchors_preset(Control.PRESET_TOP_WIDE)
	reward_row.offset_left = 130
	reward_row.offset_top = 100
	reward_row.offset_right = -130
	reward_row.offset_bottom = 138
	reward_row.alignment = BoxContainer.ALIGNMENT_CENTER
	reward_row.add_theme_constant_override("separation", 8)
	box.add_child(reward_row)
	reward_row.add_child(NeonUI.icon("res://assets/ui/ui_coin.png", 34))
	var coin_value = _label("", 30, Color("#ffd700"))
	_bold(coin_value, Color("#ffd700"))
	coin_value.name = "CoinValue"
	coin_value.custom_minimum_size = Vector2(80, 38)
	reward_row.add_child(coin_value)

	var collect = _solid_button("COLETAR", Color("#00f0ff"), Color("#001018"))
	collect.set_anchors_preset(Control.PRESET_TOP_WIDE)
	collect.offset_left = 22
	collect.offset_top = 154
	collect.offset_right = -22
	collect.offset_bottom = 202
	box.add_child(collect)
	_add_touch(collect, func(): _claim_offline(false))

	var double = _solid_button("DOBRAR - ANÚNCIO", Color("#ffd700"), Color("#001018"))
	double.set_anchors_preset(Control.PRESET_TOP_WIDE)
	double.offset_left = 22
	double.offset_top = 210
	double.offset_right = -22
	double.offset_bottom = 258
	box.add_child(double)
	_add_touch(double, func(): _claim_offline(true))

func _refresh():
	var save = SaveSystem.get_save()
	profile_name.text = String(save.get("nickname", "Player"))
	profile_level.text = "Lv.%d" % int(save.get("profile_level", 1))
	NeonUI.clear_children(resources_row)
	resources_row.add_child(_resource_badge("res://assets/ui/ui_coin.png", str(save.get("coins", 0))))
	resources_row.add_child(_resource_badge("res://assets/ui/ui_gem.png", str(save.get("gems", 0))))
	resources_row.add_child(_resource_badge("res://assets/ui/ui_key.png", str(save.get("keys", 0))))
	var timed = save.get("timed", {})
	var offline = timed.get("pending_offline_reward", {})
	var has_offline = bool(offline.get("available", false))
	offline_overlay.visible = has_offline
	if has_offline:
		offline_reward_label.text = "Você ficou fora por %.1fh." % float(offline.get("hours", 0.0))
		var coin_value = offline_overlay.find_child("CoinValue", true, false)
		if coin_value:
			coin_value.text = str(int(offline.get("coins", 0)))

func _resource_badge(icon_path: String, text: String):
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 34)
	panel.add_theme_stylebox_override("panel", _box(Color("#ffffff12"), Color("#ffffff22"), 1, 10, Vector4(10, 7, 10, 7)))
	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 5)
	panel.add_child(row)
	row.add_child(NeonUI.icon(icon_path, 18))
	var value = _label(text, 14, Color.WHITE)
	_bold(value, Color.WHITE)
	value.custom_minimum_size = Vector2(18, 18)
	row.add_child(value)
	return panel

func _solid_button(text: String, bg: Color, fg: Color):
	var root = Control.new()
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", _box(bg, Color.TRANSPARENT, 0, 10, Vector4(14, 14, 14, 14)))
	root.add_child(panel)
	var label = _label(text, 14, fg, HORIZONTAL_ALIGNMENT_CENTER)
	_bold(label, fg)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	root.add_child(label)
	return root

func _label(text: String, size: int, color: Color, align = HORIZONTAL_ALIGNMENT_LEFT):
	var node = Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", color)
	node.horizontal_alignment = align
	node.clip_text = true
	node.autowrap_mode = TextServer.AUTOWRAP_OFF
	return node

func _bold(label: Label, color: Color):
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_color_override("font_outline_color", color)

func _add_touch(parent: Control, callback: Callable):
	var button = Button.new()
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.text = ""
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal", _box(Color.TRANSPARENT, Color.TRANSPARENT, 0, 0))
	button.add_theme_stylebox_override("hover", _box(Color.TRANSPARENT, Color.TRANSPARENT, 0, 0))
	button.add_theme_stylebox_override("pressed", _box(Color("#00000022"), Color.TRANSPARENT, 0, 0))
	button.add_theme_stylebox_override("focus", _box(Color.TRANSPARENT, Color.TRANSPARENT, 0, 0))
	button.pressed.connect(callback)
	parent.add_child(button)

func _box(color: Color, border_color: Color, border_width = 1, radius = 10, margins = Vector4.ZERO, shadow_color = Color.TRANSPARENT, shadow_size = 0, shadow_alpha = 0.0):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = margins.x
	style.content_margin_top = margins.y
	style.content_margin_right = margins.z
	style.content_margin_bottom = margins.w
	if shadow_size > 0:
		style.shadow_color = Color(shadow_color, shadow_alpha)
		style.shadow_size = shadow_size
		style.shadow_offset = Vector2.ZERO
	return style

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

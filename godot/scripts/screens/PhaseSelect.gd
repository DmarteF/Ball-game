extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

func _ready():
	_build_ui()

func _build_ui():
	NeonUI.add_main_background(self)

	var header = VBoxContainer.new()
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_left = 20
	header.offset_right = -20
	header.offset_top = 60
	header.offset_bottom = 128
	header.add_theme_constant_override("separation", 10)
	add_child(header)

	var back = Button.new()
	back.text = "← VOLTAR"
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back.add_theme_font_size_override("font_size", 16)
	back.add_theme_color_override("font_color", Color("#00f0ff"))
	back.add_theme_stylebox_override("normal", NeonUI.flat(Color.TRANSPARENT, Color.TRANSPARENT, 0, 0))
	back.add_theme_stylebox_override("hover", NeonUI.flat(Color("#ffffff10"), Color.TRANSPARENT, 0, 0))
	back.pressed.connect(func(): get_tree().current_scene.go_to("menu"))
	header.add_child(back)
	header.add_child(NeonUI.label("SELECIONAR FASE", 32, Color("#00f0ff")))

	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 140
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var margin = MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	scroll.add_child(margin)

	var list = VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 16)
	margin.add_child(list)

	var save = SaveSystem.get_save()
	_add_infinite_card(list, save)
	for phase in range(1, 51):
		_add_phase_card(list, phase, save)

func _add_infinite_card(parent, save):
	var unlocked = int(save.lifetime_stats.get("highest_phase", 1)) >= 5 or 6 in save.unlocked_phases
	var card = _make_card(parent, unlocked, Color("#00ff88"), ["#00ff8888", "#00f0ff33"], ["#333333", "#222222"])
	var row = _card_row(card)
	row.add_child(_circle_icon("res://assets/ui/ui_infinite.png", "", Color("#ffffff22")))
	var info = _info_box(row)
	info.add_child(NeonUI.label("MODO INFINITO", 20, Color.WHITE if unlocked else Color("#ffffff55")))
	info.add_child(NeonUI.label("Ondas sem fim com desafios progressivos." if unlocked else "Complete a Fase 5 para desbloquear.", 14, Color("#ffffffaa") if unlocked else Color("#ffffff55")))
	var stats = HBoxContainer.new()
	stats.add_theme_constant_override("separation", 16)
	info.add_child(stats)
	stats.add_child(NeonUI.label("ESPECIAL", 12, Color("#ffffff88") if unlocked else Color("#ffffff55")))
	stats.add_child(NeonUI.label("PROGRESSÃO INFINITA", 12, Color("#ffffff88") if unlocked else Color("#ffffff55")))
	_add_press_layer(card, unlocked, Callable(self, "_start_infinite"), "FASE 5")

func _add_phase_card(parent, phase, save):
	var cfg = GameData.get_phase_config(phase)
	var unlocked = phase in save.unlocked_phases
	var color = Color(cfg.color)
	var card = _make_card(parent, unlocked, color, [cfg.color + "88", cfg.color + "44"], ["#333333", "#222222"])
	var row = _card_row(card)
	row.add_child(_circle_icon("", str(phase), Color("#ffffff22")))
	var info = _info_box(row)
	info.add_child(NeonUI.label(cfg.name, 20, Color.WHITE if unlocked else Color("#ffffff55")))
	info.add_child(NeonUI.label(cfg.description, 14, Color("#ffffffaa") if unlocked else Color("#ffffff55")))
	var stats = HBoxContainer.new()
	stats.add_theme_constant_override("separation", 16)
	info.add_child(stats)
	stats.add_child(NeonUI.label("DIFICULDADE: %s" % cfg.difficulty.to_upper(), 12, Color("#ffffff88") if unlocked else Color("#ffffff55")))
	stats.add_child(NeonUI.label("%d-%d ANÉIS • HP %d" % [cfg.ring_min, cfg.ring_max, cfg.base_hp], 12, Color("#ffffff88") if unlocked else Color("#ffffff55")))
	_add_press_layer(card, unlocked, _start_phase.bind(phase), "BLOQUEADO")

func _make_card(parent, unlocked, color, _colors_unlocked, _colors_locked):
	var root = Control.new()
	root.custom_minimum_size = Vector2(0, 140)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(root)
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg = Color(color, 0.42) if unlocked else Color("#333333")
	var border = Color("#ffffff22")
	panel.add_theme_stylebox_override("panel", NeonUI.neon_box(bg, border, 2, 16, 0.24 if unlocked else 0.05))
	root.add_child(panel)
	return root

func _card_row(card):
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	card.add_child(margin)
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	margin.add_child(row)
	return row

func _circle_icon(icon_path, number, color):
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(60, 60)
	panel.add_theme_stylebox_override("panel", NeonUI.flat(color, Color.TRANSPARENT, 0, 30))
	var center = CenterContainer.new()
	panel.add_child(center)
	if icon_path != "":
		center.add_child(NeonUI.icon(icon_path, 38))
	else:
		center.add_child(NeonUI.label(number, 32, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))
	return panel

func _info_box(parent):
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4)
	parent.add_child(info)
	return info

func _add_press_layer(card, unlocked, action, locked_text):
	var button = Button.new()
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.text = ""
	button.disabled = not unlocked
	button.add_theme_stylebox_override("normal", NeonUI.flat(Color.TRANSPARENT, Color.TRANSPARENT, 0, 0))
	button.add_theme_stylebox_override("hover", NeonUI.flat(Color("#ffffff10"), Color.TRANSPARENT, 0, 0))
	button.add_theme_stylebox_override("pressed", NeonUI.flat(Color("#00000022"), Color.TRANSPARENT, 0, 0))
	button.pressed.connect(action)
	card.add_child(button)
	if not unlocked:
		var overlay = PanelContainer.new()
		overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		overlay.add_theme_stylebox_override("panel", NeonUI.flat(Color("#00000066"), Color.TRANSPARENT, 0, 0))
		card.add_child(overlay)
		var center = CenterContainer.new()
		overlay.add_child(center)
		var box = VBoxContainer.new()
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		center.add_child(box)
		box.add_child(NeonUI.icon("res://assets/ui/ui_locked.png", 22))
		box.add_child(NeonUI.label(locked_text, 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))

func _start_phase(phase):
	AudioManager.play_sfx("button_confirm")
	get_tree().current_scene.go_to("game", {"phase": phase, "mode": "phase"})

func _start_infinite():
	AudioManager.play_sfx("button_confirm")
	get_tree().current_scene.go_to("game", {"phase": max(1, int(SaveSystem.get_save().current_phase)), "mode": "infinite"})

extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

func _ready():
	_build_ui()

func _build_ui():
	var bg = ColorRect.new()
	bg.color = Color("#080818")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var header = HBoxContainer.new()
	box.add_child(header)
	var back = NeonUI.ghost_button("VOLTAR", Color("#00f0ff"), 42)
	back.pressed.connect(func(): get_tree().current_scene.go_to("menu"))
	header.add_child(back)
	var title = NeonUI.label("JOGAR", 30, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_RIGHT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var save = SaveSystem.get_save()
	box.add_child(NeonUI.label("Escolha uma fase ou entre no modo infinito quando liberar.", 13, Color("#ffffffbb")))

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)

	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)

	_add_infinite_card(content, save)

	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	content.add_child(grid)

	for phase in range(1, 51):
		_add_phase_button(grid, phase, save)

func _add_infinite_card(parent, save):
	var unlocked = int(save.lifetime_stats.get("highest_phase", 1)) >= 5 or int(save.current_phase) >= 6
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#15092acc"), Color("#00f0ffaa") if unlocked else Color("#ffffff22"), 1, 16))
	parent.add_child(panel)
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)
	row.add_child(NeonUI.icon("res://assets/ui/ui_infinite.png", 54))
	var text_box = VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_box)
	text_box.add_child(NeonUI.label("MODO INFINITO", 20, Color("#00f0ff") if unlocked else Color("#ffffff88")))
	text_box.add_child(NeonUI.label("Aneis continuam escalando. Recompensas aumentam com combo e tempo.", 12, Color("#ffffffbb") if unlocked else Color("#ffffff66")))
	var button = NeonUI.button("ENTRAR", Color("#00f0ff"), 50) if unlocked else NeonUI.ghost_button("LIBERA NA FASE 6", Color("#ffffff66"), 50)
	button.custom_minimum_size = Vector2(118, 50)
	button.disabled = not unlocked
	if unlocked:
		button.pressed.connect(_start_infinite)
	row.add_child(button)

func _add_phase_button(parent, phase, save):
	var cfg = GameData.get_phase_config(phase)
	var unlocked = phase in save.unlocked_phases
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 82)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text = "FASE %d\n%s" % [phase, cfg.difficulty] if unlocked else "FASE %d\nBLOQ." % phase
	button.disabled = not unlocked
	button.add_theme_font_size_override("font_size", 13)
	var color = Color(cfg.color)
	button.add_theme_stylebox_override("normal", NeonUI.flat(Color(color, 0.20), Color(color, 0.72), 1, 12))
	button.add_theme_stylebox_override("hover", NeonUI.flat(Color(color, 0.32), Color(color), 1, 12))
	button.add_theme_stylebox_override("disabled", NeonUI.flat(Color("#252536"), Color("#ffffff22"), 1, 12))
	button.add_theme_color_override("font_color", Color.WHITE if unlocked else Color("#ffffff66"))
	if unlocked:
		button.pressed.connect(_start_phase.bind(phase))
	parent.add_child(button)

func _start_phase(phase):
	AudioManager.play_sfx("button_confirm")
	get_tree().current_scene.go_to("game", {"phase": phase, "mode": "phase"})

func _start_infinite():
	var save = SaveSystem.get_save()
	AudioManager.play_sfx("button_confirm")
	get_tree().current_scene.go_to("game", {"phase": max(1, int(save.current_phase)), "mode": "infinite"})

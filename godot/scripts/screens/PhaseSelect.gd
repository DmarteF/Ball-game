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
	margin.add_theme_constant_override("margin_top", 32)
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
	var title = NeonUI.label("FASES", 28, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_RIGHT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var save = SaveSystem.get_save()
	box.add_child(NeonUI.label("Escolha uma arena desbloqueada. A progressao principal vai ate a fase 50.", 13, Color("#ffffffbb")))

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)

	var grid = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(grid)

	for phase in range(1, 51):
		var cfg = GameData.get_phase_config(phase)
		var unlocked = phase in save.unlocked_phases
		var button = Button.new()
		button.custom_minimum_size = Vector2(86, 72)
		button.text = "F%d\n%s" % [phase, cfg.difficulty] if unlocked else "F%d\nBLOQ." % phase
		button.disabled = not unlocked
		button.add_theme_font_size_override("font_size", 13)
		var color = Color(cfg.color)
		button.add_theme_stylebox_override("normal", NeonUI.flat(Color(color, 0.20), Color(color, 0.7), 1, 10))
		button.add_theme_stylebox_override("disabled", NeonUI.flat(Color("#252536"), Color("#ffffff22"), 1, 10))
		button.add_theme_color_override("font_color", Color.WHITE if unlocked else Color("#ffffff66"))
		if unlocked:
			button.pressed.connect(_start_phase.bind(phase))
		grid.add_child(button)

func _start_phase(phase):
	AudioManager.play_sfx("button_confirm")
	get_tree().current_scene.go_to("game", {"phase": phase})

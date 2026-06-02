extends Control

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const PLACEHOLDER_SCENE := "res://scenes/Placeholder.tscn"

const ICON_PATHS := {
	"infinite": "res://assets/ui/ui_infinite.png",
	"locked": "res://assets/ui/ui_locked.png",
}

const PHASE_COLORS := ["#00f0ff", "#b000ff", "#ff0055", "#00ff88", "#ffd700", "#ff8800", "#ff4fd8", "#60a5fa"]

var _regular_font: Font
var _bold_font: Font


func _ready() -> void:
	_regular_font = _make_system_font(400)
	_bold_font = _make_system_font(700)
	_build_background()
	_build_screen()


func _build_background() -> void:
	var background := TextureRect.new()
	_fill(background)
	background.texture = _make_background_gradient()
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)


func _build_screen() -> void:
	var root := VBoxContainer.new()
	root.anchor_left = 0.0
	root.anchor_top = 0.0
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.offset_left = 20.0
	root.offset_top = 50.0
	root.offset_right = -20.0
	root.offset_bottom = 0.0
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var back := _make_back_button()
	back.pressed.connect(_go_back)
	root.add_child(back)
	root.add_child(_make_label("SELECIONAR FASE", 32, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 16)
	scroll.add_child(list)

	list.add_child(_make_infinite_card())
	for phase_id in range(1, 51):
		list.add_child(_make_phase_card(_phase_data(phase_id)))
	list.add_child(_spacer(18))


func _make_infinite_card() -> Button:
	var infinite_unlocked := int(GameState.data.get("max_unlocked_phase", 1)) >= 5
	var button := _make_card_button()
	button.custom_minimum_size.y = 140
	button.pressed.connect(_open_placeholder)
	var body := _make_card_body(button, "#00ff8888" if infinite_unlocked else "#333333", "#00f0ff33" if infinite_unlocked else "#222222")
	body.add_child(_make_circle_icon("infinite", "", "#ffffff22"))
	var info := _make_phase_info("Modo Infinito", "Ondas sem fim com desafios progressivos." if infinite_unlocked else "Complete a Fase 5 para desbloquear.", "ESPECIAL", "PROGRESSÃO INFINITA", not infinite_unlocked)
	body.add_child(info)
	if not infinite_unlocked:
		body.add_child(_make_lock_overlay("FASE 5"))
	return button


func _make_phase_card(phase: Dictionary) -> Button:
	var unlocked := int(phase["id"]) <= int(GameState.data.get("max_unlocked_phase", 1))
	var button := _make_card_button()
	button.custom_minimum_size.y = 140
	button.disabled = not unlocked
	button.modulate.a = 1.0 if unlocked else 0.92
	if unlocked:
		button.pressed.connect(_open_placeholder)
	var color := String(phase["color"])
	var body := _make_card_body(button, color + "88" if unlocked else "#333333", color + "44" if unlocked else "#222222")
	body.add_child(_make_circle_icon("", str(phase["id"]), "#ffffff22"))
	body.add_child(_make_phase_info(String(phase["name"]), String(phase["description"]), String(phase["difficulty"]), "%s-%s ANÉIS • HP %s" % [phase["ring_min"], phase["ring_max"], phase["base_hp"]], not unlocked))
	if not unlocked:
		body.add_child(_make_lock_overlay("BLOQUEADA"))
	return button


func _make_card_button() -> Button:
	var button := Button.new()
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	_apply_button_style(button, _make_style("#00000000", 16))
	return button


func _make_card_body(button: Button, color_a: String, color_b: String) -> HBoxContainer:
	var panel := PanelContainer.new()
	_fill(panel)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _make_style(color_a, 16, "#ffffff22", 2, color_b, 10))
	button.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)
	return row


func _make_circle_icon(icon_key: String, text: String, bg: String) -> PanelContainer:
	var circle := PanelContainer.new()
	circle.custom_minimum_size = Vector2(60, 60)
	circle.add_theme_stylebox_override("panel", _make_style(bg, 30))
	circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	circle.add_child(center)
	if icon_key.is_empty():
		center.add_child(_make_label(text, 32, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	else:
		center.add_child(_make_icon(icon_key, 38))
	return circle


func _make_phase_info(title: String, description: String, difficulty: String, stats: String, locked: bool) -> VBoxContainer:
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.add_theme_constant_override("separation", 5)
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var opacity := "55" if locked else ""
	info.add_child(_make_label(title, 20, "#ffffff" + opacity, _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	var desc := _make_label(description, 14, "#ffffffaa" if not locked else "#ffffff55", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(desc)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(row)
	row.add_child(_make_label("DIFICULDADE: %s" % difficulty, 12, "#ffffff88" if not locked else "#ffffff55", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	row.add_child(_make_label(stats, 12, "#ffffff88" if not locked else "#ffffff55", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))
	return info


func _make_lock_overlay(text: String) -> PanelContainer:
	var overlay := PanelContainer.new()
	overlay.custom_minimum_size = Vector2(88, 86)
	overlay.add_theme_stylebox_override("panel", _make_style("#00000066", 12))
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 5)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(column)
	column.add_child(_make_icon("locked", 22))
	column.add_child(_make_label(text, 14, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	return overlay


func _phase_data(id: int) -> Dictionary:
	var tier := _tier_for_phase(id)
	var tier_start: int = 1 if id <= 5 else 6 if id <= 10 else 11 if id <= 20 else 21 if id <= 30 else 31 if id <= 40 else 41
	var tier_end: int = 5 if id <= 5 else 10 if id <= 10 else 20 if id <= 20 else 30 if id <= 30 else 40 if id <= 40 else 50
	var phase_t: float = float(id - tier_start) / max(1.0, float(tier_end - tier_start))
	var ring_min := roundi(float(tier["min"]) + (float(tier["max"]) - float(tier["min"])) * phase_t * 0.72)
	var ring_max := roundi(float(tier["min"]) + (float(tier["max"]) - float(tier["min"])) * min(1.0, phase_t + 0.22))
	return {
		"id": id,
		"name": "Fase %s" % id,
		"description": "Primeira arena neon com aberturas grandes." if id == 1 else String(tier["desc"]),
		"difficulty": String(tier["name"]),
		"ring_min": ring_min,
		"ring_max": max(ring_min + 2, ring_max),
		"base_hp": roundi(float(tier["hp"]) + id * 6 + pow(id, 1.32) * 5.2),
		"color": PHASE_COLORS[(id - 1) % PHASE_COLORS.size()],
	}


func _tier_for_phase(id: int) -> Dictionary:
	if id <= 5:
		return { "min": 8, "max": 16, "hp": 12, "name": "Normal", "desc": "Arena inicial com aberturas grandes e pressão baixa." }
	if id <= 10:
		return { "min": 16, "max": 24, "hp": 34, "name": "Difícil", "desc": "Rotação alternada e anéis um pouco mais resistentes." }
	if id <= 20:
		return { "min": 24, "max": 36, "hp": 68, "name": "Avançado", "desc": "Mais padrões, aberturas menores e anéis resistentes." }
	if id <= 30:
		return { "min": 36, "max": 50, "hp": 128, "name": "Extremo", "desc": "Arena exigente para skins e upgrades mais fortes." }
	if id <= 40:
		return { "min": 50, "max": 65, "hp": 220, "name": "Insano", "desc": "Padrões complexos, fechamento perigoso e melhores baús." }
	return { "min": 65, "max": 80, "hp": 340, "name": "Ultimate", "desc": "Arena premium com rotação intensa, justa e recompensas altas." }


func _make_icon(key: String, icon_size: int) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = load(ICON_PATHS[key])
	icon.custom_minimum_size = Vector2(icon_size, icon_size)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon


func _make_label(text: String, font_size: int, color: String, font: Font, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(color))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _make_back_button() -> Button:
	var button := Button.new()
	button.text = "Back"
	button.custom_minimum_size = Vector2(180, 48)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_color_override("font_color", Color("#001018"))
	_apply_button_style(button, _make_style("#00f0ff", 12, "#00000000", 0, "#00f0ff99", 10))
	return button


func _make_background_gradient() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.52, 1.0])
	gradient.colors = PackedColorArray([Color("#0a0a1a"), Color("#1a0a2e"), Color("#16003b")])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 16
	texture.height = 1024
	texture.fill = GradientTexture2D.FILL_LINEAR
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(0.0, 1.0)
	return texture


func _make_style(bg_color: String, radius: int, border_color: String = "#00000000", border_width: int = 0, shadow_color: String = "#00000000", shadow_size: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(bg_color)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_right = radius
	style.corner_radius_bottom_left = radius
	style.border_color = Color(border_color)
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.shadow_color = Color(shadow_color)
	style.shadow_size = shadow_size
	style.shadow_offset = Vector2.ZERO
	return style


func _apply_button_style(button: Button, style: StyleBoxFlat) -> void:
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_stylebox_override("disabled", style)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _make_system_font(weight: int) -> SystemFont:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Arial", "Helvetica", "Noto Sans", "DejaVu Sans", "sans-serif"])
	font.font_weight = weight
	return font


func _spacer(height: float) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = height
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer


func _fill(control: Control) -> void:
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 1.0
	control.anchor_bottom = 1.0
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0


func _go_back() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


func _open_placeholder() -> void:
	get_tree().change_scene_to_file(PLACEHOLDER_SCENE)

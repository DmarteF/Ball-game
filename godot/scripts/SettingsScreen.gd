extends Control

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const SETTINGS_PATH := "user://settings.json"

const ICON_PATHS := {
	"settings": "res://assets/ui/ui_settings.png",
	"mute_on": "res://assets/ui/ui_mute_on.png",
	"mute_off": "res://assets/ui/ui_mute_off.png",
}

var _regular_font: Font
var _bold_font: Font
var _audio_muted := false
var _language := "pt"


func _ready() -> void:
	_regular_font = _make_system_font(400)
	_bold_font = _make_system_font(700)
	_load_settings()
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
	root.offset_left = 18.0
	root.offset_top = 50.0
	root.offset_right = -18.0
	root.offset_bottom = -18.0
	root.add_theme_constant_override("separation", 14)
	add_child(root)

	var back := _make_flat_button("← VOLTAR", "#00f0ff", 16)
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back.pressed.connect(_go_back)
	root.add_child(back)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 12)
	root.add_child(title_row)
	title_row.add_child(_make_icon("settings", 34))
	title_row.add_child(_make_label("CONFIGURAÇÕES", 28, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)

	content.add_child(_make_audio_card())
	content.add_child(_make_language_card())
	content.add_child(_make_about_card())
	content.add_child(_make_back_card())


func _make_audio_card() -> PanelContainer:
	var card := _make_card()
	var body := _card_body(card)
	body.add_child(_make_section_title("ÁUDIO"))
	var button := Button.new()
	button.custom_minimum_size.y = 58
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	_apply_button_style(button, _make_style("#00f0ff" if not _audio_muted else "#ffffff14", 14, "#00f0ff88", 1, "#00f0ff66", 8))
	button.pressed.connect(func() -> void:
		_audio_muted = not _audio_muted
		_save_settings()
		get_tree().reload_current_scene()
	)
	var row := HBoxContainer.new()
	_fill(row)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(row)
	row.add_child(_make_icon("mute_off" if _audio_muted else "mute_on", 22, Color("#ffffff") if _audio_muted else Color("#001018")))
	row.add_child(_make_label("Audio: %s" % ("Mudo" if _audio_muted else "Ligado"), 18, "#ffffff" if _audio_muted else "#001018", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	body.add_child(button)
	return card


func _make_language_card() -> PanelContainer:
	var card := _make_card()
	var body := _card_body(card)
	body.add_child(_make_section_title("IDIOMA"))
	body.add_child(_make_label("Escolha o idioma da interface.", 14, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))
	var grid := GridContainer.new()
	grid.columns = 1
	grid.add_theme_constant_override("v_separation", 8)
	body.add_child(grid)
	grid.add_child(_make_language_button("Português", "pt"))
	grid.add_child(_make_language_button("English", "en"))
	grid.add_child(_make_language_button("Español", "es"))
	return card


func _make_about_card() -> PanelContainer:
	var card := _make_card()
	var body := _card_body(card)
	body.add_child(_make_section_title("SOBRE"))
	body.add_child(_make_label("Neon Idle Escape", 18, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	var text := _make_label("Versão Godot 4 em migração fiel, mantendo o visual neon, controles mobile e estrutura preparada para Web.", 13, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(text)
	return card


func _make_back_card() -> PanelContainer:
	var card := _make_card()
	var body := _card_body(card)
	var back := _make_solid_button("VOLTAR AO MENU", "#00f0ff", "#001018", 220, 52)
	back.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back.pressed.connect(_go_back)
	body.add_child(back)
	return card


func _make_language_button(label: String, code: String) -> Button:
	var active := _language == code
	var button := _make_solid_button("%s%s" % [label, "  OK" if active else ""], "#00ff8822" if active else "#ffffff14", "#00ff88" if active else "#ffffff", 220, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_stylebox_override("normal", _make_style("#00ff8822" if active else "#ffffff14", 10, "#00ff88" if active else "#ffffff22", 1))
	button.add_theme_stylebox_override("hover", _make_style("#00ff8822" if active else "#ffffff14", 10, "#00ff88" if active else "#ffffff22", 1))
	button.add_theme_stylebox_override("pressed", _make_style("#00ff8822" if active else "#ffffff14", 10, "#00ff88" if active else "#ffffff22", 1))
	button.pressed.connect(func() -> void:
		_language = code
		_save_settings()
		get_tree().reload_current_scene()
	)
	return button


func _make_card() -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_style("#ffffff12", 12, "#ffffff22", 1))
	return card


func _card_body(card: PanelContainer) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	card.add_child(margin)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	margin.add_child(body)
	return body


func _make_section_title(text: String) -> Label:
	var label := _make_label(text, 13, "#ffffff88", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	label.add_theme_constant_override("letter_spacing", 2)
	return label


func _make_icon(key: String, icon_size: int, tint: Color = Color.WHITE) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = load(ICON_PATHS[key])
	icon.custom_minimum_size = Vector2(icon_size, icon_size)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.modulate = tint
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


func _make_flat_button(text: String, color: String, size: int) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", size)
	button.add_theme_color_override("font_color", Color(color))
	_apply_button_style(button, _make_style("#00000000", 0))
	return button


func _make_solid_button(text: String, bg: String, color: String, width: float, height: float) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(width, height)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color(color))
	_apply_button_style(button, _make_style(bg, 10, "#ffffff22", 1))
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


func _fill(control: Control) -> void:
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 1.0
	control.anchor_bottom = 1.0
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0


func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	_audio_muted = bool(parsed.get("audio_muted", parsed.get("master_muted", false)))
	_language = String(parsed.get("language", "pt"))


func _save_settings() -> void:
	var data := {
		"audio_muted": _audio_muted,
		"master_muted": _audio_muted,
		"music_muted": _audio_muted,
		"sfx_muted": _audio_muted,
		"language": _language,
	}
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))


func _go_back() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)

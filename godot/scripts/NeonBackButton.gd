extends RefCounted

const WIDTH := 180.0
const HEIGHT := 52.0
const BOTTOM_MARGIN := 22.0
const CONTENT_BOTTOM_PADDING := 92.0


static func add_to(parent: Control, target: Callable) -> Button:
	var button := Button.new()
	button.text = _label()
	button.custom_minimum_size = Vector2(WIDTH, HEIGHT)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.z_index = 100
	button.anchor_left = 0.5
	button.anchor_right = 0.5
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = -WIDTH / 2.0
	button.offset_right = WIDTH / 2.0
	button.offset_top = -HEIGHT - BOTTOM_MARGIN
	button.offset_bottom = -BOTTOM_MARGIN
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Arial", "Helvetica", "Noto Sans", "DejaVu Sans", "sans-serif"])
	font.font_weight = 700
	button.add_theme_font_override("font", font)
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", Color("#001018"))
	var style := _make_style("#00f0ff", 12, "#ffffff33", 1, "#00f0ff99", 12)
	_apply_style(button, style)
	button.pressed.connect(target)
	parent.add_child(button)
	return button


static func _label() -> String:
	if Engine.has_singleton("LocalizationManager"):
		return LocalizationManager.tr_key("back")
	if Engine.get_main_loop() and Engine.get_main_loop().root.has_node("LocalizationManager"):
		return Engine.get_main_loop().root.get_node("LocalizationManager").tr_key("back")
	return "Back"


static func reserve_footer_space(control: Control) -> void:
	control.offset_bottom = -CONTENT_BOTTOM_PADDING


static func _make_style(bg_color: String, radius: int, border_color: String, border_width: int, shadow_color: String, shadow_size: int) -> StyleBoxFlat:
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


static func _apply_style(button: Button, style: StyleBoxFlat) -> void:
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_stylebox_override("disabled", style)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

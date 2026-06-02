extends Control

const PLACEHOLDER_SCENE := "res://scenes/Placeholder.tscn"
const PROFILE_SCENE := "res://scenes/Profile.tscn"
const SETTINGS_SCENE := "res://scenes/Settings.tscn"
const SKINS_SCENE := "res://scenes/Skins.tscn"
const UPGRADES_SCENE := "res://scenes/Upgrades.tscn"
const SHOP_SCENE := "res://scenes/Shop.tscn"
const INVENTORY_SCENE := "res://scenes/Inventory.tscn"
const MISSIONS_SCENE := "res://scenes/Missions.tscn"
const EVENT_SCENE := "res://scenes/Event.tscn"
const WHEEL_SCENE := "res://scenes/Wheel.tscn"
const DAILY_REWARD_SCENE := "res://scenes/DailyReward.tscn"
const BOSS_SCENE := "res://scenes/Boss.tscn"
const LEAGUE_SCENE := "res://scenes/League.tscn"
const ACHIEVEMENTS_SCENE := "res://scenes/Achievements.tscn"

const ICON_PATHS := {
	"coin": "res://assets/ui/ui_coin.png",
	"gem": "res://assets/ui/ui_gem.png",
	"key": "res://assets/ui/ui_key.png",
	"play": "res://assets/ui/ui_play.png",
	"upgrades": "res://assets/ui/ui_upgrades.png",
	"skins": "res://assets/ui/ui_skins.png",
	"menu": "res://assets/ui/ui_menu.png",
	"shop": "res://assets/ui/ui_store.png",
	"inventory": "res://assets/ui/ui_inventory.png",
	"missions": "res://assets/ui/ui_missions.png",
	"event": "res://assets/ui/ui_event.png",
	"wheel": "res://assets/ui/ui_wheel.png",
	"daily_reward": "res://assets/ui/ui_daily_reward.png",
	"boss": "res://assets/ui/ui_boss.png",
	"league": "res://assets/ui/ui_league_neon.png",
	"achievements": "res://assets/ui/ui_achievements.png",
	"settings": "res://assets/ui/ui_settings.png",
}

const SECONDARY_ITEMS := [
	{ "label": "Shop", "icon": "shop", "color": "#00aaff88", "scene": SHOP_SCENE },
	{ "label": "Inventory", "icon": "inventory", "color": "#ffd70088", "scene": INVENTORY_SCENE },
	{ "label": "Missions", "icon": "missions", "color": "#ff880088", "scene": MISSIONS_SCENE },
	{ "label": "Event", "icon": "event", "color": "#00ff8888", "scene": EVENT_SCENE },
	{ "label": "Wheel", "icon": "wheel", "color": "#00ff8888", "scene": WHEEL_SCENE },
	{ "label": "Daily Reward", "icon": "daily_reward", "color": "#ffd70088", "scene": DAILY_REWARD_SCENE },
	{ "label": "Boss", "icon": "boss", "color": "#ff005588", "scene": BOSS_SCENE },
	{ "label": "Neon League", "icon": "league", "color": "#00ff8888", "scene": LEAGUE_SCENE },
	{ "label": "Achievements", "icon": "achievements", "color": "#ffd70088", "scene": ACHIEVEMENTS_SCENE },
	{ "label": "Settings", "icon": "settings", "color": "#b8f3ff88", "scene": SETTINGS_SCENE },
]

const ROUND_GRADIENT_SHADER := """
shader_type canvas_item;

uniform vec4 color_a : source_color = vec4(1.0);
uniform vec4 color_b : source_color = vec4(1.0);
uniform vec4 border_color : source_color = vec4(1.0);
uniform float radius = 16.0;
uniform float border_width = 0.0;
uniform float diagonal = 0.0;
uniform vec2 rect_size = vec2(1.0, 1.0);

float rounded_box_sdf(vec2 point, vec2 half_size, float corner_radius) {
	vec2 q = abs(point) - half_size + vec2(corner_radius);
	return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - corner_radius;
}

void fragment() {
	vec2 current_size = max(rect_size, vec2(1.0, 1.0));
	vec2 half_size = current_size * 0.5;
	float safe_radius = min(radius, min(half_size.x, half_size.y));
	float distance = rounded_box_sdf((UV * current_size) - half_size, half_size, safe_radius);
	if (distance > 0.0) {
		discard;
	}

	float blend_value = mix(UV.y, (UV.x + UV.y) * 0.5, diagonal);
	vec4 fill_color = mix(color_a, color_b, clamp(blend_value, 0.0, 1.0));
	if (border_width > 0.0 && distance > -border_width) {
		fill_color = border_color;
	}
	COLOR = fill_color;
}
"""

var _regular_font: Font
var _bold_font: Font
var _gradient_shader: Shader
var _click_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer
var _more_overlay: ColorRect
var _more_panel: PanelContainer
var _more_items: Array = []


func _ready() -> void:
	_regular_font = _make_system_font(400)
	_bold_font = _make_system_font(700)
	_gradient_shader = Shader.new()
	_gradient_shader.code = ROUND_GRADIENT_SHADER

	_build_audio()
	_build_background()
	_build_top_bar()
	_build_content()
	_build_more_button()
	_build_more_modal()

	resized.connect(_sync_modal_layout)
	call_deferred("_sync_modal_layout")


func _build_audio() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.stream = load("res://assets/music/menu.mp3")
	_music_player.volume_db = linear_to_db(0.38)
	_music_player.autoplay = true
	add_child(_music_player)
	_music_player.play()

	_click_player = AudioStreamPlayer.new()
	_click_player.stream = load("res://assets/sounds/button_click.mp3")
	_click_player.volume_db = linear_to_db(0.287)
	add_child(_click_player)


func _build_background() -> void:
	var background := TextureRect.new()
	_fill(background)
	background.texture = _make_background_gradient()
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)


func _build_top_bar() -> void:
	var top_bar := VBoxContainer.new()
	top_bar.anchor_left = 0.0
	top_bar.anchor_top = 0.0
	top_bar.anchor_right = 1.0
	top_bar.anchor_bottom = 0.0
	top_bar.offset_left = 18.0
	top_bar.offset_top = 50.0
	top_bar.offset_right = -18.0
	top_bar.offset_bottom = 150.0
	top_bar.add_theme_constant_override("separation", 10)
	add_child(top_bar)

	top_bar.add_child(_make_profile_badge())

	var resources := HBoxContainer.new()
	resources.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	resources.add_theme_constant_override("separation", 8)
	top_bar.add_child(resources)

	resources.add_child(_make_resource_pill("coin", "600"))
	resources.add_child(_make_resource_pill("gem", "60"))
	resources.add_child(_make_resource_pill("key", "1"))


func _build_content() -> void:
	var content := VBoxContainer.new()
	content.anchor_left = 0.0
	content.anchor_top = 0.0
	content.anchor_right = 1.0
	content.anchor_bottom = 1.0
	content.offset_left = 20.0
	content.offset_top = 152.0
	content.offset_right = -20.0
	content.offset_bottom = -96.0
	content.add_theme_constant_override("separation", 0)
	add_child(content)

	content.add_child(_spacer(22))

	var title_container := VBoxContainer.new()
	title_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_container.add_theme_constant_override("separation", 0)
	content.add_child(title_container)

	var title := _make_label("NEON", 60, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	title.add_theme_constant_override("letter_spacing", 6)
	title.add_theme_color_override("font_outline_color", Color("#00f0ff88"))
	title.add_theme_constant_override("outline_size", 8)
	title.custom_minimum_size.y = 70.0
	title_container.add_child(title)

	var subtitle := _make_label("IDLE ESCAPE", 18, "#ffffff", _regular_font, HORIZONTAL_ALIGNMENT_CENTER)
	subtitle.add_theme_constant_override("letter_spacing", 7)
	subtitle.custom_minimum_size.y = 24.0
	title_container.add_child(subtitle)

	content.add_child(_spacer(26))
	content.add_child(_make_play_button())
	content.add_child(_spacer(12))

	var primary_row := HBoxContainer.new()
	primary_row.custom_minimum_size.y = 92.0
	primary_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	primary_row.add_theme_constant_override("separation", 12)
	content.add_child(primary_row)

	var upgrades := _make_primary_card("upgrades", "UPGRADES", "#b000ff66", "#6600cc33")
	upgrades.pressed.connect(_open_scene.bind(UPGRADES_SCENE))
	primary_row.add_child(upgrades)

	var skins := _make_primary_card("skins", "SKINS", "#ff008866", "#cc006633")
	skins.pressed.connect(_open_scene.bind(SKINS_SCENE))
	primary_row.add_child(skins)


func _build_more_button() -> void:
	var more_button := Button.new()
	_clear_button_styles(more_button)
	more_button.focus_mode = Control.FOCUS_NONE
	more_button.anchor_left = 1.0
	more_button.anchor_top = 1.0
	more_button.anchor_right = 1.0
	more_button.anchor_bottom = 1.0
	more_button.offset_left = -82.0
	more_button.offset_top = -88.0
	more_button.offset_right = -18.0
	more_button.offset_bottom = -24.0
	_apply_button_style(more_button, _make_style("#00f0ff", 18, "#00000000", 0, "#00f0ffe6", 14))
	more_button.pressed.connect(_show_more_modal)
	add_child(more_button)

	var content := VBoxContainer.new()
	_fill(content)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 0)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	more_button.add_child(content)

	var icon := _make_icon("menu", 26, Color("#001018"))
	content.add_child(icon)

	var label := _make_label("More", 11, "#001018", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	label.custom_minimum_size.x = 64.0
	content.add_child(label)


func _build_more_modal() -> void:
	_more_overlay = ColorRect.new()
	_fill(_more_overlay)
	_more_overlay.color = Color("#000000cc")
	_more_overlay.visible = false
	_more_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_more_overlay)

	var center := CenterContainer.new()
	_fill(center)
	center.offset_left = 18.0
	center.offset_top = 18.0
	center.offset_right = -18.0
	center.offset_bottom = -18.0
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_more_overlay.add_child(center)

	_more_panel = PanelContainer.new()
	_more_panel.add_theme_stylebox_override("panel", _make_style("#1a0a2e", 18, "#00f0ff66", 1))
	center.add_child(_more_panel)

	var panel_margin := MarginContainer.new()
	panel_margin.add_theme_constant_override("margin_left", 16)
	panel_margin.add_theme_constant_override("margin_top", 16)
	panel_margin.add_theme_constant_override("margin_right", 16)
	panel_margin.add_theme_constant_override("margin_bottom", 16)
	_more_panel.add_child(panel_margin)

	var panel_content := VBoxContainer.new()
	panel_content.add_theme_constant_override("separation", 12)
	panel_margin.add_child(panel_content)

	var header := HBoxContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_content.add_child(header)

	var title := _make_label("Menu", 24, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var close := Button.new()
	close.focus_mode = Control.FOCUS_NONE
	_clear_button_styles(close)
	close.text = "Close"
	close.add_theme_color_override("font_color", Color("#ffffffaa"))
	close.add_theme_font_override("font", _bold_font)
	close.pressed.connect(_hide_more_modal)
	header.add_child(close)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	panel_content.add_child(grid)

	for item in SECONDARY_ITEMS:
		var more_item := _make_more_item(item)
		_more_items.append(more_item)
		grid.add_child(more_item)


func _make_profile_badge() -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(126, 50)
	button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	button.focus_mode = Control.FOCUS_NONE
	_clear_button_styles(button)
	_apply_button_style(button, _make_style("#ffffff12", 14, "#ffffff22", 1))
	button.pressed.connect(_open_profile)

	var margin := MarginContainer.new()
	_fill(margin)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)

	row.add_child(_make_avatar())

	var text_column := VBoxContainer.new()
	text_column.add_theme_constant_override("separation", 0)
	text_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(text_column)

	text_column.add_child(_make_label("Player", 14, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	text_column.add_child(_make_label("Lv.1", 12, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	return button


func _make_avatar() -> Control:
	var outer := PanelContainer.new()
	outer.custom_minimum_size = Vector2(34, 34)
	outer.add_theme_stylebox_override("panel", _make_style("#ffffff14", 17, "#ffffff55", 1, "#00f0ff59", 8))
	outer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer.add_child(center)

	var dot := Panel.new()
	dot.custom_minimum_size = Vector2(19, 19)
	dot.add_theme_stylebox_override("panel", _make_style("#1f7dff", 10))
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(dot)
	return outer


func _make_resource_pill(icon_key: String, value: String) -> PanelContainer:
	var pill := PanelContainer.new()
	pill.add_theme_stylebox_override("panel", _make_style("#ffffff12", 10, "#ffffff22", 1))
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 7)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)

	row.add_child(_make_icon(icon_key, 18))
	row.add_child(_make_label(value, 14, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	return pill


func _make_play_button() -> Button:
	var button := _make_gradient_button(78, 16, "#00f0ff", "#0088ff", "#00000000", 0, true, "#00f0ffcc", 18)
	button.pressed.connect(_open_placeholder)

	var content := HBoxContainer.new()
	_fill(content)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 12)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(content)

	content.add_child(_make_icon("play", 32, Color("#ffffff")))

	var label := _make_label("PLAY", 30, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	label.add_theme_constant_override("letter_spacing", 3)
	content.add_child(label)
	return button


func _make_primary_card(icon_key: String, text: String, color_a: String, color_b: String) -> Button:
	var button := _make_gradient_button(92, 14, color_a, color_b, "#ffffff24", 1, false)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var content := VBoxContainer.new()
	_fill(content)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 6)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(content)

	content.add_child(_make_icon(icon_key, 42))

	var label := _make_label(text, 13, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	label.add_theme_constant_override("letter_spacing", 1)
	label.custom_minimum_size.x = 150.0
	content.add_child(label)
	return button


func _make_more_item(item: Dictionary) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(150, 76)
	button.focus_mode = Control.FOCUS_NONE
	_clear_button_styles(button)
	_apply_button_style(button, _make_style("#ffffff12", 12, item["color"], 1))
	if item.has("scene"):
		button.pressed.connect(_open_scene.bind(String(item["scene"])))
	else:
		button.pressed.connect(_open_placeholder)

	var content := VBoxContainer.new()
	_fill(content)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 5)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(content)

	content.add_child(_make_icon(item["icon"], 34))

	var label := _make_label(item["label"], 12, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = 132.0
	content.add_child(label)
	return button


func _make_gradient_button(
	height: float,
	radius: float,
	color_a: String,
	color_b: String,
	border_color: String,
	border_width: float,
	diagonal: bool,
	shadow_color: String = "#00000000",
	shadow_size: int = 0
) -> Button:
	var button := Button.new()
	button.custom_minimum_size.y = height
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.clip_contents = false
	_clear_button_styles(button)

	if shadow_size > 0:
		var shadow := Panel.new()
		_fill(shadow)
		shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		shadow.add_theme_stylebox_override("panel", _make_style(color_a, radius, "#00000000", 0, shadow_color, shadow_size))
		button.add_child(shadow)

	var fill := ColorRect.new()
	_fill(fill)
	fill.color = Color.WHITE
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = _gradient_shader
	material.set_shader_parameter("color_a", Color(color_a))
	material.set_shader_parameter("color_b", Color(color_b))
	material.set_shader_parameter("border_color", Color(border_color))
	material.set_shader_parameter("border_width", border_width)
	material.set_shader_parameter("radius", radius)
	material.set_shader_parameter("diagonal", 1.0 if diagonal else 0.0)
	fill.material = material
	fill.resized.connect(_sync_gradient_material.bind(fill, material))
	button.add_child(fill)
	return button


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
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


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


func _make_system_font(weight: int) -> SystemFont:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Arial", "Helvetica", "Noto Sans", "DejaVu Sans", "sans-serif"])
	font.font_weight = weight
	return font


func _make_style(
	bg_color: String,
	radius: int,
	border_color: String = "#00000000",
	border_width: int = 0,
	shadow_color: String = "#00000000",
	shadow_size: int = 0
) -> StyleBoxFlat:
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


func _clear_button_styles(button: Button) -> void:
	var empty := StyleBoxEmpty.new()
	button.text = ""
	button.add_theme_stylebox_override("normal", empty)
	button.add_theme_stylebox_override("hover", empty)
	button.add_theme_stylebox_override("pressed", empty)
	button.add_theme_stylebox_override("disabled", empty)
	button.add_theme_stylebox_override("focus", empty)


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


func _sync_gradient_material(fill: Control, material: ShaderMaterial) -> void:
	material.set_shader_parameter("rect_size", Vector2(max(fill.size.x, 1.0), max(fill.size.y, 1.0)))


func _sync_modal_layout() -> void:
	if _more_panel == null:
		return

	var panel_width: float = min(430.0, max(280.0, size.x - 36.0))
	_more_panel.custom_minimum_size.x = panel_width
	var item_width: float = max(120.0, floor((panel_width - 32.0 - 10.0) / 2.0))
	for item in _more_items:
		item.custom_minimum_size = Vector2(item_width, 76.0)


func _show_more_modal() -> void:
	_more_overlay.visible = true


func _hide_more_modal() -> void:
	_more_overlay.visible = false


func _open_placeholder() -> void:
	_open_scene(PLACEHOLDER_SCENE)


func _open_profile() -> void:
	_open_scene(PROFILE_SCENE)


func _open_scene(scene_path: String) -> void:
	if _more_overlay != null:
		_more_overlay.visible = false
	_play_click()
	get_tree().change_scene_to_file(scene_path)


func _play_click() -> void:
	if _click_player == null:
		return
	_click_player.stop()
	_click_player.play()

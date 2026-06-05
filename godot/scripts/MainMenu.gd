extends Control

const PLACEHOLDER_SCENE := "res://scenes/Placeholder.tscn"
const PROFILE_SCENE := "res://scenes/Profile.tscn"
const SETTINGS_SCENE := "res://scenes/Settings.tscn"
const SKINS_SCENE := "res://scenes/Skins.tscn"
const UPGRADES_SCENE := "res://scenes/Upgrades.tscn"
const PHASE_SELECT_SCENE := "res://scenes/PhaseSelect.tscn"
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
var _more_overlay: ColorRect
var _more_panel: PanelContainer
var _more_items: Array = []
var _opening_achievements := false
var _achievement_notice: Button
var _achievement_notice_hide_at := 0
var _tutorial_overlay: Control
var _tutorial_page := 0
var _tutorial_dont_show := false
var _guided_hint: Button
var _guided_hint_id := ""

const TUTORIAL_STEPS := [
	{ "en_title": "Welcome", "pt_title": "Bem-vindo", "es_title": "Bienvenido", "ja_title": "ようこそ", "zh_title": "欢迎", "en_text": "Break rings by hitting their opening.", "pt_text": "Quebre os anéis acertando a abertura.", "es_text": "Rompe anillos acertando su abertura.", "ja_text": "開口部を狙ってリングを壊しましょう。", "zh_text": "击中开口来击破圆环。" },
	{ "en_title": "Progress", "pt_title": "Progresso", "es_title": "Progreso", "ja_title": "進行", "zh_title": "进度", "en_text": "Earn coins, XP, diamonds and chests.", "pt_text": "Ganhe moedas, XP, diamantes e baús.", "es_text": "Gana monedas, XP, diamantes y cofres.", "ja_text": "コイン、XP、ダイヤ、宝箱を獲得。", "zh_text": "获得金币、经验、钻石和宝箱。" },
	{ "en_title": "Upgrades", "pt_title": "Melhorias", "es_title": "Mejoras", "ja_title": "強化", "zh_title": "升级", "en_text": "Use upgrades to get stronger.", "pt_text": "Use melhorias para ficar mais forte.", "es_text": "Usa mejoras para hacerte más fuerte.", "ja_text": "強化でさらに強くなりましょう。", "zh_text": "使用升级变得更强。" },
	{ "en_title": "Skins", "pt_title": "Skins", "es_title": "Skins", "ja_title": "スキン", "zh_title": "皮肤", "en_text": "Collect skins with special effects.", "pt_text": "Colecione skins com efeitos especiais.", "es_text": "Colecciona skins con efectos especiales.", "ja_text": "特殊効果つきスキンを集めましょう。", "zh_text": "收集带特殊效果的皮肤。" },
	{ "en_title": "Modes", "pt_title": "Modos", "es_title": "Modos", "ja_title": "モード", "zh_title": "模式", "en_text": "Play levels, infinite mode, bosses, daily challenges and Neon League.", "pt_text": "Jogue fases, modo infinito, chefes, desafios diários e Liga Neon.", "es_text": "Juega niveles, modo infinito, bosses, desafíos diarios y Liga Neon.", "ja_text": "レベル、無限、ボス、デイリー、ネオンリーグで遊べます。", "zh_text": "游玩关卡、无限模式、Boss、每日挑战和霓虹联赛。" },
]


func _ready() -> void:
	_regular_font = _make_system_font(400)
	_bold_font = _make_system_font(700)
	_gradient_shader = Shader.new()
	_gradient_shader.code = ROUND_GRADIENT_SHADER

	if has_node("/root/AudioManager"):
		AudioManager.play_context("menu")
	_build_background()
	_build_top_bar()
	_build_content()
	_build_achievement_notice_overlay()
	call_deferred("_maybe_show_tutorial_or_hint")


func _process(_delta: float) -> void:
	if _achievement_notice_hide_at > 0 and Time.get_ticks_msec() >= _achievement_notice_hide_at:
		_hide_achievement_notice()
	_build_more_button()
	_build_more_modal()

	resized.connect(_sync_modal_layout)
	call_deferred("_sync_modal_layout")


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

	resources.add_child(_make_resource_pill("coin", str(GameState.data.get("coins", 0))))
	resources.add_child(_make_resource_pill("gem", str(GameState.data.get("diamonds", 0))))
	resources.add_child(_make_resource_pill("key", str(GameState.data.get("keys", 0))))


func _build_achievement_notice_overlay() -> void:
	var pending := _pending_achievement_count()
	if pending > 0:
		var signature := _pending_achievement_signature()
		if String(GameState.data.get("achievement_notice_seen_signature", "")) == signature:
			return
		var notice := _make_achievement_notice(pending)
		_achievement_notice = notice
		notice.anchor_left = 0.0
		notice.anchor_top = 1.0
		notice.anchor_right = 0.0
		notice.anchor_bottom = 1.0
		notice.offset_left = 18.0
		notice.offset_top = -146.0
		notice.offset_right = 254.0
		notice.offset_bottom = -106.0
		notice.z_index = 30
		add_child(notice)
		GameState.data["achievement_notice_seen_signature"] = signature
		GameState.save_game()
		_achievement_notice_hide_at = Time.get_ticks_msec() + 5200


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


func _pending_achievement_count() -> int:
	GameState._update_achievements(false)
	var count := 0
	for id in Dictionary(GameState.data.get("achievements", {})).keys():
		var state: Dictionary = GameState.data["achievements"][id]
		if bool(state.get("completed", false)) and not bool(state.get("claimed", false)):
			count += 1
	return count


func _pending_achievement_signature() -> String:
	GameState._update_achievements(false)
	var ids: Array[String] = []
	for id in Dictionary(GameState.data.get("achievements", {})).keys():
		var state: Dictionary = GameState.data["achievements"][id]
		if bool(state.get("completed", false)) and not bool(state.get("claimed", false)):
			ids.append(String(id))
	ids.sort()
	return "|".join(ids)


func _make_achievement_notice(count: int) -> Button:
	var button := Button.new()
	_clear_button_styles(button)
	button.custom_minimum_size = Vector2(220, 36)
	button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_apply_button_style(button, _make_style("#ffd70022", 12, "#ffd700aa", 1, "#ffd70077", 10))
	button.pressed.connect(_open_achievements_scene)
	button.button_down.connect(_open_achievements_scene)
	button.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventScreenTouch and event.pressed:
			_open_achievements_scene()
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_open_achievements_scene()
	)
	var row := HBoxContainer.new()
	_fill(row)
	row.offset_left = 10
	row.offset_right = -10
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(row)
	row.add_child(_make_icon("achievements", 24, Color("#ffd700")))
	var detail := _txt("%s rewards pending", "%s recompensas pendentes", "%s recompensas pendientes", "%s個の報酬待ち", "%s个奖励待领取") % count
	var label := _make_label(detail, 11, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.clip_text = true
	label.custom_minimum_size.x = 168
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(label)
	return button


func _hide_achievement_notice() -> void:
	_achievement_notice_hide_at = 0
	if not is_instance_valid(_achievement_notice):
		return
	var notice := _achievement_notice
	_achievement_notice = null
	var tween := create_tween()
	tween.tween_property(notice, "modulate:a", 0.0, 0.35)
	tween.parallel().tween_property(notice, "position:y", notice.position.y - 8.0, 0.35)
	tween.tween_callback(notice.queue_free)


func _open_achievements_scene() -> void:
	if _opening_achievements:
		return
	_opening_achievements = true
	call_deferred("_deferred_open_achievements_scene")


func _deferred_open_achievements_scene() -> void:
	_open_scene(ACHIEVEMENTS_SCENE)


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

	var label := _make_label(_menu_label("more"), 11, "#001018", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
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

	var title := _make_label(_menu_label("menu"), 24, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var close := Button.new()
	close.focus_mode = Control.FOCUS_NONE
	_clear_button_styles(close)
	close.text = _menu_label("close")
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

	text_column.add_child(_make_label(String(GameState.data.get("nickname", "Player")), 14, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	text_column.add_child(_make_label("Lv.%s" % GameState.data.get("level", 1), 12, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	return button


func _make_avatar() -> Control:
	var outer := PanelContainer.new()
	outer.custom_minimum_size = Vector2(34, 34)
	outer.add_theme_stylebox_override("panel", _make_style("#ffffff14", 17, "#ffffff55", 1, "#00f0ff59", 8))
	outer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer.add_child(center)

	var icon := TextureRect.new()
	icon.texture = _avatar_texture()
	icon.custom_minimum_size = Vector2(25, 25)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(icon)
	return outer


func _avatar_texture() -> Texture2D:
	var custom_path := String(GameState.data.get("avatar_image_path", ""))
	if not custom_path.is_empty() and FileAccess.file_exists(custom_path):
		var image := Image.new()
		if image.load(custom_path) == OK:
			return ImageTexture.create_from_image(image)
	var avatar := String(GameState.data.get("avatar", ""))
	var skin_id := avatar.trim_prefix("skin:") if avatar.begins_with("skin:") else String(GameState.data.get("favorite_skin", GameState.data.get("equipped_skin", "neon_blue")))
	var path := "res://assets/skins/%s.png" % skin_id
	if ResourceLoader.exists(path):
		return load(path)
	return load("res://assets/skins/neon_blue.png")


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
	button.pressed.connect(_open_scene.bind(PHASE_SELECT_SCENE))

	var content := HBoxContainer.new()
	_fill(content)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 12)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(content)

	content.add_child(_make_icon("play", 32, Color("#ffffff")))

	var label := _make_label(_menu_label("play").to_upper(), 30, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
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

	var label := _make_label(_menu_label(icon_key).to_upper(), 13, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
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

	var label := _make_label(_menu_label(String(item["icon"])), 12, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = 132.0
	content.add_child(label)
	return button


func _menu_label(key: String) -> String:
	match key:
		"more": return _txt("More", "Mais", "Más", "もっと", "更多")
		"menu": return _txt("Menu", "Menu", "Menú", "メニュー", "菜单")
		"close": return _tr("close")
		"play": return _tr("play")
		"upgrades": return _tr("upgrades")
		"skins": return _tr("skins")
		"shop": return _tr("shop")
		"inventory": return _tr("inventory")
		"missions": return _tr("missions")
		"event": return _tr("event")
		"wheel": return _tr("wheel")
		"daily_reward": return _tr("daily_reward")
		"boss": return _tr("boss")
		"league": return _tr("league")
		"achievements": return _tr("achievements")
		"settings": return _tr("settings")
	return key


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


func _maybe_show_tutorial_or_hint() -> void:
	if GameState.should_show_tutorial():
		_show_tutorial_overlay()
	else:
		_show_guided_hint_if_needed()


func _show_tutorial_overlay() -> void:
	if is_instance_valid(_tutorial_overlay):
		_tutorial_overlay.queue_free()
	_tutorial_page = 0
	_tutorial_dont_show = false
	_tutorial_overlay = Control.new()
	_fill(_tutorial_overlay)
	_tutorial_overlay.z_index = 120
	_tutorial_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_tutorial_overlay)
	_render_tutorial_page()


func _render_tutorial_page() -> void:
	if not is_instance_valid(_tutorial_overlay):
		return
	for child in _tutorial_overlay.get_children():
		child.queue_free()
	var dim := ColorRect.new()
	_fill(dim)
	dim.color = Color("#03000acc")
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_tutorial_overlay.add_child(dim)
	var center := CenterContainer.new()
	_fill(center)
	center.offset_left = 18
	center.offset_top = 22
	center.offset_right = -18
	center.offset_bottom = -22
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tutorial_overlay.add_child(center)
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(326, 360)
	card.add_theme_stylebox_override("panel", _make_style("#150724f2", 18, "#00f0ffaa", 2, "#00f0ff55", 18))
	center.add_child(card)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	card.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	var step: Dictionary = TUTORIAL_STEPS[_tutorial_page]
	var lang := _language()
	var title := _make_label(String(step.get("%s_title" % lang, step.get("en_title", ""))), 28, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	title.add_theme_color_override("font_outline_color", Color("#00f0ff66"))
	title.add_theme_constant_override("outline_size", 5)
	column.add_child(title)
	column.add_child(_make_label("%s / %s" % [_tutorial_page + 1, TUTORIAL_STEPS.size()], 12, "#ffffff99", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	var icon_keys: Array[String] = ["play", "coin", "upgrades", "skins", "league"]
	var icon_key: String = icon_keys[_tutorial_page]
	var icon_holder := CenterContainer.new()
	icon_holder.custom_minimum_size.y = 74
	icon_holder.add_child(_make_icon(icon_key, 58, Color("#00f0ff")))
	column.add_child(icon_holder)
	var body := _make_label(String(step.get("%s_text" % lang, step.get("en_text", ""))), 17, "#ffffff", _regular_font, HORIZONTAL_ALIGNMENT_CENTER)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(276, 64)
	column.add_child(body)
	var dont_show := _make_tutorial_button(_tutorial_label("dont_show"), "#ffd70022", "#ffd700aa", _toggle_tutorial_dont_show)
	dont_show.custom_minimum_size.y = 40
	column.add_child(dont_show)
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 8)
	nav.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(nav)
	var back := _make_tutorial_button(_tutorial_label("back"), "#ffffff12", "#ffffff55", _tutorial_back)
	back.disabled = _tutorial_page <= 0
	nav.add_child(back)
	nav.add_child(_make_tutorial_button(_tutorial_label("skip"), "#ff005522", "#ff0055aa", _tutorial_skip))
	var next_label := _tutorial_label("start") if _tutorial_page >= TUTORIAL_STEPS.size() - 1 else _tutorial_label("next")
	nav.add_child(_make_tutorial_button(next_label, "#00f0ff", "#00f0ff", _tutorial_next_or_start))


func _make_tutorial_button(text: String, bg: String, border: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 44)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", Color("#001018") if bg == "#00f0ff" else Color("#ffffff"))
	_apply_button_style(button, _make_style(bg, 12, border, 1, border.replace("aa", "55"), 8))
	button.pressed.connect(callback)
	return button


func _toggle_tutorial_dont_show() -> void:
	_tutorial_dont_show = true
	GameState.set_tutorial_dont_show_again(true)
	_close_tutorial_overlay()


func _tutorial_back() -> void:
	_tutorial_page = maxi(0, _tutorial_page - 1)
	_render_tutorial_page()


func _tutorial_skip() -> void:
	GameState.mark_tutorial_seen(_tutorial_dont_show)
	_close_tutorial_overlay()


func _tutorial_next_or_start() -> void:
	if _tutorial_page >= TUTORIAL_STEPS.size() - 1:
		GameState.mark_tutorial_seen(_tutorial_dont_show)
		_close_tutorial_overlay()
		return
	_tutorial_page += 1
	_render_tutorial_page()


func _close_tutorial_overlay() -> void:
	if is_instance_valid(_tutorial_overlay):
		_tutorial_overlay.queue_free()
	_tutorial_overlay = null
	call_deferred("_show_guided_hint_if_needed")


func _show_guided_hint_if_needed() -> void:
	if is_instance_valid(_guided_hint):
		return
	var hint_id := GameState.get_guided_hint_id()
	if hint_id.is_empty():
		return
	_guided_hint_id = hint_id
	_guided_hint = _make_guided_hint(hint_id)
	_guided_hint.anchor_left = 0.0
	_guided_hint.anchor_top = 1.0
	_guided_hint.anchor_right = 1.0
	_guided_hint.anchor_bottom = 1.0
	_guided_hint.offset_left = 20.0
	_guided_hint.offset_top = -158.0
	_guided_hint.offset_right = -96.0
	_guided_hint.offset_bottom = -96.0
	_guided_hint.z_index = 35
	add_child(_guided_hint)


func _make_guided_hint(hint_id: String) -> Button:
	var button := Button.new()
	_clear_button_styles(button)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_apply_button_style(button, _make_style("#00f0ff22", 14, "#00f0ffaa", 1, "#00f0ff66", 12))
	button.pressed.connect(_activate_guided_hint)
	var row := HBoxContainer.new()
	_fill(row)
	row.offset_left = 12
	row.offset_right = -12
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 9)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(row)
	row.add_child(_make_icon(_guided_hint_icon(hint_id), 28, Color("#00f0ff")))
	var label := _make_label(_guided_hint_text(hint_id), 12, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(label)
	return button


func _activate_guided_hint() -> void:
	var hint_id := _guided_hint_id
	GameState.mark_guided_hint_done(hint_id)
	if is_instance_valid(_guided_hint):
		_guided_hint.queue_free()
	_guided_hint = null
	_guided_hint_id = ""
	match hint_id:
		"open_upgrades":
			_open_scene(UPGRADES_SCENE)
		"open_skins":
			_open_scene(SKINS_SCENE)
		"modes":
			_open_scene(PHASE_SELECT_SCENE)


func _guided_hint_icon(hint_id: String) -> String:
	match hint_id:
		"open_upgrades":
			return "upgrades"
		"open_skins":
			return "skins"
	return "play"


func _guided_hint_text(hint_id: String) -> String:
	match hint_id:
		"open_upgrades": return _txt("Tap here to upgrade your ball.", "Toque aqui para melhorar sua bolinha.", "Toca aquí para mejorar tu bola.", "ここをタップしてボールを強化。", "点这里升级你的球。")
		"open_skins": return _txt("Now check and equip special skins.", "Agora veja e equipe skins especiais.", "Ahora mira y equipa skins especiales.", "特別なスキンを確認して装備しましょう。", "现在查看并装备特殊皮肤。")
		"modes": return _txt("Events, challenges and Infinite unlock more rewards.", "Eventos, desafios e Infinito liberam novas recompensas.", "Eventos, desafíos e Infinito desbloquean más recompensas.", "イベント、チャレンジ、無限で報酬が増えます。", "活动、挑战和无限模式会解锁更多奖励。")
	return ""


func _tutorial_label(id: String) -> String:
	match id:
		"next": return _txt("Next", "Próximo", "Siguiente", "次へ", "下一步")
		"back": return _tr("back")
		"skip": return _txt("Skip", "Pular", "Saltar", "スキップ", "跳过")
		"start": return _txt("Start", "Começar", "Comenzar", "開始", "开始")
		"dont_show": return _txt("Don't show again", "Não mostrar novamente", "No mostrar de nuevo", "今後表示しない", "不再显示")
	return id


func _language() -> String:
	return LocalizationManager.current_language() if has_node("/root/LocalizationManager") else String(GameState.get_setting("language", "en"))


func _tr(key: String, fallback := "") -> String:
	return LocalizationManager.tr_key(key, fallback) if has_node("/root/LocalizationManager") else (fallback if not fallback.is_empty() else key)


func _txt(en: String, pt := "", es := "", ja := "", zh := "") -> String:
	return LocalizationManager.text(en, pt, es, ja, zh) if has_node("/root/LocalizationManager") else en


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
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("res://assets/sounds/button_click.mp3", -7.0)

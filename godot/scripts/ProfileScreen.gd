extends Control

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const NeonBackButtonScript := preload("res://scripts/NeonBackButton.gd")

const ICON_PATHS := {
	"coin": "res://assets/ui/ui_coin.png",
	"gem": "res://assets/ui/ui_gem.png",
	"key": "res://assets/ui/ui_key.png",
	"legendary_key": "res://assets/ui/ui_legendary_key.png",
	"achievements": "res://assets/ui/ui_achievements.png",
	"camera": "res://assets/ui/ui_camera.png",
	"locked": "res://assets/ui/ui_locked.png",
	"league": "res://assets/ui/ui_league_neon.png",
	"mute_on": "res://assets/ui/ui_mute_on.png",
	"mute_off": "res://assets/ui/ui_mute_off.png",
	"xp": "res://assets/ui/ui_xp.png",
}

const AVATARS := ["B", "P", "C", "G", "R", "F", "N", "D", "S", "*"]
const SETTINGS_PATH := "user://settings.json"

var _regular_font: Font
var _bold_font: Font
var _nickname_edit: LineEdit
var _music_muted := false
var _sfx_muted := false
var _master_muted := false
var _language := "pt"


func _ready() -> void:
	_regular_font = _make_system_font(400)
	_bold_font = _make_system_font(700)
	if has_node("/root/AudioManager"):
		AudioManager.play_context("menu")
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
	NeonBackButtonScript.reserve_footer_space(root)
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var header := VBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	root.add_child(header)

	var title := _make_label("PERFIL", 30, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	title.add_theme_color_override("font_outline_color", Color("#00f0ff66"))
	title.add_theme_constant_override("outline_size", 4)
	header.add_child(title)
	NeonBackButtonScript.add_to(self, _go_back)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)

	content.add_child(_make_profile_card())
	content.add_child(_make_account_card())
	content.add_child(_make_stats_card())
	content.add_child(_make_abilities_card())
	content.add_child(_spacer(18))


func _make_profile_card() -> PanelContainer:
	var card := _make_card()
	var body := _card_body(card)
	body.alignment = BoxContainer.ALIGNMENT_CENTER

	var avatar := _make_large_avatar()
	avatar.custom_minimum_size = Vector2(86, 86)
	body.add_child(avatar)

	_nickname_edit = LineEdit.new()
	_nickname_edit.text = String(GameState.data.get("nickname", "Player"))
	_nickname_edit.max_length = 18
	_nickname_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_nickname_edit.custom_minimum_size.y = 42
	_nickname_edit.add_theme_font_override("font", _bold_font)
	_nickname_edit.add_theme_font_size_override("font_size", 20)
	_nickname_edit.add_theme_color_override("font_color", Color("#ffffff"))
	_nickname_edit.add_theme_color_override("font_placeholder_color", Color("#ffffff77"))
	_nickname_edit.add_theme_stylebox_override("normal", _make_style("#00000000", 0, "#00f0ff66", 0))
	_nickname_edit.add_theme_stylebox_override("focus", _make_style("#00000000", 0, "#00f0ff", 0))
	_nickname_edit.text_submitted.connect(func(_text: String) -> void: _save_profile_mock())
	body.add_child(_nickname_edit)

	var photo_row := HBoxContainer.new()
	photo_row.alignment = BoxContainer.ALIGNMENT_CENTER
	photo_row.add_theme_constant_override("separation", 8)
	body.add_child(photo_row)
	photo_row.add_child(_make_small_icon_button("camera", "TROCAR AVATAR", "#00f0ff22", "#00f0ff88"))

	var save := _make_solid_button("SALVAR NICK", "#00f0ff", "#001018", 120, 36)
	save.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	save.pressed.connect(_save_profile_mock)
	body.add_child(save)

	var avatar_row := HBoxContainer.new()
	avatar_row.alignment = BoxContainer.ALIGNMENT_CENTER
	avatar_row.add_theme_constant_override("separation", 8)
	body.add_child(avatar_row)
	for avatar_key in AVATARS:
		avatar_row.add_child(_make_avatar_pick(avatar_key, avatar_key == "B"))

	body.add_child(_make_section_title("SKIN FAVORITA"))
	body.add_child(_make_favorite_skin_box())

	var skin_row := HBoxContainer.new()
	skin_row.alignment = BoxContainer.ALIGNMENT_CENTER
	skin_row.add_theme_constant_override("separation", 8)
	body.add_child(skin_row)
	for skin_path in [
		"res://assets/skins/neon_blue.png",
		"res://assets/skins/fire.png",
		"res://assets/skins/ghost.png",
		"res://assets/skins/crystal.png",
	]:
		skin_row.add_child(_make_skin_pick(skin_path))
	return card


func _make_account_card() -> PanelContainer:
	var card := _make_card()
	var body := _card_body(card)
	body.add_child(_make_section_title("CONTA"))
	var level := int(GameState.data.get("level", 1))
	var xp := int(GameState.data.get("profile_xp", GameState.data.get("xp", 0)))
	var xp_needed := _xp_needed(level)
	body.add_child(_make_label("Level %s" % level, 24, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	body.add_child(_make_xp_bar(float(xp) / float(max(1, xp_needed)), "%s/%s XP" % [xp, xp_needed]))

	var resources := HBoxContainer.new()
	resources.add_theme_constant_override("separation", 8)
	body.add_child(resources)
	resources.add_child(_make_resource("coin", str(GameState.data.get("coins", 0))))
	resources.add_child(_make_resource("gem", str(GameState.data.get("diamonds", 0))))
	resources.add_child(_make_resource("key", str(GameState.data.get("keys", 0))))
	resources.add_child(_make_resource("legendary_key", str(GameState.data.get("legendary_keys", 0))))

	var achievements := _make_outline_button("CONQUISTAS 0/32", "achievements", "#ffd70022", "#ffd70088", "#ffd700")
	body.add_child(achievements)
	return card


func _make_audio_card() -> PanelContainer:
	var card := _make_card()
	var body := _card_body(card)
	body.add_child(_make_section_title("SOM"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	body.add_child(row)
	row.add_child(_make_toggle_button("MUSICA %s" % ("OFF" if _music_muted else "ON"), "mute_off" if _music_muted else "mute_on", not _music_muted))
	row.add_child(_make_toggle_button("EFEITOS %s" % ("OFF" if _sfx_muted else "ON"), "mute_off" if _sfx_muted else "mute_on", not _sfx_muted))
	row.add_child(_make_toggle_button("GERAL %s" % ("OFF" if _master_muted else "ON"), "mute_off" if _master_muted else "mute_on", not _master_muted))
	return card


func _make_performance_card() -> PanelContainer:
	var card := _make_card()
	var body := _card_body(card)
	body.add_child(_make_section_title("DESEMPENHO"))
	body.add_child(_make_stat("FPS do jogo"))
	body.add_child(_make_option_grid(["30 FPS", "45 FPS", "60 FPS"], "60 FPS"))
	body.add_child(_make_stat("Hz alvo da tela"))
	body.add_child(_make_option_grid(["60 Hz", "90 Hz", "120 Hz"], "60 Hz"))
	var help := _make_label("Use 30/45 FPS em aparelhos fracos. O jogo usa o menor valor entre FPS e Hz para reduzir travamentos.", 12, "#ffffff99", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(help)
	return card


func _make_language_card() -> PanelContainer:
	var card := _make_card()
	var body := _card_body(card)
	body.add_child(_make_section_title("IDIOMA"))
	body.add_child(_make_stat("Selecione o idioma"))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	body.add_child(grid)
	grid.add_child(_make_language_button("Português", "pt"))
	grid.add_child(_make_language_button("English", "en"))
	grid.add_child(_make_language_button("Español", "es"))
	return card


func _make_league_card() -> PanelContainer:
	var card := _make_card()
	var body := _card_body(card)
	body.add_child(_make_section_title("LIGA NEON"))
	for line in [
		"Posição atual: #1/201",
		"Divisão atual: Bronze",
		"Troféus: 0",
		"Pontuação secundária: 0",
		"Melhor posição: #1",
		"Melhor divisão: Bronze",
		"Temporadas vencidas: 0",
		"Vitórias/derrotas: 0/0",
		"Maior sequência: 0",
		"Skins de ranking: 0",
	]:
		body.add_child(_make_stat(line))
	body.add_child(_make_outline_button("Abrir Liga Neon", "league", "#ffd70022", "#ffd70088", "#ffd700"))
	return card


func _make_stats_card() -> PanelContainer:
	var card := _make_card()
	var body := _card_body(card)
	body.add_child(_make_section_title("ESTATÍSTICAS"))
	for line in [
		"Partidas jogadas: %s" % _stat("runs_played", 0),
		"Anéis destruídos: %s" % _stat("rings_destroyed", 0),
		"Escapes perfeitos: %s" % _stat("perfect_escapes", 0),
		"Diamantes encontrados: %s" % _stat("diamonds_found", 0),
		"Baús abertos: %s" % _stat("chests_opened", 0),
		"Skins desbloqueadas: %s" % Array(GameState.data.get("unlocked_skins", [])).size(),
		"Maior fase: %s" % GameState.data.get("max_unlocked_phase", 1),
		"Maior nível na partida: %s" % _stat("highest_run_level", 1),
		"Vitórias no Boss: %s" % _stat("boss_wins", 0),
		"Derrotas no Boss: %s" % _stat("boss_losses", 0),
	]:
		body.add_child(_make_stat(line))
	return card


func _make_abilities_card() -> PanelContainer:
	var card := _make_card()
	var body := _card_body(card)
	body.add_child(_make_section_title("HABILIDADES"))
	body.add_child(_make_stat("Desbloqueadas: 0"))
	for line in [
		"Magnetismo - Perfil nível 2",
		"Impacto Perfeito - Perfil nível 4",
		"Combo Neon - Perfil nível 6",
		"Pulso Repulsor - Perfil nível 8",
		"Fragmento Cósmico - Perfil nível 10",
	]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		body.add_child(row)
		row.add_child(_make_icon("locked", 16))
		var label := _make_label(line, 13, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(label)
	return card


func _make_large_avatar() -> PanelContainer:
	var outer := PanelContainer.new()
	outer.add_theme_stylebox_override("panel", _make_style("#ffffff14", 43, "#ffffff55", 1, "#00f0ff59", 10))
	var center := CenterContainer.new()
	outer.add_child(center)
	var dot := Panel.new()
	dot.custom_minimum_size = Vector2(48, 48)
	dot.add_theme_stylebox_override("panel", _make_style("#1f7dff", 24))
	center.add_child(dot)
	return outer


func _make_avatar_pick(text: String, active: bool) -> PanelContainer:
	var pick := PanelContainer.new()
	pick.custom_minimum_size = Vector2(42, 42)
	pick.add_theme_stylebox_override("panel", _make_style("#ffffff18", 21, "#00ff88" if active else "#00000000", 2 if active else 0))
	var center := CenterContainer.new()
	pick.add_child(center)
	center.add_child(_make_label(text, 20, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	return pick


func _make_skin_pick(path: String) -> PanelContainer:
	var pick := PanelContainer.new()
	pick.custom_minimum_size = Vector2(42, 42)
	pick.add_theme_stylebox_override("panel", _make_style("#ffffff18", 21))
	var center := CenterContainer.new()
	pick.add_child(center)
	var icon := TextureRect.new()
	icon.texture = load(path)
	icon.custom_minimum_size = Vector2(34, 34)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	center.add_child(icon)
	return pick


func _make_favorite_skin_box() -> PanelContainer:
	var box := PanelContainer.new()
	box.add_theme_stylebox_override("panel", _make_style("#ffffff10", 12))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	box.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)
	var skin := TextureRect.new()
	skin.texture = load("res://assets/skins/neon_blue.png")
	skin.custom_minimum_size = Vector2(44, 44)
	skin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	skin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(skin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	row.add_child(column)
	column.add_child(_make_label("Neon Blue", 18, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	column.add_child(_make_label("COMMON", 11, "#9ca3af", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	return box


func _make_xp_bar(progress: float, text: String) -> PanelContainer:
	var shell := PanelContainer.new()
	shell.custom_minimum_size.y = 20
	shell.add_theme_stylebox_override("panel", _make_style("#ffffff22", 10))
	var fill := ColorRect.new()
	fill.color = Color("#00f0ff")
	fill.anchor_right = progress
	fill.anchor_bottom = 1.0
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(fill)
	var label := _make_label(text, 12, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	shell.add_child(label)
	return shell


func _make_resource(icon_key: String, value: String) -> PanelContainer:
	var resource := PanelContainer.new()
	resource.add_theme_stylebox_override("panel", _make_style("#ffffff14", 8))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 6)
	resource.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	margin.add_child(row)
	row.add_child(_make_icon(icon_key, 18))
	row.add_child(_make_label(value, 14, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	return resource


func _make_toggle_button(text: String, icon_key: String, active: bool) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(96, 42)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	_apply_button_style(button, _make_style("#00f0ff" if active else "#ffffff14", 10, "#00f0ff" if active else "#ffffff22", 1))
	var row := HBoxContainer.new()
	_fill(row)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(row)
	row.add_child(_make_icon(icon_key, 18, Color("#001018") if active else Color.WHITE))
	row.add_child(_make_label(text, 12, "#001018" if active else "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	return button


func _make_option_grid(options: Array, selected: String) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	for option in options:
		var is_active := String(option) == selected
		var button := _make_solid_button(String(option), "#00ff8822" if is_active else "#ffffff14", "#00ff88" if is_active else "#ffffff", 76, 42)
		button.add_theme_stylebox_override("normal", _make_style("#00ff8822" if is_active else "#ffffff14", 10, "#00ff88" if is_active else "#ffffff22", 1))
		grid.add_child(button)
	return grid


func _make_language_button(label: String, code: String) -> Button:
	var active := _language == code
	var button := _make_solid_button("%s%s" % [label, "  OK" if active else ""], "#00ff8822" if active else "#ffffff14", "#00ff88" if active else "#ffffff", 128, 44)
	button.add_theme_stylebox_override("normal", _make_style("#00ff8822" if active else "#ffffff14", 10, "#00ff88" if active else "#ffffff22", 1))
	button.pressed.connect(func() -> void:
		_language = code
		_save_settings()
		get_tree().reload_current_scene()
	)
	return button


func _make_small_icon_button(icon_key: String, text: String, bg: String, border: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(148, 36)
	button.focus_mode = Control.FOCUS_NONE
	_apply_button_style(button, _make_style(bg, 8, border, 1))
	var row := HBoxContainer.new()
	_fill(row)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(row)
	row.add_child(_make_icon(icon_key, 16))
	row.add_child(_make_label(text, 11, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	return button


func _make_outline_button(text: String, icon_key: String, bg: String, border: String, color: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size.y = 44
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	_apply_button_style(button, _make_style(bg, 10, border, 1))
	var row := HBoxContainer.new()
	_fill(row)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(row)
	row.add_child(_make_icon(icon_key, 18))
	row.add_child(_make_label(text, 14, color, _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	return button


func _make_solid_button(text: String, bg: String, color: String, width: float, height: float) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(width, height)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", Color(color))
	_apply_button_style(button, _make_style(bg, 8))
	return button


func _make_flat_button(text: String, color: String, size: int) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", size)
	button.add_theme_color_override("font_color", Color(color))
	_apply_button_style(button, _make_style("#00000000", 0))
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
	body.add_theme_constant_override("separation", 8)
	margin.add_child(body)
	return body


func _make_section_title(text: String) -> Label:
	var label := _make_label(text, 13, "#ffffff88", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	label.add_theme_constant_override("letter_spacing", 2)
	return label


func _make_stat(text: String) -> Label:
	var label := _make_label(text, 14, "#ffffff", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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


func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	_music_muted = bool(parsed.get("music_muted", false))
	_sfx_muted = bool(parsed.get("sfx_muted", false))
	_master_muted = bool(parsed.get("master_muted", false))
	_language = String(parsed.get("language", "pt"))


func _save_settings() -> void:
	var data := {
		"music_muted": _music_muted,
		"sfx_muted": _sfx_muted,
		"master_muted": _master_muted,
		"language": _language,
	}
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))


func _save_profile_mock() -> void:
	_nickname_edit.text = _nickname_edit.text.strip_edges().substr(0, 18)
	if _nickname_edit.text.is_empty():
		_nickname_edit.text = "Player"
	GameState.data["nickname"] = _nickname_edit.text
	GameState.save_game()


func _xp_needed(level: int) -> int:
	return 100 + level * 20


func _stat(key: String, fallback: int) -> int:
	return int(GameState.data.get("stats", {}).get(key, fallback))


func _go_back() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)

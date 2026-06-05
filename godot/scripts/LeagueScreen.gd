extends Control

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const BATTLE_SCENE := "res://scenes/LeagueBattle.tscn"
const NeonBackButtonScript := preload("res://scripts/NeonBackButton.gd")

const ICON_PATHS := {
	"achievements": "res://assets/ui/ui_achievements.png",
	"coin": "res://assets/ui/ui_coin.png",
	"gem": "res://assets/ui/ui_gem.png",
	"key": "res://assets/ui/ui_key.png",
	"league": "res://assets/ui/ui_league_neon.png",
	"skins": "res://assets/ui/ui_skins.png",
}

const LEAGUE_ROOM_SIZE := 30
const LEAGUE_BOT_COUNT := LEAGUE_ROOM_SIZE - 1

var _regular_font: Font
var _bold_font: Font
var _standings: Array[Dictionary] = []
var _player_index := 0
var _notice_label: Label


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
	_standings = _make_standings()
	_player_index = _find_player_index()
	var player := _standings[_player_index]
	var root := VBoxContainer.new()
	root.anchor_left = 0.0
	root.anchor_top = 0.0
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	var margin_x := 12.0 if _is_narrow_screen() else 18.0
	root.offset_left = margin_x
	root.offset_top = 36.0 if _is_narrow_screen() else 48.0
	root.offset_right = -margin_x
	NeonBackButtonScript.reserve_footer_space(root)
	root.add_theme_constant_override("separation", 10)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(root)
	NeonBackButtonScript.add_to(self, _go_back)

	var header := VBoxContainer.new()
	header.add_theme_constant_override("separation", 4)
	root.add_child(header)
	header.add_child(_make_label("LIGA NEON", 26 if _is_narrow_screen() else 31, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_configure_scroll(scroll)
	root.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)

	content.add_child(_make_summary(player))
	content.add_child(_make_division_panel(player))
	content.add_child(_make_top_three())
	content.add_child(_make_reward_card(player))
	content.add_child(_make_ranking_list())
	content.add_child(_make_player_dock(player))
	content.add_child(_spacer(18))


func _make_summary(player: Dictionary) -> PanelContainer:
	var card := _make_card("#ffffff12", "#00f0ff44")
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	_card_margin(card).add_child(row)
	row.add_child(_make_summary_cell("Sua posição", "#%s/%s" % [_player_index + 1, _standings.size()]))
	row.add_child(_make_summary_cell("Troféus", _format_int(int(player.get("trophies", 0)))))
	row.add_child(_make_summary_cell("Temporada", "%sd" % _days_remaining_in_month()))
	return card


func _make_summary_cell(label: String, value: String) -> VBoxContainer:
	var cell := VBoxContainer.new()
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell.add_theme_constant_override("separation", 2)
	cell.add_child(_make_label(label, 11, "#ffffff88", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	cell.add_child(_make_label(value, 18, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	return cell


func _make_division_panel(player: Dictionary) -> PanelContainer:
	var rank := MainPortData.rank_for_trophies(int(player.get("trophies", 0)))
	var next_rank := _next_rank(rank)
	var current_min := int(rank.get("min", 0))
	var next_min := int(next_rank.get("min", current_min))
	var missing: int = max(0, next_min - int(player.get("trophies", 0)))
	var progress := 1.0 if next_rank.is_empty() else clampf(float(int(player.get("trophies", 0)) - current_min) / float(max(1, next_min - current_min)), 0.0, 1.0)
	var card := _make_card("#ffffff12", "#00ff8866")
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 9)
	_card_margin(card).add_child(body)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	body.add_child(top)
	top.add_child(_make_label(String(rank.get("name", "Bronze")), 18, "#00ff88", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	top.add_child(_make_label("Divisão máxima" if next_rank.is_empty() else "%s troféus até %s" % [_format_int(missing), String(next_rank.get("name", ""))], 12, "#ffffffaa", _bold_font, HORIZONTAL_ALIGNMENT_RIGHT))
	body.add_child(_make_progress_bar(progress, "#00ff88"))
	var compete := _make_solid_button("COMPETIR", "#00f0ff", "#001018", 0, 48)
	compete.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	compete.pressed.connect(_open_battle)
	body.add_child(compete)
	_notice_label = _make_label("Duelo em duas arenas: voce embaixo, rival em cima.", 12, "#ffffff99", _regular_font, HORIZONTAL_ALIGNMENT_CENTER)
	_notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(_notice_label)
	return card


func _make_top_three() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_theme_constant_override("separation", 6 if _is_narrow_screen() else 8)
	for i in range(min(3, _standings.size())):
		row.add_child(_make_podium_card(_standings[i], i))
	return row


func _make_podium_card(entry: Dictionary, index: int) -> PanelContainer:
	var card := _make_card("#ffffff10", "#ffd70066")
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var body := VBoxContainer.new()
	body.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_theme_constant_override("separation", 4)
	_card_margin(card, 10).add_child(body)
	body.add_child(_make_label(["1", "2", "3"][index], 24, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	body.add_child(_make_label("Você" if bool(entry.get("is_player", false)) else String(entry.get("name", "")), 12, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	body.add_child(_make_label("%s troféus" % _format_int(int(entry.get("trophies", 0))), 11, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	return card


func _make_reward_card(player: Dictionary) -> PanelContainer:
	var card := _make_card("#00ff8814", "#00ff8866")
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 5)
	_card_margin(card).add_child(body)
	body.add_child(_make_label("Recompensa estimada", 15, "#00ff88", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	var reward_text := "Skin especial + gemas + baú da divisão" if _player_index == 0 else "Gemas e baú raro/épico" if _player_index < 3 else "Moedas, fragmentos e chave comum" if _player_index < 10 else "Participação com moedas/XP"
	body.add_child(_make_label(reward_text, 14, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	body.add_child(_make_label("Vitória futura: +36 troféus base • Derrota futura: -18 troféus base.", 12, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))
	if String(player.get("division_id", "bronze")) == "bronze":
		body.add_child(_make_label("Primeira promoção do Bronze libera a skin ultimate Campeão Neon Inicial.", 12, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	if _player_index > 0:
		var above := _standings[_player_index - 1]
		body.add_child(_make_label("Faltam %s troféus para subir uma posição." % _format_int(int(above.get("trophies", 0)) - int(player.get("trophies", 0))), 12, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))
	return card


func _make_ranking_list() -> VBoxContainer:
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 8)
	for i in range(min(LEAGUE_ROOM_SIZE, _standings.size())):
		list.add_child(_make_ranking_row(_standings[i], i))
	return list


func _make_ranking_row(entry: Dictionary, index: int) -> PanelContainer:
	var is_player := bool(entry.get("is_player", false))
	var card := _make_card("#00ff8820" if is_player else "#ffffff10", "#00ff88" if is_player else "#ffffff22")
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	_card_margin(card, 10).add_child(row)
	row.add_child(_make_label("#%s" % (index + 1), 14, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	row.add_child(_make_skin_icon(String(entry.get("skin", "neon_blue")), 34))
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	row.add_child(info)
	info.add_child(_make_label("%s%s" % [String(entry.get("name", "")), " (Você)" if is_player else ""], 14, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	info.add_child(_make_label("%s • Fase %s • Comp %sV" % [String(entry.get("skin_name", "Neon Blue")), int(entry.get("max_phase", 1)), int(entry.get("wins", 0))], 11, "#ffffff99", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))
	var score := VBoxContainer.new()
	score.add_theme_constant_override("separation", 1)
	score.custom_minimum_size.x = 78
	row.add_child(score)
	score.add_child(_make_label(_format_int(int(entry.get("trophies", 0))), 12, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_RIGHT))
	score.add_child(_make_label(String(entry.get("division", "Bronze")), 10, "#ffffff", _regular_font, HORIZONTAL_ALIGNMENT_RIGHT))
	return card


func _make_player_dock(player: Dictionary) -> PanelContainer:
	var card := _make_card("#00f0ff", "#00f0ff")
	var margin := _card_margin(card, 12)
	margin.add_child(_make_label("Minha posição #%s/%s • %s troféus • %s" % [_player_index + 1, _standings.size(), _format_int(int(player.get("trophies", 0))), String(player.get("division", "Bronze"))], 13, "#001018", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	return card


func _make_standings() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var league: Dictionary = GameState.data.get("league", {})
	var player_trophies := int(league.get("trophies", 0))
	var player_rank := MainPortData.rank_for_trophies(player_trophies)
	var current_min := int(player_rank.get("min", 0))
	var next_rank := _next_rank(player_rank)
	var next_min := int(next_rank.get("min", current_min + 900))
	var room_span: int = max(120, next_min - current_min - 1)
	result.append({
		"id": "player",
		"name": String(GameState.data.get("nickname", "Player")),
		"skin": String(GameState.data.get("favorite_skin", GameState.data.get("equipped_skin", "neon_blue"))),
		"skin_name": _skin_name(String(GameState.data.get("favorite_skin", GameState.data.get("equipped_skin", "neon_blue")))),
		"trophies": player_trophies,
		"division_id": String(player_rank.get("id", "bronze")),
		"division": String(player_rank.get("name", "Bronze")),
		"max_phase": int(GameState.data.get("max_unlocked_phase", 1)),
		"wins": int(league.get("wins", 0)),
		"is_player": true,
	})
	var seed_offset: int = abs(("%s_%s" % [TimeManager.get_month_key(), String(player_rank.get("id", "bronze"))]).hash()) % 23
	for i in range(LEAGUE_BOT_COUNT):
		var rank_fraction: float = 1.0 - float(i) / float(max(1, LEAGUE_BOT_COUNT - 1))
		var jitter: int = int(sin(float(i + seed_offset) * 1.77) * 10.0)
		var trophies: int = current_min + max(1, roundi(float(room_span) * (0.10 + rank_fraction * 0.86)) + jitter)
		trophies = clampi(trophies, current_min + 1, next_min - 1)
		var skin_id: String = MainPortData.league_skin_id_for_position(i, seed_offset)
		result.append({
			"id": "bot_%s" % i,
			"name": MainPortData.opponent_name(i + seed_offset, String(player_rank.get("id", "bronze"))),
			"skin": skin_id,
			"skin_name": _skin_name(skin_id),
			"trophies": trophies,
			"quality": clampf(0.92 - float(i) * 0.018 + float(seed_offset % 5) * 0.01, 0.36, 0.96),
			"division_id": String(player_rank.get("id", "bronze")),
			"division": String(player_rank.get("name", "Bronze")),
			"max_phase": clampi(4 + i * 2, 1, 100),
			"wins": clampi(1 + i % 18, 1, 99),
			"is_player": false,
		})
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("trophies", 0)) > int(b.get("trophies", 0)))
	return result


func _find_player_index() -> int:
	for i in range(_standings.size()):
		if bool(_standings[i].get("is_player", false)):
			return i
	return 0


func _next_rank(rank: Dictionary) -> Dictionary:
	var ranks: Array = MainPortData.LEAGUE_RANKS
	for i in range(ranks.size()):
		if String(Dictionary(ranks[i]).get("id", "")) == String(rank.get("id", "")) and i + 1 < ranks.size():
			return Dictionary(ranks[i + 1])
	return {}


func _open_battle() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("res://assets/sounds/button_click.mp3")
	var target_index: int = max(0, _player_index - 1)
	if target_index == _player_index and _standings.size() > 1:
		target_index = 1
	if target_index >= 0 and target_index < _standings.size():
		var target := Dictionary(_standings[target_index]).duplicate(true)
		if not bool(target.get("is_player", false)):
			GameState.data["pending_league_opponent"] = target
	get_tree().change_scene_to_file(BATTLE_SCENE)


func _skin_name(id: String) -> String:
	var skin := MainPortData.skin_by_id(id)
	return String(skin.get("name", "Neon Blue"))


func _make_skin_icon(id: String, icon_size: int) -> TextureRect:
	var icon := TextureRect.new()
	var path := "res://assets/skins/%s.png" % id
	icon.texture = load(path if ResourceLoader.exists(path) else "res://assets/skins/neon_blue.png")
	icon.custom_minimum_size = Vector2(icon_size, icon_size)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon


func _make_progress_bar(progress: float, color: String) -> PanelContainer:
	var shell := PanelContainer.new()
	shell.custom_minimum_size.y = 8
	shell.add_theme_stylebox_override("panel", _make_style("#ffffff18", 4))
	var fill := ColorRect.new()
	fill.color = Color(color)
	fill.anchor_right = clampf(progress, 0.0, 1.0)
	fill.anchor_bottom = 1.0
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(fill)
	return shell


func _make_solid_button(text: String, bg: String, color: String, width: float, height: float) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(width, height)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", Color(color))
	_apply_button_style(button, _make_style(bg, 10, "#00f0ff88", 1))
	return button


func _make_card(bg: String, border: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_theme_stylebox_override("panel", _make_style(bg, 12, border, 1, "#00f0ff33", 6))
	return card


func _card_margin(card: PanelContainer, amount := 12) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", amount)
	margin.add_theme_constant_override("margin_top", amount)
	margin.add_theme_constant_override("margin_right", amount)
	margin.add_theme_constant_override("margin_bottom", amount)
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_child(margin)
	return margin


func _make_label(text: String, font_size: int, color: String, font: Font, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(color))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _make_background_gradient() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.48, 1.0])
	gradient.colors = PackedColorArray([Color("#08121d"), Color("#1a0a2e"), Color("#16003b")])
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


func _days_remaining_in_month() -> int:
	var now := Time.get_datetime_dict_from_system()
	var day := int(now.get("day", 1))
	var month := int(now.get("month", 1))
	var days := 31
	if month in [4, 6, 9, 11]:
		days = 30
	elif month == 2:
		days = 29 if int(now.get("year", 2026)) % 4 == 0 else 28
	return max(1, days - day + 1)


func _format_int(value: int) -> String:
	var text := str(value)
	var result := ""
	var count := 0
	for i in range(text.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "." + result
		result = text.substr(i, 1) + result
		count += 1
	return result


func _spacer(height: float) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = height
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer


func _configure_scroll(scroll: ScrollContainer) -> void:
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.follow_focus = true
	scroll.scroll_deadzone = 4
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP


func _is_narrow_screen() -> bool:
	return get_viewport_rect().size.x <= 430.0


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

extends Control

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const NeonBackButtonScript := preload("res://scripts/NeonBackButton.gd")

const ICON_PATHS := {
	"coin": "res://assets/ui/ui_coin.png",
	"gem": "res://assets/ui/ui_gem.png",
	"key": "res://assets/ui/ui_key.png",
	"legendary_key": "res://assets/ui/ui_legendary_key.png",
	"xp": "res://assets/ui/ui_xp.png",
	"fragments": "res://assets/ui/ui_fragments.png",
	"skins": "res://assets/ui/ui_skins.png",
	"chest_common": "res://assets/ui/ui_chest_common.png",
	"chest_rare": "res://assets/ui/ui_chest_rare.png",
	"chest_epic": "res://assets/ui/ui_chest_epic.png",
	"chest_legendary": "res://assets/ui/ui_chest_legendary.png",
	"locked": "res://assets/ui/ui_locked.png",
}

var _regular_font: Font
var _bold_font: Font

var _pass_state: Dictionary = {}
var _reward_overlay: Control


func _ready() -> void:
	_regular_font = _make_system_font(400)
	_bold_font = _make_system_font(700)
	if has_node("/root/AudioManager"):
		AudioManager.play_context("menu")
	_refresh_state()
	_build_background()
	_build_layout()


func _refresh_state() -> void:
	if has_node("/root/GameState"):
		_pass_state = GameState.get_neon_pass_state()
	else:
		_pass_state = {
			"season_name": "Neon Awakening",
			"season_name_pt": "Despertar Neon",
			"week_index": 1,
			"weekly_level_cap": 10,
			"level": 1,
			"xp": 0,
			"xp_needed": 100,
			"max_level": 40,
			"cap_reached": false,
			"seconds_until_week_end": 0,
			"seconds_until_season_end": 0,
		}


func _build_background() -> void:
	var background := TextureRect.new()
	_fill(background)
	background.texture = _make_background_gradient()
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)


func _build_layout() -> void:
	var scroll := ScrollContainer.new()
	scroll.anchor_left = 0.0
	scroll.anchor_top = 0.0
	scroll.anchor_right = 1.0
	scroll.anchor_bottom = 1.0
	scroll.offset_left = 18.0
	scroll.offset_top = _safe_top_margin()
	scroll.offset_right = -18.0
	scroll.offset_bottom = -18.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.scroll_deadzone = 2
	scroll.follow_focus = true
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	NeonBackButtonScript.reserve_footer_space(scroll)
	add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)

	content.add_child(_make_header_card())
	content.add_child(_make_track_card())
	content.add_child(_spacer(26))

	NeonBackButtonScript.add_to(self, _go_back)


func _make_header_card() -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_style("#12051ff2", 22, "#00f0ff88", 1, "#00f0ff55", 22))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	card.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)

	var hero := HBoxContainer.new()
	hero.add_theme_constant_override("separation", 12)
	column.add_child(hero)
	var badge := PanelContainer.new()
	badge.custom_minimum_size = Vector2(76, 76)
	badge.add_theme_stylebox_override("panel", _make_style("#00f0ff22", 22, "#00f0ff", 1, "#00f0ffaa", 14))
	hero.add_child(badge)
	var badge_center := CenterContainer.new()
	badge.add_child(badge_center)
	var badge_stack := VBoxContainer.new()
	badge_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	badge_center.add_child(badge_stack)
	badge_stack.add_child(_make_label("NEON", 10, "#ffffffcc", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	badge_stack.add_child(_make_label("PASS", 16, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))

	var hero_text := VBoxContainer.new()
	hero_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_text.add_theme_constant_override("separation", 4)
	hero.add_child(hero_text)
	var title := _make_label(_tr("neon_pass").to_upper(), 29, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	title.add_theme_constant_override("letter_spacing", 2)
	title.add_theme_color_override("font_outline_color", Color("#00f0ff66"))
	title.add_theme_constant_override("outline_size", 5)
	hero_text.add_child(title)
	hero_text.add_child(_make_label(_season_name(), 16, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	hero_text.add_child(_make_label("%s %s • %s 40" % [_tr("week"), int(_pass_state.get("week_index", 1)), _tr("level")], 12, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))

	var meta_grid := GridContainer.new()
	meta_grid.columns = 2
	meta_grid.add_theme_constant_override("h_separation", 10)
	meta_grid.add_theme_constant_override("v_separation", 10)
	column.add_child(meta_grid)
	meta_grid.add_child(_make_info_pill(_tr("season"), _season_name(), "#ff4fd8"))
	meta_grid.add_child(_make_info_pill(_tr("week"), "%s/4" % int(_pass_state.get("week_index", 1)), "#00ff88"))
	meta_grid.add_child(_make_info_pill(_tr("time_remaining"), _format_remaining(int(_pass_state.get("seconds_until_week_end", 0))), "#ffd700"))
	meta_grid.add_child(_make_info_pill("%s %s" % [_tr("season"), _tr("time_remaining")], _format_remaining(int(_pass_state.get("seconds_until_season_end", 0))), "#00f0ff"))
	meta_grid.add_child(_make_info_pill(_tr("weekly_cap"), "%s %s" % [_tr("level"), int(_pass_state.get("weekly_level_cap", 10))], "#ffffff"))

	var xp_card := PanelContainer.new()
	xp_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	xp_card.add_theme_stylebox_override("panel", _make_style("#ffffff10", 14, "#ffffff22", 1))
	column.add_child(xp_card)

	var xp_margin := MarginContainer.new()
	xp_margin.add_theme_constant_override("margin_left", 12)
	xp_margin.add_theme_constant_override("margin_top", 10)
	xp_margin.add_theme_constant_override("margin_right", 12)
	xp_margin.add_theme_constant_override("margin_bottom", 10)
	xp_card.add_child(xp_margin)

	var xp_column := VBoxContainer.new()
	xp_column.add_theme_constant_override("separation", 8)
	xp_margin.add_child(xp_column)

	var xp_row := HBoxContainer.new()
	xp_row.add_theme_constant_override("separation", 8)
	xp_column.add_child(xp_row)
	var current_level: int = int(_pass_state.get("level", 1))
	var current_xp: int = int(_pass_state.get("xp", 0))
	var needed_xp: int = max(1, int(_pass_state.get("xp_needed", 100)))
	var level_label := _make_label("%s %s/%s" % [_tr("level"), current_level, int(_pass_state.get("max_level", 40))], 18, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	level_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	xp_row.add_child(level_label)
	xp_row.add_child(_make_label("%s %s/%s" % [_tr("pass_xp"), current_xp, needed_xp], 13, "#ffffffaa", _bold_font, HORIZONTAL_ALIGNMENT_RIGHT))
	xp_column.add_child(_make_progress(float(current_xp) / float(needed_xp), "#00f0ff"))
	xp_column.add_child(_make_progress(float(current_level) / float(max(1, int(_pass_state.get("max_level", 40)))), "#ff4fd8"))
	if bool(_pass_state.get("cap_reached", false)):
		xp_column.add_child(_make_label(_tr("weekly_cap_reached"), 13, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))

	var claim_all := Button.new()
	claim_all.text = _tr("claim_all")
	claim_all.custom_minimum_size = Vector2(0, 46)
	claim_all.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	claim_all.focus_mode = Control.FOCUS_NONE
	claim_all.disabled = int(_pass_state.get("claimable_count", 0)) <= 0
	claim_all.add_theme_font_override("font", _bold_font)
	claim_all.add_theme_font_size_override("font_size", 14)
	claim_all.add_theme_color_override("font_color", Color("#001018"))
	claim_all.add_theme_color_override("font_disabled_color", Color("#00101899"))
	_apply_button_style(claim_all, _make_style("#00f0ff", 13, "#ffffff33", 1, "#00f0ff88", 10))
	claim_all.pressed.connect(_claim_all_rewards)
	column.add_child(claim_all)
	return card


func _make_track_card() -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_style("#080412dd", 22, "#ff4fd866", 1, "#ff4fd844", 16))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 14)
	card.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)

	column.add_child(_make_label(_txt("REWARD TRACK", "TRILHA DE RECOMPENSAS", "RUTA DE RECOMPENSAS", "報酬トラック", "奖励路线"), 18, "#ff4fd8", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	column.add_child(_make_label(_txt("Reach levels, light up rewards and collect everything unlocked.", "Avance níveis, ilumine recompensas e colete tudo que liberar.", "Sube niveles, ilumina recompensas y cobra lo desbloqueado.", "レベルを進めて報酬を光らせ、解放分を受け取ろう。", "提升等级，点亮奖励并领取已解锁内容。"), 12, "#ffffff99", _regular_font, HORIZONTAL_ALIGNMENT_CENTER))
	var grid := GridContainer.new()
	grid.columns = 2 if get_viewport_rect().size.x <= 620.0 else 4
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	column.add_child(grid)
	for level in range(1, 41):
		grid.add_child(_make_reward_tile(level))
	return card


func _make_reward_tile(level: int) -> PanelContainer:
	var entry := _reward_entry(level)
	var reached := bool(entry.get("reached", false))
	var claimed := bool(entry.get("claimed", false))
	var available := bool(entry.get("available", false))
	var capped := bool(entry.get("capped", false))
	var rarity := String(entry.get("rarity", "common")).to_lower()
	var tone := _rarity_tone(rarity)
	if available:
		tone = "#ffd700"
	elif claimed:
		tone = "#00ff88"
	elif capped:
		tone = "#ff4fd8"
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 178)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var bg := "#ffd70024" if available else "#00ff8818" if claimed else "#ff4fd812" if capped else "#ffffff0a"
	card.add_theme_stylebox_override("panel", _make_style(bg, 16, tone, 1, tone.replace("ff", "66"), 12 if available else 5))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 6)
	column.add_child(top)
	var level_chip := PanelContainer.new()
	level_chip.custom_minimum_size = Vector2(42, 30)
	level_chip.add_theme_stylebox_override("panel", _make_style("#001018" if reached else "#101018", 10, tone, 1))
	top.add_child(level_chip)
	var chip_center := CenterContainer.new()
	level_chip.add_child(chip_center)
	chip_center.add_child(_make_label(str(level), 14, "#ffffff" if reached else "#ffffff88", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	var state_label := _tr("reward_claimed") if claimed else _tr("claim") if available else _tr("weekly_cap") if capped else _tr("locked")
	top.add_child(_make_label(state_label.to_upper(), 10, "#ffd700" if available else "#00ff88" if claimed else "#ffffff88", _bold_font, HORIZONTAL_ALIGNMENT_RIGHT))

	var reward_center := CenterContainer.new()
	reward_center.custom_minimum_size = Vector2(0, 54)
	column.add_child(reward_center)
	reward_center.add_child(_make_reward_square(entry, claimed, available))

	var title := _make_label(_localized_entry_title(entry), 12, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	title.clip_text = true
	column.add_child(title)
	column.add_child(_make_progress(_track_fill_for_level(level), tone))

	var action := Button.new()
	action.text = _tr("claim") if available else _tr("view_reward")
	action.custom_minimum_size = Vector2(0, 32)
	action.focus_mode = Control.FOCUS_NONE
	action.disabled = claimed
	action.add_theme_font_override("font", _bold_font)
	action.add_theme_font_size_override("font_size", 10)
	action.add_theme_color_override("font_color", Color("#001018") if available else Color("#ffffff"))
	action.add_theme_color_override("font_disabled_color", Color("#ffffff88"))
	_apply_button_style(action, _make_style("#ffd700" if available else "#ffffff14", 10, tone, 1, tone.replace("ff", "66"), 5))
	if available:
		action.pressed.connect(func() -> void: _claim_reward(level))
	else:
		action.pressed.connect(func() -> void: _show_reward_preview(entry))
	column.add_child(action)
	return card


func _make_reward_row(level: int) -> PanelContainer:
	var entry := _reward_entry(level)
	var reached := bool(entry.get("reached", false))
	var claimed := bool(entry.get("claimed", false))
	var available := bool(entry.get("available", false))
	var capped := bool(entry.get("capped", false))
	var tone := "#00f0ff" if available else "#00ff88" if claimed else "#ff4fd855" if capped else "#ffffff55"
	var bg := "#00f0ff22" if available else "#00ff8818" if claimed else "#ff4fd80b" if capped else "#ffffff0c"

	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_style(bg, 14, tone, 1, tone.replace("ff", "55"), 10 if available else 4))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	margin.add_child(row)

	var level_box := PanelContainer.new()
	level_box.custom_minimum_size = Vector2(58, 58)
	level_box.add_theme_stylebox_override("panel", _make_style("#001018" if reached else "#14101d", 12, tone, 1, tone.replace("ff", "55"), 8))
	row.add_child(level_box)
	var level_center := CenterContainer.new()
	level_box.add_child(level_center)
	level_center.add_child(_make_label(str(level), 18, "#ffffff" if reached else "#ffffff77", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))

	var middle := VBoxContainer.new()
	middle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	middle.add_theme_constant_override("separation", 5)
	row.add_child(middle)

	var status := _tr("reward_claimed") if claimed else _tr("claim") if available else _tr("weekly_cap") if capped else _tr("locked")
	middle.add_child(_make_label(_localized_entry_title(entry), 15, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	middle.add_child(_make_progress(_track_fill_for_level(level), tone))
	middle.add_child(_make_label("%s %s • %s" % [_tr("level"), level, status], 12, "#ffd700" if available else "#00ff88" if claimed else "#ffffff77", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))

	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(92, 0)
	right.add_theme_constant_override("separation", 6)
	row.add_child(right)
	right.add_child(_make_reward_square(entry, claimed, available))
	var action := Button.new()
	action.text = _tr("claim") if available else _tr("view_reward")
	action.custom_minimum_size = Vector2(0, 34)
	action.focus_mode = Control.FOCUS_NONE
	action.disabled = claimed
	action.add_theme_font_override("font", _bold_font)
	action.add_theme_font_size_override("font_size", 10)
	action.add_theme_color_override("font_color", Color("#001018") if available else Color("#ffffff"))
	action.add_theme_color_override("font_disabled_color", Color("#ffffff88"))
	_apply_button_style(action, _make_style("#00f0ff" if available else "#ffffff14", 10, tone, 1, tone.replace("ff", "66"), 5))
	if available:
		action.pressed.connect(func() -> void: _claim_reward(level))
	else:
		action.pressed.connect(func() -> void: _show_reward_preview(entry))
	right.add_child(action)
	return card


func _make_reward_square(entry: Dictionary, claimed: bool, available: bool) -> PanelContainer:
	var icon_key := String(entry.get("icon", "locked"))
	var tone := "#ffd700" if available else "#00ff88" if claimed else "#ffffff55"
	var square := PanelContainer.new()
	square.custom_minimum_size = Vector2(62, 62)
	square.add_theme_stylebox_override("panel", _make_style("#ffd70022" if available else "#00ff8814" if claimed else "#ffffff0a", 14, tone, 1, tone.replace("ff", "55"), 10 if available else 3))

	var center := CenterContainer.new()
	square.add_child(center)
	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 0)
	center.add_child(stack)

	stack.add_child(_make_icon(icon_key if not icon_key.is_empty() else "locked", 32, Color("#ffffff") if available or claimed else Color("#ffffff77")))
	if claimed:
		stack.add_child(_make_label("✓", 15, "#00ff88", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	elif not available:
		stack.add_child(_make_label("•", 15, "#ffffff55", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	else:
		stack.add_child(_make_label("!", 15, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	return square


func _rarity_tone(rarity: String) -> String:
	match rarity.to_lower():
		"ultimate":
			return "#ffffff"
		"mythic":
			return "#ff4fd8"
		"legendary":
			return "#ffd700"
		"epic":
			return "#b000ff"
		"rare":
			return "#00f0ff"
	return "#00ff88"


func _reward_entry(level: int) -> Dictionary:
	for entry in Array(_pass_state.get("rewards", [])):
		var reward_entry := Dictionary(entry)
		if int(reward_entry.get("level", 0)) == level:
			return reward_entry
	return {
		"level": level,
		"title": "Reward",
		"title_pt": "Recompensa",
		"reward": { "type": "coins", "amount": 0 },
		"icon": "locked",
		"rarity": "common",
		"reached": false,
		"claimed": false,
		"available": false,
		"capped": false,
	}


func _localized_entry_title(entry: Dictionary) -> String:
	var language := "en"
	if has_node("/root/LocalizationManager"):
		language = LocalizationManager.current_language()
	elif has_node("/root/GameState"):
		language = String(GameState.get_setting("language", "en"))
	var title := String(entry.get("title_pt", entry.get("title", ""))) if language.begins_with("pt") else String(entry.get("title", "Reward"))
	var rarity := String(entry.get("rarity", "")).capitalize()
	if rarity.is_empty() or rarity == "Common":
		return title
	return "%s • %s" % [title, rarity]


func _claim_reward(level: int) -> void:
	if not has_node("/root/GameState"):
		return
	var result := GameState.claim_neon_pass_reward(level)
	_show_reward_modal(result, true)


func _claim_all_rewards() -> void:
	if not has_node("/root/GameState"):
		return
	var result := GameState.claim_all_neon_pass_rewards()
	_show_reward_modal(result, true)


func _show_reward_preview(entry: Dictionary) -> void:
	var reward: Dictionary = Dictionary(entry.get("reward", {})).duplicate(true)
	var text := _tr("reward_claimed") if bool(entry.get("claimed", false)) else _tr("locked")
	_show_reward_modal({
		"ok": true,
		"preview": true,
		"entry": entry,
		"reward": reward,
		"text": text,
	}, false)


func _show_reward_modal(result: Dictionary, refresh_on_close := false) -> void:
	if _reward_overlay != null and is_instance_valid(_reward_overlay):
		_reward_overlay.queue_free()
	if not bool(result.get("ok", false)):
		_show_reward_modal({
			"ok": true,
			"preview": true,
			"reward": { "type": "coins", "amount": 0 },
			"text": _tr("weekly_cap_reached") if String(result.get("reason", "")) == "locked" else _tr("locked"),
		}, false)
		return
	var overlay := Control.new()
	_fill(overlay)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	_reward_overlay = overlay

	var dim := ColorRect.new()
	_fill(dim)
	dim.color = Color("#030008bb")
	overlay.add_child(dim)

	var center := CenterContainer.new()
	_fill(center)
	center.offset_left = 18
	center.offset_top = _safe_top_margin()
	center.offset_right = -18
	center.offset_bottom = -26
	overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 0)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.add_theme_stylebox_override("panel", _make_style("#140821f6", 20, "#00f0ff88", 1, "#00f0ff66", 18))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	margin.add_child(body)
	var title_key := "view_reward" if bool(result.get("preview", false)) else "neon_pass_reward"
	body.add_child(_make_label(_tr(title_key).to_upper(), 22, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	var rewards: Array = Array(result.get("rewards", []))
	if rewards.size() > 0:
		body.add_child(_make_label(String(result.get("text", "")), 13, "#ffffffcc", _regular_font, HORIZONTAL_ALIGNMENT_CENTER))
		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size = Vector2(0, min(340, 76 * rewards.size()))
		scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		body.add_child(scroll)
		var list := VBoxContainer.new()
		list.add_theme_constant_override("separation", 8)
		scroll.add_child(list)
		for item in rewards:
			var item_data := Dictionary(item)
			list.add_child(_make_modal_reward_line(Dictionary(item_data.get("reward", {})), Dictionary(item_data.get("entry", {}))))
	else:
		var reward: Dictionary = Dictionary(result.get("reward", {}))
		body.add_child(_make_modal_reward_visual(reward, Dictionary(result.get("entry", {}))))
		body.add_child(_make_label(_reward_label(reward), 18, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
		body.add_child(_make_label(String(result.get("text", "")), 13, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_CENTER))
	var close := Button.new()
	close.text = _tr("continue")
	close.custom_minimum_size = Vector2(0, 46)
	close.focus_mode = Control.FOCUS_NONE
	close.add_theme_font_override("font", _bold_font)
	close.add_theme_font_size_override("font_size", 14)
	close.add_theme_color_override("font_color", Color("#001018"))
	_apply_button_style(close, _make_style("#00f0ff", 14, "#ffffff33", 1, "#00f0ff88", 10))
	close.pressed.connect(func() -> void: _close_reward_modal(refresh_on_close))
	body.add_child(close)


func _close_reward_modal(refresh_on_close := false) -> void:
	if _reward_overlay != null and is_instance_valid(_reward_overlay):
		_reward_overlay.queue_free()
	_reward_overlay = null
	if refresh_on_close:
		_refresh_screen()


func _refresh_screen() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_reward_overlay = null
	_refresh_state()
	_build_background()
	_build_layout()


func _make_modal_reward_line(reward: Dictionary, entry: Dictionary) -> PanelContainer:
	var line := PanelContainer.new()
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_theme_stylebox_override("panel", _make_style("#ffffff10", 12, "#ffffff22", 1))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	line.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	margin.add_child(row)
	row.add_child(_make_modal_reward_visual(reward, entry, 38))
	var labels := VBoxContainer.new()
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(labels)
	labels.add_child(_make_label(_reward_label(reward), 14, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	labels.add_child(_make_label("%s %s" % [_tr("level"), int(entry.get("level", 0))], 11, "#ffffff99", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))
	return line


func _make_modal_reward_visual(reward: Dictionary, entry: Dictionary, size := 84) -> Control:
	var center := CenterContainer.new()
	center.custom_minimum_size = Vector2(size, size)
	var reward_type := String(reward.get("type", ""))
	if reward_type == "skin":
		var skin_id := String(reward.get("skin_id", reward.get("skinId", "")))
		var texture := TextureRect.new()
		texture.custom_minimum_size = Vector2(size, size)
		texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var path := MainPortData.skin_asset_path(skin_id)
		if not path.is_empty() and ResourceLoader.exists(path):
			texture.texture = load(path)
		center.add_child(texture)
		return center
	var icon_key := String(entry.get("icon", _icon_from_reward(reward)))
	center.add_child(_make_icon(icon_key, size, Color("#ffffff")))
	return center


func _icon_from_reward(reward: Dictionary) -> String:
	match String(reward.get("type", "")):
		"coins":
			return "coin"
		"diamonds", "gems":
			return "gem"
		"keys":
			return "key"
		"legendaryKeys", "legendary_keys":
			return "legendary_key"
		"xp", "profileXp", "profile_xp":
			return "xp"
		"fragments":
			return "fragments"
		"skin":
			return "skins"
		"chest":
			return "chest_%s" % String(reward.get("chest_type", reward.get("chestType", "common")))
	return "coin"


func _reward_label(reward: Dictionary) -> String:
	var amount := int(reward.get("amount", 1))
	match String(reward.get("type", "")):
		"coins":
			return "+%s %s" % [amount, _tr("coins")]
		"diamonds", "gems":
			return "+%s %s" % [amount, _tr("diamonds")]
		"keys":
			return "+%s %s" % [amount, _tr("keys")]
		"legendaryKeys", "legendary_keys":
			return "+%s %s" % [amount, _tr("legendary_key")]
		"xp", "profileXp", "profile_xp":
			return "+%s XP" % amount
		"fragments":
			return "+%s %s" % [amount, _tr("fragments")]
		"chest":
			return "%s x%s" % [_chest_label(String(reward.get("chest_type", reward.get("chestType", "common")))), amount]
		"skin":
			var skin_id := String(reward.get("skin_id", reward.get("skinId", "")))
			var skin := MainPortData.skin_by_id(skin_id)
			if skin.is_empty():
				return _tr("exclusive_skin")
			var language := LocalizationManager.current_language() if has_node("/root/LocalizationManager") else "en"
			return String(skin.get("name_pt", skin.get("name", skin_id.capitalize()))) if language.begins_with("pt") else String(skin.get("name_en", skin.get("name", skin_id.capitalize())))
	return _tr("reward")


func _chest_label(chest_type: String) -> String:
	var key := "chest_%s" % chest_type.to_lower()
	var translated := _tr(key)
	if translated == key:
		return "%s Chest" % chest_type.capitalize()
	return translated


func _track_fill_for_level(level: int) -> float:
	var current_level := int(_pass_state.get("level", 1))
	if level < current_level:
		return 1.0
	if level == current_level:
		return float(int(_pass_state.get("xp", 0))) / float(max(1, int(_pass_state.get("xp_needed", 100))))
	return 0.0


func _make_info_pill(label_text: String, value: String, tone: String) -> PanelContainer:
	var pill := PanelContainer.new()
	pill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pill.add_theme_stylebox_override("panel", _make_style("#ffffff10", 12, tone, 1, tone.replace("ff", "55"), 6))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	pill.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 0)
	margin.add_child(column)
	column.add_child(_make_label(label_text.to_upper(), 10, "#ffffff99", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	column.add_child(_make_label(value, 15, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	return pill


func _make_progress(value: float, tone: String) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 12)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.value = clampf(value, 0.0, 1.0)
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", _make_style("#ffffff14", 6, "#ffffff18", 1))
	bar.add_theme_stylebox_override("fill", _make_style(tone, 6, "#ffffff33", 1, tone.replace("ff", "88"), 8))
	return bar


func _make_icon(icon_key: String, size: int, modulation := Color.WHITE) -> TextureRect:
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(size, size)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.modulate = modulation
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var path := String(ICON_PATHS.get(icon_key, ICON_PATHS["locked"]))
	if ResourceLoader.exists(path):
		icon.texture = load(path)
	return icon


func _make_label(text: String, size: int, color: String, font: Font, alignment := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = alignment
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color(color))
	return label


func _make_background_gradient() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.48, 1.0])
	gradient.colors = PackedColorArray([Color("#05020b"), Color("#16002b"), Color("#06010d")])
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


func _safe_top_margin() -> float:
	var height := get_viewport_rect().size.y
	return 30.0 if height <= 680.0 else 42.0


func _season_name() -> String:
	var language := "en"
	if has_node("/root/LocalizationManager"):
		language = LocalizationManager.current_language()
	elif has_node("/root/GameState"):
		language = String(GameState.get_setting("language", "en"))
	return String(_pass_state.get("season_name_pt", _pass_state.get("season_name", ""))) if language.begins_with("pt") else String(_pass_state.get("season_name", "Neon Awakening"))


func _current_week_number() -> int:
	var date := Time.get_datetime_dict_from_system()
	return int(floor((int(date.get("day", 1)) - 1) / 7.0)) + 1


func _seconds_until_week_end() -> int:
	if has_node("/root/TimeManager"):
		return max(0, int(TimeManager.get_week_end_timestamp()) - int(TimeManager.get_now_timestamp()))
	return 0


func _seconds_until_month_end() -> int:
	var now := Time.get_datetime_dict_from_system()
	var next_year := int(now.year)
	var next_month := int(now.month) + 1
	if next_month > 12:
		next_month = 1
		next_year += 1
	var next_timestamp := Time.get_unix_time_from_datetime_dict({
		"year": next_year,
		"month": next_month,
		"day": 1,
		"hour": 0,
		"minute": 0,
		"second": 0,
	})
	return max(0, int(next_timestamp) - int(Time.get_unix_time_from_system()))


func _format_remaining(seconds: int) -> String:
	var days := seconds / 86400
	var hours := (seconds % 86400) / 3600
	var minutes := (seconds % 3600) / 60
	if days > 0:
		return "%sd %02sh" % [days, hours]
	if hours > 0:
		return "%sh %02sm" % [hours, minutes]
	return "%sm" % minutes


func _tr(key: String) -> String:
	return LocalizationManager.tr_key(key) if has_node("/root/LocalizationManager") else key


func _txt(en: String, pt := "", es := "", ja := "", zh := "") -> String:
	return LocalizationManager.text(en, pt, es, ja, zh) if has_node("/root/LocalizationManager") else en


func _fill(control: Control) -> void:
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 1.0
	control.anchor_bottom = 1.0
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0


func _spacer(height: float) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = height
	return spacer


func _make_system_font(weight: int) -> SystemFont:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Arial", "Helvetica", "Noto Sans", "DejaVu Sans", "sans-serif"])
	font.font_weight = weight
	return font


func _go_back() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)

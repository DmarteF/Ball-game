extends Control

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const SETTINGS_PATH := "user://settings.json"
const BUILD_VERSION := "1.0.13"
const NeonBackButtonScript := preload("res://scripts/NeonBackButton.gd")

const ICON_PATHS := {
	"settings": "res://assets/ui/ui_settings.png",
	"mute_on": "res://assets/ui/ui_mute_on.png",
	"mute_off": "res://assets/ui/ui_mute_off.png",
}

var _regular_font: Font
var _bold_font: Font
var _music_muted := false
var _sfx_muted := false
var _language := "en"
var _active_modal: Control
var _debug_taps := 0
var _debug_enabled := false
var _debug_fps_label: Label
var _debug_stats_label: Label
var _debug_update_accum := 0.0


func _process(delta: float) -> void:
	if not _debug_enabled:
		return
	_debug_update_accum += delta
	if _debug_update_accum < 0.5:
		return
	_debug_update_accum = 0.0
	_refresh_debug_labels()


func _ready() -> void:
	_regular_font = _make_system_font(400)
	_bold_font = _make_system_font(700)
	if has_node("/root/AudioManager"):
		AudioManager.play_context("menu")
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
	var margin_x := 12.0 if _is_narrow_screen() else 18.0
	root.offset_left = margin_x
	root.offset_top = 36.0 if _is_narrow_screen() else 50.0
	root.offset_right = -margin_x
	NeonBackButtonScript.reserve_footer_space(root)
	root.add_theme_constant_override("separation", 14)
	add_child(root)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 12)
	root.add_child(title_row)
	title_row.add_child(_make_icon("settings", 34))
	title_row.add_child(_make_label(_t("settings_title"), 28, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	NeonBackButtonScript.add_to(self, _go_back)

	var scroll := ScrollContainer.new()
	_configure_scroll(scroll)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)

	content.add_child(_make_audio_card())
	content.add_child(_make_language_card())
	content.add_child(_make_save_card())
	if _debug_enabled:
		content.add_child(_make_debug_card())
	content.add_child(_make_about_card())
	content.add_child(_spacer(18))


func _make_audio_card() -> PanelContainer:
	var card := _make_card()
	var body := _card_body(card)
	body.add_child(_make_section_title(_t("audio")))
	body.add_child(_make_audio_toggle(_t("music"), _music_muted, func() -> void:
		_music_muted = not _music_muted
		_save_settings()
		get_tree().reload_current_scene()
	))
	body.add_child(_make_audio_toggle(_t("sfx"), _sfx_muted, func() -> void:
		_sfx_muted = not _sfx_muted
		_save_settings()
		get_tree().reload_current_scene()
	))
	return card


func _make_audio_toggle(label: String, muted: bool, action: Callable) -> Button:
	var button := Button.new()
	button.custom_minimum_size.y = 58
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	_apply_button_style(button, _make_style("#00f0ff" if not muted else "#ffffff14", 14, "#00f0ff88", 1, "#00f0ff66", 8))
	button.pressed.connect(action)
	var row := HBoxContainer.new()
	_fill(row)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(row)
	row.add_child(_make_icon("mute_off" if muted else "mute_on", 22, Color("#ffffff") if muted else Color("#001018")))
	row.add_child(_make_label("%s: %s" % [label, _t("muted") if muted else _t("on")], 18, "#ffffff" if muted else "#001018", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	return button


func _make_language_card() -> PanelContainer:
	var card := _make_card()
	var body := _card_body(card)
	body.add_child(_make_section_title(_t("language")))
	body.add_child(_make_label(_t("choose_language"), 14, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))
	var grid := GridContainer.new()
	grid.columns = 1
	grid.add_theme_constant_override("v_separation", 8)
	body.add_child(grid)
	grid.add_child(_make_language_button("Português", "pt"))
	grid.add_child(_make_language_button("English", "en"))
	grid.add_child(_make_language_button("Español", "es"))
	return card


func _make_save_card() -> PanelContainer:
	var card := _make_card()
	var body := _card_body(card)
	body.add_child(_make_section_title(_t("save_progress")))
	var text := _make_label(_t("save_help"), 13, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(text)
	body.add_child(_make_save_button(_t("export_save"), "#00f0ff", _show_export_save))
	body.add_child(_make_save_button(_t("import_save"), "#00ff88", _show_import_save))
	body.add_child(_make_save_button(_t("copy_save"), "#ffd700", _copy_save_code))
	body.add_child(_make_save_button(_t("paste_save"), "#ff5cff", _show_paste_save))
	body.add_child(_make_save_button(_t("reset_progress"), "#ff3b6b", _show_reset_warning))
	return card


func _make_about_card() -> PanelContainer:
	var card := _make_card()
	var body := _card_body(card)
	body.add_child(_make_section_title(_t("about")))
	body.add_child(_make_label("Neon Idle Escape", 18, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	var text := _make_label(_t("about_text"), 13, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(text)
	var secret := Button.new()
	secret.text = "💎"
	secret.custom_minimum_size = Vector2(34, 30)
	secret.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	secret.focus_mode = Control.FOCUS_NONE
	secret.add_theme_font_size_override("font_size", 16)
	secret.add_theme_stylebox_override("normal", _make_style("#00000000", 8))
	secret.add_theme_stylebox_override("hover", _make_style("#ffffff08", 8))
	secret.add_theme_stylebox_override("pressed", _make_style("#ffffff12", 8))
	secret.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	secret.pressed.connect(_on_debug_secret_pressed)
	body.add_child(secret)
	return card


func _make_debug_card() -> PanelContainer:
	var card := _make_card()
	card.add_theme_stylebox_override("panel", _make_style("#0b0820ee", 12, "#ff5cff88", 1, "#ff5cff55", 10))
	var body := _card_body(card)
	body.add_child(_make_section_title(_t("debug_mode")))
	_debug_fps_label = _make_label("", 15, "#00ff88", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	body.add_child(_debug_fps_label)
	_debug_stats_label = _make_label("", 12, "#ffffffcc", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	_debug_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(_debug_stats_label)
	body.add_child(_make_debug_grid([
		[_t("add_1k_coins"), "#ffd700", func() -> void: _debug_add_resource("coins", 1000)],
		[_t("add_10k_coins"), "#ffd700", func() -> void: _debug_add_resource("coins", 10000)],
		[_t("add_100_diamonds"), "#00f0ff", func() -> void: _debug_add_resource("diamonds", 100)],
		[_t("add_1000_diamonds"), "#00f0ff", func() -> void: _debug_add_resource("diamonds", 1000)],
		[_t("add_10_keys"), "#ff5cff", func() -> void: _debug_add_resource("keys", 10)],
		[_t("add_100_keys"), "#ff5cff", func() -> void: _debug_add_resource("keys", 100)],
		[_t("add_1k_xp"), "#7dd3fc", func() -> void: _debug_add_xp(1000)],
		[_t("add_10k_xp"), "#7dd3fc", func() -> void: _debug_add_xp(10000)],
		[_t("add_1_level"), "#00ff88", func() -> void: _debug_add_levels(1)],
		[_t("add_10_levels"), "#00ff88", func() -> void: _debug_add_levels(10)],
	]))
	body.add_child(_make_debug_grid([
		[_t("unlock_all_levels"), "#ffffff", func() -> void: _confirm_debug_action(_t("unlock_all_levels"), func() -> void: GameState.debug_unlock_all_levels())],
		[_t("print_upgrade_state"), "#00f0ff", _print_upgrade_state],
		[_t("unlock_next_upgrade"), "#00ff88", _unlock_next_upgrade],
		[_t("unlock_all_upgrades"), "#ffffff", func() -> void: _confirm_debug_action(_t("unlock_all_upgrades"), func() -> void: GameState.debug_unlock_all_upgrades())],
		[_t("lock_starter_upgrades"), "#ffb000", func() -> void: _confirm_debug_action(_t("lock_starter_upgrades"), func() -> void: GameState.debug_lock_all_except_starter_upgrades())],
		[_t("reset_upgrade_levels"), "#ffb000", func() -> void: _confirm_debug_action(_t("reset_upgrade_levels"), func() -> void: GameState.debug_reset_upgrade_levels())],
		[_t("unlock_all_skins"), "#ffffff", func() -> void: _confirm_debug_action(_t("unlock_all_skins"), func() -> void: GameState.debug_unlock_all_skins())],
		[_t("level_up_equipped_skin"), "#00ff88", func() -> void: _debug_skin_action(func() -> void: GameState.debug_level_up_equipped_skin())],
		[_t("max_equipped_skin"), "#00f0ff", func() -> void: _debug_skin_action(func() -> void: GameState.debug_max_equipped_skin())],
		[_t("max_all_skins"), "#ffffff", func() -> void: _confirm_debug_action(_t("max_all_skins"), func() -> void: _debug_skin_action(func() -> void: GameState.debug_max_all_skins()))],
		[_t("reset_skin_levels"), "#ffb000", func() -> void: _confirm_debug_action(_t("reset_skin_levels"), func() -> void: _debug_skin_action(func() -> void: GameState.debug_reset_skin_levels()))],
		[_t("reset_daily"), "#ffb000", func() -> void: _confirm_debug_action(_t("reset_daily"), func() -> void: GameState.debug_reset_daily_reward())],
		[_t("reset_daily_challenge"), "#ffb000", func() -> void: _confirm_debug_action(_t("reset_daily_challenge"), func() -> void: GameState.debug_reset_daily_challenge())],
		[_t("reroll_daily_challenge"), "#00f0ff", func() -> void: _confirm_debug_action(_t("reroll_daily_challenge"), func() -> void: GameState.debug_randomize_daily_challenge_seed())],
		[_t("next_daily_challenge"), "#00ff88", func() -> void: _confirm_debug_action(_t("next_daily_challenge"), func() -> void: GameState.debug_simulate_next_daily_challenge_day())],
		[_t("reset_wheel"), "#ffb000", func() -> void: _confirm_debug_action(_t("reset_wheel"), func() -> void: GameState.debug_reset_wheel_timer())],
		[_t("reset_tutorial"), "#ffb000", func() -> void: _confirm_debug_action(_t("reset_tutorial"), func() -> void: GameState.reset_tutorial_for_debug())],
		[_t("export_debug_save"), "#00f0ff", _show_export_save],
		[_t("force_ad_success"), "#00ff88", _toggle_force_ad_success],
		[_t("force_ad_failure"), "#ff6b9a", _toggle_force_ad_failure],
		[_t("reset_ad_cooldowns"), "#ffb000", func() -> void: _confirm_debug_action(_t("reset_ad_cooldowns"), func() -> void: AdManager.reset_cooldowns())],
		[_t("reset_ad_session"), "#ffb000", func() -> void: _confirm_debug_action(_t("reset_ad_session"), func() -> void: AdManager.reset_session_limits())],
		[_t("disable_debug"), "#ff3b6b", _disable_debug_mode],
	]))
	_refresh_debug_labels()
	return card


func _make_debug_grid(items: Array) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 1 if _is_narrow_screen() else 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	for item in items:
		var data: Array = item
		grid.add_child(_make_save_button(String(data[0]), String(data[1]), data[2]))
	return grid


func _make_save_button(text: String, color: String, action: Callable) -> Button:
	var button := _make_solid_button(text, "#ffffff12", color, 220, 50)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_stylebox_override("normal", _make_style("#ffffff12", 12, color + "88", 1, color + "33", 8))
	button.add_theme_stylebox_override("hover", _make_style("#ffffff18", 12, color, 1, color + "44", 9))
	button.add_theme_stylebox_override("pressed", _make_style("#ffffff22", 12, color, 1, color + "55", 10))
	button.pressed.connect(action)
	return button


func _make_language_button(label: String, code: String) -> Button:
	var active := _language == code
	var button := _make_solid_button("%s%s" % [label, "  OK" if active else ""], "#00ff8822" if active else "#ffffff14", "#00ff88" if active else "#ffffff", 220, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	button.add_theme_stylebox_override("normal", _make_style("#00ff8822" if active else "#ffffff14", 10, "#00ff88" if active else "#ffffff22", 1))
	button.add_theme_stylebox_override("hover", _make_style("#00ff8822" if active else "#ffffff14", 10, "#00ff88" if active else "#ffffff22", 1))
	button.add_theme_stylebox_override("pressed", _make_style("#00ff8822" if active else "#ffffff14", 10, "#00ff88" if active else "#ffffff22", 1))
	button.pressed.connect(func() -> void:
		_language = code
		_save_settings()
		if has_node("/root/LocalizationManager"):
			LocalizationManager.set_language(code)
		get_tree().reload_current_scene()
	)
	return button


func _show_export_save() -> void:
	var code := GameState.export_save_text()
	var path := SaveManager.write_export_file(code)
	var message := _t("export_ready")
	if not path.is_empty():
		message += "\n%s: %s" % [_t("saved_file"), path]
	_show_code_modal(_t("export_save"), message, code, false, [])


func _copy_save_code() -> void:
	var code := GameState.export_save_text()
	DisplayServer.clipboard_set(code)
	_show_code_modal(_t("copy_save"), _t("copy_done"), code, false, [])


func _show_import_save() -> void:
	_show_import_editor("")


func _show_paste_save() -> void:
	_show_import_editor(DisplayServer.clipboard_get())


func _show_import_editor(initial_text: String) -> void:
	var import_button := Button.new()
	import_button.text = _t("validate_import")
	_style_modal_button(import_button, "#00ff88")
	_show_code_modal(_t("import_save"), _t("paste_help"), initial_text, true, [import_button])
	var editor := _active_modal.get_meta("code_editor") as TextEdit
	import_button.pressed.connect(func() -> void:
		_validate_import_text(editor.text)
	)


func _validate_import_text(text: String) -> void:
	var validation := GameState.validate_import_save_text(text)
	if not bool(validation.get("ok", false)):
		_show_message_modal(_t("import_error"), _import_error_message(String(validation.get("reason", ""))), "#ff3b6b")
		return
	var preview: Dictionary = validation.get("preview", {})
	var body := "%s\n\n%s: %s\n%s: %s\n%s: %s\n%s: %s\n%s: %s" % [
		_t("import_confirm"),
		_t("coins"), int(preview.get("coins", 0)),
		_t("diamonds"), int(preview.get("diamonds", 0)),
		_t("level"), int(preview.get("level", 1)),
		_t("max_phase"), int(preview.get("max_phase", 1)),
		_t("skins"), int(preview.get("skins", 0)),
	]
	var cancel := Button.new()
	cancel.text = _t("cancel")
	_style_modal_button(cancel, "#ffffff")
	cancel.pressed.connect(_close_modal)
	var confirm := Button.new()
	confirm.text = _t("confirm_import")
	_style_modal_button(confirm, "#00ff88")
	confirm.pressed.connect(func() -> void:
		var result := GameState.import_save_text(text)
		if bool(result.get("ok", false)):
			_load_settings()
			_show_message_modal(_t("import_success"), _t("import_success_body"), "#00ff88")
		else:
			_show_message_modal(_t("import_error"), _import_error_message(String(result.get("reason", ""))), "#ff3b6b")
	)
	_show_message_modal(_t("import_save"), body, "#00ff88", [cancel, confirm])


func _show_reset_warning() -> void:
	var cancel := Button.new()
	cancel.text = _t("cancel")
	_style_modal_button(cancel, "#ffffff")
	cancel.pressed.connect(_close_modal)
	var next := Button.new()
	next.text = _t("continue")
	_style_modal_button(next, "#ff3b6b")
	next.pressed.connect(_show_reset_type_confirm)
	_show_message_modal(_t("reset_progress"), _t("reset_warning"), "#ff3b6b", [cancel, next])


func _show_reset_type_confirm() -> void:
	_close_modal()
	var overlay := _make_modal_root()
	var body := _modal_body(overlay, _t("reset_progress"), "#ff3b6b")
	var label := _make_label(_t("reset_type_reset"), 14, "#ffffffcc", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(label)
	var input := LineEdit.new()
	input.placeholder_text = "RESET"
	input.custom_minimum_size.y = 48
	input.add_theme_font_override("font", _bold_font)
	input.add_theme_font_size_override("font_size", 16)
	input.add_theme_color_override("font_color", Color("#ffffff"))
	input.add_theme_color_override("caret_color", Color("#00f0ff"))
	input.add_theme_stylebox_override("normal", _make_style("#050516", 10, "#ff3b6b88", 1))
	input.add_theme_stylebox_override("focus", _make_style("#050516", 10, "#ff3b6b", 1, "#ff3b6b55", 8))
	body.add_child(input)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	body.add_child(row)
	var cancel := Button.new()
	cancel.text = _t("cancel")
	_style_modal_button(cancel, "#ffffff")
	cancel.pressed.connect(_close_modal)
	row.add_child(cancel)
	var confirm := Button.new()
	confirm.text = _t("confirm_reset")
	_style_modal_button(confirm, "#ff3b6b")
	confirm.pressed.connect(func() -> void:
		if input.text.strip_edges() != "RESET":
			_show_message_modal(_t("reset_progress"), _t("reset_need_reset"), "#ff3b6b")
			return
		GameState.reset_progress()
		_load_settings()
		_show_message_modal(_t("reset_progress"), _t("reset_done"), "#00ff88")
	)
	row.add_child(confirm)
	add_child(overlay)
	_active_modal = overlay
	input.grab_focus()


func _debug_make_test_save() -> void:
	GameState.make_debug_save()
	_show_message_modal(_t("debug_tools"), _t("debug_test_done"), "#00ff88")


func _debug_unlock_all() -> void:
	GameState.debug_unlock_all()
	_show_message_modal(_t("debug_tools"), _t("debug_unlock_done"), "#00ff88")


func _on_debug_secret_pressed() -> void:
	if _debug_enabled:
		_show_toast(_t("debug_already_enabled"))
		return
	_debug_taps += 1
	if _debug_taps >= 4:
		_debug_taps = 0
		_debug_enabled = true
		GameState.set_debug_enabled(true)
		_show_toast(_t("debug_enabled_toast"))
		get_tree().create_timer(0.35).timeout.connect(func() -> void:
			get_tree().reload_current_scene()
		)


func _disable_debug_mode() -> void:
	GameState.set_debug_enabled(false)
	_debug_enabled = false
	_show_toast(_t("debug_disabled_toast"))
	get_tree().create_timer(0.35).timeout.connect(func() -> void:
		get_tree().reload_current_scene()
	)


func _debug_add_resource(kind: String, amount: int) -> void:
	match kind:
		"coins":
			GameState.add_coins(amount)
		"diamonds":
			GameState.add_diamonds(amount)
		"keys":
			GameState.add_keys(amount)
	_show_toast(_t("debug_done"))
	_refresh_debug_labels()


func _debug_add_levels(amount: int) -> void:
	GameState.debug_add_levels(amount)
	_show_toast(_t("debug_done"))
	_refresh_debug_labels()


func _debug_add_xp(amount: int) -> void:
	GameState.add_profile_xp(amount)
	_show_toast(_t("debug_done"))
	_refresh_debug_labels()


func _debug_skin_action(action: Callable) -> void:
	if action.is_valid():
		action.call()
	_show_toast(_t("debug_done"))
	_refresh_debug_labels()


func _confirm_debug_action(title: String, action: Callable) -> void:
	var cancel := Button.new()
	cancel.text = _t("cancel")
	_style_modal_button(cancel, "#ffffff")
	cancel.pressed.connect(_close_modal)
	var confirm := Button.new()
	confirm.text = _t("confirm")
	_style_modal_button(confirm, "#ffb000")
	confirm.pressed.connect(func() -> void:
		action.call()
		_close_modal()
		_show_toast(_t("debug_done"))
		_refresh_debug_labels()
	)
	_show_message_modal(title, _t("debug_confirm_body"), "#ffb000", [cancel, confirm])


func _toggle_force_ad_success() -> void:
	AdManager.set_force_success(not AdManager.is_force_success())
	_show_toast(_t("debug_done"))
	_refresh_debug_labels()


func _toggle_force_ad_failure() -> void:
	AdManager.set_force_failure(not AdManager.is_force_failure())
	_show_toast(_t("debug_done"))
	_refresh_debug_labels()


func _print_upgrade_state() -> void:
	var state := GameState.debug_upgrade_state()
	var lines := [
		"total_upgrades: %s" % int(state.get("total_upgrades", 0)),
		"unlocked_count: %s" % int(state.get("unlocked_count", 0)),
		"locked_count: %s" % int(state.get("locked_count", 0)),
		"unlocked_upgrade_ids: %s" % JSON.stringify(state.get("unlocked_upgrade_ids", [])),
		"gameplay_pool_ids: %s" % JSON.stringify(state.get("gameplay_pool_ids", [])),
		"upgrade_levels: %s" % JSON.stringify(state.get("upgrade_levels", {})),
	]
	_show_message_modal(_t("print_upgrade_state"), "\n".join(lines), "#00f0ff")
	_refresh_debug_labels()


func _unlock_next_upgrade() -> void:
	var result := GameState.debug_unlock_next_upgrade()
	_show_toast(String(result.get("name", result.get("reason", "OK"))))
	_refresh_debug_labels()


func _refresh_debug_labels() -> void:
	if _debug_fps_label != null and is_instance_valid(_debug_fps_label):
		_debug_fps_label.text = "%s: %s" % [_t("fps"), Engine.get_frames_per_second()]
	if _debug_stats_label == null or not is_instance_valid(_debug_stats_label):
		return
	var runtime: Dictionary = GameState.data.get("runtime_debug", {})
	var wheel: Dictionary = GameState.data.get("wheel", {})
	var daily: Dictionary = GameState.data.get("daily_missions", {})
	var challenge: Dictionary = GameState.get_daily_challenge()
	var current_music := "-"
	var music_context := "-"
	if has_node("/root/AudioManager"):
		current_music = AudioManager.current_music_path().get_file()
		music_context = AudioManager.current_context()
	var lines := [
		"%s: %s" % [_t("active_rings"), int(runtime.get("active_rings", 0))],
		"%s: %s" % [_t("active_particles"), int(runtime.get("particles", 0))],
		"%s: %s" % [_t("current_mode"), String(runtime.get("mode", GameState.data.get("selected_mode", "menu")))],
		"%s: %s" % [_t("equipped_skin"), String(GameState.data.get("equipped_skin", "neon_blue"))],
		"%s: %s / %s" % [_t("current_music"), music_context, current_music],
		"%s: %s" % [_t("build_version"), BUILD_VERSION],
		"%s: %s / %s" % [_t("seed"), String(wheel.get("day_key", "")), String(daily.get("day_key", ""))],
		"%s: %s" % [_t("daily_challenge_seed"), String(challenge.get("seed", ""))],
		"%s: %s  %s: %s  %s: %s  XP: %s  %s: %s" % [
			_t("coins"), int(GameState.data.get("coins", 0)),
			_t("diamonds"), int(GameState.data.get("diamonds", 0)),
			_t("keys"), int(GameState.data.get("keys", 0)),
			int(GameState.data.get("xp", 0)),
			_t("level"), int(GameState.data.get("level", 1)),
		],
	]
	if has_node("/root/AdManager"):
		var ads := AdManager.ad_debug_summary()
		lines.append("%s: %s" % [_t("ad_completed"), JSON.stringify(ads.get("completed", {}))])
		lines.append("%s: %s" % [_t("ad_failed"), JSON.stringify(ads.get("failed", {}))])
		lines.append("%s: %s / %s: %s" % [_t("force_ad_success"), bool(ads.get("force_success", false)), _t("force_ad_failure"), bool(ads.get("force_failure", false))])
	_debug_stats_label.text = "\n".join(lines)


func _show_toast(message: String) -> void:
	var toast := PanelContainer.new()
	toast.anchor_left = 0.5
	toast.anchor_right = 0.5
	toast.anchor_top = 0.0
	toast.anchor_bottom = 0.0
	toast.offset_left = -132
	toast.offset_right = 132
	toast.offset_top = 24
	toast.offset_bottom = 72
	toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast.add_theme_stylebox_override("panel", _make_style("#08132bee", 14, "#00f0ff99", 1, "#00f0ff55", 10))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	toast.add_child(margin)
	margin.add_child(_make_label(message, 13, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	add_child(toast)
	get_tree().create_timer(1.6).timeout.connect(func() -> void:
		if is_instance_valid(toast):
			toast.queue_free()
	)


func _show_code_modal(title: String, message: String, code: String, editable: bool, extra_buttons: Array) -> void:
	_close_modal()
	var overlay := _make_modal_root()
	var body := _modal_body(overlay, title, "#00f0ff")
	var label := _make_label(message, 13, "#ffffffcc", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(label)
	var editor := TextEdit.new()
	editor.text = code
	editor.editable = editable
	editor.custom_minimum_size = Vector2(0, 210 if _is_narrow_screen() else 260)
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	editor.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	editor.add_theme_font_override("font", _regular_font)
	editor.add_theme_font_size_override("font_size", 11)
	editor.add_theme_color_override("font_color", Color("#ffffff"))
	editor.add_theme_color_override("caret_color", Color("#00f0ff"))
	editor.add_theme_stylebox_override("normal", _make_style("#030312", 10, "#00f0ff77", 1))
	body.add_child(editor)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	body.add_child(row)
	var close := Button.new()
	close.text = _t("close")
	_style_modal_button(close, "#ffffff")
	close.pressed.connect(_close_modal)
	row.add_child(close)
	for button in extra_buttons:
		row.add_child(button)
	overlay.set_meta("code_editor", editor)
	add_child(overlay)
	_active_modal = overlay
	if editable:
		editor.grab_focus()


func _show_message_modal(title: String, message: String, accent: String, buttons: Array = []) -> void:
	_close_modal()
	var overlay := _make_modal_root()
	var body := _modal_body(overlay, title, accent)
	var label := _make_label(message, 14, "#ffffffcc", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(label)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	body.add_child(row)
	if buttons.is_empty():
		var close := Button.new()
		close.text = _t("close")
		_style_modal_button(close, accent)
		close.pressed.connect(_close_modal)
		row.add_child(close)
	else:
		for button in buttons:
			row.add_child(button)
	add_child(overlay)
	_active_modal = overlay


func _make_modal_root() -> Control:
	var overlay := Control.new()
	_fill(overlay)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var shade := ColorRect.new()
	_fill(shade)
	shade.color = Color("#000000bb")
	overlay.add_child(shade)
	var center := CenterContainer.new()
	_fill(center)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.offset_left = 12
	center.offset_top = 24
	center.offset_right = -12
	center.offset_bottom = -24
	overlay.add_child(center)
	var panel := PanelContainer.new()
	var viewport := get_viewport_rect().size
	panel.custom_minimum_size = Vector2(min(340.0, max(280.0, viewport.x - 28.0)), min(520.0, max(260.0, viewport.y - 88.0)))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.add_theme_stylebox_override("panel", _make_style("#11102aee", 16, "#00f0ff88", 1, "#00f0ff55", 14))
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.follow_focus = true
	scroll.scroll_deadzone = 4
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	margin.add_child(scroll)
	var body := VBoxContainer.new()
	body.name = "ModalBody"
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	scroll.add_child(body)
	return overlay


func _modal_body(overlay: Control, title: String, accent: String) -> VBoxContainer:
	var body := overlay.find_child("ModalBody", true, false) as VBoxContainer
	body.add_child(_make_label(title, 20, accent, _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	return body


func _style_modal_button(button: Button, color: String) -> void:
	button.custom_minimum_size = Vector2(120, 44)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color(color))
	button.add_theme_stylebox_override("normal", _make_style("#ffffff12", 11, color + "88", 1))
	button.add_theme_stylebox_override("hover", _make_style("#ffffff18", 11, color, 1))
	button.add_theme_stylebox_override("pressed", _make_style("#ffffff22", 11, color, 1))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _close_modal() -> void:
	if _active_modal != null and is_instance_valid(_active_modal):
		_active_modal.queue_free()
	_active_modal = null


func _import_error_message(reason: String) -> String:
	match reason:
		"empty": return _t("error_empty")
		"json": return _t("error_json")
		"format": return _t("error_format")
		"version": return _t("error_version")
		"data", "structure": return _t("error_structure")
	return _t("error_unknown")


func _make_card() -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_theme_stylebox_override("panel", _make_style("#ffffff12", 12, "#ffffff22", 1))
	return card


func _card_body(card: PanelContainer) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_child(margin)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	body.mouse_filter = Control.MOUSE_FILTER_PASS
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
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if font_size <= 13:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _make_flat_button(text: String, color: String, size: int) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", size)
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.add_theme_color_override("font_color", Color(color))
	_apply_button_style(button, _make_style("#00000000", 0))
	return button


func _make_solid_button(text: String, bg: String, color: String, width: float, height: float) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(width, height)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 14)
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.add_theme_color_override("font_color", Color(color))
	_apply_button_style(button, _make_style(bg, 10, "#ffffff22", 1))
	return button


func _spacer(height: float) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = height
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer


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
	_music_muted = bool(GameState.get_setting("music_muted", GameState.get_setting("audio_muted", false)))
	_sfx_muted = bool(GameState.get_setting("sfx_muted", GameState.get_setting("audio_muted", false)))
	_language = String(GameState.get_setting("language", "en"))
	_debug_enabled = bool(GameState.get_setting("debug_enabled", false))


func _save_settings() -> void:
	GameState.set_music_muted(_music_muted)
	GameState.set_sfx_muted(_sfx_muted)
	if has_node("/root/LocalizationManager"):
		LocalizationManager.set_language(_language)
	else:
		GameState.set_language(_language)
	if has_node("/root/AudioManager"):
		AudioManager.apply_audio_settings()


func _t(key: String) -> String:
	var pt := _language == "pt"
	match key:
		"settings_title": return "CONFIGURAÇÕES" if pt else "SETTINGS"
		"audio": return "ÁUDIO" if pt else "AUDIO"
		"music": return "Música" if pt else "Music"
		"sfx": return "Efeitos" if pt else "Sound FX"
		"muted": return "Mudo" if pt else "Muted"
		"on": return "Ligado" if pt else "On"
		"language": return "IDIOMA" if pt else "LANGUAGE"
		"choose_language": return "Escolha o idioma da interface." if pt else "Choose the interface language."
		"about": return "SOBRE" if pt else "ABOUT"
		"about_text": return "Versão Godot 4 em migração fiel, mantendo o visual neon, controles mobile e estrutura preparada para Web." if pt else "Godot 4 faithful migration, keeping the neon look, mobile controls and Web-ready structure."
		"save_progress": return "SAVE / PROGRESSO" if pt else "SAVE / PROGRESS"
		"save_help": return "Exporte, importe ou restaure seu progresso com segurança. A importação cria backup automático antes de substituir o save atual." if pt else "Export, import or restore your progress safely. Import creates an automatic backup before replacing the current save."
		"export_save": return "Exportar Save" if pt else "Export Save"
		"import_save": return "Importar Save" if pt else "Import Save"
		"copy_save": return "Copiar Código do Save" if pt else "Copy Save Code"
		"paste_save": return "Colar Código do Save" if pt else "Paste Save Code"
		"reset_progress": return "Resetar Progresso" if pt else "Reset Progress"
		"export_ready": return "Código do save gerado. Copie o texto abaixo e guarde em local seguro." if pt else "Save code generated. Copy the text below and keep it somewhere safe."
		"saved_file": return "Arquivo local" if pt else "Local file"
		"copy_done": return "Código copiado para a área de transferência quando disponível. Se o navegador bloquear, copie pelo campo abaixo." if pt else "Code copied to clipboard when available. If the browser blocks it, copy it from the field below."
		"paste_help": return "Cole o JSON/código do save abaixo. O jogo validará antes de substituir seu progresso." if pt else "Paste the save JSON/code below. The game will validate it before replacing your progress."
		"validate_import": return "Validar Importação" if pt else "Validate Import"
		"import_confirm": return "Save válido encontrado. Confirme para substituir o progresso atual. Um backup automático será criado antes." if pt else "Valid save found. Confirm to replace current progress. An automatic backup will be created first."
		"confirm_import": return "Confirmar Importação" if pt else "Confirm Import"
		"import_success": return "Importação concluída" if pt else "Import Complete"
		"import_success_body": return "Progresso importado com sucesso. Volte ao menu para ver tudo atualizado." if pt else "Progress imported successfully. Return to the menu to see everything updated."
		"import_error": return "Importação inválida" if pt else "Invalid Import"
		"reset_warning": return "Isso apagará todo o progresso. Esta ação cria um backup, mas substitui imediatamente o save atual. Deseja continuar?" if pt else "This will erase all progress. This action creates a backup, but immediately replaces the current save. Continue?"
		"reset_type_reset": return "Confirmação final: digite RESET para apagar todo o progresso." if pt else "Final confirmation: type RESET to erase all progress."
		"reset_need_reset": return "Digite RESET exatamente para confirmar." if pt else "Type RESET exactly to confirm."
		"reset_done": return "Progresso resetado com segurança." if pt else "Progress safely reset."
		"continue": return "Continuar" if pt else "Continue"
		"confirm_reset": return "Confirmar Reset" if pt else "Confirm Reset"
		"cancel": return "Cancelar" if pt else "Cancel"
		"close": return "Fechar" if pt else "Close"
		"coins": return "Moedas" if pt else "Coins"
		"diamonds": return "Diamantes" if pt else "Diamonds"
		"level": return "Nível" if pt else "Level"
		"max_phase": return "Fase máxima" if pt else "Max phase"
		"skins": return "Skins" if pt else "Skins"
		"debug_tools": return "DEBUG" if pt else "DEBUG"
		"debug_test_save": return "Gerar save de teste" if pt else "Generate test save"
		"debug_unlock_all": return "Desbloquear tudo" if pt else "Unlock all"
		"debug_clear_save": return "Limpar save" if pt else "Clear save"
		"debug_test_done": return "Recursos de teste adicionados." if pt else "Test resources added."
		"debug_unlock_done": return "Conteúdo desbloqueado no save de debug." if pt else "Content unlocked in debug save."
		"debug_mode": return "MODO DEBUG" if pt else "DEBUG MODE"
		"debug_enabled_toast": return "Debug ativado" if pt else "Debug enabled"
		"debug_disabled_toast": return "Debug desativado" if pt else "Debug disabled"
		"debug_already_enabled": return "Debug já está ativo" if pt else "Debug already enabled"
		"debug_done": return "Ação debug aplicada" if pt else "Debug action applied"
		"debug_confirm_body": return "Esta ação altera bastante o progresso. Confirmar?" if pt else "This action changes progress significantly. Confirm?"
		"fps": return "FPS" if pt else "FPS"
		"active_rings": return "Anéis ativos" if pt else "Active rings"
		"active_particles": return "Partículas ativas" if pt else "Active particles"
		"current_mode": return "Modo atual" if pt else "Current mode"
		"equipped_skin": return "Skin equipada" if pt else "Equipped skin"
		"current_music": return "Música atual" if pt else "Current music"
		"build_version": return "Versão do build" if pt else "Build version"
		"seed": return "Seed roleta/desafio" if pt else "Wheel/daily seed"
		"add_1k_coins": return "+1.000 moedas" if pt else "+1,000 coins"
		"add_10k_coins": return "+10.000 moedas" if pt else "+10,000 coins"
		"add_100_diamonds": return "+100 diamantes" if pt else "+100 diamonds"
		"add_1000_diamonds": return "+1.000 diamantes" if pt else "+1,000 diamonds"
		"add_10_keys": return "+10 chaves" if pt else "+10 keys"
		"add_100_keys": return "+100 chaves" if pt else "+100 keys"
		"add_1k_xp": return "+1.000 XP" if pt else "+1,000 XP"
		"add_10k_xp": return "+10.000 XP" if pt else "+10,000 XP"
		"add_1_level": return "+1 nível" if pt else "+1 level"
		"add_10_levels": return "+10 níveis" if pt else "+10 levels"
		"unlock_all_levels": return "Liberar Todas as Fases" if pt else "Unlock All Levels"
		"print_upgrade_state": return "Print Upgrade State"
		"unlock_next_upgrade": return "Liberar Próxima Melhoria" if pt else "Unlock Next Upgrade"
		"unlock_all_upgrades": return "Liberar Todas as Melhorias" if pt else "Unlock All Upgrades"
		"lock_starter_upgrades": return "Bloquear Exceto Starters" if pt else "Lock All Except Starter Upgrades"
		"reset_upgrade_levels": return "Resetar Níveis de Melhorias" if pt else "Reset Upgrade Levels"
		"unlock_all_skins": return "Liberar Todas as Skins" if pt else "Unlock All Skins"
		"level_up_equipped_skin": return "Upar Skin Equipada" if pt else "Level Up Equipped Skin"
		"max_equipped_skin": return "Maximizar Skin Equipada" if pt else "Max Equipped Skin"
		"max_all_skins": return "Maximizar Todas as Skins" if pt else "Max All Skins"
		"reset_skin_levels": return "Resetar Níveis das Skins" if pt else "Reset Skin Levels"
		"skin_level": return "Nível da Skin" if pt else "Skin Level"
		"level": return "Nível" if pt else "Level"
		"max_level": return "Nível Máximo" if pt else "Max Level"
		"upgrade_skin": return "Melhorar Skin" if pt else "Upgrade Skin"
		"upgrade_with_coins": return "Melhorar com Moedas" if pt else "Upgrade with Coins"
		"upgrade_with_diamonds": return "Melhorar com Diamantes" if pt else "Upgrade with Diamonds"
		"current_effect": return "Efeito Atual" if pt else "Current Effect"
		"next_level": return "Próximo Nível" if pt else "Next Level"
		"max": return "Máximo" if pt else "Max"
		"not_enough_coins": return "Moedas insuficientes" if pt else "Not enough coins"
		"not_enough_diamonds": return "Diamantes insuficientes" if pt else "Not enough diamonds"
		"skin_upgraded": return "Skin melhorada" if pt else "Skin upgraded"
		"reset_daily": return "Resetar Recompensa Diária" if pt else "Reset Daily Reward"
		"reset_daily_challenge": return "Resetar Desafio Diário" if pt else "Reset Daily Challenge"
		"reroll_daily_challenge": return "Trocar Seed do Desafio" if pt else "Change Challenge Seed"
		"next_daily_challenge": return "Simular Próximo Dia" if pt else "Simulate Next Day"
		"daily_challenge_seed": return "Seed do desafio" if pt else "Challenge seed"
		"reset_wheel": return "Resetar Timer da Roleta" if pt else "Reset Wheel Timer"
		"reset_tutorial": return "Resetar Tutorial" if pt else "Reset Tutorial"
		"export_debug_save": return "Exportar Save Debug" if pt else "Export Debug Save"
		"force_ad_success": return "Forçar sucesso de anúncio" if pt else "Force ad success"
		"force_ad_failure": return "Forçar falha de anúncio" if pt else "Force ad failure"
		"reset_ad_cooldowns": return "Resetar cooldowns de anúncios" if pt else "Reset ad cooldowns"
		"reset_ad_session": return "Resetar limites da sessão" if pt else "Reset session limits"
		"ad_completed": return "Anúncios completos" if pt else "Completed ads"
		"ad_failed": return "Anúncios falhos" if pt else "Failed ads"
		"disable_debug": return "Desativar Debug" if pt else "Disable Debug"
		"confirm": return "Confirmar" if pt else "Confirm"
		"error_empty": return "O campo está vazio." if pt else "The field is empty."
		"error_json": return "JSON inválido ou corrompido." if pt else "Invalid or corrupted JSON."
		"error_format": return "Formato de save não reconhecido." if pt else "Unknown save format."
		"error_version": return "Este save é de uma versão mais nova do jogo." if pt else "This save is from a newer game version."
		"error_structure": return "O save não possui a estrutura mínima esperada." if pt else "The save does not have the expected minimum structure."
		"error_unknown": return "Não foi possível importar este save." if pt else "Could not import this save."
	return key


func _go_back() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


func _configure_scroll(scroll: ScrollContainer) -> void:
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.follow_focus = true
	scroll.scroll_deadzone = 4
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP


func _is_narrow_screen() -> bool:
	return get_viewport_rect().size.x <= 430.0

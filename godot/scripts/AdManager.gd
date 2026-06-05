extends Node

const MOCK_ENABLED := true

const REASONS := [
	"revive",
	"double_rewards",
	"reroll_upgrades",
	"free_chest",
	"wheel_extra_spin",
	"daily_bonus",
	"shop_free_coins",
	"shop_free_diamonds",
	"boss_retry",
	"league_double_rewards",
]

const COOLDOWNS := {
	"free_chest": 3600,
	"daily_bonus": 86400,
	"shop_free_coins": 300,
	"shop_free_diamonds": 600,
	"wheel_extra_spin": 0,
	"reroll_upgrades": 0,
	"revive": 0,
	"double_rewards": 0,
	"boss_retry": 0,
	"league_double_rewards": 0,
}

const SESSION_LIMITS := {}

var _session_counts: Dictionary = {}
var _active_overlay: Control
var _force_success := false
var _force_failure := false


func _ready() -> void:
	_ensure_state()


func show_rewarded_ad(reason: String, callback: Callable) -> void:
	_ensure_state()
	if not can_show_ad(reason):
		register_ad_failed(reason)
		_call_callback(callback, false)
		return
	if _force_failure:
		register_ad_failed(reason)
		_call_callback(callback, false)
		return
	if _force_success:
		register_ad_completed(reason)
		_call_callback(callback, true)
		return
	if is_mock_enabled():
		_show_mock_ad(reason, callback)
		return
	# Future SDK path: call the platform-specific rewarded implementation here.
	register_ad_failed(reason)
	_call_callback(callback, false)


func can_show_ad(reason: String) -> bool:
	_ensure_state()
	if not REASONS.has(reason):
		return false
	var limit := int(SESSION_LIMITS.get(reason, -1))
	if limit >= 0 and int(_session_counts.get(reason, 0)) >= limit:
		return false
	var remaining := get_ad_cooldown(reason)
	return remaining <= 0


func register_ad_completed(reason: String) -> void:
	_ensure_state()
	_session_counts[reason] = int(_session_counts.get(reason, 0)) + 1
	var ads: Dictionary = GameState.data.get("ads", {})
	var completed: Dictionary = ads.get("completed", {})
	completed[reason] = int(completed.get(reason, 0)) + 1
	ads["completed"] = completed
	ads["last_completed"] = reason
	ads["last_completed_at"] = TimeManager.get_now_timestamp()
	var cooldowns: Dictionary = ads.get("cooldowns", {})
	var cooldown := int(COOLDOWNS.get(reason, 0))
	if cooldown > 0:
		cooldowns[reason] = TimeManager.get_now_timestamp() + cooldown
	ads["cooldowns"] = cooldowns
	GameState.data["ads"] = ads
	GameState.save_game(false)


func register_ad_failed(reason: String) -> void:
	_ensure_state()
	var ads: Dictionary = GameState.data.get("ads", {})
	var failed: Dictionary = ads.get("failed", {})
	failed[reason] = int(failed.get(reason, 0)) + 1
	ads["failed"] = failed
	ads["last_failed"] = reason
	ads["last_failed_at"] = TimeManager.get_now_timestamp()
	GameState.data["ads"] = ads
	GameState.save_game(false)


func get_ad_cooldown(reason: String) -> int:
	_ensure_state()
	var ads: Dictionary = GameState.data.get("ads", {})
	var cooldowns: Dictionary = ads.get("cooldowns", {})
	var until := int(cooldowns.get(reason, 0))
	return max(0, until - TimeManager.get_now_timestamp())


func is_mock_enabled() -> bool:
	var ads: Dictionary = GameState.data.get("ads", {})
	return bool(ads.get("mock_enabled", MOCK_ENABLED))


func reset_cooldowns() -> void:
	_ensure_state()
	var ads: Dictionary = GameState.data.get("ads", {})
	ads["cooldowns"] = {}
	GameState.data["ads"] = ads
	GameState.save_game(false)


func reset_session_limits() -> void:
	_session_counts.clear()


func set_force_success(enabled: bool) -> void:
	_force_success = enabled
	if enabled:
		_force_failure = false


func set_force_failure(enabled: bool) -> void:
	_force_failure = enabled
	if enabled:
		_force_success = false


func is_force_success() -> bool:
	return _force_success


func is_force_failure() -> bool:
	return _force_failure


func ad_debug_summary() -> Dictionary:
	_ensure_state()
	var ads: Dictionary = GameState.data.get("ads", {})
	return {
		"session": _session_counts.duplicate(true),
		"completed": Dictionary(ads.get("completed", {})).duplicate(true),
		"failed": Dictionary(ads.get("failed", {})).duplicate(true),
		"cooldowns": Dictionary(ads.get("cooldowns", {})).duplicate(true),
		"force_success": _force_success,
		"force_failure": _force_failure,
	}


func _ensure_state() -> void:
	if not has_node("/root/GameState"):
		return
	var ads: Dictionary = GameState.data.get("ads", {})
	if ads.is_empty():
		ads = {
			"mock_enabled": MOCK_ENABLED,
			"completed": {},
			"failed": {},
			"cooldowns": {},
			"last_completed": "",
			"last_completed_at": 0,
			"last_failed": "",
			"last_failed_at": 0,
		}
	else:
		if not ads.has("mock_enabled"):
			ads["mock_enabled"] = MOCK_ENABLED
		if not ads.has("completed"):
			ads["completed"] = {}
		if not ads.has("failed"):
			ads["failed"] = {}
		if not ads.has("cooldowns"):
			ads["cooldowns"] = {}
	GameState.data["ads"] = ads


func _show_mock_ad(reason: String, callback: Callable) -> void:
	_close_overlay()
	var root := get_tree().root
	var overlay := Control.new()
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(overlay)
	_active_overlay = overlay
	var shade := ColorRect.new()
	shade.anchor_right = 1.0
	shade.anchor_bottom = 1.0
	shade.color = Color("#000000cc")
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(shade)
	var center := CenterContainer.new()
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	center.offset_left = 18
	center.offset_right = -18
	overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(310, 230)
	panel.add_theme_stylebox_override("panel", _style("#11102aee", 18, "#00f0ff99", 2, "#00f0ff66", 14))
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	column.add_child(_label(_title_text(), 24, "#00f0ff", true))
	column.add_child(_label(_reason_text(reason), 13, "#ffffffaa", false))
	var finish := _button(_finish_text(), "#00ff88")
	finish.pressed.connect(func() -> void:
		_close_overlay()
		register_ad_completed(reason)
		_call_callback(callback, true)
	)
	column.add_child(finish)
	var cancel := _button(_cancel_text(), "#ff6b9a")
	cancel.pressed.connect(func() -> void:
		_close_overlay()
		register_ad_failed(reason)
		_call_callback(callback, false)
	)
	column.add_child(cancel)


func _close_overlay() -> void:
	if _active_overlay != null and is_instance_valid(_active_overlay):
		_active_overlay.queue_free()
	_active_overlay = null


func _call_callback(callback: Callable, ok: bool) -> void:
	if callback.is_valid():
		callback.call(ok)


func _is_pt() -> bool:
	return String(GameState.get_setting("language", "en")).begins_with("pt")


func _title_text() -> String:
	return "Anúncio de teste" if _is_pt() else "Mock Ad"


func _finish_text() -> String:
	return "Finalizar anúncio" if _is_pt() else "Finish Ad"


func _cancel_text() -> String:
	return "Cancelar" if _is_pt() else "Cancel"


func _reason_text(reason: String) -> String:
	return ("Motivo: %s" if _is_pt() else "Reason: %s") % reason


func _label(text: String, size: int, color: String, bold := false) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color(color))
	if bold:
		var font := SystemFont.new()
		font.font_weight = 700
		label.add_theme_font_override("font", font)
	return label


func _button(text: String, color: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(220, 48)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color(color))
	button.add_theme_stylebox_override("normal", _style("#ffffff12", 12, color + "88", 1, color + "33", 8))
	button.add_theme_stylebox_override("hover", _style("#ffffff18", 12, color, 1, color + "44", 9))
	button.add_theme_stylebox_override("pressed", _style("#ffffff22", 12, color, 1, color + "55", 10))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return button


func _style(bg_color: String, radius: int, border_color := "#00000000", border_width := 0, shadow_color := "#00000000", shadow_size := 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(bg_color)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_color = Color(border_color)
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.shadow_color = Color(shadow_color)
	style.shadow_size = shadow_size
	return style

extends Control

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const NeonBackButtonScript := preload("res://scripts/NeonBackButton.gd")

const ICON_PATHS := {
	"coin": "res://assets/ui/ui_coin.png",
	"gem": "res://assets/ui/ui_gem.png",
	"key": "res://assets/ui/ui_key.png",
	"locked": "res://assets/ui/ui_locked.png",
	"damage": "res://assets/ui/ui_damage.png",
	"speed": "res://assets/ui/ui_speed.png",
	"crit": "res://assets/ui/ui_crit.png",
	"xp": "res://assets/ui/ui_xp.png",
	"freeze": "res://assets/ui/ui_freeze.png",
	"burn": "res://assets/ui/ui_burn.png",
	"shock": "res://assets/ui/ui_shock.png",
	"pierce": "res://assets/ui/ui_pierce.png",
	"repulse": "res://assets/ui/ui_repulse.png",
}

const UPGRADE_METADATA := {
	"baseDamage": { "name": "Damage", "desc": "+10% dano por nível", "icon": "damage", "unlock": "Disponível desde o início" },
	"baseSpeed": { "name": "Speed", "desc": "+8% velocidade por nível", "icon": "speed", "unlock": "Disponível desde o início" },
	"coinMultiplier": { "name": "Cash Gain", "desc": "+15% moedas por nível", "icon": "coin", "unlock": "Disponível desde o início" },
	"critChance": { "name": "Crit Chance", "desc": "+2% crítico por nível", "icon": "crit", "unlock": "Disponível desde o início" },
	"xpBoost": { "name": "XP Boost", "desc": "+20% XP por nível", "icon": "xp", "unlock": "Desbloqueia ao alcançar a fase 3 ou perfil nível 3" },
	"perfectChance": { "name": "Perfect Chance", "desc": "+1% chance de diamante no perfect", "icon": "gem", "unlock": "Desbloqueia por fase 5 ou perfil nível 5" },
	"slowRings": { "name": "Slow Rings", "desc": "Anéis fecham mais devagar", "icon": "freeze", "unlock": "Desbloqueia por fase 8 ou perfil nível 9" },
}

const LEGACY_PERMANENT_UPGRADES := [
	{ "id": "baseDamage", "name": "Damage", "desc": "+10% dano por nível", "icon": "damage", "unlock": "Disponível desde o início" },
	{ "id": "baseSpeed", "name": "Speed", "desc": "+8% velocidade por nível", "icon": "speed", "unlock": "Disponível desde o início" },
	{ "id": "coinMultiplier", "name": "Cash Gain", "desc": "+15% moedas por nível", "icon": "coin", "unlock": "Disponível desde o início" },
	{ "id": "critChance", "name": "Crit Chance", "desc": "+2% crítico por nível", "icon": "crit", "unlock": "Disponível desde o início" },
	{ "id": "xpBoost", "name": "XP Boost", "desc": "+20% XP por nível", "icon": "xp", "unlock": "Desbloqueia ao alcançar a fase 3 ou perfil nível 3" },
	{ "id": "perfectChance", "name": "Perfect Chance", "desc": "+1% chance de diamante no perfect", "icon": "gem", "unlock": "Desbloqueia por fase 5 ou perfil nível 5" },
	{ "id": "slowRings", "name": "Slow Rings", "desc": "Anéis fecham mais devagar", "icon": "freeze", "unlock": "Desbloqueia por fase 8 ou perfil nível 9" },
]

var _regular_font: Font
var _bold_font: Font
var _feedback_label: Label


func _ready() -> void:
	_regular_font = _make_system_font(400)
	_bold_font = _make_system_font(700)
	if has_node("/root/AudioManager"):
		AudioManager.play_context("menu")
	GameState.refresh_unlocks(false)
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
	GameState.refresh_unlocks(false)
	var root := VBoxContainer.new()
	root.anchor_left = 0.0
	root.anchor_top = 0.0
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	var margin_x := 12.0 if _is_narrow_screen() else 20.0
	root.offset_left = margin_x
	root.offset_top = 36.0 if _is_narrow_screen() else 50.0
	root.offset_right = -margin_x
	NeonBackButtonScript.reserve_footer_space(root)
	root.add_theme_constant_override("separation", 10)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(root)

	root.add_child(_make_label(_loc("UPGRADES PERMANENTES"), 24 if _is_narrow_screen() else 28, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	NeonBackButtonScript.add_to(self, _go_back)
	root.add_child(_make_resource_display())
	_feedback_label = _make_label("", 13, "#00ff88", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	_feedback_label.custom_minimum_size.y = 24
	root.add_child(_feedback_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_configure_scroll(scroll)
	root.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.mouse_filter = Control.MOUSE_FILTER_PASS
	list.add_theme_constant_override("separation", 16)
	scroll.add_child(list)
	list.add_child(_make_upgrade_summary())
	list.add_child(_make_label(_loc("MELHORIAS DISPONIVEIS"), 18, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	var visible_upgrades := _visible_permanent_upgrade_list()
	if visible_upgrades.is_empty():
		list.add_child(_make_empty_upgrade_message())
	for upgrade in visible_upgrades:
		list.add_child(_make_upgrade_card(upgrade))


func _ensure_available_permanent_unlocks() -> void:
	var changed := false
	var max_phase := int(GameState.data.get("max_unlocked_phase", GameState.data.get("current_phase", 1)))
	var profile_level := int(GameState.data.get("level", 1))
	for id in GameState.PERMANENT_UPGRADE_DEFS.keys():
		var definition: Dictionary = GameState.PERMANENT_UPGRADE_DEFS[id]
		var available := max_phase >= int(definition.get("phase", 999)) or profile_level >= int(definition.get("level", 999))
		if available and not GameState.is_upgrade_unlocked(String(id)):
			GameState.unlock_upgrade(String(id))
			changed = true
	if changed:
		GameState.refresh_unlocks(false)


func _visible_permanent_upgrade_list() -> Array[Dictionary]:
	return GameState.get_unlocked_upgrades()


func _is_permanent_upgrade_available(id: String) -> bool:
	if not GameState.PERMANENT_UPGRADE_DEFS.has(id):
		return GameState.is_upgrade_unlocked(id)
	var definition: Dictionary = GameState.PERMANENT_UPGRADE_DEFS[id]
	var max_phase := int(GameState.data.get("max_unlocked_phase", GameState.data.get("current_phase", 1)))
	var profile_level := int(GameState.data.get("level", 1))
	return max_phase >= int(definition.get("phase", 999)) or profile_level >= int(definition.get("level", 999))


func _visible_run_upgrade_list() -> Array[Dictionary]:
	return GameState.get_gameplay_upgrade_pool()


func _is_run_upgrade_available_for_player(id: String) -> bool:
	return GameState.available_run_upgrade_ids().has(id)


func _locked_upgrade_list() -> Array[Dictionary]:
	return GameState.get_locked_upgrades()


func _make_empty_upgrade_message() -> PanelContainer:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _make_style("#ffffff10", 14, "#ffffff22", 1))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 18)
	card.add_child(margin)
	margin.add_child(_make_label(_txt("No permanent upgrades available yet.", "Nenhuma melhoria permanente disponivel ainda.", "Aún no hay mejoras permanentes disponibles.", "利用可能な永続強化はまだありません。", "暂无可用永久升级。"), 14, "#ffffffaa", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	return card


func _make_empty_temp_upgrade_message() -> PanelContainer:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _make_style("#ffffff10", 14, "#ffffff22", 1))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 18)
	card.add_child(margin)
	margin.add_child(_make_label(_txt("No temporary upgrades unlocked yet.", "Nenhuma melhoria temporaria liberada ainda.", "Aún no hay mejoras temporales desbloqueadas.", "一時強化はまだ解除されていません。", "暂无已解锁临时升级。"), 14, "#ffffffaa", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	return card


func _make_upgrade_summary() -> PanelContainer:
	var total_count := GameState.get_all_upgrades().size()
	var available_permanent_count := GameState.get_unlocked_upgrades().size()
	var locked_count := _locked_upgrade_list().size()
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _make_style("#ffffff12", 12, "#00f0ff55", 1))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	card.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	margin.add_child(column)
	column.add_child(_make_label(_txt("Available upgrades: %s/%s", "Melhorias disponíveis: %s/%s", "Mejoras disponibles: %s/%s", "利用可能な強化: %s/%s", "可用升级：%s/%s") % [available_permanent_count, total_count], 14, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	column.add_child(_make_label(_txt("Locked upgrades: %s", "Melhorias bloqueadas: %s", "Mejoras bloqueadas: %s", "ロック中の強化: %s", "未解锁升级：%s") % locked_count, 13, "#ffffffaa", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	column.add_child(_make_label(_txt("Gameplay rolls exactly this same unlocked list.", "A gameplay sorteia exatamente essa mesma lista liberada.", "La partida sortea exactamente esta misma lista desbloqueada.", "ゲーム内抽選はこの解除済みリストだけを使います。", "游戏内只会从这份已解锁列表中抽取。"), 12, "#ffffff88", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))
	return card


func _permanent_upgrade_list() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var source: Dictionary = GameState.PERMANENT_UPGRADE_DEFS
	for id in source.keys():
		var metadata: Dictionary = UPGRADE_METADATA.get(id, {})
		var definition: Dictionary = source[id]
		result.append({
			"id": String(id),
			"name": _upgrade_name(String(id), String(metadata.get("name", _title_from_id(String(id))))),
			"desc": _upgrade_desc(String(id), String(metadata.get("desc", "Melhoria permanente"))),
			"icon": String(metadata.get("icon", "key")),
			"unlock": _upgrade_unlock(String(metadata.get("unlock", "Desbloqueia na fase %s ou perfil nível %s" % [int(definition.get("phase", 1)), int(definition.get("level", 1))]))),
		})
	if result.is_empty():
		for upgrade in LEGACY_PERMANENT_UPGRADES:
			result.append(Dictionary(upgrade).duplicate(true))
	return result


func _title_from_id(id: String) -> String:
	var title := ""
	for i in range(id.length()):
		var character := id.substr(i, 1)
		if i > 0 and character == character.to_upper() and character != character.to_lower():
			title += " "
		title += character
	return title.capitalize()


func _make_resource_display() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_theme_constant_override("separation", 10)
	row.add_child(_make_resource_pill("coin", str(GameState.data.get("coins", 0)), "#ffd70044"))
	row.add_child(_make_resource_pill("gem", str(GameState.data.get("diamonds", 0)), "#00ff8844"))
	row.add_child(_make_resource_pill("key", str(GameState.data.get("keys", 0)), "#00f0ff44"))
	return row


func _make_resource_pill(icon_key: String, value: String, border: String) -> PanelContainer:
	var box := PanelContainer.new()
	box.custom_minimum_size = Vector2(106, 48)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_stylebox_override("panel", _make_style("#ffffff22", 12, border, 2))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	box.add_child(margin)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)
	row.add_child(_make_icon(icon_key, 22))
	var value_label := _make_label(value, 20, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	value_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	value_label.clip_text = false
	value_label.custom_minimum_size.x = 34
	row.add_child(value_label)
	return box


func _make_upgrade_card(upgrade: Dictionary, locked_preview := false) -> PanelContainer:
	var id := String(upgrade["id"])
	var unlocked := GameState.is_upgrade_unlocked(id)
	var preview := GameState.get_upgrade_preview(id)
	var level := int(preview.get("level", 0))
	var max_level := int(preview.get("max_level", GameState.get_upgrade_max_level(id)))
	var coin_cost := int(preview.get("coins", 0))
	var diamond_cost := int(preview.get("diamonds", 0))
	var is_maxed := level >= max_level
	var card := PanelContainer.new()
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_theme_stylebox_override("panel", _make_style("#ffffff12" if unlocked else "#ffffff0c", 16, "#ffffff22" if unlocked else "#55557755", 2))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_child(row)

	var icon_box := PanelContainer.new()
	icon_box.custom_minimum_size = Vector2(60, 60)
	icon_box.add_theme_stylebox_override("panel", _make_style("#ffffff22", 30))
	var center := CenterContainer.new()
	icon_box.add_child(center)
	center.add_child(_make_icon(_upgrade_icon_key(id) if unlocked else "locked", 34))
	row.add_child(icon_box)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.mouse_filter = Control.MOUSE_FILTER_PASS
	info.add_theme_constant_override("separation", 4)
	row.add_child(info)
	info.add_child(_make_label(_upgrade_name(id, String(upgrade["name"])), 18, "#ffffff" if unlocked else "#ffffffcc", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	if unlocked:
		info.add_child(_make_label(_upgrade_desc(id, String(upgrade.get("description", upgrade.get("desc", "")))), 14, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))
	else:
		if locked_preview:
			info.add_child(_make_label(_upgrade_desc(id, String(upgrade.get("description", upgrade.get("desc", "")))), 13, "#ffffff88", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))
		var locked := HBoxContainer.new()
		locked.add_theme_constant_override("separation", 5)
		locked.add_child(_make_icon("locked", 14))
		locked.add_child(_make_label(_upgrade_unlock(String(upgrade.get("unlockRequirement", upgrade.get("unlock", "Upgrade bloqueado")))), 14, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))
		info.add_child(locked)
	info.add_child(_make_label("%s: %s/%s" % [_t("upgrade_level"), level, max_level], 12, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	if unlocked:
		info.add_child(_make_label("%s: %s" % [_t("current_effect"), _effect_label(Dictionary(preview.get("current", {})))], 11, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))
		if not is_maxed:
			info.add_child(_make_label("%s: %s" % [_t("next_level"), _effect_label(Dictionary(preview.get("next", {})))], 11, "#00ff88", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))
			info.add_child(_make_label("%s: %s %s / %s %s" % [_t("cost"), coin_cost, _t("coins"), diamond_cost, _t("diamonds")], 11, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
		else:
			info.add_child(_make_label(_t("max"), 13, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))

	if unlocked:
		var actions := VBoxContainer.new()
		actions.custom_minimum_size.x = 112 if _is_narrow_screen() else 132
		actions.add_theme_constant_override("separation", 7)
		actions.mouse_filter = Control.MOUSE_FILTER_PASS
		row.add_child(actions)
		if is_maxed:
			actions.add_child(_make_upgrade_button(_t("max"), "#00aa77", true, Callable()))
		else:
			actions.add_child(_make_upgrade_button("%s\n%s" % [_t("upgrade_with_coins"), coin_cost], "#0088ff", false, _buy_upgrade.bind(id, "coins")))
			actions.add_child(_make_upgrade_button("%s\n%s" % [_t("upgrade_with_diamonds"), diamond_cost], "#00aa77", false, _buy_upgrade.bind(id, "diamonds")))
	return card


func _make_temp_upgrade_card(upgrade: Dictionary) -> PanelContainer:
	var id := String(upgrade.get("id", ""))
	var unlocked := _is_run_upgrade_available_for_player(id)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _make_style("#ffffff10", 14, "#ffffff1f" if unlocked else "#55555544", 2))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	card.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	margin.add_child(row)
	row.add_child(_make_icon(_upgrade_icon_key(id), 32))
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 3)
	row.add_child(info)
	info.add_child(_make_label(String(upgrade.get("name", id)), 16, "#ffffff" if unlocked else "#ffffffcc", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	info.add_child(_make_label(String(upgrade.get("description", "")), 12, "#ffffffaa" if unlocked else "#ffffff88", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))
	if not unlocked:
		info.add_child(_make_label(String(upgrade.get("unlockRequirement", "Bloqueado")), 11, "#ffcc66", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	else:
		info.add_child(_make_label("Aparece nas escolhas de level-up durante fases, infinito, Liga e Boss.", 11, "#00f0ffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))
	info.add_child(_make_label("%s • max Lv.%s" % [String(upgrade.get("rarity", "common")).to_upper(), int(upgrade.get("maxLevel", 1))], 11, _rarity_color(String(upgrade.get("rarity", "common"))), _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	var status := _make_label("LIBERADO" if unlocked else "BLOQUEADO", 12, "#00ff88" if unlocked else "#ff6b9a", _bold_font, HORIZONTAL_ALIGNMENT_RIGHT)
	status.custom_minimum_size.x = 84
	row.add_child(status)
	return card


func _upgrade_icon_key(id: String) -> String:
	match id:
		"damage", "burn", "penetration", "laser", "laserCut", "bomb", "multihit", "chainBreak", "criticalOverload":
			return "damage"
		"speed", "ricochet":
			return "speed"
		"coinBoost", "magnetCoins", "secretMagnet":
			return "coin"
		"critical":
			return "crit"
		"xpBoost":
			return "xp"
		"frost", "timeFreeze", "chronoBreak", "slowField", "perfectChance", "diamondInstinct":
			return "freeze"
		"chainLightning", "shockwave":
			return "shock"
		"ringRepulse":
			return "repulse"
	return "locked" if not GameState.is_upgrade_unlocked(id) else "key"


func _rarity_color(rarity: String) -> String:
	match rarity:
		"rare":
			return "#00aaff"
		"epic":
			return "#b000ff"
		"legendary":
			return "#ffd700"
	return "#00f0ff"


func _upgrade_value_text(id: String, level: int, max_level: int) -> String:
	var current := _upgrade_value(id, level)
	var next := "MAX" if level >= max_level else _upgrade_value(id, level + 1)
	return "Atual: %s • Próx: %s" % [current, next]


func _upgrade_value(id: String, level: int) -> String:
	match id:
		"baseDamage":
			return "%.1f dano" % (10.0 * pow(1.1, level))
		"baseSpeed":
			return "%.0f vel." % (100.0 * pow(1.08, level))
		"coinMultiplier":
			return "%.2fx moedas" % (1.0 + level * 0.15)
		"critChance":
			return "%s%% crit." % (5 + level * 2)
		"xpBoost":
			return "%.2fx XP" % (1.0 + level * 0.2)
		"perfectChance":
			return "%s%% perfect" % level
		"slowRings":
			return "%.1f%% lento" % min(24.0, level * 1.8)
	return "Lv.%s" % level


func _make_upgrade_button(text: String, color: String, disabled: bool, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 46)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	button.disabled = disabled
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 10 if _is_narrow_screen() else 11)
	button.add_theme_color_override("font_color", Color("#001018") if not disabled else Color("#ffffffaa"))
	button.add_theme_color_override("font_hover_color", Color("#001018") if not disabled else Color("#ffffffaa"))
	button.add_theme_color_override("font_pressed_color", Color("#001018") if not disabled else Color("#ffffffaa"))
	button.add_theme_color_override("font_focus_color", Color("#001018") if not disabled else Color("#ffffffaa"))
	button.add_theme_color_override("font_disabled_color", Color("#ffffff88"))
	button.modulate.a = 0.55 if disabled else 1.0
	_apply_button_style(button, _make_style(color if not disabled else "#555555", 12, "#00000000", 0, color + "88" if not disabled else "#00000000", 8))
	if action.is_valid() and not disabled:
		button.pressed.connect(action)
	return button


func _effect_label(effect: Dictionary) -> String:
	return _localize_effect_label(String(effect.get("label", "Lv.%s" % int(effect.get("level", 0)))))


func _buy_upgrade(id: String, currency := "coins") -> void:
	var result := GameState.upgrade_with_diamonds(id) if currency == "diamonds" else GameState.upgrade_with_coins(id)
	if bool(result.get("ok", false)):
		_play_sfx("res://assets/sounds/button_confirm.mp3")
		_rebuild_upgrade_list()
		_play_feedback("%s! Lv.%s" % [_t("upgrade_improved"), int(result.get("level", 0))], "#00ff88")
		return
	var reason := String(result.get("reason", ""))
	var text := "Upgrade bloqueado"
	if reason == "coins":
		text = "%s: %s" % [_t("not_enough_coins"), int(result.get("cost", GameState.get_upgrade_cost(id, GameState.get_upgrade_level(id), "coins")))]
	elif reason == "diamonds":
		text = "%s: %s" % [_t("not_enough_diamonds"), int(result.get("cost", GameState.get_upgrade_cost(id, GameState.get_upgrade_level(id), "diamonds")))]
	elif reason == "max":
		text = _t("max")
	_play_feedback(text, "#ff6b9a")
	_play_sfx("res://assets/sounds/button_error.mp3")


func _t(key: String) -> String:
	var lang := LocalizationManager.current_language() if has_node("/root/LocalizationManager") else String(GameState.get_setting("language", "en"))
	match key:
		"upgrade_level": return _txt("Upgrade Level", "Nível da Melhoria", "Nivel de Mejora", "強化レベル", "升级等级")
		"level": return _txt("Level", "Nível", "Nivel", "レベル", "等级")
		"max_level": return _txt("Max Level", "Nível Máximo", "Nivel Máximo", "最大レベル", "最高等级")
		"upgrade_improved": return _txt("Upgrade Improved", "Melhoria aprimorada", "Mejora aumentada", "強化しました", "升级成功")
		"upgrade_with_coins": return _txt("Upgrade with Coins", "Melhorar com Moedas", "Mejorar con Monedas", "コインで強化", "用金币升级")
		"upgrade_with_diamonds": return _txt("Upgrade with Diamonds", "Melhorar com Diamantes", "Mejorar con Diamantes", "ダイヤで強化", "用钻石升级")
		"current_effect": return _txt("Current Effect", "Efeito Atual", "Efecto Actual", "現在の効果", "当前效果")
		"next_level": return _txt("Next Level", "Próximo Nível", "Siguiente Nivel", "次のレベル", "下一级")
		"max": return _txt("Max", "Máximo", "Máximo", "最大", "满级")
		"not_enough_coins": return _txt("Not enough coins", "Moedas insuficientes", "Monedas insuficientes", "コイン不足", "金币不足")
		"not_enough_diamonds": return _txt("Not enough diamonds", "Diamantes insuficientes", "Diamantes insuficientes", "ダイヤ不足", "钻石不足")
		"cost": return _txt("Cost", "Custo", "Costo", "コスト", "花费")
		"coins": return _txt("coins", "moedas", "monedas", "コイン", "金币")
		"diamonds": return _txt("diamonds", "diamantes", "diamantes", "ダイヤ", "钻石")
	return key


func _txt(en: String, pt := "", es := "", ja := "", zh := "") -> String:
	return LocalizationManager.text(en, pt, es, ja, zh) if has_node("/root/LocalizationManager") else en


func _loc(value: String) -> String:
	return LocalizationManager.phrase(value) if has_node("/root/LocalizationManager") else value


func _upgrade_name(id: String, fallback: String) -> String:
	return LocalizationManager.upgrade_name(id, fallback) if has_node("/root/LocalizationManager") else fallback


func _upgrade_desc(id: String, fallback: String) -> String:
	return LocalizationManager.upgrade_description(id, fallback) if has_node("/root/LocalizationManager") else fallback


func _upgrade_unlock(value: String) -> String:
	return LocalizationManager.upgrade_unlock_requirement(value) if has_node("/root/LocalizationManager") else value


func _localize_effect_label(label: String) -> String:
	var output := label
	var replacements := {
		"dano": _txt("damage", "dano", "daño", "ダメージ", "伤害"),
		"velocidade": _txt("speed", "velocidade", "velocidad", "速度", "速度"),
		"moedas": _txt("coins", "moedas", "monedas", "コイン", "金币"),
		"critico": _txt("critical", "crítico", "crítico", "クリティカル", "暴击"),
		"diamante/perfect": _txt("diamond/perfect", "diamante/perfect", "diamante/perfect", "ダイヤ/Perfect", "钻石/Perfect"),
		"chance gelo": _txt("ice chance", "chance gelo", "prob. hielo", "氷確率", "冰冻概率"),
		"chance lentidao": _txt("slow chance", "chance lentidão", "prob. lentitud", "減速確率", "减速概率"),
		"chance repulsao": _txt("repulse chance", "chance repulsão", "prob. repulsión", "反発確率", "排斥概率"),
		"corrente": _txt("chain", "corrente", "cadena", "連鎖", "连锁"),
		"area": _txt("area", "área", "área", "範囲", "范围"),
		"bonus": _txt("bonus", "bônus", "bono", "ボーナス", "加成"),
	}
	for source in replacements.keys():
		output = output.replace(String(source), String(replacements[source]))
	return output


func _rebuild_upgrade_list() -> void:
	for child in get_children():
		child.queue_free()
	_build_background()
	_build_screen()


func _play_feedback(text: String, color: String) -> void:
	if _feedback_label:
		_feedback_label.text = text
		_feedback_label.add_theme_color_override("font_color", Color(color))


func _play_sfx(path: String) -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx(path, -6.0)


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
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _configure_scroll(scroll: ScrollContainer) -> void:
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.follow_focus = true
	scroll.scroll_deadzone = 2
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP


func _is_narrow_screen() -> bool:
	return get_viewport_rect().size.x <= 430.0


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


func _go_back() -> void:
	if has_node("/root/NavigationManager"):
		NavigationManager.go_back(MENU_SCENE)
	else:
		get_tree().change_scene_to_file(MENU_SCENE)

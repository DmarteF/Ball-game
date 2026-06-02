extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

var coins_row
var list

func _ready():
	SaveSystem.save_changed.connect(func(_save): _refresh())
	_build_ui()
	_refresh()

func _build_ui():
	NeonUI.add_main_background(self)
	var header_data = NeonUI.header(self, "UPGRADES PERMANENTES", 60, 20, 20, 28)
	header_data.back.pressed.connect(func(): get_tree().current_scene.go_to("menu"))
	coins_row = HBoxContainer.new()
	coins_row.add_theme_constant_override("separation", 8)
	header_data.box.add_child(coins_row)

	list = NeonUI.make_scroll(self, 174, 20, 20, 20, 16)

func _refresh():
	if not is_node_ready():
		return
	var save = SaveSystem.get_save()
	NeonUI.clear_children(coins_row)
	var coins_badge = PanelContainer.new()
	coins_badge.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	coins_badge.add_theme_stylebox_override("panel", NeonUI.neon_box(Color("#ffffff22"), Color("#ffd70044"), 2, 12, 0.22))
	var coin_box = HBoxContainer.new()
	coin_box.add_theme_constant_override("separation", 8)
	coins_badge.add_child(coin_box)
	coin_box.add_child(NeonUI.icon("res://assets/ui/ui_coin.png", 24))
	coin_box.add_child(NeonUI.label(str(save.coins), 24, Color("#ffd700")))
	coins_row.add_child(coins_badge)

	NeonUI.clear_children(list)
	for upgrade in GameData.get_permanent_upgrades():
		_add_upgrade_card(upgrade, save)
	for upgrade in GameData.RUN_UPGRADES:
		if bool(upgrade.get("secret", false)):
			_add_secret_upgrade_card(upgrade, save)

func _add_upgrade_card(upgrade, save):
	var unlocked = GameData.is_permanent_upgrade_unlocked(upgrade.id, save)
	var level = int(save.permanent_upgrades.get(upgrade.id, 0))
	var max_level = int(upgrade.max_level)
	var is_maxed = level >= max_level
	var cost = GameData.get_permanent_upgrade_cost(upgrade.id, level)
	var can_afford = int(save.coins) >= cost and unlocked and not is_maxed
	var color = Color("#00f0ff") if unlocked else Color("#666666")
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#ffffff18"), Color("#ffffff22"), 2, 16))
	list.add_child(panel)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	panel.add_child(row)
	row.add_child(_round_icon(upgrade.icon_path, 60))

	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 3)
	row.add_child(info)
	info.add_child(NeonUI.label(upgrade.name if unlocked else "???", 18, Color.WHITE))
	if unlocked:
		info.add_child(NeonUI.label(upgrade.description, 14, Color("#ffffffaa")))
	else:
		var locked = HBoxContainer.new()
		locked.add_theme_constant_override("separation", 5)
		locked.add_child(NeonUI.icon("res://assets/ui/ui_locked.png", 14))
		locked.add_child(NeonUI.label(_unlock_text(upgrade), 14, Color("#ffffffaa")))
		info.add_child(locked)
	info.add_child(NeonUI.label("Nível: %d/%d" % [level, max_level], 12, Color("#00f0ff") if unlocked else Color("#ffffff66")))
	if unlocked:
		var value_text = "Atual: %s • MAX" % _value_text(upgrade.id, level) if is_maxed else "Atual: %s • Próx: %s" % [_value_text(upgrade.id, level), _value_text(upgrade.id, level + 1)]
		info.add_child(NeonUI.label(value_text, 11, Color("#ffffff88")))

	var buy = NeonUI.main_button("MAX" if is_maxed else str(cost), Color("#00ff88") if is_maxed else Color("#00f0ff"), Color("#0088ff"), 48)
	buy.custom_minimum_size.x = 96
	buy.disabled = not can_afford and not is_maxed
	buy.modulate = Color(1, 1, 1, 0.5) if not can_afford and not is_maxed else Color.WHITE
	buy.icon = load("res://assets/ui/ui_coin.png") if ResourceLoader.exists("res://assets/ui/ui_coin.png") and unlocked and not is_maxed else null
	buy.pressed.connect(_buy.bind(upgrade.id))
	row.add_child(buy)

func _add_secret_upgrade_card(upgrade, save):
	var unlocked = upgrade.id in save.unlocked_upgrades
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#ffffff18"), Color("#ffffff22"), 2, 16))
	list.add_child(panel)
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	panel.add_child(row)
	row.add_child(_round_icon(upgrade.icon_path, 60))
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	info.add_child(NeonUI.label(upgrade.name if unlocked else "???", 18, Color.WHITE))
	info.add_child(NeonUI.label(upgrade.description if unlocked else upgrade.get("secretCondition", "Conquista secreta"), 14, Color("#ffffffaa")))
	info.add_child(NeonUI.label("Secreto liberado" if unlocked else "Upgrade secreto", 12, Color("#00f0ff")))
	var ok = NeonUI.main_button("OK" if unlocked else "🔒", Color("#ffd700"), Color("#ff8800"), 48)
	ok.custom_minimum_size.x = 96
	ok.disabled = not unlocked
	row.add_child(ok)

func _round_icon(icon_path, size):
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(size, size)
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#ffffff22"), Color.TRANSPARENT, 0, int(size / 2.0)))
	var center = CenterContainer.new()
	panel.add_child(center)
	center.add_child(NeonUI.icon(icon_path, 34))
	return panel

func _buy(upgrade_id):
	var result = SaveSystem.purchase_permanent_upgrade(upgrade_id)
	AudioManager.play_sfx("button_confirm" if result.ok else "button_error")
	_refresh()

func _unlock_text(upgrade):
	if upgrade.has("unlock_text"):
		return String(upgrade.unlock_text)
	if upgrade.unlock == "phase_3":
		return "Desbloqueia ao alcançar a fase 3"
	if upgrade.unlock == "phase_5_or_chest":
		return "Desbloqueia por baús raros ou fase 5"
	if upgrade.unlock == "chest":
		return "Desbloqueia por rank ou recompensas especiais"
	return "Disponível desde o início"

func _value_text(upgrade_id, level):
	match upgrade_id:
		"baseDamage":
			return "%.1f dano" % (10.0 * pow(1.1, level))
		"baseSpeed":
			return "%.0f vel." % (100.0 * pow(1.08, level))
		"coinMultiplier":
			return "%.2fx moedas" % (1.0 + level * 0.15)
		"critChance":
			return "%d%% crit." % int(5 + level * 2)
		"xpBoost":
			return "%.2fx XP" % (1.0 + level * 0.2)
		"perfectChance":
			return "%d%% perfect" % level
		"slowRings":
			return "%.1f%% lento" % min(24.0, level * 1.8)
	return "Lv.%d" % level

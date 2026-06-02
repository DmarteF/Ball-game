extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

var wallet_label
var list

func _ready():
	SaveSystem.save_changed.connect(func(_save): _refresh())
	_build_ui()
	_refresh()

func _build_ui():
	var bg = ColorRect.new()
	bg.color = Color("#080818")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)
	var header = HBoxContainer.new()
	box.add_child(header)
	var back = NeonUI.ghost_button("VOLTAR", Color("#00f0ff"), 42)
	back.pressed.connect(func(): get_tree().current_scene.go_to("menu"))
	header.add_child(back)
	var title = NeonUI.label("UPGRADES", 28, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_RIGHT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	wallet_label = NeonUI.label("", 13, Color("#ffd700"))
	box.add_child(wallet_label)
	box.add_child(NeonUI.label("Upgrades comecam bloqueados e aparecem conforme fase, perfil ou baus.", 13, Color("#ffffffbb")))
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	list = VBoxContainer.new()
	list.add_theme_constant_override("separation", 10)
	scroll.add_child(list)

func _refresh():
	if not is_node_ready():
		return
	var save = SaveSystem.get_save()
	wallet_label.text = "Moedas %d  Diamantes %d" % [save.coins, save.gems]
	NeonUI.clear_children(list)
	for upgrade in GameData.get_permanent_upgrades():
		_add_upgrade_card(upgrade, save)

func _add_upgrade_card(upgrade, save):
	var panel = PanelContainer.new()
	var unlocked = GameData.is_permanent_upgrade_unlocked(upgrade.id, save)
	var level = int(save.permanent_upgrades.get(upgrade.id, 0))
	var max_level = int(upgrade.max_level)
	var is_maxed = level >= max_level
	var color = Color("#00f0ff") if unlocked else Color("#555566")
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color(color, 0.14), Color(color, 0.65), 1, 10))
	list.add_child(panel)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)
	row.add_child(NeonUI.icon(upgrade.icon_path, 44))
	var text_box = VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_box)
	text_box.add_child(NeonUI.label(upgrade.name if unlocked else "???", 17, Color.WHITE))
	text_box.add_child(NeonUI.label(upgrade.description if unlocked else _unlock_text(upgrade), 12, Color("#ffffffaa")))
	text_box.add_child(NeonUI.label("Nivel %d/%d  |  Atual: %s" % [level, max_level, _value_text(upgrade.id, level)], 12, Color("#00f0ff") if unlocked else Color("#ffffff66")))
	var buy = NeonUI.button("MAX" if is_maxed else _cost_text(upgrade, level), Color("#00ff88") if is_maxed else Color("#ffd700"), 48)
	buy.custom_minimum_size.x = 96
	buy.disabled = not unlocked or is_maxed
	buy.pressed.connect(_buy.bind(upgrade.id))
	row.add_child(buy)

func _buy(upgrade_id):
	var result = SaveSystem.purchase_permanent_upgrade(upgrade_id)
	AudioManager.play_sfx("button_confirm" if result.ok else "button_error")
	_refresh()

func _cost_text(upgrade, level):
	var currency = "D" if upgrade.currency == "gems" else "M"
	return "%d %s" % [GameData.get_permanent_upgrade_cost(upgrade.id, level), currency]

func _unlock_text(upgrade):
	if upgrade.unlock == "phase_3":
		return "Desbloqueia na fase 3 ou perfil 3."
	if upgrade.unlock == "phase_5_or_chest":
		return "Desbloqueia na fase 5 ou em baus."
	if upgrade.unlock == "chest":
		return "Desbloqueia por baus ou recompensas especiais."
	return "Disponivel desde o inicio."

func _value_text(upgrade_id, level):
	match upgrade_id:
		"baseDamage":
			return "+%d%% dano" % int(level * 10)
		"baseSpeed":
			return "+%d%% velocidade" % int(level * 8)
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

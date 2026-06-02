extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

var stats_row
var list
var reward_panel
var reward_label

func _ready():
	SaveSystem.save_changed.connect(func(_save): _refresh())
	_build_ui()
	_refresh()

func _build_ui():
	NeonUI.add_main_background(self)
	var header = NeonUI.header(self, "BAÚS & INVENTÁRIO", 56, 16, 16, 25)
	header.back.pressed.connect(func(): get_tree().current_scene.go_to("menu"))
	stats_row = HBoxContainer.new()
	stats_row.add_theme_constant_override("separation", 8)
	header.box.add_child(stats_row)

	list = NeonUI.make_scroll(self, 148, 16, 16, 16, 12)
	_build_reward_modal()

func _build_reward_modal():
	reward_panel = PanelContainer.new()
	reward_panel.visible = false
	reward_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	reward_panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#000000cc"), Color.TRANSPARENT, 0, 0))
	add_child(reward_panel)
	var center = CenterContainer.new()
	reward_panel.add_child(center)
	var box_panel = PanelContainer.new()
	box_panel.custom_minimum_size = Vector2(340, 0)
	box_panel.add_theme_stylebox_override("panel", NeonUI.neon_box(Color("#1a0a2e"), Color("#00f0ff55"), 1, 16, 0.35))
	center.add_child(box_panel)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	box_panel.add_child(box)
	box.add_child(NeonUI.label("REVELADO", 24, Color("#ffd700"), HORIZONTAL_ALIGNMENT_CENTER))
	reward_label = NeonUI.label("", 22, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(reward_label)
	var close = NeonUI.main_button("COLETAR", Color("#00f0ff"), Color("#0088ff"), 50)
	close.pressed.connect(func(): reward_panel.visible = false)
	box.add_child(close)

func _refresh():
	if not is_node_ready():
		return
	var save = SaveSystem.get_save()
	NeonUI.clear_children(stats_row)
	stats_row.add_child(NeonUI.resource_badge("res://assets/ui/ui_coin.png", str(save.coins)))
	stats_row.add_child(NeonUI.resource_badge("res://assets/ui/ui_gem.png", str(save.gems)))
	stats_row.add_child(NeonUI.resource_badge("res://assets/ui/ui_key.png", str(save.keys)))
	stats_row.add_child(NeonUI.resource_badge("res://assets/ui/ui_legendary_key.png", str(save.legendary_keys)))
	NeonUI.clear_children(list)
	_add_free_chest_card()
	list.add_child(NeonUI.label("BAÚS", 13, Color("#ffffff88")))
	for chest in GameData.get_chests():
		_add_chest_card(chest, false)
	list.add_child(NeonUI.label("ITENS", 13, Color("#ffffff88")))
	var had_inventory = false
	for chest in GameData.get_chests():
		var amount = int(save.inventory_chests.get(chest.id, 0))
		if amount > 0:
			had_inventory = true
			_add_chest_card(chest, true, amount)
	if not had_inventory:
		list.add_child(NeonUI.label("Trails, auras e efeitos aparecerão aqui.", 14, Color("#ffffff88")))

func _add_free_chest_card():
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 86)
	button.text = ""
	button.add_theme_stylebox_override("normal", NeonUI.neon_box(Color("#ffd700"), Color("#ff8800"), 1, 12, 0.42))
	button.add_theme_stylebox_override("hover", NeonUI.neon_box(Color("#ffdf3d"), Color("#ff8800"), 1, 12, 0.55))
	button.pressed.connect(_open_free_chest)
	list.add_child(button)
	var row = HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 14)
	button.add_child(row)
	row.add_child(NeonUI.icon("res://assets/ui/ui_daily_reward.png", 48))
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	info.add_child(NeonUI.label("BAÚ GRÁTIS", 18, Color.BLACK))
	info.add_child(NeonUI.label("Recompensa local", 12, Color("#000000aa")))
	row.add_child(NeonUI.icon("res://assets/ui/ui_ad.png", 30))

func _add_chest_card(chest, owned, amount = 0):
	var color = Color(chest.color)
	var disabled = not owned and not _can_afford(chest)
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 108)
	button.text = ""
	button.disabled = disabled
	button.modulate = Color(1, 1, 1, 0.5) if disabled else Color.WHITE
	button.add_theme_stylebox_override("normal", NeonUI.neon_box(Color(color, 0.36), Color("#ffffff24"), 1, 12, 0.18))
	button.add_theme_stylebox_override("hover", NeonUI.neon_box(Color(color, 0.46), color, 1, 12, 0.28))
	if owned:
		button.pressed.connect(_open_owned.bind(chest.id))
	else:
		button.pressed.connect(_buy_open.bind(chest.id))
	list.add_child(button)
	var row = HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 12)
	button.add_child(row)
	row.add_child(NeonUI.icon(chest.icon_path, 44))
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 3)
	row.add_child(info)
	info.add_child(NeonUI.label(chest.name, 18, Color.WHITE))
	info.add_child(NeonUI.label(chest.description, 12, Color("#ffffffaa")))
	info.add_child(NeonUI.label("Chances: %s" % _chance_text(chest), 12, Color("#ffffffaa")))
	var price = HBoxContainer.new()
	price.add_theme_constant_override("separation", 4)
	row.add_child(price)
	price.add_child(NeonUI.label("ABRIR x%d" % amount if owned else str(chest.cost), 12, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))
	if not owned:
		price.add_child(NeonUI.icon(_currency_icon(chest.currency), 15))

func _buy_open(chest_id):
	var result = SaveSystem.buy_and_open_chest(chest_id)
	if result.ok:
		AudioManager.play_sfx("chest_open")
		_show_reward(result.reward)
	else:
		AudioManager.play_sfx("button_error")

func _open_owned(chest_id):
	var reward = SaveSystem.open_inventory_chest(chest_id)
	if reward.is_empty():
		AudioManager.play_sfx("button_error")
		return
	AudioManager.play_sfx("chest_open")
	_show_reward(reward)

func _open_free_chest():
	AudioManager.play_sfx("button_click")
	await AdsService.show_rewarded("inventory_free_chest")
	var chest = GameData.get_chest("common")
	var reward = GameData.roll_chest_reward(chest.id, SaveSystem.get_save())
	SaveSystem.grant_chest_reward(reward)
	AudioManager.play_sfx("chest_open")
	_show_reward(reward)

func _show_reward(reward):
	var rarity = String(reward.get("rarity", "common")).capitalize()
	var label = reward.get("label", "Recompensa")
	var amount = int(reward.get("amount", 1))
	reward_label.text = "%s\n%s\nx%d" % [rarity, label, amount]
	if reward.get("type", "") == "skin" and reward.has("skin_id"):
		reward_label.text += "\nEQUIPAR SKIN em Skins"
	if reward.get("rarity", "") in ["legendary", "mythic", "ultimate"]:
		AudioManager.play_sfx("legendary_drop")
	elif reward.get("rarity", "") in ["rare", "epic"]:
		AudioManager.play_sfx("rare_drop")
	reward_panel.visible = true
	_refresh()

func _can_afford(chest):
	var save = SaveSystem.get_save()
	var wallet = int(save.coins)
	if chest.currency == "gems":
		wallet = int(save.gems)
	elif chest.currency == "keys":
		wallet = int(save.keys)
	elif chest.currency == "legendary_keys":
		wallet = int(save.legendary_keys)
	return wallet >= int(chest.cost)

func _chance_text(chest):
	var parts = []
	for rarity in GameData.RARITY_ORDER:
		if chest.chances.has(rarity):
			parts.append("%s %d%%" % [_rarity_label(rarity).to_lower(), int(round(float(chest.chances[rarity]) * 100.0))])
	return " • ".join(parts)

func _currency_icon(currency):
	if currency == "coins":
		return "res://assets/ui/ui_coin.png"
	if currency == "gems":
		return "res://assets/ui/ui_gem.png"
	if currency == "legendary_keys":
		return "res://assets/ui/ui_legendary_key.png"
	return "res://assets/ui/ui_key.png"

func _rarity_label(rarity):
	match rarity:
		"common":
			return "Comum"
		"rare":
			return "Rara"
		"epic":
			return "Épica"
		"legendary":
			return "Lendária"
		"mythic":
			return "Mítica"
		"ultimate":
			return "Ultimate"
	return String(rarity)

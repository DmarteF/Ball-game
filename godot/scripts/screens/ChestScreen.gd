extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

var wallet_label
var list
var reward_panel
var reward_label

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
	var title = NeonUI.label("BAUS", 28, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_RIGHT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	wallet_label = NeonUI.label("", 13, Color("#ffd700"))
	box.add_child(wallet_label)
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	list = VBoxContainer.new()
	list.add_theme_constant_override("separation", 10)
	scroll.add_child(list)

	reward_panel = PanelContainer.new()
	reward_panel.visible = false
	reward_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	reward_panel.add_theme_stylebox_override("panel", NeonUI.flat(Color(0, 0, 0, 0.82), Color("#ffd700"), 1, 0))
	add_child(reward_panel)
	var center = CenterContainer.new()
	reward_panel.add_child(center)
	var reward_box = VBoxContainer.new()
	reward_box.custom_minimum_size = Vector2(320, 0)
	reward_box.add_theme_constant_override("separation", 10)
	center.add_child(reward_box)
	reward_label = NeonUI.label("", 22, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	reward_box.add_child(reward_label)
	var close = NeonUI.button("FECHAR", Color("#00f0ff"), 48)
	close.pressed.connect(func(): reward_panel.visible = false)
	reward_box.add_child(close)

func _refresh():
	if not is_node_ready():
		return
	var save = SaveSystem.get_save()
	wallet_label.text = "Moedas %d  Diamantes %d  Chaves %d  Lendarias %d" % [save.coins, save.gems, save.keys, save.legendary_keys]
	NeonUI.clear_children(list)
	list.add_child(NeonUI.label("COMPRAR E ABRIR", 13, Color("#ffffff88")))
	for chest in GameData.get_chests():
		_add_chest_card(chest, false)
	list.add_child(NeonUI.label("BAUS NO INVENTARIO", 13, Color("#ffffff88")))
	var had_inventory = false
	for chest in GameData.get_chests():
		var amount = int(save.inventory_chests.get(chest.id, 0))
		if amount > 0:
			had_inventory = true
			_add_chest_card(chest, true, amount)
	if not had_inventory:
		list.add_child(NeonUI.label("Nenhum bau guardado. Ganhe em fases, loja ou anuncios mock.", 13, Color("#ffffff88")))

func _add_chest_card(chest, owned, amount = 0):
	var color = Color(chest.color)
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 82)
	var price = "x%d guardado" % amount if owned else "%d %s" % [int(chest.cost), _currency_label(chest.currency)]
	button.text = "%s  -  %s\n%s" % [chest.name, price, chest.description]
	button.icon = load(chest.icon_path) if ResourceLoader.exists(chest.icon_path) else null
	button.expand_icon = true
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", NeonUI.flat(Color(color, 0.20), Color(color, 0.74), 1, 10))
	button.add_theme_stylebox_override("hover", NeonUI.flat(Color(color, 0.35), Color(color), 1, 10))
	if owned:
		button.pressed.connect(_open_owned.bind(chest.id))
	else:
		button.pressed.connect(_buy_open.bind(chest.id))
	list.add_child(button)

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

func _show_reward(reward):
	var rarity = String(reward.get("rarity", "common")).capitalize()
	var label = reward.get("label", "Recompensa")
	var amount = int(reward.get("amount", 1))
	reward_label.text = "Voce recebeu\n%s\n%s x%d" % [rarity, label, amount]
	if reward.get("type", "") == "skin" and reward.has("skin_id"):
		reward_label.text += "\nSkin equipada automaticamente."
	if reward.get("rarity", "") in ["legendary", "mythic", "ultimate"]:
		AudioManager.play_sfx("legendary_drop")
	elif reward.get("rarity", "") in ["rare", "epic"]:
		AudioManager.play_sfx("rare_drop")
	reward_panel.visible = true
	_refresh()

func _currency_label(currency):
	if currency == "coins":
		return "moedas"
	if currency == "gems":
		return "diamantes"
	if currency == "legendary_keys":
		return "chave lend."
	return "chave"

extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

var wallet_row
var tab_row
var list
var active_tab = "chests"
var tabs = [
	["chests", "Baus"],
	["gems", "Diamantes"],
	["keys", "Chaves"],
	["specials", "Recompensas"],
	["free", "Bau gratis"]
]

func _ready():
	SaveSystem.save_changed.connect(func(_save): _refresh())
	_build_ui()
	_refresh()

func _build_ui():
	NeonUI.add_main_background(self)
	var header = NeonUI.header(self, "LOJA", 56, 18, 18, 30)
	header.back.pressed.connect(func(): get_tree().current_scene.go_to("menu"))
	wallet_row = HBoxContainer.new()
	wallet_row.add_theme_constant_override("separation", 8)
	header.box.add_child(wallet_row)

	tab_row = HBoxContainer.new()
	tab_row.set_anchors_preset(Control.PRESET_TOP_WIDE)
	tab_row.offset_top = 158
	tab_row.offset_left = 12
	tab_row.offset_right = -12
	tab_row.add_theme_constant_override("separation", 6)
	add_child(tab_row)
	for item in tabs:
		var button = Button.new()
		button.text = item[1]
		button.custom_minimum_size = Vector2(0, 40)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 12)
		button.pressed.connect(_set_tab.bind(item[0]))
		tab_row.add_child(button)

	list = NeonUI.make_scroll(self, 212, 16, 16, 16, 12)

func _refresh():
	if not is_node_ready():
		return
	var save = SaveSystem.get_save()
	NeonUI.clear_children(wallet_row)
	wallet_row.add_child(NeonUI.resource_badge("res://assets/ui/ui_coin.png", str(save.coins)))
	wallet_row.add_child(NeonUI.resource_badge("res://assets/ui/ui_gem.png", str(save.gems)))
	wallet_row.add_child(NeonUI.resource_badge("res://assets/ui/ui_key.png", str(save.keys)))
	wallet_row.add_child(NeonUI.resource_badge("res://assets/ui/ui_legendary_key.png", str(save.legendary_keys)))
	for i in range(tab_row.get_child_count()):
		var tab_id = tabs[i][0]
		var active = tab_id == active_tab
		var button = tab_row.get_child(i)
		button.add_theme_color_override("font_color", Color("#001018") if active else Color("#ffffffaa"))
		button.add_theme_stylebox_override("normal", NeonUI.flat(Color("#00f0ff") if active else Color("#ffffff11"), Color("#00f0ff") if active else Color.TRANSPARENT, 0, 8))
		button.add_theme_stylebox_override("hover", NeonUI.flat(Color("#00f0ff") if active else Color("#ffffff18"), Color("#00f0ff"), 0, 8))
	NeonUI.clear_children(list)
	match active_tab:
		"chests":
			_build_chests()
		"gems":
			_build_gems()
		"keys":
			_build_keys()
		"specials":
			_build_specials()
		"free":
			_build_free()

func _set_tab(tab):
	active_tab = tab
	AudioManager.play_sfx("button_click")
	_refresh()

func _build_chests():
	list.add_child(NeonUI.label("COMPRAR E ABRIR", 12, Color("#ffffff88")))
	for chest in GameData.get_chests():
		_add_chest_product(chest)
	list.add_child(NeonUI.label("BAUS GUARDADOS", 12, Color("#ffffff88")))
	var save = SaveSystem.get_save()
	var found = false
	for chest in GameData.get_chests():
		var amount = int(save.inventory_chests.get(chest.id, 0))
		if amount > 0:
			found = true
			_add_owned_chest(chest, amount)
	if not found:
		list.add_child(NeonUI.label("Nenhum bau guardado.", 13, Color("#ffffff88")))

func _build_gems():
	_add_product("res://assets/ui/ui_gem.png", "Diamantes pequenos", "+140 diamantes", "R$ 1,99", "diamonds_small", Color("#00f0ff"), func(): _grant_paid({"gems": 140}))
	_add_product("res://assets/ui/ui_gem.png", "Diamantes medios", "+480 diamantes", "R$ 4,99", "diamonds_medium", Color("#00f0ff"), func(): _grant_paid({"gems": 480}))
	_add_product("res://assets/ui/ui_gem.png", "Diamantes grandes", "+1.350 diamantes", "R$ 9,99", "diamonds_large", Color("#00f0ff"), func(): _grant_paid({"gems": 1350}))
	_add_product("res://assets/ui/ui_daily_reward.png", "Oferta diaria", "Diamantes, chaves e XP", "R$ 2,99", "daily_offer", Color("#ffd700"), func(): _grant_paid({"gems": 90, "keys": 2, "profile_xp": 180}))
	_add_ad_button("res://assets/ui/ui_ad.png", "Gemas gratis", _ad_gems)

func _build_keys():
	_add_product("res://assets/ui/ui_key.png", "Pacote de chaves", "+6 chaves raras", "80", "keys_pack", Color("#ffd700"), func():
		if SaveSystem.pay("gems", 80):
			SaveSystem.add_resource("keys", 6)
			SaveSystem.save_game()
	)
	_add_product("res://assets/ui/ui_legendary_key.png", "Chaves lendarias", "+2 chaves lendarias", "180", "legendary_key", Color("#ffd700"), _buy_legendary_key_pack)
	_add_ad_button("res://assets/ui/ui_ad.png", "Chave gratis", _ad_key)

func _build_specials():
	_add_product("res://assets/ui/ui_inventory.png", "Pacote inicial", "Diamantes, moedas, chaves e chave lendaria", "R$ 4,99", "starter_pack", Color("#00aaff"), func(): _grant_paid({"gems": 260, "coins": 2500, "keys": 5, "legendary_keys": 1}))
	_add_product("res://assets/ui/ui_skins.png", "Pacote de skins", "2 baus raros e 2 baus epicos", "R$ 5,99", "skin_pack", Color("#ff4fd8"), func(): _grant_paid({"rare_chests": 2, "epic_chests": 2}))
	_add_product("res://assets/ui/ui_fragments.png", "Pacote de fragmentos", "130 fragmentos da skin equipada", "R$ 3,99", "fragment_pack", Color("#b000ff"), func(): _grant_paid({"fragments": 130}))
	_add_product("res://assets/ui/ui_event.png", "Pacote de evento", "Bau epico, diamantes, chaves e XP", "R$ 4,99", "event_pack", Color("#00ff88"), func(): _grant_paid({"epic_chests": 1, "gems": 90, "keys": 2, "profile_xp": 420}))
	_add_product("res://assets/ui/ui_chest_epic.png", "Pacote de baus", "3 comuns, 2 raros e 1 epico", "R$ 6,99", "chest_pack", Color("#ffd700"), func(): _grant_paid({"common_chests": 3, "rare_chests": 2, "epic_chests": 1}))

func _build_free():
	_add_ad_button("res://assets/ui/ui_ad.png", "Gemas gratis", _ad_gems)
	_add_ad_button("res://assets/ui/ui_coin.png", "Moedas gratis", _ad_coins)
	_add_ad_button("res://assets/ui/ui_chest_common.png", "Bau comum gratis", _ad_chest)
	_add_ad_button("res://assets/ui/ui_key.png", "Chave gratis", _ad_key)

func _add_chest_product(chest):
	var color = Color(chest.color)
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 112)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text = ""
	button.add_theme_stylebox_override("normal", NeonUI.neon_box(Color(color, 0.25), Color(color, 0.60), 1, 12, 0.20))
	button.add_theme_stylebox_override("hover", NeonUI.neon_box(Color(color, 0.34), color, 1, 12, 0.28))
	button.pressed.connect(func(): _buy_open_chest(chest.id))
	list.add_child(button)
	var row = HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 12)
	button.add_child(row)
	row.add_child(_icon_box(chest.icon_path, 54))
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 3)
	row.add_child(info)
	info.add_child(NeonUI.label(chest.name, 17, Color.WHITE))
	info.add_child(NeonUI.label(chest.description, 12, Color("#ffffffaa")))
	info.add_child(NeonUI.label(_chance_text(chest), 11, Color("#ffd700")))
	var action = VBoxContainer.new()
	action.custom_minimum_size = Vector2(72, 0)
	action.alignment = BoxContainer.ALIGNMENT_CENTER
	action.add_theme_constant_override("separation", 3)
	row.add_child(action)
	action.add_child(NeonUI.label("%d" % int(chest.cost), 12, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))
	action.add_child(NeonUI.icon(_currency_icon(chest.currency), 15))
	action.add_child(NeonUI.label("ABRIR", 11, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_CENTER))

func _add_owned_chest(chest, amount):
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 64)
	button.text = "%s\nx%d disponivel" % [chest.name, amount]
	button.icon = load(chest.icon_path) if ResourceLoader.exists(chest.icon_path) else null
	button.expand_icon = true
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", NeonUI.flat(Color("#ffffff12"), Color("#00f0ff44"), 1, 12))
	button.add_theme_stylebox_override("hover", NeonUI.flat(Color("#ffffff18"), Color("#00f0ff"), 1, 12))
	button.pressed.connect(_open_owned.bind(chest.id))
	list.add_child(button)

func _add_product(icon_path, title, subtitle, price, _key, color, action):
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 76)
	button.text = ""
	button.add_theme_stylebox_override("normal", NeonUI.flat(Color("#ffffff12"), Color("#ffffff22"), 1, 10))
	button.add_theme_stylebox_override("hover", NeonUI.flat(Color("#ffffff18"), Color(color, 0.55), 1, 10))
	button.pressed.connect(action)
	list.add_child(button)
	var row = HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 12)
	button.add_child(row)
	row.add_child(_icon_box(icon_path, 48))
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	info.add_child(NeonUI.label(title, 17, Color.WHITE))
	info.add_child(NeonUI.label(subtitle, 12, Color("#ffffff99")))
	var price_box = PanelContainer.new()
	price_box.add_theme_stylebox_override("panel", NeonUI.flat(Color.TRANSPARENT, Color.TRANSPARENT, 0, 0))
	row.add_child(price_box)
	price_box.add_child(NeonUI.label(price, 13, Color("#ffd700"), HORIZONTAL_ALIGNMENT_RIGHT))

func _add_ad_button(icon_path, title, action):
	var button = NeonUI.main_button(title, Color("#00ff88"), Color("#008855"), 54)
	button.icon = load(icon_path) if ResourceLoader.exists(icon_path) else null
	button.expand_icon = true
	button.pressed.connect(action)
	list.add_child(button)

func _icon_box(icon_path, size):
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(size, size)
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#00000033"), Color.TRANSPARENT, 0, 14))
	var center = CenterContainer.new()
	panel.add_child(center)
	center.add_child(NeonUI.icon(icon_path, min(size - 12, 42)))
	return panel

func _buy_open_chest(chest_id):
	var result = SaveSystem.buy_and_open_chest(chest_id)
	AudioManager.play_sfx("chest_open" if result.get("ok", false) else "button_error")
	_refresh()

func _open_owned(chest_id):
	var reward = SaveSystem.open_inventory_chest(chest_id)
	AudioManager.play_sfx("chest_open" if not reward.is_empty() else "button_error")
	_refresh()

func _ad_gems():
	await _grant_ad("gems")

func _ad_coins():
	await _grant_ad("coins")

func _ad_key():
	await _grant_ad("key")

func _ad_chest():
	await _grant_ad("chest")

func _grant_ad(kind):
	AudioManager.play_sfx("button_click")
	await AdsService.show_rewarded("store_%s" % kind)
	SaveSystem.grant_ad_reward(kind)
	AudioManager.play_sfx("button_confirm")

func _grant_paid(rewards):
	var save = SaveSystem.get_save()
	save.gems += int(rewards.get("gems", 0))
	save.coins += int(rewards.get("coins", 0))
	save.keys += int(rewards.get("keys", 0))
	save.legendary_keys += int(rewards.get("legendary_keys", 0))
	for _i in range(int(rewards.get("common_chests", 0))):
		SaveSystem.add_chest("common", 1)
	for _i in range(int(rewards.get("rare_chests", 0))):
		SaveSystem.add_chest("rare", 1)
	for _i in range(int(rewards.get("epic_chests", 0))):
		SaveSystem.add_chest("epic", 1)
	var fragments = int(rewards.get("fragments", 0))
	if fragments > 0:
		var skin_id = save.equipped_skin
		save.skin_fragments[skin_id] = int(save.skin_fragments.get(skin_id, 0)) + fragments
	SaveSystem.save_game()
	AudioManager.play_sfx("button_confirm")

func _buy_legendary_key_pack():
	if SaveSystem.pay("gems", 180):
		SaveSystem.add_resource("legendary_keys", 2)
		AudioManager.play_sfx("button_confirm")
	else:
		AudioManager.play_sfx("button_error")

func _chance_text(chest):
	var parts = []
	for rarity in GameData.RARITY_ORDER:
		if chest.chances.has(rarity):
			parts.append("%s %d%%" % [_rarity_label(rarity).to_lower(), int(round(float(chest.chances[rarity]) * 100.0))])
	return " / ".join(parts)

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
			return "Epica"
		"legendary":
			return "Lendaria"
		"mythic":
			return "Mitica"
		"ultimate":
			return "Ultimate"
	return String(rarity)

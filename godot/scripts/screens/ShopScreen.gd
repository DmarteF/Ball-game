extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

var wallet_row
var tab_row
var list
var active_tab = "chests"
var tabs = [
	["chests", "BAUS"],
	["gems", "DIAMANTES"],
	["keys", "CHAVES"],
	["specials", "RECOMPENSAS"],
	["free", "GRATIS"]
]

func _ready():
	SaveSystem.save_changed.connect(func(_save): _refresh())
	_build_ui()
	_refresh()

func _build_ui():
	NeonUI.add_main_background(self)
	var header = VBoxContainer.new()
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_top = 56
	header.offset_left = 18
	header.offset_right = -18
	header.add_theme_constant_override("separation", 10)
	add_child(header)

	var back = Button.new()
	back.text = "< VOLTAR"
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back.add_theme_font_size_override("font_size", 16)
	back.add_theme_color_override("font_color", Color("#00f0ff"))
	back.add_theme_stylebox_override("normal", NeonUI.flat(Color.TRANSPARENT, Color.TRANSPARENT, 0, 0))
	back.add_theme_stylebox_override("hover", NeonUI.flat(Color("#ffffff10"), Color.TRANSPARENT, 0, 0))
	back.pressed.connect(func(): get_tree().current_scene.go_to("menu"))
	header.add_child(back)
	header.add_child(NeonUI.label("LOJA", 28, Color("#00f0ff")))

	wallet_row = HBoxContainer.new()
	wallet_row.add_theme_constant_override("separation", 8)
	header.add_child(wallet_row)

	tab_row = HBoxContainer.new()
	tab_row.set_anchors_preset(Control.PRESET_TOP_WIDE)
	tab_row.offset_top = 158
	tab_row.offset_left = 12
	tab_row.offset_right = -12
	tab_row.add_theme_constant_override("separation", 6)
	add_child(tab_row)

	for item in tabs:
		var button = NeonUI.ghost_button(item[1], Color("#00f0ff"), 40)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_set_tab.bind(item[0]))
		tab_row.add_child(button)

	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 212
	scroll.offset_left = 14
	scroll.offset_right = -14
	scroll.offset_bottom = -14
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	list = VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 10)
	scroll.add_child(list)

func _set_tab(tab):
	active_tab = tab
	AudioManager.play_sfx("button_click")
	_refresh()

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
		tab_row.get_child(i).modulate = Color.WHITE if tab_id == active_tab else Color(1, 1, 1, 0.65)
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

func _build_chests():
	for chest in GameData.get_chests():
		var price = "%d %s" % [int(chest.cost), _currency_label(chest.currency)]
		_add_product(_chest_icon(chest.id), chest.name, chest.description, price, Color(chest.color), func(): _buy_open_chest(chest.id))

func _build_gems():
	_add_product("res://assets/ui/ui_gem.png", "Pacote Pequeno de Diamantes", "Receba 140 diamantes para upgrades, baus e recompensas.", "1.99", Color("#00f0ff"), func(): _grant_paid({"gems": 140}))
	_add_product("res://assets/ui/ui_gem.png", "Pacote Medio de Diamantes", "Receba 480 diamantes para acelerar seu progresso.", "4.99", Color("#00f0ff"), func(): _grant_paid({"gems": 480}))
	_add_product("res://assets/ui/ui_gem.png", "Pacote Grande de Diamantes", "Receba 1.350 diamantes para desbloquear mais recompensas.", "9.99", Color("#00f0ff"), func(): _grant_paid({"gems": 1350}))

func _build_keys():
	_add_product("res://assets/ui/ui_daily_reward.png", "Oferta Diaria", "90 diamantes, 2 chaves e XP para ajudar no progresso.", "2.99", Color("#ffd700"), func(): _grant_paid({"gems": 90, "keys": 2, "profile_xp": 180}))
	_add_product("res://assets/ui/ui_key.png", "Pacote Inicial", "260 diamantes, 2.500 moedas, 5 chaves e 1 chave lendaria.", "4.99", Color("#00aaff"), func(): _grant_paid({"gems": 260, "coins": 2500, "keys": 5, "legendary_keys": 1}))
	_add_product("res://assets/ui/ui_legendary_key.png", "Chaves lendarias", "+2 chaves lendarias por 180 diamantes.", "180", Color("#ffd700"), _buy_legendary_key_pack)

func _build_specials():
	_add_product("res://assets/ui/ui_skins.png", "Pacote de Skins", "2 baus raros e 2 baus epicos para tentar desbloquear skins.", "5.99", Color("#ff4fd8"), func(): _grant_paid({"rare_chests": 2, "epic_chests": 2}))
	_add_product("res://assets/ui/ui_fragments.png", "Pacote de Fragmentos", "130 fragmentos para evoluir a skin equipada.", "3.99", Color("#b000ff"), func(): _grant_paid({"fragments": 130}))
	_add_product("res://assets/ui/ui_event.png", "Pacote de Evento", "1 bau epico, 90 diamantes, 2 chaves e XP.", "4.99", Color("#00ff88"), func(): _grant_paid({"epic_chests": 1, "gems": 90, "keys": 2, "profile_xp": 420}))
	_add_product("res://assets/ui/ui_chest_epic.png", "Pacote de Baus", "3 comuns, 2 raros e 1 epico.", "6.99", Color("#ffd700"), func(): _grant_paid({"common_chests": 3, "rare_chests": 2, "epic_chests": 1}))

func _build_free():
	_add_product("res://assets/ui/ui_ad.png", "Gemas gratis", "Assista anuncio para +12 diamantes.", "GRATIS", Color("#00ff88"), _ad_gems)
	_add_product("res://assets/ui/ui_coin.png", "Moedas gratis", "Assista anuncio para +300 moedas.", "GRATIS", Color("#00ff88"), _ad_coins)
	_add_product("res://assets/ui/ui_key.png", "Chave gratis", "Assista anuncio para +1 chave.", "GRATIS", Color("#00ff88"), _ad_key)
	_add_product("res://assets/ui/ui_chest_common.png", "Bau comum gratis", "Receba um bau comum no inventario.", "GRATIS", Color("#00ff88"), _ad_chest)

func _add_product(icon_path, title, subtitle, price, color, action):
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 76)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text = "%s\n%s\n%s" % [title, subtitle, price]
	button.icon = load(icon_path) if ResourceLoader.exists(icon_path) else null
	button.expand_icon = true
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", NeonUI.neon_box(Color("#ffffff12"), Color(color, 0.58), 1, 12, 0.22))
	button.add_theme_stylebox_override("hover", NeonUI.neon_box(Color(color, 0.18), Color(color), 1, 12, 0.34))
	button.pressed.connect(action)
	list.add_child(button)

func _buy_open_chest(chest_id):
	var result = SaveSystem.buy_and_open_chest(chest_id)
	AudioManager.play_sfx("chest_open" if result.get("ok", false) else "button_error")

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

func _chest_icon(id):
	if id == "rare":
		return "res://assets/ui/ui_chest_rare.png"
	if id == "epic":
		return "res://assets/ui/ui_chest_epic.png"
	if id == "legendary":
		return "res://assets/ui/ui_chest_legendary.png"
	return "res://assets/ui/ui_chest_common.png"

func _currency_label(currency):
	if currency == "coins":
		return "moedas"
	if currency == "gems":
		return "diamantes"
	if currency == "legendary_keys":
		return "chaves lend."
	return "chaves"

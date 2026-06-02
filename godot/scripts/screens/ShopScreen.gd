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
	var title = NeonUI.label("LOJA", 28, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_RIGHT)
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

func _refresh():
	if not is_node_ready():
		return
	var save = SaveSystem.get_save()
	wallet_label.text = "Moedas %d  Diamantes %d  Chaves %d  Lendarias %d" % [save.coins, save.gems, save.keys, save.legendary_keys]
	NeonUI.clear_children(list)
	list.add_child(NeonUI.label("RECOMPENSAS GRATIS", 13, Color("#ffffff88")))
	_add_product("Gemas gratis", "Assista anuncio mock para +12 diamantes", "res://assets/ui/ui_ad.png", Color("#00ff88"), _ad_gems)
	_add_product("Moedas gratis", "Assista anuncio mock para +300 moedas", "res://assets/ui/ui_coin.png", Color("#00ff88"), _ad_coins)
	_add_product("Chave gratis", "Assista anuncio mock para +1 chave rara", "res://assets/ui/ui_key.png", Color("#00ff88"), _ad_key)
	_add_product("Bau comum gratis", "Receba um bau comum no inventario", "res://assets/ui/ui_chest_common.png", Color("#00ff88"), _ad_chest)
	list.add_child(NeonUI.label("PACOTES COM DIAMANTES", 13, Color("#ffffff88")))
	_add_product("Pacote de chaves", "+6 chaves raras por 80 diamantes", "res://assets/ui/ui_key.png", Color("#00aaff"), _buy_key_pack)
	_add_product("Chaves lendarias", "+2 chaves lendarias por 180 diamantes", "res://assets/ui/ui_legendary_key.png", Color("#ffd700"), _buy_legendary_key_pack)
	_add_product("Pacote de fragmentos", "+30 fragmentos da skin equipada por 90 diamantes", "res://assets/ui/ui_fragments.png", Color("#b000ff"), _buy_fragment_pack)
	list.add_child(NeonUI.label("ATALHOS", 13, Color("#ffffff88")))
	_add_product("Abrir baus", "Comprar e abrir baus por raridade", "res://assets/ui/ui_chest_epic.png", Color("#ffd700"), func(): get_tree().current_scene.go_to("chests"))

func _add_product(title, subtitle, icon_path, color, action):
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 74)
	button.text = "%s\n%s" % [title, subtitle]
	button.icon = load(icon_path) if ResourceLoader.exists(icon_path) else null
	button.expand_icon = true
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", NeonUI.flat(Color(color, 0.22), Color(color, 0.70), 1, 10))
	button.add_theme_stylebox_override("hover", NeonUI.flat(Color(color, 0.36), Color(color), 1, 10))
	button.pressed.connect(action)
	list.add_child(button)

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

func _buy_key_pack():
	if SaveSystem.pay("gems", 80):
		SaveSystem.add_resource("keys", 6)
		AudioManager.play_sfx("button_confirm")
	else:
		AudioManager.play_sfx("button_error")

func _buy_legendary_key_pack():
	if SaveSystem.pay("gems", 180):
		SaveSystem.add_resource("legendary_keys", 2)
		AudioManager.play_sfx("button_confirm")
	else:
		AudioManager.play_sfx("button_error")

func _buy_fragment_pack():
	if SaveSystem.pay("gems", 90):
		var skin_id = SaveSystem.get_save().equipped_skin
		SaveSystem.save.skin_fragments[skin_id] = int(SaveSystem.save.skin_fragments.get(skin_id, 0)) + 30
		SaveSystem.save_game()
		AudioManager.play_sfx("button_confirm")
	else:
		AudioManager.play_sfx("button_error")

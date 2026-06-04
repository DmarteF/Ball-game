extends Control

@export var screen_id := "shop"

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const NeonBackButtonScript := preload("res://scripts/NeonBackButton.gd")

const ICON_PATHS := {
	"shop": "res://assets/ui/ui_store.png",
	"inventory": "res://assets/ui/ui_inventory.png",
	"missions": "res://assets/ui/ui_missions.png",
	"event": "res://assets/ui/ui_event.png",
	"wheel": "res://assets/ui/ui_wheel.png",
	"daily_reward": "res://assets/ui/ui_daily_reward.png",
	"boss": "res://assets/ui/ui_boss.png",
	"league": "res://assets/ui/ui_league_neon.png",
	"achievements": "res://assets/ui/ui_achievements.png",
	"skins": "res://assets/ui/ui_skins.png",
	"coin": "res://assets/ui/ui_coin.png",
	"gem": "res://assets/ui/ui_gem.png",
	"key": "res://assets/ui/ui_key.png",
	"chest_common": "res://assets/ui/ui_chest_common.png",
	"chest_rare": "res://assets/ui/ui_chest_rare.png",
	"chest_epic": "res://assets/ui/ui_chest_epic.png",
	"chest_legendary": "res://assets/ui/ui_chest_legendary.png",
	"product_starter": "res://assets/icons/products/product_starter_pack.png",
	"product_diamonds": "res://assets/icons/products/product_diamonds_medium.png",
	"product_chests": "res://assets/icons/products/product_chests_pack.png",
	"product_event": "res://assets/icons/products/product_event_pack.png",
	"product_daily": "res://assets/icons/products/product_daily_offer.png",
}

const SCREEN_DATA := {
	"shop": {
		"title": "LOJA",
		"icon": "shop",
		"accent": "#00aaff",
		"cards": [
			{ "title": "Pacote inicial", "desc": "Moedas, diamantes e chaves para acelerar o começo.", "icon": "product_starter", "button": "COMPRAR", "tone": "#00f0ff" },
			{ "title": "Diamantes", "desc": "Pacote médio de diamantes para skins e baús.", "icon": "product_diamonds", "button": "COMPRAR", "tone": "#00ff88" },
			{ "title": "Baús", "desc": "Pacote visual com baús comum, raro e épico.", "icon": "product_chests", "button": "COMPRAR", "tone": "#ffd700" },
			{ "title": "Recompensa por anúncio", "desc": "Assista um anúncio mockado para ganhar moedas.", "icon": "coin", "button": "VER ANÚNCIO", "tone": "#ff8800" },
			{ "title": "Oferta especial", "desc": "Bundle visual temporário preparado para eventos.", "icon": "product_event", "button": "RESGATAR", "tone": "#ff00aa" },
		],
	},
	"inventory": {
		"title": "INVENTÁRIO",
		"icon": "inventory",
		"accent": "#ffd700",
		"empty_title": "Inventário vazio",
		"empty_desc": "",
		"cards": [],
	},
	"missions": {
		"title": "MISSÕES",
		"icon": "missions",
		"accent": "#ff8800",
		"empty_title": "Nenhuma missão disponível",
		"empty_desc": "",
		"cards": [],
	},
	"event": {
		"title": "EVENTO",
		"icon": "event",
		"accent": "#00ff88",
		"empty_title": "Nenhum evento ativo",
		"empty_desc": "",
		"cards": [],
	},
	"wheel": {
		"title": "ROLETA",
		"icon": "wheel",
		"accent": "#00ff88",
		"cards": [
			{ "title": "Giro grátis", "desc": "1 giro visual disponível hoje.", "icon": "wheel", "button": "GIRAR", "tone": "#00f0ff" },
			{ "title": "Prêmios", "desc": "Moedas, diamantes, chaves, baús e efeitos.", "icon": "gem", "button": "VER PRÊMIOS", "tone": "#ffd700" },
		],
	},
	"daily_reward": {
		"title": "RECOMPENSA DIÁRIA",
		"icon": "daily_reward",
		"accent": "#ffd700",
		"cards": [
			{ "title": "Dia 1", "desc": "100 moedas", "icon": "coin", "button": "COLETAR", "tone": "#ffd700" },
			{ "title": "Dia 2", "desc": "25 diamantes", "icon": "gem", "button": "COLETAR", "tone": "#00ff88" },
			{ "title": "Dia 3", "desc": "1 chave", "icon": "key", "button": "COLETAR", "tone": "#00f0ff" },
			{ "title": "Dia 4", "desc": "Baú comum", "icon": "chest_common", "button": "COLETAR", "tone": "#9ca3af" },
			{ "title": "Dia 5", "desc": "Baú raro", "icon": "chest_rare", "button": "COLETAR", "tone": "#00aaff" },
			{ "title": "Dia 6", "desc": "75 diamantes", "icon": "gem", "button": "COLETAR", "tone": "#00ff88" },
			{ "title": "Dia 7", "desc": "Baú épico", "icon": "chest_epic", "button": "COLETAR", "tone": "#b000ff" },
		],
	},
	"boss": {
		"title": "BOSS",
		"icon": "boss",
		"accent": "#ff0055",
		"empty_title": "Nenhum boss disponível",
		"empty_desc": "",
		"cards": [],
	},
	"league": {
		"title": "LIGA NEON",
		"icon": "league",
		"accent": "#00ff88",
		"empty_title": "Liga indisponível",
		"empty_desc": "",
		"cards": [],
	},
	"achievements": {
		"title": "CONQUISTAS",
		"icon": "achievements",
		"accent": "#ffd700",
		"empty_title": "Nenhuma conquista desbloqueada",
		"empty_desc": "",
		"cards": [],
	},
}

const SHOP_TABS := [
	{
		"id": "chests",
		"label": "Baús",
		"section": "COMPRAR E ABRIR",
		"cards": [
			{ "title": "Baú Comum", "desc": "Recompensas básicas, moedas e chance de skin comum.", "icon": "chest_common", "button": "buy", "tone": "#9ca3af", "price": "100", "cost_icon": "coin", "action": "common_chest" },
			{ "title": "Baú Raro", "desc": "Chance maior de diamantes, itens raros e efeitos.", "icon": "chest_rare", "button": "buy", "tone": "#00aaff", "price": "40", "cost_icon": "gem", "action": "rare_chest" },
			{ "title": "Baú Épico", "desc": "Recompensas melhores e chance de skins épicas.", "icon": "chest_epic", "button": "buy", "tone": "#b000ff", "price": "120", "cost_icon": "gem", "action": "epic_chest" },
			{ "title": "Baú Lendário", "desc": "Skins lendárias, diamantes e itens especiais.", "icon": "chest_legendary", "button": "buy", "tone": "#ffd700", "price": "1", "cost_icon": "chest_legendary", "action": "legendary_chest" },
		],
	},
	{
		"id": "gems",
		"label": "Diamantes",
		"section": "PACOTES DE DIAMANTES",
		"cards": [
			{ "title": "Pacote pequeno de diamantes", "desc": "Diamantes para baús, skins e ofertas.", "icon": "product_diamonds", "button": "buy", "tone": "#00ff88", "price": "R$ 4,90" },
			{ "title": "Pacote médio de diamantes", "desc": "Mais valor para evoluir sua coleção.", "icon": "product_diamonds", "button": "buy", "tone": "#00ff88", "price": "R$ 9,90" },
			{ "title": "Oferta diária", "desc": "Pacote visual diário com diamantes e bônus.", "icon": "product_daily", "button": "buy", "tone": "#ffd700", "price": "R$ 6,90" },
			{ "title": "Diamantes grátis", "desc": "Recompensa mockada por anúncio.", "icon": "gem", "button": "watch_ad", "tone": "#00f0ff", "price": "+12", "cost_icon": "gem", "action": "ad_gems" },
		],
	},
	{
		"id": "keys",
		"label": "Chaves",
		"section": "CHAVES",
		"cards": [
			{ "title": "Pacote de chaves", "desc": "+6 chaves raras para abrir recompensas.", "icon": "key", "button": "buy", "tone": "#00f0ff", "price": "80", "cost_icon": "gem", "action": "keys_pack" },
			{ "title": "Chaves lendárias", "desc": "+2 chaves lendárias para baús premium.", "icon": "chest_legendary", "button": "buy", "tone": "#ffd700", "price": "180", "cost_icon": "gem", "action": "legendary_keys_pack" },
			{ "title": "Chave grátis", "desc": "Recompensa mockada por anúncio.", "icon": "key", "button": "watch_ad", "tone": "#00ff88", "price": "+1", "cost_icon": "key", "action": "ad_key" },
		],
	},
	{
		"id": "specials",
		"label": "Recompensas",
		"section": "OFERTAS ESPECIAIS",
		"cards": [
			{ "title": "Pacote inicial", "desc": "Moedas, diamantes e chaves para acelerar o começo.", "icon": "product_starter", "button": "buy", "tone": "#00f0ff", "price": "R$ 7,90", "action": "mock_paid" },
			{ "title": "Pacote de skins", "desc": "Visual preparado para liberar skins futuras.", "icon": "product_chests", "button": "buy", "tone": "#ff00aa", "price": "R$ 12,90", "action": "mock_paid" },
			{ "title": "Pacote de evento", "desc": "Bundle visual temporário preparado para eventos.", "icon": "product_event", "button": "buy", "tone": "#00ff88", "price": "R$ 14,90", "action": "mock_paid" },
			{ "title": "Pacote de baús", "desc": "Baús variados para recompensas futuras.", "icon": "product_chests", "button": "buy", "tone": "#ffd700", "price": "R$ 9,90", "action": "mock_paid" },
		],
	},
	{
		"id": "free",
		"label": "Baú grátis",
		"section": "RECOMPENSAS GRÁTIS",
		"cards": [
			{ "title": "Diamantes grátis", "desc": "Assista um anúncio mockado para receber diamantes.", "icon": "gem", "button": "watch_ad", "tone": "#00ff88", "price": "+12", "cost_icon": "gem", "action": "ad_gems" },
			{ "title": "Moedas grátis", "desc": "Assista um anúncio mockado para receber moedas.", "icon": "coin", "button": "watch_ad", "tone": "#ffd700", "price": "+300", "cost_icon": "coin", "action": "ad_coins" },
			{ "title": "Baú comum grátis", "desc": "Recompensa visual por anúncio.", "icon": "chest_common", "button": "watch_ad", "tone": "#00f0ff", "price": "1x", "cost_icon": "chest_common", "action": "ad_chest" },
			{ "title": "Dobrar offline", "desc": "Preparado para dobrar recompensas AFK.", "icon": "product_daily", "button": "watch_ad", "tone": "#ff8800", "price": "2x", "cost_icon": "coin", "action": "ad_coins" },
		],
	},
]

var _regular_font: Font
var _bold_font: Font
var _shop_tab := "chests"
var _content: VBoxContainer
var _shop_tab_buttons: Array[Button] = []
var _feedback_label: Label
var _reward_overlay: Control
var _wheel_prize_ring: Control
var _wheel_prizes := ["coin", "gem", "key", "chest_common", "skins", "chest_rare", "skins", "chest_epic", "gem", "skins"]


func _ready() -> void:
	_regular_font = _make_system_font(400)
	_bold_font = _make_system_font(700)
	if has_node("/root/AudioManager"):
		AudioManager.play_context("menu")
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
	var data: Dictionary = SCREEN_DATA.get(screen_id, SCREEN_DATA["shop"])
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
	root.add_theme_constant_override("separation", 10 if _is_narrow_screen() else 12)
	add_child(root)

	var header := _make_header(data)
	root.add_child(header)
	NeonBackButtonScript.add_to(self, _go_back)

	if screen_id == "shop":
		root.add_child(_make_wallet())
		root.add_child(_make_shop_tabs())
	_feedback_label = _make_label("", 13, "#00ff88", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	_feedback_label.custom_minimum_size.y = 22
	root.add_child(_feedback_label)

	if screen_id == "wheel":
		root.add_child(_make_wheel_visual(data))

	var scroll := ScrollContainer.new()
	_configure_scroll(scroll)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.mouse_filter = Control.MOUSE_FILTER_PASS
	_content.add_theme_constant_override("separation", 12)
	scroll.add_child(_content)

	_populate_content(data)


func _populate_content(data: Dictionary) -> void:
	for child in _content.get_children():
		child.queue_free()

	if screen_id == "shop":
		_content.add_child(_make_section_title(_shop_section_label(String(_current_shop_tab()["id"]), String(_current_shop_tab()["section"]))))
		for card_data in _current_shop_tab()["cards"]:
			_content.add_child(_make_feature_card(card_data))
		_content.add_child(_make_section_title("STORED CHESTS" if _language() == "en" else "BAÚS GUARDADOS"))
		_content.add_child(_make_inventory_summary())
	elif screen_id == "inventory":
		_populate_inventory()
	elif screen_id == "missions":
		_populate_missions()
	elif screen_id == "event":
		_populate_event()
	elif screen_id == "boss":
		_populate_boss()
	elif screen_id == "achievements":
		_populate_achievements()
	elif screen_id == "daily_reward":
		_populate_daily_reward(data)
	elif screen_id == "wheel":
		_populate_wheel(data)
	elif data.get("cards", []).is_empty() and data.has("empty_title"):
		_content.add_child(_make_empty_state(_dynamic_empty_title(data), String(data["empty_desc"]), String(data["icon"])))
	else:
		for card_data in data["cards"]:
			_content.add_child(_make_feature_card(card_data))
	_content.add_child(_spacer(24))


func _make_header(data: Dictionary) -> PanelContainer:
	var card := _make_card(String(data["accent"]) + "18", String(data["accent"]) + "88")
	var body := _card_body(card, 14)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	body.add_child(row)
	row.add_child(_make_icon(String(data["icon"]), 34 if _is_narrow_screen() else 42))
	var title := _make_label(_screen_title(), 23 if _is_narrow_screen() else 27, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	title.add_theme_color_override("font_outline_color", Color("#00f0ff66"))
	title.add_theme_constant_override("outline_size", 4)
	row.add_child(title)
	return card


func _current_shop_tab() -> Dictionary:
	for tab in SHOP_TABS:
		if String(tab["id"]) == _shop_tab:
			return tab
	return SHOP_TABS[0]


func _make_wallet() -> GridContainer:
	var wallet := GridContainer.new()
	wallet.columns = 2 if _is_narrow_screen() else 4
	wallet.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wallet.mouse_filter = Control.MOUSE_FILTER_PASS
	wallet.add_theme_constant_override("separation", 8)
	wallet.add_child(_make_wallet_item("coin", str(GameState.data.get("coins", 0))))
	wallet.add_child(_make_wallet_item("gem", str(GameState.data.get("diamonds", 0))))
	wallet.add_child(_make_wallet_item("key", str(GameState.data.get("keys", 0))))
	wallet.add_child(_make_wallet_item("chest_legendary", str(GameState.data.get("legendary_keys", 0))))
	return wallet


func _make_wallet_item(icon_key: String, value: String) -> PanelContainer:
	var item := PanelContainer.new()
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.mouse_filter = Control.MOUSE_FILTER_PASS
	item.add_theme_stylebox_override("panel", _make_style("#ffffff12", 8, "#ffffff22", 1))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 5)
	item.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	margin.add_child(row)
	row.add_child(_make_icon(icon_key, 17))
	row.add_child(_make_label(value, 13, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	return item


func _make_shop_tabs() -> GridContainer:
	var tabs := GridContainer.new()
	tabs.columns = 2 if _is_narrow_screen() else 3
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.mouse_filter = Control.MOUSE_FILTER_PASS
	tabs.add_theme_constant_override("separation", 6)
	tabs.add_theme_constant_override("h_separation", 6)
	tabs.add_theme_constant_override("v_separation", 6)
	_shop_tab_buttons.clear()
	for tab in SHOP_TABS:
		tabs.add_child(_make_shop_tab_button(tab))
	return tabs


func _make_shop_tab_button(tab: Dictionary) -> Button:
	var active := String(tab["id"]) == _shop_tab
	var button := Button.new()
	button.text = _shop_tab_label(String(tab["id"]), String(tab["label"]))
	button.custom_minimum_size.y = 42
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 11)
	button.set_meta("tab_id", String(tab["id"]))
	_apply_shop_tab_style(button, active)
	button.pressed.connect(func() -> void:
		_shop_tab = String(tab["id"])
		_refresh_shop_tabs()
		_populate_content(SCREEN_DATA["shop"])
	)
	_shop_tab_buttons.append(button)
	return button


func _refresh_shop_tabs() -> void:
	for button in _shop_tab_buttons:
		_apply_shop_tab_style(button, String(button.get_meta("tab_id")) == _shop_tab)


func _apply_shop_tab_style(button: Button, active: bool) -> void:
	button.add_theme_color_override("font_color", Color("#001018") if active else Color("#ffffffaa"))
	_apply_button_style(button, _make_style("#00f0ff" if active else "#ffffff11", 8))


func _make_section_title(text: String) -> Label:
	var label := _make_label(text, 12, "#ffffff88", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	label.add_theme_constant_override("letter_spacing", 1)
	return label


func _make_empty_state(title: String, desc: String, icon_key: String) -> PanelContainer:
	var card := _make_card("#ffffff10", "#00f0ff44")
	card.custom_minimum_size.y = 210
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 20)
	card.add_child(margin)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	column.add_child(_make_icon(icon_key, 52, Color("#ffffffcc")))
	column.add_child(_make_label(title, 20, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	var label := _make_label(desc, 13, "#ffffff99", _regular_font, HORIZONTAL_ALIGNMENT_CENTER)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if not desc.is_empty():
		column.add_child(label)
	return card


func _dynamic_empty_title(data: Dictionary) -> String:
	if screen_id == "boss":
		return ("Boss available" if _language() == "en" else "Boss disponível") if TimeManager.is_boss_available() else ("No boss available" if _language() == "en" else "Nenhum boss disponível")
	if screen_id == "daily_reward":
		return ("Reward available" if _language() == "en" else "Recompensa disponível") if TimeManager.can_claim_daily_reward() else ("Daily reward already claimed" if _language() == "en" else "Recompensa diária já coletada")
	if screen_id == "event":
		return "No active event" if _language() == "en" else "Nenhum evento ativo"
	if screen_id == "achievements":
		return "No achievements unlocked" if _language() == "en" else "Nenhuma conquista desbloqueada"
	return String(data["empty_title"])


func _make_feature_card(data: Dictionary) -> PanelContainer:
	var tone := String(data.get("tone", "#00f0ff"))
	var card := _make_card("#ffffff12", tone + "77")
	var body := _card_body(card, 12)

	var title := _make_label(String(data["title"]), 17 if _is_narrow_screen() else 18, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var desc := _make_label(String(data["desc"]), 12, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var button := _make_action_button(_button_text(String(data.get("button", "view"))), tone)
	button.disabled = bool(data.get("disabled", false))
	if data.has("action"):
		button.pressed.connect(_handle_action.bind(String(data["action"])))
	if _is_narrow_screen():
		var top := HBoxContainer.new()
		top.add_theme_constant_override("separation", 10)
		top.mouse_filter = Control.MOUSE_FILTER_PASS
		body.add_child(top)
		top.add_child(_make_icon(String(data.get("icon", "coin")), 38))
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.mouse_filter = Control.MOUSE_FILTER_PASS
		column.add_theme_constant_override("separation", 4)
		top.add_child(column)
		column.add_child(title)
		column.add_child(desc)
		if data.has("progress"):
			column.add_child(_make_progress_bar(float(data["progress"]), tone))
		var bottom := HBoxContainer.new()
		bottom.alignment = BoxContainer.ALIGNMENT_END
		bottom.add_theme_constant_override("separation", 8)
		bottom.mouse_filter = Control.MOUSE_FILTER_PASS
		body.add_child(bottom)
		if data.has("price"):
			bottom.add_child(_make_price_badge(String(data["price"]), String(data.get("cost_icon", ""))))
		button.custom_minimum_size = Vector2(122, 42)
		bottom.add_child(button)
	else:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		body.add_child(row)
		row.add_child(_make_icon(String(data.get("icon", "coin")), 46))
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.mouse_filter = Control.MOUSE_FILTER_PASS
		column.add_theme_constant_override("separation", 4)
		row.add_child(column)
		column.add_child(title)
		column.add_child(desc)
		if data.has("progress"):
			column.add_child(_make_progress_bar(float(data["progress"]), tone))
		var right := VBoxContainer.new()
		right.alignment = BoxContainer.ALIGNMENT_CENTER
		right.mouse_filter = Control.MOUSE_FILTER_PASS
		right.add_theme_constant_override("separation", 5)
		row.add_child(right)
		if data.has("price"):
			right.add_child(_make_price_badge(String(data["price"]), String(data.get("cost_icon", ""))))
		right.add_child(button)
	return card


func _populate_inventory() -> void:
	var inventory: Dictionary = GameState.data.get("inventory", {})
	if inventory.is_empty():
		_content.add_child(_make_empty_state(_tr("inventory_empty"), _tr("inventory_empty_desc"), "inventory"))
		return
	for id in inventory.keys():
		var item: Dictionary = inventory[id]
		var card := {
			"title": "%s x%s" % [String(item.get("label", id)), int(item.get("amount", 0))],
			"desc": _tr("stored_reward") if String(item.get("type", "")) == "chest" else _tr("stored_item"),
			"icon": "chest_%s" % String(item.get("icon", "common")) if String(item.get("type", "")) == "chest" else "key",
			"button": "open" if String(item.get("type", "")) == "chest" else "done",
			"tone": "#ffd700",
			"action": "open:%s" % id,
		}
		_content.add_child(_make_feature_card(card))


func _make_inventory_summary() -> Control:
	var inventory: Dictionary = GameState.data.get("inventory", {})
	if inventory.is_empty():
		return _make_empty_state(_tr("no_chests"), _tr("stored_chests_desc"), "chest_common")
	var count := 0
	for id in inventory.keys():
		count += int(inventory[id].get("amount", 0))
	return _make_empty_state("%s item(s)" % count, _tr("stored_chests_desc"), "chest_common")


func _populate_daily_reward(data: Dictionary) -> void:
	var can_claim := TimeManager.can_claim_daily_reward()
	var streak := int(GameState.data.get("daily_streak", TimeManager.get_daily_streak()))
	_content.add_child(_make_section_title("7 DAY STREAK" if _language() == "en" else "SEQUÊNCIA DE 7 DIAS"))
	for i in range(data["cards"].size()):
		var card: Dictionary = data["cards"][i].duplicate()
		card["title"] = "Day %s" % (i + 1) if _language() == "en" else "Dia %s" % (i + 1)
		card["button"] = "claim" if can_claim and i == clampi(streak, 0, 6) else "done" if i < streak else "wait"
		card["action"] = "daily_claim" if can_claim and i == clampi(streak, 0, 6) else ""
		_content.add_child(_make_feature_card(card))


func _populate_wheel(data: Dictionary) -> void:
	var wheel: Dictionary = GameState.data.get("wheel", {})
	var free_used := bool(wheel.get("free_used", false))
	_content.add_child(_make_feature_card({
		"title": _tr("free_spin"),
		"desc": _tr("spin_desc"),
		"icon": "wheel",
		"button": "used" if free_used else "spin",
		"tone": "#00f0ff",
		"action": "" if free_used else "wheel_free",
	}))
	_content.add_child(_make_feature_card({
		"title": _tr("mock_ad_spin"),
		"desc": _tr("ad_spin_desc"),
		"icon": "gem",
		"button": "watch_ad",
		"tone": "#ffd700",
		"action": "wheel_ad",
	}))


func _populate_event() -> void:
	var event: Dictionary = GameState.get_weekly_event()
	_content.add_child(_make_event_header(event))
	_content.add_child(_make_section_title("OBJETIVOS DA SEMANA" if _language() == "pt" else "WEEKLY GOALS"))
	for task_value in Array(event.get("tasks", [])):
		var task: Dictionary = task_value
		var completed := bool(task.get("completed", false))
		var claimed := bool(task.get("claimed", false))
		var progress := int(task.get("progress", 0))
		var target := int(task.get("target", 1))
		_content.add_child(_make_feature_card({
			"title": String(task.get("title", "")),
			"desc": "%s/%s • %s" % [progress, target, _reward_label(Dictionary(task.get("reward", {})))],
			"icon": String(task.get("icon", "event")),
			"button": "done" if claimed else "claim" if completed else "go",
			"tone": String(task.get("tone", "#00f0ff")),
			"progress": float(progress) / max(1.0, float(target)),
			"action": "event:%s" % String(task.get("id", "")) if completed and not claimed else "",
			"disabled": not completed or claimed,
		}))
	var final: Dictionary = event.get("final", {})
	var final_completed := bool(final.get("completed", false))
	var final_claimed := bool(final.get("claimed", false))
	_content.add_child(_make_section_title("RECOMPENSA FINAL" if _language() == "pt" else "FINAL REWARD"))
	_content.add_child(_make_feature_card({
		"title": String(final.get("title", "")),
		"desc": "%s/%s • %s" % [int(final.get("progress", 0)), int(final.get("target", 1)), _reward_label(Dictionary(final.get("reward", {})))],
		"icon": String(final.get("icon", "skins")),
		"button": "done" if final_claimed else "claim" if final_completed else "locked",
		"tone": String(final.get("tone", "#ff00aa")),
		"progress": float(final.get("progress", 0)) / max(1.0, float(final.get("target", 1))),
		"action": "event:%s" % String(final.get("id", "final_skin")) if final_completed and not final_claimed else "",
		"disabled": not final_completed or final_claimed,
	}))


func _make_event_header(event: Dictionary) -> PanelContainer:
	var card := _make_card("#00f0ff16", "#00f0ff88")
	var body := _card_body(card, 14)
	var row: BoxContainer = VBoxContainer.new() if _is_narrow_screen() else HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	body.add_child(row)
	row.add_child(_make_icon("event", 54 if _is_narrow_screen() else 66))
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 4)
	copy.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_child(copy)
	copy.add_child(_make_label(String(event.get("title", "Evento Codex Neon")).to_upper(), 20, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	var desc := _make_label(String(event.get("desc", "")), 13, "#ffffffbb", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.add_child(desc)
	copy.add_child(_make_label("Termina em %s" % _format_remaining(int(event.get("seconds_remaining", 0))), 13, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	return card


func _populate_boss() -> void:
	var boss := _current_boss_data()
	_content.add_child(_make_boss_header(boss))
	_content.add_child(_make_section_title("NÍVEIS DO BOSS" if _language() == "pt" else "BOSS LEVELS"))
	var unlocked := int(GameState.data.get("max_unlocked_phase", 1)) >= 5 or int(GameState.data.get("level", 1)) >= 5
	for level_data in _boss_level_data():
		var card := Dictionary(level_data).duplicate(true)
		card["disabled"] = true
		card["button"] = "wait" if unlocked else "locked"
		card["desc"] = "%s • %s" % [String(card.get("desc", "")), _reward_label(Dictionary(card.get("reward", {})))]
		_content.add_child(_make_feature_card(card))
	_content.add_child(_make_empty_state(
		"Gameplay do Boss em breve" if _language() == "pt" else "Boss gameplay coming soon",
		"Interface portada da main. As lutas do Boss ainda nao iniciam nesta etapa." if _language() == "pt" else "Interface ported from main. Boss fights do not start yet.",
		"boss"
	))


func _make_boss_header(boss: Dictionary) -> PanelContainer:
	var card := _make_card("#ff005516", "#ff005588")
	var body := _card_body(card, 14)
	var row: BoxContainer = VBoxContainer.new() if _is_narrow_screen() else HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	body.add_child(row)
	row.add_child(_make_skin_preview(String(boss.get("skin", "neon_phoenix")), 72))
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 4)
	copy.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_child(copy)
	copy.add_child(_make_label("BOSS MENSAL", 12, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	copy.add_child(_make_label(String(boss.get("name", "Fênix Solar")).to_upper(), 22, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	var desc := _make_label(String(boss.get("desc", "")), 13, "#ffffffbb", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.add_child(desc)
	copy.add_child(_make_label("Passiva: %s" % String(boss.get("passive", "")), 12, "#ffcc66", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	copy.add_child(_make_label("Reset diario: %s • Reset mensal: %s" % [_format_remaining(_seconds_until_next_day()), _format_remaining(_seconds_until_next_month())], 11, "#ffffff99", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	return card


func _current_boss_data() -> Dictionary:
	var month := int(Time.get_datetime_dict_from_system().get("month", 6))
	match month:
		6:
			return { "name": "Fênix Solar", "skin": "neon_phoenix", "desc": "Um Boss que renasce em anéis sólidos.", "passive": "Quebras sólidas dão mais moedas ao Boss." }
		7:
			return { "name": "Dragão Astral", "skin": "astral_dragon", "desc": "Pressiona a arena com anéis orbitais.", "passive": "Quanto maior o combo, maior a rotação." }
		8:
			return { "name": "Guardião Dimensional", "skin": "dimensional_guardian", "desc": "Alterna padrões de fase e repulsão.", "passive": "A arena muda de ritmo em ciclos." }
	return { "name": "Fênix Solar", "skin": "neon_phoenix", "desc": "Um Boss que renasce em anéis sólidos.", "passive": "Quebras sólidas dão mais moedas ao Boss." }


func _boss_level_data() -> Array[Dictionary]:
	return [
		{ "title": "Normal", "desc": "Entrada diária do Boss", "icon": "boss", "tone": "#00f0ff", "reward": { "type": "coins", "amount": 180 } },
		{ "title": "Forte", "desc": "Boss com rotação elevada", "icon": "boss", "tone": "#00ff88", "reward": { "type": "diamonds", "amount": 4 } },
		{ "title": "Elite", "desc": "Arena mais agressiva", "icon": "boss", "tone": "#b000ff", "reward": { "type": "keys", "amount": 1 } },
		{ "title": "Lendário", "desc": "Recompensa rara e baú especial", "icon": "boss", "tone": "#ffd700", "reward": { "type": "chest", "chest_type": "rare", "amount": 1 } },
		{ "title": "Impossível", "desc": "Desafio visual máximo", "icon": "boss", "tone": "#ff0055", "reward": { "type": "chest", "chest_type": "epic", "amount": 1 } },
	]


func _populate_missions() -> void:
	GameState._ensure_live_systems()
	var daily: Dictionary = GameState.data.get("daily_missions", {})
	for mission in daily.get("missions", []):
		var definition := GameState.get_daily_mission_def(String(mission.get("id", "")))
		if definition.is_empty():
			continue
		var progress := int(mission.get("progress", 0))
		var target := int(definition.get("target", 1))
		var reward_text := _reward_label(Dictionary(definition.get("reward", {})))
		_content.add_child(_make_feature_card({
			"title": _localized_definition_title(definition),
			"desc": "%s: %s/%s • %s: %s" % [_tr("progress"), progress, target, _tr("missions_reward"), reward_text],
			"icon": "missions",
			"button": "claim" if progress >= target and not bool(mission.get("claimed", false)) else "done" if bool(mission.get("claimed", false)) else "go",
			"tone": "#ff8800",
			"progress": float(progress) / max(1.0, float(target)),
			"action": "mission:%s" % String(mission.get("id", "")) if progress >= target and not bool(mission.get("claimed", false)) else "",
		}))


func _populate_achievements() -> void:
	GameState._update_achievements(false)
	for achievement in GameState.get_achievements():
		var id := String(achievement["id"])
		var state: Dictionary = GameState.data.get("achievements", {}).get(id, {})
		var progress := int(state.get("progress", 0))
		var required := int(achievement.get("required", 1))
		var completed := bool(state.get("completed", false))
		var claimed := bool(state.get("claimed", false))
		var reward_text := _reward_label(Dictionary(achievement.get("reward", {})))
		_content.add_child(_make_feature_card({
			"title": _localized_achievement_name(achievement),
			"desc": "%s • %s: %s/%s • %s: %s" % [_localized_achievement_desc(achievement), _tr("progress"), progress, required, _tr("missions_reward"), reward_text],
			"icon": "achievements",
			"button": "claim" if completed and not claimed else "done" if claimed else "locked",
			"tone": "#ffd700",
			"progress": float(progress) / max(1.0, float(required)),
			"action": "achievement:%s" % id if completed and not claimed else "",
		}))


func _localized_definition_title(definition: Dictionary) -> String:
	return String(definition.get("title_pt", definition.get("title", ""))) if _language() == "pt" else String(definition.get("title", ""))


func _localized_achievement_name(achievement: Dictionary) -> String:
	return String(achievement.get("name_pt", achievement.get("name", ""))) if _language() == "pt" else String(achievement.get("name", ""))


func _localized_achievement_desc(achievement: Dictionary) -> String:
	return String(achievement.get("desc_pt", achievement.get("desc", ""))) if _language() == "pt" else String(achievement.get("desc", ""))


func _handle_action(action: String) -> void:
	if action.is_empty():
		return
	var result := { "ok": false, "text": "" }
	if action.begins_with("open:"):
		result = GameState.open_chest(action.trim_prefix("open:"))
	elif action.begins_with("mission:"):
		result = GameState.claim_daily_mission(action.trim_prefix("mission:"))
	elif action.begins_with("achievement:"):
		result = GameState.claim_achievement(action.trim_prefix("achievement:"))
	elif action.begins_with("event:"):
		result = GameState.claim_weekly_event_reward(action.trim_prefix("event:"))
	elif action == "daily_claim":
		result = GameState.claim_daily_reward()
	elif action == "wheel_free":
		result = GameState.spin_wheel("free")
		if bool(result.get("ok", false)):
			_animate_wheel(Dictionary(result.get("reward", {})))
			await get_tree().create_timer(2.25).timeout
	elif action == "wheel_ad":
		result = GameState.spin_wheel("ad")
		if bool(result.get("ok", false)):
			_animate_wheel(Dictionary(result.get("reward", {})))
			await get_tree().create_timer(2.25).timeout
	else:
		result = GameState.shop_claim(action)
	_play_sfx("res://assets/sounds/button_confirm.mp3" if bool(result.get("ok", false)) else "res://assets/sounds/button_error.mp3")
	_rebuild_current()
	if bool(result.get("ok", false)):
		_show_reward_modal(result)
	_show_feedback(_failure_label(String(result.get("reason", result.get("text", "not_ready")))) if not bool(result.get("ok", false)) else String(result.get("text", "")), bool(result.get("ok", false)))


func _rebuild_current() -> void:
	for child in get_children():
		child.queue_free()
	_build_background()
	_build_screen()


func _show_feedback(text: String, ok: bool) -> void:
	if _feedback_label:
		_feedback_label.text = text
		_feedback_label.add_theme_color_override("font_color", Color("#00ff88") if ok else Color("#ff6b9a"))


func _show_reward_modal(result: Dictionary) -> void:
	if _reward_overlay:
		_reward_overlay.queue_free()
	var reward: Dictionary = result.get("reward", {})
	_reward_overlay = Control.new()
	_fill(_reward_overlay)
	_reward_overlay.z_index = 140
	add_child(_reward_overlay)
	var dim := ColorRect.new()
	_fill(dim)
	dim.color = Color("#02010acc")
	_reward_overlay.add_child(dim)
	var center := CenterContainer.new()
	_fill(center)
	center.offset_left = 20
	center.offset_right = -20
	_reward_overlay.add_child(center)
	var card := _make_card("#16003bee", "#00f0ffaa")
	card.custom_minimum_size = Vector2(300, 260)
	center.add_child(card)
	var body := _card_body(card, 18)
	body.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(_make_label(_tr("reward_obtained").to_upper(), 22, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	var reward_icon := _make_reward_visual(reward)
	body.add_child(reward_icon)
	body.add_child(_make_label(_reward_label(reward), 20, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	if String(reward.get("type", "")) == "skin" or reward.has("converted_from_skin"):
		body.add_child(_make_label(_skin_reward_status(reward), 13, _skin_reward_color(reward), _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	var detail := _make_label(String(result.get("text", "")), 13, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_CENTER)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(detail)
	var close := _make_action_button(_tr("continue"), "#00f0ff")
	close.custom_minimum_size = Vector2(180, 46)
	close.pressed.connect(func() -> void:
		if _reward_overlay:
			_reward_overlay.queue_free()
			_reward_overlay = null
	)
	body.add_child(close)
	if _is_diamond_reward(reward):
		_play_sfx("res://assets/sounds/diamond_gain.mp3")
		_flash_reward_diamonds(card)


func _play_sfx(path: String) -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx(path, -6.0)


func _language() -> String:
	return String(GameState.get_setting("language", "en"))


func _tr(key: String, fallback := "") -> String:
	if has_node("/root/LocalizationManager"):
		return LocalizationManager.tr_key(key, fallback)
	return fallback if not fallback.is_empty() else key


func _button_text(key: String) -> String:
	var normalized := key.to_lower().replace(" ", "_")
	match normalized:
		"comprar", "buy":
			return _tr("buy")
		"abrir", "open":
			return _tr("open")
		"coletar", "claim", "resgatar":
			return _tr("claim")
		"concluído", "concluido", "done", "ok":
			return _tr("done")
		"usado", "used":
			return _tr("used")
		"ver_anúncio", "ver_anuncio", "watch_ad":
			return _tr("watch_ad")
		"girar", "spin":
			return _tr("spin")
		"ir", "go":
			return _tr("go")
		"wait", "aguardar":
			return _tr("wait")
		"locked", "bloqueado":
			return _tr("locked")
		"free", "grátis", "gratis":
			return _tr("free")
	return key


func _failure_label(reason: String) -> String:
	match reason:
		"coins", "diamonds", "keys", "legendary_key":
			return _tr("insufficient")
		"free_used":
			return _tr("used")
		"ad_limit":
			return _tr("unavailable")
		"empty":
			return _tr("inventory_empty")
	return reason


func _screen_title() -> String:
	if _language() == "pt":
		match screen_id:
			"shop": return "LOJA"
			"inventory": return "INVENTÁRIO"
			"missions": return "MISSÕES"
			"event": return "EVENTO"
			"wheel": return "ROLETA"
			"daily_reward": return "RECOMPENSA DIÁRIA"
			"boss": return "BOSS"
			"league": return "LIGA NEON"
			"achievements": return "CONQUISTAS"
	else:
		match screen_id:
			"shop": return "SHOP"
			"inventory": return "INVENTORY"
			"missions": return "MISSIONS"
			"event": return "EVENT"
			"wheel": return "WHEEL"
			"daily_reward": return "DAILY REWARD"
			"boss": return "BOSS"
			"league": return "NEON LEAGUE"
			"achievements": return "ACHIEVEMENTS"
	return String(SCREEN_DATA.get(screen_id, {}).get("title", screen_id)).to_upper()


func _shop_tab_label(id: String, fallback: String) -> String:
	if _language() == "pt":
		match id:
			"chests": return _tr("chests")
			"gems": return _tr("diamonds")
			"keys": return _tr("keys")
			"specials": return _tr("rewards")
			"free": return _tr("free_chest")
		return fallback
	match id:
		"chests": return "Chests"
		"gems": return "Diamonds"
		"keys": return "Keys"
		"specials": return "Rewards"
		"free": return "Free Chest"
	return fallback


func _shop_section_label(id: String, fallback: String) -> String:
	if _language() == "en":
		match id:
			"chests": return "BUY CHESTS"
			"gems": return "DIAMOND PACKS"
			"keys": return "KEYS"
			"specials": return "SPECIAL OFFERS"
			"free": return "FREE REWARDS"
		return fallback
	match id:
		"chests": return "COMPRAR BAÚS"
		"gems": return "PACOTES DE DIAMANTES"
		"keys": return "CHAVES"
		"specials": return "OFERTAS ESPECIAIS"
		"free": return "RECOMPENSAS GRÁTIS"
	return fallback


func _make_wheel_visual(data: Dictionary) -> PanelContainer:
	var card := _make_card("#ffffff10", String(data["accent"]) + "88")
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	card.add_child(margin)
	var center := CenterContainer.new()
	margin.add_child(center)
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(248, 248)
	center.add_child(holder)
	_wheel_prize_ring = Control.new()
	_wheel_prize_ring.position = Vector2(124, 124)
	holder.add_child(_wheel_prize_ring)
	for i in range(_wheel_prizes.size()):
		var angle := -PI / 2.0 + i * TAU / float(_wheel_prizes.size())
		var segment := PanelContainer.new()
		segment.custom_minimum_size = Vector2(58, 58)
		segment.position = Vector2(cos(angle), sin(angle)) * 84.0 - Vector2(29, 29)
		segment.add_theme_stylebox_override("panel", _make_style("#00f0ff22" if i % 2 == 0 else "#ffd70022", 18, "#ffffff55", 1, "#00f0ff55", 6))
		_wheel_prize_ring.add_child(segment)
		var segment_center := CenterContainer.new()
		segment.add_child(segment_center)
		segment_center.add_child(_make_icon(_wheel_prizes[i], 30))
	var hub := PanelContainer.new()
	hub.custom_minimum_size = Vector2(98, 98)
	hub.position = Vector2(75, 75)
	hub.add_theme_stylebox_override("panel", _make_style("#16003b", 49, "#00f0ff", 3, "#00f0ffaa", 14))
	holder.add_child(hub)
	var hub_center := CenterContainer.new()
	hub.add_child(hub_center)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 2)
	hub_center.add_child(column)
	column.add_child(_make_icon("wheel", 34))
	column.add_child(_make_label(_tr("spin").to_upper(), 14, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	var pointer_glow := Polygon2D.new()
	pointer_glow.polygon = PackedVector2Array([Vector2(0, 0), Vector2(38, 0), Vector2(19, 42)])
	pointer_glow.color = Color("#ff005566")
	pointer_glow.position = Vector2(105, -12)
	holder.add_child(pointer_glow)
	var pointer := Polygon2D.new()
	pointer.polygon = PackedVector2Array([Vector2(0, 0), Vector2(30, 0), Vector2(15, 34)])
	pointer.color = Color("#ffd700")
	pointer.position = Vector2(109, -8)
	holder.add_child(pointer)
	return card


func _animate_wheel(reward: Dictionary = {}) -> void:
	if not _wheel_prize_ring:
		return
	var tween := create_tween()
	var prize_key := _wheel_prize_key(reward)
	var slot_index: int = max(0, _wheel_prizes.find(prize_key))
	var slot_angle: float = -PI / 2.0 + float(slot_index) * TAU / float(_wheel_prizes.size())
	var target_mod: float = fposmod(-PI / 2.0 - slot_angle, TAU)
	var current_mod: float = fposmod(_wheel_prize_ring.rotation, TAU)
	var delta: float = fposmod(target_mod - current_mod, TAU)
	var target_rotation := _wheel_prize_ring.rotation + TAU * 7.0 + delta
	tween.tween_property(_wheel_prize_ring, "rotation", target_rotation, 2.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


func _wheel_prize_key(reward: Dictionary) -> String:
	match String(reward.get("type", "")):
		"coins":
			return "coin"
		"diamonds", "gems":
			return "gem"
		"keys", "legendary_key", "legendaryKeys":
			return "key"
		"chest":
			return "chest_%s" % String(reward.get("chest_type", "common"))
		"skin":
			return "skins"
	return "coin"


func _make_price_badge(price: String, icon_key: String) -> Control:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 4)
	if not icon_key.is_empty():
		row.add_child(_make_icon(icon_key, 16))
	row.add_child(_make_label(price, 12, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	return row


func _reward_icon(reward: Dictionary) -> String:
	match String(reward.get("type", "")):
		"coins":
			return "coin"
		"diamonds", "gems":
			return "gem"
		"keys":
			return "key"
		"legendaryKeys", "legendary_keys":
			return "chest_legendary"
		"chest":
			return "chest_%s" % String(reward.get("chest_type", reward.get("chestType", "common")))
		"skin":
			return "skins"
	return "coin"


func _make_reward_visual(reward: Dictionary) -> Control:
	if String(reward.get("type", "")) == "skin":
		var skin_id := String(reward.get("skin_id", reward.get("skinId", "")))
		return _make_skin_preview(skin_id, 90)
	return _make_icon(_reward_icon(reward), 72)


func _make_skin_preview(skin_id: String, preview_size: int) -> TextureRect:
	var icon := TextureRect.new()
	var path := "res://assets/skins/%s.png" % skin_id
	if not ResourceLoader.exists(path):
		path = "res://assets/skins/neon_blue.png"
	if ResourceLoader.exists(path):
		icon.texture = load(path)
	icon.custom_minimum_size = Vector2(preview_size, preview_size)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon


func _reward_label(reward: Dictionary) -> String:
	var amount := int(reward.get("amount", 1))
	match String(reward.get("type", "")):
		"coins":
			return "+%s %s" % [amount, "coins" if _language() == "en" else "moedas"]
		"diamonds", "gems":
			return "+%s %s" % [amount, _tr("diamonds")]
		"keys":
			return "+%s %s" % [amount, _tr("keys")]
		"legendaryKeys", "legendary_keys":
			return "+%s %s" % [amount, "legendary keys" if _language() == "en" else "chaves lendárias"]
		"xp", "profileXp", "profile_xp":
			return "+%s XP" % amount
		"chest":
			var chest_type := String(reward.get("chest_type", reward.get("chestType", "common"))).capitalize()
			return "+%s %s %s" % [amount, chest_type, "Chest" if _language() == "en" else "Baú"]
		"skin":
			var skin_id := String(reward.get("skin_id", reward.get("skinId", "")))
			var skin := MainPortData.skin_by_id(skin_id) if has_node("/root/MainPortData") else {}
			return String(skin.get("name", skin_id))
	return String(reward.get("type", "Reward"))


func _skin_reward_status(reward: Dictionary) -> String:
	if reward.has("converted_from_skin"):
		return "Duplicate skin • Converted to diamonds" if _language() == "en" else "Skin repetida • Convertida em diamantes"
	var rarity := String(reward.get("rarity", "common")).capitalize()
	return "%s • %s" % ["New skin unlocked" if _language() == "en" else "Nova skin desbloqueada", rarity]


func _skin_reward_color(reward: Dictionary) -> String:
	var rarity := String(reward.get("rarity", "common"))
	if reward.has("converted_from_skin"):
		rarity = "rare"
	match rarity:
		"rare":
			return "#00aaff"
		"epic":
			return "#b000ff"
		"legendary":
			return "#ffd700"
		"mythic", "ultimate":
			return "#ff00aa"
	return "#ffffffaa"


func _is_diamond_reward(reward: Dictionary) -> bool:
	if reward.has("converted_from_skin"):
		return true
	if String(reward.get("type", "")) in ["diamonds", "gems"]:
		return true
	if String(reward.get("type", "")) == "skin":
		return String(reward.get("rarity", "common")) != "common"
	return false


func _flash_reward_diamonds(card: Control) -> void:
	for i in range(9):
		var sparkle := _make_icon("gem", 18)
		sparkle.modulate = Color("#c084fc")
		sparkle.position = Vector2(randf_range(30.0, 250.0), randf_range(40.0, 210.0))
		card.add_child(sparkle)
		var tween := create_tween()
		tween.tween_property(sparkle, "modulate:a", 0.0, 0.75)
		tween.parallel().tween_property(sparkle, "position", sparkle.position + Vector2(randf_range(-14.0, 14.0), randf_range(-38.0, -16.0)), 0.75)
		tween.tween_callback(sparkle.queue_free)


func _format_remaining(seconds: int) -> String:
	var safe_seconds: int = maxi(0, seconds)
	var days := floori(float(safe_seconds) / 86400.0)
	var hours := floori(float(safe_seconds % 86400) / 3600.0)
	var minutes := floori(float(safe_seconds % 3600) / 60.0)
	if days > 0:
		return "%sd %02dh" % [days, hours]
	if hours > 0:
		return "%02dh %02dm" % [hours, minutes]
	return "%02dm" % minutes


func _seconds_until_next_day() -> int:
	var now := Time.get_unix_time_from_system()
	var date := Time.get_datetime_dict_from_system()
	var next_day := Time.get_unix_time_from_datetime_dict({
		"year": int(date.year),
		"month": int(date.month),
		"day": int(date.day) + 1,
		"hour": 0,
		"minute": 0,
		"second": 0,
	})
	return max(0, int(next_day) - int(now))


func _seconds_until_next_month() -> int:
	var now := Time.get_unix_time_from_system()
	var date := Time.get_datetime_dict_from_system()
	var month := int(date.month) + 1
	var year := int(date.year)
	if month > 12:
		month = 1
		year += 1
	var next_month := Time.get_unix_time_from_datetime_dict({
		"year": year,
		"month": month,
		"day": 1,
		"hour": 0,
		"minute": 0,
		"second": 0,
	})
	return max(0, int(next_month) - int(now))


func _make_progress_bar(progress: float, tone: String) -> PanelContainer:
	var shell := PanelContainer.new()
	shell.custom_minimum_size.y = 12
	shell.add_theme_stylebox_override("panel", _make_style("#ffffff22", 6))
	var fill := ColorRect.new()
	fill.color = Color(tone)
	fill.anchor_right = clamp(progress, 0.0, 1.0)
	fill.anchor_bottom = 1.0
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(fill)
	return shell


func _make_action_button(text: String, tone: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(94, 42)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	button.text = text
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", Color("#001018"))
	_apply_button_style(button, _make_style(tone, 10, "#00000000", 0, tone + "88", 8))
	return button


func _make_card(bg: String = "#ffffff12", border: String = "#ffffff22") -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_theme_stylebox_override("panel", _make_style(bg, 12, border, 1))
	return card


func _card_body(card: PanelContainer, padding: int) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", padding)
	margin.add_theme_constant_override("margin_top", padding)
	margin.add_theme_constant_override("margin_right", padding)
	margin.add_theme_constant_override("margin_bottom", padding)
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_child(margin)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	body.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_child(body)
	return body


func _make_icon(key: String, icon_size: int, tint: Color = Color.WHITE) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = load(ICON_PATHS.get(key, ICON_PATHS["coin"]))
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
	return label


func _make_flat_button(text: String, color: String, size: int) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", size)
	button.add_theme_color_override("font_color", Color(color))
	_apply_button_style(button, _make_style("#00000000", 0))
	return button


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


func _spacer(height: float) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = height
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer


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
	get_tree().change_scene_to_file(MENU_SCENE)


func _configure_scroll(scroll: ScrollContainer) -> void:
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.follow_focus = true
	scroll.scroll_deadzone = 6
	scroll.mouse_filter = Control.MOUSE_FILTER_PASS


func _is_narrow_screen() -> bool:
	return get_viewport_rect().size.x <= 430.0

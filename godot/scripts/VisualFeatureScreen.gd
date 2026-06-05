extends Control

@export var screen_id := "shop"

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const GAME_SCENE := "res://scenes/GameScene.tscn"
const BATTLE_SCENE := "res://scenes/LeagueBattle.tscn"
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
		"empty_desc": "missions_empty_desc",
		"cards": [],
	},
	"event": {
		"title": "EVENTO",
		"icon": "event",
		"accent": "#00ff88",
		"empty_title": "Nenhum evento ativo",
		"empty_desc": "event_empty_desc",
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
		_content.add_child(_make_section_title(_txt("STORED CHESTS", "BAÚS GUARDADOS", "COFRES GUARDADOS", "保存された宝箱", "已保存宝箱")))
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
		_content.add_child(_make_empty_state(_dynamic_empty_title(data), _dynamic_empty_desc(data), String(data["icon"])))
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


func _make_shop_tabs() -> ScrollContainer:
	var scroller := ScrollContainer.new()
	scroller.custom_minimum_size.y = 46
	scroller.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroller.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroller.follow_focus = true
	scroller.scroll_deadzone = 2
	scroller.mouse_filter = Control.MOUSE_FILTER_STOP
	var tabs := HBoxContainer.new()
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.mouse_filter = Control.MOUSE_FILTER_PASS
	tabs.add_theme_constant_override("separation", 6)
	scroller.add_child(tabs)
	_shop_tab_buttons.clear()
	for tab in SHOP_TABS:
		tabs.add_child(_make_shop_tab_button(tab))
	return scroller


func _make_shop_tab_button(tab: Dictionary) -> Button:
	var active := String(tab["id"]) == _shop_tab
	var button := Button.new()
	button.text = _shop_tab_label(String(tab["id"]), String(tab["label"]))
	button.custom_minimum_size = Vector2(112 if _is_narrow_screen() else 132, 42)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 11)
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
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
		return _txt("Boss available", "Boss disponível", "Boss disponible", "ボス挑戦可能", "Boss可挑战") if TimeManager.is_boss_available() else _txt("No boss available", "Nenhum boss disponível", "No hay Boss disponible", "利用可能なボスはいません", "暂无可挑战Boss")
	if screen_id == "daily_reward":
		return _txt("Reward available", "Recompensa disponível", "Recompensa disponible", "報酬を受け取れます", "奖励可领取") if TimeManager.can_claim_daily_reward() else _txt("Daily reward already claimed", "Recompensa diária já coletada", "Recompensa diaria ya cobrada", "デイリー報酬は受け取り済み", "每日奖励已领取")
	if screen_id == "event":
		return _txt("No active event", "Nenhum evento ativo", "No hay evento activo", "開催中のイベントはありません", "暂无活动")
	if screen_id == "achievements":
		return _txt("No achievements unlocked", "Nenhuma conquista desbloqueada", "Ningún logro desbloqueado", "解除済み実績はありません", "暂无已解锁成就")
	return _phrase(String(data["empty_title"]))


func _dynamic_empty_desc(data: Dictionary) -> String:
	var raw := String(data.get("empty_desc", ""))
	if raw.is_empty():
		match screen_id:
			"missions":
				return _tr("missions_empty_desc")
			"event":
				return _tr("event_empty_desc")
			"boss":
				return _txt("Boss battles refresh with the internal clock.", "Batalhas de Boss atualizam com o relógio interno.", "Las batallas de Boss se actualizan con el reloj interno.", "ボス戦は内部時計で更新されます。", "Boss战斗会根据内部时钟刷新。")
		return ""
	if raw.find(" ") == -1:
		return _tr(raw, raw)
	return _phrase(raw)


func _make_feature_card(data: Dictionary) -> PanelContainer:
	var tone := String(data.get("tone", "#00f0ff"))
	var card := _make_card("#ffffff12", tone + "77")
	card.custom_minimum_size.y = 122 if _is_narrow_screen() else 96
	var body := _card_body(card, 12)

	var title_text := _phrase(String(data.get("title", ""))).strip_edges()
	if title_text.is_empty():
		title_text = _tr("unavailable", "Indisponível")
	var desc_text := _phrase(String(data.get("desc", ""))).strip_edges()
	if desc_text.is_empty():
		desc_text = _txt("Information will appear here.", "As informações aparecerão aqui.", "La información aparecerá aquí.", "情報はここに表示されます。", "信息会显示在这里。")
	var title := _make_label(title_text, 17 if _is_narrow_screen() else 18, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var desc := _make_label(desc_text, 12, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var button := _make_action_button(_button_text(String(data.get("button", "view"))), tone)
	button.disabled = bool(data.get("disabled", false))
	if data.has("action"):
		button.pressed.connect(_handle_action.bind(String(data["action"])))
	if _is_narrow_screen():
		var top := HBoxContainer.new()
		top.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top.add_theme_constant_override("separation", 10)
		top.mouse_filter = Control.MOUSE_FILTER_PASS
		body.add_child(top)
		top.add_child(_make_icon(String(data.get("icon", "coin")), 38))
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.custom_minimum_size.x = 210
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
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 12)
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		body.add_child(row)
		row.add_child(_make_icon(String(data.get("icon", "coin")), 46))
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.custom_minimum_size.x = 220
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
	_content.add_child(_make_section_title(_txt("7 DAY STREAK", "SEQUÊNCIA DE 7 DIAS", "RACHA DE 7 DÍAS", "7日連続", "7天连续")))
	for i in range(data["cards"].size()):
		var card: Dictionary = data["cards"][i].duplicate()
		card["title"] = _txt("Day %s", "Dia %s", "Día %s", "%s日目", "第%s天") % (i + 1)
		card["desc"] = _daily_streak_reward_description(i)
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
	_content.add_child(_make_section_title(_txt("TODAY'S CHALLENGE", "DESAFIO DE HOJE", "DESAFÍO DE HOY", "今日のチャレンジ", "今日挑战")))
	_populate_daily_challenge()
	_content.add_child(_make_section_title(_txt("WEEKLY GOALS", "OBJETIVOS DA SEMANA", "OBJETIVOS SEMANALES", "週間目標", "每周目标")))
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
	_content.add_child(_make_section_title(_txt("FINAL REWARD", "RECOMPENSA FINAL", "RECOMPENSA FINAL", "最終報酬", "最终奖励")))
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


func _populate_daily_challenge() -> void:
	var challenge: Dictionary = GameState.get_daily_challenge()
	var completed := bool(challenge.get("completed", false))
	var claimed := bool(challenge.get("claimed", false))
	var status := _txt("Completed", "Coletado", "Completado", "完了", "已完成") if claimed else _txt("Reward available", "Disponível para coletar", "Recompensa disponible", "報酬受取可能", "奖励可领取") if completed else _txt("Available", "Disponível", "Disponible", "利用可能", "可用")
	var desc := "%s: %s • %s: %s • %s: %s\n%s: %s • %s: %s • %s: %s" % [
		_tr("date", "Data"), String(challenge.get("date", "")),
		_tr("difficulty", "Dificuldade"), String(challenge.get("difficulty_label", "")),
		_tr("seed", "Seed"), String(challenge.get("seed", "")),
		_tr("best_score", "Melhor pontuação"), int(challenge.get("best_score", 0)),
		_tr("reward", "Recompensa"), _daily_reward_label(Dictionary(challenge.get("reward", {}))),
		_tr("time_until_reset", "Tempo até resetar"), _format_remaining(int(challenge.get("seconds_until_reset", 0))),
	]
	_content.add_child(_make_feature_card({
		"title": _tr("daily_challenge", "Desafio Diário"),
		"desc": desc,
		"icon": "event",
		"button": "play",
		"tone": "#00ff88",
		"progress": float(int(challenge.get("best_rings", 0))) / max(1.0, float(int(challenge.get("objective_rings", 30)))),
		"action": "daily_challenge_start",
	}))
	_content.add_child(_make_feature_card({
		"title": _tr("today_challenge_status", "Status do desafio"),
		"desc": "%s • %s/%s %s • %ss" % [status, int(challenge.get("best_rings", 0)), int(challenge.get("objective_rings", 30)), _txt("rings", "anéis", "anillos", "リング", "圆环"), int(challenge.get("duration", 90))],
		"icon": "chest_rare" if completed and not claimed else "gem",
		"button": "claim" if completed and not claimed else "done" if claimed else "locked",
		"tone": "#ffd700",
		"action": "daily_challenge_claim" if completed and not claimed else "",
		"disabled": not completed or claimed,
	}))
	if completed and not claimed:
		_content.add_child(_make_feature_card({
			"title": _tr("double_reward", "Dobrar recompensa"),
			"desc": _tr("double_reward_desc", "Assista um anúncio de teste para coletar a recompensa diária em dobro."),
			"icon": "wheel",
			"button": "watch_ad",
			"tone": "#00f0ff",
			"action": "daily_challenge_claim_ad",
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
	copy.add_child(_make_label(_txt("Ends in %s", "Termina em %s", "Termina en %s", "終了まで %s", "剩余 %s") % _format_remaining(int(event.get("seconds_remaining", 0))), 13, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	return card


func _populate_boss() -> void:
	var boss := _current_boss_data()
	_content.add_child(_make_boss_header(boss))
	_content.add_child(_make_feature_card({
		"title": _txt("Daily attempts", "Tentativas diárias", "Intentos diarios", "デイリー挑戦", "每日挑战次数"),
		"desc": _txt("Each difficulty can be attempted once per day. Battle uses two arenas like Neon League: Boss above, you below.", "Cada dificuldade pode ser enfrentada uma vez por dia. A batalha usa duas arenas como a Liga Neon: Boss em cima, você embaixo.", "Cada dificultad se puede intentar una vez al día. La batalla usa dos arenas como Liga Neon: Boss arriba, tú abajo.", "各難易度は1日1回挑戦できます。ネオンリーグ同様、上がボス、下があなたの2アリーナです。", "每个难度每天可挑战一次。战斗使用类似霓虹联赛的双竞技场：Boss在上，你在下。"),
		"icon": "boss",
		"button": "done",
		"tone": "#ff8800",
		"disabled": true,
	}))
	_content.add_child(_make_section_title(_txt("BOSS LEVELS", "NÍVEIS DO BOSS", "NIVELES DE BOSS", "ボスレベル", "Boss等级")))
	var unlocked := int(GameState.data.get("max_unlocked_phase", 1)) >= 5 or int(GameState.data.get("level", 1)) >= 5
	for level_data in _boss_level_data():
		var card := Dictionary(level_data).duplicate(true)
		var level_id := String(card.get("id", "normal"))
		var available := unlocked and GameState.can_start_boss_level(level_id)
		card["disabled"] = not available
		card["button"] = "battle" if available else "used" if unlocked else "locked"
		card["action"] = "boss_start:%s" % level_id if available else ""
		card["desc"] = "%s • %s" % [String(card.get("desc", "")), _reward_label(Dictionary(card.get("reward", {})))]
		_content.add_child(_make_feature_card(card))


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
	copy.add_child(_make_label(_txt("MONTHLY BOSS", "BOSS MENSAL", "BOSS MENSUAL", "月間ボス", "月度Boss"), 12, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	copy.add_child(_make_label(String(boss.get("name", "Fênix Solar")).to_upper(), 22, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	var desc := _make_label(String(boss.get("desc", "")), 13, "#ffffffbb", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.add_child(desc)
	copy.add_child(_make_label(_txt("Passive: %s", "Passiva: %s", "Pasiva: %s", "パッシブ: %s", "被动：%s") % String(boss.get("passive", "")), 12, "#ffcc66", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	copy.add_child(_make_label(_txt("Daily reset: %s • Monthly reset: %s", "Reset diário: %s • Reset mensal: %s", "Reset diario: %s • Reset mensual: %s", "日次リセット: %s • 月次リセット: %s", "每日重置：%s • 每月重置：%s") % [_format_remaining(_seconds_until_next_day()), _format_remaining(_seconds_until_next_month())], 11, "#ffffff99", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	return card


func _current_boss_data() -> Dictionary:
	var month := int(Time.get_datetime_dict_from_system().get("month", 6))
	match month:
		6:
			return { "name": _txt("Solar Phoenix", "Fênix Solar", "Fénix Solar", "太陽フェニックス", "太阳凤凰"), "skin": "neon_phoenix", "desc": _txt("A Boss that is reborn in solid rings.", "Um Boss que renasce em anéis sólidos.", "Un Boss que renace en anillos sólidos.", "固いリングの中で蘇るボス。", "会在实体圆环中重生的Boss。"), "passive": _txt("Solid breaks give the Boss more coins.", "Quebras sólidas dão mais moedas ao Boss.", "Las roturas sólidas dan más monedas al Boss.", "ソリッド破壊でボスのコインが増える。", "实体破坏会让Boss获得更多金币。") }
		7:
			return { "name": _txt("Astral Dragon", "Dragão Astral", "Dragón Astral", "星界ドラゴン", "星界巨龙"), "skin": "astral_dragon", "desc": _txt("Pressures the arena with orbital rings.", "Pressiona a arena com anéis orbitais.", "Presiona la arena con anillos orbitales.", "軌道リングでアリーナに圧力をかける。", "用轨道圆环压迫竞技场。"), "passive": _txt("The higher the combo, the faster the rotation.", "Quanto maior o combo, maior a rotação.", "Cuanto mayor el combo, mayor la rotación.", "コンボが高いほど回転が速くなる。", "连击越高，旋转越快。") }
		8:
			return { "name": _txt("Dimensional Guardian", "Guardião Dimensional", "Guardián Dimensional", "次元ガーディアン", "次元守卫"), "skin": "dimensional_guardian", "desc": _txt("Alternates phase and repulse patterns.", "Alterna padrões de fase e repulsão.", "Alterna patrones de fase y repulsión.", "位相と反発パターンを切り替える。", "交替使用相位和排斥模式。"), "passive": _txt("The arena changes rhythm in cycles.", "A arena muda de ritmo em ciclos.", "La arena cambia de ritmo en ciclos.", "アリーナが周期的にリズムを変える。", "竞技场会周期性改变节奏。") }
	return { "name": _txt("Solar Phoenix", "Fênix Solar", "Fénix Solar", "太陽フェニックス", "太阳凤凰"), "skin": "neon_phoenix", "desc": _txt("A Boss that is reborn in solid rings.", "Um Boss que renasce em anéis sólidos.", "Un Boss que renace en anillos sólidos.", "固いリングの中で蘇るボス。", "会在实体圆环中重生的Boss。"), "passive": _txt("Solid breaks give the Boss more coins.", "Quebras sólidas dão mais moedas ao Boss.", "Las roturas sólidas dan más monedas al Boss.", "ソリッド破壊でボスのコインが増える。", "实体破坏会让Boss获得更多金币。") }


func _boss_level_data() -> Array[Dictionary]:
	return [
		{ "id": "normal", "title": _txt("Normal", "Normal", "Normal", "ノーマル", "普通"), "desc": _txt("Daily Boss entry", "Entrada diária do Boss", "Entrada diaria del Boss", "デイリーボス入門", "每日Boss入门"), "icon": "boss", "tone": "#00f0ff", "reward": { "type": "coins", "amount": 220 } },
		{ "id": "strong", "title": _txt("Strong", "Forte", "Fuerte", "強い", "强力"), "desc": _txt("Boss with higher rotation", "Boss com rotação elevada", "Boss con rotación elevada", "回転が速いボス", "旋转更快的Boss"), "icon": "boss", "tone": "#00ff88", "reward": { "type": "diamonds", "amount": 8 } },
		{ "id": "elite", "title": _txt("Elite", "Elite", "Élite", "エリート", "精英"), "desc": _txt("More aggressive arena", "Arena mais agressiva", "Arena más agresiva", "より攻撃的なアリーナ", "更激烈的竞技场"), "icon": "boss", "tone": "#b000ff", "reward": { "type": "keys", "amount": 1 } },
		{ "id": "legendary", "title": _txt("Legendary", "Lendário", "Legendario", "レジェンド", "传奇"), "desc": _txt("Rare reward and special chest", "Recompensa rara e baú especial", "Recompensa rara y cofre especial", "レア報酬と特別な宝箱", "稀有奖励和特殊宝箱"), "icon": "boss", "tone": "#ffd700", "reward": { "type": "chest", "chest_type": "rare", "amount": 1 } },
		{ "id": "impossible", "title": _txt("Impossible", "Impossível", "Imposible", "不可能", "不可能"), "desc": _txt("Maximum visual challenge", "Desafio visual máximo", "Desafío visual máximo", "最大級のビジュアルチャレンジ", "最高视觉挑战"), "icon": "boss", "tone": "#ff0055", "reward": { "type": "chest", "chest_type": "epic", "amount": 1 } },
	]


func _populate_missions() -> void:
	GameState._ensure_live_systems()
	var daily: Dictionary = GameState.data.get("daily_missions", {})
	var added := 0
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
		added += 1
	if added == 0:
		_content.add_child(_make_empty_state(_dynamic_empty_title(SCREEN_DATA["missions"]), _tr("missions_empty_desc"), "missions"))


func _populate_achievements() -> void:
	GameState._update_achievements(false)
	var pending_claims := 0
	for achievement in GameState.get_achievements():
		var state: Dictionary = GameState.data.get("achievements", {}).get(String(achievement.get("id", "")), {})
		if bool(state.get("completed", false)) and not bool(state.get("claimed", false)):
			pending_claims += 1
	_content.add_child(_make_feature_card({
		"title": _tr("claim_all"),
		"desc": (_txt("%s achievement reward(s) ready to claim.", "%s conquista(s) prontas para coletar.", "%s recompensa(s) de logro listas para cobrar.", "%s個の実績報酬を受け取れます。", "%s个成就奖励可领取。") % pending_claims) if pending_claims > 0 else _txt("No pending achievements.", "Nenhuma conquista pendente.", "No hay logros pendientes.", "保留中の実績はありません。", "没有待领取成就。"),
		"icon": "achievements",
		"button": "claim" if pending_claims > 0 else "done",
		"tone": "#ffd700",
		"action": "achievement_all" if pending_claims > 0 else "",
		"disabled": pending_claims <= 0,
	}))
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
	if _language() == "pt":
		return String(definition.get("title_pt", definition.get("title", "")))
	return _phrase(String(definition.get("title", "")))


func _localized_achievement_name(achievement: Dictionary) -> String:
	return LocalizationManager.achievement_name(achievement) if has_node("/root/LocalizationManager") else String(achievement.get("name", ""))


func _localized_achievement_desc(achievement: Dictionary) -> String:
	return LocalizationManager.achievement_desc(achievement) if has_node("/root/LocalizationManager") else String(achievement.get("desc", ""))


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
	elif action == "achievement_all":
		result = GameState.claim_all_achievements()
	elif action.begins_with("event:"):
		result = GameState.claim_weekly_event_reward(action.trim_prefix("event:"))
	elif action == "daily_challenge_start":
		result = GameState.start_daily_challenge()
		if bool(result.get("ok", false)):
			_play_sfx("res://assets/sounds/button_confirm.mp3")
			get_tree().change_scene_to_file(GAME_SCENE)
			return
	elif action == "daily_challenge_claim":
		result = GameState.claim_daily_challenge_reward(false)
	elif action == "daily_challenge_claim_ad":
		AdManager.show_rewarded_ad("daily_bonus", func(ok: bool) -> void:
			if ok:
				_complete_rewarded_action(action)
			else:
				_show_feedback(_tr("ad_cancelled", "Anúncio cancelado"), false)
		)
		return
	elif action.begins_with("boss_start:"):
		result = GameState.start_boss_battle(action.trim_prefix("boss_start:"))
		if bool(result.get("ok", false)):
			_play_sfx("res://assets/sounds/button_confirm.mp3")
			get_tree().change_scene_to_file(BATTLE_SCENE)
			return
	elif action == "daily_claim":
		result = GameState.claim_daily_reward()
	elif action == "wheel_free":
		result = GameState.spin_wheel("free")
		if bool(result.get("ok", false)):
			_animate_wheel(Dictionary(result.get("reward", {})))
			await get_tree().create_timer(2.25).timeout
	elif action == "wheel_ad":
		AdManager.show_rewarded_ad("wheel_extra_spin", func(ok: bool) -> void:
			if ok:
				_complete_rewarded_action(action)
			else:
				_show_feedback(_tr("ad_cancelled", "Anúncio cancelado"), false)
		)
		return
	elif _is_ad_shop_action(action):
		AdManager.show_rewarded_ad(_ad_reason_for_shop_action(action), func(ok: bool) -> void:
			if ok:
				_complete_rewarded_action(action)
			else:
				_show_feedback(_tr("ad_cancelled", "Anúncio cancelado"), false)
		)
		return
	else:
		result = GameState.shop_claim(action)
	_play_sfx("res://assets/sounds/button_confirm.mp3" if bool(result.get("ok", false)) else "res://assets/sounds/button_error.mp3")
	_rebuild_current()
	if bool(result.get("ok", false)):
		_show_reward_modal(result)
	_show_feedback(_failure_label(String(result.get("reason", result.get("text", "not_ready")))) if not bool(result.get("ok", false)) else String(result.get("text", "")), bool(result.get("ok", false)))


func _complete_rewarded_action(action: String) -> void:
	call_deferred("_complete_rewarded_action_async", action)


func _complete_rewarded_action_async(action: String) -> void:
	var result := { "ok": false, "text": "" }
	if action == "wheel_ad":
		result = GameState.spin_wheel("ad")
		if bool(result.get("ok", false)):
			_animate_wheel(Dictionary(result.get("reward", {})))
			await get_tree().create_timer(2.25).timeout
	elif action == "daily_challenge_claim_ad":
		result = GameState.claim_daily_challenge_reward(true)
	else:
		result = GameState.shop_claim(action)
	_play_sfx("res://assets/sounds/button_confirm.mp3" if bool(result.get("ok", false)) else "res://assets/sounds/button_error.mp3")
	_rebuild_current()
	if bool(result.get("ok", false)):
		_show_reward_modal(result)
	_show_feedback(_failure_label(String(result.get("reason", result.get("text", "not_ready")))) if not bool(result.get("ok", false)) else String(result.get("text", "")), bool(result.get("ok", false)))


func _is_ad_shop_action(action: String) -> bool:
	return ["ad_gems", "ad_coins", "ad_key", "ad_chest"].has(action)


func _ad_reason_for_shop_action(action: String) -> String:
	match action:
		"ad_gems":
			return "shop_free_diamonds"
		"ad_coins":
			return "shop_free_coins"
		"ad_chest":
			return "free_chest"
	return "daily_bonus"


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
	if has_node("/root/LocalizationManager"):
		return LocalizationManager.current_language()
	return String(GameState.get_setting("language", "en"))


func _tr(key: String, fallback := "") -> String:
	if has_node("/root/LocalizationManager"):
		return LocalizationManager.tr_key(key, fallback)
	return fallback if not fallback.is_empty() else key


func _txt(en: String, pt := "", es := "", ja := "", zh := "") -> String:
	return LocalizationManager.text(en, pt, es, ja, zh) if has_node("/root/LocalizationManager") else en


func _phrase(value: String) -> String:
	match value:
		"Pacote inicial": return _txt("Starter Pack", "Pacote inicial", "Paquete inicial", "スターターパック", "新手礼包")
		"Moedas, diamantes e chaves para acelerar o começo.": return _txt("Coins, diamonds and keys to speed up the start.", "Moedas, diamantes e chaves para acelerar o começo.", "Monedas, diamantes y llaves para acelerar el inicio.", "序盤を加速するコイン、ダイヤ、鍵。", "金币、钻石和钥匙，帮助快速开局。")
		"Diamantes": return _tr("diamonds")
		"Pacote médio de diamantes para skins e baús.": return _txt("Medium diamond pack for skins and chests.", "Pacote médio de diamantes para skins e baús.", "Paquete mediano de diamantes para skins y cofres.", "スキンと宝箱用の中型ダイヤパック。", "用于皮肤和宝箱的中型钻石礼包。")
		"Baús": return _tr("chests")
		"Pacote visual com baús comum, raro e épico.": return _txt("Visual pack with common, rare and epic chests.", "Pacote visual com baús comum, raro e épico.", "Paquete visual con cofres común, raro y épico.", "コモン、レア、エピック宝箱のビジュアルパック。", "包含普通、稀有和史诗宝箱的视觉礼包。")
		"Recompensa por anúncio": return _txt("Ad Reward", "Recompensa por anúncio", "Recompensa por anuncio", "広告報酬", "广告奖励")
		"Assista um anúncio mockado para ganhar moedas.": return _txt("Watch a mock ad to earn coins.", "Assista um anúncio mockado para ganhar moedas.", "Mira un anuncio simulado para ganar monedas.", "モック広告を見てコインを獲得。", "观看模拟广告获得金币。")
		"Oferta especial": return _txt("Special Offer", "Oferta especial", "Oferta especial", "特別オファー", "特别优惠")
		"Bundle visual temporário preparado para eventos.": return _txt("Temporary visual bundle prepared for events.", "Bundle visual temporário preparado para eventos.", "Bundle visual temporal preparado para eventos.", "イベント用の一時ビジュアルバンドル。", "为活动准备的临时视觉礼包。")
		"Inventário vazio": return _tr("inventory_empty")
		"Nenhuma missão disponível": return _txt("No missions available", "Nenhuma missão disponível", "No hay misiones disponibles", "利用可能なミッションはありません", "暂无可用任务")
		"Nenhum evento ativo": return _txt("No active event", "Nenhum evento ativo", "No hay evento activo", "開催中のイベントはありません", "暂无活动")
		"Giro grátis": return _tr("free_spin")
		"1 giro visual disponível hoje.": return _txt("1 visual spin available today.", "1 giro visual disponível hoje.", "1 giro visual disponible hoy.", "本日1回のビジュアルスピンが利用可能。", "今日可进行1次视觉转盘。")
		"Prêmios": return _tr("rewards")
		"Moedas, diamantes, chaves, baús e efeitos.": return _txt("Coins, diamonds, keys, chests and effects.", "Moedas, diamantes, chaves, baús e efeitos.", "Monedas, diamantes, llaves, cofres y efectos.", "コイン、ダイヤ、鍵、宝箱、効果。", "金币、钻石、钥匙、宝箱和效果。")
		"Nenhum boss disponível": return _txt("No boss available", "Nenhum boss disponível", "No hay Boss disponible", "利用可能なボスはいません", "暂无可挑战Boss")
		"Liga indisponível": return _txt("League unavailable", "Liga indisponível", "Liga no disponible", "リーグ利用不可", "联赛不可用")
		"Nenhuma conquista desbloqueada": return _txt("No achievement unlocked", "Nenhuma conquista desbloqueada", "Ningún logro desbloqueado", "解除済み実績はありません", "暂无已解锁成就")
		"Baú Comum": return _txt("Common Chest", "Baú Comum", "Cofre Común", "コモン宝箱", "普通宝箱")
		"Baú Raro": return _txt("Rare Chest", "Baú Raro", "Cofre Raro", "レア宝箱", "稀有宝箱")
		"Baú Épico": return _txt("Epic Chest", "Baú Épico", "Cofre Épico", "エピック宝箱", "史诗宝箱")
		"Baú Lendário": return _txt("Legendary Chest", "Baú Lendário", "Cofre Legendario", "レジェンド宝箱", "传奇宝箱")
		"Recompensas básicas, moedas e chance de skin comum.": return _txt("Basic rewards, coins and common skin chance.", "Recompensas básicas, moedas e chance de skin comum.", "Recompensas básicas, monedas y probabilidad de skin común.", "基本報酬、コイン、コモンスキンのチャンス。", "基础奖励、金币和普通皮肤概率。")
		"Chance maior de diamantes, itens raros e efeitos.": return _txt("Higher chance of diamonds, rare items and effects.", "Chance maior de diamantes, itens raros e efeitos.", "Mayor probabilidad de diamantes, objetos raros y efectos.", "ダイヤ、レアアイテム、効果の確率が高い。", "更高概率获得钻石、稀有物品和效果。")
		"Recompensas melhores e chance de skins épicas.": return _txt("Better rewards and epic skin chance.", "Recompensas melhores e chance de skins épicas.", "Mejores recompensas y probabilidad de skins épicas.", "より良い報酬とエピックスキンのチャンス。", "更好奖励和史诗皮肤概率。")
		"Skins lendárias, diamantes e itens especiais.": return _txt("Legendary skins, diamonds and special items.", "Skins lendárias, diamantes e itens especiais.", "Skins legendarias, diamantes y objetos especiales.", "レジェンドスキン、ダイヤ、特別アイテム。", "传奇皮肤、钻石和特殊物品。")
		"Pacote pequeno de diamantes": return _txt("Small Diamond Pack", "Pacote pequeno de diamantes", "Paquete pequeño de diamantes", "小ダイヤパック", "小钻石礼包")
		"Pacote médio de diamantes": return _txt("Medium Diamond Pack", "Pacote médio de diamantes", "Paquete mediano de diamantes", "中ダイヤパック", "中钻石礼包")
		"Diamantes para baús, skins e ofertas.": return _txt("Diamonds for chests, skins and offers.", "Diamantes para baús, skins e ofertas.", "Diamantes para cofres, skins y ofertas.", "宝箱、スキン、オファー用のダイヤ。", "用于宝箱、皮肤和优惠的钻石。")
		"Mais valor para evoluir sua coleção.": return _txt("More value to grow your collection.", "Mais valor para evoluir sua coleção.", "Más valor para mejorar tu colección.", "コレクション強化にお得。", "更划算地提升收藏。")
		"Oferta diária": return _txt("Daily Offer", "Oferta diária", "Oferta diaria", "デイリーオファー", "每日优惠")
		"Pacote visual diário com diamantes e bônus.": return _txt("Daily visual pack with diamonds and bonuses.", "Pacote visual diário com diamantes e bônus.", "Paquete visual diario con diamantes y bonus.", "ダイヤとボーナス付きデイリーパック。", "每日视觉礼包，包含钻石和加成。")
		"Diamantes grátis": return _txt("Free Diamonds", "Diamantes grátis", "Diamantes gratis", "無料ダイヤ", "免费钻石")
		"Recompensa mockada por anúncio.": return _txt("Mock ad reward.", "Recompensa mockada por anúncio.", "Recompensa simulada por anuncio.", "モック広告報酬。", "模拟广告奖励。")
		"Pacote de chaves": return _txt("Key Pack", "Pacote de chaves", "Paquete de llaves", "鍵パック", "钥匙礼包")
		"+6 chaves raras para abrir recompensas.": return _txt("+6 rare keys to open rewards.", "+6 chaves raras para abrir recompensas.", "+6 llaves raras para abrir recompensas.", "報酬を開けるレア鍵 +6。", "+6把稀有钥匙用于开启奖励。")
		"Chaves lendárias": return _txt("Legendary Keys", "Chaves lendárias", "Llaves legendarias", "レジェンド鍵", "传奇钥匙")
		"+2 chaves lendárias para baús premium.": return _txt("+2 legendary keys for premium chests.", "+2 chaves lendárias para baús premium.", "+2 llaves legendarias para cofres premium.", "プレミアム宝箱用レジェンド鍵 +2。", "+2把传奇钥匙用于高级宝箱。")
		"Chave grátis": return _txt("Free Key", "Chave grátis", "Llave gratis", "無料鍵", "免费钥匙")
		"Assista um anúncio mockado para receber diamantes.": return _txt("Watch a mock ad to receive diamonds.", "Assista um anúncio mockado para receber diamantes.", "Mira un anuncio simulado para recibir diamantes.", "モック広告を見てダイヤを受け取る。", "观看模拟广告领取钻石。")
		"Assista um anúncio mockado para receber moedas.": return _txt("Watch a mock ad to receive coins.", "Assista um anúncio mockado para receber moedas.", "Mira un anuncio simulado para recibir monedas.", "モック広告を見てコインを受け取る。", "观看模拟广告领取金币。")
		"Moedas grátis": return _txt("Free Coins", "Moedas grátis", "Monedas gratis", "無料コイン", "免费金币")
		"Baú comum grátis": return _txt("Free Common Chest", "Baú comum grátis", "Cofre común gratis", "無料コモン宝箱", "免费普通宝箱")
		"Recompensa visual por anúncio.": return _txt("Visual reward from a mock ad.", "Recompensa visual por anúncio.", "Recompensa visual por anuncio.", "広告によるビジュアル報酬。", "通过广告获得的视觉奖励。")
		"Dobrar offline": return _txt("Double Offline", "Dobrar offline", "Duplicar offline", "オフライン2倍", "离线翻倍")
		"Preparado para dobrar recompensas AFK.": return _txt("Prepared to double AFK rewards.", "Preparado para dobrar recompensas AFK.", "Preparado para duplicar recompensas AFK.", "AFK報酬2倍用に準備済み。", "已准备离线奖励翻倍。")
		"Pacote de skins": return _txt("Skin Pack", "Pacote de skins", "Paquete de skins", "スキンパック", "皮肤礼包")
		"Visual preparado para liberar skins futuras.": return _txt("Visual pack prepared for future skins.", "Visual preparado para liberar skins futuras.", "Visual preparado para liberar skins futuras.", "将来のスキン解放用ビジュアルパック。", "为未来皮肤准备的视觉礼包。")
		"Pacote de evento": return _txt("Event Pack", "Pacote de evento", "Paquete de evento", "イベントパック", "活动礼包")
		"Pacote de baús": return _txt("Chest Pack", "Pacote de baús", "Paquete de cofres", "宝箱パック", "宝箱礼包")
		"Baús variados para recompensas futuras.": return _txt("Mixed chests for future rewards.", "Baús variados para recompensas futuras.", "Cofres variados para recompensas futuras.", "将来の報酬用の各種宝箱。", "用于未来奖励的混合宝箱。")
	return LocalizationManager.phrase(value) if has_node("/root/LocalizationManager") else value


func _button_text(key: String) -> String:
	if key.strip_edges().is_empty():
		return _tr("unavailable", "Indisponível")
	var normalized := key.to_lower().replace(" ", "_")
	match normalized:
		"play", "jogar":
			return _tr("play", "Jogar" if _language() == "pt" else "Play")
		"comprar", "buy":
			return _tr("buy", "Comprar" if _language() == "pt" else "Buy")
		"abrir", "open":
			return _tr("open", "Abrir" if _language() == "pt" else "Open")
		"coletar", "claim", "resgatar":
			return _tr("claim", "Coletar" if _language() == "pt" else "Claim")
		"concluído", "concluido", "done", "ok":
			return _tr("done", "Concluído" if _language() == "pt" else "Done")
		"usado", "used":
			return _tr("used", "Usado" if _language() == "pt" else "Used")
		"ver_anúncio", "ver_anuncio", "watch_ad":
			return _tr("watch_ad", "Ver anúncio" if _language() == "pt" else "Watch Ad")
		"girar", "spin":
			return _tr("spin", "Girar" if _language() == "pt" else "Spin")
		"ir", "go":
			return _tr("go", "Ir" if _language() == "pt" else "Go")
		"wait", "aguardar":
			return _tr("wait", "Aguardar" if _language() == "pt" else "Wait")
		"locked", "bloqueado":
			return _tr("locked", "Bloqueado" if _language() == "pt" else "Locked")
		"battle", "batalhar", "lutar":
			return _tr("battle", "Batalhar" if _language() == "pt" else "Battle")
		"free", "grátis", "gratis":
			return _tr("free", "Grátis" if _language() == "pt" else "Free")
		"ver_prêmios", "ver_premios", "view_rewards":
			return _tr("view_rewards")
		"claim_all", "coletar_tudo":
			return _tr("claim_all")
	var translated := _phrase(key)
	return translated if not translated.strip_edges().is_empty() else _tr("unavailable", "Indisponível")


func _failure_label(reason: String) -> String:
	match reason:
		"coins", "diamonds", "keys", "legendary_key":
			return _tr("insufficient")
		"already_claimed":
			return _tr("used")
		"not_ready":
			return _tr("unavailable")
		"free_used":
			return _tr("used")
		"ad_limit":
			return _tr("unavailable")
		"empty":
			return _tr("inventory_empty")
	return reason


func _screen_title() -> String:
	match screen_id:
		"shop": return _tr("shop").to_upper()
		"inventory": return _tr("inventory").to_upper()
		"missions": return _tr("missions").to_upper()
		"event": return _tr("event").to_upper()
		"wheel": return _tr("wheel").to_upper()
		"daily_reward": return _tr("daily_reward").to_upper()
		"boss": return _tr("boss").to_upper()
		"league": return _tr("league").to_upper()
		"achievements": return _tr("achievements").to_upper()
	return _phrase(String(SCREEN_DATA.get(screen_id, {}).get("title", screen_id))).to_upper()


func _shop_tab_label(id: String, fallback: String) -> String:
	match id:
		"chests": return _tr("chests")
		"gems": return _tr("diamonds")
		"keys": return _tr("keys")
		"specials": return _tr("rewards")
		"free": return _tr("free_chest")
	return _phrase(fallback)


func _shop_section_label(id: String, fallback: String) -> String:
	match id:
		"chests": return _txt("BUY CHESTS", "COMPRAR BAÚS", "COMPRAR COFRES", "宝箱購入", "购买宝箱")
		"gems": return _txt("DIAMOND PACKS", "PACOTES DE DIAMANTES", "PAQUETES DE DIAMANTES", "ダイヤパック", "钻石礼包")
		"keys": return _tr("keys").to_upper()
		"specials": return _txt("SPECIAL OFFERS", "OFERTAS ESPECIAIS", "OFERTAS ESPECIALES", "特別オファー", "特别优惠")
		"free": return _txt("FREE REWARDS", "RECOMPENSAS GRÁTIS", "RECOMPENSAS GRATIS", "無料報酬", "免费奖励")
	return _phrase(fallback)


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
		"upgrade", "run_upgrade", "upgrade_unlock":
			return "upgrade"
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
	if reward.has("coins") or reward.has("diamonds") or reward.has("chests") or reward.has("skins"):
		return _txt("Multiple rewards", "Várias recompensas", "Varias recompensas", "複数報酬", "多种奖励")
	var amount := int(reward.get("amount", 1))
	match String(reward.get("type", "")):
		"coins":
			return "+%s %s" % [amount, _txt("coins", "moedas", "monedas", "コイン", "金币")]
		"diamonds", "gems":
			return "+%s %s" % [amount, _tr("diamonds")]
		"keys":
			return "+%s %s" % [amount, _tr("keys")]
		"legendaryKeys", "legendary_keys":
			return "+%s %s" % [amount, _txt("legendary keys", "chaves lendárias", "llaves legendarias", "レジェンド鍵", "传奇钥匙")]
		"xp", "profileXp", "profile_xp":
			return "+%s XP" % amount
		"chest":
			var chest_type := String(reward.get("chest_type", reward.get("chestType", "common"))).capitalize()
			return "+%s %s %s" % [amount, chest_type, _tr("chests")]
		"skin":
			var skin_id := String(reward.get("skin_id", reward.get("skinId", "")))
			var skin := MainPortData.skin_by_id(skin_id) if has_node("/root/MainPortData") else {}
			return String(skin.get("name", skin_id))
		"upgrade", "run_upgrade", "upgrade_unlock":
			var upgrade_id := String(reward.get("upgrade_id", reward.get("upgradeId", reward.get("id", ""))))
			var upgrade := MainPortData.upgrade_by_id(upgrade_id) if has_node("/root/MainPortData") else {}
			var upgrade_name := String(upgrade.get("name", upgrade_id))
			return "%s: %s" % [_t_or_text("Upgrade", "Melhoria", "Mejora", "強化", "升级"), upgrade_name]
	return String(reward.get("type", "Reward"))


func _daily_reward_label(reward: Dictionary) -> String:
	var parts: Array[String] = []
	if int(reward.get("coins", 0)) > 0:
		parts.append("%s %s" % [int(reward.get("coins", 0)), _txt("coins", "moedas", "monedas", "コイン", "金币")])
	if int(reward.get("xp", 0)) > 0:
		parts.append("%s XP" % int(reward.get("xp", 0)))
	if int(reward.get("diamonds", 0)) > 0:
		parts.append("%s %s" % [int(reward.get("diamonds", 0)), _tr("diamonds")])
	if int(reward.get("keys", 0)) > 0:
		parts.append("%s %s" % [int(reward.get("keys", 0)), _tr("keys")])
	if reward.has("chest_type"):
		parts.append("%s %s" % [String(reward.get("chest_type", "rare")), _tr("chests")])
	return ", ".join(parts)


func _daily_streak_reward_description(day_index: int) -> String:
	match day_index:
		0:
			return _txt("100 coins", "100 moedas", "100 monedas", "100 コイン", "100 金币")
		1:
			return _txt("25 diamonds", "25 diamantes", "25 diamantes", "25 ダイヤ", "25 钻石")
		2:
			return _txt("1 key", "1 chave", "1 llave", "鍵 1本", "1 把钥匙")
		3:
			return _txt("Common chest", "Baú comum", "Cofre común", "コモン宝箱", "普通宝箱")
		4:
			return _txt("Rare chest", "Baú raro", "Cofre raro", "レア宝箱", "稀有宝箱")
		5:
			return _txt("75 diamonds", "75 diamantes", "75 diamantes", "75 ダイヤ", "75 钻石")
		6:
			return _txt("Epic chest", "Baú épico", "Cofre épico", "エピック宝箱", "史诗宝箱")
	return _txt("Daily reward", "Recompensa diária", "Recompensa diaria", "デイリー報酬", "每日奖励")


func _skin_reward_status(reward: Dictionary) -> String:
	if reward.has("converted_from_skin"):
		return _txt("Duplicate skin • Converted to diamonds", "Skin repetida • Convertida em diamantes", "Skin duplicada • Convertida en diamantes", "重複スキン • ダイヤに変換", "重复皮肤 • 已转为钻石")
	var rarity := String(reward.get("rarity", "common")).capitalize()
	return "%s • %s" % [_txt("New skin unlocked", "Nova skin desbloqueada", "Nueva skin desbloqueada", "新スキン解除", "新皮肤已解锁"), rarity]


func _t_or_text(en: String, pt := "", es := "", ja := "", zh := "") -> String:
	return _txt(en, pt, es, ja, zh)


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
	button.text = text if not text.strip_edges().is_empty() else _tr("unavailable", "Indisponível")
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 11)
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.add_theme_color_override("font_color", Color("#001018"))
	button.add_theme_color_override("font_disabled_color", Color("#ffffffcc"))
	button.add_theme_color_override("font_pressed_color", Color("#001018"))
	button.add_theme_color_override("font_hover_color", Color("#001018"))
	_apply_button_style(button, _make_style(tone, 10, "#00000000", 0, tone + "88", 8))
	button.add_theme_stylebox_override("disabled", _make_style("#ffffff18", 10, tone + "66", 1, tone + "44", 5))
	return button


func _make_card(bg: String = "#ffffff12", border: String = "#ffffff22") -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_theme_stylebox_override("panel", _make_style(bg, 12, border, 1))
	return card


func _card_body(card: PanelContainer, padding: int) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", padding)
	margin.add_theme_constant_override("margin_top", padding)
	margin.add_theme_constant_override("margin_right", padding)
	margin.add_theme_constant_override("margin_bottom", padding)
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_child(margin)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
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
	label.custom_minimum_size.y = max(18.0, float(font_size + 8))
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(color))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.clip_text = false
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if font_size <= 13:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	if has_node("/root/NavigationManager"):
		NavigationManager.go_back(MENU_SCENE)
	else:
		get_tree().change_scene_to_file(MENU_SCENE)


func _configure_scroll(scroll: ScrollContainer) -> void:
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.follow_focus = true
	scroll.scroll_deadzone = 2
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP


func _is_narrow_screen() -> bool:
	return get_viewport_rect().size.x <= 430.0

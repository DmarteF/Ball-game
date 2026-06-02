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
			{ "title": "Baú Comum", "desc": "Recompensas básicas, moedas e chance de skin comum.", "icon": "chest_common", "button": "ABRIR", "tone": "#9ca3af", "price": "100", "action": "common_chest" },
			{ "title": "Baú Raro", "desc": "Chance maior de diamantes, itens raros e efeitos.", "icon": "chest_rare", "button": "ABRIR", "tone": "#00aaff", "price": "40", "action": "rare_chest" },
			{ "title": "Baú Épico", "desc": "Recompensas melhores e chance de skins épicas.", "icon": "chest_epic", "button": "ABRIR", "tone": "#b000ff", "price": "120", "action": "epic_chest" },
			{ "title": "Baú Lendário", "desc": "Skins lendárias, diamantes e itens especiais.", "icon": "chest_legendary", "button": "ABRIR", "tone": "#ffd700", "price": "1", "action": "legendary_chest" },
		],
	},
	{
		"id": "gems",
		"label": "Diamantes",
		"section": "PACOTES DE DIAMANTES",
		"cards": [
			{ "title": "Pacote pequeno de diamantes", "desc": "Diamantes para baús, skins e ofertas.", "icon": "product_diamonds", "button": "COMPRAR", "tone": "#00ff88", "price": "R$ 4,90" },
			{ "title": "Pacote médio de diamantes", "desc": "Mais valor para evoluir sua coleção.", "icon": "product_diamonds", "button": "COMPRAR", "tone": "#00ff88", "price": "R$ 9,90" },
			{ "title": "Oferta diária", "desc": "Pacote visual diário com diamantes e bônus.", "icon": "product_daily", "button": "COMPRAR", "tone": "#ffd700", "price": "R$ 6,90" },
			{ "title": "Diamantes grátis", "desc": "Recompensa mockada por anúncio.", "icon": "gem", "button": "VER ANÚNCIO", "tone": "#00f0ff", "price": "+12", "action": "ad_gems" },
		],
	},
	{
		"id": "keys",
		"label": "Chaves",
		"section": "CHAVES",
		"cards": [
			{ "title": "Pacote de chaves", "desc": "+6 chaves raras para abrir recompensas.", "icon": "key", "button": "COMPRAR", "tone": "#00f0ff", "price": "80", "action": "keys_pack" },
			{ "title": "Chaves lendárias", "desc": "+2 chaves lendárias para baús premium.", "icon": "chest_legendary", "button": "COMPRAR", "tone": "#ffd700", "price": "180", "action": "legendary_keys_pack" },
			{ "title": "Chave grátis", "desc": "Recompensa mockada por anúncio.", "icon": "key", "button": "VER ANÚNCIO", "tone": "#00ff88", "price": "+1", "action": "ad_key" },
		],
	},
	{
		"id": "specials",
		"label": "Recompensas",
		"section": "OFERTAS ESPECIAIS",
		"cards": [
			{ "title": "Pacote inicial", "desc": "Moedas, diamantes e chaves para acelerar o começo.", "icon": "product_starter", "button": "COMPRAR", "tone": "#00f0ff", "price": "R$ 7,90", "action": "mock_paid" },
			{ "title": "Pacote de skins", "desc": "Visual preparado para liberar skins futuras.", "icon": "product_chests", "button": "COMPRAR", "tone": "#ff00aa", "price": "R$ 12,90", "action": "mock_paid" },
			{ "title": "Pacote de evento", "desc": "Bundle visual temporário preparado para eventos.", "icon": "product_event", "button": "COMPRAR", "tone": "#00ff88", "price": "R$ 14,90", "action": "mock_paid" },
			{ "title": "Pacote de baús", "desc": "Baús variados para recompensas futuras.", "icon": "product_chests", "button": "COMPRAR", "tone": "#ffd700", "price": "R$ 9,90", "action": "mock_paid" },
		],
	},
	{
		"id": "free",
		"label": "Baú grátis",
		"section": "RECOMPENSAS GRÁTIS",
		"cards": [
			{ "title": "Diamantes grátis", "desc": "Assista um anúncio mockado para receber diamantes.", "icon": "gem", "button": "VER ANÚNCIO", "tone": "#00ff88", "price": "+12", "action": "ad_gems" },
			{ "title": "Moedas grátis", "desc": "Assista um anúncio mockado para receber moedas.", "icon": "coin", "button": "VER ANÚNCIO", "tone": "#ffd700", "price": "+300", "action": "ad_coins" },
			{ "title": "Baú comum grátis", "desc": "Recompensa visual por anúncio.", "icon": "chest_common", "button": "VER ANÚNCIO", "tone": "#00f0ff", "price": "1x", "action": "ad_chest" },
			{ "title": "Dobrar offline", "desc": "Preparado para dobrar recompensas AFK.", "icon": "product_daily", "button": "VER ANÚNCIO", "tone": "#ff8800", "price": "2x", "action": "ad_coins" },
		],
	},
]

var _regular_font: Font
var _bold_font: Font
var _shop_tab := "chests"
var _content: VBoxContainer
var _shop_tab_buttons: Array[Button] = []
var _feedback_label: Label


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
	root.offset_left = 18.0
	root.offset_top = 50.0
	root.offset_right = -18.0
	NeonBackButtonScript.reserve_footer_space(root)
	root.add_theme_constant_override("separation", 12)
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
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 12)
	scroll.add_child(_content)

	_populate_content(data)


func _populate_content(data: Dictionary) -> void:
	for child in _content.get_children():
		child.queue_free()

	if screen_id == "shop":
		_content.add_child(_make_section_title(_current_shop_tab()["section"]))
		for card_data in _current_shop_tab()["cards"]:
			_content.add_child(_make_feature_card(card_data))
		_content.add_child(_make_section_title("BAÚS GUARDADOS"))
		_content.add_child(_make_inventory_summary())
	elif screen_id == "inventory":
		_populate_inventory()
	elif screen_id == "missions":
		_populate_missions()
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
	body.add_child(row)
	row.add_child(_make_icon(String(data["icon"]), 42))
	var title := _make_label(_screen_title(), 27, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	title.add_theme_color_override("font_outline_color", Color("#00f0ff66"))
	title.add_theme_constant_override("outline_size", 4)
	row.add_child(title)
	return card


func _current_shop_tab() -> Dictionary:
	for tab in SHOP_TABS:
		if String(tab["id"]) == _shop_tab:
			return tab
	return SHOP_TABS[0]


func _make_wallet() -> HBoxContainer:
	var wallet := HBoxContainer.new()
	wallet.add_theme_constant_override("separation", 8)
	wallet.add_child(_make_wallet_item("coin", str(GameState.data.get("coins", 0))))
	wallet.add_child(_make_wallet_item("gem", str(GameState.data.get("diamonds", 0))))
	wallet.add_child(_make_wallet_item("key", str(GameState.data.get("keys", 0))))
	wallet.add_child(_make_wallet_item("chest_legendary", str(GameState.data.get("legendary_keys", 0))))
	return wallet


func _make_wallet_item(icon_key: String, value: String) -> PanelContainer:
	var item := PanelContainer.new()
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
	tabs.columns = 3
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
		return "Boss disponível" if TimeManager.is_boss_available() else "Nenhum boss disponível"
	if screen_id == "daily_reward":
		return "Recompensa disponível" if TimeManager.can_claim_daily_reward() else "Recompensa diária já coletada"
	return String(data["empty_title"])


func _make_feature_card(data: Dictionary) -> PanelContainer:
	var tone := String(data.get("tone", "#00f0ff"))
	var card := _make_card("#ffffff12", tone + "77")
	var body := _card_body(card, 12)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	body.add_child(row)

	row.add_child(_make_icon(String(data.get("icon", "coin")), 46))

	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 4)
	row.add_child(column)

	column.add_child(_make_label(String(data["title"]), 18, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	var desc := _make_label(String(data["desc"]), 12, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(desc)

	if data.has("progress"):
		column.add_child(_make_progress_bar(float(data["progress"]), tone))

	var right := VBoxContainer.new()
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	right.add_theme_constant_override("separation", 5)
	row.add_child(right)
	if data.has("price"):
		right.add_child(_make_label(String(data["price"]), 12, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	var button := _make_action_button(String(data.get("button", "VER")), tone)
	if data.has("action"):
		button.pressed.connect(_handle_action.bind(String(data["action"])))
	right.add_child(button)
	return card


func _populate_inventory() -> void:
	var inventory: Dictionary = GameState.data.get("inventory", {})
	if inventory.is_empty():
		_content.add_child(_make_empty_state("Inventory is empty", "Chests, keys and saved rewards will appear here.", "inventory"))
		return
	for id in inventory.keys():
		var item: Dictionary = inventory[id]
		var card := {
			"title": "%s x%s" % [String(item.get("label", id)), int(item.get("amount", 0))],
			"desc": "Stored reward. Open when ready." if String(item.get("type", "")) == "chest" else "Stored item.",
			"icon": "chest_%s" % String(item.get("icon", "common")) if String(item.get("type", "")) == "chest" else "key",
			"button": "OPEN" if String(item.get("type", "")) == "chest" else "OK",
			"tone": "#ffd700",
			"action": "open:%s" % id,
		}
		_content.add_child(_make_feature_card(card))


func _make_inventory_summary() -> Control:
	var inventory: Dictionary = GameState.data.get("inventory", {})
	if inventory.is_empty():
		return _make_empty_state("No stored chests", "Purchased or earned chests will appear in Inventory.", "chest_common")
	var count := 0
	for id in inventory.keys():
		count += int(inventory[id].get("amount", 0))
	return _make_empty_state("%s stored item(s)" % count, "Open them from Inventory.", "chest_common")


func _populate_daily_reward(data: Dictionary) -> void:
	var can_claim := TimeManager.can_claim_daily_reward()
	var streak := int(GameState.data.get("daily_streak", TimeManager.get_daily_streak()))
	_content.add_child(_make_section_title("7 DAY STREAK"))
	for i in range(data["cards"].size()):
		var card: Dictionary = data["cards"][i].duplicate()
		card["title"] = "Day %s" % (i + 1)
		card["button"] = "CLAIM" if can_claim and i == clampi(streak, 0, 6) else "DONE" if i < streak else "WAIT"
		card["action"] = "daily_claim" if can_claim and i == clampi(streak, 0, 6) else ""
		_content.add_child(_make_feature_card(card))


func _populate_wheel(data: Dictionary) -> void:
	var wheel: Dictionary = GameState.data.get("wheel", {})
	var free_used := bool(wheel.get("free_used", false))
	_content.add_child(_make_feature_card({
		"title": "Free Spin",
		"desc": "Spin once per day for coins, diamonds, keys or chests.",
		"icon": "wheel",
		"button": "USED" if free_used else "SPIN",
		"tone": "#00f0ff",
		"action": "" if free_used else "wheel_free",
	}))
	_content.add_child(_make_feature_card({
		"title": "Mock Ad Spin",
		"desc": "Prepared rewarded-ad flow. Uses a mock reward for now.",
		"icon": "gem",
		"button": "WATCH AD",
		"tone": "#ffd700",
		"action": "wheel_ad",
	}))


func _populate_missions() -> void:
	GameState._ensure_live_systems()
	var daily: Dictionary = GameState.data.get("daily_missions", {})
	for mission in daily.get("missions", []):
		var definition := GameState.get_daily_mission_def(String(mission.get("id", "")))
		if definition.is_empty():
			continue
		var progress := int(mission.get("progress", 0))
		var target := int(definition.get("target", 1))
		_content.add_child(_make_feature_card({
			"title": _localized_definition_title(definition),
			"desc": "%s/%s" % [progress, target],
			"icon": "missions",
			"button": "CLAIM" if progress >= target and not bool(mission.get("claimed", false)) else "DONE" if bool(mission.get("claimed", false)) else "GO",
			"tone": "#ff8800",
			"progress": float(progress) / max(1.0, float(target)),
			"action": "mission:%s" % String(mission.get("id", "")) if progress >= target and not bool(mission.get("claimed", false)) else "",
		}))


func _populate_achievements() -> void:
	GameState._update_achievements(false)
	for achievement in GameState.ACHIEVEMENTS:
		var id := String(achievement["id"])
		var state: Dictionary = GameState.data.get("achievements", {}).get(id, {})
		var progress := int(state.get("progress", 0))
		var required := int(achievement.get("required", 1))
		var completed := bool(state.get("completed", false))
		var claimed := bool(state.get("claimed", false))
		_content.add_child(_make_feature_card({
			"title": _localized_achievement_name(achievement),
			"desc": "%s • %s/%s" % [_localized_achievement_desc(achievement), progress, required],
			"icon": "achievements",
			"button": "CLAIM" if completed and not claimed else "DONE" if claimed else "LOCKED",
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
	elif action == "daily_claim":
		result = GameState.claim_daily_reward()
	elif action == "wheel_free":
		result = GameState.spin_wheel("free")
	elif action == "wheel_ad":
		result = GameState.spin_wheel("ad")
	else:
		result = GameState.shop_claim(action)
	_play_sfx("res://assets/sounds/button_confirm.mp3" if bool(result.get("ok", false)) else "res://assets/sounds/button_error.mp3")
	_rebuild_current()
	_show_feedback(String(result.get("text", result.get("reason", "Not ready"))), bool(result.get("ok", false)))


func _rebuild_current() -> void:
	for child in get_children():
		child.queue_free()
	_build_background()
	_build_screen()


func _show_feedback(text: String, ok: bool) -> void:
	if _feedback_label:
		_feedback_label.text = text
		_feedback_label.add_theme_color_override("font_color", Color("#00ff88") if ok else Color("#ff6b9a"))


func _play_sfx(path: String) -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx(path, -6.0)


func _language() -> String:
	return String(GameState.get_setting("language", "en"))


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
		return fallback
	match id:
		"chests": return "Chests"
		"gems": return "Diamonds"
		"keys": return "Keys"
		"specials": return "Rewards"
		"free": return "Free Chest"
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
	var wheel := PanelContainer.new()
	wheel.custom_minimum_size = Vector2(214, 214)
	wheel.add_theme_stylebox_override("panel", _make_style("#00f0ff18", 107, "#00f0ff99", 3, "#00f0ff77", 14))
	center.add_child(wheel)
	var wheel_center := CenterContainer.new()
	wheel.add_child(wheel_center)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 6)
	wheel_center.add_child(column)
	column.add_child(_make_icon("wheel", 58))
	column.add_child(_make_label("GIRO", 22, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	column.add_child(_make_label("GRATIS", 13, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	return card


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
	button.text = text
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", Color("#001018"))
	_apply_button_style(button, _make_style(tone, 10, "#00000000", 0, tone + "88", 8))
	return button


func _make_card(bg: String = "#ffffff12", border: String = "#ffffff22") -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_style(bg, 12, border, 1))
	return card


func _card_body(card: PanelContainer, padding: int) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", padding)
	margin.add_theme_constant_override("margin_top", padding)
	margin.add_theme_constant_override("margin_right", padding)
	margin.add_theme_constant_override("margin_bottom", padding)
	card.add_child(margin)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
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

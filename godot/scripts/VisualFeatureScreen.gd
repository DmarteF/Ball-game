extends Control

@export var screen_id := "shop"

const MENU_SCENE := "res://scenes/MainMenu.tscn"

const ICON_PATHS := {
	"shop": "res://assets/ui/ui_store.png",
	"inventory": "res://assets/ui/ui_inventory.png",
	"missions": "res://assets/ui/ui_missions.png",
	"event": "res://assets/ui/ui_event.png",
	"wheel": "res://assets/ui/ui_wheel.png",
	"daily_reward": "res://assets/ui/ui_daily_reward.png",
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
		"subtitle": "Ofertas visuais preparadas para compras, anúncios e recompensas futuras.",
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
		"subtitle": "Área visual para baús, chaves, itens e recompensas guardadas.",
		"accent": "#ffd700",
		"cards": [
			{ "title": "Baú comum", "desc": "3 disponíveis. Recompensas básicas e moedas.", "icon": "chest_common", "button": "ABRIR", "tone": "#9ca3af" },
			{ "title": "Baú raro", "desc": "Chance visual de diamantes, efeitos e skins raras.", "icon": "chest_rare", "button": "ABRIR", "tone": "#00aaff" },
			{ "title": "Baú épico", "desc": "Itens melhores preparados para recompensas futuras.", "icon": "chest_epic", "button": "ABRIR", "tone": "#b000ff" },
			{ "title": "Chaves", "desc": "Chaves comuns e lendárias organizadas em cards.", "icon": "key", "button": "VER", "tone": "#ffd700" },
			{ "title": "Itens e efeitos", "desc": "Espaço reservado para skins, trilhas e boosts.", "icon": "inventory", "button": "DETALHES", "tone": "#00ff88" },
		],
	},
	"missions": {
		"title": "MISSÕES",
		"icon": "missions",
		"subtitle": "Lista visual de missões diárias e semanais com progresso mockado.",
		"accent": "#ff8800",
		"cards": [
			{ "title": "Missão diária", "desc": "Quebre 15 anéis. Progresso 6/15.", "icon": "missions", "button": "RESGATAR", "tone": "#00f0ff", "progress": 0.4 },
			{ "title": "Coletor neon", "desc": "Colete 250 moedas durante partidas. Progresso 90/250.", "icon": "coin", "button": "RESGATAR", "tone": "#ffd700", "progress": 0.36 },
			{ "title": "Diamante raro", "desc": "Encontre 1 diamante acertando o centro.", "icon": "gem", "button": "RESGATAR", "tone": "#00ff88", "progress": 0.0 },
			{ "title": "Missão semanal", "desc": "Complete 5 fases nesta semana. Progresso 2/5.", "icon": "missions", "button": "RESGATAR", "tone": "#ff00aa", "progress": 0.4 },
		],
	},
	"event": {
		"title": "EVENTO",
		"icon": "event",
		"subtitle": "Tela visual preparada para eventos temporários e recompensas especiais.",
		"accent": "#00ff88",
		"cards": [
			{ "title": "Festival dos Baús", "desc": "Tempo restante mockado: 2d 14h. Ganhe pontos abrindo baús.", "icon": "product_event", "button": "PARTICIPAR", "tone": "#00ff88" },
			{ "title": "Trilha de recompensas", "desc": "Moedas, diamantes, chaves e skins futuras.", "icon": "chest_epic", "button": "VER EVENTO", "tone": "#ffd700" },
			{ "title": "Bônus ativo", "desc": "Mais chance visual de baú raro durante o evento.", "icon": "chest_rare", "button": "DETALHES", "tone": "#00aaff" },
		],
	},
	"wheel": {
		"title": "ROLETA",
		"icon": "wheel",
		"subtitle": "Roleta visual parada, preparada para giros e prêmios depois.",
		"accent": "#00ff88",
		"cards": [
			{ "title": "Giro grátis", "desc": "1 giro visual disponível hoje.", "icon": "wheel", "button": "GIRAR", "tone": "#00f0ff" },
			{ "title": "Prêmios", "desc": "Moedas, diamantes, chaves, baús e efeitos.", "icon": "gem", "button": "VER PRÊMIOS", "tone": "#ffd700" },
		],
	},
	"daily_reward": {
		"title": "RECOMPENSA DIÁRIA",
		"icon": "daily_reward",
		"subtitle": "Calendário visual de 7 dias. Lógica real de tempo fica para depois.",
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
}

var _regular_font: Font
var _bold_font: Font


func _ready() -> void:
	_regular_font = _make_system_font(400)
	_bold_font = _make_system_font(700)
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
	root.offset_bottom = 0.0
	root.add_theme_constant_override("separation", 12)
	add_child(root)

	var back := _make_flat_button("← VOLTAR", "#00f0ff", 16)
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back.pressed.connect(_go_back)
	root.add_child(back)

	var header := _make_header(data)
	root.add_child(header)

	if screen_id == "wheel":
		root.add_child(_make_wheel_visual(data))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)

	for card_data in data["cards"]:
		content.add_child(_make_feature_card(card_data))
	content.add_child(_spacer(18))


func _make_header(data: Dictionary) -> PanelContainer:
	var card := _make_card(String(data["accent"]) + "18", String(data["accent"]) + "88")
	var body := _card_body(card, 14)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	body.add_child(row)
	row.add_child(_make_icon(String(data["icon"]), 42))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	row.add_child(column)
	var title := _make_label(String(data["title"]), 27, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	title.add_theme_color_override("font_outline_color", Color("#00f0ff66"))
	title.add_theme_constant_override("outline_size", 4)
	column.add_child(title)
	var subtitle := _make_label(String(data["subtitle"]), 12, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(subtitle)
	return card


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

	var button := _make_action_button(String(data.get("button", "VER")), tone)
	row.add_child(button)
	return card


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

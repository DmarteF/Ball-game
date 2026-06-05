extends Control

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const NeonBackButtonScript := preload("res://scripts/NeonBackButton.gd")

const ICON_PATHS := {
	"coin": "res://assets/ui/ui_coin.png",
	"gem": "res://assets/ui/ui_gem.png",
	"key": "res://assets/ui/ui_key.png",
}

const RARITY_FILTERS := [
	{ "id": "all", "label": "Todas" },
	{ "id": "owned", "label": "Obtidas" },
	{ "id": "common", "label": "Comuns" },
	{ "id": "rare", "label": "Raras" },
	{ "id": "epic", "label": "Épicas" },
	{ "id": "legendary", "label": "Lendárias" },
	{ "id": "mythic", "label": "Míticas" },
	{ "id": "ultimate", "label": "Ultimate" },
	{ "id": "locked", "label": "Bloqueadas" },
]

const RARITIES := ["common", "rare", "epic", "legendary", "mythic", "ultimate"]
const EFFECT_FILTERS := [
	{ "id": "all", "label_pt": "Todos", "label_en": "All" },
	{ "id": "control", "label_pt": "Controle", "label_en": "Control" },
	{ "id": "ice", "label_pt": "Gelo", "label_en": "Ice" },
	{ "id": "fire", "label_pt": "Fogo", "label_en": "Fire" },
	{ "id": "critical", "label_pt": "Crítico", "label_en": "Critical" },
	{ "id": "coins", "label_pt": "Moedas", "label_en": "Coins" },
	{ "id": "xp", "label_pt": "XP", "label_en": "XP" },
	{ "id": "speed", "label_pt": "Velocidade", "label_en": "Speed" },
	{ "id": "chain", "label_pt": "Corrente", "label_en": "Chain" },
	{ "id": "area", "label_pt": "Área", "label_en": "Area" },
	{ "id": "phase", "label_pt": "Fase", "label_en": "Phase" },
	{ "id": "gravity", "label_pt": "Gravidade", "label_en": "Gravity" },
]

const SKINS := [
	{ "id": "neon_blue", "name": "Neon Azul", "rarity": "common", "desc": "Esfera inicial equilibrada.", "primary": "#00f0ff", "secondary": "#0088ff", "effects": ["Perfect"], "owned": true, "selected": true },
	{ "id": "puppy", "name": "Cachorrinho", "rarity": "common", "desc": "Chance de moedas extras no impacto.", "primary": "#ffcc88", "secondary": "#8a5a32", "effects": ["Moedas"], "owned": false },
	{ "id": "kitty", "name": "Gatinho", "rarity": "common", "desc": "Aumenta chance crítica.", "primary": "#ff99cc", "secondary": "#ffeeaa", "effects": ["Crítico"], "owned": false },
	{ "id": "piggy", "name": "Porquinho", "rarity": "common", "desc": "Aumenta moedas ganhas.", "primary": "#ff86aa", "secondary": "#ffd1dc", "effects": ["Tesouro"], "owned": false },
	{ "id": "bunny", "name": "Coelho", "rarity": "common", "desc": "Aumenta velocidade da bolinha.", "primary": "#ffffff", "secondary": "#a7f3ff", "effects": ["Velocidade"], "owned": false },
	{ "id": "slime", "name": "Slime", "rarity": "common", "desc": "Chance de ricochete sem perder velocidade.", "primary": "#3dff8f", "secondary": "#00995a", "effects": ["Ricochete"], "owned": false },
	{ "id": "ghost", "name": "Fantasma", "rarity": "common", "desc": "Chance de atravessar parte sólida.", "primary": "#dff7ff", "secondary": "#8a7cff", "effects": ["Fase"], "owned": false },
	{ "id": "robot", "name": "Robô", "rarity": "rare", "desc": "Calcula ricochetes eficientes.", "primary": "#94a3b8", "secondary": "#00f0ff", "effects": ["Ricochete"], "owned": false },
	{ "id": "skull", "name": "Caveira", "rarity": "rare", "desc": "Chance de crítico pesado.", "primary": "#f8fafc", "secondary": "#ff0055", "effects": ["Mega Crítico"], "owned": false },
	{ "id": "fire", "name": "Fogo", "rarity": "rare", "desc": "Aplica dano contínuo.", "primary": "#ff6b00", "secondary": "#ffdd55", "effects": ["Queima"], "owned": false },
	{ "id": "ice", "name": "Gelo", "rarity": "rare", "desc": "Congela ou desacelera anéis.", "primary": "#b8f3ff", "secondary": "#3b82f6", "effects": ["Congela"], "owned": false },
	{ "id": "lightning", "name": "Raio", "rarity": "rare", "desc": "Corrente elétrica atinge outro anel.", "primary": "#faff00", "secondary": "#00e5ff", "effects": ["Corrente"], "owned": false },
	{ "id": "crystal", "name": "Cristal", "rarity": "rare", "desc": "Bônus de gemas por perfect.", "primary": "#67e8f9", "secondary": "#a855f7", "effects": ["Perfect"], "owned": false },
	{ "id": "comet", "name": "Cometa", "rarity": "rare", "desc": "Mais velocidade e impacto.", "primary": "#ff8a00", "secondary": "#60a5fa", "effects": ["Velocidade"], "owned": false },
	{ "id": "red_eye", "name": "Olho Carmesim", "rarity": "epic", "desc": "Pode desacelerar o anel atingido.", "primary": "#ff183f", "secondary": "#111111", "effects": ["Lentidão", "Trilha"], "owned": false },
	{ "id": "cosmic_eye", "name": "Olho Cósmico", "rarity": "epic", "desc": "Aumenta a chance de diamante por perfect.", "primary": "#7c3aed", "secondary": "#22d3ee", "effects": ["Perfect", "Trilha"], "owned": false },
	{ "id": "tiny_dragon", "name": "Dragão Pequeno", "rarity": "epic", "desc": "Chamas extras no impacto.", "primary": "#22c55e", "secondary": "#ff6b00", "effects": ["Queima", "Trilha"], "owned": false },
	{ "id": "shadow_orb", "name": "Esfera Sombria", "rarity": "epic", "desc": "Dano extra em impactos críticos.", "primary": "#20113f", "secondary": "#8b5cf6", "effects": ["Crítico", "Trilha"], "owned": false },
	{ "id": "solar_orb", "name": "Esfera Solar", "rarity": "epic", "desc": "Dano em área em explosões solares.", "primary": "#fff176", "secondary": "#ff4d00", "effects": ["Área", "Trilha"], "owned": false },
	{ "id": "electric_core", "name": "Núcleo Elétrico", "rarity": "epic", "desc": "Corrente mais forte entre anéis.", "primary": "#faff00", "secondary": "#00e5ff", "effects": ["Corrente", "Trilha"], "owned": false },
	{ "id": "ripple_eye", "name": "Olho Espiral Roxo", "rarity": "legendary", "desc": "Pode repelir anéis para fora.", "primary": "#b88cff", "secondary": "#4c1d95", "effects": ["Repulsão", "Trilha", "Top"], "owned": false },
	{ "id": "black_hole", "name": "Buraco Negro", "rarity": "legendary", "desc": "Pode causar dano em área gravitacional.", "primary": "#0b0018", "secondary": "#a855f7", "effects": ["Área", "Gravidade", "Top"], "owned": false },
	{ "id": "neon_phoenix", "name": "Fênix Neon", "rarity": "legendary", "desc": "Críticos queimam anéis próximos.", "primary": "#ff4fd8", "secondary": "#ffb000", "effects": ["Queima", "Trilha", "Top"], "owned": false },
	{ "id": "astral_dragon", "name": "Dragão Astral", "rarity": "legendary", "desc": "Dano e XP superiores.", "primary": "#22d3ee", "secondary": "#7c3aed", "effects": ["Impacto", "XP", "Top"], "owned": false },
	{ "id": "living_singularity", "name": "Singularidade Viva", "rarity": "ultimate", "desc": "Ultimate raríssima com dano gravitacional extremo.", "primary": "#050015", "secondary": "#ff4fd8", "effects": ["Ultimate", "Área", "Top", "Trilha"], "owned": false },
	{ "id": "divine_core", "name": "Núcleo Divino", "rarity": "ultimate", "desc": "Ultimate com bônus de dano, XP e controle.", "primary": "#fff7ad", "secondary": "#22d3ee", "effects": ["Ultimate", "Cósmico", "Top", "Trilha"], "owned": false },
	{ "id": "void_devourer_ultimate", "name": "Devorador do Vazio", "rarity": "ultimate", "desc": "Ultimate oculta que devora anéis.", "primary": "#020617", "secondary": "#8b5cf6", "effects": ["Ultimate", "Gravidade", "Top", "Trilha"], "owned": false },
]

var _regular_font: Font
var _bold_font: Font
var _filter := "all"
var _effect_filter := "all"
var _root: VBoxContainer
var _scroll_content: VBoxContainer
var _content_grid: GridContainer
var _filter_buttons: Array[Button] = []
var _effect_filter_buttons: Array[Button] = []
var _all_skin_data: Array = []
var _detail_overlay: PanelContainer


func _ready() -> void:
	_regular_font = _make_system_font(400)
	_bold_font = _make_system_font(700)
	if has_node("/root/AudioManager"):
		AudioManager.play_context("menu")
	GameState.refresh_unlocks(false)
	_all_skin_data = _build_all_skin_data()
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
	_root = VBoxContainer.new()
	var root := _root
	root.anchor_left = 0.0
	root.anchor_top = 0.0
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	var margin_x := 12.0 if _is_narrow_screen() else 18.0
	root.offset_left = margin_x
	root.offset_top = 36.0 if _is_narrow_screen() else 50.0
	root.offset_right = -margin_x
	NeonBackButtonScript.reserve_footer_space(root)
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var header: BoxContainer = VBoxContainer.new() if _is_narrow_screen() else HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	root.add_child(header)
	NeonBackButtonScript.add_to(self, _go_back)
	header.add_child(_make_label("SKINS", 28 if _is_narrow_screen() else 30, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	header.add_child(_make_wallet())

	var scroll := ScrollContainer.new()
	_configure_scroll(scroll)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)
	_scroll_content = content

	_rebuild_collection_content(content)
	_build_detail_overlay()


func _rebuild_collection_content(content: VBoxContainer = null) -> void:
	if content == null:
		content = _scroll_content
	if content == null:
		return
	for child in content.get_children():
		child.queue_free()
	content.add_child(_make_collection_summary())
	content.add_child(_make_counter_grid("rarity"))
	content.add_child(_make_counter_grid("effect"))
	content.add_child(_make_collection_actions())
	content.add_child(_make_filters("rarity"))
	content.add_child(_make_filters("effect"))

	_content_grid = GridContainer.new()
	_content_grid.columns = 1 if _is_narrow_screen() else 2
	_content_grid.add_theme_constant_override("h_separation", 10)
	_content_grid.add_theme_constant_override("v_separation", 10)
	_content_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_grid.mouse_filter = Control.MOUSE_FILTER_PASS
	content.add_child(_content_grid)
	_populate_skins()


func _make_wallet() -> HBoxContainer:
	var wallet := HBoxContainer.new()
	wallet.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wallet.alignment = BoxContainer.ALIGNMENT_BEGIN if _is_narrow_screen() else BoxContainer.ALIGNMENT_END
	wallet.add_theme_constant_override("separation", 8)
	wallet.add_child(_make_wallet_item("coin", str(GameState.data.get("coins", 0))))
	wallet.add_child(_make_wallet_item("gem", str(GameState.data.get("diamonds", 0))))
	wallet.add_child(_make_wallet_item("key", str(GameState.data.get("keys", 0))))
	return wallet


func _make_wallet_item(icon_key: String, value: String) -> PanelContainer:
	var pill := PanelContainer.new()
	pill.add_theme_stylebox_override("panel", _make_style("#ffffff12", 8, "#ffffff22", 1))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 7)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_right", 7)
	margin.add_theme_constant_override("margin_bottom", 5)
	pill.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	margin.add_child(row)
	row.add_child(_make_icon(icon_key, 15))
	row.add_child(_make_label(value, 12, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	return pill


func _make_counter_grid(kind: String) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 2 if _is_narrow_screen() else 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.mouse_filter = Control.MOUSE_FILTER_PASS
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	var entries := _rarity_counter_entries() if kind == "rarity" else _effect_counter_entries()
	for entry in entries:
		var id := String(entry.get("id", ""))
		var owned := int(entry.get("owned", 0))
		var total := int(entry.get("total", 0))
		var tone := String(entry.get("color", "#00f0ff"))
		var card := PanelContainer.new()
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_stylebox_override("panel", _make_style("#ffffff10", 10, tone + "77", 1))
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_bottom", 8)
		card.add_child(margin)
		var column := VBoxContainer.new()
		margin.add_child(column)
		column.add_child(_make_label(String(entry.get("label", id.to_upper())), 10, tone, _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
		column.add_child(_make_label("%s/%s" % [owned, total], 15, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
		grid.add_child(card)
	return grid


func _make_collection_summary() -> PanelContainer:
	var unlocked: int = Array(GameState.data.get("unlocked_skins", [])).size()
	var locked: int = max(0, _all_skin_data.size() - unlocked)
	var percent := 0 if _all_skin_data.is_empty() else roundi(float(unlocked) / float(_all_skin_data.size()) * 100.0)
	var new_count := Array(GameState.data.get("new_skins", [])).size()
	var pt := String(GameState.get_setting("language", "en")).begins_with("pt")
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _make_style("#ffffff12", 12, "#00f0ff55", 1))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	card.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	margin.add_child(column)
	column.add_child(_make_label("COLEÇÃO" if pt else "COLLECTION", 13, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	column.add_child(_make_label("%s/%s skins" % [unlocked, _all_skin_data.size()], 24, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	column.add_child(_make_label("%s%% %s" % [percent, "completo" if pt else "complete"], 14, "#00ff88", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	column.add_child(_make_label(("Bloqueadas: %s  •  Novas: %s" if pt else "Locked: %s  •  New: %s") % [locked, new_count], 12, "#ffffffaa", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	return card


func _make_collection_actions() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	var best := _make_action(_ui_text("EQUIPAR MELHOR SKIN", "EQUIP BEST SKIN"), "#00f0ff", false, _equip_best_skin)
	var clear := _make_action(_ui_text("LIMPAR NOVAS", "CLEAR NEW"), "#ffd700", Array(GameState.data.get("new_skins", [])).is_empty(), _clear_new_tags)
	row.add_child(best)
	row.add_child(clear)
	return row


func _make_filters(kind: String) -> GridContainer:
	var row := GridContainer.new()
	row.columns = 2 if _is_narrow_screen() else 3
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_theme_constant_override("h_separation", 8)
	row.add_theme_constant_override("v_separation", 8)
	if kind == "rarity":
		_filter_buttons.clear()
	else:
		_effect_filter_buttons.clear()
	var filters := RARITY_FILTERS if kind == "rarity" else EFFECT_FILTERS
	for filter_data in filters:
		var button := Button.new()
		var filter_id := String(filter_data["id"])
		button.text = _filter_label(filter_id, String(filter_data.get("label", filter_data.get("label_pt", filter_id))), kind)
		button.custom_minimum_size = Vector2(96, 34)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_filter = Control.MOUSE_FILTER_PASS
		button.add_theme_font_override("font", _bold_font)
		button.add_theme_font_size_override("font_size", 12)
		button.set_meta("filter_id", filter_id)
		button.set_meta("filter_kind", kind)
		_apply_filter_style(button, filter_id == (_filter if kind == "rarity" else _effect_filter))
		button.pressed.connect(func() -> void:
			if kind == "rarity":
				_filter = filter_id
			else:
				_effect_filter = filter_id
			_refresh_filters()
			_populate_skins()
		)
		if kind == "rarity":
			_filter_buttons.append(button)
		else:
			_effect_filter_buttons.append(button)
		row.add_child(button)
	return row


func _populate_skins() -> void:
	for child in _content_grid.get_children():
		child.queue_free()
	for skin in _all_skin_data:
		var owned := _is_owned(String(skin["id"]))
		if _filter == "owned" and not owned:
			continue
		if _filter == "locked" and owned:
			continue
		if _filter not in ["all", "owned", "locked"] and skin["rarity"] != _filter:
			continue
		if _effect_filter != "all" and not _skin_matches_effect(skin, _effect_filter):
			continue
		_content_grid.add_child(_make_skin_card(skin))


func _filter_label(id: String, fallback: String, kind := "rarity") -> String:
	var pt := String(GameState.get_setting("language", "en")).begins_with("pt")
	if kind == "effect":
		for item in EFFECT_FILTERS:
			if String(item.get("id", "")) == id:
				return String(item.get("label_pt" if pt else "label_en", fallback))
		return fallback
	if not pt:
		match id:
			"all": return "All"
			"common": return "Common"
			"rare": return "Rare"
			"epic": return "Epic"
			"legendary": return "Legendary"
			"mythic": return "Mythic"
			"ultimate": return "Ultimate"
			"owned": return "Owned"
			"locked": return "Locked"
		return fallback
	match id:
		"all": return "Todas"
		"common": return "Comuns"
		"rare": return "Raras"
		"epic": return "Épicas"
		"legendary": return "Lendárias"
		"mythic": return "Míticas"
		"ultimate": return "Ultimate"
		"owned": return "Obtidas"
		"locked": return "Bloqueadas"
	return fallback


func _make_skin_card(skin: Dictionary) -> PanelContainer:
	var owned := _is_owned(String(skin["id"]))
	var selected := String(GameState.data.get("equipped_skin", "neon_blue")) == String(skin["id"])
	var hidden := not owned
	var is_new := owned and GameState.is_new_skin(String(skin["id"]))
	var rarity_color := _rarity_color(String(skin["rarity"]))
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 246)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.add_theme_stylebox_override("panel", _make_style("#ffffff12", 14, "#00ff88" if selected else rarity_color + "88", 2 if selected else 1))
	card.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			_show_skin_details(skin)
		elif event is InputEventScreenTouch and event.pressed:
			_show_skin_details(skin)
	)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 7)
	column.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_child(column)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	top.mouse_filter = Control.MOUSE_FILTER_PASS
	column.add_child(top)
	top.add_child(_make_skin_icon(String(skin["id"]), hidden, Color(String(skin["primary"]))))
	if is_new:
		top.add_child(_make_new_badge())
	var badge := _make_label(_rarity_name(String(skin["rarity"])), 9, "#001018", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	badge.custom_minimum_size = Vector2(58, 24)
	badge.add_theme_stylebox_override("normal", _make_style(rarity_color, 7))
	top.add_child(badge)

	column.add_child(_make_label("???" if hidden else String(skin["name"]), 16, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	var desc := _make_label("???" if hidden else String(skin["desc"]), 12, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size.y = 30
	column.add_child(desc)

	var effects := HBoxContainer.new()
	effects.add_theme_constant_override("separation", 5)
	effects.mouse_filter = Control.MOUSE_FILTER_PASS
	column.add_child(effects)
	if owned and not hidden:
		for effect in skin.get("effects", []).slice(0, 3):
			effects.add_child(_make_effect_badge(String(effect), rarity_color))
	else:
		effects.add_child(_make_effect_badge("???", rarity_color))

	column.add_child(_make_label(("EQUIPADA" if selected else "DESBLOQUEADA") if owned else _unlock_hint(String(skin.get("source", "")), String(skin["rarity"])), 11, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))

	if owned:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 7)
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		column.add_child(row)
		row.add_child(_make_action("USANDO" if selected else "EQUIPAR", "#00f0ff", selected, _equip_skin.bind(String(skin["id"]))))
		row.add_child(_make_action("EVOLUIR", "#00ff88", true))
	else:
		column.add_child(_make_label("Revele em baús, fases ou conquistas", 11, "#ffffff77", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	return card


func _build_all_skin_data() -> Array:
	var result: Array = []
	var seen := {}
	for skin in MainPortData.SKINS:
		var item: Dictionary = skin.duplicate(true)
		item["desc"] = String(item.get("desc", item.get("description", "")))
		item["effects"] = _effects_from_passive(Dictionary(item.get("passive", {})))
		if MainPortData.skin_has_control(String(item.get("id", ""))) and not Array(item["effects"]).has("Controle"):
			item["effects"].append("Controle")
		item["source"] = _source_hint_from_skin(item)
		item["owned"] = String(item.get("id", "")) == "neon_blue"
		result.append(item)
		seen[String(item["id"])] = true

	var directory := DirAccess.open("res://assets/skins")
	if directory == null:
		return result
	_append_asset_skins_from_dir(result, seen, "res://assets/skins")
	_append_asset_skins_from_dir(result, seen, "res://assets/skins/generated")
	return result


func _append_asset_skins_from_dir(result: Array, seen: Dictionary, path: String) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		return
	directory.list_dir_begin()
	var file_name := directory.get_next()
	while file_name != "":
		if not directory.current_is_dir() and file_name.ends_with(".png"):
			var id := file_name.trim_suffix(".png")
			if not seen.has(id):
				var rarity := _rarity_from_id(id)
				result.append({
					"id": id,
					"name": _name_from_id(id),
					"rarity": rarity,
					"desc": _description_from_id(id),
					"primary": _primary_from_id(id, rarity),
					"secondary": _secondary_from_id(id),
					"effects": _effects_from_id(id),
					"source": _source_hint_from_id(id, rarity),
					"owned": false,
				})
				seen[id] = true
		file_name = directory.get_next()


func _effects_from_passive(passive: Dictionary) -> Array[String]:
	match String(passive.get("type", "trail")):
		"perfect_chance":
			return ["Perfect"]
		"coin_on_hit", "coin_multiplier":
			return ["Moedas"]
		"crit_chance", "mega_crit", "cosmic_critical":
			return ["Crítico"]
		"speed", "slime_bounce":
			return ["Velocidade"]
		"phase_solid":
			return ["Fase"]
		"slow_ring", "freeze_ring":
			return ["Congela"]
		"burn":
			return ["Queima"]
		"chain_damage":
			return ["Corrente"]
		"area_damage", "league_king_wave":
			return ["Área"]
		"gravity":
			return ["Gravidade"]
		"repel_ring", "league_starter_champion":
			return ["Repulsão"]
		"xp_multiplier":
			return ["XP"]
		"control", "controle":
			return ["Controle"]
		"all_bonus":
			return ["Bônus"]
	return ["Trilha"]


func _source_hint_from_skin(skin: Dictionary) -> String:
	var id := String(skin.get("id", ""))
	return _source_hint_from_id(id, String(skin.get("rarity", "common")))


func _source_hint_from_id(id: String, rarity: String) -> String:
	var lower := id.to_lower()
	if _contains_any(lower, ["league", "emperor", "champion"]):
		return _ui_text("Recompensa da Liga Neon", "Neon League reward")
	if _contains_any(lower, ["boss", "phoenix", "dragon", "guardian"]):
		return _ui_text("Recompensa de Boss", "Boss reward")
	if _contains_any(lower, ["event", "codex"]):
		return _ui_text("Recompensa de evento", "Event reward")
	if rarity in ["mythic", "ultimate"]:
		return _ui_text("Conquista, evento ou baú raro", "Achievement, event or rare chest")
	return _ui_text("Obtida em baús", "Found in chests")


func _name_from_id(id: String) -> String:
	var words := id.replace("_", " ").split(" ")
	var output := []
	for word in words:
		output.append(word.substr(0, 1).to_upper() + word.substr(1))
	return " ".join(output)


func _rarity_from_id(id: String) -> String:
	if id.contains("ultimate"):
		return "ultimate"
	if id.contains("mythic"):
		return "mythic"
	if id.contains("legendary") or id.contains("king") or id.contains("emperor") or id.contains("guardian") or id.contains("phoenix") or id.contains("dragon") or id.contains("singularity") or id.contains("devourer"):
		return "legendary"
	if id.contains("epic") or id.contains("core") or id.contains("eye") or id.contains("orb") or id.contains("plasma") or id.contains("spiral"):
		return "epic"
	if id.contains("rare") or id.contains("comet") or id.contains("crystal") or id.contains("meteor") or id.contains("wizard") or id.contains("ninja"):
		return "rare"
	return "common"


func _description_from_id(id: String) -> String:
	var effects := _effects_from_id(id)
	if effects.has("Congela") or effects.has("Lentidão"):
		return "Reduz temporariamente a rotação dos anéis durante a gameplay."
	if effects.has("Queima"):
		return "Aplica dano extra e efeito quente nos impactos."
	if effects.has("Corrente"):
		return "Pode atingir outro anel próximo com energia elétrica."
	if effects.has("Área") or effects.has("Gravidade"):
		return "Causa dano em área ou pulso gravitacional nos anéis próximos."
	if effects.has("Fase"):
		return "Pode atravessar parte sólida por chance."
	if effects.has("Repulsão"):
		return "Pode empurrar anéis perigosos para fora."
	if effects.has("Moedas"):
		return "Aumenta ganhos de moedas durante ou ao fim da rodada."
	if effects.has("XP"):
		return "Aumenta ganhos de XP."
	if effects.has("Velocidade"):
		return "Deixa a bolinha mais rápida e ativa."
	if effects.has("Crítico"):
		return "Melhora chance ou dano crítico."
	return "Skin importada da branch main com brilho/trilha próprios."


func _effects_from_id(id: String) -> Array[String]:
	var lower := id.to_lower()
	var effects: Array[String] = []
	if _contains_any(lower, ["ice", "frost", "penguin", "wizard", "red_eye", "neon_spiral", "chrono", "celestial"]):
		effects.append("Congela" if lower.contains("ice") or lower.contains("frost") else "Lentidão")
	if _contains_any(lower, ["fire", "flame", "dragon", "phoenix", "solar", "meteor", "radioactive"]):
		effects.append("Queima")
	if _contains_any(lower, ["electric", "lightning", "plasma", "satellite", "orbital", "blade"]):
		effects.append("Corrente")
	if _contains_any(lower, ["ghost", "shadow", "void"]):
		effects.append("Fase")
	if _contains_any(lower, ["ripple", "guardian", "king", "repulse", "robot"]):
		effects.append("Repulsão")
	if _contains_any(lower, ["black_hole", "singularity", "cosmic", "collapsed", "eclipse", "prism"]):
		effects.append("Área")
	if _contains_any(lower, ["piggy", "cow", "ladybug", "chick", "hamster", "puppy", "emperor", "eternal", "pulse"]):
		effects.append("Moedas")
	if _contains_any(lower, ["monkey", "panda", "heart", "star", "astral", "endless"]):
		effects.append("XP")
	if _contains_any(lower, ["bunny", "fox", "fish", "comet", "ninja", "vortex"]):
		effects.append("Velocidade")
	if _contains_any(lower, ["kitty", "tiger", "bee", "skull", "crown", "omega", "champion"]):
		effects.append("Crítico")
	if MainPortData.skin_has_control(id) or _contains_any(lower, ["control", "ripple", "chrono", "ultimate"]):
		effects.append("Controle")
	if effects.is_empty():
		effects.append("Trilha")
	if _rarity_from_id(id) in ["legendary", "mythic", "ultimate"]:
		effects.append("Top")
	return effects


func _primary_from_id(id: String, rarity: String) -> String:
	var lower := id.to_lower()
	if _contains_any(lower, ["ice", "frost", "blue", "fish", "penguin"]):
		return "#9be8ff"
	if _contains_any(lower, ["fire", "flame", "meteor", "solar", "phoenix"]):
		return "#ff8800"
	if _contains_any(lower, ["electric", "lightning", "plasma"]):
		return "#38bdf8"
	if _contains_any(lower, ["shadow", "void", "ghost", "black", "singularity"]):
		return "#a855f7"
	if _contains_any(lower, ["gold", "king", "crown", "star", "divine", "champion"]):
		return "#ffd700"
	return _rarity_color(rarity)


func _secondary_from_id(id: String) -> String:
	var lower := id.to_lower()
	if _contains_any(lower, ["ice", "frost", "blue"]):
		return "#3b82f6"
	if _contains_any(lower, ["fire", "flame", "solar"]):
		return "#ff0055"
	if _contains_any(lower, ["electric", "lightning"]):
		return "#00f0ff"
	if _contains_any(lower, ["shadow", "void", "ghost", "black"]):
		return "#16003b"
	return "#00f0ff"


func _contains_any(id: String, needles: Array) -> bool:
	for needle in needles:
		if id.contains(String(needle)):
			return true
	return false


func _make_skin_icon(skin_id: String, hidden: bool, tint: Color) -> PanelContainer:
	var box := PanelContainer.new()
	box.custom_minimum_size = Vector2(58, 58)
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	box.add_theme_stylebox_override("panel", _make_style("#00000033", 29, "#ffffff44", 1))
	var center := CenterContainer.new()
	box.add_child(center)
	if hidden:
		center.add_child(_make_label("?", 26, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	else:
		var path := MainPortData.skin_asset_path(skin_id)
		if ResourceLoader.exists(path):
			var texture := TextureRect.new()
			texture.texture = load(path)
			texture.custom_minimum_size = Vector2(54, 54)
			texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture.modulate = tint.lightened(0.15)
			center.add_child(texture)
		else:
			center.add_child(_make_label("?", 26, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	return box


func _make_effect_badge(text: String, color: String) -> PanelContainer:
	var badge := PanelContainer.new()
	badge.add_theme_stylebox_override("panel", _make_style("#00000033", 6, color + "88", 1))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 3)
	badge.add_child(margin)
	margin.add_child(_make_label(text, 9, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	return badge


func _make_new_badge() -> PanelContainer:
	var badge := PanelContainer.new()
	badge.add_theme_stylebox_override("panel", _make_style("#ff0055", 8, "#ffffff66", 1, "#ff005588", 6))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 7)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 7)
	margin.add_theme_constant_override("margin_bottom", 4)
	badge.add_child(margin)
	margin.add_child(_make_label(_ui_text("NOVA", "NEW"), 9, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	return badge


func _rarity_counter_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for rarity in RARITIES:
		var owned := 0
		var total := 0
		for skin in _all_skin_data:
			if String(skin.get("rarity", "")) == rarity:
				total += 1
				if _is_owned(String(skin.get("id", ""))):
					owned += 1
		entries.append({ "id": rarity, "label": _rarity_name(rarity), "owned": owned, "total": total, "color": _rarity_color(rarity) })
	return entries


func _effect_counter_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for item in EFFECT_FILTERS:
		var id := String(item.get("id", ""))
		if id == "all":
			continue
		var owned := 0
		var total := 0
		for skin in _all_skin_data:
			if _skin_matches_effect(skin, id):
				total += 1
				if _is_owned(String(skin.get("id", ""))):
					owned += 1
		entries.append({ "id": id, "label": _filter_label(id, id, "effect").to_upper(), "owned": owned, "total": total, "color": _effect_color(id) })
	return entries


func _skin_matches_effect(skin: Dictionary, effect_id: String) -> bool:
	if effect_id == "control":
		return MainPortData.skin_has_control(String(skin.get("id", ""))) or _effect_keys(skin).has("control")
	return _effect_keys(skin).has(effect_id)


func _effect_keys(skin: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for effect in Array(skin.get("effects", [])):
		var text := String(effect).to_lower()
		if _contains_any(text, ["controle", "control"]): keys.append("control")
		if _contains_any(text, ["gelo", "ice", "congela", "lentidão", "lento", "freeze", "slow"]): keys.append("ice")
		if _contains_any(text, ["fogo", "fire", "queima", "burn", "chama"]): keys.append("fire")
		if _contains_any(text, ["crítico", "critico", "critical", "crit"]): keys.append("critical")
		if _contains_any(text, ["moeda", "coins", "tesouro"]): keys.append("coins")
		if text == "xp" or text.contains("xp"): keys.append("xp")
		if _contains_any(text, ["velocidade", "speed"]): keys.append("speed")
		if _contains_any(text, ["corrente", "chain"]): keys.append("chain")
		if _contains_any(text, ["área", "area"]): keys.append("area")
		if _contains_any(text, ["fase", "phase"]): keys.append("phase")
		if _contains_any(text, ["gravidade", "gravity"]): keys.append("gravity")
	var unique: Array[String] = []
	for key in keys:
		if not unique.has(key):
			unique.append(key)
	return unique


func _effect_color(id: String) -> String:
	match id:
		"control": return "#00f0ff"
		"ice": return "#9be8ff"
		"fire": return "#ff8800"
		"critical": return "#ff4fd8"
		"coins": return "#ffd700"
		"xp": return "#00ff88"
		"speed": return "#67e8f9"
		"chain": return "#38bdf8"
		"area": return "#b000ff"
		"phase": return "#a855f7"
		"gravity": return "#c084fc"
	return "#00f0ff"


func _clear_new_tags() -> void:
	GameState.clear_new_skins()
	_rebuild_collection_content()
	_play_ui_sfx(true)


func _equip_best_skin() -> void:
	var best_id := ""
	var best_score := -1
	var equipped := String(GameState.data.get("equipped_skin", "neon_blue"))
	for id_value in Array(GameState.data.get("unlocked_skins", [])):
		var id := String(id_value)
		var skin := _skin_data_by_id(id)
		if skin.is_empty():
			continue
		var score := _rarity_rank(String(skin.get("rarity", "common"))) * 100
		if MainPortData.skin_has_control(id) or _skin_matches_effect(skin, "control"):
			score += 25
		if score > best_score:
			best_score = score
			best_id = id
	if best_id.is_empty() or best_id == equipped:
		_play_ui_sfx(false)
		return
	_equip_skin(best_id)


func _skin_data_by_id(id: String) -> Dictionary:
	for skin in _all_skin_data:
		if String(skin.get("id", "")) == id:
			return skin
	return {}


func _rarity_rank(rarity: String) -> int:
	return RARITIES.find(rarity)


func _unlock_hint(source: String, rarity: String) -> String:
	if not source.is_empty():
		return source
	if rarity in ["legendary", "mythic", "ultimate"]:
		return _ui_text("Recompensa da Liga Neon, Boss, evento ou baú", "Neon League, Boss, event or chest reward")
	return _ui_text("Obtida em baús, fases ou conquistas", "Found in chests, levels or achievements")


func _make_action(text: String, color: String, disabled: bool, action: Callable = Callable()) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(66, 34)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	button.modulate.a = 0.45 if disabled else 1.0
	button.disabled = disabled
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_color_override("font_color", Color("#001018"))
	_apply_button_style(button, _make_style(color, 8))
	if action.is_valid() and not disabled:
		button.pressed.connect(action)
	return button


func _build_detail_overlay() -> void:
	_detail_overlay = PanelContainer.new()
	_fill(_detail_overlay)
	_detail_overlay.visible = false
	_detail_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_detail_overlay.add_theme_stylebox_override("panel", _make_style("#050014cc", 0))
	add_child(_detail_overlay)


func _show_skin_details(skin: Dictionary) -> void:
	if _detail_overlay == null:
		return
	for child in _detail_overlay.get_children():
		child.queue_free()
	var skin_id := String(skin.get("id", ""))
	var owned := _is_owned(skin_id)
	if owned and GameState.is_new_skin(skin_id):
		GameState.mark_skin_seen(skin_id)
	var center := CenterContainer.new()
	_fill(center)
	_detail_overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(330, 470)
	var rarity := String(skin.get("rarity", "common"))
	panel.add_theme_stylebox_override("panel", _make_style("#16003bee", 18, _rarity_color(rarity) + "aa", 2, _rarity_color(rarity) + "55", 14))
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)
	var icon_box := CenterContainer.new()
	icon_box.custom_minimum_size = Vector2(0, 116)
	column.add_child(icon_box)
	icon_box.add_child(_make_skin_icon(skin_id, not owned, Color(String(skin.get("primary", "#00f0ff")))))
	column.add_child(_make_label(String(skin.get("name", "???")) if owned else "???", 24, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	column.add_child(_make_label(_rarity_name(rarity), 13, _rarity_color(rarity), _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	var effect_text := _effects_text(skin) if owned else "???"
	column.add_child(_make_label(effect_text, 12, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	var desc := _make_label(String(skin.get("desc", "")) if owned else _ui_text("Asset oculto até desbloquear.", "Asset hidden until unlocked."), 12, "#ffffffcc", _regular_font, HORIZONTAL_ALIGNMENT_CENTER)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size.y = 54
	column.add_child(desc)
	column.add_child(_make_label(_unlock_hint(String(skin.get("source", "")), rarity), 11, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	if owned:
		var selected := String(GameState.data.get("equipped_skin", "neon_blue")) == skin_id
		column.add_child(_make_action(_ui_text("USANDO", "USING") if selected else _ui_text("EQUIPAR", "EQUIP"), "#00f0ff", selected, func() -> void:
			_equip_skin(skin_id)
			_detail_overlay.visible = false
		))
	column.add_child(_make_action(_ui_text("FECHAR", "CLOSE"), "#ffffff", false, func() -> void:
		_detail_overlay.visible = false
		_rebuild_collection_content()
	))
	_detail_overlay.visible = true


func _effects_text(skin: Dictionary) -> String:
	var effects: Array = skin.get("effects", [])
	var parts: Array[String] = []
	for effect in effects:
		parts.append(String(effect))
	return " • ".join(parts)


func _equip_skin(skin_id: String) -> void:
	if GameState.equip_skin(skin_id):
		_play_ui_sfx(true)
		_rebuild_collection_content()
	else:
		_play_ui_sfx(false)


func _play_ui_sfx(ok: bool) -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("res://assets/sounds/button_confirm.mp3" if ok else "res://assets/sounds/button_error.mp3", -6.0)


func _ui_text(pt: String, en: String) -> String:
	return pt if String(GameState.get_setting("language", "en")).begins_with("pt") else en


func _refresh_filters() -> void:
	for button in _filter_buttons:
		_apply_filter_style(button, String(button.get_meta("filter_id")) == _filter)
	for button in _effect_filter_buttons:
		_apply_filter_style(button, String(button.get_meta("filter_id")) == _effect_filter)


func _apply_filter_style(button: Button, active: bool) -> void:
	button.add_theme_color_override("font_color", Color("#001018") if active else Color("#ffffffaa"))
	_apply_button_style(button, _make_style("#00f0ff" if active else "#ffffff12", 17, "#00f0ff" if active else "#ffffff22", 1))


func _rarity_color(rarity: String) -> String:
	match rarity:
		"common": return "#888888"
		"rare": return "#0088ff"
		"epic": return "#b000ff"
		"legendary": return "#ffd700"
		"mythic": return "#ff00aa"
		"ultimate": return "#00ff88"
	return "#ffffff"


func _rarity_name(rarity: String) -> String:
	match rarity:
		"common": return "COMUM"
		"rare": return "RARO"
		"epic": return "ÉPICO"
		"legendary": return "LENDÁRIO"
		"mythic": return "MÍTICO"
		"ultimate": return "ULTIMATE"
	return rarity.to_upper()


func _is_owned(skin_id: String) -> bool:
	return Array(GameState.data.get("unlocked_skins", [])).has(skin_id)


func _make_icon(key: String, icon_size: int) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = load(ICON_PATHS[key])
	icon.custom_minimum_size = Vector2(icon_size, icon_size)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
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

extends Control

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const NeonBackButtonScript := preload("res://scripts/NeonBackButton.gd")

const ICON_PATHS := {
	"coin": "res://assets/ui/ui_coin.png",
	"gem": "res://assets/ui/ui_gem.png",
	"key": "res://assets/ui/ui_key.png",
}

const FILTERS := [
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
var _filter := "owned"
var _content_grid: GridContainer
var _filter_buttons: Array[Button] = []
var _all_skin_data: Array = []


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
	var root := VBoxContainer.new()
	root.anchor_left = 0.0
	root.anchor_top = 0.0
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.offset_left = 18.0
	root.offset_top = 50.0
	root.offset_right = -18.0
	NeonBackButtonScript.reserve_footer_space(root)
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	root.add_child(header)
	NeonBackButtonScript.add_to(self, _go_back)
	header.add_child(_make_label("SKINS", 30, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	header.add_child(_make_wallet())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)

	content.add_child(_make_progress_grid())
	content.add_child(_make_skin_summary())
	content.add_child(_make_filters())

	_content_grid = GridContainer.new()
	_content_grid.columns = 2
	_content_grid.add_theme_constant_override("h_separation", 10)
	_content_grid.add_theme_constant_override("v_separation", 10)
	content.add_child(_content_grid)
	_populate_skins()


func _make_wallet() -> HBoxContainer:
	var wallet := HBoxContainer.new()
	wallet.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wallet.alignment = BoxContainer.ALIGNMENT_END
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


func _make_progress_grid() -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	for rarity in RARITIES:
		var owned := 0
		var total := 0
		for skin in _all_skin_data:
			if skin["rarity"] == rarity:
				total += 1
				if _is_owned(String(skin["id"])):
					owned += 1
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", _make_style("#ffffff10", 10, _rarity_color(rarity) + "77", 1))
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_bottom", 8)
		card.add_child(margin)
		var column := VBoxContainer.new()
		margin.add_child(column)
		column.add_child(_make_label(_rarity_name(rarity), 10, _rarity_color(rarity), _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
		column.add_child(_make_label("%s/%s" % [owned, "???" if rarity in ["mythic", "ultimate"] else str(total)], 15, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
		grid.add_child(card)
	return grid


func _make_skin_summary() -> PanelContainer:
	var unlocked: int = Array(GameState.data.get("unlocked_skins", [])).size()
	var locked: int = max(0, _all_skin_data.size() - unlocked)
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
	column.add_child(_make_label(("Skins desbloqueadas: %s" if pt else "Unlocked skins: %s") % unlocked, 14, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	column.add_child(_make_label(("Skins bloqueadas: %s" if pt else "Locked skins: %s") % locked, 13, "#ffffffaa", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	column.add_child(_make_label("Use filtros para ver raridade ou bloqueadas." if pt else "Use filters to view rarity or locked skins.", 12, "#ffffff88", _regular_font, HORIZONTAL_ALIGNMENT_LEFT))
	return card


func _make_filters() -> GridContainer:
	var row := GridContainer.new()
	row.columns = 3
	row.add_theme_constant_override("h_separation", 8)
	row.add_theme_constant_override("v_separation", 8)
	_filter_buttons.clear()
	for filter_data in FILTERS:
		var button := Button.new()
		button.text = _filter_label(String(filter_data["id"]), String(filter_data["label"]))
		button.custom_minimum_size = Vector2(96, 34)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_override("font", _bold_font)
		button.add_theme_font_size_override("font_size", 12)
		button.set_meta("filter_id", String(filter_data["id"]))
		_apply_filter_style(button, String(filter_data["id"]) == _filter)
		button.pressed.connect(func() -> void:
			_filter = String(filter_data["id"])
			_refresh_filters()
			_populate_skins()
		)
		_filter_buttons.append(button)
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
		if _filter not in ["owned", "locked"] and skin["rarity"] != _filter:
			continue
		_content_grid.add_child(_make_skin_card(skin))


func _filter_label(id: String, fallback: String) -> String:
	var pt := String(GameState.get_setting("language", "en")).begins_with("pt")
	if not pt:
		match id:
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
	var rarity_color := _rarity_color(String(skin["rarity"]))
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(160, 246)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_style("#ffffff12", 14, "#00ff88" if selected else rarity_color + "88", 2 if selected else 1))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	card.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 7)
	margin.add_child(column)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	column.add_child(top)
	top.add_child(_make_skin_icon(String(skin["id"]), hidden, Color(String(skin["primary"]))))
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
	column.add_child(effects)
	if owned and not hidden:
		for effect in skin.get("effects", []).slice(0, 3):
			effects.add_child(_make_effect_badge(String(effect), rarity_color))
	else:
		effects.add_child(_make_effect_badge("???", rarity_color))

	column.add_child(_make_label("Lv.1 • 0/10" if owned else "BLOQUEADA", 11, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))

	if owned:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 7)
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
		item["owned"] = String(item.get("id", "")) == "neon_blue"
		result.append(item)
		seen[String(item["id"])] = true

	var directory := DirAccess.open("res://assets/skins")
	if directory == null:
		return result
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
					"owned": false,
				})
		file_name = directory.get_next()
	return result


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
		"repel_ring", "league_starter_champion":
			return ["Repulsão"]
		"xp_multiplier":
			return ["XP"]
	return ["Trilha"]


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
	box.add_theme_stylebox_override("panel", _make_style("#00000033", 29, "#ffffff44", 1))
	var center := CenterContainer.new()
	box.add_child(center)
	if hidden:
		center.add_child(_make_label("?", 26, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	else:
		var path := "res://assets/skins/%s.png" % skin_id
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


func _make_action(text: String, color: String, disabled: bool, action: Callable = Callable()) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(66, 34)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.modulate.a = 0.45 if disabled else 1.0
	button.disabled = disabled
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_color_override("font_color", Color("#001018"))
	_apply_button_style(button, _make_style(color, 8))
	if action.is_valid() and not disabled:
		button.pressed.connect(action)
	return button


func _equip_skin(skin_id: String) -> void:
	if GameState.equip_skin(skin_id):
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("res://assets/sounds/button_confirm.mp3", -6.0)
		_populate_skins()
	else:
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("res://assets/sounds/button_error.mp3", -6.0)


func _refresh_filters() -> void:
	for button in _filter_buttons:
		_apply_filter_style(button, String(button.get_meta("filter_id")) == _filter)


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

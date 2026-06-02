extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

const FILTERS = [
	["all", "Todas"],
	["common", "Comuns"],
	["rare", "Raras"],
	["epic", "Épicas"],
	["legendary", "Lendárias"],
	["mythic", "Míticas"],
	["ultimate", "Ultimate"],
	["owned", "Obtidas"],
	["locked", "Bloqueadas"]
]
const RARITIES = ["common", "rare", "epic", "legendary", "mythic", "ultimate"]

var wallet_label
var content
var skin_grid
var filter = "all"
var filter_buttons = {}

func _ready():
	SaveSystem.save_changed.connect(func(_save): _refresh())
	_build_ui()
	_refresh()

func _build_ui():
	NeonUI.add_main_background(self)
	var header = NeonUI.header(self, "SKINS", 54, 18, 18, 30)
	header.back.pressed.connect(func(): get_tree().current_scene.go_to("menu"))
	wallet_label = NeonUI.label("", 12, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT)
	header.box.add_child(wallet_label)

	content = NeonUI.make_scroll(self, 132, 14, 14, 18, 12)
	var progress_grid = GridContainer.new()
	progress_grid.name = "ProgressGrid"
	progress_grid.columns = 3
	progress_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_grid.add_theme_constant_override("h_separation", 8)
	progress_grid.add_theme_constant_override("v_separation", 8)
	content.add_child(progress_grid)

	var filters_scroll = ScrollContainer.new()
	filters_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	filters_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	filters_scroll.custom_minimum_size = Vector2(0, 40)
	content.add_child(filters_scroll)
	var filter_row = HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 8)
	filters_scroll.add_child(filter_row)
	for item in FILTERS:
		var button = _filter_button(item[1])
		button.pressed.connect(_set_filter.bind(item[0]))
		filter_row.add_child(button)
		filter_buttons[item[0]] = button

	skin_grid = GridContainer.new()
	skin_grid.columns = 2
	skin_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skin_grid.add_theme_constant_override("h_separation", 10)
	skin_grid.add_theme_constant_override("v_separation", 10)
	content.add_child(skin_grid)

func _refresh():
	if not is_node_ready():
		return
	var save = SaveSystem.get_save()
	wallet_label.text = "💰 %d  💎 %d  🔑 %d" % [save.coins, save.gems, save.keys]
	for key in filter_buttons.keys():
		var active = key == filter
		filter_buttons[key].modulate = Color.WHITE if active else Color(1, 1, 1, 0.72)
		filter_buttons[key].add_theme_color_override("font_color", Color("#001018") if active else Color("#ffffffaa"))
		filter_buttons[key].add_theme_stylebox_override("normal", NeonUI.flat(Color("#00f0ff") if active else Color("#ffffff12"), Color("#00f0ff") if active else Color("#ffffff22"), 1, 17))

	var progress_grid = content.get_node("ProgressGrid")
	NeonUI.clear_children(progress_grid)
	for rarity in RARITIES:
		_add_progress_card(progress_grid, rarity, save)
	NeonUI.clear_children(skin_grid)
	for skin in _filtered_skins(save):
		_add_skin_card(skin, save)

func _add_progress_card(parent, rarity, save):
	var color = Color(GameData.get_skin_rarity_color(rarity))
	var total = GameData.RARITY_SKINS.get(rarity, []).size()
	var owned = 0
	for skin_id in GameData.RARITY_SKINS.get(rarity, []):
		if skin_id in save.unlocked_skins:
			owned += 1
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#ffffff10"), Color(color, 0.46), 1, 10))
	parent.add_child(panel)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	panel.add_child(box)
	box.add_child(NeonUI.label(_rarity_label(rarity), 10, color))
	box.add_child(NeonUI.label("%d/%s" % [owned, "???" if rarity in ["mythic", "ultimate"] else str(total)], 15, Color.WHITE))

func _add_skin_card(skin, save):
	var owned = skin.id in save.unlocked_skins
	var selected = skin.id == save.equipped_skin
	var hidden = not owned and skin.rarity in ["mythic", "ultimate"]
	var rarity_color = Color(GameData.get_skin_rarity_color(skin.rarity))
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 268)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color(rarity_color, 0.24 if owned else 0.10), Color("#00ff88") if selected else Color(rarity_color, 0.72), 2 if selected else 1, 14))
	skin_grid.add_child(panel)

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	panel.add_child(box)

	var top = HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	box.add_child(top)
	top.add_child(_skin_icon(skin, hidden))
	var badge = Label.new()
	badge.text = _rarity_label(skin.rarity)
	badge.add_theme_font_size_override("font_size", 9)
	badge.add_theme_color_override("font_color", Color("#001018"))
	badge.add_theme_stylebox_override("normal", NeonUI.flat(rarity_color, Color.TRANSPARENT, 0, 7))
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.custom_minimum_size = Vector2(58, 24)
	top.add_child(badge)

	box.add_child(NeonUI.label("???" if hidden else skin.name, 16, Color.WHITE))
	box.add_child(NeonUI.label("???" if hidden else skin.description, 12, Color("#ffffffaa")))

	if owned and not hidden:
		var effect_row = HBoxContainer.new()
		effect_row.add_theme_constant_override("separation", 5)
		box.add_child(effect_row)
		for label in [skin.trail, skin.impact_effect]:
			var effect = NeonUI.stat_badge(label, Color.WHITE)
			effect.custom_minimum_size = Vector2(62, 24)
			effect_row.add_child(effect)

	var level = int(save.skin_levels.get(skin.id, 1))
	var fragments = int(save.skin_fragments.get(skin.id, 0))
	var cost = SaveSystem.get_skin_evolution_cost(skin.id) if owned else int(skin.fragments_required)
	var meta = HBoxContainer.new()
	meta.add_theme_constant_override("separation", 8)
	box.add_child(meta)
	var frag = NeonUI.label("Lv.%d • %d/%d" % [level, fragments, cost] if owned else ("Oculta" if hidden else "%d/%d" % [fragments, cost]), 11, Color("#ffd700"))
	frag.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meta.add_child(frag)
	if selected:
		meta.add_child(NeonUI.label("Equipada", 10, Color("#00ff88"), HORIZONTAL_ALIGNMENT_RIGHT))

	if owned:
		var actions = HBoxContainer.new()
		actions.add_theme_constant_override("separation", 7)
		box.add_child(actions)
		var equip = NeonUI.main_button("USANDO" if selected else "EQUIPAR", Color("#00f0ff"), Color("#0088ff"), 38)
		equip.disabled = selected
		equip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		equip.pressed.connect(_equip.bind(skin.id))
		actions.add_child(equip)
		if level < 5:
			var evolve = NeonUI.main_button("EVOLUIR", Color("#00ff88"), Color("#008855"), 38)
			evolve.disabled = fragments < cost
			evolve.modulate = Color(1, 1, 1, 0.45) if fragments < cost else Color.WHITE
			evolve.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			evolve.pressed.connect(_evolve.bind(skin.id))
			actions.add_child(evolve)
	else:
		box.add_child(NeonUI.label("Revele em baus" if hidden else "Disponivel em baus", 11, Color("#ffffff77")))

func _skin_icon(skin, hidden):
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(54, 54)
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#ffffff16"), Color("#ffffff44"), 1, 27))
	var center = CenterContainer.new()
	panel.add_child(center)
	if hidden:
		center.add_child(NeonUI.icon("res://assets/ui/ui_locked.png", 28))
	else:
		center.add_child(NeonUI.icon(skin.path, 54))
	return panel

func _filter_button(text):
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 34)
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_stylebox_override("normal", NeonUI.flat(Color("#ffffff12"), Color("#ffffff22"), 1, 17))
	button.add_theme_stylebox_override("hover", NeonUI.flat(Color("#ffffff18"), Color("#00f0ff"), 1, 17))
	return button

func _set_filter(next_filter):
	filter = next_filter
	AudioManager.play_sfx("button_click")
	_refresh()

func _filtered_skins(save):
	var skins = GameData.get_skins().duplicate(true)
	skins.sort_custom(func(a, b):
		var a_owned = a.id in save.unlocked_skins
		var b_owned = b.id in save.unlocked_skins
		var a_equipped = a.id == save.equipped_skin
		var b_equipped = b.id == save.equipped_skin
		if a_equipped != b_equipped:
			return a_equipped
		if a_owned != b_owned:
			return a_owned
		var ar = GameData.RARITY_ORDER.find(a.rarity)
		var br = GameData.RARITY_ORDER.find(b.rarity)
		if ar != br:
			return ar < br
		return String(a.name) < String(b.name)
	)
	return skins.filter(func(skin):
		var owned = skin.id in save.unlocked_skins
		if filter == "owned":
			return owned
		if filter == "locked":
			return not owned
		if filter == "all":
			return true
		return skin.rarity == filter
	)

func _equip(skin_id):
	var ok = SaveSystem.equip_skin(skin_id)
	AudioManager.play_sfx("button_confirm" if ok else "button_error")

func _evolve(skin_id):
	var ok = SaveSystem.upgrade_skin_level(skin_id)
	AudioManager.play_sfx("button_confirm" if ok else "button_error")

func _rarity_label(rarity):
	match rarity:
		"common":
			return "Comum"
		"rare":
			return "Rara"
		"epic":
			return "Épica"
		"legendary":
			return "Lendária"
		"mythic":
			return "Mítica"
		"ultimate":
			return "Ultimate"
	return String(rarity)

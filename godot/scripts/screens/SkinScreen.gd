extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

var wallet_label
var grid
var filter = "all"
var filter_buttons = {}

const FILTERS = ["all", "owned", "locked", "common", "rare", "epic", "legendary", "mythic", "ultimate"]

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
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	margin.add_child(box)
	var header = HBoxContainer.new()
	box.add_child(header)
	var back = NeonUI.ghost_button("VOLTAR", Color("#00f0ff"), 42)
	back.pressed.connect(func(): get_tree().current_scene.go_to("menu"))
	header.add_child(back)
	var title = NeonUI.label("SKINS", 28, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_RIGHT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	wallet_label = NeonUI.label("", 13, Color("#ffd700"))
	box.add_child(wallet_label)

	var filters_scroll = ScrollContainer.new()
	filters_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	filters_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	filters_scroll.custom_minimum_size = Vector2(0, 42)
	box.add_child(filters_scroll)
	var filter_row = HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 7)
	filters_scroll.add_child(filter_row)
	for item in FILTERS:
		var button = NeonUI.ghost_button(item.to_upper(), Color("#00f0ff"), 36)
		button.pressed.connect(_set_filter.bind(item))
		filter_row.add_child(button)
		filter_buttons[item] = button

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 9)
	grid.add_theme_constant_override("v_separation", 9)
	scroll.add_child(grid)

func _set_filter(next_filter):
	filter = next_filter
	AudioManager.play_sfx("button_click")
	_refresh()

func _refresh():
	if not is_node_ready():
		return
	var save = SaveSystem.get_save()
	wallet_label.text = "Moedas %d  Diamantes %d  Skins %d/%d" % [save.coins, save.gems, save.unlocked_skins.size(), GameData.get_skins().size()]
	for key in filter_buttons.keys():
		filter_buttons[key].modulate = Color.WHITE if key == filter else Color(1, 1, 1, 0.72)
	NeonUI.clear_children(grid)
	var skins = _filtered_skins(save)
	for skin in skins:
		_add_skin_card(skin, save)

func _filtered_skins(save):
	var skins = GameData.get_skins().duplicate(true)
	skins.sort_custom(func(a, b):
		var a_owned = a.id in save.unlocked_skins
		var b_owned = b.id in save.unlocked_skins
		if a.id == save.equipped_skin:
			return true
		if b.id == save.equipped_skin:
			return false
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

func _add_skin_card(skin, save):
	var owned = skin.id in save.unlocked_skins
	var selected = skin.id == save.equipped_skin
	var rarity_color = Color(GameData.get_skin_rarity_color(skin.rarity))
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(180, 254)
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color(rarity_color, 0.16 if owned else 0.08), Color("#00ff88") if selected else Color(rarity_color, 0.72), 2 if selected else 1, 10))
	grid.add_child(panel)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	var top = HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	box.add_child(top)
	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(58, 58)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(skin.path):
		icon.texture = load(skin.path)
	top.add_child(icon)
	var meta = VBoxContainer.new()
	meta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(meta)
	meta.add_child(NeonUI.label(skin.name if owned or skin.rarity in ["common", "rare"] else "???", 15, Color.WHITE))
	meta.add_child(NeonUI.label(skin.rarity.to_upper(), 11, rarity_color))
	if selected:
		meta.add_child(NeonUI.label("EQUIPADA", 11, Color("#00ff88")))
	box.add_child(NeonUI.label(skin.description if owned else ("Origem: %s" % skin.origin), 11, Color("#ffffffaa")))
	box.add_child(NeonUI.label("Trail %s | Impacto %s" % [skin.trail, skin.impact_effect], 10, Color("#ffffff88")))
	var level = int(save.skin_levels.get(skin.id, 1))
	var fragments = int(save.skin_fragments.get(skin.id, 0))
	var cost = SaveSystem.get_skin_evolution_cost(skin.id) if owned else int(skin.fragments_required)
	box.add_child(NeonUI.label(("Lv.%d  " % level if owned else "Bloqueada  ") + "Frag. %d/%d" % [fragments, cost], 11, Color("#ffd700")))
	var actions = HBoxContainer.new()
	actions.add_theme_constant_override("separation", 6)
	box.add_child(actions)
	if owned:
		var equip = NeonUI.button("USANDO" if selected else "EQUIPAR", Color("#00f0ff"), 38)
		equip.disabled = selected
		equip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		equip.pressed.connect(_equip.bind(skin.id))
		actions.add_child(equip)
		var evolve = NeonUI.ghost_button("EVOLUIR", Color("#00ff88"), 38)
		evolve.disabled = level >= 5 or fragments < cost
		evolve.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		evolve.pressed.connect(_evolve.bind(skin.id))
		actions.add_child(evolve)
	else:
		var craft = NeonUI.ghost_button("CRIAR" if fragments >= cost else "BAUS", rarity_color, 38)
		craft.disabled = fragments < cost
		craft.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		craft.pressed.connect(_craft.bind(skin.id))
		actions.add_child(craft)

func _equip(skin_id):
	var ok = SaveSystem.equip_skin(skin_id)
	AudioManager.play_sfx("button_confirm" if ok else "button_error")

func _evolve(skin_id):
	var ok = SaveSystem.upgrade_skin_level(skin_id)
	AudioManager.play_sfx("button_confirm" if ok else "button_error")

func _craft(skin_id):
	var ok = SaveSystem.craft_skin(skin_id)
	AudioManager.play_sfx("button_confirm" if ok else "button_error")

class_name NeonUI
extends Object

const BG_DARK = Color("#080818")
const BG_MAIN = Color("#0a0a1a")
const BG_PURPLE = Color("#1a0a2e")
const BG_DEEP = Color("#16003b")
const BG_PANEL = Color("#121228")
const CYAN = Color("#00f0ff")
const BLUE = Color("#0088ff")
const PINK = Color("#ff0055")
const PURPLE = Color("#b000ff")
const GOLD = Color("#ffd700")
const GREEN = Color("#00ff88")
const WHITE_SOFT = Color(1, 1, 1, 0.78)

static func flat(color, border_color = Color(1, 1, 1, 0.12), border_width = 1, radius = 10):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

static func neon_box(color, border_color = CYAN, border_width = 1, radius = 12, shadow_alpha = 0.35):
	var style = flat(color, border_color, border_width, radius)
	style.shadow_color = Color(border_color, shadow_alpha)
	style.shadow_size = 10
	style.shadow_offset = Vector2.ZERO
	return style

static func add_main_background(parent):
	var gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.58, 1.0])
	gradient.colors = PackedColorArray([BG_MAIN, BG_PURPLE, BG_DEEP])
	var texture = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0, 0)
	texture.fill_to = Vector2(0, 1)
	var background = TextureRect.new()
	background.texture = texture
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.stretch_mode = TextureRect.STRETCH_SCALE
	parent.add_child(background)
	return background

static func add_screen_margin(parent, left = 16, top = 0, right = 16, bottom = 0):
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", left)
	margin.add_theme_constant_override("margin_top", top)
	margin.add_theme_constant_override("margin_right", right)
	margin.add_theme_constant_override("margin_bottom", bottom)
	parent.add_child(margin)
	return margin

static func header(parent, title, top = 56, left = 18, right = 18, title_size = 30):
	var box = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_TOP_WIDE)
	box.offset_top = top
	box.offset_left = left
	box.offset_right = -right
	box.add_theme_constant_override("separation", 8)
	parent.add_child(box)
	var back = back_button()
	box.add_child(back)
	box.add_child(label(title, title_size, CYAN))
	return {"box": box, "back": back}

static func back_button(text = "← VOLTAR"):
	var node = Button.new()
	node.text = text
	node.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	node.custom_minimum_size = Vector2(0, 30)
	node.add_theme_font_size_override("font_size", 16)
	node.add_theme_color_override("font_color", CYAN)
	node.add_theme_stylebox_override("normal", flat(Color.TRANSPARENT, Color.TRANSPARENT, 0, 0))
	node.add_theme_stylebox_override("hover", flat(Color("#ffffff10"), Color.TRANSPARENT, 0, 0))
	node.add_theme_stylebox_override("pressed", flat(Color("#ffffff18"), Color.TRANSPARENT, 0, 0))
	return node

static func make_scroll(parent, top, left = 16, right = 16, bottom = 16, gap = 12):
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = top
	scroll.offset_left = left
	scroll.offset_right = -right
	scroll.offset_bottom = -bottom
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	parent.add_child(scroll)
	var content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", gap)
	scroll.add_child(content)
	return content

static func label(text, size = 16, color = Color.WHITE, align = HORIZONTAL_ALIGNMENT_LEFT):
	var node = Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", color)
	node.horizontal_alignment = align
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return node

static func title_label(text, size = 60):
	var node = label(text, size, CYAN, HORIZONTAL_ALIGNMENT_CENTER)
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_shadow_color", CYAN)
	node.add_theme_constant_override("shadow_offset_x", 0)
	node.add_theme_constant_override("shadow_offset_y", 0)
	node.add_theme_constant_override("shadow_outline_size", 18)
	return node

static func button(text, color = CYAN, min_height = 48):
	var node = Button.new()
	node.text = text
	node.custom_minimum_size = Vector2(0, min_height)
	node.add_theme_font_size_override("font_size", 15)
	node.add_theme_color_override("font_color", Color.WHITE)
	node.add_theme_stylebox_override("normal", neon_box(color, color.lightened(0.18), 1, 12, 0.55))
	node.add_theme_stylebox_override("hover", neon_box(color.lightened(0.08), color.lightened(0.24), 1, 12, 0.7))
	node.add_theme_stylebox_override("pressed", neon_box(color.darkened(0.12), color, 1, 12, 0.45))
	node.add_theme_stylebox_override("disabled", flat(Color("#444444"), Color("#666666"), 1, 12))
	return node

static func main_button(text, color_a = CYAN, color_b = BLUE, min_height = 54):
	var node = Button.new()
	node.text = text
	node.custom_minimum_size = Vector2(0, min_height)
	node.add_theme_font_size_override("font_size", 14)
	node.add_theme_color_override("font_color", Color.WHITE)
	node.add_theme_stylebox_override("normal", neon_box(color_a, color_a, 1, 12, 0.58))
	node.add_theme_stylebox_override("hover", neon_box(color_a.lightened(0.08), color_a, 1, 12, 0.72))
	node.add_theme_stylebox_override("pressed", neon_box(color_b, color_a, 1, 12, 0.48))
	node.add_theme_stylebox_override("disabled", flat(Color("#444444"), Color("#666666"), 1, 12))
	return node

static func ghost_button(text, border = CYAN, min_height = 44):
	var node = Button.new()
	node.text = text
	node.custom_minimum_size = Vector2(0, min_height)
	node.add_theme_font_size_override("font_size", 14)
	node.add_theme_color_override("font_color", border)
	node.add_theme_stylebox_override("normal", neon_box(Color(1, 1, 1, 0.07), border.darkened(0.25), 1, 12, 0.22))
	node.add_theme_stylebox_override("hover", neon_box(Color(1, 1, 1, 0.12), border, 1, 12, 0.36))
	node.add_theme_stylebox_override("pressed", neon_box(Color(0, 0, 0, 0.32), border, 1, 12, 0.2))
	return node

static func card(color = Color("#ffffff"), radius = 12):
	return neon_box(Color(1, 1, 1, 0.07), Color(color, 0.52), 1, radius, 0.24)

static func resource_badge(icon_path, text, color = Color.WHITE):
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", flat(Color("#ffffff12"), Color("#ffffff22"), 1, 10))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	panel.add_child(row)
	row.add_child(icon(icon_path, 18))
	var value = label(text, 14, color)
	value.add_theme_color_override("font_color", color)
	row.add_child(value)
	return panel

static func wallet_row(save, include_legendary = false):
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.add_child(resource_badge("res://assets/ui/ui_coin.png", str(save.get("coins", 0))))
	row.add_child(resource_badge("res://assets/ui/ui_gem.png", str(save.get("gems", 0))))
	row.add_child(resource_badge("res://assets/ui/ui_key.png", str(save.get("keys", 0))))
	if include_legendary:
		row.add_child(resource_badge("res://assets/ui/ui_legendary_key.png", str(save.get("legendary_keys", 0))))
	return row

static func stat_badge(text, color = WHITE_SOFT):
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", flat(Color("#ffffff12"), Color("#ffffff22"), 1, 8))
	var value = label(text, 13, color, HORIZONTAL_ALIGNMENT_CENTER)
	panel.add_child(value)
	return panel

static func progress_bar(value, max_value, fill_color = CYAN, height = 22):
	var root = Control.new()
	root.custom_minimum_size = Vector2(0, height)
	var bg = PanelContainer.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.add_theme_stylebox_override("panel", flat(Color("#00000055"), Color.TRANSPARENT, 0, int(height / 2.0)))
	root.add_child(bg)
	var pct = clamp(float(value) / max(1.0, float(max_value)), 0.0, 1.0)
	var fill = PanelContainer.new()
	fill.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	fill.offset_right = 0
	fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fill.custom_minimum_size = Vector2(1, height)
	fill.add_theme_stylebox_override("panel", flat(fill_color, Color.TRANSPARENT, 0, int(height / 2.0)))
	root.add_child(fill)
	root.resized.connect(func():
		fill.offset_right = max(1.0, root.size.x * pct)
	)
	fill.offset_right = max(1.0, root.size.x * pct)
	var text = label("%d/%d" % [int(value), int(max_value)], 12, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	text.set_anchors_preset(Control.PRESET_FULL_RECT)
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	root.add_child(text)
	return root

static func icon(path, size = 32):
	var texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(size, size)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if path != "" and ResourceLoader.exists(path):
		texture_rect.texture = load(path)
	return texture_rect

static func clear_children(node):
	for child in node.get_children():
		child.queue_free()

static func wallet_text(save):
	return "Moedas %s   Diamantes %s   Chaves %s   Lend. %s" % [
		save.get("coins", 0),
		save.get("gems", 0),
		save.get("keys", 0),
		save.get("legendary_keys", 0)
	]

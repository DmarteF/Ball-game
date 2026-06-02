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
	var base = ColorRect.new()
	base.color = BG_MAIN
	base.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(base)
	var purple = ColorRect.new()
	purple.color = Color(BG_PURPLE, 0.82)
	purple.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(purple)
	var deep = ColorRect.new()
	deep.color = Color(BG_DEEP, 0.56)
	deep.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(deep)
	return base

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

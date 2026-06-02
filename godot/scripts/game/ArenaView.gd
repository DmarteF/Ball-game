class_name ArenaView
extends Control

const RingLogic = preload("res://scripts/game/RingLogic.gd")

var rings = []
var ball_pos = Vector2.ZERO
var ball_radius = 10.0
var center = Vector2.ZERO
var outer_radius = 180.0
var skin = {}
var trail_points = []
var floating = []
var invincible = false

func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS

func set_state(next_rings, next_ball_pos, next_center, next_outer_radius, next_skin, next_trail, next_floating, is_invincible):
	rings = next_rings
	ball_pos = next_ball_pos
	center = next_center
	outer_radius = next_outer_radius
	skin = next_skin
	trail_points = next_trail
	floating = next_floating
	invincible = is_invincible
	queue_redraw()

func _draw():
	var now_ms = Time.get_ticks_msec()
	draw_circle(center, outer_radius + 8.0, Color(0, 0.85, 1, 0.04))
	draw_arc(center, outer_radius, 0, PI * 2.0, 192, Color("#1b3150"), 2.0, true)
	for r in range(5):
		draw_arc(center, outer_radius * (r + 1) / 5.0, 0, PI * 2.0, 128, Color(1, 1, 1, 0.025), 1.0, true)
	for i in range(trail_points.size()):
		var point = trail_points[i]
		var alpha = float(i + 1) / max(1.0, trail_points.size())
		var trail_color = Color(skin.get("secondary_color", "#00f0ff"))
		trail_color.a = alpha * 0.26
		draw_circle(point, ball_radius * (0.28 + alpha * 0.45), trail_color)
	for ring in rings:
		if ring.get("status", "active") != "active" or float(ring.get("hp", 0.0)) <= 0.0:
			continue
		var color = Color(RingLogic.get_visual_color(ring, now_ms))
		var thickness = float(ring.get("thickness", 5.0))
		if ring.get("type", "normal") == "solid" or float(ring.get("gap_size", 0.0)) <= 0.001:
			draw_arc(center, float(ring.radius), 0, PI * 2.0, 220, color, thickness, true)
		else:
			var gap_center = RingLogic.get_ring_gap_center(ring)
			var half_gap = float(ring.gap_size) * 0.5
			var from_angle = gap_center + half_gap
			var to_angle = gap_center - half_gap + PI * 2.0
			draw_arc(center, float(ring.radius), from_angle, to_angle, 220, color, thickness, true)
			var cap_a = center + Vector2(cos(gap_center - half_gap), sin(gap_center - half_gap)) * float(ring.radius)
			var cap_b = center + Vector2(cos(gap_center + half_gap), sin(gap_center + half_gap)) * float(ring.radius)
			draw_circle(cap_a, thickness * 0.55, color)
			draw_circle(cap_b, thickness * 0.55, color)
		var hp_ratio = clamp(float(ring.hp) / max(1.0, float(ring.max_hp)), 0.0, 1.0)
		if hp_ratio < 0.96:
			var hp_color = Color("#ffffff")
			hp_color.a = 0.38
			draw_arc(center, float(ring.radius), -PI * 0.5, -PI * 0.5 + PI * 2.0 * hp_ratio, 96, hp_color, max(1.0, thickness * 0.35), true)
	var primary = Color(skin.get("primary_color", "#00f0ff"))
	var secondary = Color(skin.get("secondary_color", "#0088ff"))
	draw_circle(ball_pos, ball_radius + 10.0, Color(primary, 0.12))
	draw_circle(ball_pos, ball_radius + 5.0, Color(secondary, 0.18))
	var path = skin.get("path", "")
	if path != "" and ResourceLoader.exists(path):
		var texture = load(path)
		var size = Vector2(ball_radius * 3.4, ball_radius * 3.4)
		draw_texture_rect(texture, Rect2(ball_pos - size * 0.5, size), false, Color.WHITE)
	else:
		draw_circle(ball_pos, ball_radius, primary)
	if invincible:
		draw_arc(ball_pos, ball_radius + 15.0, 0, PI * 2.0, 80, Color("#00ff88"), 2.0, true)
	for item in floating:
		var age = max(0.0, (now_ms - float(item.get("born", now_ms))) / 900.0)
		if age > 1.0:
			continue
		var pos = item.position + Vector2(0, -34.0 * age)
		var color = Color(item.get("color", "#ffffff"))
		color.a = 1.0 - age
		draw_string(get_theme_default_font(), pos, str(item.text), HORIZONTAL_ALIGNMENT_CENTER, 120, 16, color)

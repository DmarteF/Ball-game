class_name RingLogic
extends Object

const MIN_RING_GAP = 5.0
const TWO_PI = PI * 2.0

static func normalize_angle(angle):
	return fmod(fmod(angle, TWO_PI) + TWO_PI, TWO_PI)

static func angle_distance(a, b):
	var diff = abs(normalize_angle(a) - normalize_angle(b))
	return min(diff, TWO_PI - diff)

static func get_ring_gap_center(ring):
	return normalize_angle(float(ring.get("gap_start", 0.0)) + float(ring.get("rotation", 0.0)))

static func is_angle_inside_ring_gap(angle, ring, padding = 0.0):
	if ring.get("type", "normal") == "solid":
		return false
	var half_gap = max(0.0, float(ring.get("gap_size", 0.0)) * 0.5 - padding)
	return angle_distance(angle, get_ring_gap_center(ring)) <= half_gap

static func create_rings(config, phase):
	var rings = []
	var growth = config.get("difficulty_growth", 0.22)
	var difficulty = 1.0 + max(0, phase - 1) * growth
	var count_growth = config.get("count_growth", 2)
	var requested_count = min(
		config.get("max_count", 9999),
		max(config.get("min_count", 20), int(config.count) + int(max(0, phase - 1) * count_growth))
	)
	var inner_radius = max(float(config.inner_radius), float(config.get("safe_start_radius", config.inner_radius)))
	var available_radius = max(1.0, float(config.outer_radius) - inner_radius)
	var adaptive_min_spacing = min(float(config.get("min_spacing", MIN_RING_GAP)), max(2.25, available_radius / max(1.0, requested_count - 1.0)))
	var max_count_by_spacing = max(1, int(floor(available_radius / adaptive_min_spacing)) + 1)
	var count = max(1, min(int(requested_count), max_count_by_spacing))
	var spacing = available_radius / max(1.0, count - 1.0)
	var min_gap = float(config.get("min_gap_size", PI / 7.5))
	var phase_gap = max(min_gap, float(config.base_gap_size) - (phase - 1) * float(config.get("gap_shrink_per_phase", 0.045)))
	var suggested_solid_count = 1
	if phase <= 5:
		suggested_solid_count = 1
	elif phase <= 10:
		suggested_solid_count = 1 + (1 if phase >= 8 else 0)
	elif phase <= 20:
		suggested_solid_count = 2 + int(floor((phase - 11) / 5.0))
	elif phase <= 35:
		suggested_solid_count = 4 + int(floor((phase - 21) / 6.0))
	else:
		suggested_solid_count = 6 + int(floor((phase - 36) / 5.0))
	var solid_count = max(1, min(count, int(config.get("solid_count", suggested_solid_count))))
	var solid_indexes = {count - 1: true}
	for solid_index in range(1, solid_count):
		var slot = max(1, count - 1 - int(floor((solid_index * count) / float(solid_count + 1))))
		solid_indexes[slot] = true
	for i in range(count):
		var progress = 0.0 if count == 1 else float(i) / float(count - 1)
		var radius = inner_radius + i * spacing
		var direction = 1 if i % 2 == 0 else -1
		var pattern_shift = sin(i * 0.9) * 0.18 if phase % 3 == 0 else 0.0
		var inner_speed_bias = 1.35 - progress * 0.55
		var speed_variation = 0.86 + ((i * 17 + phase * 11) % 23) / 100.0
		var is_solid = solid_indexes.has(i)
		var hp = int(floor(float(config.base_hp) * difficulty * (0.9 + progress * 1.55) * (float(config.get("solid_hp_multiplier", 1.45)) if is_solid else 1.0)))
		var gap_size = max(min_gap, phase_gap * (1.08 - progress * 0.16))
		var colors = config.colors
		var solid_colors = ["#ff3d00", "#ff0055", "#b000ff"]
		rings.append({
			"id": "ring_%d_%d" % [phase, i],
			"type": "solid" if is_solid else "normal",
			"radius": radius,
			"initial_radius": radius,
			"closing_speed": float(config.closing_speed) * difficulty * (0.75 + progress * 0.42),
			"rotation": normalize_angle(i * 0.61 + phase * 0.37 + pattern_shift),
			"rotation_speed": float(config.base_rotation_speed) * difficulty * inner_speed_bias * speed_variation * direction,
			"gap_start": normalize_angle(i * 0.83 + phase * 0.49 + pattern_shift),
			"gap_size": 0.0 if is_solid else gap_size,
			"hp": hp,
			"max_hp": hp,
			"status": "active",
			"thickness": float(config.base_thickness) + (2.0 if is_solid else 0.0),
			"color": solid_colors[i % solid_colors.size()] if is_solid else colors[i % colors.size()],
			"min_radius": 4.0,
			"effect_type": "",
			"effect_until": 0.0,
			"slow_until": 0.0,
			"burn_until": 0.0,
			"burn_dps": 0.0
		})
	return rings

static func update_ring(ring, delta_steps, now_ms):
	if ring.get("status", "active") != "active":
		return ring
	var next = ring.duplicate(true)
	var slow_multiplier = 0.25 if float(next.get("slow_until", 0.0)) > now_ms else 1.0
	next.rotation = normalize_angle(float(next.rotation) + float(next.rotation_speed) * slow_multiplier * delta_steps)
	next.radius = max(float(next.min_radius), float(next.radius) - float(next.closing_speed) * slow_multiplier * delta_steps)
	if float(next.get("burn_until", 0.0)) > now_ms and float(next.get("burn_dps", 0.0)) > 0.0:
		next.hp = max(0.0, float(next.hp) - (float(next.burn_dps) * delta_steps) / 60.0)
	if float(next.hp) <= 0.0:
		next.status = "broken"
	if float(next.get("effect_until", 0.0)) <= now_ms:
		next.effect_type = ""
		next.effect_until = 0.0
	return next

static func update_rings(rings, delta_steps, now_ms, min_gap = MIN_RING_GAP):
	var updated = []
	for ring in rings:
		updated.append(update_ring(ring, delta_steps, now_ms))
	return clamp_ring_spacing(updated, min_gap)

static func clamp_ring_spacing(rings, min_gap = MIN_RING_GAP):
	var inner_active = null
	var next = []
	for ring in rings:
		var item = ring
		if item.get("status", "active") == "active" and float(item.get("hp", 0.0)) > 0.0:
			var min_radius_from_inner = float(item.min_radius)
			if inner_active != null:
				min_radius_from_inner = float(inner_active.radius) + float(inner_active.thickness) * 0.5 + float(item.thickness) * 0.5 + min_gap
			var min_radius = max(float(item.min_radius), min_radius_from_inner)
			if float(item.radius) < min_radius:
				item = item.duplicate(true)
				item.radius = min_radius
			inner_active = item
		next.append(item)
	return next

static func check_ring_collision(ball_pos, ball_radius, ring, center):
	if ring.get("status", "active") != "active":
		return {"is_overlapping": false, "is_in_solid_part": false, "is_in_gap": false, "dist_from_ring": INF, "angle": 0.0}
	var dx = ball_pos.x - center.x
	var dy = ball_pos.y - center.y
	var dist_from_center = sqrt(dx * dx + dy * dy)
	var dist_from_ring = abs(dist_from_center - float(ring.radius))
	var is_overlapping = dist_from_ring <= float(ring.thickness) * 0.5 + ball_radius
	var angle = normalize_angle(atan2(dy, dx))
	var gap_padding = min(0.08, ball_radius / max(1.0, float(ring.radius)))
	var is_gap = is_angle_inside_ring_gap(angle, ring, gap_padding)
	return {
		"is_overlapping": is_overlapping,
		"is_in_solid_part": is_overlapping and not is_gap,
		"is_in_gap": is_gap,
		"dist_from_ring": dist_from_ring,
		"angle": angle
	}

static func find_closest_colliding_ring(ball_pos, ball_radius, rings, center):
	var closest_ring = null
	var closest_index = -1
	var closest_dist = INF
	var in_solid = false
	var in_gap = false
	for i in range(rings.size()):
		var ring = rings[i]
		if ring.get("status", "active") != "active" or float(ring.get("hp", 0.0)) <= 0.0:
			continue
		var result = check_ring_collision(ball_pos, ball_radius, ring, center)
		if result.is_overlapping and result.dist_from_ring < closest_dist:
			closest_dist = result.dist_from_ring
			closest_ring = ring
			closest_index = i
			in_solid = result.is_in_solid_part
			in_gap = result.is_in_gap
	return {"ring": closest_ring, "index": closest_index, "is_in_solid_part": in_solid, "is_in_gap": in_gap}

static func find_perfect_escape_ring(prev_dist, next_dist, ball_pos, ball_radius, rings, center):
	var dx = ball_pos.x - center.x
	var dy = ball_pos.y - center.y
	var angle = normalize_angle(atan2(dy, dx))
	var best_index = -1
	var best_dist = INF
	for i in range(rings.size()):
		var ring = rings[i]
		if ring.get("status", "active") != "active" or ring.get("type", "normal") == "solid":
			continue
		var crossed = (prev_dist - float(ring.radius)) * (next_dist - float(ring.radius)) <= 0.0
		if not crossed:
			continue
		var near = abs(next_dist - float(ring.radius)) <= ball_radius + abs(next_dist - prev_dist) + float(ring.thickness)
		if not near:
			continue
		if not is_angle_inside_ring_gap(angle, ring, min(0.06, ball_radius / max(1.0, float(ring.radius)))):
			continue
		var dist = abs(next_dist - float(ring.radius))
		if dist < best_dist:
			best_dist = dist
			best_index = i
	return {"ring": rings[best_index] if best_index >= 0 else null, "index": best_index}

static func is_ball_crushed_by_ring(ball_pos, ball_radius, ring, center):
	if ring.get("status", "active") != "active" or float(ring.get("hp", 0.0)) <= 0.0:
		return false
	var collision = check_ring_collision(ball_pos, ball_radius, ring, center)
	if collision.is_in_gap or not collision.is_in_solid_part:
		return false
	var dist = ball_pos.distance_to(center)
	var outer_edge = float(ring.radius) + float(ring.thickness) * 0.5
	var ring_passed_into_ball = outer_edge <= max(0.0, dist - ball_radius * 0.25)
	var center_trap = dist <= ball_radius * 1.15 and outer_edge <= ball_radius + 4.0
	return ring_passed_into_ball or center_trap

static func clamp_ball_speed(velocity, min_speed, max_speed):
	var speed = velocity.length()
	if speed <= 0.001:
		return Vector2(min_speed, 0.0)
	var clamped = clamp(speed, min_speed, max_speed)
	return velocity.normalized() * clamped

static func with_effect(ring, effect_type, duration_ms, now_ms):
	var next = ring.duplicate(true)
	next.effect_type = effect_type
	next.effect_until = max(float(next.get("effect_until", 0.0)), now_ms + duration_ms)
	return next

static func get_visual_color(ring, now_ms):
	var effect = ring.get("effect_type", "") if float(ring.get("effect_until", 0.0)) > now_ms else ""
	if effect == "frozen":
		return "#9be8ff"
	if effect == "slowed":
		return "#6ddcff"
	if effect == "burning":
		return "#ff6a00"
	if effect == "poisoned":
		return "#39ff88"
	if effect == "shocked":
		return "#fff56a" if int(now_ms) % 260 < 130 else "#00e5ff"
	if effect == "repulsed":
		return "#c084fc"
	if effect == "exploded":
		return "#ff3d8b"
	if effect == "gravity":
		return "#7c3aed"
	if effect == "critical":
		return "#ffd700"
	if float(ring.get("burn_until", 0.0)) > now_ms:
		return "#ff7a1a"
	if float(ring.get("slow_until", 0.0)) > now_ms:
		return "#9be8ff"
	return ring.get("color", "#ffffff")


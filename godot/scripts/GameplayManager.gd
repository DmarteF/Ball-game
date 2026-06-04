extends Control

const LevelData := preload("res://scripts/LevelData.gd")

const PHASE_SELECT_SCENE := "res://scenes/PhaseSelect.tscn"
const BALL_RADIUS := 10.0
const INNER_RADIUS := 35.0
const BASE_BALL_SPEED := 2.2
const MIN_RING_SPACING := 7.2
const MAX_VISIBLE_RINGS := 32
const MIN_TARGET_ACTIVE_RINGS := 12
const TARGET_ACTIVE_RINGS := 12
const MAX_TARGET_ACTIVE_RINGS := 12
const MIN_SPAWN_DISTANCE_FROM_BALL := 30.0
const MAX_SPAWN_DISTANCE_FROM_BALL := 170.0
const INFINITE_RING_REACH_DISTANCE := 132.0
const PLAYABLE_RING_RADIUS_FACTOR := 0.94
const PLAYABLE_RING_MARGIN := 7.0
const SPAWN_LOOKAHEAD_DISTANCE := 110.0
const MAX_PHYSICS_SUBSTEPS := 6
const SAFE_STEP_DISTANCE := 8.0
const MIN_DIRECTION_COMPONENT := 0.24
const RING_SPAWN_GRACE_MSEC := 1050
const RING_REPOSITION_GRACE_MSEC := 520
const CRUSH_CONFIRM_MSEC := 150
const XP_BASE_REQUIREMENT := 150.0
const RUN_COIN_MULTIPLIER := 1.25
const GLOBAL_COIN_CONVERSION_RATE := 0.72
const PROFILE_XP_MULTIPLIER := 0.95
const COMBO_WINDOW_MSEC := 2600
const PHYSICS_STEPS_PER_SECOND := 60.0
const TWO_PI := PI * 2.0
const RING_COLORS := ["#00f0ff", "#b000ff", "#ff0055", "#00ff88", "#ffd700", "#ff8800"]
const RING_PALETTES := [
	["#00f0ff", "#b000ff", "#ff0055", "#00ff88", "#ffd700", "#ff8800"],
	["#00f0ff", "#7c3aed", "#ff4fd8", "#22d3ee", "#00ff88", "#c084fc"],
	["#38bdf8", "#a855f7", "#f43f5e", "#14f195", "#facc15", "#fb7185"],
	["#67e8f9", "#8b5cf6", "#ec4899", "#10b981", "#f97316", "#e879f9"],
]
const BACKGROUND_PALETTES := [
	["#0a0a1a", "#1a0a2e", "#16003b"],
	["#050816", "#081a3a", "#18002f"],
	["#07020f", "#240817", "#390928"],
	["#03010a", "#12052a", "#25004a"],
	["#020617", "#0b102a", "#24104a"],
]
const ICON_PATHS := {
	"coin": "res://assets/ui/ui_coin.png",
	"gem": "res://assets/ui/ui_gem.png",
	"key": "res://assets/ui/ui_key.png",
	"xp": "res://assets/ui/ui_xp.png",
	"damage": "res://assets/ui/ui_damage.png",
	"speed": "res://assets/ui/ui_speed.png",
	"crit": "res://assets/ui/ui_crit.png",
	"perfect": "res://assets/ui/ui_perfect.png",
	"upgrade": "res://assets/ui/ui_upgrades.png",
}
const SOUND_PATHS := {
	"ring_hit": "res://assets/sounds/hit_light.mp3",
	"ring_crit": "res://assets/sounds/hit_heavy.mp3",
	"ring_break": "res://assets/sounds/ring_break.mp3",
	"ring_clear": "res://assets/sounds/perfect.mp3",
	"reward_coin": "res://assets/sounds/coin_gain.mp3",
	"xp": "res://assets/sounds/xp_gain.mp3",
	"level_up": "res://assets/sounds/level_up.mp3",
	"diamond": "res://assets/sounds/diamond_gain.mp3",
	"victory": "res://assets/sounds/victory.mp3",
	"defeat": "res://assets/sounds/defeat.mp3",
	"click": "res://assets/sounds/button_click.mp3",
	"upgrade_select": "res://assets/sounds/button_confirm.mp3",
}
const MUSIC_PATH := "res://assets/music/gameplay.mp3"
var phase_id := 1
var game_mode := "phase"
var is_infinite := false
var phase_config: Dictionary
var gameplay_config: Dictionary
var rings: Array[Dictionary] = []
var ball_position := Vector2.ZERO
var ball_velocity := Vector2.ZERO
var arena_center := Vector2.ZERO
var arena_size := 320.0
var outer_radius := 154.0
var previous_ball_position := Vector2.ZERO
var previous_distance := 0.0
var last_hit_msec := 0
var run_coins := 0
var run_xp := 0
var total_run_xp := 0
var run_diamonds := 0
var run_level := 1
var run_score := 0.0
var run_dps := 0
var best_combo := 0
var combo := 0
var last_combo_msec := 0
var reward_multiplier := 1
var run_upgrades := 0
var criticals := 0
var skin_effects := 0
var run_shop_upgrades := { "atk": 0, "gold": 0 }
var current_upgrades: Dictionary = {}
var upgrade_effect_cooldowns: Dictionary = {}
var available_upgrades: Array[Dictionary] = []
var recent_hit_damage: Array[float] = []
var rings_destroyed := 0
var perfect_escapes := 0
var is_paused := false
var level_up_active := false
var finished := false
var particles: Array[Dictionary] = []
var trail_points: Array[Dictionary] = []
var floating_feedback: Array[Dictionary] = []
var temporary_upgrade: Dictionary = {}
var ring_spawn_delay := 1.0
var ring_pacing_multiplier := 1.0
var rapid_clear_streak := 0
var last_ring_clear_msec := 0
var background_palette_index := 0
var ring_palette_index := 0
var infinite_elapsed := 0.0
var infinite_level := 1
var infinite_score := 0
var infinite_clear_pressure := 0.0
var last_direction_shift_msec := 0
var crush_contact_started_msec := 0
var rerolls_used := 0
var last_upgrade_option_ids: Array[String] = []
var revive_used := false
var control_input := 0.0
var control_left_down := false
var control_right_down := false
var last_control_sfx_msec := 0
var result_rewards_doubled := false
var pending_result_reward: Dictionary = {}
var skin_profile: Dictionary = {}

var _regular_font: Font
var _bold_font: Font
var _skin_texture: Texture2D
var _background_texture_rect: TextureRect
var _hud_phase: Label
var _hud_resources: HBoxContainer
var _resource_labels: Dictionary = {}
var _hud_meta: Label
var _hud_xp: Label
var _hud_xp_bar: ProgressBar
var _hud_ring_bar: ProgressBar
var _hud_upgrade: HBoxContainer
var _hud_upgrade_icon: TextureRect
var _hud_upgrade_label: Label
var _run_upgrade_bar: HBoxContainer
var _run_atk_button: Button
var _run_gold_button: Button
var _pause_overlay: Control
var _level_up_overlay: Control
var _level_up_cards: VBoxContainer
var _victory_overlay: Control
var _victory_title: Label
var _victory_rewards: VBoxContainer
var _victory_unlock_label: Label
var _victory_next_button: Button
var _victory_double_button: Button
var _defeat_overlay: Control
var _defeat_title: Label
var _defeat_summary: VBoxContainer
var _defeat_revive_button: Button
var _defeat_double_button: Button
var _control_overlay: Control
var _control_indicator: Label
var _music_player: AudioStreamPlayer
var _sfx_players: Dictionary = {}


func _ready() -> void:
	_regular_font = _make_system_font(400)
	_bold_font = _make_system_font(700)
	game_mode = String(GameState.data.get("selected_mode", "phase"))
	is_infinite = game_mode == "infinite"
	phase_id = 1 if is_infinite else clampi(int(GameState.data.get("selected_phase", GameState.data.get("current_phase", 1))), 1, LevelData.MAX_PHASE)
	phase_config = LevelData.get_phase_config(phase_id)
	gameplay_config = _make_infinite_gameplay_config() if is_infinite else LevelData.get_solo_gameplay_config(phase_id, int(GameState.data.get("level", 1)), int(GameState.data.get("permanent_upgrades", {}).get("slowRings", 0)))
	_select_visual_palettes()
	_load_skin_texture()
	_setup_audio()
	_build_background()
	_build_hud()
	_build_control_overlay()
	_build_pause_overlay()
	_build_level_up_overlay()
	_build_result_overlays()
	call_deferred("_start_level")


func _process(delta: float) -> void:
	_update_control_overlay()
	if is_paused or level_up_active or finished:
		return
	_update_game(delta * PHYSICS_STEPS_PER_SECOND)
	_update_effects(delta)
	_update_hud()
	queue_redraw()


func _draw() -> void:
	_update_arena_metrics()
	_draw_arena()
	_draw_rings()
	_draw_effects()
	_draw_ball()
	_draw_floating_feedback()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if has_node("/root/AudioManager"):
			AudioManager.ensure_music()


func _start_level() -> void:
	finished = false
	is_paused = false
	level_up_active = false
	run_coins = 0
	run_xp = 0
	total_run_xp = 0
	run_diamonds = 0
	run_level = 1
	run_score = 0.0
	run_dps = 0
	best_combo = 0
	combo = 0
	last_combo_msec = 0
	reward_multiplier = 1
	run_upgrades = 0
	criticals = 0
	skin_effects = 0
	run_shop_upgrades = { "atk": 0, "gold": 0 }
	current_upgrades = {}
	upgrade_effect_cooldowns = {}
	available_upgrades = []
	rerolls_used = 0
	revive_used = false
	result_rewards_doubled = false
	pending_result_reward = {}
	control_input = 0.0
	control_left_down = false
	control_right_down = false
	recent_hit_damage.clear()
	rings_destroyed = 0
	perfect_escapes = 0
	particles.clear()
	trail_points.clear()
	floating_feedback.clear()
	temporary_upgrade = {}
	ring_spawn_delay = _base_ring_spawn_delay()
	ring_pacing_multiplier = 1.0
	rapid_clear_streak = 0
	last_ring_clear_msec = 0
	infinite_elapsed = 0.0
	infinite_level = 1
	infinite_score = 0
	infinite_clear_pressure = 0.0
	crush_contact_started_msec = 0
	if is_infinite:
		gameplay_config = _make_infinite_gameplay_config()
	_update_arena_metrics()
	var start_angle: float = _safe_motion_angle(randf() * TWO_PI)
	var speed: float = BASE_BALL_SPEED + min(0.62, float(phase_id - 1) * 0.08 + int(GameState.data.get("level", 1)) * 0.006)
	if is_infinite:
		speed += 0.16
	ball_position = arena_center
	previous_ball_position = ball_position
	ball_velocity = Vector2(cos(start_angle), sin(start_angle)) * speed
	rings = _create_rings()
	last_direction_shift_msec = Time.get_ticks_msec()
	previous_distance = 0.0
	_hide_all_overlays()
	_update_hud()
	queue_redraw()


func _update_game(delta_steps: float) -> void:
	_update_arena_metrics()
	var delta_seconds := delta_steps / PHYSICS_STEPS_PER_SECOND
	var target_speed: float = _target_ball_speed()
	ball_velocity = _stabilize_velocity(_clamp_vector_speed(ball_velocity, target_speed * 0.78, target_speed * 1.42))
	var travel := ball_velocity.length() * delta_steps
	var substeps: int = clampi(ceili(travel / SAFE_STEP_DISTANCE), 1, MAX_PHYSICS_SUBSTEPS)
	var step_delta := delta_steps / float(substeps)
	for step in range(substeps):
		var previous_vector := ball_position - arena_center
		var prev_dist := previous_vector.length()
		var prev_pos := ball_position
		previous_ball_position = prev_pos
		_apply_dynamic_steering(step_delta)
		_apply_control_influence(step_delta)
		ball_position += ball_velocity * step_delta
		_bounce_arena_edge()
		var next_dist := (ball_position - arena_center).length()
		_update_rings(step_delta)
		_check_perfect_escape(prev_dist, next_dist, prev_pos, ball_position)
		_check_ring_hit(prev_dist, next_dist, prev_pos, ball_position)
		_bounce_arena_edge()
		next_dist = (ball_position - arena_center).length()
		_clamp_ring_spacing()
		previous_distance = next_dist
		if _is_ball_crushed():
			if crush_contact_started_msec <= 0:
				crush_contact_started_msec = Time.get_ticks_msec()
			elif Time.get_ticks_msec() - crush_contact_started_msec >= CRUSH_CONFIRM_MSEC:
				_finish_defeat()
				return
		else:
			crush_contact_started_msec = 0
	_add_trail_point()
	_update_combo_timeout()
	if is_infinite:
		_update_infinite_mode(delta_seconds)
	else:
		_update_phase_ring_queue()
	if not is_infinite and _active_ring_count() == 0 and _queued_ring_count() == 0:
		_finish_victory()
		return


func _create_rings() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var count: int = int(gameplay_config["ring_count"])
	var min_radius: float = _playable_ring_min_radius()
	var max_radius: float = _playable_ring_max_radius()
	var available_radius: float = max(1.0, max_radius - min_radius)
	var adaptive_min_spacing: float = MIN_RING_SPACING
	var max_count_by_spacing: int = max(1, floori(available_radius / adaptive_min_spacing) + 1)
	count = max(1, min(count, min(MAX_VISIBLE_RINGS, max_count_by_spacing)))
	var spacing: float = available_radius / max(1.0, float(count - 1))
	var difficulty: float = 1.0 + max(0, phase_id - 1) * 0.22
	var phase_gap: float = max(PI / 13.0, float(gameplay_config["gap_size"]))
	var palette: Array = RING_PALETTES[ring_palette_index]
	var solid_indexes: Dictionary = {} if is_infinite else { count - 1: true }
	var initial_active_count: int = min(count, _target_active_ring_count())
	for i in range(count):
		var progress := 0.0 if count == 1 else 1.0 - float(i) / float(count - 1)
		var direction := 1.0 if i % 2 == 0 else -1.0
		var pattern_shift := sin(i * 0.9) * 0.18 if phase_id % 3 == 0 else 0.0
		var inner_speed_bias := 1.35 - progress * 0.55
		var speed_variation := 0.86 + float((i * 17 + phase_id * 11) % 23) / 100.0
		var is_solid: bool = solid_indexes.has(i)
		var hp: int = floori(float(gameplay_config["base_hp"]) * difficulty * (0.9 + progress * 1.55) * (1.45 if is_solid else 1.0))
		var gap_size: float = max(PI / 13.0, phase_gap * (1.02 - progress * 0.14))
		var status := "active" if i < initial_active_count else "queued"
		var spawn_radius := max_radius - spacing * float(i)
		if status != "active":
			spawn_radius = max_radius
		var ring := {
			"id": "ring_%s_%s" % [phase_id, i],
			"type": "solid" if is_solid else "normal",
			"radius": spawn_radius,
			"initial_radius": spawn_radius,
			"closing_speed": float(gameplay_config["closing_speed"]) * difficulty * (0.66 + progress * 0.34),
			"rotation": _normalize_angle(i * 0.61 + phase_id * 0.37 + pattern_shift),
			"rotation_speed": float(gameplay_config["rotation_speed"]) * difficulty * inner_speed_bias * speed_variation * direction,
			"gap_start": _normalize_angle(i * 0.83 + phase_id * 0.49 + pattern_shift),
			"gap_size": 0.0 if is_solid else gap_size,
			"hp": hp,
			"max_hp": hp,
			"status": status,
			"thickness": 7.0 if is_solid else 5.0,
			"color": ["#ff3d00", "#ff0055", "#b000ff"][i % 3] if is_solid else palette[i % palette.size()],
			"min_radius": 4.0,
			"effect_color": "",
			"effect_until": 0,
			"spawned_at": Time.get_ticks_msec(),
			"defeat_grace_until": Time.get_ticks_msec() + RING_SPAWN_GRACE_MSEC,
			"rotation_multiplier": 1.0,
			"closing_multiplier": 1.0,
		}
		if status == "active":
			ring = _randomize_ring_gap(ring) if is_infinite else _align_ring_gap_to_ball(ring)
		result.append(ring)
	return result


func _make_infinite_gameplay_config() -> Dictionary:
	var level_factor: int = max(1, infinite_level)
	var player_level := int(GameState.data.get("level", 1))
	var pressure := clampf(infinite_clear_pressure, 0.0, 8.0)
	return {
		"ring_count": clampi(12 + floori(float(level_factor) * 0.34 + pressure * 0.34), 12, 20),
		"base_hp": 18 + floori(float(level_factor) * 2.8 + pressure * 1.4) + floori(float(player_level) * 0.25),
		"closing_speed": 0.0068 + min(0.024, float(level_factor) * 0.00062 + pressure * 0.0008),
		"rotation_speed": 0.0044 + min(0.014, float(level_factor) * 0.00038 + pressure * 0.00045),
		"gap_size": max(PI / 13.5, PI / (3.55 + float(level_factor) * 0.065 + pressure * 0.09)),
	}


func _update_infinite_mode(delta_seconds: float) -> void:
	infinite_elapsed += delta_seconds
	infinite_clear_pressure = max(0.0, infinite_clear_pressure - delta_seconds * 0.18)
	var next_level := 1 + floori(infinite_elapsed / 22.0) + floori(float(rings_destroyed) / 10.0) + floori(infinite_clear_pressure * 0.45)
	if next_level != infinite_level:
		infinite_level = next_level
		gameplay_config = _make_infinite_gameplay_config()
	_refill_active_rings_now()


func _update_phase_ring_queue() -> void:
	_refill_active_rings_now()


func _refill_active_rings_now() -> void:
	if finished:
		return
	if is_infinite and rings.size() >= MAX_VISIBLE_RINGS:
		_prune_inactive_rings()
	var target_count: int = _target_active_ring_count()
	if is_infinite:
		target_count = mini(target_count, _infinite_ring_capacity())
	else:
		target_count = min(target_count, int(gameplay_config.get("ring_count", TARGET_ACTIVE_RINGS)))
	var attempts := 0
	while _active_ring_count() < target_count and rings.size() < MAX_VISIBLE_RINGS + 6 and attempts < 16:
		attempts += 1
		if _queued_ring_count() > 0 and _activate_next_queued_ring():
			continue
		if not is_infinite or not _append_infinite_ring():
			break
	_clamp_ring_spacing()


func _target_active_ring_count() -> int:
	var pressure: float = clampf(infinite_clear_pressure, 0.0, 8.0) if is_infinite else 0.0
	var difficulty_step: int = floori(float(maxi(0, phase_id - 1)) / 18.0)
	if is_infinite:
		difficulty_step = floori(float(maxi(0, infinite_level - 1)) / 5.0 + pressure * 0.16)
	return clampi(TARGET_ACTIVE_RINGS + difficulty_step, MIN_TARGET_ACTIVE_RINGS, MAX_TARGET_ACTIVE_RINGS)


func _queued_ring_count() -> int:
	var count := 0
	for ring in rings:
		if String(ring.get("status", "")) == "queued":
			count += 1
	return count


func _activate_next_queued_ring() -> bool:
	for i in range(rings.size()):
		var ring := rings[i]
		if String(ring.get("status", "")) != "queued":
			continue
		var safe_spawn := _find_outer_spawn_radius(rings)
		if not bool(safe_spawn.get("ok", false)):
			return false
		ring["status"] = "active"
		ring["radius"] = float(safe_spawn["radius"])
		ring = _randomize_ring_gap(ring) if is_infinite else _align_ring_gap_to_ball(ring)
		ring["initial_radius"] = max(float(ring.get("initial_radius", ring["radius"])), float(ring["radius"]))
		ring["spawned_at"] = Time.get_ticks_msec()
		ring["defeat_grace_until"] = Time.get_ticks_msec() + RING_SPAWN_GRACE_MSEC
		rings[i] = ring
		return true
	return false


func _prune_inactive_rings() -> void:
	var kept: Array[Dictionary] = []
	for ring in rings:
		if String(ring.get("status", "")) == "active" and int(ring.get("hp", 0)) > 0:
			kept.append(ring)
	rings = kept


func _append_infinite_ring() -> bool:
	var ring_index := rings.size()
	var ring := _make_infinite_ring(ring_index)
	if ring.is_empty():
		return false
	rings.append(ring)
	return true


func _infinite_ring_spacing() -> float:
	return max(MIN_RING_SPACING + 0.8, 8.0)


func _infinite_ring_capacity() -> int:
	var available: float = _playable_ring_max_radius() - _playable_ring_min_radius()
	return clampi(floori(available / _infinite_ring_spacing()) + 1, TARGET_ACTIVE_RINGS, 16)


func _active_ring_indices_by_radius() -> Array[int]:
	var indices: Array[int] = []
	for i in range(rings.size()):
		var ring := rings[i]
		if String(ring.get("status", "")) == "active" and int(ring.get("hp", 0)) > 0:
			indices.append(i)
	for i in range(indices.size()):
		for j in range(i + 1, indices.size()):
			var a: int = indices[i]
			var b: int = indices[j]
			if float(rings[b].get("radius", 0.0)) < float(rings[a].get("radius", 0.0)):
				indices[i] = b
				indices[j] = a
	return indices


func _keep_infinite_rings_in_reach() -> void:
	if not is_infinite:
		return
	var indices := _active_ring_indices_by_radius()
	var count := indices.size()
	if count <= 0:
		return
	var min_radius := _playable_ring_min_radius()
	var max_radius := _playable_ring_max_radius()
	var ball_dist := clampf((ball_position - arena_center).length(), min_radius, max_radius)
	var spacing := _infinite_ring_spacing()
	var width := spacing * float(max(0, count - 1))
	var available_width := max_radius - min_radius
	if width > available_width:
		spacing = max(MIN_RING_SPACING, available_width / float(max(1, count - 1)))
		width = spacing * float(max(0, count - 1))
	var reach: float = min(INFINITE_RING_REACH_DISTANCE, max(width * 0.5 + spacing * 2.2, 68.0))
	var low: float = max(min_radius, ball_dist - reach)
	var high: float = min(max_radius, ball_dist + reach)
	if high - low < width:
		var center_radius := clampf(ball_dist, min_radius + width * 0.5, max_radius - width * 0.5)
		low = clampf(center_radius - width * 0.5, min_radius, max_radius - width)
		high = low + width
	else:
		low = clampf(ball_dist - width * 0.5, low, high - width)
		high = low + width
	for order in range(count):
		var index: int = indices[order]
		var ring: Dictionary = rings[index]
		var target_radius: float = clampf(low + spacing * float(order), min_radius, max_radius)
		var current_radius: float = float(ring.get("radius", target_radius))
		var too_far: bool = abs(current_radius - ball_dist) > reach or current_radius < min_radius or current_radius > max_radius
		if too_far or abs(current_radius - target_radius) > MIN_RING_SPACING * 1.25:
			var next_radius: float = move_toward(current_radius, target_radius, 2.4)
			ring["radius"] = next_radius
			ring["initial_radius"] = max(float(ring.get("initial_radius", target_radius)), target_radius)
			if abs(current_radius - next_radius) > 0.5:
				ring["defeat_grace_until"] = Time.get_ticks_msec() + RING_REPOSITION_GRACE_MSEC
			rings[index] = ring


func _make_infinite_ring(index: int) -> Dictionary:
	var palette: Array = RING_PALETTES[ring_palette_index]
	var progress := clampf(float(_active_ring_count()) / 16.0, 0.0, 1.0)
	var direction := 1.0 if index % 2 == 0 else -1.0
	var solid_every: int = max(7, 12 - min(5, floori(float(infinite_level) / 3.0)))
	var is_solid := infinite_level >= 4 and index % solid_every == 0
	var base_hp := int(gameplay_config.get("base_hp", 20))
	var hp := floori(float(base_hp) * (1.0 + progress * 0.75) * (1.42 if is_solid else 1.0))
	var safe_spawn := _find_outer_spawn_radius(rings)
	if not bool(safe_spawn.get("ok", false)):
		return {}
	var radius := float(safe_spawn["radius"])
	var gap: float = 0.0 if is_solid else max(PI / 15.0, float(gameplay_config.get("gap_size", PI / 4.0)) * randf_range(0.88, 1.08))
	var rotation := randf() * TWO_PI
	var ring := {
		"id": "infinite_%s_%s" % [floori(infinite_elapsed), index],
		"type": "solid" if is_solid else "normal",
		"radius": radius,
		"initial_radius": radius,
		"closing_speed": float(gameplay_config.get("closing_speed", 0.012)) * randf_range(0.78, 1.08),
		"rotation": rotation,
		"rotation_speed": float(gameplay_config.get("rotation_speed", 0.005)) * randf_range(0.86, 1.25) * direction,
		"gap_start": randf() * TWO_PI,
		"gap_size": gap,
		"hp": hp,
		"max_hp": hp,
		"status": "active",
		"thickness": 7.0 if is_solid else 5.0,
		"color": ["#ff3d00", "#ff0055", "#b000ff"][index % 3] if is_solid else palette[index % palette.size()],
		"min_radius": 4.0,
		"effect_color": "",
		"effect_until": 0,
		"spawned_at": Time.get_ticks_msec(),
		"defeat_grace_until": Time.get_ticks_msec() + RING_SPAWN_GRACE_MSEC,
		"rotation_multiplier": 1.0,
		"closing_multiplier": 1.0,
	}
	ring["rotation"] = rotation
	return _randomize_ring_gap(ring)


func _update_rings(delta_steps: float) -> void:
	var pacing := _effective_ring_pacing()
	for i in range(rings.size()):
		var ring := rings[i]
		if String(ring.get("status", "")) != "active":
			continue
		var now := Time.get_ticks_msec()
		if int(ring.get("effect_until", 0)) > 0 and now >= int(ring.get("effect_until", 0)):
			ring["effect_color"] = ""
			ring["effect_until"] = 0
			ring["rotation_multiplier"] = 1.0
			ring["closing_multiplier"] = 1.0
		var rotation_multiplier := float(ring.get("rotation_multiplier", 1.0))
		var closing_multiplier := float(ring.get("closing_multiplier", 1.0))
		if now < int(ring.get("defeat_grace_until", 0)):
			closing_multiplier *= 0.28
		ring["rotation"] = _normalize_angle(float(ring["rotation"]) + float(ring["rotation_speed"]) * delta_steps * rotation_multiplier)
		ring["radius"] = max(float(ring["min_radius"]), float(ring["radius"]) - float(ring["closing_speed"]) * delta_steps * pacing * closing_multiplier)
		rings[i] = ring


func _check_perfect_escape(prev_dist: float, next_dist: float, prev_pos: Vector2, next_pos: Vector2) -> void:
	for i in range(rings.size()):
		var ring := rings[i]
		if String(ring.get("status", "")) != "active" or String(ring.get("type", "normal")) == "solid":
			continue
		var radius := float(ring["radius"])
		var crossed: bool = (prev_dist - radius) * (next_dist - radius) <= 0.0
		var near: bool = abs(next_dist - radius) <= BALL_RADIUS + abs(next_dist - prev_dist) + float(ring["thickness"])
		var contact := _segment_contact_for_radius(prev_pos, next_pos, radius)
		var inside_gap_band: bool = abs(next_dist - radius) <= BALL_RADIUS + float(ring["thickness"]) * 0.75
		var angle: float = _normalize_angle((next_pos - arena_center).angle())
		if bool(contact.get("ok", false)):
			angle = float(contact["angle"])
		elif not inside_gap_band:
			continue
		if (crossed or inside_gap_band) and near and _is_angle_inside_gap(angle, ring, min(0.012, BALL_RADIUS / max(1.0, radius) * 0.18)):
			_try_apply_skin_effect(i, "perfect")
			_try_apply_upgrade_effects(i, "perfect", 0)
			ring = rings[i]
			ring["status"] = "cleared"
			ring["hp"] = 0
			rings[i] = ring
			_register_ring_clear()
			perfect_escapes += 1
			var perfect_coins: int = max(5, floori(10.0 * _gold_multiplier()))
			var perfect_xp: int = floori((28.0 + randf() * 16.0 + phase_id * 1.2) * _xp_multiplier())
			_award_coins(perfect_coins)
			_award_xp(perfect_xp)
			_register_combo("Perfect", Color("#00f0ff"))
			_spawn_particles(ball_position, Color("#b8f3ff"), 12, 110.0)
			_spawn_floating("Perfect", ball_position + Vector2(10, -20), Color("#b8f3ff"))
			_play_sfx("ring_clear")
			if randf() < min(0.18, 0.03 + _perfect_diamond_bonus()):
				run_diamonds += 1
				_play_sfx("diamond")
				_spawn_floating("+1 DIAMANTE", ball_position + Vector2(16, 12), Color("#c084fc"))
			_refill_active_rings_now()
			return


func _check_ring_hit(prev_dist: float, next_dist: float, prev_pos: Vector2, next_pos: Vector2) -> void:
	var closest_index := -1
	var closest_dist := INF
	for i in range(rings.size()):
		var ring := rings[i]
		if String(ring.get("status", "")) != "active":
			continue
		var collision := _check_ring_collision(ring, prev_dist, next_dist, prev_pos, next_pos)
		if bool(collision["overlap"]) and not bool(collision["gap"]) and float(collision["dist"]) < closest_dist:
			closest_index = i
			closest_dist = float(collision["dist"])
	if closest_index < 0:
		return

	var ring := rings[closest_index]
	if _skin_can_phase_collision(ring):
		_spawn_particles(ball_position, Color("#a855f7"), 10, 90.0)
		_spawn_floating("Phase", ball_position + Vector2(10, -18), Color("#c084fc"))
		return
	_separate_and_reflect(ring, prev_dist)
	var now: int = Time.get_ticks_msec()
	if now - last_hit_msec <= 90:
		return
	last_hit_msec = now
	var is_crit := randf() * 100.0 < _crit_chance()
	var damage := floori(float(_base_damage()) * (_crit_damage() if is_crit else 1.0))
	damage += _try_apply_skin_effect(closest_index, "hit")
	damage += _try_apply_upgrade_effects(closest_index, "hit", damage)
	ring = rings[closest_index]
	var new_hp: int = max(0, int(ring["hp"]) - damage)
	ring["hp"] = new_hp
	ring["status"] = "broken" if new_hp <= 0 else "active"
	rings[closest_index] = ring
	_award_coins(max(2, floori(damage * 0.82 * _gold_multiplier())))
	_award_xp(floori((18.0 if is_crit else 12.0) * _xp_multiplier()))
	run_score += damage
	_track_dps(float(damage))
	_spawn_particles(ball_position, Color(String(ring["color"])), 6, 70.0)
	_spawn_floating("+%s%s" % [damage, " CRIT" if is_crit else ""], ball_position + Vector2(8, -12), Color("#ffd700") if is_crit else Color("#ffffff"))
	if is_crit:
		criticals += 1
	if new_hp <= 0:
		rings_destroyed += 1
		infinite_score += max(1, damage)
		_register_ring_clear()
		_try_apply_skin_effect(closest_index, "break")
		_try_apply_upgrade_effects(closest_index, "break", damage)
		_register_combo("Break", Color("#ffd700"))
		_award_coins(max(10, floori((26.0 if String(ring.get("type", "normal")) == "solid" else 18.0) * _gold_multiplier())))
		_award_xp(floori(((24.0 if String(ring.get("type", "normal")) == "solid" else 14.0) + phase_id * 0.8 + randf() * (14.0 if String(ring.get("type", "normal")) == "solid" else 9.0)) * _xp_multiplier()))
		_spawn_particles(ball_position, Color("#ffd700"), 18, 130.0)
		_spawn_floating("Break!", ball_position + Vector2(-18, -28), Color("#ffd700"))
		_play_sfx("ring_break")
		_refill_active_rings_now()
	else:
		_play_sfx("ring_crit" if is_crit else "ring_hit")


func _check_ring_collision(ring: Dictionary, prev_dist := -1.0, next_dist := -1.0, prev_pos := Vector2.ZERO, next_pos := Vector2.ZERO) -> Dictionary:
	var offset := ball_position - arena_center
	var dist_from_center := offset.length()
	var dist_from_ring: float = abs(dist_from_center - float(ring["radius"]))
	var overlapping: bool = dist_from_ring <= float(ring["thickness"]) / 2.0 + BALL_RADIUS
	var radius := float(ring["radius"])
	if prev_dist >= 0.0 and next_dist >= 0.0:
		var crossed: bool = (prev_dist - radius) * (next_dist - radius) <= 0.0
		var swept_near: bool = abs(next_dist - prev_dist) + BALL_RADIUS + float(ring["thickness"]) >= min(abs(prev_dist - radius), abs(next_dist - radius))
		overlapping = overlapping or (crossed and swept_near)
	var angle: float = _normalize_angle(offset.angle())
	if prev_pos != Vector2.ZERO or next_pos != Vector2.ZERO:
		var contact := _segment_contact_for_radius(prev_pos, next_pos, radius)
		if bool(contact.get("ok", false)):
			angle = float(contact["angle"])
			dist_from_ring = min(dist_from_ring, float(contact.get("distance", dist_from_ring)))
	var padding: float = min(0.018, BALL_RADIUS / max(1.0, float(ring["radius"])) * 0.22)
	var in_gap: bool = false if String(ring.get("type", "normal")) == "solid" else _is_angle_inside_gap(angle, ring, padding)
	return { "overlap": overlapping, "gap": in_gap, "dist": dist_from_ring, "angle": angle }


func _segment_angle_for_radius(prev_pos: Vector2, next_pos: Vector2, radius: float) -> float:
	var contact := _segment_contact_for_radius(prev_pos, next_pos, radius)
	if bool(contact.get("ok", false)):
		return float(contact["angle"])
	var fallback := ball_position - arena_center
	return _normalize_angle(fallback.angle())


func _segment_contact_for_radius(prev_pos: Vector2, next_pos: Vector2, radius: float) -> Dictionary:
	var start := prev_pos - arena_center
	var end := next_pos - arena_center
	var delta := end - start
	var t := 0.5
	var a := delta.dot(delta)
	var b := 2.0 * start.dot(delta)
	var c := start.dot(start) - radius * radius
	if a > 0.0001:
		var disc := b * b - 4.0 * a * c
		if disc >= 0.0:
			var root := sqrt(disc)
			var t1 := (-b - root) / (2.0 * a)
			var t2 := (-b + root) / (2.0 * a)
			if t1 >= 0.0 and t1 <= 1.0:
				t = t1
			elif t2 >= 0.0 and t2 <= 1.0:
				t = t2
			else:
				t = clampf((radius - start.length()) / max(0.001, end.length() - start.length()), 0.0, 1.0)
		else:
			return { "ok": false, "angle": _normalize_angle((ball_position - arena_center).angle()), "distance": abs((ball_position - arena_center).length() - radius) }
	var point := start.lerp(end, t)
	if point.length() <= 0.01:
		point = ball_position - arena_center
	return { "ok": true, "angle": _normalize_angle(point.angle()), "distance": abs(point.length() - radius), "t": t }


func _apply_dynamic_steering(delta_steps: float) -> void:
	var speed := ball_velocity.length()
	if speed <= 0.01:
		return
	var dir := ball_velocity / speed
	var too_flat: bool = abs(dir.y) < MIN_DIRECTION_COMPONENT
	var too_vertical: bool = abs(dir.x) < MIN_DIRECTION_COMPONENT * 0.65
	var stale: bool = Time.get_ticks_msec() - last_direction_shift_msec > 1450
	if too_flat or too_vertical or stale:
		var sign := -1.0 if randf() < 0.5 else 1.0
		var amount := (0.022 if stale else 0.035) * sign * clampf(delta_steps, 0.5, 2.4)
		ball_velocity = ball_velocity.rotated(amount)
		ball_velocity = _stabilize_velocity(ball_velocity)
		last_direction_shift_msec = Time.get_ticks_msec()


func _apply_control_influence(delta_steps: float) -> void:
	if abs(control_input) <= 0.01 or not bool(skin_profile.get("control", false)):
		return
	var speed := ball_velocity.length()
	if speed <= 0.01:
		return
	var strength := clampf(float(skin_profile.get("control_strength", 0.0)), 0.0, 0.85)
	if strength <= 0.0:
		return
	var current_dir := ball_velocity / speed
	var desired := (current_dir + Vector2(control_input * (0.45 + strength * 0.75), 0.0)).normalized()
	var blend := clampf((0.022 + strength * 0.074) * delta_steps, 0.012, 0.12)
	var steered := current_dir.lerp(desired, blend).normalized()
	var target_speed := _target_ball_speed()
	ball_velocity = _stabilize_velocity(_clamp_vector_speed(steered * speed, target_speed * 0.78, target_speed * 1.42))
	last_direction_shift_msec = Time.get_ticks_msec()
	if randf() < 0.08 * strength:
		_spawn_particles(ball_position, Color(String(skin_profile.get("color", "#00f0ff"))), 1, 34.0)


func _safe_motion_angle(angle: float) -> float:
	var vector := Vector2(cos(angle), sin(angle))
	if abs(vector.y) < MIN_DIRECTION_COMPONENT:
		vector.y = MIN_DIRECTION_COMPONENT * (-1.0 if vector.y < 0.0 else 1.0)
	if abs(vector.x) < MIN_DIRECTION_COMPONENT * 0.65:
		vector.x = MIN_DIRECTION_COMPONENT * 0.65 * (-1.0 if vector.x < 0.0 else 1.0)
	return _normalize_angle(vector.normalized().angle())


func _stabilize_velocity(value: Vector2) -> Vector2:
	var speed := value.length()
	if speed <= 0.01:
		var random_angle := _safe_motion_angle(randf() * TWO_PI)
		return Vector2(cos(random_angle), sin(random_angle)) * _target_ball_speed()
	var angle := _safe_motion_angle(value.angle())
	return Vector2(cos(angle), sin(angle)) * speed


func _separate_and_reflect(ring: Dictionary, prev_dist: float) -> void:
	var radial := ball_position - arena_center
	var dist: float = max(1.0, radial.length())
	var radial_dir: Vector2 = radial / dist
	var started_outside: bool = prev_dist >= float(ring["radius"])
	var normal: Vector2 = radial_dir if started_outside else -radial_dir
	var safe_distance: float = float(ring["radius"]) + float(ring["thickness"]) / 2.0 + BALL_RADIUS + 2.6 if started_outside else max(0.0, float(ring["radius"]) - float(ring["thickness"]) / 2.0 - BALL_RADIUS - 2.6)
	ball_position = arena_center + radial_dir * min(outer_radius - BALL_RADIUS, safe_distance)
	var dot := ball_velocity.dot(normal)
	if dot < 0.0:
		ball_velocity -= 2.0 * dot * normal
		var target_speed := _target_ball_speed()
		ball_velocity = _stabilize_velocity(_clamp_vector_speed(ball_velocity.rotated(randf_range(-0.15, 0.15)) * 1.04, target_speed * 0.88, target_speed * 1.55))
		last_direction_shift_msec = Time.get_ticks_msec()


func _is_ball_crushed() -> bool:
	var now := Time.get_ticks_msec()
	for ring in rings:
		if String(ring.get("status", "")) != "active" or int(ring.get("hp", 0)) <= 0:
			continue
		if now < int(ring.get("defeat_grace_until", 0)):
			continue
		var collision := _check_ring_collision(ring)
		if bool(collision["gap"]) or not bool(collision["overlap"]):
			continue
		var dist := (ball_position - arena_center).length()
		var outer_edge := float(ring["radius"]) + float(ring["thickness"]) / 2.0
		if outer_edge <= max(0.0, dist - BALL_RADIUS * 0.25) or (dist <= BALL_RADIUS * 1.15 and outer_edge <= BALL_RADIUS + 4.0):
			return true
	return false


func _finish_victory() -> void:
	finished = true
	var profile_xp_reward := _run_profile_xp() * reward_multiplier
	var global_coins_reward := _global_coins_from_run(run_coins * reward_multiplier, best_combo, true)
	var diamond_reward := run_diamonds * reward_multiplier
	GameState.record_phase_complete(phase_id, global_coins_reward, profile_xp_reward, rings_destroyed, perfect_escapes, run_diamonds * reward_multiplier, best_combo, criticals, skin_effects, run_upgrades)
	pending_result_reward = { "coins": global_coins_reward, "xp": profile_xp_reward, "diamonds": diamond_reward, "manual_quit": false, "victory": true }
	_spawn_particles(arena_center, Color("#00ff88"), 42, 180.0)
	_play_sfx("victory")
	_victory_title.text = "FASE %s CONCLUIDA" % phase_id
	_rebuild_victory_rewards(global_coins_reward, profile_xp_reward)
	if _victory_unlock_label:
		_victory_unlock_label.text = "PROXIMA FASE LIBERADA" if phase_id < LevelData.MAX_PHASE else "TODAS AS FASES CONCLUIDAS"
	if _victory_next_button:
		_victory_next_button.disabled = phase_id >= LevelData.MAX_PHASE
		_victory_next_button.text = "PROXIMA FASE" if phase_id < LevelData.MAX_PHASE else "CONCLUIDO"
	if _victory_double_button:
		_victory_double_button.visible = _can_double_result_reward()
		_victory_double_button.disabled = false
	_victory_overlay.visible = true
	queue_redraw()


func _finish_defeat() -> void:
	finished = true
	_play_sfx("defeat")
	if is_infinite:
		var global_coins_reward := _global_coins_from_run(run_coins, best_combo, false)
		var profile_xp_reward := _run_profile_xp()
		var previous_best_seconds := int(GameState.data.get("stats", {}).get("bestInfiniteSeconds", 0))
		var summary := {
			"seconds": floori(infinite_elapsed),
			"rings": rings_destroyed,
			"coins": global_coins_reward,
			"xp": profile_xp_reward,
			"diamonds": run_diamonds,
			"score": infinite_score,
			"best_combo": best_combo,
			"criticals": criticals,
			"skin_effects": skin_effects,
			"run_upgrades": run_upgrades,
			"run_level": run_level,
			"new_record": floori(infinite_elapsed) > previous_best_seconds,
		}
		GameState.record_infinite_run(summary)
		pending_result_reward = { "coins": global_coins_reward, "xp": profile_xp_reward, "diamonds": run_diamonds, "manual_quit": false, "victory": false }
		_rebuild_defeat_summary(summary)
	elif _defeat_summary:
		pending_result_reward = {}
		_rebuild_defeat_summary({})
	if _defeat_revive_button:
		_defeat_revive_button.visible = not bool(pending_result_reward.get("manual_quit", false))
	if _defeat_double_button:
		_defeat_double_button.visible = _can_double_result_reward()
		_defeat_double_button.disabled = false
	_defeat_overlay.visible = true
	queue_redraw()


func _revive_with_ad() -> void:
	if revive_used or not finished:
		return
	GameState.show_mock_rewarded_ad(func(ok: bool) -> void:
		if not ok:
			return
		revive_used = true
		finished = false
		is_paused = false
		_defeat_overlay.visible = false
		ball_position = arena_center
		ball_velocity = Vector2(_target_ball_speed(), -_target_ball_speed() * 0.72)
		last_hit_msec = 0
		for i in range(rings.size()):
			var ring := rings[i]
			if String(ring.get("status", "")) == "active":
				ring["radius"] = max(float(ring.get("radius", INNER_RADIUS)), (ball_position - arena_center).length() + MIN_SPAWN_DISTANCE_FROM_BALL)
				rings[i] = ring
		_spawn_particles(ball_position, Color("#00f0ff"), 28, 150.0)
		_spawn_floating("Revive", ball_position + Vector2(-20, -34), Color("#00f0ff"))
		_play_sfx("level_up")
	)


func _draw_arena() -> void:
	pass


func _draw_rings() -> void:
	for ring in rings:
		if String(ring.get("status", "")) != "active":
			continue
		var radius := float(ring["radius"])
		var color := Color(String(ring["color"]))
		if not String(ring.get("effect_color", "")).is_empty():
			color = Color(String(ring.get("effect_color", "")))
		var thickness := float(ring["thickness"])
		if String(ring.get("type", "normal")) == "solid":
			draw_arc(arena_center, radius, 0.0, TWO_PI, 180, Color(color, 0.28), thickness + 7.0, true)
			draw_arc(arena_center, radius, 0.0, TWO_PI, 180, color, thickness, true)
		else:
			var gap_center := _normalize_angle(float(ring["gap_start"]) + float(ring["rotation"]))
			var half_gap := float(ring["gap_size"]) / 2.0
			_draw_ring_segment(radius, gap_center + half_gap, gap_center - half_gap + TWO_PI, color, thickness)


func _draw_ring_segment(radius: float, start_angle: float, end_angle: float, color: Color, thickness: float) -> void:
	draw_arc(arena_center, radius, start_angle, end_angle, 150, Color(color, 0.24), thickness + 7.0, true)
	draw_arc(arena_center, radius, start_angle, end_angle, 150, color, thickness, true)


func _draw_ball() -> void:
	var skin_glow := Color(String(skin_profile.get("color", "#00f0ff")))
	draw_circle(ball_position, BALL_RADIUS + 12.0, Color(skin_glow, 0.16))
	draw_circle(ball_position, BALL_RADIUS + 5.0, Color("#ffffff22"))
	var rect := Rect2(ball_position - Vector2(BALL_RADIUS, BALL_RADIUS) * 1.65, Vector2(BALL_RADIUS, BALL_RADIUS) * 3.3)
	if _skin_texture:
		draw_texture_rect(_skin_texture, rect, false)
	else:
		draw_circle(ball_position, BALL_RADIUS, Color("#00f0ff"))


func _draw_effects() -> void:
	for point in trail_points:
		draw_circle(point["position"], float(point["size"]), Color(String(point.get("color", "#00f0ff")), float(point["life"]) * 0.22))
	for particle in particles:
		draw_circle(particle["position"], float(particle["size"]), Color(particle["color"], float(particle["life"])))


func _draw_floating_feedback() -> void:
	for item in floating_feedback:
		draw_string(_bold_font, item["position"], String(item["text"]), HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color(item["color"], float(item["life"])))


func _build_background() -> void:
	var background := TextureRect.new()
	_background_texture_rect = background
	_fill(background)
	background.texture = _make_background_gradient()
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.show_behind_parent = true
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)


func _build_hud() -> void:
	var hud := VBoxContainer.new()
	hud.anchor_left = 0.0
	hud.anchor_top = 0.0
	hud.anchor_right = 1.0
	hud.offset_left = 18.0
	hud.offset_top = 42.0
	hud.offset_right = -18.0
	hud.add_theme_constant_override("separation", 8)
	add_child(hud)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	hud.add_child(top)
	var pause := _make_button("PAUSAR", 96, 40)
	pause.pressed.connect(_open_pause)
	top.add_child(pause)
	_hud_phase = _make_label("FASE %s" % phase_id, 24, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_RIGHT)
	top.add_child(_hud_phase)

	_hud_resources = HBoxContainer.new()
	_hud_resources.add_theme_constant_override("separation", 6)
	hud.add_child(_hud_resources)
	_hud_resources.add_child(_make_resource_badge("coin", "0", "coins"))
	_hud_resources.add_child(_make_resource_badge("gem", "0", "gems"))
	_hud_resources.add_child(_make_resource_badge("coin", "0", "account"))
	_hud_resources.add_child(_make_resource_badge("key", "0", "keys"))

	_hud_meta = _make_label("", 12, "#ffffffaa", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	hud.add_child(_hud_meta)
	_hud_xp = _make_label("", 12, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	hud.add_child(_hud_xp)
	_hud_xp_bar = _make_progress_bar("#00f0ff")
	hud.add_child(_hud_xp_bar)
	_hud_upgrade = HBoxContainer.new()
	_hud_upgrade.add_theme_constant_override("separation", 6)
	_hud_upgrade.visible = false
	_hud_upgrade_icon = _make_icon_texture("upgrade", 18)
	_hud_upgrade.add_child(_hud_upgrade_icon)
	_hud_upgrade_label = _make_label("", 12, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	_hud_upgrade.add_child(_hud_upgrade_label)
	hud.add_child(_hud_upgrade)

	_run_upgrade_bar = HBoxContainer.new()
	_run_upgrade_bar.anchor_left = 0.0
	_run_upgrade_bar.anchor_top = 1.0
	_run_upgrade_bar.anchor_right = 1.0
	_run_upgrade_bar.anchor_bottom = 1.0
	_run_upgrade_bar.offset_left = 12.0
	_run_upgrade_bar.offset_top = -78.0
	_run_upgrade_bar.offset_right = -12.0
	_run_upgrade_bar.offset_bottom = -14.0
	_run_upgrade_bar.add_theme_constant_override("separation", 8)
	add_child(_run_upgrade_bar)
	_run_atk_button = _make_button("", 0, 58)
	_run_atk_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_run_atk_button.add_theme_color_override("font_color", Color("#ffffff"))
	_apply_button_style(_run_atk_button, _make_style("#06162a", 12, "#00f0ffaa", 2, "#00f0ff55", 8))
	_run_atk_button.pressed.connect(_buy_run_atk_upgrade)
	_run_upgrade_bar.add_child(_run_atk_button)
	_run_gold_button = _make_button("", 0, 58)
	_run_gold_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_run_gold_button.add_theme_color_override("font_color", Color("#ffffff"))
	_apply_button_style(_run_gold_button, _make_style("#06162a", 12, "#00f0ffaa", 2, "#00f0ff55", 8))
	_run_gold_button.pressed.connect(_buy_run_gold_upgrade)
	_run_upgrade_bar.add_child(_run_gold_button)


func _build_control_overlay() -> void:
	_control_overlay = HBoxContainer.new()
	_control_overlay.anchor_left = 0.0
	_control_overlay.anchor_top = 1.0
	_control_overlay.anchor_right = 1.0
	_control_overlay.anchor_bottom = 1.0
	_control_overlay.offset_left = 18.0
	_control_overlay.offset_top = -156.0
	_control_overlay.offset_right = -18.0
	_control_overlay.offset_bottom = -92.0
	_control_overlay.add_theme_constant_override("separation", 10)
	_control_overlay.visible = false
	add_child(_control_overlay)

	var left := _make_control_button("<")
	left.button_down.connect(_set_control_left.bind(true))
	left.button_up.connect(_set_control_left.bind(false))
	_control_overlay.add_child(left)

	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	_control_indicator = _make_label("CONTROLE", 11, "#00f0ffaa", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	_control_indicator.add_theme_color_override("font_shadow_color", Color("#00f0ff77"))
	_control_indicator.add_theme_constant_override("shadow_offset_x", 0)
	_control_indicator.add_theme_constant_override("shadow_offset_y", 0)
	center.add_child(_control_indicator)
	_control_overlay.add_child(center)

	var right := _make_control_button(">")
	right.button_down.connect(_set_control_right.bind(true))
	right.button_up.connect(_set_control_right.bind(false))
	_control_overlay.add_child(right)
	_update_control_overlay()


func _make_control_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(72, 58)
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 26)
	button.add_theme_color_override("font_color", Color("#00f0ff"))
	button.add_theme_color_override("font_hover_color", Color("#ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("#001018"))
	_apply_button_style(button, _make_style("#06162add", 18, "#00f0ffaa", 2, "#00f0ff66", 10))
	return button


func _set_control_left(pressed: bool) -> void:
	control_left_down = pressed
	_refresh_control_input()


func _set_control_right(pressed: bool) -> void:
	control_right_down = pressed
	_refresh_control_input()


func _refresh_control_input() -> void:
	control_input = 0.0
	if control_left_down:
		control_input -= 1.0
	if control_right_down:
		control_input += 1.0
	if abs(control_input) > 0.0 and Time.get_ticks_msec() - last_control_sfx_msec > 420:
		last_control_sfx_msec = Time.get_ticks_msec()
		_play_sfx("click")


func _update_control_overlay() -> void:
	if not _control_overlay:
		return
	var should_show := bool(skin_profile.get("control", false)) and not is_paused and not level_up_active and not finished
	_control_overlay.visible = should_show
	if not should_show:
		control_left_down = false
		control_right_down = false
		control_input = 0.0
	if _control_indicator:
		_control_indicator.text = "CONTROLE %s%%" % roundi(float(skin_profile.get("control_strength", 0.0)) * 100.0)


func _build_pause_overlay() -> void:
	_pause_overlay = _make_modal()
	var card := _make_modal_content(_pause_overlay, "PAUSA")
	card.add_child(_make_modal_button("CONTINUAR", _close_pause))
	card.add_child(_make_modal_button("REINICIAR", _restart_level))
	card.add_child(_make_modal_button("SAIR PARA FASES", _go_to_phase_select))
	add_child(_pause_overlay)


func _build_level_up_overlay() -> void:
	_level_up_overlay = _make_modal()
	var card := _make_modal_content(_level_up_overlay, "LEVEL UP", Vector2(326, 454))
	card.add_theme_constant_override("separation", 9)
	card.add_child(_make_label("ESCOLHA UMA MELHORIA", 13, "#ffffffcc", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	_level_up_cards = VBoxContainer.new()
	_level_up_cards.add_theme_constant_override("separation", 6)
	card.add_child(_level_up_cards)
	var reroll_row := HBoxContainer.new()
	reroll_row.add_theme_constant_override("separation", 6)
	card.add_child(reroll_row)
	reroll_row.add_child(_make_modal_button("REROLL AD", _reroll_upgrades_ad))
	reroll_row.add_child(_make_modal_button("REROLL 10♦", _reroll_upgrades_diamond))
	add_child(_level_up_overlay)


func _build_result_overlays() -> void:
	_victory_overlay = _make_modal()
	var victory_card := _make_modal_content(_victory_overlay, "VITORIA")
	_victory_title = _make_label("FASE 1 CONCLUIDA", 24, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	victory_card.add_child(_victory_title)
	_victory_rewards = VBoxContainer.new()
	_victory_rewards.add_theme_constant_override("separation", 8)
	victory_card.add_child(_victory_rewards)
	_victory_unlock_label = _make_label("PROXIMA FASE LIBERADA", 14, "#00ff88", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	victory_card.add_child(_victory_unlock_label)
	_victory_double_button = _make_modal_button("DOBRAR RECOMPENSA - AD", _double_result_reward)
	victory_card.add_child(_victory_double_button)
	victory_card.add_child(_make_modal_button("VOLTAR AS FASES", _go_to_phase_select))
	victory_card.add_child(_make_modal_button("JOGAR NOVAMENTE", _restart_level))
	_victory_next_button = _make_modal_button("PROXIMA FASE", _go_to_next_phase)
	victory_card.add_child(_victory_next_button)
	add_child(_victory_overlay)

	_defeat_overlay = _make_modal()
	var defeat_card := _make_modal_content(_defeat_overlay, "GAME OVER")
	_defeat_title = _make_label("A bolinha foi presa pelos aneis.", 15, "#ffffffcc", _regular_font, HORIZONTAL_ALIGNMENT_CENTER)
	defeat_card.add_child(_defeat_title)
	_defeat_summary = VBoxContainer.new()
	_defeat_summary.add_theme_constant_override("separation", 8)
	defeat_card.add_child(_defeat_summary)
	_defeat_double_button = _make_modal_button("DOBRAR RECOMPENSA - AD", _double_result_reward)
	defeat_card.add_child(_defeat_double_button)
	_defeat_revive_button = _make_modal_button("REVIVER COM ANUNCIO", _revive_with_ad)
	defeat_card.add_child(_defeat_revive_button)
	defeat_card.add_child(_make_modal_button("TENTAR DE NOVO", _restart_level))
	defeat_card.add_child(_make_modal_button("SAIR PARA FASES", _go_to_phase_select))
	add_child(_defeat_overlay)
	_hide_all_overlays()


func _make_modal() -> PanelContainer:
	var overlay := PanelContainer.new()
	_fill(overlay)
	overlay.visible = false
	overlay.add_theme_stylebox_override("panel", _make_style("#050014cc", 0))
	return overlay


func _make_modal_content(overlay: Control, title: String, panel_size: Vector2 = Vector2(320, 260)) -> VBoxContainer:
	var center := CenterContainer.new()
	_fill(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = panel_size
	panel.add_theme_stylebox_override("panel", _make_style("#16003bdd", 18, "#00f0ff66", 2, "#00f0ff55", 18))
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18 if panel_size.y > 420.0 else 24)
	margin.add_theme_constant_override("margin_top", 16 if panel_size.y > 420.0 else 22)
	margin.add_theme_constant_override("margin_right", 18 if panel_size.y > 420.0 else 24)
	margin.add_theme_constant_override("margin_bottom", 16 if panel_size.y > 420.0 else 22)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 10 if panel_size.y > 420.0 else 14)
	margin.add_child(column)
	column.add_child(_make_label(title, 24 if panel_size.y > 420.0 else 26, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	overlay.add_child(center)
	return column


func _make_modal_button(text: String, target: Callable) -> Button:
	var button := _make_button(text, 0, 42)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(target)
	return button


func _make_resource_badge(icon_key: String, value: String, label_key: String) -> PanelContainer:
	var badge := PanelContainer.new()
	badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	badge.custom_minimum_size = Vector2(0, 38)
	badge.add_theme_stylebox_override("panel", _make_style("#ffffff11", 10, "#ffffff22", 1, "#00f0ff33", 5))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 7)
	margin.add_theme_constant_override("margin_right", 7)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	badge.add_child(margin)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 5)
	margin.add_child(row)
	row.add_child(_make_icon_texture(icon_key, 20))
	var label := _make_label(value, 13, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	_resource_labels[label_key] = label
	return badge


func _set_resource_value(key: String, value: int) -> void:
	if _resource_labels.has(key):
		var label: Label = _resource_labels[key]
		label.text = str(value)


func _make_icon_texture(icon_key: String, icon_size: int) -> TextureRect:
	var icon := TextureRect.new()
	var path := String(ICON_PATHS.get(icon_key, ICON_PATHS["upgrade"]))
	if ResourceLoader.exists(path):
		icon.texture = load(path)
	icon.custom_minimum_size = Vector2(icon_size, icon_size)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon


func _make_button(text: String, width: int, height: int) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(width, height)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color("#001018"))
	_apply_button_style(button, _make_style("#00f0ff", 13, "#ffffff33", 1, "#00f0ff88", 10))
	return button


func _make_progress_bar(fill_color: String) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 14)
	bar.show_percentage = false
	bar.max_value = 100
	bar.value = 0
	bar.add_theme_stylebox_override("background", _make_style("#ffffff11", 7, "#ffffff22", 1))
	bar.add_theme_stylebox_override("fill", _make_style(fill_color, 7, "#ffffff22", 0, fill_color, 6))
	return bar


func _update_hud() -> void:
	var active: int = _active_ring_count()
	_hud_phase.text = "INFINITO" if is_infinite else "FASE %s" % phase_id
	_set_resource_value("coins", run_coins)
	_set_resource_value("gems", run_diamonds)
	_set_resource_value("account", int(GameState.data.get("coins", 0)))
	_set_resource_value("keys", int(GameState.data.get("keys", 0)))
	var difficulty_text := "INFINITO Lv.%s" % infinite_level if is_infinite else String(phase_config["difficulty"]).to_upper()
	var combo_text := "   COMBO x%s" % combo if combo >= 2 else ""
	if is_infinite:
		_hud_meta.text = "TEMPO %s   %s%s" % [_format_time(floori(infinite_elapsed)), difficulty_text, combo_text]
	else:
		_hud_meta.text = "DIFICULDADE: %s%s" % [difficulty_text, combo_text]
	var xp_needed := _run_xp_needed_for_level(run_level)
	_hud_xp.text = "LV.%s   XP %s/%s   +%s XP" % [run_level, run_xp, xp_needed, run_xp]
	_hud_xp_bar.max_value = xp_needed
	_hud_xp_bar.value = run_xp
	_hud_upgrade.visible = not temporary_upgrade.is_empty()
	if _hud_upgrade.visible:
		var upgrade_icon_key := String(temporary_upgrade.get("icon_key", "upgrade"))
		var icon_path := String(ICON_PATHS.get(upgrade_icon_key, ICON_PATHS["upgrade"]))
		if ResourceLoader.exists(icon_path):
			_hud_upgrade_icon.texture = load(icon_path)
		_hud_upgrade_label.text = String(temporary_upgrade.get("short", temporary_upgrade.get("effect", "")))
	_update_run_upgrade_buttons()


func _format_time(seconds: int) -> String:
	var safe_seconds: int = maxi(0, seconds)
	return "%02d:%02d" % [floori(float(safe_seconds) / 60.0), safe_seconds % 60]


func _active_ring_count() -> int:
	var count := 0
	for ring in rings:
		if String(ring.get("status", "")) == "active" and int(ring.get("hp", 0)) > 0:
			count += 1
	return count


func _safe_spawn_radius(preferred_radius: float, active_rings: Array = []) -> float:
	var result := _find_safe_ring_spawn_radius(preferred_radius, active_rings)
	return float(result.get("radius", clampf(preferred_radius, _playable_ring_min_radius(), _playable_ring_max_radius())))


func _find_safe_ring_spawn_radius(preferred_radius: float, active_rings: Array = []) -> Dictionary:
	var references: Array = active_rings if not active_rings.is_empty() else rings
	return get_safe_ring_spawn_radius(_ball_spawn_state(), references, preferred_radius)


func _find_outer_spawn_radius(active_rings: Array = []) -> Dictionary:
	var max_radius := _playable_ring_max_radius()
	return { "ok": true, "radius": max_radius }


func _ball_spawn_state() -> Dictionary:
	return {
		"position": ball_position,
		"previous_position": previous_ball_position,
		"velocity": ball_velocity,
		"radius": BALL_RADIUS,
		"center": arena_center,
	}


func _playable_ring_min_radius() -> float:
	return INNER_RADIUS


func _playable_ring_max_radius() -> float:
	return max(INNER_RADIUS + MIN_RING_SPACING * 2.0, min(outer_radius - PLAYABLE_RING_MARGIN, outer_radius * PLAYABLE_RING_RADIUS_FACTOR))


func get_safe_ring_spawn_radius(ball_state: Dictionary, active_rings: Array, preferred_radius: float) -> Dictionary:
	var min_radius := _playable_ring_min_radius()
	var max_radius := _playable_ring_max_radius()
	var position: Vector2 = ball_state.get("position", arena_center)
	var velocity: Vector2 = ball_state.get("velocity", Vector2.RIGHT)
	var ball_dist: float = (position - arena_center).length()
	var radial_dir := (position - arena_center).normalized() if ball_dist > 0.01 else velocity.normalized()
	var radial_speed := velocity.dot(radial_dir)
	var inward_first := radial_speed < 0.0 or ball_dist > max_radius - MIN_SPAWN_DISTANCE_FROM_BALL
	var candidates: Array[float] = []
	_add_spawn_candidate(candidates, preferred_radius, min_radius, max_radius)
	_add_spawn_candidate(candidates, _projected_reachable_radius(preferred_radius, min_radius, max_radius), min_radius, max_radius)
	var offsets := [MIN_SPAWN_DISTANCE_FROM_BALL + 4.0, 48.0, 68.0, 88.0, MAX_SPAWN_DISTANCE_FROM_BALL]
	for offset in offsets:
		if inward_first:
			_add_spawn_candidate(candidates, ball_dist - offset, min_radius, max_radius)
			_add_spawn_candidate(candidates, ball_dist + offset, min_radius, max_radius)
		else:
			_add_spawn_candidate(candidates, ball_dist + offset, min_radius, max_radius)
			_add_spawn_candidate(candidates, ball_dist - offset, min_radius, max_radius)
	for factor in [0.32, 0.42, 0.52, 0.62, 0.72]:
		_add_spawn_candidate(candidates, outer_radius * factor, min_radius, max_radius)
	for radius in candidates:
		var ring_data := clamp_ring_to_playable_area({ "radius": radius, "thickness": 5.0 })
		if can_spawn_ring_safely(ring_data, active_rings, ball_state):
			return { "ok": true, "radius": float(ring_data["radius"]) }
	for i in range(18):
		var radius := randf_range(min_radius, max_radius)
		var ring_data := clamp_ring_to_playable_area({ "radius": radius, "thickness": 5.0 })
		if can_spawn_ring_safely(ring_data, active_rings, ball_state):
			return { "ok": true, "radius": float(ring_data["radius"]) }
	var sweep_offsets: Array[float] = []
	var step: float = max(4.0, MIN_RING_SPACING * 0.55)
	var search_limit: float = max_radius - min_radius
	var steps: int = ceili(search_limit / step)
	for i in range(steps + 1):
		var offset: float = MIN_SPAWN_DISTANCE_FROM_BALL + float(i) * step
		sweep_offsets.append(offset)
	for offset in sweep_offsets:
		var first_radius: float = ball_dist - offset if inward_first else ball_dist + offset
		var second_radius: float = ball_dist + offset if inward_first else ball_dist - offset
		for value in [first_radius, second_radius]:
			var ring_data := clamp_ring_to_playable_area({ "radius": value, "thickness": 5.0 })
			if can_spawn_ring_safely(ring_data, active_rings, ball_state):
				return { "ok": true, "radius": float(ring_data["radius"]) }
	return {
		"ok": false,
		"radius": clampf(ball_dist + (-MIN_SPAWN_DISTANCE_FROM_BALL if inward_first else MIN_SPAWN_DISTANCE_FROM_BALL), min_radius, max_radius),
	}


func _add_spawn_candidate(candidates: Array[float], value: float, min_radius: float, max_radius: float) -> void:
	var radius := clampf(value, min_radius, max_radius)
	for existing in candidates:
		if abs(float(existing) - radius) < MIN_RING_SPACING * 0.5:
			return
	candidates.append(radius)


func clamp_ring_to_playable_area(ring_data: Dictionary) -> Dictionary:
	ring_data["radius"] = clampf(float(ring_data.get("radius", INNER_RADIUS)), _playable_ring_min_radius(), _playable_ring_max_radius())
	return ring_data


func _projected_reachable_radius(preferred_radius: float, min_radius: float, max_radius: float) -> float:
	var from_center: Vector2 = ball_position - arena_center
	var future: Vector2 = ball_position + ball_velocity.normalized() * min(SPAWN_LOOKAHEAD_DISTANCE, outer_radius * 0.52)
	var future_dist: float = (future - arena_center).length()
	var low: float = min(from_center.length(), future_dist) - BALL_RADIUS * 1.5
	var high: float = max(from_center.length(), future_dist) + BALL_RADIUS * 4.0
	if high < min_radius or low > max_radius:
		return clampf(preferred_radius, min_radius, max_radius)
	return clampf(preferred_radius, max(min_radius, low), min(max_radius, high))


func can_spawn_ring_safely(ring_data: Dictionary, active_rings: Array, ball_state: Dictionary) -> bool:
	var radius := float(ring_data.get("radius", INNER_RADIUS))
	if radius < _playable_ring_min_radius() or radius > _playable_ring_max_radius():
		return false
	var position: Vector2 = ball_state.get("position", ball_position)
	var ball_dist: float = (position - arena_center).length()
	var distance: float = abs(radius - ball_dist)
	if distance < MIN_SPAWN_DISTANCE_FROM_BALL * 0.86 or distance > MAX_SPAWN_DISTANCE_FROM_BALL:
		return false
	if not is_ring_reachable_by_ball(ring_data, ball_state):
		return false
	for ring in active_rings:
		if String(ring.get("status", "")) != "active":
			continue
		if abs(float(ring.get("radius", 0.0)) - radius) < MIN_RING_SPACING + float(ring.get("thickness", 5.0)) * 0.5:
			return false
	return true


func _can_spawn_ring_safely(radius: float, min_radius: float, max_radius: float) -> bool:
	if radius < min_radius or radius > max_radius:
		return false
	return can_spawn_ring_safely({ "radius": radius, "thickness": 5.0 }, rings, _ball_spawn_state())


func is_ring_reachable_by_ball(ring_data: Dictionary, ball_state: Dictionary) -> bool:
	var radius := float(ring_data.get("radius", INNER_RADIUS))
	var position: Vector2 = ball_state.get("position", ball_position)
	var previous_position: Vector2 = ball_state.get("previous_position", previous_ball_position)
	var velocity: Vector2 = ball_state.get("velocity", ball_velocity)
	var ball_radius := float(ball_state.get("radius", BALL_RADIUS))
	var current_dist := (position - arena_center).length()
	var previous_dist := (previous_position - arena_center).length()
	var future: Vector2 = position + velocity.normalized() * min(SPAWN_LOOKAHEAD_DISTANCE, MAX_SPAWN_DISTANCE_FROM_BALL)
	var future_dist: float = (future - arena_center).length()
	var low: float = min(current_dist, min(previous_dist, future_dist)) - ball_radius * 2.0
	var high: float = max(current_dist, max(previous_dist, future_dist)) + ball_radius * 6.0
	if radius >= low and radius <= high:
		return true
	if current_dist < INNER_RADIUS * 0.75 and radius <= min(_playable_ring_max_radius(), MAX_SPAWN_DISTANCE_FROM_BALL):
		return true
	return abs(radius - current_dist) <= MAX_SPAWN_DISTANCE_FROM_BALL * 0.82


func _align_ring_gap_to_ball(ring: Dictionary) -> Dictionary:
	if String(ring.get("type", "normal")) == "solid":
		return ring
	var aim := ball_velocity.normalized()
	if aim.length() <= 0.01:
		aim = (ball_position - arena_center).normalized()
	var target_angle := _normalize_angle((ball_position + aim * max(24.0, float(ring.get("radius", INNER_RADIUS)) - (ball_position - arena_center).length()) - arena_center).angle())
	ring["gap_start"] = _normalize_angle(target_angle - float(ring.get("rotation", 0.0)) + randf_range(-0.18, 0.18))
	return ring


func _randomize_ring_gap(ring: Dictionary) -> Dictionary:
	if String(ring.get("type", "normal")) == "solid":
		return ring
	ring["gap_start"] = _normalize_angle(randf() * TWO_PI - float(ring.get("rotation", 0.0)))
	return ring


func _base_damage() -> int:
	var upgrades: Dictionary = GameState.data.get("permanent_upgrades", {})
	var base_damage := 10.0 * pow(1.1, int(upgrades.get("baseDamage", 0)))
	var temporary_damage := int(current_upgrades.get("damage", 0)) * 0.15
	var skin_bonus := _skin_damage_bonus()
	var arena_bonus := int(run_shop_upgrades.get("atk", 0)) * 0.12
	return max(1, roundi(base_damage * (1.0 + skin_bonus + arena_bonus + temporary_damage)))


func _target_ball_speed() -> float:
	var difficulty_speed: float = min(0.62, float(phase_id - 1) * 0.08)
	if is_infinite:
		difficulty_speed = min(1.05, 0.18 + float(infinite_level - 1) * 0.025)
	return (BASE_BALL_SPEED + difficulty_speed) * _speed_multiplier()


func _speed_multiplier() -> float:
	var upgrades: Dictionary = GameState.data.get("permanent_upgrades", {})
	var base_speed := 100.0 * pow(1.08, int(upgrades.get("baseSpeed", 0)))
	var temporary_speed := int(current_upgrades.get("speed", 0)) * 0.20
	return 1.0 + base_speed / 1200.0 + _skin_speed_bonus() + temporary_speed + int(current_upgrades.get("ricochet", 0)) * 0.025


func _gold_multiplier() -> float:
	var upgrades: Dictionary = GameState.data.get("permanent_upgrades", {})
	var base := 1.0 + int(upgrades.get("coinMultiplier", 0)) * 0.15
	var temporary_gold := int(current_upgrades.get("coinBoost", 0)) * 0.5
	return base * (1.0 + int(run_shop_upgrades.get("gold", 0)) * 0.12 + _skin_coin_bonus() + temporary_gold)


func _xp_multiplier() -> float:
	var upgrades: Dictionary = GameState.data.get("permanent_upgrades", {})
	var base := 1.0 + int(upgrades.get("xpBoost", 0)) * 0.2
	var temporary_xp := int(current_upgrades.get("xpBoost", 0)) * 0.5
	return base * (1.0 + int(run_shop_upgrades.get("gold", 0)) * 0.05 + _skin_xp_bonus() + temporary_xp)


func _crit_chance() -> float:
	var upgrades: Dictionary = GameState.data.get("permanent_upgrades", {})
	return 5.0 + int(upgrades.get("critChance", 0)) * 2.0 + int(current_upgrades.get("critical", 0)) * 5.0 + _skin_crit_bonus()


func _crit_damage() -> float:
	return 2.0 + int(current_upgrades.get("criticalOverload", 0)) * 0.3


func _perfect_diamond_bonus() -> float:
	var skin_id := String(GameState.data.get("equipped_skin", "neon_blue"))
	var permanent_upgrades: Dictionary = GameState.data.get("permanent_upgrades", {})
	var temporary_bonus := int(current_upgrades.get("perfectChance", 0)) * 0.01
	var permanent_bonus := int(permanent_upgrades.get("perfectChance", 0)) * 0.01
	if skin_id == "neon_blue":
		return 0.005 + temporary_bonus + permanent_bonus
	if skin_id in ["star_rare", "planet", "crystal", "alien_rare", "purple_crystal", "cosmic_eye", "astral_eye"]:
		return 0.02 + temporary_bonus + permanent_bonus
	return temporary_bonus + permanent_bonus


func _skin_damage_bonus() -> float:
	var skin_id := String(GameState.data.get("equipped_skin", "neon_blue"))
	if skin_id in ["bear_common", "moon", "meteor_rare", "astral_dragon", "wolf_rare"]:
		return 0.08
	return 0.0


func _skin_coin_bonus() -> float:
	var skin_id := String(GameState.data.get("equipped_skin", "neon_blue"))
	if skin_id in ["piggy", "cow_common", "ladybug_common", "cosmic_emperor"]:
		return 0.08
	return 0.0


func _skin_xp_bonus() -> float:
	var skin_id := String(GameState.data.get("equipped_skin", "neon_blue"))
	if skin_id in ["monkey", "panda", "neon_heart"]:
		return 0.08
	return 0.0


func _skin_speed_bonus() -> float:
	var skin_id := String(GameState.data.get("equipped_skin", "neon_blue"))
	if skin_id in ["bunny", "fox_common", "fish_common", "comet", "ninja_rare", "blue_comet"]:
		return 0.08
	return 0.0


func _skin_crit_bonus() -> float:
	var skin_id := String(GameState.data.get("equipped_skin", "neon_blue"))
	if skin_id in ["kitty", "tiger_common", "bee_common"]:
		return 3.0
	return 0.0


func _try_apply_skin_effect(ring_index: int, trigger: String) -> int:
	if ring_index < 0 or ring_index >= rings.size():
		return 0
	var effect := String(skin_profile.get("effect", "trail"))
	var chance := float(skin_profile.get("chance", 0.0))
	if trigger == "perfect":
		chance *= 0.65
	if randf() > chance:
		return 0
	skin_effects += 1
	return _apply_effect_to_ring(ring_index, effect, float(skin_profile.get("value", 0.0)), Color(String(skin_profile.get("color", "#00f0ff"))), "skin")


func _try_apply_upgrade_effects(ring_index: int, trigger: String, base_damage_value: int) -> int:
	var bonus_damage := 0
	if int(current_upgrades.get("frost", 0)) > 0 and randf() < 0.22 + int(current_upgrades.get("frost", 0)) * 0.04:
		bonus_damage += _apply_effect_to_ring(ring_index, "freeze", 0.48, Color("#9be8ff"), "upgrade")
	if int(current_upgrades.get("timeFreeze", 0)) > 0 or int(current_upgrades.get("chronoBreak", 0)) > 0:
		var time_level := int(current_upgrades.get("timeFreeze", 0)) + int(current_upgrades.get("chronoBreak", 0))
		if randf() < 0.08 + time_level * 0.035:
			_apply_time_freeze(1300 + time_level * 240)
	if int(current_upgrades.get("burn", 0)) > 0:
		bonus_damage += floori(max(1, base_damage_value) * (0.26 + int(current_upgrades.get("burn", 0)) * 0.08))
		_apply_effect_to_ring(ring_index, "burn", 0.22, Color("#ff8800"), "upgrade")
	if int(current_upgrades.get("penetration", 0)) > 0:
		bonus_damage += floori(max(1, base_damage_value) * (0.18 + int(current_upgrades.get("penetration", 0)) * 0.05))
		_apply_effect_to_ring(ring_index, "poison", 0.18, Color("#39ff14"), "upgrade")
	var repulse_level := int(current_upgrades.get("ringRepulse", 0))
	if repulse_level > 0 and trigger == "hit" and _can_trigger_upgrade_effect("ringRepulse", 0.10 + repulse_level * 0.035, max(720, 1500 - repulse_level * 110)):
		_mark_upgrade_effect_triggered("ringRepulse")
		_apply_effect_to_ring(ring_index, "repulse", 8.0 + repulse_level * 2.5, Color("#c084fc"), "upgrade")
	if int(current_upgrades.get("chainLightning", 0)) > 0 and randf() < 0.16 + int(current_upgrades.get("chainLightning", 0)) * 0.035:
		_apply_effect_to_ring(ring_index, "chain", 0.30, Color("#38bdf8"), "upgrade")
	if int(current_upgrades.get("shockwave", 0)) > 0 or int(current_upgrades.get("voidPulse", 0)) > 0:
		var area_level := int(current_upgrades.get("shockwave", 0)) + int(current_upgrades.get("voidPulse", 0))
		if trigger == "break" or randf() < 0.08 + area_level * 0.03:
			bonus_damage += _apply_effect_to_ring(ring_index, "area", 0.30 + area_level * 0.04, Color("#7c3aed"), "upgrade")
	if int(current_upgrades.get("laserCut", 0)) > 0 or int(current_upgrades.get("laser", 0)) > 0:
		var laser_level := int(current_upgrades.get("laserCut", 0)) + int(current_upgrades.get("laser", 0))
		if randf() < 0.10 + laser_level * 0.025:
			bonus_damage += max(1, floori(max(1, base_damage_value) * (0.55 + laser_level * 0.12)))
	if int(current_upgrades.get("chainBreak", 0)) > 0 and trigger == "break":
		bonus_damage += _apply_effect_to_ring(ring_index, "chain", 0.42 + int(current_upgrades.get("chainBreak", 0)) * 0.06, Color("#ffd700"), "upgrade")
	return bonus_damage


func _can_trigger_upgrade_effect(id: String, chance: float, cooldown_ms: int) -> bool:
	var now := Time.get_ticks_msec()
	var ready_at := int(upgrade_effect_cooldowns.get(id, 0))
	if now < ready_at:
		return false
	return randf() < clampf(chance, 0.0, 0.65)


func _mark_upgrade_effect_triggered(id: String, cooldown_ms := -1) -> void:
	var level := int(current_upgrades.get(id, 0))
	var duration := cooldown_ms
	if duration < 0:
		duration = max(720, 1500 - level * 110)
	upgrade_effect_cooldowns[id] = Time.get_ticks_msec() + duration


func _apply_effect_to_ring(ring_index: int, effect: String, value: float, color: Color, source: String) -> int:
	if ring_index < 0 or ring_index >= rings.size():
		return 0
	var ring := rings[ring_index]
	if String(ring.get("status", "")) != "active":
		return 0
	var bonus_damage := 0
	match effect:
		"freeze":
			ring["effect_color"] = "#9be8ff"
			ring["effect_until"] = Time.get_ticks_msec() + 1850
			ring["rotation_multiplier"] = clampf(1.0 - max(value, 0.34), 0.28, 0.72)
			ring["closing_multiplier"] = 0.72
			_spawn_particles(ball_position, color, 10, 80.0)
			_spawn_floating("Freeze", ball_position + Vector2(8, -30), color)
		"burn":
			bonus_damage = max(1, floori(float(_base_damage()) * max(0.20, value)))
			ring["effect_color"] = "#ff8800"
			ring["effect_until"] = Time.get_ticks_msec() + 1150
			_spawn_particles(ball_position, color, 12, 105.0)
			_spawn_floating("Burn +%s" % bonus_damage, ball_position + Vector2(6, -32), color)
		"poison":
			bonus_damage = max(1, floori(float(_base_damage()) * max(0.16, value)))
			ring["effect_color"] = "#39ff14"
			ring["effect_until"] = Time.get_ticks_msec() + 1350
			_spawn_particles(ball_position, color, 10, 95.0)
			_spawn_floating("Poison +%s" % bonus_damage, ball_position + Vector2(6, -32), color)
		"chain":
			bonus_damage = _damage_neighbor_ring(ring_index, max(1, floori(float(_base_damage()) * max(0.25, value))), color)
			_spawn_particles(ball_position, color, 14, 120.0)
		"area":
			bonus_damage = _damage_area_rings(ring_index, max(1, floori(float(_base_damage()) * max(0.24, value))), color)
			_spawn_particles(ball_position, color, 18, 125.0)
		"repulse":
			ring["radius"] = min(_playable_ring_max_radius(), float(ring["radius"]) + max(6.0, value))
			ring["effect_color"] = "#c084fc"
			ring["effect_until"] = Time.get_ticks_msec() + 900
			_spawn_particles(ball_position, color, 9, 95.0)
		"coin":
			_award_coins(max(3, floori(value)))
			_spawn_particles(ball_position, color, 8, 80.0)
		"xp":
			_award_xp(max(4, floori(value)))
			_spawn_particles(ball_position, color, 8, 80.0)
		"speed":
			ball_velocity = _stabilize_velocity(ball_velocity * (1.0 + clampf(value, 0.03, 0.12)))
			_spawn_particles(ball_position, color, 8, 90.0)
		"crit":
			bonus_damage = max(1, floori(float(_base_damage()) * max(0.25, value)))
			_spawn_particles(ball_position, color, 10, 100.0)
		_:
			_spawn_particles(ball_position, color, 5, 70.0)
	rings[ring_index] = ring
	return bonus_damage


func _apply_time_freeze(duration_ms: int) -> void:
	var until := Time.get_ticks_msec() + duration_ms
	for i in range(rings.size()):
		var ring := rings[i]
		if String(ring.get("status", "")) != "active":
			continue
		ring["effect_color"] = "#9be8ff"
		ring["effect_until"] = until
		ring["rotation_multiplier"] = 0.22
		ring["closing_multiplier"] = 0.55
		rings[i] = ring
	_spawn_particles(ball_position, Color("#9be8ff"), 18, 130.0)
	_spawn_floating("Time Freeze", ball_position + Vector2(-30, -40), Color("#9be8ff"))


func _skin_can_phase_collision(ring: Dictionary) -> bool:
	if String(skin_profile.get("effect", "")) != "phase":
		return false
	if randf() > float(skin_profile.get("chance", 0.0)):
		return false
	skin_effects += 1
	return true


func _damage_neighbor_ring(source_index: int, amount: int, color: Color) -> int:
	var best_index := -1
	var best_distance := INF
	for i in range(rings.size()):
		if i == source_index:
			continue
		var ring := rings[i]
		if String(ring.get("status", "")) != "active":
			continue
		var dist: float = abs(float(ring.get("radius", 0.0)) - float(rings[source_index].get("radius", 0.0)))
		if dist < best_distance:
			best_distance = dist
			best_index = i
	if best_index < 0:
		return 0
	var ring := rings[best_index]
	ring["hp"] = max(0, int(ring.get("hp", 0)) - amount)
	ring["effect_color"] = "#38bdf8"
	ring["effect_until"] = Time.get_ticks_msec() + 850
	if int(ring["hp"]) <= 0:
		ring["status"] = "broken"
		rings_destroyed += 1
		_register_ring_clear()
		_award_coins(max(3, floori(8.0 * _gold_multiplier())))
		_award_xp(floori(8.0 * _xp_multiplier()))
	rings[best_index] = ring
	_spawn_floating("Chain", ball_position + Vector2(-24, -36), color)
	return amount


func _damage_area_rings(source_index: int, amount: int, color: Color) -> int:
	var total := 0
	var source_radius := float(rings[source_index].get("radius", 0.0))
	for i in range(rings.size()):
		if i == source_index:
			continue
		var ring := rings[i]
		if String(ring.get("status", "")) != "active":
			continue
		if abs(float(ring.get("radius", 0.0)) - source_radius) > MIN_RING_SPACING * 2.2:
			continue
		ring["hp"] = max(0, int(ring.get("hp", 0)) - amount)
		ring["effect_color"] = "#7c3aed"
		ring["effect_until"] = Time.get_ticks_msec() + 900
		if int(ring["hp"]) <= 0:
			ring["status"] = "broken"
			rings_destroyed += 1
			_register_ring_clear()
			_award_coins(max(3, floori(6.0 * _gold_multiplier())))
			_award_xp(floori(6.0 * _xp_multiplier()))
		rings[i] = ring
		total += amount
	if total > 0:
		_spawn_floating("Area", ball_position + Vector2(-24, -36), color)
	return total


func _award_coins(amount: int) -> void:
	if amount <= 0:
		return
	var balanced: int = max(1, floori(float(amount) * _combo_coin_multiplier() * RUN_COIN_MULTIPLIER))
	run_coins += balanced
	if balanced >= 5:
		_spawn_floating("+%s MOEDAS" % balanced, ball_position + Vector2(12, 18), Color("#ffd700"))


func _award_xp(amount: int) -> void:
	if amount <= 0:
		return
	var balanced: int = max(1, floori(float(amount) * _combo_xp_multiplier()))
	run_xp += balanced
	total_run_xp += balanced
	_spawn_floating("+%s XP" % balanced, ball_position + Vector2(-28, 18), Color("#00f0ff"))
	var needed: int = _run_xp_needed_for_level(run_level)
	if run_xp >= needed:
		run_xp -= needed
		run_level += 1
		_open_level_up()


func _register_combo(label: String, color: Color) -> void:
	var now := Time.get_ticks_msec()
	combo = combo + 1 if now - last_combo_msec <= COMBO_WINDOW_MSEC else 1
	last_combo_msec = now
	best_combo = max(best_combo, combo)
	if combo >= 2:
		_spawn_floating("%s x%s" % [_combo_label(), combo], ball_position + Vector2(-22, -34), color)
	elif not label.is_empty():
		_spawn_floating(label, ball_position + Vector2(-8, -24), color)


func _update_combo_timeout() -> void:
	if combo > 0 and Time.get_ticks_msec() - last_combo_msec > COMBO_WINDOW_MSEC:
		combo = 0
	if rapid_clear_streak > 0 and Time.get_ticks_msec() - last_ring_clear_msec > COMBO_WINDOW_MSEC:
		rapid_clear_streak = 0
		ring_pacing_multiplier = max(1.0, ring_pacing_multiplier - 0.012)


func _base_ring_spawn_delay() -> float:
	var count: int = int(gameplay_config.get("ring_count", 1))
	return clampf(1.12 - min(0.42, float(max(0, count - 8)) * 0.018) - min(0.16, float(max(0, phase_id - 1)) * 0.004), 0.42, 1.12)


func _effective_ring_pacing() -> float:
	var active := _active_ring_count()
	var many_ring_bonus := clampf(float(max(0, active - 8)) * 0.01, 0.0, 0.12)
	var delay_bonus := clampf((1.12 - ring_spawn_delay) * 0.12, 0.0, 0.08)
	return clampf(ring_pacing_multiplier + many_ring_bonus + delay_bonus, 0.92, 1.34 if is_infinite else 1.42)


func _register_ring_clear() -> void:
	var now := Time.get_ticks_msec()
	var elapsed_since_clear := now - last_ring_clear_msec
	rapid_clear_streak = rapid_clear_streak + 1 if elapsed_since_clear <= 1800 else 1
	last_ring_clear_msec = now
	ring_spawn_delay = clampf(ring_spawn_delay - 0.052 - float(max(0, _active_ring_count() - 10)) * 0.002, 0.42, _base_ring_spawn_delay())
	if is_infinite:
		var quick_bonus := 0.20 if elapsed_since_clear <= 1150 else 0.10
		infinite_clear_pressure = clampf(infinite_clear_pressure + quick_bonus + float(max(0, rapid_clear_streak - 3)) * 0.018, 0.0, 8.0)
		ring_pacing_multiplier = clampf(0.96 + rapid_clear_streak * 0.045 + infinite_clear_pressure * 0.018, 0.96, 1.42)
	else:
		ring_pacing_multiplier = clampf(0.96 + rapid_clear_streak * 0.048, 0.96, 1.36)


func _combo_coin_multiplier() -> float:
	if combo >= 20:
		return 1.28
	if combo >= 10:
		return 1.2
	if combo >= 5:
		return 1.1
	if combo >= 2:
		return 1.05
	return 1.0


func _combo_xp_multiplier() -> float:
	if combo >= 20:
		return 1.24
	if combo >= 10:
		return 1.2
	if combo >= 5:
		return 1.1
	if combo >= 2:
		return 1.03
	return 1.0


func _combo_label() -> String:
	if combo >= 20:
		return "Ring Rush!"
	if combo >= 10:
		return "Perfect Chain!"
	if combo >= 5:
		return "Great!"
	return "Combo!"


func _track_dps(damage: float) -> void:
	recent_hit_damage.append(damage)
	if recent_hit_damage.size() > 60:
		recent_hit_damage.pop_front()
	var total := 0.0
	for value in recent_hit_damage:
		total += value
	run_dps = floori(total)


func _run_profile_xp() -> int:
	return max(24, floori((total_run_xp * 0.58 + rings_destroyed * 6.0 + perfect_escapes * 9.0 + best_combo * 1.8 + phase_id * 10.0) * PROFILE_XP_MULTIPLIER))


func _global_coins_from_run(coins_value: int, combo_value: int, won: bool) -> int:
	var combo_bonus := 1.18 if combo_value >= 20 else 1.1 if combo_value >= 10 else 1.05 if combo_value >= 5 else 1.0
	var win_bonus := 1.08 if won else 1.0
	return max(0, floori(float(coins_value) * GLOBAL_COIN_CONVERSION_RATE * combo_bonus * win_bonus))


func _run_xp_needed_for_level(level_value: int) -> int:
	return floori(XP_BASE_REQUIREMENT * pow(max(1, level_value), 1.55))


func _open_level_up() -> void:
	rerolls_used = 0
	available_upgrades = _get_safe_upgrade_options()
	last_upgrade_option_ids = _upgrade_ids(available_upgrades)
	_rebuild_level_up_cards()
	level_up_active = true
	_level_up_overlay.visible = true
	_spawn_particles(arena_center, Color("#00f0ff"), 34, 150.0)
	_spawn_floating("LEVEL %s" % run_level, arena_center + Vector2(-24, -46), Color("#ffd700"))


func _get_safe_upgrade_options(exclude_ids: Array[String] = [], allow_repeats := true) -> Array[Dictionary]:
	GameState.refresh_unlocks(false)
	var unlocked: Array = GameState.data.get("unlocked_upgrades", [])
	var pool: Array = MainPortData.released_run_upgrades()
	var filtered: Array[Dictionary] = []
	var fallback: Array[Dictionary] = []
	for upgrade in pool:
		var id := String(upgrade.get("id", ""))
		if _is_run_upgrade_available(upgrade, unlocked):
			var copy: Dictionary = upgrade.duplicate(true)
			copy["color"] = _rarity_upgrade_color(String(copy.get("rarity", "common")))
			if exclude_ids.has(id):
				fallback.append(copy)
			else:
				filtered.append(copy)
	filtered.shuffle()
	fallback.shuffle()
	while filtered.size() < 3 and not fallback.is_empty():
		filtered.append(fallback.pop_front())
	if allow_repeats and not filtered.is_empty():
		var seed_options: Array[Dictionary] = []
		for upgrade in filtered:
			seed_options.append(upgrade.duplicate(true))
		while filtered.size() < 3:
			filtered.append(seed_options[randi() % seed_options.size()].duplicate(true))
	return filtered.slice(0, min(3, filtered.size()))


func _is_run_upgrade_available(upgrade: Dictionary, unlocked: Array) -> bool:
	var id := String(upgrade.get("id", ""))
	if id.is_empty():
		return false
	if not MainPortData.is_released_run_upgrade(id):
		return false
	if int(upgrade.get("maxLevel", 0)) <= 0:
		return false
	if Array(upgrade.get("effects", [])).is_empty():
		return false
	if int(current_upgrades.get(id, 0)) >= int(upgrade.get("maxLevel", 1)):
		return false
	if bool(upgrade.get("secret", false)):
		return unlocked.has(id)
	if not unlocked.has(id):
		return false
	if MainPortData.auto_run_upgrade_ids().has(id):
		return true
	var explicit_unlocks: Array = GameState.data.get("explicit_unlocked_run_upgrades", [])
	if explicit_unlocks.has(id):
		return true
	var profile_level: int = int(GameState.data.get("level", 1))
	var max_phase: int = int(GameState.data.get("max_unlocked_phase", GameState.data.get("current_phase", 1)))
	var required_profile: int = max(int(upgrade.get("unlockLevel", 1)), _profile_requirement_from_text(String(upgrade.get("unlockRequirement", ""))))
	if profile_level < required_profile:
		return false
	if GameState.TEMP_UPGRADE_UNLOCKS.has(id):
		var rule: Dictionary = GameState.TEMP_UPGRADE_UNLOCKS[id]
		var phase_required := int(rule.get("phase", 999))
		var level_required := int(rule.get("level", 999))
		if max_phase < phase_required and profile_level < level_required:
			return false
	return true


func _profile_requirement_from_text(text: String) -> int:
	var required := 1
	var normalized := text.replace(".", " ").replace(",", " ").replace(":", " ")
	for token in normalized.split(" ", false):
		if token.is_valid_int():
			required = max(required, int(token))
	return required


func _upgrade_ids(upgrades: Array[Dictionary]) -> Array[String]:
	var ids: Array[String] = []
	for upgrade in upgrades:
		ids.append(String(upgrade.get("id", "")))
	return ids


func _rarity_upgrade_color(rarity: String) -> String:
	match rarity:
		"rare":
			return "#00aaff"
		"epic":
			return "#b000ff"
		"legendary":
			return "#ffd700"
	return "#00f0ff"


func _rebuild_level_up_cards() -> void:
	for child in _level_up_cards.get_children():
		child.queue_free()
	if available_upgrades.is_empty():
		available_upgrades = _get_safe_upgrade_options([], true)
		last_upgrade_option_ids = _upgrade_ids(available_upgrades)
	var reroll_text := "Rerolls %s/3" % rerolls_used
	if String(GameState.data.get("language", "pt")) == "pt":
		reroll_text = "Rerolls %s/3 - anuncio ou 10 diamantes" % rerolls_used
	_level_up_cards.add_child(_make_label(reroll_text, 12, "#ffffff99", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	if available_upgrades.is_empty():
		_level_up_cards.add_child(_make_label("Todas as melhorias da rodada chegaram ao limite.", 13, "#ffffffcc", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
		return
	for upgrade in available_upgrades:
		var button := _make_level_up_button(upgrade)
		_level_up_cards.add_child(button)


func _reroll_upgrades_ad() -> void:
	if rerolls_used >= 3:
		_spawn_floating(_level_up_feedback("Limite de reroll", "Reroll limit"), arena_center + Vector2(-34, -62), Color("#ff6b9a"))
		return
	GameState.show_mock_rewarded_ad(func(ok: bool) -> void:
		if ok:
			_do_upgrade_reroll()
	)


func _reroll_upgrades_diamond() -> void:
	if rerolls_used >= 3:
		_spawn_floating(_level_up_feedback("Limite de reroll", "Reroll limit"), arena_center + Vector2(-34, -62), Color("#ff6b9a"))
		return
	if not GameState.spend_diamonds(10):
		_spawn_floating(_level_up_feedback("Diamantes insuficientes", "Not enough diamonds"), arena_center + Vector2(-34, -62), Color("#ff6b9a"))
		return
	_do_upgrade_reroll()


func _do_upgrade_reroll() -> void:
	rerolls_used += 1
	available_upgrades = _get_safe_upgrade_options([], true)
	last_upgrade_option_ids = _upgrade_ids(available_upgrades)
	_rebuild_level_up_cards()
	_play_sfx("upgrade_select")


func _level_up_feedback(pt: String, en: String) -> String:
	return pt if String(GameState.data.get("language", "pt")) == "pt" else en


func _make_level_up_button(upgrade: Dictionary) -> Button:
	var id := String(upgrade["id"])
	var current_level := int(current_upgrades.get(id, 0))
	var button := _make_button("      %s\n      %s\n      Lv.%s > Lv.%s" % [String(upgrade["name"]).to_upper(), String(upgrade["description"]), current_level, current_level + 1], 286, 62)
	button.add_theme_color_override("font_color", Color("#ffffff"))
	button.add_theme_font_size_override("font_size", 10)
	_apply_button_style(button, _make_style("#16003bdd", 12, String(upgrade["color"]), 2, String(upgrade["color"]), 8))
	var icon := _make_icon_texture(_upgrade_icon_key(id), 32)
	icon.anchor_left = 0.0
	icon.anchor_top = 0.5
	icon.anchor_right = 0.0
	icon.anchor_bottom = 0.5
	icon.offset_left = 13.0
	icon.offset_top = -16.0
	icon.offset_right = 45.0
	icon.offset_bottom = 16.0
	button.add_child(icon)
	button.pressed.connect(_select_level_up_upgrade.bind(id))
	return button


func _select_level_up_upgrade(id: String) -> void:
	var allowed := false
	for upgrade in available_upgrades:
		if String(upgrade.get("id", "")) == id:
			allowed = true
			break
	if not allowed:
		_spawn_floating(_level_up_feedback("Melhoria bloqueada", "Upgrade locked"), arena_center + Vector2(-34, -62), Color("#ff6b9a"))
		_play_sfx("upgrade_select")
		return
	current_upgrades[id] = int(current_upgrades.get(id, 0)) + 1
	run_upgrades += 1
	temporary_upgrade = _describe_current_upgrades()
	level_up_active = false
	_level_up_overlay.visible = false
	_play_sfx("upgrade_select")
	_update_hud()


func _describe_current_upgrades() -> Dictionary:
	if current_upgrades.is_empty():
		return {}
	var labels: Array[String] = []
	var last_key := ""
	var names := {
		"damage": "Dano+",
		"speed": "Velocidade+",
		"coinBoost": "Chuva de Moedas",
		"critical": "Critico+",
		"xpBoost": "XP Boost",
		"perfectChance": "Perfect Chance",
		"burn": "Queimar",
		"ringRepulse": "Ring Repulse",
		"frost": "Gelo Neon",
		"chainLightning": "Choque",
	}
	for key in current_upgrades.keys():
		last_key = String(key)
		var def := MainPortData.upgrade_by_id(last_key)
		labels.append("%s Lv.%s" % [String(def.get("name", names.get(key, key))), int(current_upgrades[key])])
	var short := labels[labels.size() - 1] if labels.size() > 0 else ""
	return { "name": "Upgrades da run", "level": current_upgrades.size(), "effect": ", ".join(labels), "short": short, "icon_key": _upgrade_icon_key(last_key) }


func _upgrade_icon_key(id: String) -> String:
	match id:
		"damage":
			return "damage"
		"speed":
			return "speed"
		"critical":
			return "crit"
		"xpBoost":
			return "xp"
		"perfectChance":
			return "perfect"
		"frost", "timeFreeze", "chronoBreak", "perfectChance":
			return "perfect"
		"chainLightning", "shockwave":
			return "speed"
		"burn", "penetration", "laser", "laserCut", "bomb", "multihit", "chainBreak", "criticalOverload":
			return "damage"
		"ringRepulse", "shieldPulse", "slowField", "voidPulse", "lastShield", "royalBreaker", "bossHunter", "rivalCrusher", "trophyInstinct":
			return "upgrade"
		"coinBoost":
			return "coin"
		_:
			return "upgrade"




func _get_run_upgrade_cost(type: String) -> int:
	var base := 20 if type == "atk" else 18
	return floori(base * pow(1.35, int(run_shop_upgrades.get(type, 0))))


func _buy_run_atk_upgrade() -> void:
	_buy_run_upgrade("atk")


func _buy_run_gold_upgrade() -> void:
	_buy_run_upgrade("gold")


func _buy_run_upgrade(type: String) -> void:
	var cost := _get_run_upgrade_cost(type)
	if run_coins < cost:
		_play_sfx("click")
		return
	_play_sfx("upgrade_select")
	run_coins -= cost
	run_shop_upgrades[type] = int(run_shop_upgrades.get(type, 0)) + 1
	run_upgrades += 1
	_spawn_floating("ATK+" if type == "atk" else "Gold+", arena_center + Vector2(-36, -30), Color("#ffd700"))
	_update_hud()


func _update_run_upgrade_buttons() -> void:
	if not _run_atk_button or not _run_gold_button:
		return
	var atk_cost := _get_run_upgrade_cost("atk")
	var gold_cost := _get_run_upgrade_cost("gold")
	_run_atk_button.text = "ATK Lv.%s\n%s MOEDAS" % [int(run_shop_upgrades.get("atk", 0)), atk_cost]
	_run_gold_button.text = "GOLD Lv.%s\n%s MOEDAS" % [int(run_shop_upgrades.get("gold", 0)), gold_cost]
	_run_atk_button.disabled = run_coins < atk_cost
	_run_gold_button.disabled = run_coins < gold_cost


func _open_pause() -> void:
	_play_sfx("click")
	is_paused = true
	_pause_overlay.visible = true


func _close_pause() -> void:
	_play_sfx("click")
	_pause_overlay.visible = false
	is_paused = false


func _restart_level() -> void:
	_play_sfx("click")
	_start_level()


func _go_to_phase_select() -> void:
	_play_sfx("click")
	if not finished and (rings_destroyed > 0 or run_coins > 0 or run_xp > 0 or infinite_elapsed > 2.0):
		_finish_quit_reward()
		return
	if has_node("/root/AudioManager"):
		AudioManager.play_context("menu")
	get_tree().change_scene_to_file(PHASE_SELECT_SCENE)


func _leave_to_phase_select_now() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_context("menu")
	get_tree().change_scene_to_file(PHASE_SELECT_SCENE)


func _finish_quit_reward() -> void:
	finished = true
	is_paused = false
	revive_used = true
	_pause_overlay.visible = false
	var global_coins_reward: int = max(0, floori(float(_global_coins_from_run(run_coins, best_combo, false)) * (0.48 if is_infinite else 0.35)))
	var profile_xp_reward: int = max(0, floori(float(_run_profile_xp()) * (0.52 if is_infinite else 0.38)))
	var diamonds: int = max(0, floori(float(run_diamonds) * 0.5))
	var summary := {
		"seconds": floori(infinite_elapsed),
		"rings": rings_destroyed,
		"coins": global_coins_reward,
		"xp": profile_xp_reward,
		"diamonds": diamonds,
		"score": infinite_score,
		"best_combo": best_combo,
		"criticals": criticals,
		"skin_effects": skin_effects,
		"run_upgrades": run_upgrades,
		"run_level": run_level,
		"new_record": false,
		"quit": true,
	}
	pending_result_reward = { "coins": global_coins_reward, "xp": profile_xp_reward, "diamonds": diamonds, "manual_quit": true, "victory": false }
	if is_infinite:
		GameState.record_mode_quit("infinite", summary)
	else:
		GameState.record_mode_quit("phase", summary)
	_rebuild_defeat_summary(summary)
	_defeat_title.text = "RECOMPENSA DE SAIDA"
	if _defeat_revive_button:
		_defeat_revive_button.visible = false
	if _defeat_double_button:
		_defeat_double_button.visible = _can_double_result_reward()
		_defeat_double_button.disabled = false
	_defeat_overlay.visible = true
	queue_redraw()


func _go_to_next_phase() -> void:
	_play_sfx("click")
	var next_phase: int = min(LevelData.MAX_PHASE, phase_id + 1)
	if GameState.select_phase(next_phase):
		phase_id = next_phase
		phase_config = LevelData.get_phase_config(phase_id)
		gameplay_config = LevelData.get_solo_gameplay_config(phase_id, int(GameState.data.get("level", 1)), int(GameState.data.get("permanent_upgrades", {}).get("slowRings", 0)))
		_select_visual_palettes()
		_refresh_background_texture()
		_start_level()


func _hide_all_overlays() -> void:
	_pause_overlay.visible = false
	_level_up_overlay.visible = false
	_victory_overlay.visible = false
	_defeat_overlay.visible = false


func _rebuild_victory_rewards(global_coins_reward: int, profile_xp_reward: int) -> void:
	for child in _victory_rewards.get_children():
		child.queue_free()
	_victory_rewards.add_child(_make_victory_line("coin", "Moedas", "+%s" % global_coins_reward))
	_victory_rewards.add_child(_make_victory_line("xp", "XP", "+%s" % profile_xp_reward))
	var diamond_total := int(pending_result_reward.get("diamonds", run_diamonds * reward_multiplier))
	if diamond_total > 0:
		_victory_rewards.add_child(_make_victory_line("gem", "Diamantes", "+%s" % diamond_total))
	_victory_rewards.add_child(_make_victory_line("perfect", "Perfects", str(perfect_escapes)))
	_victory_rewards.add_child(_make_victory_line("upgrade", "Level da rodada", str(run_level)))


func _rebuild_defeat_summary(summary: Dictionary) -> void:
	if not _defeat_summary:
		return
	for child in _defeat_summary.get_children():
		child.queue_free()
	if not summary.is_empty():
		var seconds := int(summary.get("seconds", 0))
		var new_record := bool(summary.get("new_record", false))
		_defeat_title.text = "RESULTADO DO MODO INFINITO" if is_infinite else "RECOMPENSA DA PARTIDA"
		if is_infinite or seconds > 0:
			_defeat_summary.add_child(_make_victory_line("perfect", "Tempo", _format_seconds(seconds)))
		_defeat_summary.add_child(_make_victory_line("upgrade", "Aneis quebrados", str(summary.get("rings", 0))))
		_defeat_summary.add_child(_make_victory_line("coin", "Moedas", "+%s" % int(summary.get("coins", 0))))
		_defeat_summary.add_child(_make_victory_line("xp", "XP", "+%s" % int(summary.get("xp", 0))))
		if int(summary.get("diamonds", 0)) > 0:
			_defeat_summary.add_child(_make_victory_line("gem", "Diamantes", "+%s" % int(summary.get("diamonds", 0))))
		if new_record:
			_defeat_summary.add_child(_make_label("NOVO RECORDE!", 15, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	else:
		_defeat_title.text = "A bolinha foi presa pelos aneis."


func _can_double_result_reward() -> bool:
	if result_rewards_doubled or pending_result_reward.is_empty():
		return false
	return int(pending_result_reward.get("coins", 0)) > 0 or int(pending_result_reward.get("xp", 0)) > 0 or int(pending_result_reward.get("diamonds", 0)) > 0


func _double_result_reward() -> void:
	if not _can_double_result_reward():
		_spawn_floating("Recompensa ja dobrada", arena_center + Vector2(-54, -60), Color("#ff6b9a"))
		return
	GameState.show_mock_rewarded_ad(func(ok: bool) -> void:
		if not ok:
			return
		result_rewards_doubled = true
		var coins := int(pending_result_reward.get("coins", 0))
		var xp := int(pending_result_reward.get("xp", 0))
		var diamonds := int(pending_result_reward.get("diamonds", 0))
		if coins > 0:
			GameState.add_coins(coins)
		if xp > 0:
			GameState.add_profile_xp(xp)
		if diamonds > 0:
			GameState.add_diamonds(diamonds)
		pending_result_reward["coins"] = coins * 2
		pending_result_reward["xp"] = xp * 2
		pending_result_reward["diamonds"] = diamonds * 2
		_spawn_particles(arena_center, Color("#ffd700"), 30, 170.0)
		_spawn_floating("Recompensa x2", arena_center + Vector2(-46, -52), Color("#ffd700"))
		_play_sfx("reward_coin")
		if _victory_overlay and _victory_overlay.visible:
			_rebuild_victory_rewards(int(pending_result_reward["coins"]), int(pending_result_reward["xp"]))
			if _victory_double_button:
				_victory_double_button.disabled = true
				_victory_double_button.text = "RECOMPENSA DOBRADA"
		elif _defeat_overlay and _defeat_overlay.visible:
			var summary := {
				"seconds": floori(infinite_elapsed),
				"rings": rings_destroyed,
				"coins": int(pending_result_reward["coins"]),
				"xp": int(pending_result_reward["xp"]),
				"diamonds": int(pending_result_reward["diamonds"]),
				"new_record": false,
			}
			_rebuild_defeat_summary(summary)
			if _defeat_double_button:
				_defeat_double_button.disabled = true
				_defeat_double_button.text = "RECOMPENSA DOBRADA"
	)


func _format_seconds(seconds: int) -> String:
	var minutes := seconds / 60
	var remain := seconds % 60
	return "%02d:%02d" % [minutes, remain]


func _make_victory_line(icon_key: String, label_text: String, value_text: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(280, 42)
	panel.add_theme_stylebox_override("panel", _make_style("#06162a", 11, "#00f0ff55", 1, "#00f0ff33", 5))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)
	row.add_child(_make_icon_texture(icon_key, 22))
	row.add_child(_make_label(label_text, 14, "#ffffffcc", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	row.add_child(_make_label(value_text, 16, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_RIGHT))
	return panel


func _bounce_arena_edge() -> void:
	var offset := ball_position - arena_center
	var dist := offset.length()
	var max_dist: float = maxf(4.0, outer_radius - BALL_RADIUS - 1.0)
	if dist <= 0.0:
		ball_position = arena_center
		ball_velocity = _stabilize_velocity(ball_velocity)
		return
	if dist <= max_dist:
		return
	var normal := offset / dist
	ball_position = arena_center + normal * max_dist
	var outward_velocity := ball_velocity.dot(normal)
	if outward_velocity > 0.0:
		ball_velocity -= 2.0 * outward_velocity * normal
		ball_velocity = _stabilize_velocity(ball_velocity.rotated(randf_range(-0.10, 0.10)))
		last_direction_shift_msec = Time.get_ticks_msec()
	else:
		ball_velocity = _stabilize_velocity(ball_velocity)


func _clamp_ring_spacing() -> void:
	var active_indices := _active_ring_indices_by_radius()
	if active_indices.is_empty():
		return
	var max_radius := _playable_ring_max_radius()
	var min_radius := _playable_ring_min_radius()
	var crush_min_radius := 4.0
	var playable_width := max_radius - min_radius
	var spacing := _infinite_ring_spacing() if is_infinite else MIN_RING_SPACING
	if active_indices.size() > 1:
		spacing = min(spacing, playable_width / float(active_indices.size() - 1))
	active_indices.reverse()
	var previous_radius: float = INF
	var now := Time.get_ticks_msec()
	for index in active_indices:
		var ring: Dictionary = rings[index]
		var lower_bound: float = maxf(float(ring.get("min_radius", crush_min_radius)), crush_min_radius)
		var upper_bound: float = max_radius if previous_radius == INF else previous_radius - maxf(spacing, float(ring.get("thickness", 5.0)) + 1.5)
		upper_bound = maxf(lower_bound, upper_bound)
		var current_radius: float = float(ring.get("radius", upper_bound))
		var next_radius: float = clampf(current_radius, lower_bound, upper_bound)
		if abs(next_radius - current_radius) > 0.5:
			ring["defeat_grace_until"] = now + RING_REPOSITION_GRACE_MSEC
		ring["radius"] = next_radius
		rings[index] = ring
		previous_radius = float(ring["radius"])


func _is_angle_inside_gap(angle: float, ring: Dictionary, padding := 0.0) -> bool:
	var half_gap: float = max(0.0, float(ring["gap_size"]) / 2.0 - padding)
	return _angle_distance(angle, _normalize_angle(float(ring["gap_start"]) + float(ring["rotation"]))) <= half_gap


func _angle_distance(a: float, b: float) -> float:
	var diff: float = abs(_normalize_angle(a) - _normalize_angle(b))
	return min(diff, TWO_PI - diff)


func _normalize_angle(angle: float) -> float:
	return fposmod(angle, TWO_PI)


func _clamp_vector_speed(value: Vector2, min_speed: float, max_speed: float) -> Vector2:
	var speed := value.length()
	if speed <= 0.001:
		return Vector2.RIGHT * min_speed
	var clamped := clampf(speed, min_speed, max_speed)
	return value / speed * clamped


func _update_arena_metrics() -> void:
	var gameplay_top := 206.0
	var gameplay_bottom := 94.0
	arena_size = min(size.x - 18.0, size.y - gameplay_top - gameplay_bottom)
	arena_size = clampf(arena_size, 250.0, 540.0)
	arena_center = Vector2(size.x / 2.0, gameplay_top + arena_size / 2.0)
	outer_radius = arena_size / 2.0 - 8.0


func _update_effects(delta: float) -> void:
	for i in range(particles.size() - 1, -1, -1):
		var particle := particles[i]
		particle["position"] = Vector2(particle["position"]) + Vector2(particle["velocity"]) * delta
		particle["life"] = float(particle["life"]) - delta * 1.8
		if float(particle["life"]) <= 0.0:
			particles.remove_at(i)
		else:
			particles[i] = particle
	for i in range(trail_points.size() - 1, -1, -1):
		var point := trail_points[i]
		point["life"] = float(point["life"]) - delta * 2.4
		if float(point["life"]) <= 0.0:
			trail_points.remove_at(i)
		else:
			trail_points[i] = point
	for i in range(floating_feedback.size() - 1, -1, -1):
		var item := floating_feedback[i]
		item["position"] = Vector2(item["position"]) + Vector2(0, -22) * delta
		item["life"] = float(item["life"]) - delta * 0.9
		if float(item["life"]) <= 0.0:
			floating_feedback.remove_at(i)
		else:
			floating_feedback[i] = item


func _add_trail_point() -> void:
	var rarity_size := float(skin_profile.get("trail_size", 5.0))
	trail_points.append({ "position": ball_position, "life": 1.0, "size": BALL_RADIUS + rarity_size, "color": String(skin_profile.get("color", "#00f0ff")) })
	if trail_points.size() > 18:
		trail_points.pop_front()


func _spawn_particles(origin: Vector2, color: Color, amount: int, speed: float) -> void:
	for i in range(amount):
		var angle := randf() * TWO_PI
		var velocity := Vector2(cos(angle), sin(angle)) * randf_range(speed * 0.25, speed)
		particles.append({ "position": origin, "velocity": velocity, "color": color, "life": randf_range(0.45, 1.0), "size": randf_range(2.0, 4.5) })
	if particles.size() > 90:
		particles = particles.slice(particles.size() - 90)


func _spawn_floating(text: String, position: Vector2, color: Color) -> void:
	floating_feedback.append({ "text": text, "position": position, "color": color, "life": 1.0 })
	if floating_feedback.size() > 12:
		floating_feedback.pop_front()


func _setup_audio() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_context("gameplay")


func _play_sfx(key: String) -> void:
	if not SOUND_PATHS.has(key):
		return
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx(String(SOUND_PATHS[key]), -5.0)


func _ensure_music_state() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.ensure_music()


func _audio_muted() -> bool:
	return bool(GameState.data.get("settings", {}).get("audio_muted", false)) or bool(GameState.data.get("settings", {}).get("master_muted", false))


func _xp_needed_for_level(player_level: int) -> int:
	return floori(150.0 * pow(max(1, player_level), 1.55))


func _load_skin_texture() -> void:
	var skin_id := String(GameState.data.get("equipped_skin", "neon_blue"))
	skin_profile = _make_skin_profile(skin_id)
	var path := "res://assets/skins/%s.png" % skin_id
	if ResourceLoader.exists(path):
		_skin_texture = load(path)
	else:
		_skin_texture = load("res://assets/skins/neon_blue.png")


func _make_skin_profile(skin_id: String) -> Dictionary:
	var id := skin_id.to_lower()
	var profile := { "id": skin_id, "effect": "trail", "chance": 0.06, "value": 0.0, "color": "#00f0ff", "trail_size": 5.0, "control": false, "control_strength": 0.0 }
	var skin_def := MainPortData.skin_by_id(skin_id)
	if not skin_def.is_empty():
		var passive: Dictionary = skin_def.get("passive", {})
		var rarity := String(skin_def.get("rarity", "common"))
		profile["color"] = String(skin_def.get("primary", "#00f0ff"))
		profile["trail_size"] = _rarity_trail_size(rarity)
		var chance := float(passive.get("chance", _default_skin_chance(rarity)))
		var value := float(passive.get("value", 0.0))
		match String(passive.get("type", "trail")):
			"freeze_ring", "slow_ring":
				profile.merge({ "effect": "freeze", "chance": chance, "value": max(0.34, value), "color": String(skin_def.get("primary", "#9be8ff")) }, true)
			"burn":
				profile.merge({ "effect": "burn", "chance": chance, "value": max(0.22, value * 0.12), "color": String(skin_def.get("primary", "#ff8800")) }, true)
			"chain_damage":
				profile.merge({ "effect": "chain", "chance": chance, "value": max(0.28, value), "color": String(skin_def.get("primary", "#38bdf8")) }, true)
			"phase_solid":
				profile.merge({ "effect": "phase", "chance": chance, "value": value, "color": String(skin_def.get("primary", "#a855f7")) }, true)
			"repel_ring":
				profile.merge({ "effect": "repulse", "chance": chance, "value": max(10.0, value), "color": String(skin_def.get("primary", "#c084fc")) }, true)
			"area_damage", "cosmic_critical", "league_king_wave":
				profile.merge({ "effect": "area", "chance": chance, "value": max(0.28, value), "color": String(skin_def.get("primary", "#7c3aed")) }, true)
			"coin_on_hit", "coin_multiplier":
				profile.merge({ "effect": "coin", "chance": chance, "value": max(4.0, value * 20.0), "color": String(skin_def.get("primary", "#ffd700")) }, true)
			"xp_multiplier":
				profile.merge({ "effect": "xp", "chance": chance, "value": max(6.0, value * 40.0), "color": String(skin_def.get("primary", "#00ff88")) }, true)
			"speed", "slime_bounce":
				profile.merge({ "effect": "speed", "chance": chance, "value": max(0.04, value), "color": String(skin_def.get("primary", "#67e8f9")) }, true)
			"crit_chance", "mega_crit", "damage_multiplier":
				profile.merge({ "effect": "crit", "chance": chance, "value": max(0.25, value), "color": String(skin_def.get("primary", "#ff4fd8")) }, true)
		_apply_control_profile(profile, skin_id, rarity)
		return profile
	if _id_contains_any(id, ["ice", "frost", "snow", "penguin", "wizard", "red_eye", "neon_spiral"]):
		profile.merge({ "effect": "freeze", "chance": 0.24, "value": 0.42, "color": "#9be8ff", "trail_size": 7.5 }, true)
	elif _id_contains_any(id, ["fire", "flame", "dragon", "phoenix", "solar", "meteor"]):
		profile.merge({ "effect": "burn", "chance": 0.22, "value": 0.55, "color": "#ff8800", "trail_size": 7.0 }, true)
	elif _id_contains_any(id, ["electric", "lightning", "plasma", "satellite", "orbital"]):
		profile.merge({ "effect": "chain", "chance": 0.20, "value": 0.36, "color": "#38bdf8", "trail_size": 7.0 }, true)
	elif _id_contains_any(id, ["ghost", "shadow", "void", "astral"]):
		profile.merge({ "effect": "phase", "chance": 0.12, "value": 0.0, "color": "#a855f7", "trail_size": 7.5 }, true)
	elif _id_contains_any(id, ["ripple", "guardian", "king", "repulse", "robot"]):
		profile.merge({ "effect": "repulse", "chance": 0.18, "value": 14.0, "color": "#c084fc", "trail_size": 6.5 }, true)
	elif _id_contains_any(id, ["piggy", "cow", "ladybug", "chick", "hamster", "puppy"]):
		profile.merge({ "effect": "coin", "chance": 0.18, "value": 5.0, "color": "#ffd700", "trail_size": 6.0 }, true)
	elif _id_contains_any(id, ["monkey", "panda", "heart"]):
		profile.merge({ "effect": "xp", "chance": 0.18, "value": 8.0, "color": "#00ff88", "trail_size": 6.0 }, true)
	elif _id_contains_any(id, ["bunny", "fox", "fish", "comet", "ninja"]):
		profile.merge({ "effect": "speed", "chance": 0.14, "value": 0.05, "color": "#67e8f9", "trail_size": 6.5 }, true)
	elif _id_contains_any(id, ["kitty", "tiger", "bee", "skull"]):
		profile.merge({ "effect": "crit", "chance": 0.16, "value": 0.35, "color": "#ff4fd8", "trail_size": 6.5 }, true)
	elif _id_contains_any(id, ["black_hole", "singularity", "cosmic"]):
		profile.merge({ "effect": "area", "chance": 0.18, "value": 0.32, "color": "#7c3aed", "trail_size": 8.0 }, true)
	_apply_control_profile(profile, skin_id, String(profile.get("rarity", "common")))
	return profile


func _apply_control_profile(profile: Dictionary, skin_id: String, _rarity: String) -> void:
	if not MainPortData.skin_has_control(skin_id):
		return
	profile["control"] = true
	profile["control_strength"] = MainPortData.skin_control_strength(skin_id)
	profile["trail_size"] = max(float(profile.get("trail_size", 5.0)), 6.6 + float(profile["control_strength"]) * 3.5)
	profile["effect"] = "trail"
	profile["chance"] = 0.0
	profile["value"] = 0.0


func _default_skin_chance(rarity: String) -> float:
	match rarity:
		"rare":
			return 0.14
		"epic":
			return 0.18
		"legendary", "mythic":
			return 0.22
		"ultimate":
			return 0.28
	return 0.10


func _rarity_trail_size(rarity: String) -> float:
	match rarity:
		"rare":
			return 6.4
		"epic":
			return 7.1
		"legendary", "mythic":
			return 8.0
		"ultimate":
			return 9.0
	return 5.4


func _id_contains_any(id: String, needles: Array) -> bool:
	for needle in needles:
		if id.contains(String(needle)):
			return true
	return false


func _select_visual_palettes() -> void:
	background_palette_index = int(fposmod(phase_id + Time.get_ticks_msec() / 1000, BACKGROUND_PALETTES.size()))
	ring_palette_index = int(fposmod(phase_id * 3 + Time.get_ticks_msec() / 1200, RING_PALETTES.size()))


func _refresh_background_texture() -> void:
	if _background_texture_rect:
		_background_texture_rect.texture = _make_background_gradient()


func _make_background_gradient() -> GradientTexture2D:
	var gradient := Gradient.new()
	var palette: Array = BACKGROUND_PALETTES[background_palette_index]
	gradient.offsets = PackedFloat32Array([0.0, 0.52, 1.0])
	gradient.colors = PackedColorArray([Color(String(palette[0])), Color(String(palette[1])), Color(String(palette[2]))])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 16
	texture.height = 1024
	texture.fill = GradientTexture2D.FILL_LINEAR
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(0.0, 1.0)
	return texture


func _make_label(text: String, font_size: int, color: String, font: Font, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(color))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


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

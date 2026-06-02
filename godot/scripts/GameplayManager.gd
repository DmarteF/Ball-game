extends Control

const LevelData := preload("res://scripts/LevelData.gd")

const PHASE_SELECT_SCENE := "res://scenes/PhaseSelect.tscn"
const BALL_RADIUS := 10.0
const INNER_RADIUS := 35.0
const BASE_BALL_SPEED := 2.2
const XP_BASE_REQUIREMENT := 150.0
const RUN_COIN_MULTIPLIER := 0.92
const GLOBAL_COIN_CONVERSION_RATE := 0.72
const PROFILE_XP_MULTIPLIER := 0.95
const COMBO_WINDOW_MSEC := 2600
const PHYSICS_STEPS_PER_SECOND := 60.0
const TWO_PI := PI * 2.0
const RING_COLORS := ["#00f0ff", "#b000ff", "#ff0055", "#00ff88", "#ffd700", "#ff8800"]
const SOUND_PATHS := {
	"hit": "res://assets/sounds/hit_light.mp3",
	"hit_heavy": "res://assets/sounds/hit_heavy.mp3",
	"break": "res://assets/sounds/ring_break.mp3",
	"perfect": "res://assets/sounds/perfect.mp3",
	"coin": "res://assets/sounds/coin_gain.mp3",
	"victory": "res://assets/sounds/victory.mp3",
	"defeat": "res://assets/sounds/defeat.mp3",
	"click": "res://assets/sounds/button_click.mp3",
}
const MUSIC_PATH := "res://assets/music/gameplay.mp3"

var phase_id := 1
var phase_config: Dictionary
var gameplay_config: Dictionary
var rings: Array[Dictionary] = []
var ball_position := Vector2.ZERO
var ball_velocity := Vector2.ZERO
var arena_center := Vector2.ZERO
var arena_size := 320.0
var outer_radius := 154.0
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

var _regular_font: Font
var _bold_font: Font
var _skin_texture: Texture2D
var _hud_phase: Label
var _hud_resources: Label
var _hud_rings: Label
var _hud_stats: Label
var _hud_xp: Label
var _hud_upgrade: Label
var _run_upgrade_bar: HBoxContainer
var _run_atk_button: Button
var _run_gold_button: Button
var _pause_overlay: Control
var _level_up_overlay: Control
var _level_up_cards: VBoxContainer
var _victory_overlay: Control
var _victory_title: Label
var _victory_rewards: Label
var _defeat_overlay: Control
var _music_player: AudioStreamPlayer
var _sfx_players: Dictionary = {}


func _ready() -> void:
	_regular_font = _make_system_font(400)
	_bold_font = _make_system_font(700)
	phase_config = LevelData.get_phase_config(phase_id)
	gameplay_config = LevelData.get_solo_gameplay_config(phase_id, int(GameState.data.get("level", 1)), int(GameState.data.get("permanent_upgrades", {}).get("slowRings", 0)))
	_load_skin_texture()
	_setup_audio()
	_build_background()
	_build_hud()
	_build_pause_overlay()
	_build_level_up_overlay()
	_build_result_overlays()
	call_deferred("_start_level")


func _process(delta: float) -> void:
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
	available_upgrades = []
	recent_hit_damage.clear()
	rings_destroyed = 0
	perfect_escapes = 0
	particles.clear()
	trail_points.clear()
	floating_feedback.clear()
	temporary_upgrade = {}
	_update_arena_metrics()
	rings = _create_rings()
	var start_angle: float = randf() * TWO_PI
	var speed: float = BASE_BALL_SPEED + min(0.62, float(phase_id - 1) * 0.08 + int(GameState.data.get("level", 1)) * 0.006)
	ball_position = arena_center
	ball_velocity = Vector2(cos(start_angle), sin(start_angle)) * speed
	previous_distance = 0.0
	_hide_all_overlays()
	_update_hud()
	queue_redraw()


func _update_game(delta_steps: float) -> void:
	_update_arena_metrics()
	var target_speed: float = _target_ball_speed()
	ball_velocity = _clamp_vector_speed(ball_velocity, target_speed * 0.78, target_speed * 1.42)
	var previous_vector := ball_position - arena_center
	var prev_dist := previous_vector.length()
	ball_position += ball_velocity * delta_steps
	_bounce_arena_edge()
	var next_dist := (ball_position - arena_center).length()
	_add_trail_point()
	_update_combo_timeout()
	_update_rings(delta_steps)
	_check_perfect_escape(prev_dist, next_dist)
	_check_ring_hit(prev_dist)
	_clamp_ring_spacing()
	if _active_ring_count() == 0:
		_finish_victory()
		return
	if _is_ball_crushed():
		_finish_defeat()
		return
	previous_distance = next_dist


func _create_rings() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var count: int = int(gameplay_config["ring_count"])
	var inner_radius: float = INNER_RADIUS
	var available_radius: float = max(1.0, outer_radius - inner_radius)
	var adaptive_min_spacing: float = min(5.0, max(2.25, available_radius / max(1.0, float(count - 1))))
	var max_count_by_spacing: int = max(1, floori(available_radius / adaptive_min_spacing) + 1)
	count = max(1, min(count, max_count_by_spacing))
	var spacing: float = available_radius / max(1.0, float(count - 1))
	var difficulty: float = 1.0 + max(0, phase_id - 1) * 0.22
	var phase_gap: float = max(PI / 7.5, float(gameplay_config["gap_size"]))
	var solid_indexes: Dictionary = { count - 1: true }
	for i in range(count):
		var progress := 0.0 if count == 1 else float(i) / float(count - 1)
		var direction := 1.0 if i % 2 == 0 else -1.0
		var pattern_shift := sin(i * 0.9) * 0.18 if phase_id % 3 == 0 else 0.0
		var inner_speed_bias := 1.35 - progress * 0.55
		var speed_variation := 0.86 + float((i * 17 + phase_id * 11) % 23) / 100.0
		var is_solid: bool = solid_indexes.has(i)
		var hp: int = floori(float(gameplay_config["base_hp"]) * difficulty * (0.9 + progress * 1.55) * (1.45 if is_solid else 1.0))
		var gap_size: float = max(PI / 7.5, phase_gap * (1.08 - progress * 0.16))
		result.append({
			"id": "ring_%s_%s" % [phase_id, i],
			"type": "solid" if is_solid else "normal",
			"radius": inner_radius + i * spacing,
			"initial_radius": inner_radius + i * spacing,
			"closing_speed": float(gameplay_config["closing_speed"]) * difficulty * (0.75 + progress * 0.42),
			"rotation": _normalize_angle(i * 0.61 + phase_id * 0.37 + pattern_shift),
			"rotation_speed": float(gameplay_config["rotation_speed"]) * difficulty * inner_speed_bias * speed_variation * direction,
			"gap_start": _normalize_angle(i * 0.83 + phase_id * 0.49 + pattern_shift),
			"gap_size": 0.0 if is_solid else gap_size,
			"hp": hp,
			"max_hp": hp,
			"status": "active",
			"thickness": 7.0 if is_solid else 5.0,
			"color": ["#ff3d00", "#ff0055", "#b000ff"][i % 3] if is_solid else RING_COLORS[i % RING_COLORS.size()],
			"min_radius": 4.0,
		})
	return result


func _update_rings(delta_steps: float) -> void:
	for i in range(rings.size()):
		var ring := rings[i]
		if String(ring.get("status", "")) != "active":
			continue
		ring["rotation"] = _normalize_angle(float(ring["rotation"]) + float(ring["rotation_speed"]) * delta_steps)
		ring["radius"] = max(float(ring["min_radius"]), float(ring["radius"]) - float(ring["closing_speed"]) * delta_steps)
		rings[i] = ring


func _check_perfect_escape(prev_dist: float, next_dist: float) -> void:
	var angle := _normalize_angle((ball_position - arena_center).angle())
	for i in range(rings.size()):
		var ring := rings[i]
		if String(ring.get("status", "")) != "active" or String(ring.get("type", "normal")) == "solid":
			continue
		var radius := float(ring["radius"])
		var crossed: bool = (prev_dist - radius) * (next_dist - radius) <= 0.0
		var near: bool = abs(next_dist - radius) <= BALL_RADIUS + abs(next_dist - prev_dist) + float(ring["thickness"])
		if crossed and near and _is_angle_inside_gap(angle, ring, min(0.06, BALL_RADIUS / max(1.0, radius))):
			ring["status"] = "cleared"
			ring["hp"] = 0
			rings[i] = ring
			perfect_escapes += 1
			var perfect_coins: int = max(2, floori(5.0 * _gold_multiplier()))
			var perfect_xp: int = floori((10.0 + randf() * 8.0) * _xp_multiplier())
			_award_coins(perfect_coins)
			_award_xp(perfect_xp)
			_register_combo("Perfect", Color("#00f0ff"))
			_spawn_particles(ball_position, Color("#b8f3ff"), 12, 110.0)
			_spawn_floating("Perfect", ball_position + Vector2(10, -20), Color("#b8f3ff"))
			_play_sfx("perfect")
			if randf() < min(0.18, 0.03 + _perfect_diamond_bonus()):
				run_diamonds += 1
				_play_sfx("coin")
				_spawn_floating("+1 DIAMANTE", ball_position + Vector2(16, 12), Color("#c084fc"))
			return


func _check_ring_hit(prev_dist: float) -> void:
	var closest_index := -1
	var closest_dist := INF
	for i in range(rings.size()):
		var ring := rings[i]
		if String(ring.get("status", "")) != "active":
			continue
		var collision := _check_ring_collision(ring)
		if bool(collision["overlap"]) and not bool(collision["gap"]) and float(collision["dist"]) < closest_dist:
			closest_index = i
			closest_dist = float(collision["dist"])
	if closest_index < 0:
		return

	var ring := rings[closest_index]
	_separate_and_reflect(ring, prev_dist)
	var now: int = Time.get_ticks_msec()
	if now - last_hit_msec <= 90:
		return
	last_hit_msec = now
	var is_crit := randf() * 100.0 < _crit_chance()
	var damage := floori(float(_base_damage()) * (_crit_damage() if is_crit else 1.0))
	var new_hp: int = max(0, int(ring["hp"]) - damage)
	ring["hp"] = new_hp
	ring["status"] = "broken" if new_hp <= 0 else "active"
	rings[closest_index] = ring
	_award_coins(floori(damage * 0.5 * _gold_multiplier()))
	_award_xp(floori((2 if is_crit else 1) * _xp_multiplier()))
	run_score += damage
	_track_dps(float(damage))
	_spawn_particles(ball_position, Color(String(ring["color"])), 6, 70.0)
	_spawn_floating("+%s%s" % [damage, " CRIT" if is_crit else ""], ball_position + Vector2(8, -12), Color("#ffd700") if is_crit else Color("#ffffff"))
	_play_sfx("hit_heavy" if is_crit else "hit")
	if is_crit:
		criticals += 1
	if new_hp <= 0:
		rings_destroyed += 1
		_register_combo("Break", Color("#ffd700"))
		_award_coins(max(6, floori((18.0 if String(ring.get("type", "normal")) == "solid" else 12.0) * _gold_multiplier())))
		_award_xp(floori(((16.0 if String(ring.get("type", "normal")) == "solid" else 8.0) + randf() * (12.0 if String(ring.get("type", "normal")) == "solid" else 7.0)) * _xp_multiplier()))
		_spawn_particles(ball_position, Color("#ffd700"), 18, 130.0)
		_spawn_floating("Break!", ball_position + Vector2(-18, -28), Color("#ffd700"))
		_play_sfx("break")


func _check_ring_collision(ring: Dictionary) -> Dictionary:
	var offset := ball_position - arena_center
	var dist_from_center := offset.length()
	var dist_from_ring: float = abs(dist_from_center - float(ring["radius"]))
	var overlapping: bool = dist_from_ring <= float(ring["thickness"]) / 2.0 + BALL_RADIUS
	var angle: float = _normalize_angle(offset.angle())
	var padding: float = min(0.08, BALL_RADIUS / max(1.0, float(ring["radius"])))
	var in_gap: bool = false if String(ring.get("type", "normal")) == "solid" else _is_angle_inside_gap(angle, ring, padding)
	return { "overlap": overlapping, "gap": in_gap, "dist": dist_from_ring, "angle": angle }


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
		ball_velocity = _clamp_vector_speed(ball_velocity * 1.04, target_speed * 0.88, target_speed * 1.55)


func _is_ball_crushed() -> bool:
	for ring in rings:
		if String(ring.get("status", "")) != "active" or int(ring.get("hp", 0)) <= 0:
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
	GameState.record_phase_complete(phase_id, global_coins_reward, profile_xp_reward, rings_destroyed, perfect_escapes, run_diamonds * reward_multiplier)
	_spawn_particles(arena_center, Color("#00ff88"), 42, 180.0)
	_play_sfx("victory")
	_victory_title.text = "FASE 1 CONCLUIDA"
	_victory_rewards.text = "FASE: 1\nRESULTADO: VITORIA\nMOEDAS DA RODADA: %s\nMOEDAS GERAIS: +%s\nDIAMANTES: %s\nXP DE PERFIL: +%s\nXP GANHO: %s\nQUEBRADOS: %s\nPERFECTS: %s\nMAIOR COMBO: x%s\nCHAVES/BAUS: 0/0\nLEVEL: %s\nSCORE: %s\n\nFASE 2 LIBERADA" % [run_coins, global_coins_reward, run_diamonds * reward_multiplier, profile_xp_reward, total_run_xp, rings_destroyed, perfect_escapes, best_combo, run_level, floori(run_score)]
	_victory_overlay.visible = true
	queue_redraw()


func _finish_defeat() -> void:
	finished = true
	_play_sfx("defeat")
	_defeat_overlay.visible = true
	queue_redraw()


func _draw_arena() -> void:
	pass


func _draw_rings() -> void:
	for ring in rings:
		if String(ring.get("status", "")) != "active":
			continue
		var radius := float(ring["radius"])
		var color := Color(String(ring["color"]))
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
	var skin_glow := Color("#00f0ff")
	draw_circle(ball_position, BALL_RADIUS + 12.0, Color(skin_glow, 0.16))
	draw_circle(ball_position, BALL_RADIUS + 5.0, Color("#ffffff22"))
	var rect := Rect2(ball_position - Vector2(BALL_RADIUS, BALL_RADIUS) * 1.65, Vector2(BALL_RADIUS, BALL_RADIUS) * 3.3)
	if _skin_texture:
		draw_texture_rect(_skin_texture, rect, false)
	else:
		draw_circle(ball_position, BALL_RADIUS, Color("#00f0ff"))


func _draw_effects() -> void:
	for point in trail_points:
		draw_circle(point["position"], float(point["size"]), Color("#00f0ff", float(point["life"]) * 0.22))
	for particle in particles:
		draw_circle(particle["position"], float(particle["size"]), Color(particle["color"], float(particle["life"])))


func _draw_floating_feedback() -> void:
	for item in floating_feedback:
		draw_string(_bold_font, item["position"], String(item["text"]), HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color(item["color"], float(item["life"])))


func _build_background() -> void:
	var background := TextureRect.new()
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
	_hud_phase = _make_label("FASE 1", 24, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_RIGHT)
	top.add_child(_hud_phase)
	_hud_resources = _make_label("", 13, "#ffffffcc", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	hud.add_child(_hud_resources)
	_hud_rings = _make_label("", 13, "#ffffffaa", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	hud.add_child(_hud_rings)
	_hud_stats = _make_label("", 12, "#ffffff88", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	hud.add_child(_hud_stats)
	_hud_xp = _make_label("", 12, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	hud.add_child(_hud_xp)
	_hud_upgrade = _make_label("", 12, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	_hud_upgrade.visible = false
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


func _build_pause_overlay() -> void:
	_pause_overlay = _make_modal()
	var card := _make_modal_content(_pause_overlay, "PAUSA")
	card.add_child(_make_modal_button("CONTINUAR", _close_pause))
	card.add_child(_make_modal_button("REINICIAR", _restart_level))
	card.add_child(_make_modal_button("SAIR PARA FASES", _go_to_phase_select))
	add_child(_pause_overlay)


func _build_level_up_overlay() -> void:
	_level_up_overlay = _make_modal()
	var card := _make_modal_content(_level_up_overlay, "LEVEL UP")
	card.add_child(_make_label("ESCOLHA UMA MELHORIA", 14, "#ffffffcc", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	_level_up_cards = VBoxContainer.new()
	_level_up_cards.add_theme_constant_override("separation", 10)
	card.add_child(_level_up_cards)
	add_child(_level_up_overlay)


func _build_result_overlays() -> void:
	_victory_overlay = _make_modal()
	var victory_card := _make_modal_content(_victory_overlay, "VITORIA")
	_victory_title = _make_label("FASE 1 CONCLUIDA", 24, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	_victory_rewards = _make_label("", 16, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	victory_card.add_child(_victory_title)
	victory_card.add_child(_victory_rewards)
	victory_card.add_child(_make_modal_button("VOLTAR AS FASES", _go_to_phase_select))
	victory_card.add_child(_make_modal_button("JOGAR NOVAMENTE", _restart_level))
	var next := _make_modal_button("PROXIMA FASE EM BREVE", _go_to_phase_select)
	next.disabled = true
	victory_card.add_child(next)
	add_child(_victory_overlay)

	_defeat_overlay = _make_modal()
	var defeat_card := _make_modal_content(_defeat_overlay, "GAME OVER")
	defeat_card.add_child(_make_label("A bolinha foi presa pelos aneis.", 15, "#ffffffcc", _regular_font, HORIZONTAL_ALIGNMENT_CENTER))
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


func _make_modal_content(overlay: Control, title: String) -> VBoxContainer:
	var center := CenterContainer.new()
	_fill(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(320, 260)
	panel.add_theme_stylebox_override("panel", _make_style("#16003bdd", 18, "#00f0ff66", 2, "#00f0ff55", 18))
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)
	column.add_child(_make_label(title, 26, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	overlay.add_child(center)
	return column


func _make_modal_button(text: String, target: Callable) -> Button:
	var button := _make_button(text, 250, 46)
	button.pressed.connect(target)
	return button


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


func _update_hud() -> void:
	var active: int = _active_ring_count()
	_hud_phase.text = "FASE %s" % phase_id
	_hud_resources.text = "MOEDAS %s   DIAMANTES %s   CONTA %s   CHAVES %s" % [run_coins, run_diamonds, int(GameState.data.get("coins", 0)), int(GameState.data.get("keys", 0))]
	_hud_rings.text = "ANEIS RESTANTES: %s/%s   DIFICULDADE: %s" % [active, rings.size(), String(phase_config["difficulty"]).to_upper()]
	_hud_stats.text = "ATK %s   DPS %s%s   SKIN %s" % [_base_damage(), run_dps, "   COMBO x%s" % combo if combo >= 2 else "", String(GameState.data.get("equipped_skin", "neon_blue")).replace("_", " ").to_upper()]
	var xp_needed := _run_xp_needed_for_level(run_level)
	_hud_xp.text = "LV.%s   XP %s/%s   +%s XP" % [run_level, run_xp, xp_needed, run_xp]
	_hud_upgrade.visible = not temporary_upgrade.is_empty()
	if _hud_upgrade.visible:
		_hud_upgrade.text = "UPGRADE TEMP: %s Lv.%s • %s" % [temporary_upgrade["name"], temporary_upgrade["level"], temporary_upgrade["effect"]]
	_update_run_upgrade_buttons()


func _active_ring_count() -> int:
	var count := 0
	for ring in rings:
		if String(ring.get("status", "")) == "active" and int(ring.get("hp", 0)) > 0:
			count += 1
	return count


func _base_damage() -> int:
	var upgrades: Dictionary = GameState.data.get("permanent_upgrades", {})
	var base_damage := 10.0 * pow(1.1, int(upgrades.get("baseDamage", 0)))
	var temporary_damage := int(current_upgrades.get("damage", 0)) * 0.15
	var skin_bonus := _skin_damage_bonus()
	var arena_bonus := int(run_shop_upgrades.get("atk", 0)) * 0.12
	return max(1, roundi(base_damage * (1.0 + skin_bonus + arena_bonus + temporary_damage)))


func _target_ball_speed() -> float:
	return (BASE_BALL_SPEED + min(0.62, float(phase_id - 1) * 0.08)) * _speed_multiplier()


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
	return 2.0


func _perfect_diamond_bonus() -> float:
	var skin_id := String(GameState.data.get("equipped_skin", "neon_blue"))
	var temporary_bonus := int(current_upgrades.get("perfectChance", 0)) * 0.01
	if skin_id == "neon_blue":
		return 0.005 + temporary_bonus
	if skin_id in ["star_rare", "planet", "crystal", "alien_rare", "purple_crystal", "cosmic_eye", "astral_eye"]:
		return 0.02 + temporary_bonus
	return temporary_bonus


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


func _award_coins(amount: int) -> void:
	if amount <= 0:
		return
	var balanced: int = max(1, floori(float(amount) * _combo_coin_multiplier() * RUN_COIN_MULTIPLIER))
	run_coins += balanced


func _award_xp(amount: int) -> void:
	if amount <= 0:
		return
	var balanced: int = max(1, floori(float(amount) * _combo_xp_multiplier()))
	run_xp += balanced
	total_run_xp += balanced
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
	return max(8, floori((total_run_xp * 0.42 + rings_destroyed * 3.6 + perfect_escapes * 5.0 + best_combo * 1.2) * PROFILE_XP_MULTIPLIER))


func _global_coins_from_run(coins_value: int, combo_value: int, won: bool) -> int:
	var combo_bonus := 1.18 if combo_value >= 20 else 1.1 if combo_value >= 10 else 1.05 if combo_value >= 5 else 1.0
	var win_bonus := 1.08 if won else 1.0
	return max(0, floori(float(coins_value) * GLOBAL_COIN_CONVERSION_RATE * combo_bonus * win_bonus))


func _run_xp_needed_for_level(level_value: int) -> int:
	return floori(XP_BASE_REQUIREMENT * pow(max(1, level_value), 1.55))


func _open_level_up() -> void:
	available_upgrades = _get_safe_upgrade_options()
	_rebuild_level_up_cards()
	level_up_active = true
	_level_up_overlay.visible = true
	_play_sfx("coin")


func _get_safe_upgrade_options() -> Array[Dictionary]:
	var profile_level := int(GameState.data.get("level", 1))
	var unlocked: Array = GameState.data.get("unlocked_upgrades", [])
	var pool: Array[Dictionary] = [
		{ "id": "damage", "name": "Dano+", "description": "+15% de dano", "rarity": "common", "color": "#00f0ff", "unlock": 1 },
		{ "id": "speed", "name": "Velocidade+", "description": "+20% de velocidade", "rarity": "common", "color": "#00f0ff", "unlock": 1 },
		{ "id": "coinBoost", "name": "Chuva de Moedas", "description": "+50% de moedas", "rarity": "common", "color": "#ffd700", "unlock": 1 },
		{ "id": "critical", "name": "Critico+", "description": "+5% chance critica", "rarity": "common", "color": "#ff0055", "unlock": 1 },
		{ "id": "xpBoost", "name": "XP Boost", "description": "+50% de XP", "rarity": "common", "color": "#00ff88", "unlock": 3 },
		{ "id": "perfectChance", "name": "Perfect Chance", "description": "+1% chance de diamante no Perfect", "rarity": "rare", "color": "#c084fc", "unlock": 5 },
	]
	var filtered: Array[Dictionary] = []
	for upgrade in pool:
		var required := int(upgrade["unlock"])
		var allowed_by_profile := profile_level >= required
		var allowed_by_save := unlocked.has(String(upgrade["id"])) or String(upgrade["id"]) in ["damage", "speed", "coinBoost", "critical"]
		if allowed_by_profile and allowed_by_save:
			filtered.append(upgrade)
	filtered.shuffle()
	if filtered.size() < 3:
		for upgrade in pool:
			if not filtered.has(upgrade):
				filtered.append(upgrade)
			if filtered.size() >= 3:
				break
	return filtered.slice(0, 3)


func _rebuild_level_up_cards() -> void:
	for child in _level_up_cards.get_children():
		child.queue_free()
	for upgrade in available_upgrades:
		var button := _make_level_up_button(upgrade)
		_level_up_cards.add_child(button)


func _make_level_up_button(upgrade: Dictionary) -> Button:
	var id := String(upgrade["id"])
	var current_level := int(current_upgrades.get(id, 0))
	var button := _make_button("%s\n%s\nLv.%s > Lv.%s\nSELECIONAR" % [String(upgrade["name"]).to_upper(), String(upgrade["description"]), current_level, current_level + 1], 270, 92)
	button.add_theme_color_override("font_color", Color("#ffffff"))
	button.add_theme_font_size_override("font_size", 12)
	_apply_button_style(button, _make_style("#16003bdd", 12, String(upgrade["color"]), 2, String(upgrade["color"]), 8))
	button.pressed.connect(_select_level_up_upgrade.bind(id))
	return button


func _select_level_up_upgrade(id: String) -> void:
	current_upgrades[id] = int(current_upgrades.get(id, 0)) + 1
	run_upgrades += 1
	temporary_upgrade = _describe_current_upgrades()
	level_up_active = false
	_level_up_overlay.visible = false
	_play_sfx("coin")
	_update_hud()


func _describe_current_upgrades() -> Dictionary:
	if current_upgrades.is_empty():
		return {}
	var labels: Array[String] = []
	var names := {
		"damage": "Dano+",
		"speed": "Velocidade+",
		"coinBoost": "Chuva de Moedas",
		"critical": "Critico+",
		"xpBoost": "XP Boost",
		"perfectChance": "Perfect Chance",
	}
	for key in current_upgrades.keys():
		labels.append("%s Lv.%s" % [String(names.get(key, key)), int(current_upgrades[key])])
	return { "name": "Upgrades da run", "level": current_upgrades.size(), "effect": ", ".join(labels) }


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
	_play_sfx("coin")
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
	get_tree().change_scene_to_file(PHASE_SELECT_SCENE)


func _hide_all_overlays() -> void:
	_pause_overlay.visible = false
	_level_up_overlay.visible = false
	_victory_overlay.visible = false
	_defeat_overlay.visible = false


func _bounce_arena_edge() -> void:
	var offset := ball_position - arena_center
	var dist := offset.length()
	var max_dist := outer_radius - BALL_RADIUS
	if dist <= max_dist or dist <= 0.0:
		return
	var normal := offset / dist
	ball_position = arena_center + normal * max_dist
	var outward_velocity := ball_velocity.dot(normal)
	if outward_velocity > 0.0:
		ball_velocity -= 2.0 * outward_velocity * normal


func _clamp_ring_spacing() -> void:
	var inner_active: Dictionary = {}
	for i in range(rings.size()):
		var ring := rings[i]
		if String(ring.get("status", "")) != "active":
			continue
		var min_radius := float(ring["min_radius"])
		if not inner_active.is_empty():
			min_radius = max(min_radius, float(inner_active["radius"]) + float(inner_active["thickness"]) / 2.0 + float(ring["thickness"]) / 2.0 + 5.0)
		if float(ring["radius"]) < min_radius:
			ring["radius"] = min_radius
			rings[i] = ring
		inner_active = ring


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
	arena_size = min(size.x - 18.0, size.y - 248.0)
	arena_size = clampf(arena_size, 250.0, 520.0)
	arena_center = Vector2(size.x / 2.0, 142.0 + arena_size / 2.0)
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
	trail_points.append({ "position": ball_position, "life": 1.0, "size": BALL_RADIUS + 5.0 })
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
	_music_player = AudioStreamPlayer.new()
	if ResourceLoader.exists(MUSIC_PATH):
		_music_player.stream = load(MUSIC_PATH)
		_music_player.volume_db = -13.0
		add_child(_music_player)
		if not _audio_muted():
			_music_player.play()
	for key in SOUND_PATHS.keys():
		var player := AudioStreamPlayer.new()
		if ResourceLoader.exists(SOUND_PATHS[key]):
			player.stream = load(SOUND_PATHS[key])
			player.volume_db = -5.0
			add_child(player)
			_sfx_players[key] = player


func _play_sfx(key: String) -> void:
	if _audio_muted() or not _sfx_players.has(key):
		return
	var player: AudioStreamPlayer = _sfx_players[key]
	player.stop()
	player.play()


func _audio_muted() -> bool:
	return bool(GameState.data.get("settings", {}).get("audio_muted", false)) or bool(GameState.data.get("settings", {}).get("master_muted", false))


func _xp_needed_for_level(player_level: int) -> int:
	return floori(150.0 * pow(max(1, player_level), 1.55))


func _load_skin_texture() -> void:
	var skin_id := String(GameState.data.get("equipped_skin", "neon_blue"))
	var path := "res://assets/skins/%s.png" % skin_id
	if ResourceLoader.exists(path):
		_skin_texture = load(path)
	else:
		_skin_texture = load("res://assets/skins/neon_blue.png")


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

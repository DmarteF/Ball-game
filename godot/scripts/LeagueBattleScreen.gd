extends Control

const LEAGUE_SCENE := "res://scenes/League.tscn"
const BOSS_SCENE := "res://scenes/Boss.tscn"
const MENU_SCENE := "res://scenes/MainMenu.tscn"

const TWO_PI := PI * 2.0
const BALL_RADIUS := 8.0
const TARGET_ACTIVE_RINGS := 6
const MAX_ACTIVE_RINGS := 6
const MIN_RING_SPACING := 8.8
const MIN_RING_RADIUS := 25.0
const SAFE_STEP_DISTANCE := 7.0
const MAX_PHYSICS_SUBSTEPS := 7
const PHYSICS_STEPS_PER_SECOND := 60.0
const RING_SPAWN_GRACE_MSEC := 900
const CRUSH_CONFIRM_MSEC := 150
const MATCH_LIMIT_SECONDS := 60.0
const XP_BASE := 34.0
const BASE_BALL_SPEED := 2.25
const MAX_UPGRADE_REROLLS := 3
const REROLL_DIAMOND_COST := 15
const SOUND_PATHS := {
	"click": "res://assets/sounds/button_click.mp3",
	"select": "res://assets/sounds/button_confirm.mp3",
	"hit": "res://assets/sounds/hit_light.mp3",
	"crit": "res://assets/sounds/hit_heavy.mp3",
	"break": "res://assets/sounds/ring_break.mp3",
	"clear": "res://assets/sounds/perfect.mp3",
	"coin": "res://assets/sounds/coin_gain.mp3",
	"level": "res://assets/sounds/level_up.mp3",
	"victory": "res://assets/sounds/victory.mp3",
	"defeat": "res://assets/sounds/defeat.mp3",
}
const ICON_PATHS := {
	"coin": "res://assets/ui/ui_coin.png",
	"gem": "res://assets/ui/ui_gem.png",
	"key": "res://assets/ui/ui_key.png",
	"xp": "res://assets/ui/ui_xp.png",
	"league": "res://assets/ui/ui_league_neon.png",
	"upgrade": "res://assets/ui/ui_upgrades.png",
	"damage": "res://assets/ui/ui_damage.png",
	"speed": "res://assets/ui/ui_speed.png",
	"crit": "res://assets/ui/ui_crit.png",
	"burn": "res://assets/ui/ui_burn.png",
	"freeze": "res://assets/ui/ui_freeze.png",
	"repulse": "res://assets/ui/ui_repulse.png",
	"shock": "res://assets/ui/ui_shock.png",
	"area": "res://assets/ui/ui_area.png",
	"perfect": "res://assets/ui/ui_perfect.png",
}
const RING_PALETTE := ["#00f0ff", "#b000ff", "#ff0055", "#00ff88", "#ffd700", "#ff8800"]

var _regular_font: Font
var _bold_font: Font
var _opponent: Dictionary = {}
var _player: Dictionary = {}
var _rival: Dictionary = {}
var _battle_active := false
var _finished := false
var _paused := false
var _elapsed := 0.0
var _winner := ""
var _finish_reason := ""
var _result_reward: Dictionary = {}
var _revive_used := false
var _result_doubled := false
var _control_input := 0.0
var _control_left_down := false
var _control_right_down := false
var _battle_kind := "league"
var _boss_level_id := ""

var _hud_layer: Control
var _status_label: Label
var _meta_label: Label
var _player_label: Label
var _rival_label: Label
var _resource_labels: Dictionary = {}
var _hud_xp_label: Label
var _hud_xp_bar: ProgressBar
var _control_overlay: HBoxContainer
var _control_indicator: Label
var _run_atk_button: Button
var _run_gold_button: Button
var _pause_overlay: Control
var _level_up_overlay: Control
var _level_up_cards: VBoxContainer
var _level_up_actions: VBoxContainer
var _current_upgrade_choices: Array[Dictionary] = []
var _upgrade_rerolls_used := 0
var _result_overlay: Control
var _result_title: Label
var _result_details: VBoxContainer
var _result_double_button: Button
var _result_retry_button: Button
var _revive_overlay: Control
var _battle_started_flash := 0.0


func _ready() -> void:
	_regular_font = _make_system_font(400)
	_bold_font = _make_system_font(700)
	if has_node("/root/AudioManager"):
		AudioManager.play_context("league")
	_build_background()
	_build_hud()
	_build_control_overlay()
	_build_pause_overlay()
	_build_level_up_overlay()
	_build_result_overlay()
	_build_revive_overlay()
	call_deferred("_prepare_match")


func _process(delta: float) -> void:
	if _player.is_empty() or _rival.is_empty():
		return
	_update_control_overlay()
	_battle_started_flash = max(0.0, _battle_started_flash - delta * 1.8)
	if _finished or _paused or not _battle_active:
		_update_status()
		queue_redraw()
		return
	_elapsed += delta
	_tick_arena(_player, delta, false)
	_tick_arena(_rival, delta, true)
	if bool(_rival.get("level_pending", false)):
		_apply_ai_upgrade(_rival)
	_update_bot_run_shop()
	if bool(_player.get("level_pending", false)):
		_open_player_upgrade()
	if bool(_player.get("crushed", false)) and bool(_rival.get("crushed", false)):
		_finish_match(_timed_result(), "colisao dupla")
	elif bool(_player.get("crushed", false)):
		_offer_revive_or_finish()
	elif bool(_rival.get("crushed", false)):
		_finish_match("win", "rival preso")
	elif _elapsed >= MATCH_LIMIT_SECONDS:
		_finish_match(_timed_result(), "tempo")
	_update_status()
	queue_redraw()


func _draw() -> void:
	if _battle_started_flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color("#00f0ff", 0.018 * _battle_started_flash), true)
	if not _rival.is_empty():
		_draw_arena(_rival)
	if not _player.is_empty():
		_draw_arena(_player)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and not _player.is_empty() and not _rival.is_empty():
		_layout_arenas()


func _prepare_match() -> void:
	var league: Dictionary = GameState.data.get("league", {})
	var trophies := int(league.get("trophies", 0))
	var pending_boss: Dictionary = GameState.data.get("pending_boss_battle", {})
	var reuse_current_boss := _battle_kind == "boss" and not _finished and not _opponent.is_empty() and not _boss_level_id.is_empty()
	if reuse_current_boss:
		_battle_kind = "boss"
	elif not pending_boss.is_empty():
		_battle_kind = "boss"
		_opponent = pending_boss.duplicate(true)
		_boss_level_id = String(_opponent.get("level_id", "normal"))
		GameState.data.erase("pending_boss_battle")
		GameState.save_game(false)
	else:
		_battle_kind = "league"
		_opponent = _resolve_pending_opponent(trophies)
		_boss_level_id = ""
	_elapsed = 0.0
	_winner = ""
	_finish_reason = ""
	_result_reward = {}
	_result_doubled = false
	_upgrade_rerolls_used = 0
	_revive_used = false
	_finished = false
	_paused = false
	_battle_active = true
	_battle_started_flash = 1.0
	var rank := MainPortData.rank_for_trophies(trophies)
	var rival_skin: Dictionary = _skin_dict_from_value(_opponent.get("skin", "neon_blue"))
	_rival = _make_arena("rival", String(_opponent.get("name", "Rival")), String(rival_skin.get("id", "neon_blue")), float(_opponent.get("quality", 0.45)), true)
	_player = _make_arena("player", String(GameState.data.get("nickname", "Voce")), String(GameState.data.get("equipped_skin", "neon_blue")), 1.0, false)
	_layout_arenas()
	_status_label.text = "BOSS %s" % _boss_level_id.to_upper() if _battle_kind == "boss" else "LIGA %s" % String(rank.get("name", "Bronze")).to_upper()
	_meta_label.text = "Duelo diario - %s" % String(_opponent.get("name", "Boss")) if _battle_kind == "boss" else "Temporada %s - %s trofeus" % [TimeManager.get_month_key(), trophies]
	_hide_overlays()
	if _result_double_button:
		_result_double_button.text = "DOBRAR RECOMPENSA - AD"
		_result_double_button.disabled = false
	if _result_retry_button:
		_result_retry_button.text = "VOLTAR AO BOSS" if _battle_kind == "boss" else "JOGAR NOVAMENTE"
	_update_status()
	_update_run_upgrade_buttons()
	queue_redraw()


func _resolve_pending_opponent(trophies: int) -> Dictionary:
	var pending: Dictionary = GameState.data.get("pending_league_opponent", {})
	if not pending.is_empty() and not bool(pending.get("is_player", false)):
		GameState.data.erase("pending_league_opponent")
		var rank := MainPortData.rank_for_trophies(int(pending.get("trophies", trophies)))
		return {
			"id": String(pending.get("id", "league_rival")),
			"name": String(pending.get("name", "Rival Neon")),
			"rank": rank,
			"quality": float(pending.get("quality", 0.55)),
			"skin": MainPortData.skin_by_id(String(pending.get("skin", "neon_blue"))),
		}
	return MainPortData.opponent_for(trophies)


func _skin_dict_from_value(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		var dict := Dictionary(value)
		if not dict.is_empty():
			return dict
	var skin := MainPortData.skin_by_id(String(value))
	if skin.is_empty():
		return MainPortData.skin_by_id("neon_blue")
	return skin


func _make_arena(id: String, label: String, skin_id: String, quality: float, ai: bool) -> Dictionary:
	var skin := MainPortData.skin_by_id(skin_id)
	var speed := BASE_BALL_SPEED + (0.18 if ai else 0.0) + quality * 0.28
	var angle := _safe_motion_angle(randf() * TWO_PI)
	return {
		"id": id,
		"label": label,
		"skin": skin_id,
		"skin_color": String(skin.get("primary", "#00f0ff")),
		"skin_secondary": String(skin.get("secondary", "#ffffff")),
		"skin_rarity": String(skin.get("rarity", "common")),
		"control": MainPortData.skin_has_control(skin_id),
		"control_strength": MainPortData.skin_control_strength(skin_id),
		"quality": quality,
		"ai": ai,
		"center": Vector2.ZERO,
		"arena_radius": 100.0,
		"ball": Vector2.ZERO,
		"prev_ball": Vector2.ZERO,
		"velocity": Vector2(cos(angle), sin(angle)) * speed,
		"rings": [],
		"spawned": 0,
		"coins": 0,
		"xp": 0,
		"total_xp": 0,
		"diamonds": 0,
		"level": 1,
		"score": 0,
		"atk": 0,
		"gold": 0,
		"run_upgrades": {},
		"run_upgrade_count": 0,
		"rings_destroyed": 0,
		"perfects": 0,
		"criticals": 0,
		"crushed": false,
		"level_pending": false,
		"crush_started": 0,
		"last_hit": 0,
		"last_direction_shift": Time.get_ticks_msec(),
		"effect_cooldowns": {},
		"trail": [],
		"bursts": [],
	}


func _layout_arenas() -> void:
	var viewport_size := size
	if viewport_size.x < 10.0 or viewport_size.y < 10.0:
		viewport_size = get_viewport_rect().size
	var hud_height := 150.0
	var controls_height := 166.0
	var gap := 44.0
	var available: float = max(260.0, viewport_size.y - hud_height - controls_height - gap)
	var arena_box_height: float = available / 2.0
	var max_radius: float = min((viewport_size.x - 88.0) / 2.0, arena_box_height / 2.0) - 10.0
	max_radius = clampf(max_radius, 72.0, 106.0)
	var top_center := Vector2(viewport_size.x / 2.0, hud_height + arena_box_height * 0.5)
	var bottom_center := Vector2(viewport_size.x / 2.0, hud_height + arena_box_height + gap + arena_box_height * 0.5)
	_assign_arena_metrics(_rival, top_center, max_radius)
	_assign_arena_metrics(_player, bottom_center, max_radius)


func _assign_arena_metrics(state: Dictionary, center: Vector2, radius: float) -> void:
	var had_center := Vector2(state.get("center", Vector2.ZERO))
	state["center"] = center
	state["arena_radius"] = radius
	if Array(state.get("rings", [])).is_empty():
		state["ball"] = center
		state["prev_ball"] = center
		state["rings"] = _create_initial_rings(state)
	else:
		var offset: Vector2 = Vector2(state.get("ball", center)) - had_center
		if had_center == Vector2.ZERO:
			offset = Vector2.ZERO
		state["ball"] = center + offset.limit_length(radius - BALL_RADIUS)
		state["prev_ball"] = state["ball"]
		for i in range(Array(state.get("rings", [])).size()):
			var ring: Dictionary = state["rings"][i]
			ring["radius"] = clampf(float(ring.get("radius", radius)), MIN_RING_RADIUS, radius - 3.0)
			state["rings"][i] = ring


func _create_initial_rings(state: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var count := _target_count_for_arena(state)
	var min_radius := MIN_RING_RADIUS
	var max_radius := float(state.get("arena_radius", 100.0)) - 4.0
	var spacing := (max_radius - min_radius) / float(max(1, count - 1))
	for i in range(count):
		var radius := max_radius - spacing * float(i)
		result.append(_make_ring(state, radius, i))
	state["spawned"] = count
	return result


func _target_count_for_arena(state: Dictionary) -> int:
	var capacity := floori((float(state.get("arena_radius", 100.0)) - MIN_RING_RADIUS) / MIN_RING_SPACING) + 1
	return clampi(min(TARGET_ACTIVE_RINGS, capacity), TARGET_ACTIVE_RINGS, MAX_ACTIVE_RINGS)


func _tick_arena(state: Dictionary, delta: float, is_ai: bool) -> void:
	if bool(state.get("crushed", false)):
		return
	_append_trail(state)
	var delta_steps := delta * PHYSICS_STEPS_PER_SECOND
	var target_speed := _target_ball_speed(state)
	var velocity: Vector2 = _stabilize_velocity(Vector2(state.get("velocity", Vector2.RIGHT)) )
	velocity = _clamp_vector_speed(velocity, target_speed * 0.78, target_speed * 1.42)
	state["velocity"] = velocity
	var travel := velocity.length() * delta_steps
	var substeps := clampi(ceili(travel / SAFE_STEP_DISTANCE), 1, MAX_PHYSICS_SUBSTEPS)
	var step_delta := delta_steps / float(substeps)
	for _step in range(substeps):
		var center: Vector2 = state.get("center", Vector2.ZERO)
		var prev_pos: Vector2 = state.get("ball", center)
		var prev_dist := (prev_pos - center).length()
		state["prev_ball"] = prev_pos
		_apply_dynamic_steering(state, step_delta)
		var next_pos: Vector2 = Vector2(state.get("ball", center)) + Vector2(state.get("velocity", Vector2.RIGHT)) * step_delta
		state["ball"] = next_pos
		_bounce_arena_edge(state)
		var next_dist := (Vector2(state.get("ball", center)) - center).length()
		_update_rings(state, step_delta)
		_check_perfect_escape(state, prev_dist, next_dist, prev_pos, Vector2(state.get("ball", center)))
		_check_ring_hit(state, prev_dist, next_dist, prev_pos, Vector2(state.get("ball", center)))
		_bounce_arena_edge(state)
		_clamp_ring_spacing(state)
		if _is_ball_crushed(state):
			var now := Time.get_ticks_msec()
			if int(state.get("crush_started", 0)) <= 0:
				state["crush_started"] = now
			elif now - int(state.get("crush_started", 0)) >= CRUSH_CONFIRM_MSEC:
				state["crushed"] = true
				return
		else:
			state["crush_started"] = 0
	_refill_rings(state)
	_update_visual_effects(state, delta)
	_update_level_progress(state)


func _update_rings(state: Dictionary, delta_steps: float) -> void:
	var level := int(state.get("level", 1))
	var pressure: float = min(0.65, float(int(state.get("rings_destroyed", 0))) * 0.006 + _elapsed * 0.0009)
	for i in range(Array(state.get("rings", [])).size()):
		var ring: Dictionary = state["rings"][i]
		if String(ring.get("status", "")) != "active":
			continue
		var grace_multiplier := 0.32 if Time.get_ticks_msec() < int(ring.get("defeat_grace_until", 0)) else 1.0
		ring["rotation"] = _normalize_angle(float(ring.get("rotation", 0.0)) + float(ring.get("rotation_speed", 0.004)) * delta_steps)
		ring["radius"] = max(float(ring.get("min_radius", MIN_RING_RADIUS)), float(ring.get("radius", 0.0)) - float(ring.get("closing_speed", 0.008)) * delta_steps * (1.0 + pressure + float(level) * 0.014) * grace_multiplier)
		if int(ring.get("effect_until", 0)) > 0 and Time.get_ticks_msec() > int(ring.get("effect_until", 0)):
			ring["effect_color"] = ""
			ring["rotation_speed"] = float(ring.get("base_rotation_speed", ring.get("rotation_speed", 0.004)))
		state["rings"][i] = ring


func _refill_rings(state: Dictionary) -> void:
	var target := _target_count_for_arena(state)
	var attempts := 0
	while _active_ring_count(state) < target and attempts < 16:
		attempts += 1
		_append_ring(state)
	_clamp_ring_spacing(state)


func _append_ring(state: Dictionary) -> void:
	var rings: Array = state.get("rings", [])
	var max_radius := float(state.get("arena_radius", 100.0)) - 4.0
	var radius := max_radius
	for ring in rings:
		if String(ring.get("status", "")) == "active":
			radius = max(radius, min(max_radius, float(ring.get("radius", max_radius)) + MIN_RING_SPACING))
	var index := int(state.get("spawned", 0))
	state["spawned"] = index + 1
	rings.append(_make_ring(state, radius, index))
	state["rings"] = rings


func _make_ring(state: Dictionary, radius: float, index: int) -> Dictionary:
	var level := int(state.get("level", 1))
	var destroyed := int(state.get("rings_destroyed", 0))
	var quality := float(state.get("quality", 0.5))
	var is_solid: bool = level >= 4 and index % max(8, 13 - min(5, level / 3)) == 0
	var direction: float = 1.0 if index % 2 == 0 else -1.0
	var hp: int = floori((18.0 + float(level) * 2.7 + float(destroyed) * 0.22) * (1.0 + quality * 0.35) * (1.45 if is_solid else 1.0))
	var gap: float = 0.0 if is_solid else max(PI / 14.0, PI / (3.45 + float(level) * 0.07 + float(destroyed) * 0.003))
	var rotation_speed: float = (0.0042 + float(level) * 0.00028 + quality * 0.0018) * randf_range(0.86, 1.18) * direction
	return {
		"id": "%s_ring_%s" % [String(state.get("id", "arena")), index],
		"type": "solid" if is_solid else "normal",
		"radius": clampf(radius, MIN_RING_RADIUS, float(state.get("arena_radius", 100.0)) - 4.0),
		"initial_radius": radius,
		"closing_speed": 0.0067 + float(level) * 0.00046 + quality * 0.0015 + float(destroyed) * 0.000015,
		"rotation": randf() * TWO_PI,
		"rotation_speed": rotation_speed,
		"base_rotation_speed": rotation_speed,
		"gap_start": randf() * TWO_PI,
		"gap_size": gap,
		"hp": hp,
		"max_hp": hp,
		"status": "active",
		"thickness": 6.5 if is_solid else 5.0,
		"color": "#ff0055" if is_solid else RING_PALETTE[index % RING_PALETTE.size()],
		"min_radius": 4.0,
		"effect_color": "",
		"effect_until": 0,
		"spawned_at": Time.get_ticks_msec(),
		"defeat_grace_until": Time.get_ticks_msec() + RING_SPAWN_GRACE_MSEC,
	}


func _check_perfect_escape(state: Dictionary, prev_dist: float, next_dist: float, prev_pos: Vector2, next_pos: Vector2) -> void:
	var center: Vector2 = state.get("center", Vector2.ZERO)
	for i in range(Array(state.get("rings", [])).size()):
		var ring: Dictionary = state["rings"][i]
		if String(ring.get("status", "")) != "active" or String(ring.get("type", "normal")) == "solid":
			continue
		var radius: float = float(ring.get("radius", 0.0))
		var crossed: bool = (prev_dist - radius) * (next_dist - radius) <= 0.0
		var near: bool = abs(next_dist - radius) <= BALL_RADIUS + abs(next_dist - prev_dist) + float(ring.get("thickness", 5.0))
		var contact := _segment_contact_for_radius(state, prev_pos, next_pos, radius)
		var angle := _normalize_angle((next_pos - center).angle())
		if bool(contact.get("ok", false)):
			angle = float(contact.get("angle", angle))
		if crossed and near and _is_angle_inside_gap(angle, ring, 0.014):
			ring["status"] = "cleared"
			ring["hp"] = 0
			state["rings"][i] = ring
			state["rings_destroyed"] = int(state.get("rings_destroyed", 0)) + 1
			state["perfects"] = int(state.get("perfects", 0)) + 1
			_award_arena_coins(state, 8 + int(state.get("gold", 0)) * 2)
			_award_arena_xp(state, floori(30.0 * _xp_multiplier(state)))
			if String(state.get("id", "")) == "player":
				_play_sfx("clear")
				if randf() < 0.035 + _perfect_bonus(state):
					state["diamonds"] = int(state.get("diamonds", 0)) + 1
			_spawn_burst(state, Vector2(state.get("ball", center)), String(ring.get("color", "#00f0ff")), "clear")
			return


func _check_ring_hit(state: Dictionary, prev_dist: float, next_dist: float, prev_pos: Vector2, next_pos: Vector2) -> void:
	var closest_index := -1
	var closest_dist := INF
	for i in range(Array(state.get("rings", [])).size()):
		var ring: Dictionary = state["rings"][i]
		if String(ring.get("status", "")) != "active":
			continue
		var collision := _check_ring_collision(state, ring, prev_dist, next_dist, prev_pos, next_pos)
		if bool(collision.get("overlap", false)) and not bool(collision.get("gap", false)) and float(collision.get("dist", 999.0)) < closest_dist:
			closest_dist = float(collision.get("dist", 999.0))
			closest_index = i
	if closest_index < 0:
		return
	var now := Time.get_ticks_msec()
	if now - int(state.get("last_hit", 0)) <= 80:
		return
	state["last_hit"] = now
	var ring: Dictionary = state["rings"][closest_index]
	_separate_and_reflect(state, ring, prev_dist)
	var crit := randf() * 100.0 < _crit_chance(state)
	var damage := floori(float(_base_damage(state)) * (2.0 if crit else 1.0))
	damage += _apply_special_upgrade_effects(state, closest_index, damage)
	ring = state["rings"][closest_index]
	var new_hp: int = max(0, int(ring.get("hp", 0)) - damage)
	ring["hp"] = new_hp
	ring["status"] = "broken" if new_hp <= 0 else "active"
	state["rings"][closest_index] = ring
	state["score"] = int(state.get("score", 0)) + damage
	if crit:
		state["criticals"] = int(state.get("criticals", 0)) + 1
	_award_arena_coins(state, max(2, floori(float(damage) * 0.72 * _gold_multiplier(state))))
	_award_arena_xp(state, floori((18.0 if crit else 12.0) * _xp_multiplier(state)))
	if new_hp <= 0:
		state["rings_destroyed"] = int(state.get("rings_destroyed", 0)) + 1
		_spawn_burst(state, Vector2(state.get("ball", Vector2.ZERO)), String(ring.get("color", "#00f0ff")), "break")
		_award_arena_coins(state, max(8, floori((24.0 if String(ring.get("type", "normal")) == "solid" else 16.0) * _gold_multiplier(state))))
		_award_arena_xp(state, floori((22.0 + randf() * 12.0) * _xp_multiplier(state)))
		if String(state.get("id", "")) == "player":
			_play_sfx("break")
	elif String(state.get("id", "")) == "player":
		_spawn_burst(state, Vector2(state.get("ball", Vector2.ZERO)), String(ring.get("color", "#00f0ff")), "hit")
		_play_sfx("crit" if crit else "hit")


func _check_ring_collision(state: Dictionary, ring: Dictionary, prev_dist: float, next_dist: float, prev_pos: Vector2, next_pos: Vector2) -> Dictionary:
	var center: Vector2 = state.get("center", Vector2.ZERO)
	var ball: Vector2 = state.get("ball", center)
	var offset: Vector2 = ball - center
	var dist_from_center: float = offset.length()
	var radius: float = float(ring.get("radius", 0.0))
	var dist_from_ring: float = abs(dist_from_center - radius)
	var overlapping: bool = dist_from_ring <= float(ring.get("thickness", 5.0)) / 2.0 + BALL_RADIUS
	var crossed: bool = (prev_dist - radius) * (next_dist - radius) <= 0.0
	var swept_near: bool = abs(next_dist - prev_dist) + BALL_RADIUS + float(ring.get("thickness", 5.0)) >= min(abs(prev_dist - radius), abs(next_dist - radius))
	overlapping = overlapping or (crossed and swept_near)
	var angle := _normalize_angle(offset.angle())
	var contact := _segment_contact_for_radius(state, prev_pos, next_pos, radius)
	if bool(contact.get("ok", false)):
		angle = float(contact.get("angle", angle))
		dist_from_ring = min(dist_from_ring, float(contact.get("distance", dist_from_ring)))
	var in_gap: bool = false if String(ring.get("type", "normal")) == "solid" else _is_angle_inside_gap(angle, ring, min(0.018, BALL_RADIUS / max(1.0, radius) * 0.22))
	return { "overlap": overlapping, "gap": in_gap, "dist": dist_from_ring, "angle": angle }


func _segment_contact_for_radius(state: Dictionary, prev_pos: Vector2, next_pos: Vector2, radius: float) -> Dictionary:
	var center: Vector2 = state.get("center", Vector2.ZERO)
	var start := prev_pos - center
	var end := next_pos - center
	var delta := end - start
	var a := delta.dot(delta)
	if a <= 0.0001:
		return { "ok": false }
	var b := 2.0 * start.dot(delta)
	var c := start.dot(start) - radius * radius
	var disc := b * b - 4.0 * a * c
	if disc < 0.0:
		return { "ok": false, "distance": abs(end.length() - radius) }
	var root := sqrt(disc)
	var t := (-b - root) / (2.0 * a)
	if t < 0.0 or t > 1.0:
		t = (-b + root) / (2.0 * a)
	if t < 0.0 or t > 1.0:
		return { "ok": false, "distance": abs(end.length() - radius) }
	var point := start.lerp(end, t)
	return { "ok": true, "angle": _normalize_angle(point.angle()), "distance": abs(point.length() - radius), "t": t }


func _is_angle_inside_gap(angle: float, ring: Dictionary, padding: float = 0.0) -> bool:
	if String(ring.get("type", "normal")) == "solid":
		return false
	var gap_center := _normalize_angle(float(ring.get("gap_start", 0.0)) + float(ring.get("rotation", 0.0)))
	var diff: float = abs(_normalize_angle(angle - gap_center))
	diff = min(diff, TWO_PI - diff)
	return diff <= max(0.0, float(ring.get("gap_size", 0.0)) / 2.0 - padding)


func _separate_and_reflect(state: Dictionary, ring: Dictionary, prev_dist: float) -> void:
	var center: Vector2 = state.get("center", Vector2.ZERO)
	var ball: Vector2 = state.get("ball", center)
	var radial: Vector2 = ball - center
	var dist: float = max(1.0, radial.length())
	var radial_dir: Vector2 = radial / dist
	var started_outside: bool = prev_dist >= float(ring.get("radius", dist))
	var normal: Vector2 = radial_dir if started_outside else -radial_dir
	var safe_distance: float = float(ring.get("radius", dist)) + float(ring.get("thickness", 5.0)) / 2.0 + BALL_RADIUS + 2.0 if started_outside else max(0.0, float(ring.get("radius", dist)) - float(ring.get("thickness", 5.0)) / 2.0 - BALL_RADIUS - 2.0)
	state["ball"] = center + radial_dir * min(float(state.get("arena_radius", 100.0)) - BALL_RADIUS, safe_distance)
	var velocity: Vector2 = state.get("velocity", Vector2.RIGHT)
	var dot := velocity.dot(normal)
	if dot < 0.0:
		velocity -= 2.0 * dot * normal
		state["velocity"] = _stabilize_velocity(_clamp_vector_speed(velocity.rotated(randf_range(-0.16, 0.16)) * 1.04, _target_ball_speed(state) * 0.82, _target_ball_speed(state) * 1.5))
		state["last_direction_shift"] = Time.get_ticks_msec()


func _bounce_arena_edge(state: Dictionary) -> void:
	var center: Vector2 = state.get("center", Vector2.ZERO)
	var ball: Vector2 = state.get("ball", center)
	var offset := ball - center
	var limit := float(state.get("arena_radius", 100.0)) - BALL_RADIUS
	if offset.length() > limit:
		var normal := offset.normalized()
		state["ball"] = center + normal * limit
		var velocity: Vector2 = state.get("velocity", Vector2.RIGHT)
		state["velocity"] = _stabilize_velocity(velocity.bounce(normal).rotated(randf_range(-0.14, 0.14)))
		state["last_direction_shift"] = Time.get_ticks_msec()


func _is_ball_crushed(state: Dictionary) -> bool:
	for ring in Array(state.get("rings", [])):
		if String(ring.get("status", "")) != "active" or int(ring.get("hp", 0)) <= 0:
			continue
		if Time.get_ticks_msec() < int(ring.get("defeat_grace_until", 0)):
			continue
		var collision := _check_ring_collision(state, ring, -1.0, -1.0, Vector2.ZERO, Vector2.ZERO)
		if bool(collision.get("gap", false)) or not bool(collision.get("overlap", false)):
			continue
		var center: Vector2 = state.get("center", Vector2.ZERO)
		var dist := (Vector2(state.get("ball", center)) - center).length()
		var outer_edge := float(ring.get("radius", 0.0)) + float(ring.get("thickness", 5.0)) / 2.0
		if outer_edge <= max(0.0, dist - BALL_RADIUS * 0.25) or (dist <= BALL_RADIUS * 1.15 and outer_edge <= BALL_RADIUS + 4.0):
			return true
	return false


func _clamp_ring_spacing(state: Dictionary) -> void:
	var indices: Array[int] = []
	for i in range(Array(state.get("rings", [])).size()):
		var ring: Dictionary = state["rings"][i]
		if String(ring.get("status", "")) == "active" and int(ring.get("hp", 0)) > 0:
			indices.append(i)
	for i in range(indices.size()):
		for j in range(i + 1, indices.size()):
			var left: Dictionary = state["rings"][indices[i]]
			var right: Dictionary = state["rings"][indices[j]]
			var left_radius: float = float(left.get("radius", 0.0))
			var right_radius: float = float(right.get("radius", 0.0))
			var right_is_outer: bool = right_radius > left_radius
			var same_radius_newer: bool = absf(right_radius - left_radius) < 0.01 and int(right.get("spawned_at", 0)) > int(left.get("spawned_at", 0))
			if right_is_outer or same_radius_newer:
				var temp := indices[i]
				indices[i] = indices[j]
				indices[j] = temp
	var min_radius := MIN_RING_RADIUS
	var crush_min_radius := 4.0
	var max_radius := float(state.get("arena_radius", 100.0)) - 4.0
	var spacing: float = min(MIN_RING_SPACING, max(4.2, (max_radius - min_radius) / float(max(1, indices.size() - 1))))
	var previous: float = max_radius + spacing
	var now: int = Time.get_ticks_msec()
	for index in indices:
		var ring: Dictionary = state["rings"][index]
		var upper_bound: float = minf(max_radius, previous - spacing)
		var lower_bound: float = maxf(float(ring.get("min_radius", crush_min_radius)), crush_min_radius)
		var current_radius: float = float(ring.get("radius", upper_bound))
		var radius: float = clampf(current_radius, lower_bound, maxf(lower_bound, upper_bound))
		if abs(radius - current_radius) > 0.5 and now - int(ring.get("spawned_at", 0)) > 180:
			ring["defeat_grace_until"] = maxi(int(ring.get("defeat_grace_until", 0)), now + 260)
		ring["radius"] = radius
		previous = radius
		state["rings"][index] = ring


func _active_ring_count(state: Dictionary) -> int:
	var count := 0
	for ring in Array(state.get("rings", [])):
		if String(ring.get("status", "")) == "active" and int(ring.get("hp", 0)) > 0:
			count += 1
	return count


func _update_level_progress(state: Dictionary) -> void:
	var needed := _arena_xp_needed(int(state.get("level", 1)))
	if int(state.get("xp", 0)) < needed:
		return
	state["xp"] = int(state.get("xp", 0)) - needed
	state["level"] = int(state.get("level", 1)) + 1
	state["level_pending"] = true


func _open_player_upgrade() -> void:
	_battle_active = false
	_player["level_pending"] = false
	_current_upgrade_choices = _upgrade_choices(_player, true)
	_render_player_upgrade_choices()
	_level_up_overlay.visible = true


func _render_player_upgrade_choices() -> void:
	for child in _level_up_cards.get_children():
		child.queue_free()
	if _current_upgrade_choices.is_empty():
		_level_up_cards.add_child(_make_label("Todas as melhorias chegaram ao limite.", 13, "#ffffffcc", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	else:
		for upgrade in _current_upgrade_choices:
			var id := String(upgrade.get("id", ""))
			var current := int(Dictionary(_player.get("run_upgrades", {})).get(id, 0))
			var button := _make_button("%s\n%s\nLv.%s > Lv.%s" % [String(upgrade.get("name", id)).to_upper(), String(upgrade.get("description", "")), current, current + 1], 286, 60)
			button.add_theme_font_size_override("font_size", 10)
			_set_button_icon(button, _upgrade_icon_key(id))
			button.pressed.connect(_select_player_upgrade.bind(id))
			_level_up_cards.add_child(button)
	_render_reroll_actions()


func _render_reroll_actions() -> void:
	if not _level_up_actions:
		return
	for child in _level_up_actions.get_children():
		child.queue_free()
	if _current_upgrade_choices.is_empty():
		return
	var label := _make_label("Rerolls %s/%s" % [_upgrade_rerolls_used, MAX_UPGRADE_REROLLS], 12, "#ffffffaa", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	_level_up_actions.add_child(label)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	_level_up_actions.add_child(row)
	var ad_button := _make_button("REROLL\nVIDEO", 0, 42)
	ad_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ad_button.disabled = _upgrade_rerolls_used >= MAX_UPGRADE_REROLLS
	ad_button.pressed.connect(_reroll_player_upgrades_with_ad)
	row.add_child(ad_button)
	var diamond_button := _make_button("REROLL\n%s DIAMANTES" % REROLL_DIAMOND_COST, 0, 42)
	diamond_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	diamond_button.disabled = _upgrade_rerolls_used >= MAX_UPGRADE_REROLLS or int(GameState.data.get("diamonds", 0)) < REROLL_DIAMOND_COST
	diamond_button.pressed.connect(_reroll_player_upgrades_with_diamonds)
	row.add_child(diamond_button)


func _reroll_player_upgrades_with_ad() -> void:
	if _upgrade_rerolls_used >= MAX_UPGRADE_REROLLS:
		_play_sfx("click")
		return
	GameState.show_mock_rewarded_ad(func(ok: bool) -> void:
		if ok:
			_consume_upgrade_reroll()
	)


func _reroll_player_upgrades_with_diamonds() -> void:
	if _upgrade_rerolls_used >= MAX_UPGRADE_REROLLS:
		_play_sfx("click")
		return
	if not GameState.spend_diamonds(REROLL_DIAMOND_COST):
		_play_sfx("click")
		return
	_consume_upgrade_reroll()


func _consume_upgrade_reroll() -> void:
	_upgrade_rerolls_used += 1
	_current_upgrade_choices = _upgrade_choices(_player, true)
	_render_player_upgrade_choices()
	_play_sfx("select")


func _select_player_upgrade(id: String) -> void:
	_apply_run_upgrade(_player, id)
	_level_up_overlay.visible = false
	_battle_active = true
	_play_sfx("select")
	_update_status()


func _apply_ai_upgrade(state: Dictionary) -> void:
	state["level_pending"] = false
	var choices := _upgrade_choices(state, false)
	if choices.is_empty():
		return
	var weighted := choices[0]
	for option in choices:
		var id := String(option.get("id", ""))
		if id in ["damage", "speed", "critical", "coinBoost", "xpBoost"]:
			weighted = option
			break
	_apply_run_upgrade(state, String(weighted.get("id", "damage")))


func _upgrade_choices(state: Dictionary, player_only: bool) -> Array[Dictionary]:
	if player_only:
		GameState.refresh_unlocks(false)
	var unlocked: Array = _player_unlocked_run_upgrade_ids() if player_only else MainPortData.released_run_upgrade_ids()
	var options: Array[Dictionary] = []
	for upgrade in MainPortData.run_upgrades():
		var id := String(upgrade.get("id", ""))
		if id.is_empty() or bool(upgrade.get("secret", false)):
			continue
		if not unlocked.has(id):
			continue
		if not player_only and int(upgrade.get("unlockLevel", 1)) > int(state.get("level", 1)) + 4:
			continue
		if int(Dictionary(state.get("run_upgrades", {})).get(id, 0)) >= int(upgrade.get("maxLevel", 1)):
			continue
		var copy := upgrade.duplicate(true)
		options.append(copy)
	options.shuffle()
	while options.size() < 3 and not options.is_empty():
		options.append(Dictionary(options[randi() % options.size()]).duplicate(true))
	return options.slice(0, min(3, options.size()))


func _player_unlocked_run_upgrade_ids() -> Array[String]:
	var released: Array[String] = MainPortData.released_run_upgrade_ids()
	var unlocked_save: Array = GameState.data.get("unlocked_upgrades", [])
	var explicit: Array = GameState.data.get("explicit_unlocked_run_upgrades", [])
	var result: Array[String] = []
	for id in MainPortData.auto_run_upgrade_ids():
		var upgrade_id := String(id)
		if released.has(upgrade_id) and not result.has(upgrade_id):
			result.append(upgrade_id)
	for id in explicit:
		var upgrade_id := String(id)
		if released.has(upgrade_id) and unlocked_save.has(upgrade_id) and not result.has(upgrade_id):
			result.append(upgrade_id)
	return result


func _apply_run_upgrade(state: Dictionary, id: String) -> void:
	var upgrades: Dictionary = state.get("run_upgrades", {})
	upgrades[id] = int(upgrades.get(id, 0)) + 1
	state["run_upgrades"] = upgrades
	state["run_upgrade_count"] = int(state.get("run_upgrade_count", 0)) + 1
	if id == "speed":
		state["velocity"] = Vector2(state.get("velocity", Vector2.RIGHT)) * 1.06
	elif id == "coinBoost":
		state["gold"] = int(state.get("gold", 0)) + 1
	elif id in ["damage", "critical", "burn", "frost", "ringRepulse", "shockwave", "chainLightning"]:
		state["atk"] = int(state.get("atk", 0)) + 1


func _update_bot_run_shop() -> void:
	if _rival.is_empty():
		return
	for type in ["atk", "gold"]:
		var cost := _get_run_upgrade_cost(_rival, type)
		if int(_rival.get("coins", 0)) >= cost and randf() < 0.28 + float(_rival.get("quality", 0.4)) * 0.18:
			_rival["coins"] = int(_rival.get("coins", 0)) - cost
			_rival[type] = int(_rival.get(type, 0)) + 1
			_rival["run_upgrade_count"] = int(_rival.get("run_upgrade_count", 0)) + 1


func _buy_player_run_upgrade(type: String) -> void:
	var cost := _get_run_upgrade_cost(_player, type)
	if int(_player.get("coins", 0)) < cost:
		_play_sfx("click")
		return
	_player["coins"] = int(_player.get("coins", 0)) - cost
	_player[type] = int(_player.get(type, 0)) + 1
	_player["run_upgrade_count"] = int(_player.get("run_upgrade_count", 0)) + 1
	_play_sfx("select")
	_update_run_upgrade_buttons()
	_update_status()


func _get_run_upgrade_cost(state: Dictionary, type: String) -> int:
	var base := 20 if type == "atk" else 18
	return floori(base * pow(1.35, int(state.get(type, 0))))


func _award_arena_coins(state: Dictionary, amount: int) -> void:
	state["coins"] = int(state.get("coins", 0)) + max(0, amount)
	if String(state.get("id", "")) == "player":
		_update_run_upgrade_buttons()


func _award_arena_xp(state: Dictionary, amount: int) -> void:
	var value: int = max(0, amount)
	state["xp"] = int(state.get("xp", 0)) + value
	state["total_xp"] = int(state.get("total_xp", 0)) + value


func _base_damage(state: Dictionary) -> int:
	var permanent: Dictionary = GameState.data.get("permanent_upgrades", {}) if not bool(state.get("ai", false)) else {}
	var base := 10.0 * pow(1.1, int(permanent.get("baseDamage", 0)))
	base *= 1.0 + int(state.get("atk", 0)) * 0.12
	base *= 1.0 + int(Dictionary(state.get("run_upgrades", {})).get("damage", 0)) * 0.15
	base *= 1.0 + float(state.get("quality", 0.5)) * (0.08 if bool(state.get("ai", false)) else 0.0)
	return max(1, roundi(base))


func _target_ball_speed(state: Dictionary) -> float:
	var permanent: Dictionary = GameState.data.get("permanent_upgrades", {}) if not bool(state.get("ai", false)) else {}
	var speed: float = BASE_BALL_SPEED + min(1.05, float(int(state.get("level", 1)) - 1) * 0.028 + float(int(state.get("rings_destroyed", 0))) * 0.002)
	speed *= 1.0 + int(permanent.get("baseSpeed", 0)) * 0.018 + int(Dictionary(state.get("run_upgrades", {})).get("speed", 0)) * 0.2
	speed *= 1.0 + float(state.get("quality", 0.5)) * (0.05 if bool(state.get("ai", false)) else 0.0)
	return speed


func _gold_multiplier(state: Dictionary) -> float:
	var permanent: Dictionary = GameState.data.get("permanent_upgrades", {}) if not bool(state.get("ai", false)) else {}
	return (1.0 + int(permanent.get("coinMultiplier", 0)) * 0.15) * (1.0 + int(state.get("gold", 0)) * 0.12 + int(Dictionary(state.get("run_upgrades", {})).get("coinBoost", 0)) * 0.5)


func _xp_multiplier(state: Dictionary) -> float:
	var permanent: Dictionary = GameState.data.get("permanent_upgrades", {}) if not bool(state.get("ai", false)) else {}
	return (1.0 + int(permanent.get("xpBoost", 0)) * 0.2) * (1.0 + int(state.get("gold", 0)) * 0.05 + int(Dictionary(state.get("run_upgrades", {})).get("xpBoost", 0)) * 0.5)


func _crit_chance(state: Dictionary) -> float:
	var permanent: Dictionary = GameState.data.get("permanent_upgrades", {}) if not bool(state.get("ai", false)) else {}
	return 5.0 + int(permanent.get("critChance", 0)) * 2.0 + int(Dictionary(state.get("run_upgrades", {})).get("critical", 0)) * 5.0


func _perfect_bonus(state: Dictionary) -> float:
	return int(Dictionary(state.get("run_upgrades", {})).get("perfectChance", 0)) * 0.01


func _apply_special_upgrade_effects(state: Dictionary, ring_index: int, damage: int) -> int:
	var upgrades: Dictionary = state.get("run_upgrades", {})
	var bonus := 0
	var ring: Dictionary = state["rings"][ring_index]
	var burn_level := int(upgrades.get("burn", 0))
	if burn_level > 0 and _can_trigger_arena_effect(state, "burn", 0.12 + burn_level * 0.035, 650):
		bonus += 4 * burn_level
		ring["effect_color"] = "#ff6b00"
		ring["effect_until"] = Time.get_ticks_msec() + 900
		_mark_arena_effect_triggered(state, "burn", 650)
	var frost_level := int(upgrades.get("frost", 0))
	if frost_level > 0 and _can_trigger_arena_effect(state, "frost", 0.12 + frost_level * 0.03, 900):
		ring["rotation_speed"] = float(ring.get("base_rotation_speed", ring.get("rotation_speed", 0.004))) * 0.42
		ring["effect_color"] = "#b8f3ff"
		ring["effect_until"] = Time.get_ticks_msec() + 1500
		_mark_arena_effect_triggered(state, "frost", 900)
	var repulse_level := int(upgrades.get("ringRepulse", 0))
	var repulse_cooldown: int = maxi(850, 1550 - repulse_level * 120)
	if repulse_level > 0 and _can_trigger_arena_effect(state, "ringRepulse", 0.08 + repulse_level * 0.018, repulse_cooldown):
		ring["radius"] = min(float(state.get("arena_radius", 100.0)) - 5.0, float(ring.get("radius", 0.0)) + 12.0)
		ring["defeat_grace_until"] = Time.get_ticks_msec() + 520
		_spawn_burst(state, Vector2(state.get("ball", Vector2.ZERO)), "#00f0ff", "repulse")
		_mark_arena_effect_triggered(state, "ringRepulse", repulse_cooldown)
	state["rings"][ring_index] = ring
	var shockwave_level := int(upgrades.get("shockwave", 0))
	if shockwave_level > 0 and _can_trigger_arena_effect(state, "shockwave", 0.12, 760):
		bonus += floori(float(damage) * 0.35)
		_mark_arena_effect_triggered(state, "shockwave", 760)
	var chain_level := int(upgrades.get("chainLightning", 0))
	if chain_level > 0 and _can_trigger_arena_effect(state, "chainLightning", 0.12, 760):
		bonus += floori(float(damage) * 0.28)
		_mark_arena_effect_triggered(state, "chainLightning", 760)
	return bonus


func _can_trigger_arena_effect(state: Dictionary, id: String, chance: float, _cooldown_ms: int) -> bool:
	var cooldowns: Dictionary = state.get("effect_cooldowns", {})
	var now := Time.get_ticks_msec()
	if now < int(cooldowns.get(id, 0)):
		return false
	return randf() < clampf(chance, 0.0, 0.75)


func _mark_arena_effect_triggered(state: Dictionary, id: String, cooldown_ms: int) -> void:
	var cooldowns: Dictionary = state.get("effect_cooldowns", {})
	cooldowns[id] = Time.get_ticks_msec() + max(0, cooldown_ms)
	state["effect_cooldowns"] = cooldowns


func _arena_xp_needed(level: int) -> int:
	return floori(XP_BASE * pow(max(1, level), 1.34))


func _apply_dynamic_steering(state: Dictionary, delta_steps: float) -> void:
	var velocity: Vector2 = state.get("velocity", Vector2.RIGHT)
	var speed := velocity.length()
	if speed <= 0.01:
		return
	var dir := velocity / speed
	var stale := Time.get_ticks_msec() - int(state.get("last_direction_shift", 0)) > 1400
	if abs(dir.y) < 0.24 or abs(dir.x) < 0.16 or stale:
		var amount := (0.024 if stale else 0.034) * (-1.0 if randf() < 0.5 else 1.0) * clampf(delta_steps, 0.4, 2.4)
		state["velocity"] = _stabilize_velocity(velocity.rotated(amount))
		state["last_direction_shift"] = Time.get_ticks_msec()
	if not bool(state.get("ai", false)) and bool(state.get("control", false)) and abs(_control_input) > 0.01:
		var current := Vector2(state.get("velocity", velocity)).normalized()
		var strength := clampf(float(state.get("control_strength", 0.0)), 0.0, 0.85)
		var desired := (current + Vector2(_control_input * (0.42 + strength * 0.74), 0.0)).normalized()
		state["velocity"] = desired * speed


func _append_trail(state: Dictionary) -> void:
	var trail: Array = state.get("trail", [])
	var ball: Vector2 = state.get("ball", state.get("center", Vector2.ZERO))
	if trail.is_empty() or Vector2(trail[trail.size() - 1]).distance_to(ball) > 4.0:
		trail.append(ball)
	while trail.size() > (12 if String(state.get("id", "")) == "player" else 9):
		trail.pop_front()
	state["trail"] = trail


func _spawn_burst(state: Dictionary, position: Vector2, color: String, kind: String) -> void:
	var bursts: Array = state.get("bursts", [])
	var base_radius := 24.0
	if kind == "clear":
		base_radius = 34.0
	elif kind == "break":
		base_radius = 28.0
	elif kind == "repulse":
		base_radius = 42.0
	bursts.append({
		"position": position,
		"color": color,
		"kind": kind,
		"life": 0.34,
		"max_life": 0.34,
		"radius": base_radius,
	})
	while bursts.size() > 10:
		bursts.pop_front()
	state["bursts"] = bursts


func _update_visual_effects(state: Dictionary, delta: float) -> void:
	var bursts: Array = state.get("bursts", [])
	for i in range(bursts.size() - 1, -1, -1):
		var burst: Dictionary = bursts[i]
		burst["life"] = float(burst.get("life", 0.0)) - delta
		if float(burst.get("life", 0.0)) <= 0.0:
			bursts.remove_at(i)
		else:
			bursts[i] = burst
	state["bursts"] = bursts


func _safe_motion_angle(angle: float) -> float:
	var vector := Vector2(cos(angle), sin(angle))
	if abs(vector.y) < 0.24:
		vector.y = 0.24 * (-1.0 if vector.y < 0.0 else 1.0)
	if abs(vector.x) < 0.16:
		vector.x = 0.16 * (-1.0 if vector.x < 0.0 else 1.0)
	return _normalize_angle(vector.normalized().angle())


func _stabilize_velocity(value: Vector2) -> Vector2:
	var speed := value.length()
	if speed <= 0.01:
		var angle := _safe_motion_angle(randf() * TWO_PI)
		return Vector2(cos(angle), sin(angle)) * BASE_BALL_SPEED
	var angle := _safe_motion_angle(value.angle())
	return Vector2(cos(angle), sin(angle)) * speed


func _clamp_vector_speed(value: Vector2, min_speed: float, max_speed: float) -> Vector2:
	var speed := value.length()
	if speed <= 0.01:
		return Vector2.RIGHT * min_speed
	return value.normalized() * clampf(speed, min_speed, max_speed)


func _timed_result() -> String:
	var player_rings := int(_player.get("rings_destroyed", 0))
	var rival_rings := int(_rival.get("rings_destroyed", 0))
	if player_rings != rival_rings:
		return "win" if player_rings > rival_rings else "loss"
	var player_score := int(_player.get("score", 0))
	var rival_score := int(_rival.get("score", 0))
	return "win" if player_score >= rival_score else "loss"


func _offer_revive_or_finish() -> void:
	if _revive_used:
		_finish_match("loss", "voce foi preso")
		return
	_battle_active = false
	_paused = true
	_play_sfx("defeat")
	_revive_overlay.visible = true


func _revive_with_ad() -> void:
	if _revive_used or _finished:
		return
	GameState.show_mock_rewarded_ad(func(ok: bool) -> void:
		if not ok:
			return
		_revive_used = true
		_revive_overlay.visible = false
		_paused = false
		_battle_active = true
		_player["crushed"] = false
		_player["crush_started"] = 0
		_player["ball"] = Vector2(_player.get("center", Vector2.ZERO))
		_player["prev_ball"] = _player["ball"]
		_player["velocity"] = Vector2(_target_ball_speed(_player), -_target_ball_speed(_player) * 0.72)
		for i in range(Array(_player.get("rings", [])).size()):
			var ring: Dictionary = _player["rings"][i]
			if String(ring.get("status", "")) == "active":
				ring["radius"] = max(float(ring.get("radius", MIN_RING_RADIUS)), MIN_RING_RADIUS + 24.0)
				ring["defeat_grace_until"] = Time.get_ticks_msec() + 1400
				_player["rings"][i] = ring
		_play_sfx("level")
	)


func _accept_loss() -> void:
	_revive_overlay.visible = false
	_paused = false
	_finish_match("loss", "voce foi preso")


func _finish_match(result: String, reason: String = "") -> void:
	if _finished:
		return
	_finished = true
	_battle_active = false
	_paused = false
	_winner = result
	_finish_reason = reason
	var global_coins: int = max(0, floori(float(int(_player.get("coins", 0))) * 0.72))
	var profile_xp: int = max(0, floori(float(int(_player.get("total_xp", 0))) * 0.95))
	var summary := {
		"opponent_id": String(_opponent.get("id", "")),
		"seconds": floori(_elapsed),
		"rings": int(_player.get("rings_destroyed", 0)),
		"coins": global_coins,
		"xp": profile_xp,
		"diamonds": int(_player.get("diamonds", 0)),
		"score": int(_player.get("score", 0)),
		"best_combo": 0,
		"criticals": int(_player.get("criticals", 0)),
		"skin_effects": 0,
		"run_upgrades": int(_player.get("run_upgrade_count", 0)),
	}
	_result_reward = GameState.record_boss_match(_boss_level_id, result, summary) if _battle_kind == "boss" else GameState.record_neon_league_match(result, summary)
	if result == "win":
		_play_sfx("victory")
	elif result == "loss":
		_play_sfx("defeat")
	else:
		_play_sfx("click")
	_show_result(summary)


func _show_result(summary: Dictionary) -> void:
	if _battle_kind == "boss":
		_result_title.text = "BOSS DERROTADO" if _winner == "win" else "DERROTA NO BOSS" if _winner == "loss" else "SAIDA DO BOSS"
	else:
		_result_title.text = "VITORIA NEON" if _winner == "win" else "DERROTA NEON" if _winner == "loss" else "SAIDA DA LIGA"
	for child in _result_details.get_children():
		child.queue_free()
	_result_details.add_child(_make_result_line("Tempo", "%ss" % int(summary.get("seconds", 0))))
	if not _finish_reason.is_empty():
		_result_details.add_child(_make_result_line("Decisao", _finish_reason.capitalize()))
	_result_details.add_child(_make_result_line("Voce", "%s aneis" % int(_player.get("rings_destroyed", 0))))
	_result_details.add_child(_make_result_line("Rival", "%s aneis" % int(_rival.get("rings_destroyed", 0))))
	_result_details.add_child(_make_result_line("Moedas", "+%s" % int(_result_reward.get("coins", 0))))
	_result_details.add_child(_make_result_line("XP", "+%s" % int(_result_reward.get("xp", 0))))
	if int(_result_reward.get("diamonds", 0)) > 0:
		_result_details.add_child(_make_result_line("Diamantes", "+%s" % int(_result_reward.get("diamonds", 0))))
	if _battle_kind == "boss":
		var reward: Dictionary = _result_reward.get("reward", {})
		_result_details.add_child(_make_result_line("Boss", String(_opponent.get("name", "Boss"))))
		_result_details.add_child(_make_result_line("Recompensa", _boss_reward_label(reward)))
	else:
		_result_details.add_child(_make_result_line("Trofeus", "%+d" % int(_result_reward.get("trophy_delta", 0))))
		if not String(_result_reward.get("promotion_skin", "")).is_empty():
			_result_details.add_child(_make_label("Skin desbloqueada: Campeao Neon Inicial", 13, "#ffd700", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	if _result_double_button:
		_result_double_button.visible = _winner != "quit"
		_result_double_button.disabled = _result_doubled
	_result_overlay.visible = true
	queue_redraw()


func _double_result_reward() -> void:
	if _result_doubled or _winner == "quit":
		return
	GameState.show_mock_rewarded_ad(func(ok: bool) -> void:
		if not ok:
			return
		_result_doubled = true
		var coins := int(_result_reward.get("coins", 0))
		var xp := int(_result_reward.get("xp", 0))
		var diamonds := int(_result_reward.get("diamonds", 0))
		if coins > 0:
			GameState.add_coins(coins)
		if xp > 0:
			GameState.add_profile_xp(xp)
		if diamonds > 0:
			GameState.add_diamonds(diamonds)
		_result_reward["coins"] = coins * 2
		_result_reward["xp"] = xp * 2
		_result_reward["diamonds"] = diamonds * 2
		if _result_double_button:
			_result_double_button.disabled = true
			_result_double_button.text = "RECOMPENSA DOBRADA"
		_show_result({ "seconds": floori(_elapsed) })
	)


func _draw_arena(state: Dictionary) -> void:
	var center: Vector2 = state.get("center", Vector2.ZERO)
	var arena_radius := float(state.get("arena_radius", 100.0))
	var is_player := String(state.get("id", "")) == "player"
	draw_circle(center, arena_radius + 7.0, Color("#12052a3a"))
	draw_arc(center, arena_radius + 1.0, 0.0, TWO_PI, 116, Color("#00f0ff38" if is_player else "#ff4fd838"), 2.0, true)
	var skin_color := Color(String(state.get("skin_color", "#00f0ff")))
	var trail: Array = state.get("trail", [])
	for i in range(trail.size()):
		var progress := float(i + 1) / float(max(1, trail.size()))
		var alpha := 0.04 + progress * 0.14
		var trail_radius := BALL_RADIUS * (0.58 + progress * 0.64)
		draw_circle(Vector2(trail[i]), trail_radius, Color(skin_color, alpha))
	for ring in Array(state.get("rings", [])):
		if String(ring.get("status", "")) != "active":
			continue
		var color := Color(String(ring.get("effect_color", ring.get("color", "#00f0ff"))) if not String(ring.get("effect_color", "")).is_empty() else String(ring.get("color", "#00f0ff")))
		var spawn_alpha := clampf(float(Time.get_ticks_msec() - int(ring.get("spawned_at", 0))) / 360.0, 0.35, 1.0)
		color.a *= spawn_alpha
		var radius := float(ring.get("radius", 0.0))
		var thickness := float(ring.get("thickness", 5.0))
		if String(ring.get("type", "normal")) == "solid":
			draw_arc(center, radius, 0.0, TWO_PI, 112, Color(color, 0.20), thickness + 6.0, true)
			draw_arc(center, radius, 0.0, TWO_PI, 112, color, thickness, true)
		else:
			var gap_center := _normalize_angle(float(ring.get("gap_start", 0.0)) + float(ring.get("rotation", 0.0)))
			var half_gap := float(ring.get("gap_size", 0.0)) / 2.0
			draw_arc(center, radius, gap_center + half_gap, gap_center - half_gap + TWO_PI, 108, Color(color, 0.20), thickness + 6.0, true)
			draw_arc(center, radius, gap_center + half_gap, gap_center - half_gap + TWO_PI, 108, color, thickness, true)
	var ball: Vector2 = state.get("ball", center)
	_draw_skin_ball(state, ball)
	for burst in Array(state.get("bursts", [])):
		var max_life: float = max(0.001, float(burst.get("max_life", 0.34)))
		var life: float = clampf(float(burst.get("life", 0.0)) / max_life, 0.0, 1.0)
		var burst_color: Color = Color(String(burst.get("color", "#00f0ff")))
		var burst_radius: float = float(burst.get("radius", 26.0)) * (1.0 + (1.0 - life) * 0.65)
		var position: Vector2 = burst.get("position", ball)
		draw_arc(position, burst_radius, 0.0, TWO_PI, 44, Color(burst_color, 0.34 * life), 2.2, true)
		draw_circle(position, max(3.0, burst_radius * 0.12), Color("#ffffff", 0.16 * life))
	var label_pos := center + Vector2(-arena_radius + 8.0, -arena_radius + 17.0)
	draw_string(_bold_font, label_pos, String(state.get("label", "")).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, arena_radius * 2.0 - 16.0, 12, Color("#ffffff"))
	var info := "Lv.%s  %s aneis  %s moedas" % [int(state.get("level", 1)), int(state.get("rings_destroyed", 0)), int(state.get("coins", 0))]
	draw_string(_regular_font, center + Vector2(-arena_radius + 8.0, arena_radius - 9.0), info, HORIZONTAL_ALIGNMENT_LEFT, arena_radius * 2.0 - 16.0, 11, Color("#ffffffaa"))


func _draw_skin_ball(state: Dictionary, ball: Vector2) -> void:
	var primary := Color(String(state.get("skin_color", "#00f0ff")))
	var secondary := Color(String(state.get("skin_secondary", "#ffffff")))
	var rarity := String(state.get("skin_rarity", "common"))
	var ring_scale: float = float({
		"common": 1.0,
		"rare": 1.08,
		"epic": 1.16,
		"legendary": 1.25,
		"mythic": 1.32,
		"ultimate": 1.42,
	}.get(rarity, 1.0))
	draw_circle(ball, BALL_RADIUS + 10.0 * float(ring_scale), Color(primary, 0.15))
	draw_circle(ball, BALL_RADIUS + 4.0, Color("#ffffff24"))
	draw_circle(ball, BALL_RADIUS, primary)
	draw_circle(ball + Vector2(BALL_RADIUS * 0.28, -BALL_RADIUS * 0.28), BALL_RADIUS * 0.46, secondary)
	draw_arc(ball, BALL_RADIUS + 2.2, -0.35, PI * 1.45, 34, Color(secondary, 0.9), 2.0, true)
	if rarity in ["epic", "legendary", "mythic", "ultimate"]:
		draw_arc(ball, BALL_RADIUS + 5.0, PI * 0.12, PI * 1.28, 36, Color(secondary, 0.42), 1.5, true)
	if rarity in ["legendary", "mythic", "ultimate"]:
		var crown_y := ball.y - BALL_RADIUS * 0.86
		draw_line(Vector2(ball.x - 5.0, crown_y + 2.0), Vector2(ball.x - 2.0, crown_y - 4.0), secondary, 1.8)
		draw_line(Vector2(ball.x - 2.0, crown_y - 4.0), Vector2(ball.x + 2.0, crown_y + 2.0), secondary, 1.8)
		draw_line(Vector2(ball.x + 2.0, crown_y + 2.0), Vector2(ball.x + 5.0, crown_y - 4.0), secondary, 1.8)
	if rarity == "ultimate":
		draw_circle(ball, BALL_RADIUS * 0.22, Color("#ffffff", 0.92))


func _build_background() -> void:
	var background := TextureRect.new()
	_fill(background)
	background.show_behind_parent = true
	background.z_index = -100
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color("#050816"), Color("#1a0a2e"), Color("#16003b")])
	gradient.offsets = PackedFloat32Array([0.0, 0.48, 1.0])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 16
	texture.height = 1024
	texture.fill = GradientTexture2D.FILL_LINEAR
	texture.fill_from = Vector2.ZERO
	texture.fill_to = Vector2.DOWN
	background.texture = texture
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)


func _build_hud() -> void:
	_hud_layer = Control.new()
	_fill(_hud_layer)
	_hud_layer.z_index = 20
	add_child(_hud_layer)

	var hud := VBoxContainer.new()
	hud.anchor_left = 0.0
	hud.anchor_top = 0.0
	hud.anchor_right = 1.0
	hud.offset_left = 18.0
	hud.offset_top = 38.0
	hud.offset_right = -18.0
	hud.add_theme_constant_override("separation", 7)
	_hud_layer.add_child(hud)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	hud.add_child(top)
	var pause := _make_button("PAUSAR", 96, 40)
	pause.pressed.connect(_open_pause)
	top.add_child(pause)
	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title_box)
	_status_label = _make_label("LIGA NEON", 24, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_RIGHT)
	title_box.add_child(_status_label)
	_meta_label = _make_label("", 11, "#ffffff99", _bold_font, HORIZONTAL_ALIGNMENT_RIGHT)
	title_box.add_child(_meta_label)

	var resources := HBoxContainer.new()
	resources.add_theme_constant_override("separation", 6)
	hud.add_child(resources)
	resources.add_child(_make_resource_badge("coin", "0", "coins"))
	resources.add_child(_make_resource_badge("gem", "0", "gems"))
	resources.add_child(_make_resource_badge("xp", "0", "xp_total"))
	resources.add_child(_make_resource_badge("key", str(GameState.data.get("keys", 0)), "keys"))

	_hud_xp_label = _make_label("", 12, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	hud.add_child(_hud_xp_label)
	_hud_xp_bar = _make_progress_bar("#00f0ff")
	hud.add_child(_hud_xp_bar)

	_rival_label = _make_label("", 12, "#ff4fd8", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	_rival_label.anchor_left = 0.0
	_rival_label.anchor_right = 1.0
	_rival_label.offset_top = 76.0
	_rival_label.visible = false
	_hud_layer.add_child(_rival_label)
	_player_label = _make_label("", 12, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	_player_label.anchor_left = 0.0
	_player_label.anchor_right = 1.0
	_player_label.anchor_bottom = 1.0
	_player_label.offset_bottom = -78.0
	_player_label.visible = false
	_hud_layer.add_child(_player_label)

	var bottom := HBoxContainer.new()
	bottom.anchor_left = 0.0
	bottom.anchor_top = 1.0
	bottom.anchor_right = 1.0
	bottom.anchor_bottom = 1.0
	bottom.offset_left = 12.0
	bottom.offset_top = -78.0
	bottom.offset_right = -12.0
	bottom.offset_bottom = -14.0
	bottom.add_theme_constant_override("separation", 8)
	_hud_layer.add_child(bottom)
	_run_atk_button = _make_button("", 0, 58)
	_run_atk_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(_run_atk_button, _make_style("#06162add", 12, "#00f0ffaa", 2, "#00f0ff55", 8))
	_set_button_icon(_run_atk_button, "damage")
	_run_atk_button.pressed.connect(_buy_player_run_upgrade.bind("atk"))
	bottom.add_child(_run_atk_button)
	_run_gold_button = _make_button("", 0, 58)
	_run_gold_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(_run_gold_button, _make_style("#06162add", 12, "#00f0ffaa", 2, "#00f0ff55", 8))
	_set_button_icon(_run_gold_button, "coin")
	_run_gold_button.pressed.connect(_buy_player_run_upgrade.bind("gold"))
	bottom.add_child(_run_gold_button)


func _build_control_overlay() -> void:
	_control_overlay = HBoxContainer.new()
	_control_overlay.anchor_left = 0.0
	_control_overlay.anchor_top = 1.0
	_control_overlay.anchor_right = 1.0
	_control_overlay.anchor_bottom = 1.0
	_control_overlay.offset_left = 18.0
	_control_overlay.offset_top = -150.0
	_control_overlay.offset_right = -18.0
	_control_overlay.offset_bottom = -92.0
	_control_overlay.add_theme_constant_override("separation", 10)
	_control_overlay.z_index = 25
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


func _build_pause_overlay() -> void:
	_pause_overlay = _make_modal()
	var card := _make_modal_content(_pause_overlay, "PAUSA", Vector2(320, 250))
	card.add_child(_make_modal_button("CONTINUAR", _close_pause))
	card.add_child(_make_modal_button("REINICIAR DUELO", _prepare_match))
	card.add_child(_make_modal_button("SAIR", _quit_match))
	add_child(_pause_overlay)


func _build_level_up_overlay() -> void:
	_level_up_overlay = _make_modal()
	var card := _make_modal_content(_level_up_overlay, "LEVEL UP", Vector2(326, 438))
	card.add_theme_constant_override("separation", 8)
	card.add_child(_make_label("Escolha uma melhoria para sua arena.", 13, "#ffffffcc", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	_level_up_cards = VBoxContainer.new()
	_level_up_cards.add_theme_constant_override("separation", 6)
	card.add_child(_level_up_cards)
	_level_up_actions = VBoxContainer.new()
	_level_up_actions.add_theme_constant_override("separation", 5)
	card.add_child(_level_up_actions)
	add_child(_level_up_overlay)


func _build_result_overlay() -> void:
	_result_overlay = _make_modal()
	var card := _make_modal_content(_result_overlay, "RESULTADO", Vector2(334, 420))
	_result_title = _make_label("", 24, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
	card.add_child(_result_title)
	_result_details = VBoxContainer.new()
	_result_details.add_theme_constant_override("separation", 8)
	card.add_child(_result_details)
	_result_double_button = _make_modal_button("DOBRAR RECOMPENSA - AD", _double_result_reward)
	card.add_child(_result_double_button)
	_result_retry_button = _make_modal_button("JOGAR NOVAMENTE", _retry_or_return)
	card.add_child(_result_retry_button)
	card.add_child(_make_modal_button("VOLTAR", _go_to_mode_menu))
	card.add_child(_make_modal_button("MENU", _go_to_menu))
	add_child(_result_overlay)


func _build_revive_overlay() -> void:
	_revive_overlay = _make_modal()
	var card := _make_modal_content(_revive_overlay, "REVIVER", Vector2(326, 260))
	card.add_child(_make_label("Sua bolinha foi presa. Assista um anuncio mockado para continuar esta luta.", 13, "#ffffffcc", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	card.add_child(_make_modal_button("REVIVER COM ANUNCIO", _revive_with_ad))
	card.add_child(_make_modal_button("ACEITAR DERROTA", _accept_loss))
	add_child(_revive_overlay)


func _make_result_line(label: String, value: String) -> Label:
	return _make_label("%s: %s" % [label, value], 14, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)


func _boss_reward_label(reward: Dictionary) -> String:
	var amount := int(reward.get("amount", 1))
	match String(reward.get("type", "")):
		"coins":
			return "+%s moedas" % amount
		"diamonds", "gems":
			return "+%s diamantes" % amount
		"keys":
			return "+%s chaves" % amount
		"chest":
			return "+%s baú %s" % [amount, String(reward.get("chest_type", "common"))]
		"skin":
			return "Skin %s" % String(reward.get("skin_id", ""))
	return "Recompensa"


func _open_pause() -> void:
	if _finished:
		return
	_paused = true
	_battle_active = false
	_play_sfx("click")
	_pause_overlay.visible = true


func _close_pause() -> void:
	_paused = false
	_battle_active = true
	_pause_overlay.visible = false
	_play_sfx("click")


func _quit_match() -> void:
	if not _finished and not _player.is_empty():
		_finish_match("quit")
	else:
		_go_to_league()


func _go_to_league() -> void:
	get_tree().change_scene_to_file(LEAGUE_SCENE)


func _go_to_mode_menu() -> void:
	get_tree().change_scene_to_file(BOSS_SCENE if _battle_kind == "boss" else LEAGUE_SCENE)


func _retry_or_return() -> void:
	if _battle_kind == "boss":
		_go_to_mode_menu()
	else:
		_prepare_match()


func _go_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


func _hide_overlays() -> void:
	if _pause_overlay:
		_pause_overlay.visible = false
	if _level_up_overlay:
		_level_up_overlay.visible = false
	if _result_overlay:
		_result_overlay.visible = false
	if _revive_overlay:
		_revive_overlay.visible = false


func _set_control_left(pressed: bool) -> void:
	_control_left_down = pressed
	_refresh_control_input()


func _set_control_right(pressed: bool) -> void:
	_control_right_down = pressed
	_refresh_control_input()


func _refresh_control_input() -> void:
	_control_input = 0.0
	if _control_left_down:
		_control_input -= 1.0
	if _control_right_down:
		_control_input += 1.0


func _update_status() -> void:
	if _player.is_empty() or _rival.is_empty():
		return
	_player_label.text = "VOCE - Lv.%s - %s aneis - %s moedas" % [int(_player.get("level", 1)), int(_player.get("rings_destroyed", 0)), int(_player.get("coins", 0))]
	_rival_label.text = "%s - Lv.%s - %s aneis" % [String(_rival.get("label", "Rival")).to_upper(), int(_rival.get("level", 1)), int(_rival.get("rings_destroyed", 0))]
	if _meta_label:
		var remaining: int = max(0, ceili(MATCH_LIMIT_SECONDS - _elapsed))
		_meta_label.text = "TEMPO %s   VOCE %s x %s RIVAL" % [_format_time(remaining), int(_player.get("rings_destroyed", 0)), int(_rival.get("rings_destroyed", 0))]
	_set_resource_value("coins", int(_player.get("coins", 0)))
	_set_resource_value("gems", int(_player.get("diamonds", 0)))
	_set_resource_value("xp_total", int(_player.get("total_xp", 0)))
	_set_resource_value("keys", int(GameState.data.get("keys", 0)))
	if _hud_xp_label != null and _hud_xp_bar != null:
		var needed := _arena_xp_needed(int(_player.get("level", 1)))
		_hud_xp_label.text = "LV.%s   XP %s/%s   GOLD Lv.%s   ATK Lv.%s" % [int(_player.get("level", 1)), int(_player.get("xp", 0)), needed, int(_player.get("gold", 0)), int(_player.get("atk", 0))]
		_hud_xp_bar.max_value = needed
		_hud_xp_bar.value = int(_player.get("xp", 0))
	_update_run_upgrade_buttons()


func _update_run_upgrade_buttons() -> void:
	if not _run_atk_button or _player.is_empty():
		return
	var atk_cost := _get_run_upgrade_cost(_player, "atk")
	var gold_cost := _get_run_upgrade_cost(_player, "gold")
	_run_atk_button.text = "ATK Lv.%s\n%s MOEDAS" % [int(_player.get("atk", 0)), atk_cost]
	_run_gold_button.text = "GOLD Lv.%s\n%s MOEDAS" % [int(_player.get("gold", 0)), gold_cost]
	_run_atk_button.disabled = int(_player.get("coins", 0)) < atk_cost or _finished
	_run_gold_button.disabled = int(_player.get("coins", 0)) < gold_cost or _finished


func _update_control_overlay() -> void:
	if not _control_overlay:
		return
	var should_show := _battle_active and not _finished and not _paused and not _player.is_empty() and bool(_player.get("control", false))
	_control_overlay.visible = should_show
	if not should_show:
		_control_left_down = false
		_control_right_down = false
		_control_input = 0.0
	if _control_indicator:
		_control_indicator.text = "CONTROLE %s%%" % roundi(float(_player.get("control_strength", 0.0)) * 100.0)


func _format_time(seconds: int) -> String:
	var safe_seconds: int = maxi(0, seconds)
	return "%02d:%02d" % [floori(float(safe_seconds) / 60.0), safe_seconds % 60]


func _skin_texture(id: String) -> Texture2D:
	var path := "res://assets/skins/%s.png" % id
	if ResourceLoader.exists(path):
		return load(path)
	return load("res://assets/skins/neon_blue.png")


func _play_sfx(id: String) -> void:
	if has_node("/root/AudioManager") and SOUND_PATHS.has(id):
		AudioManager.play_sfx(String(SOUND_PATHS[id]))


func _make_resource_badge(icon_key: String, value: String, label_key: String) -> PanelContainer:
	var badge := PanelContainer.new()
	badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	badge.custom_minimum_size = Vector2(0, 34)
	badge.add_theme_stylebox_override("panel", _make_style("#ffffff11", 10, "#ffffff22", 1, "#00f0ff33", 5))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 7)
	margin.add_theme_constant_override("margin_right", 7)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	badge.add_child(margin)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 5)
	margin.add_child(row)
	row.add_child(_make_icon_texture(icon_key, 18))
	var label := _make_label(value, 12, "#ffffff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER)
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


func _make_progress_bar(fill_color: String) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 12)
	bar.show_percentage = false
	bar.max_value = 100
	bar.value = 0
	bar.add_theme_stylebox_override("background", _make_style("#ffffff11", 7, "#ffffff22", 1))
	bar.add_theme_stylebox_override("fill", _make_style(fill_color, 7, "#ffffff22", 0, fill_color, 6))
	return bar


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


func _set_button_icon(button: Button, icon_key: String) -> void:
	var path := String(ICON_PATHS.get(icon_key, ICON_PATHS["upgrade"]))
	if ResourceLoader.exists(path):
		button.icon = load(path)
		button.expand_icon = true


func _upgrade_icon_key(id: String) -> String:
	match id:
		"damage":
			return "damage"
		"speed":
			return "speed"
		"critical", "criticalOverload":
			return "crit"
		"coinBoost", "magnetCoins":
			return "coin"
		"xpBoost":
			return "xp"
		"perfectChance", "diamondInstinct":
			return "perfect"
		"burn":
			return "burn"
		"frost", "slowField", "timeFreeze", "chronoBreak":
			return "freeze"
		"ringRepulse":
			return "repulse"
		"shockwave", "chainLightning":
			return "shock"
		"bomb", "laser", "laserCut", "chainBreak", "multihit", "voidPulse":
			return "area"
		_:
			return "upgrade"


func _normalize_angle(angle: float) -> float:
	return fposmod(angle, TWO_PI)


func _make_modal() -> PanelContainer:
	var overlay := PanelContainer.new()
	_fill(overlay)
	overlay.z_index = 40
	overlay.visible = false
	overlay.add_theme_stylebox_override("panel", _make_style("#050014cc", 0))
	return overlay


func _make_modal_content(overlay: Control, title: String, panel_size: Vector2) -> VBoxContainer:
	var center := CenterContainer.new()
	_fill(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = panel_size
	panel.add_theme_stylebox_override("panel", _make_style("#16003bdd", 18, "#00f0ff66", 2, "#00f0ff55", 18))
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)
	content.add_child(_make_label(title, 22, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_CENTER))
	overlay.add_child(center)
	return content


func _make_modal_button(text: String, callback: Callable) -> Button:
	var button := _make_button(text, 0, 46)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	return button


func _make_button(text: String, width: int, height: int) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(width, height)
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color("#ffffff"))
	button.add_theme_color_override("font_disabled_color", Color("#ffffff66"))
	_apply_button_style(button, _make_style("#06162add", 13, "#00f0ffaa", 2, "#00f0ff66", 8))
	return button


func _make_label(text: String, font_size: int, color: String, font: Font, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(color))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


func _make_style(bg: String, radius: int, border := "#00000000", border_width := 0, shadow := "#00000000", shadow_size := 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(bg)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_color = Color(border)
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.shadow_color = Color(shadow)
	style.shadow_size = shadow_size
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

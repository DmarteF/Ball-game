extends Control

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const NeonBackButtonScript := preload("res://scripts/NeonBackButton.gd")

const TWO_PI := PI * 2.0
const TARGET_ACTIVE_RINGS := 8
const MIN_RING_SPACING := 7.0
const BALL_RADIUS := 7.0
const CONTROL_SKIN_IDS := [
	"robot",
	"alien_rare",
	"ninja_rare",
	"satellite_rare",
	"blue_vortex",
	"neon_spiral",
	"ripple_eye",
	"celestial_core",
	"chrono_loop_mythic",
]
const CONTROL_STRENGTH_BY_RARITY := {
	"common": 0.13,
	"rare": 0.24,
	"epic": 0.34,
	"legendary": 0.48,
	"mythic": 0.62,
	"ultimate": 0.80,
}

var _regular_font: Font
var _bold_font: Font
var _opponent: Dictionary = {}
var _player := {}
var _rival := {}
var _battle_active := false
var _battle_finished := false
var _elapsed := 0.0
var _result_text := ""
var _result_detail := ""
var _upgrade_overlay: Control
var _upgrade_cards: VBoxContainer
var _root: VBoxContainer
var _status_label: Label
var _season_label: Label
var _start_button: Button
var _quit_button: Button
var _control_overlay: HBoxContainer
var _control_input := 0.0
var _control_left_down := false
var _control_right_down := false


func _ready() -> void:
	_regular_font = _make_system_font(400)
	_bold_font = _make_system_font(700)
	if has_node("/root/AudioManager"):
		AudioManager.play_context("gameplay")
	_build_background()
	_build_ui()
	_build_control_overlay()
	_build_upgrade_overlay()
	_prepare_match()


func _process(delta: float) -> void:
	if not _battle_active or _battle_finished:
		_update_control_overlay()
		return
	_elapsed += delta
	_update_control_overlay()
	_tick_arena(_player, delta, false)
	_tick_arena(_rival, delta, true)
	if bool(_player.get("level_pending", false)):
		_open_player_upgrade()
	if bool(_rival.get("level_pending", false)):
		_apply_ai_upgrade(_rival)
	if bool(_player.get("crushed", false)):
		_finish_match("loss")
	elif bool(_rival.get("crushed", false)):
		_finish_match("win")
	_update_status()
	queue_redraw()


func _draw() -> void:
	_draw_arena(_rival)
	_draw_arena(_player)
	if _battle_finished:
		var view_size := _view_size()
		var rect := Rect2(Vector2(28, view_size.y * 0.36), Vector2(view_size.x - 56, 180))
		draw_rect(rect, Color("#12052add"), true)
		draw_rect(rect, Color("#00f0ff88"), false, 2.0)
		draw_string(_bold_font, rect.position + Vector2(rect.size.x / 2.0 - 75, 48), _result_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#ffffff"))
		draw_string(_regular_font, rect.position + Vector2(22, 92), _result_detail, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 44, 14, Color("#ffffffcc"))


func _prepare_match() -> void:
	var league: Dictionary = GameState.data.get("league", {})
	var trophies := int(league.get("trophies", 0))
	_opponent = MainPortData.opponent_for(trophies)
	_elapsed = 0.0
	_battle_active = false
	_battle_finished = false
	_result_text = ""
	_result_detail = ""
	var rank := MainPortData.rank_for_trophies(trophies)
	_player = _make_arena("player", "PLAYER", String(GameState.data.get("equipped_skin", "neon_blue")), 0.58, 0.38, 1.0)
	_rival = _make_arena("rival", String(_opponent.get("name", "Rival")), String(Dictionary(_opponent.get("skin", {})).get("id", "neon_blue")), 0.20, 0.30, float(_opponent.get("quality", 0.45)))
	_status_label.text = "LIGA %s  •  %s troféus" % [String(rank.get("name", "Bronze")).to_upper(), trophies]
	_season_label.text = "Temporada %s  •  Oponente: %s" % [TimeManager.get_month_key(), String(_opponent.get("name", "Rival"))]
	_start_button.text = "BATALHAR"
	_start_button.visible = true
	_quit_button.visible = false
	queue_redraw()


func _start_match() -> void:
	_battle_active = true
	_battle_finished = false
	_start_button.visible = false
	_quit_button.visible = true
	_update_status()


func _quit_match() -> void:
	if _battle_active and not _battle_finished:
		_finish_match("quit")
	else:
		get_tree().change_scene_to_file(MENU_SCENE)


func _finish_match(result: String) -> void:
	_battle_active = false
	_battle_finished = true
	_quit_button.visible = false
	_start_button.visible = true
	_start_button.text = "NOVA BATALHA"
	var summary := {
		"opponent_id": String(_opponent.get("id", "")),
		"seconds": floori(_elapsed),
		"rings": int(_player.get("rings_destroyed", 0)),
		"coins": int(_player.get("coins", 0)),
		"xp": int(_player.get("xp", 0)),
	}
	var reward := GameState.record_neon_league_match(result, summary)
	if result == "win":
		_result_text = "VITÓRIA NEON"
	elif result == "loss":
		_result_text = "DERROTA"
	else:
		_result_text = "SAÍDA"
	_result_detail = "%ss • %s anéis • +%s moedas • +%s XP • %+d troféus" % [summary["seconds"], summary["rings"], int(reward.get("coins", 0)), int(reward.get("xp", 0)), int(reward.get("trophy_delta", 0))]
	_update_status()
	queue_redraw()


func _make_arena(id: String, label: String, skin_id: String, top_ratio: float, height_ratio: float, quality: float) -> Dictionary:
	var view_size := _view_size()
	var arena_size: float = min(view_size.x - 48.0, view_size.y * height_ratio)
	var center := Vector2(view_size.x / 2.0, view_size.y * top_ratio + arena_size / 2.0)
	var radius := arena_size / 2.0 - 8.0
	var speed := 2.05 + quality * 0.7
	var state := {
		"id": id,
		"label": label,
		"skin": skin_id,
		"center": center,
		"arena_radius": radius,
		"ball": center + Vector2(10, -14),
		"velocity": Vector2(speed, -speed * 0.72),
		"rings": [],
		"coins": 0,
		"xp": 0,
		"level": 1,
		"atk": 0,
		"gold": 0,
		"run_upgrades": {},
		"quality": quality,
		"control_strength": _skin_control_strength(skin_id),
		"rings_destroyed": 0,
		"spawned": 0,
		"crushed": false,
		"level_pending": false,
	}
	for i in range(TARGET_ACTIVE_RINGS):
		_add_ring(state)
	return state


func _view_size() -> Vector2:
	if size.x > 10.0 and size.y > 10.0:
		return size
	return get_viewport_rect().size


func _tick_arena(state: Dictionary, delta: float, is_ai: bool) -> void:
	if bool(state.get("crushed", false)):
		return
	var ball: Vector2 = state["ball"]
	var velocity: Vector2 = state["velocity"]
	var center: Vector2 = state["center"]
	var arena_radius := float(state["arena_radius"])
	velocity = _apply_league_control(state, velocity, is_ai, delta)
	ball += velocity * delta * 60.0
	var offset := ball - center
	if offset.length() > arena_radius - BALL_RADIUS:
		var normal := offset.normalized()
		ball = center + normal * (arena_radius - BALL_RADIUS)
		velocity = velocity.bounce(normal).rotated(randf_range(-0.12, 0.12))
	for i in range(Array(state["rings"]).size()):
		var ring: Dictionary = state["rings"][i]
		if String(ring.get("status", "")) != "active":
			continue
		ring["rotation"] = fposmod(float(ring["rotation"]) + float(ring["rotation_speed"]) * delta * 60.0, TWO_PI)
		ring["radius"] = float(ring["radius"]) - float(ring["closing_speed"]) * delta * 60.0
		state["rings"][i] = ring
	var prev_destroyed := int(state.get("rings_destroyed", 0))
	_check_arena_collisions(state)
	velocity = Vector2(state.get("velocity", velocity))
	while _arena_active_count(state) < TARGET_ACTIVE_RINGS:
		_add_ring(state)
	if int(state.get("rings_destroyed", 0)) > prev_destroyed:
		state["coins"] = int(state.get("coins", 0)) + 7 + int(state.get("gold", 0)) * 2
		state["xp"] = int(state.get("xp", 0)) + 10
		if int(state["xp"]) >= _arena_xp_needed(int(state["level"])):
			state["xp"] = int(state["xp"]) - _arena_xp_needed(int(state["level"]))
			state["level"] = int(state["level"]) + 1
			state["level_pending"] = true
	state["ball"] = ball
	state["velocity"] = velocity.normalized() * clampf(velocity.length(), 2.0, 4.8)
	state["crushed"] = _is_arena_crushed(state)


func _apply_league_control(state: Dictionary, velocity: Vector2, is_ai: bool, delta: float) -> Vector2:
	var strength := float(state.get("control_strength", 0.0))
	if strength <= 0.0 or velocity.length() <= 0.01:
		return velocity
	var control := 0.0
	if is_ai:
		var ball: Vector2 = state["ball"]
		var center: Vector2 = state["center"]
		control = sign(center.x - ball.x) * clampf(strength * 0.34, 0.05, 0.22)
	else:
		control = _control_input
	if abs(control) <= 0.01:
		return velocity
	var speed := velocity.length()
	var desired := (velocity.normalized() + Vector2(control * (0.42 + strength * 0.72), 0.0)).normalized()
	var blend := clampf((0.75 + strength * 1.2) * delta, 0.01, 0.12)
	return velocity.normalized().lerp(desired, blend).normalized() * speed


func _check_arena_collisions(state: Dictionary) -> void:
	var ball: Vector2 = state["ball"]
	var center: Vector2 = state["center"]
	var dist := (ball - center).length()
	for i in range(Array(state["rings"]).size()):
		var ring: Dictionary = state["rings"][i]
		if String(ring.get("status", "")) != "active":
			continue
		if abs(dist - float(ring["radius"])) > BALL_RADIUS + float(ring["thickness"]):
			continue
		var angle := fposmod((ball - center).angle(), TWO_PI)
		var in_gap := false
		if String(ring.get("type", "normal")) != "solid":
			var gap_center := fposmod(float(ring["gap_start"]) + float(ring["rotation"]), TWO_PI)
			var diff: float = abs(angle - gap_center)
			diff = min(diff, TWO_PI - diff)
			in_gap = diff <= float(ring["gap_size"]) / 2.0
		if in_gap:
			ring["status"] = "cleared"
			state["rings_destroyed"] = int(state.get("rings_destroyed", 0)) + 1
			state["rings"][i] = ring
			return
		var damage := 5.0 + int(state.get("atk", 0)) * 1.8
		var upgrades: Dictionary = state.get("run_upgrades", {})
		damage *= 1.0 + int(upgrades.get("damage", 0)) * 0.15 + int(upgrades.get("rivalCrusher", 0)) * 0.24
		ring["hp"] = max(0, int(ring["hp"]) - floori(damage))
		if int(ring["hp"]) <= 0:
			ring["status"] = "broken"
			state["rings_destroyed"] = int(state.get("rings_destroyed", 0)) + 1
		state["rings"][i] = ring
		var normal := (ball - center).normalized()
		state["velocity"] = Vector2(state["velocity"]).bounce(normal).rotated(randf_range(-0.14, 0.14))
		return


func _is_arena_crushed(state: Dictionary) -> bool:
	var ball: Vector2 = state["ball"]
	var center: Vector2 = state["center"]
	var dist := (ball - center).length()
	for ring in Array(state["rings"]):
		if String(ring.get("status", "")) == "active" and int(ring.get("hp", 0)) > 0:
			if float(ring.get("radius", 0.0)) <= max(8.0, dist - BALL_RADIUS * 0.2):
				return true
	return false


func _add_ring(state: Dictionary) -> void:
	var active := _arena_active_count(state)
	var center: Vector2 = state["center"]
	var ball: Vector2 = state["ball"]
	var arena_radius := float(state["arena_radius"])
	var ball_dist := (ball - center).length()
	var max_radius := arena_radius - 3.0
	var min_radius := clampf(ball_dist + 24.0, 18.0, max_radius - MIN_RING_SPACING)
	var far_radius := clampf(ball_dist + 120.0, min_radius + MIN_RING_SPACING, max_radius)
	if ball_dist > max_radius - 24.0:
		min_radius = max(18.0, ball_dist - 120.0)
		far_radius = max(18.0 + MIN_RING_SPACING, ball_dist - 24.0)
	var radius := clampf(arena_radius - 4.0 - active * MIN_RING_SPACING, min_radius, far_radius)
	for ring in Array(state["rings"]):
		if String(ring.get("status", "")) == "active" and abs(float(ring.get("radius", 0.0)) - radius) < MIN_RING_SPACING:
			var outward := float(ring.get("radius", 0.0)) + MIN_RING_SPACING
			var inward := float(ring.get("radius", 0.0)) - MIN_RING_SPACING
			radius = outward if outward <= far_radius else inward
	radius = clampf(radius, 18.0, max_radius)
	var index := int(state.get("spawned", 0))
	state["spawned"] = index + 1
	var rings: Array = state["rings"]
	rings.append({
		"id": "%s_%s" % [String(state.get("id", "arena")), index],
		"type": "solid" if index % 9 == 8 else "normal",
		"radius": radius,
		"hp": 14 + floori(float(index) * 0.9 + float(state.get("quality", 0.4)) * 12.0),
		"status": "active",
		"thickness": 5.0,
		"rotation": randf() * TWO_PI,
		"rotation_speed": (0.004 + float(state.get("quality", 0.4)) * 0.004) * (1.0 if index % 2 == 0 else -1.0),
		"closing_speed": 0.010 + float(state.get("quality", 0.4)) * 0.010 + _elapsed * 0.00008,
		"gap_start": randf() * TWO_PI,
		"gap_size": 0.0 if index % 9 == 8 else max(PI / 7.0, PI / (3.4 + _elapsed * 0.012)),
		"color": "#ff0055" if index % 9 == 8 else "#00f0ff",
	})
	state["rings"] = rings


func _arena_active_count(state: Dictionary) -> int:
	var count := 0
	for ring in Array(state["rings"]):
		if String(ring.get("status", "")) == "active" and int(ring.get("hp", 0)) > 0:
			count += 1
	return count


func _open_player_upgrade() -> void:
	_battle_active = false
	_player["level_pending"] = false
	for child in _upgrade_cards.get_children():
		child.queue_free()
	var choices := _league_upgrade_choices(_player)
	for upgrade in choices:
		var button := _make_button("%s\n%s" % [String(upgrade.get("name", "")).to_upper(), String(upgrade.get("description", ""))], 286, 74)
		button.pressed.connect(_select_player_upgrade.bind(String(upgrade.get("id", ""))))
		_upgrade_cards.add_child(button)
	_upgrade_overlay.visible = true


func _select_player_upgrade(id: String) -> void:
	_apply_run_upgrade(_player, id)
	_upgrade_overlay.visible = false
	_battle_active = true


func _apply_ai_upgrade(state: Dictionary) -> void:
	state["level_pending"] = false
	var choices := _league_upgrade_choices(state)
	if choices.is_empty():
		return
	_apply_run_upgrade(state, String(choices[0].get("id", "damage")))


func _league_upgrade_choices(state: Dictionary) -> Array:
	var unlocked: Array = GameState.data.get("unlocked_upgrades", [])
	var available: Array = []
	for upgrade in MainPortData.RUN_UPGRADES:
		var id := String(upgrade.get("id", ""))
		if not unlocked.has(id) and String(state.get("id", "")) == "player":
			continue
		if int(Dictionary(state.get("run_upgrades", {})).get(id, 0)) >= int(upgrade.get("maxLevel", 1)):
			continue
		available.append(upgrade)
	available.shuffle()
	return available.slice(0, min(3, available.size()))


func _apply_run_upgrade(state: Dictionary, id: String) -> void:
	var upgrades: Dictionary = state.get("run_upgrades", {})
	upgrades[id] = int(upgrades.get(id, 0)) + 1
	state["run_upgrades"] = upgrades
	if id == "speed" or id == "ricochet":
		state["velocity"] = Vector2(state["velocity"]) * 1.08
	elif id == "coinBoost":
		state["gold"] = int(state.get("gold", 0)) + 1
	else:
		state["atk"] = int(state.get("atk", 0)) + 1


func _arena_xp_needed(level: int) -> int:
	return floori(28.0 * pow(max(1, level), 1.35))


func _skin_control_strength(skin_id: String) -> float:
	var skin := MainPortData.skin_by_id(skin_id)
	if skin.is_empty():
		return 0.0
	var rarity := String(skin.get("rarity", "common"))
	var id := skin_id.to_lower()
	if rarity != "ultimate" and not CONTROL_SKIN_IDS.has(id):
		return 0.0
	return float(CONTROL_STRENGTH_BY_RARITY.get(rarity, 0.13))


func _draw_arena(state: Dictionary) -> void:
	if state.is_empty():
		return
	var center: Vector2 = state["center"]
	var arena_radius := float(state["arena_radius"])
	draw_circle(center, arena_radius + 8.0, Color("#12052a44"))
	draw_arc(center, arena_radius, 0.0, TWO_PI, 96, Color("#00f0ff55"), 2.0, true)
	for ring in Array(state["rings"]):
		if String(ring.get("status", "")) != "active":
			continue
		var color := Color(String(ring.get("color", "#00f0ff")))
		var radius := float(ring.get("radius", 0.0))
		if String(ring.get("type", "normal")) == "solid":
			draw_arc(center, radius, 0.0, TWO_PI, 128, color, float(ring.get("thickness", 5.0)), true)
		else:
			var gap_center := fposmod(float(ring["gap_start"]) + float(ring["rotation"]), TWO_PI)
			var half_gap := float(ring["gap_size"]) / 2.0
			draw_arc(center, radius, gap_center + half_gap, gap_center - half_gap + TWO_PI, 128, color, float(ring.get("thickness", 5.0)), true)
	var ball: Vector2 = state["ball"]
	var skin_color := Color(String(Dictionary(MainPortData.skin_by_id(String(state.get("skin", "neon_blue")))).get("primary", "#00f0ff")))
	draw_circle(ball, BALL_RADIUS + 8.0, Color(skin_color, 0.18))
	draw_circle(ball, BALL_RADIUS, skin_color)
	draw_string(_bold_font, center + Vector2(-arena_radius, -arena_radius - 12), String(state.get("label", "")), HORIZONTAL_ALIGNMENT_LEFT, arena_radius * 2.0, 13, Color("#ffffff"))
	draw_string(_regular_font, center + Vector2(-arena_radius, arena_radius + 20), "Lv.%s • %s anéis" % [int(state.get("level", 1)), int(state.get("rings_destroyed", 0))], HORIZONTAL_ALIGNMENT_LEFT, arena_radius * 2.0, 12, Color("#ffffffaa"))


func _update_status() -> void:
	_status_label.text = "Tempo %ss  •  Você %s anéis  •  Rival %s anéis" % [floori(_elapsed), int(_player.get("rings_destroyed", 0)), int(_rival.get("rings_destroyed", 0))]


func _build_background() -> void:
	var background := TextureRect.new()
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color("#03010a"), Color("#16003b"), Color("#050816")])
	gradient.offsets = PackedFloat32Array([0.0, 0.58, 1.0])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 16
	texture.height = 1024
	texture.fill_from = Vector2.ZERO
	texture.fill_to = Vector2.DOWN
	background.texture = texture
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(background)


func _build_ui() -> void:
	_root = VBoxContainer.new()
	_root.anchor_right = 1.0
	_root.anchor_bottom = 1.0
	_root.offset_left = 18
	_root.offset_top = 44
	_root.offset_right = -18
	NeonBackButtonScript.reserve_footer_space(_root)
	_root.add_theme_constant_override("separation", 7)
	add_child(_root)
	NeonBackButtonScript.add_to(self, _quit_match)
	_root.add_child(_make_label("LIGA NEON", 27, "#00f0ff", _bold_font, HORIZONTAL_ALIGNMENT_LEFT))
	_status_label = _make_label("", 13, "#ffffffcc", _bold_font, HORIZONTAL_ALIGNMENT_LEFT)
	_root.add_child(_status_label)
	_season_label = _make_label("", 12, "#ffffff88", _regular_font, HORIZONTAL_ALIGNMENT_LEFT)
	_root.add_child(_season_label)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_root.add_child(spacer)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	_root.add_child(row)
	_start_button = _make_button("BATALHAR", 170, 52)
	_start_button.pressed.connect(_start_match)
	row.add_child(_start_button)
	_quit_button = _make_button("SAIR", 140, 52)
	_quit_button.pressed.connect(_quit_match)
	row.add_child(_quit_button)


func _build_control_overlay() -> void:
	_control_overlay = HBoxContainer.new()
	_control_overlay.anchor_left = 0.0
	_control_overlay.anchor_top = 1.0
	_control_overlay.anchor_right = 1.0
	_control_overlay.anchor_bottom = 1.0
	_control_overlay.offset_left = 20.0
	_control_overlay.offset_top = -148.0
	_control_overlay.offset_right = -20.0
	_control_overlay.offset_bottom = -88.0
	_control_overlay.add_theme_constant_override("separation", 10)
	_control_overlay.visible = false
	add_child(_control_overlay)
	var left := _make_control_button("<")
	left.button_down.connect(_set_control_left.bind(true))
	left.button_up.connect(_set_control_left.bind(false))
	_control_overlay.add_child(left)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_control_overlay.add_child(spacer)
	var right := _make_control_button(">")
	right.button_down.connect(_set_control_right.bind(true))
	right.button_up.connect(_set_control_right.bind(false))
	_control_overlay.add_child(right)


func _make_control_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(72, 56)
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 26)
	button.add_theme_color_override("font_color", Color("#00f0ff"))
	button.add_theme_stylebox_override("normal", _make_style("#06162add", 18, "#00f0ffaa", 2, "#00f0ff66", 10))
	button.add_theme_stylebox_override("pressed", _make_style("#00f0ff", 18, "#ffffff", 2, "#00f0ffaa", 12))
	return button


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


func _update_control_overlay() -> void:
	if not _control_overlay:
		return
	var should_show := _battle_active and not _battle_finished and not _upgrade_overlay.visible and float(_player.get("control_strength", 0.0)) > 0.0
	_control_overlay.visible = should_show
	if not should_show:
		_control_left_down = false
		_control_right_down = false
		_control_input = 0.0


func _build_upgrade_overlay() -> void:
	_upgrade_overlay = Control.new()
	_upgrade_overlay.anchor_right = 1.0
	_upgrade_overlay.anchor_bottom = 1.0
	_upgrade_overlay.visible = false
	add_child(_upgrade_overlay)
	var dim := ColorRect.new()
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.color = Color("#03010acc")
	_upgrade_overlay.add_child(dim)
	var box := PanelContainer.new()
	box.anchor_left = 0.08
	box.anchor_top = 0.30
	box.anchor_right = 0.92
	box.anchor_bottom = 0.70
	box.add_theme_stylebox_override("panel", _make_style("#16003bee", 16, "#00f0ff88", 2))
	_upgrade_overlay.add_child(box)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	box.add_child(margin)
	_upgrade_cards = VBoxContainer.new()
	_upgrade_cards.add_theme_constant_override("separation", 10)
	margin.add_child(_upgrade_cards)


func _make_button(text: String, width: int, height: int) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(width, height)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", _bold_font)
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", Color("#ffffff"))
	button.add_theme_stylebox_override("normal", _make_style("#00aaff", 12, "#00f0ff", 2, "#00f0ff66", 10))
	button.add_theme_stylebox_override("hover", _make_style("#00c6ff", 12, "#ffffff", 2, "#00f0ff88", 12))
	button.add_theme_stylebox_override("pressed", _make_style("#0077bb", 12, "#00f0ff", 2, "#00f0ff66", 8))
	return button


func _make_label(text: String, font_size: int, color: String, font: Font, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(color))
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


func _make_system_font(weight: int) -> Font:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Space Mono", "Arial", "Sans Serif"])
	font.font_weight = weight
	return font

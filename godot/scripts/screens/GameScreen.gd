extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")
const RingLogic = preload("res://scripts/game/RingLogic.gd")
const ArenaViewScript = preload("res://scripts/game/ArenaView.gd")

const BALL_RADIUS = 10.0
const INNER_RADIUS = 35.0
const INITIAL_BALL_SPEED = 2.2
const PHYSICS_STEP = 60.0
const COMBO_WINDOW_MS = 2600.0

var phase_id = 1
var phase_config = {}
var rings = []
var ball_pos = Vector2.ZERO
var velocity = Vector2.ZERO
var center = Vector2.ZERO
var arena_size = 360.0
var outer_radius = 170.0
var previous_distance = 0.0
var running = false
var paused = false
var level_up_open = false
var rewards_saved = false

var run_level = 1
var run_xp = 0
var run_coins = 0
var run_gems = 0
var score = 0
var combo = 0
var best_combo = 0
var last_combo_at = 0.0
var last_hit_at = 0.0
var invincible_until = 0.0
var current_upgrades = {}
var run_shop_upgrades = {"atk": 0, "gold": 0}
var run_rewards = {
	"coins": 0,
	"gems": 0,
	"xp": 0,
	"rings_broken": 0,
	"perfect_escapes": 0,
	"best_combo": 0,
	"criticals": 0,
	"skin_effects": 0,
	"run_upgrades": 0
}
var trail_points = []
var floating_numbers = []

var root_vbox
var arena_view
var wallet_label
var progress_label
var xp_label
var combo_label
var result_label
var pause_button
var level_up_panel
var level_up_list

func setup(payload):
	phase_id = int(payload.get("phase", phase_id))
	if is_node_ready():
		call_deferred("_start_game")

func _ready():
	_build_ui()
	call_deferred("_start_game")

func _process(delta):
	if not running or paused or level_up_open:
		return
	var delta_steps = clamp(delta * PHYSICS_STEP, 0.25, 2.4)
	_update_game(delta_steps)

func _build_ui():
	var bg = ColorRect.new()
	bg.color = Color("#080818")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	root_vbox = VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 10)
	margin.add_child(root_vbox)

	var top_row = HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 8)
	root_vbox.add_child(top_row)

	wallet_label = NeonUI.label("", 14, Color.WHITE)
	wallet_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(wallet_label)

	pause_button = NeonUI.ghost_button("PAUSAR", Color("#00f0ff"), 38)
	pause_button.pressed.connect(_toggle_pause)
	top_row.add_child(pause_button)

	progress_label = NeonUI.label("", 13, Color("#ffffffcc"))
	root_vbox.add_child(progress_label)

	var xp_row = HBoxContainer.new()
	xp_row.add_theme_constant_override("separation", 8)
	root_vbox.add_child(xp_row)
	xp_label = NeonUI.label("", 13, Color("#00f0ff"))
	xp_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	xp_row.add_child(xp_label)
	combo_label = NeonUI.label("", 13, Color("#ffd700"), HORIZONTAL_ALIGNMENT_RIGHT)
	combo_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	xp_row.add_child(combo_label)

	var center_box = CenterContainer.new()
	center_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(center_box)
	arena_view = ArenaViewScript.new()
	arena_view.custom_minimum_size = Vector2(360, 360)
	arena_view.gui_input.connect(_on_arena_input)
	center_box.add_child(arena_view)

	result_label = NeonUI.label("", 14, Color("#00ff88"), HORIZONTAL_ALIGNMENT_CENTER)
	root_vbox.add_child(result_label)

	var controls = HBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)
	root_vbox.add_child(controls)

	var left_button = NeonUI.ghost_button("GIRAR -", Color("#b000ff"), 50)
	left_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_button.pressed.connect(func(): _rotate_velocity(-0.28))
	controls.add_child(left_button)

	var impulse_button = NeonUI.button("IMPULSO", Color("#00f0ff"), 50)
	impulse_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	impulse_button.pressed.connect(_impulse_outward)
	controls.add_child(impulse_button)

	var right_button = NeonUI.ghost_button("GIRAR +", Color("#ff0055"), 50)
	right_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_button.pressed.connect(func(): _rotate_velocity(0.28))
	controls.add_child(right_button)

	var shop_row = HBoxContainer.new()
	shop_row.add_theme_constant_override("separation", 8)
	root_vbox.add_child(shop_row)

	var atk_button = NeonUI.ghost_button("ATK rodada", Color("#ffd700"), 42)
	atk_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	atk_button.pressed.connect(func(): _buy_run_upgrade("atk"))
	shop_row.add_child(atk_button)

	var gold_button = NeonUI.ghost_button("Gold rodada", Color("#ffd700"), 42)
	gold_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gold_button.pressed.connect(func(): _buy_run_upgrade("gold"))
	shop_row.add_child(gold_button)

	var exit_button = NeonUI.ghost_button("SAIR", Color("#ffffff88"), 42)
	exit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exit_button.pressed.connect(_quit_run)
	shop_row.add_child(exit_button)

	_build_level_up_panel()

func _build_level_up_panel():
	level_up_panel = PanelContainer.new()
	level_up_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	level_up_panel.visible = false
	level_up_panel.add_theme_stylebox_override("panel", NeonUI.flat(Color(0, 0, 0, 0.84), Color("#00f0ff"), 1, 0))
	add_child(level_up_panel)
	var outer = CenterContainer.new()
	level_up_panel.add_child(outer)
	var box = VBoxContainer.new()
	box.custom_minimum_size = Vector2(340, 0)
	box.add_theme_constant_override("separation", 10)
	outer.add_child(box)
	box.add_child(NeonUI.label("LEVEL UP", 28, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(NeonUI.label("Escolha um upgrade temporario para esta rodada.", 14, Color("#ffffffcc"), HORIZONTAL_ALIGNMENT_CENTER))
	level_up_list = VBoxContainer.new()
	level_up_list.add_theme_constant_override("separation", 8)
	box.add_child(level_up_list)
	var reroll = NeonUI.ghost_button("REROLL COM ANUNCIO MOCK", Color("#ffd700"), 46)
	reroll.pressed.connect(_reroll_level_up_with_ad)
	box.add_child(reroll)

func _start_game():
	if not is_node_ready():
		return
	phase_config = GameData.get_phase_config(phase_id)
	var viewport_size = get_viewport_rect().size
	arena_size = clamp(min(viewport_size.x - 28.0, viewport_size.y - 280.0), 260.0, 520.0)
	arena_view.custom_minimum_size = Vector2(arena_size, arena_size)
	center = Vector2(arena_size * 0.5, arena_size * 0.5)
	outer_radius = arena_size * 0.5 - 9.0
	var save = SaveSystem.get_save()
	var slow_level = int(save.permanent_upgrades.get("slowRings", 0))
	var difficulty = 1.0 + (phase_id - 1) * 0.13 + max(0, int(save.profile_level) - 1) * 0.012
	var ring_count = min(45, int(floor((phase_config.ring_min + phase_config.ring_max) / 2.0)) + int(floor(int(save.profile_level) / 10.0)))
	var config = {
		"count": ring_count,
		"inner_radius": INNER_RADIUS,
		"outer_radius": outer_radius,
		"base_rotation_speed": min(0.029, (float(phase_config.rotation_speed) + int(save.profile_level) * 0.00014) * 0.9),
		"base_hp": int(round(float(phase_config.base_hp) * difficulty)),
		"base_gap_size": max(PI / 7.2, float(phase_config.gap_size) - int(save.profile_level) * 0.001),
		"base_thickness": 5.0,
		"closing_speed": min(0.118, (float(phase_config.closing_speed) + int(save.profile_level) * 0.00022) * 0.82 * (1.0 - min(0.28, slow_level * 0.018))),
		"colors": ["#00f0ff", "#b000ff", "#ff0055", "#00ff88", "#ffd700", "#ff8800"],
		"min_count": 12,
		"max_count": 80
	}
	rings = RingLogic.create_rings(config, phase_id)
	var speed = INITIAL_BALL_SPEED + min(0.62, (phase_id - 1) * 0.08 + int(save.profile_level) * 0.006)
	var angle = randf() * PI * 2.0
	velocity = Vector2(cos(angle), sin(angle)) * speed
	ball_pos = center
	previous_distance = 0.0
	run_level = 1
	run_xp = 0
	run_coins = 0
	run_gems = 0
	score = 0
	combo = 0
	best_combo = 0
	last_combo_at = 0.0
	last_hit_at = 0.0
	invincible_until = 0.0
	current_upgrades = {}
	run_shop_upgrades = {"atk": 0, "gold": 0}
	run_rewards = {
		"coins": 0,
		"gems": 0,
		"xp": 0,
		"rings_broken": 0,
		"perfect_escapes": 0,
		"best_combo": 0,
		"criticals": 0,
		"skin_effects": 0,
		"run_upgrades": 0
	}
	trail_points.clear()
	floating_numbers.clear()
	result_label.text = ""
	level_up_panel.visible = false
	level_up_open = false
	rewards_saved = false
	paused = false
	running = true
	_update_hud()
	_push_arena_state()

func _update_game(delta_steps):
	var save = SaveSystem.get_save()
	var stats = _final_stats()
	var target_speed = (INITIAL_BALL_SPEED + min(0.62, (phase_id - 1) * 0.08)) * stats.speed_multiplier
	velocity = RingLogic.clamp_ball_speed(velocity, target_speed * 0.78, target_speed * 1.55)

	var prev_dist = ball_pos.distance_to(center)
	ball_pos += velocity * delta_steps
	_constrain_outer_wall()
	var next_dist = ball_pos.distance_to(center)
	var now_ms = Time.get_ticks_msec()

	if combo > 0 and now_ms - last_combo_at > COMBO_WINDOW_MS:
		combo = 0

	rings = RingLogic.update_rings(rings, delta_steps, now_ms)
	var perfect = RingLogic.find_perfect_escape_ring(prev_dist, next_dist, ball_pos, BALL_RADIUS, rings, center)
	if perfect.index >= 0:
		_handle_perfect_escape(perfect.index, stats)

	var collision = RingLogic.find_closest_colliding_ring(ball_pos, BALL_RADIUS, rings, center)
	if collision.ring != null and collision.index >= 0 and collision.is_in_solid_part:
		_handle_ring_hit(collision.index, prev_dist, stats)

	var active_rings = _active_rings()
	if active_rings.is_empty():
		_finish_run(true)
		return
	for ring in active_rings:
		if Time.get_ticks_msec() >= invincible_until and RingLogic.is_ball_crushed_by_ring(ball_pos, BALL_RADIUS, ring, center):
			_finish_run(false)
			return
	previous_distance = next_dist
	_push_trail()
	_cleanup_floating()
	_update_hud()
	_push_arena_state()

func _handle_perfect_escape(index, stats):
	var ring = rings[index].duplicate(true)
	ring.status = "cleared"
	ring.hp = 0
	rings[index] = ring
	var coins = max(2, int(floor(5.0 * stats.gold_multiplier)))
	var xp = int(floor((10.0 + randf() * 8.0) * stats.xp_multiplier))
	_award_coins(coins)
	_award_xp(xp)
	run_rewards.perfect_escapes += 1
	_register_combo("Perfect", Color("#b8f3ff"))
	_add_float("Perfect", ball_pos, Color("#b8f3ff"))
	AudioManager.play_sfx("perfect")
	var diamond_chance = min(0.18, 0.03 + stats.reward_chance)
	if randf() < diamond_chance:
		run_gems += 1
		run_rewards.gems += 1
		_add_float("+1 Diamante", ball_pos + Vector2(10, 12), Color("#c084fc"))
		AudioManager.play_sfx("diamond_gain")

func _handle_ring_hit(index, prev_dist, stats):
	var now_ms = Time.get_ticks_msec()
	var ring = rings[index]
	var dx = ball_pos.x - center.x
	var dy = ball_pos.y - center.y
	var dist = max(1.0, sqrt(dx * dx + dy * dy))
	var radial = Vector2(dx / dist, dy / dist)
	var started_outside = prev_dist >= float(ring.radius)
	var normal = radial if started_outside else -radial
	var safe_distance = float(ring.radius) + float(ring.thickness) * 0.5 + BALL_RADIUS + 2.6 if started_outside else max(0.0, float(ring.radius) - float(ring.thickness) * 0.5 - BALL_RADIUS - 2.6)
	ball_pos = center + radial * min(outer_radius - BALL_RADIUS, safe_distance)
	var dot = velocity.dot(normal)
	if dot < 0.0:
		velocity -= 2.0 * dot * normal
		velocity = RingLogic.clamp_ball_speed(velocity * 1.04, stats.target_speed * 0.88, stats.target_speed * 1.60)
	if now_ms - last_hit_at <= 90.0:
		return
	last_hit_at = now_ms
	var skin = GameData.get_skin(SaveSystem.get_save().equipped_skin)
	var passive = skin.passive
	if ring.get("type", "normal") != "solid" and passive.type == "phase_solid" and randf() < float(passive.get("chance", 0.0)):
		ring = ring.duplicate(true)
		ring.status = "cleared"
		ring.hp = 0
		rings[index] = ring
		run_rewards.perfect_escapes += 1
		run_rewards.skin_effects += 1
		_register_combo("Phase", Color("#dff7ff"))
		_add_float("Phase!", ball_pos, Color("#dff7ff"))
		return
	var is_crit = randf() * 100.0 < stats.crit_chance
	var damage = stats.damage * (stats.crit_damage if is_crit else 1.0)
	var was_alive = float(ring.hp) > 0.0
	var next_ring = ring.duplicate(true)
	next_ring.hp = max(0.0, float(next_ring.hp) - damage)
	next_ring.status = "broken" if float(next_ring.hp) <= 0.0 else "active"
	rings[index] = next_ring
	if is_crit:
		run_rewards.criticals += 1
		AudioManager.play_sfx("hit_heavy")
	else:
		AudioManager.play_sfx("hit_light")
	_add_float(int(damage), ball_pos, Color("#ffd700") if is_crit else Color.WHITE)
	_apply_skin_and_upgrade_effects(index, damage, stats)
	var coins_gained = int(floor(damage * 0.5 * stats.gold_multiplier))
	if passive.type == "coin_on_hit" and randf() < float(passive.get("chance", 0.0)):
		coins_gained += int(passive.get("value", 0))
		run_rewards.skin_effects += 1
		_add_float("Bonus moedas", ball_pos + Vector2(0, 18), Color("#ffd700"))
	_award_coins(coins_gained)
	_award_xp(max(1, int(floor((2.0 if is_crit else 1.0) * stats.xp_multiplier))))
	score += int(damage)
	if was_alive and float(rings[index].hp) <= 0.0:
		run_rewards.rings_broken += 1
		_register_combo("Break", Color("#ffd700"))
		_add_float("Break!", ball_pos + Vector2(8, -8), Color("#ffd700"))
		AudioManager.play_sfx("ring_break")
		_award_coins(max(6, int(floor((18.0 if ring.type == "solid" else 12.0) * stats.gold_multiplier))))
		_award_xp(int(floor(((16.0 if ring.type == "solid" else 8.0) + randf() * 8.0) * stats.xp_multiplier)))

func _apply_skin_and_upgrade_effects(index, damage, stats):
	var now_ms = Time.get_ticks_msec()
	var skin = GameData.get_skin(SaveSystem.get_save().equipped_skin)
	var passive = skin.passive
	var ring = rings[index]
	if passive.type in ["slow_ring", "freeze_ring"] and randf() < float(passive.get("chance", 0.0)):
		var duration = float(passive.get("duration_ms", 2200))
		ring = RingLogic.with_effect(ring, "frozen" if passive.type == "freeze_ring" else "slowed", duration, now_ms)
		ring.slow_until = now_ms + duration
		rings[index] = ring
		run_rewards.skin_effects += 1
		_add_float("Frost", ball_pos, Color("#9be8ff"))
	if passive.type == "burn" and randf() < float(passive.get("chance", 0.0)):
		var duration_burn = float(passive.get("duration_ms", 2800))
		ring = RingLogic.with_effect(rings[index], "burning", duration_burn, now_ms)
		ring.burn_until = now_ms + duration_burn
		ring.burn_dps = float(passive.get("value", 4.0))
		rings[index] = ring
		run_rewards.skin_effects += 1
		_add_float("Burn", ball_pos, Color("#ff8a00"))
	if passive.type == "repel_ring" and randf() < float(passive.get("chance", 0.0)):
		ring = RingLogic.with_effect(rings[index], "repulsed", 760, now_ms)
		ring.radius = min(float(ring.initial_radius) + 18.0, float(ring.radius) + float(passive.get("value", 18.0)) * 0.45, outer_radius)
		rings[index] = ring
		run_rewards.skin_effects += 1
		_add_float("Repel", ball_pos, Color("#c084fc"))
	if passive.type in ["area_damage", "cosmic_critical"] and randf() < float(passive.get("chance", 0.0)):
		for i in range(rings.size()):
			if i == index or rings[i].status != "active":
				continue
			if abs(float(rings[i].radius) - float(ring.radius)) > 38.0:
				continue
			var other = rings[i].duplicate(true)
			other.hp = max(0.0, float(other.hp) - damage * float(passive.get("value", 0.4)))
			other.status = "broken" if float(other.hp) <= 0.0 else other.status
			rings[i] = RingLogic.with_effect(other, "gravity" if passive.type == "cosmic_critical" else "exploded", 850, now_ms)
		run_rewards.skin_effects += 1
		_add_float("Area", ball_pos, Color("#ff3d8b"))
	if passive.type == "chain_damage" and randf() < float(passive.get("chance", 0.0)):
		for i in range(rings.size()):
			if i != index and rings[i].status == "active":
				var target = rings[i].duplicate(true)
				target.hp = max(0.0, float(target.hp) - damage * float(passive.get("value", 0.35)))
				target.status = "broken" if float(target.hp) <= 0.0 else target.status
				rings[i] = RingLogic.with_effect(target, "shocked", 760, now_ms)
				run_rewards.skin_effects += 1
				_add_float("Chain", ball_pos, Color("#faff00"))
				break
	if int(current_upgrades.get("frost", 0)) > 0 and randf() < 0.16 + int(current_upgrades.get("frost", 0)) * 0.04:
		var frozen = RingLogic.with_effect(rings[index], "frozen", 1900 + int(current_upgrades.get("frost", 0)) * 300, now_ms)
		frozen.slow_until = now_ms + 1900 + int(current_upgrades.get("frost", 0)) * 300
		rings[index] = frozen
	if int(current_upgrades.get("shockwave", 0)) > 0 and randf() < 0.08 + int(current_upgrades.get("shockwave", 0)) * 0.04:
		for i in range(rings.size()):
			if i == index or rings[i].status != "active":
				continue
			if abs(float(rings[i].radius) - float(ring.radius)) < 45.0:
				var shock = rings[i].duplicate(true)
				shock.hp = max(0.0, float(shock.hp) - damage * 0.25)
				shock.status = "broken" if float(shock.hp) <= 0.0 else shock.status
				rings[i] = RingLogic.with_effect(shock, "exploded", 720, now_ms)

func _final_stats():
	var save = SaveSystem.get_save()
	var permanent = save.permanent_upgrades
	var skin = GameData.get_skin(save.equipped_skin)
	var passive = skin.passive
	var base_damage = 10.0 * (1.0 + int(permanent.get("baseDamage", 0)) * 0.10)
	var damage_mult = 1.0 + int(run_shop_upgrades.atk) * 0.12
	var gold_mult = 1.0 + int(permanent.get("coinMultiplier", 0)) * 0.15 + int(run_shop_upgrades.gold) * 0.12
	var xp_mult = 1.0 + int(permanent.get("xpBoost", 0)) * 0.20 + int(run_shop_upgrades.gold) * 0.05
	var speed_mult = 1.0 + int(permanent.get("baseSpeed", 0)) * 0.08
	var crit_chance = 5.0 + int(permanent.get("critChance", 0)) * 2.0
	var crit_damage = 2.0
	var reward_chance = int(permanent.get("perfectChance", 0)) * 0.01
	if passive.type == "damage_multiplier":
		damage_mult += float(passive.value)
	if passive.type in ["coin_multiplier", "cosmic_critical", "league_starter_champion", "league_king_wave"]:
		gold_mult += float(passive.value) * 0.6
	if passive.type == "xp_multiplier":
		xp_mult += float(passive.value)
	if passive.type == "speed":
		speed_mult += float(passive.value)
	if passive.type == "crit_chance":
		crit_chance += float(passive.value)
	if passive.type in ["perfect_chance", "cosmic_critical", "league_king_wave"]:
		reward_chance += float(passive.value)
	for upgrade_id in current_upgrades.keys():
		var upgrade = GameData.get_run_upgrade(upgrade_id)
		var level = int(current_upgrades.get(upgrade_id, 0))
		for effect in upgrade.get("effects", []):
			var value = float(effect.value) * level
			match effect.type:
				"damage", "competitiveBoost", "outerDamage", "comboBoost":
					damage_mult += value
				"speed":
					speed_mult += value
				"coinMultiplier":
					gold_mult += value
				"xpMultiplier":
					xp_mult += value
				"critChance":
					crit_chance += value
				"critOverload":
					crit_damage += value
				"perfectChance":
					reward_chance += value
	var target_speed = (INITIAL_BALL_SPEED + min(0.62, (phase_id - 1) * 0.08)) * speed_mult
	return {
		"damage": max(1, int(round(base_damage * damage_mult))),
		"gold_multiplier": gold_mult,
		"xp_multiplier": xp_mult,
		"speed_multiplier": speed_mult,
		"crit_chance": crit_chance,
		"crit_damage": crit_damage,
		"reward_chance": reward_chance,
		"target_speed": target_speed
	}

func _award_coins(amount):
	if amount <= 0:
		return
	var mult = GameData.get_combo_multiplier(combo).coins
	var balanced = max(1, int(floor(amount * mult * 0.92)))
	run_coins += balanced
	run_rewards.coins += balanced
	AudioManager.play_sfx("coin_gain")

func _award_xp(amount):
	if amount <= 0:
		return
	var mult = GameData.get_combo_multiplier(combo).xp
	var value = max(1, int(floor(amount * mult)))
	run_rewards.xp += value
	run_xp += value
	var needed = GameData.get_run_xp_needed(run_level)
	if run_xp >= needed:
		run_xp -= needed
		run_level += 1
		_open_level_up()

func _register_combo(label, color):
	var now_ms = Time.get_ticks_msec()
	combo = combo + 1 if now_ms - last_combo_at <= COMBO_WINDOW_MS else 1
	last_combo_at = now_ms
	best_combo = max(best_combo, combo)
	run_rewards.best_combo = best_combo
	if combo >= 2:
		var combo_data = GameData.get_combo_multiplier(combo)
		_add_float("%s x%d" % [combo_data.label, combo], ball_pos + Vector2(-18, -24), color)
		if combo in [5, 10, 20]:
			AudioManager.play_sfx("combo")
	else:
		_add_float(label, ball_pos + Vector2(0, -18), color)

func _open_level_up():
	level_up_open = true
	level_up_panel.visible = true
	AudioManager.play_sfx("level_up")
	_fill_level_up_options()

func _fill_level_up_options():
	NeonUI.clear_children(level_up_list)
	var options = GameData.get_random_run_upgrades(3, SaveSystem.get_save(), current_upgrades)
	for upgrade in options:
		var button = NeonUI.ghost_button("%s\n%s" % [upgrade.name, upgrade.description], Color(upgrade.get("color", "#00f0ff")), 66)
		button.pressed.connect(_select_run_upgrade.bind(upgrade.id))
		level_up_list.add_child(button)

func _select_run_upgrade(upgrade_id):
	current_upgrades[upgrade_id] = int(current_upgrades.get(upgrade_id, 0)) + 1
	run_rewards.run_upgrades += 1
	level_up_open = false
	level_up_panel.visible = false
	AudioManager.play_sfx("button_confirm")

func _reroll_level_up_with_ad():
	AudioManager.play_sfx("button_click")
	await AdsService.show_rewarded("upgrade_reroll")
	SaveSystem.record_ad_use()
	_fill_level_up_options()

func _buy_run_upgrade(kind):
	var cost = int(floor((20.0 if kind == "atk" else 18.0) * pow(1.35, int(run_shop_upgrades[kind]))))
	if run_coins < cost:
		AudioManager.play_sfx("button_error")
		_add_float("Moedas insuficientes", center, Color("#ff0055"))
		return
	run_coins -= cost
	run_shop_upgrades[kind] += 1
	run_rewards.run_upgrades += 1
	AudioManager.play_sfx("button_confirm")
	_add_float("ATK+" if kind == "atk" else "Gold+", center + Vector2(0, -24), Color("#ffd700"))

func _constrain_outer_wall():
	var dir = ball_pos - center
	var dist = dir.length()
	var max_distance = outer_radius - BALL_RADIUS
	if dist > max_distance and dist > 0.0:
		var normal = dir / dist
		ball_pos = center + normal * max_distance
		var outward = velocity.dot(normal)
		if outward > 0.0:
			velocity -= 2.0 * outward * normal

func _active_rings():
	var active = []
	for ring in rings:
		if ring.status == "active" and float(ring.hp) > 0.0:
			active.append(ring)
	return active

func _push_trail():
	trail_points.append(ball_pos)
	while trail_points.size() > 12:
		trail_points.pop_front()

func _cleanup_floating():
	var now_ms = Time.get_ticks_msec()
	floating_numbers = floating_numbers.filter(func(item): return now_ms - float(item.get("born", now_ms)) <= 950.0)

func _add_float(text, position, color):
	floating_numbers.append({"text": text, "position": position, "color": color.to_html(false), "born": Time.get_ticks_msec()})
	while floating_numbers.size() > 18:
		floating_numbers.pop_front()

func _push_arena_state():
	var skin = GameData.get_skin(SaveSystem.get_save().equipped_skin)
	arena_view.set_state(rings, ball_pos, center, outer_radius, skin, trail_points, floating_numbers, Time.get_ticks_msec() < invincible_until)

func _update_hud():
	var save = SaveSystem.get_save()
	var active = _active_rings().size()
	var total = rings.size()
	var stats = _final_stats()
	wallet_label.text = "Rodada %d moedas  %d diamantes    Conta %d / %d" % [run_coins, run_gems, save.coins, save.gems]
	progress_label.text = "Fase %d %s | Aneis %d/%d | ATK %d | Skin %s" % [phase_id, phase_config.get("difficulty", ""), active, total, stats.damage, GameData.get_skin(save.equipped_skin).name]
	xp_label.text = "Lv.%d  XP %d/%d" % [run_level, run_xp, GameData.get_run_xp_needed(run_level)]
	combo_label.text = "Combo x%d" % combo if combo >= 2 else ""
	pause_button.text = "CONTINUAR" if paused else "PAUSAR"

func _toggle_pause():
	paused = not paused
	AudioManager.play_sfx("button_click")
	_update_hud()

func _quit_run():
	_finish_run(false, true)

func _finish_run(won, quit = false):
	if not running:
		return
	running = false
	var profile_xp = GameData.get_run_profile_xp(run_rewards.xp, run_rewards.rings_broken, run_rewards.perfect_escapes, best_combo)
	var summary = {
		"phase": phase_id,
		"won": won,
		"quit": quit,
		"coins": run_coins,
		"gems": run_gems,
		"xp": run_rewards.xp,
		"profile_xp": profile_xp,
		"rings_broken": run_rewards.rings_broken,
		"perfect_escapes": run_rewards.perfect_escapes,
		"run_level": run_level,
		"best_combo": best_combo,
		"run_upgrades": run_rewards.run_upgrades,
		"criticals": run_rewards.criticals,
		"skin_effects": run_rewards.skin_effects
	}
	AudioManager.play_sfx("victory" if won else "defeat")
	get_tree().current_scene.go_to("game_over", {"summary": summary, "phase": phase_id, "won": won})

func _on_arena_input(event):
	if not running or paused or level_up_open:
		return
	if event is InputEventScreenTouch and event.pressed:
		_nudge_toward(event.position)
	elif event is InputEventMouseButton and event.pressed:
		_nudge_toward(event.position)
	elif event is InputEventScreenDrag:
		_nudge_toward(event.position, 0.28)

func _nudge_toward(local_position, force = 0.72):
	var dir = local_position - center
	if dir.length() <= 2.0:
		return
	velocity += dir.normalized() * force
	velocity = RingLogic.clamp_ball_speed(velocity, 1.6, 4.4)
	_add_float("Impulse", ball_pos, Color("#00f0ff"))

func _impulse_outward():
	var dir = ball_pos - center
	if dir.length() < 2.0:
		dir = velocity.normalized()
	velocity += dir.normalized() * 0.9
	velocity = RingLogic.clamp_ball_speed(velocity, 1.6, 4.8)
	AudioManager.play_sfx("button_click")

func _rotate_velocity(amount):
	velocity = velocity.rotated(amount)
	AudioManager.play_sfx("button_click")

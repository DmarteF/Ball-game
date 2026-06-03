extends RefCounted

const MAX_PHASE := 100
const COLORS := ["#00f0ff", "#b000ff", "#ff0055", "#00ff88", "#ffd700", "#ff8800", "#ff4fd8", "#60a5fa"]


static func get_phase_config(phase_id: int) -> Dictionary:
	var id := clampi(phase_id, 1, MAX_PHASE)
	var tier := _tier_for_phase(id)
	var tier_start: int = 1 if id <= 5 else 6 if id <= 10 else 11 if id <= 20 else 21 if id <= 35 else 36 if id <= 50 else 51 if id <= 70 else 71 if id <= 85 else 86
	var tier_end: int = 5 if id <= 5 else 10 if id <= 10 else 20 if id <= 20 else 35 if id <= 35 else 50 if id <= 50 else 70 if id <= 70 else 85 if id <= 85 else MAX_PHASE
	var phase_t: float = float(id - tier_start) / max(1.0, float(tier_end - tier_start))
	var ring_min := roundi(float(tier["min"]) + (float(tier["max"]) - float(tier["min"])) * phase_t * 0.72)
	var ring_max := roundi(float(tier["min"]) + (float(tier["max"]) - float(tier["min"])) * min(1.0, phase_t + 0.22))
	var late_scale: float = 1.0 + max(0.0, float(id - 50)) * 0.006
	return {
		"id": id,
		"name": "Fase %s" % id,
		"description": "Primeira arena neon com aberturas grandes." if id == 1 else String(tier["desc"]),
		"difficulty": String(tier["name"]),
		"ring_min": ring_min,
		"ring_max": max(ring_min + 2, ring_max),
		"base_hp": roundi((float(tier["hp"]) + id * 5.2 + pow(id, 1.26) * 4.6) * late_scale),
		"closing_speed": min(0.172, float(tier["close"]) + phase_t * 0.022 + id * 0.00072),
		"rotation_speed": min(0.044, float(tier["rotate"]) + phase_t * 0.0058 + id * 0.00026),
		"gap_size": max(PI / 12.5, PI / (float(tier["gap"]) + phase_t * 0.82) * 0.72),
		"reward_coins": roundi(70 + id * 36 + pow(id, 1.18) * 6),
		"reward_xp": roundi(45 + id * 22 + pow(id, 1.12) * 4),
		"key_chance": min(0.34, 0.025 + id * 0.0058),
		"chest_chance": min(0.25, 0.015 + id * 0.0044),
		"color": COLORS[(id - 1) % COLORS.size()],
	}


static func get_solo_gameplay_config(phase_id: int, player_level: int, slow_ring_level := 0) -> Dictionary:
	var phase: Dictionary = get_phase_config(phase_id)
	var difficulty: float = 1.0 + float(phase_id - 1) * 0.072 + max(0.0, float(player_level - 1)) * 0.011
	return {
		"ring_count": min(70, floori((int(phase["ring_min"]) + int(phase["ring_max"])) / 2.0) + floori(player_level / 10.0)),
		"base_hp": roundi(float(phase["base_hp"]) * difficulty),
		"closing_speed": min(0.122, (float(phase["closing_speed"]) + player_level * 0.0002) * 0.8 * (1.0 - min(0.30, slow_ring_level * 0.017))),
		"rotation_speed": min(0.031, (float(phase["rotation_speed"]) + player_level * 0.00013) * 0.88),
		"gap_size": max(PI / 13.0, float(phase["gap_size"]) - player_level * 0.001),
	}


static func _tier_for_phase(id: int) -> Dictionary:
	if id <= 5:
		return { "min": 8, "max": 16, "hp": 12, "close": 0.018, "rotate": 0.0045, "gap": 2.4, "name": "Normal", "desc": "Arena inicial com aberturas grandes e pressão baixa." }
	if id <= 10:
		return { "min": 16, "max": 24, "hp": 34, "close": 0.03, "rotate": 0.007, "gap": 2.75, "name": "Difícil", "desc": "Rotação alternada e anéis um pouco mais resistentes." }
	if id <= 20:
		return { "min": 24, "max": 36, "hp": 68, "close": 0.045, "rotate": 0.01, "gap": 3.15, "name": "Avançado", "desc": "Mais padrões, aberturas menores e anéis resistentes." }
	if id <= 35:
		return { "min": 36, "max": 50, "hp": 128, "close": 0.067, "rotate": 0.014, "gap": 3.55, "name": "Extremo", "desc": "Arena exigente para skins e upgrades mais fortes." }
	if id <= 50:
		return { "min": 50, "max": 65, "hp": 220, "close": 0.092, "rotate": 0.019, "gap": 4.05, "name": "Insano", "desc": "Padrões complexos, fechamento perigoso e melhores baús." }
	if id <= 70:
		return { "min": 60, "max": 78, "hp": 310, "close": 0.108, "rotate": 0.023, "gap": 4.35, "name": "Ultimate", "desc": "Arena premium com rotação intensa, justa e recompensas altas." }
	if id <= 85:
		return { "min": 70, "max": 92, "hp": 430, "close": 0.122, "rotate": 0.027, "gap": 4.75, "name": "Mítico", "desc": "Pressão mítica com anéis rápidos e recompensas raras." }
	return { "min": 82, "max": 110, "hp": 580, "close": 0.136, "rotate": 0.031, "gap": 5.15, "name": "Ômega", "desc": "Final neon com padrões densos, velozes e altamente recompensadores." }

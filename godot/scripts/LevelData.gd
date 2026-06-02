extends RefCounted

const COLORS := ["#00f0ff", "#b000ff", "#ff0055", "#00ff88", "#ffd700", "#ff8800", "#ff4fd8", "#60a5fa"]


static func get_phase_config(phase_id: int) -> Dictionary:
	var id := clampi(phase_id, 1, 50)
	var tier := _tier_for_phase(id)
	var tier_start: int = 1 if id <= 5 else 6 if id <= 10 else 11 if id <= 20 else 21 if id <= 30 else 31 if id <= 40 else 41
	var tier_end: int = 5 if id <= 5 else 10 if id <= 10 else 20 if id <= 20 else 30 if id <= 30 else 40 if id <= 40 else 50
	var phase_t: float = float(id - tier_start) / max(1.0, float(tier_end - tier_start))
	var ring_min := roundi(float(tier["min"]) + (float(tier["max"]) - float(tier["min"])) * phase_t * 0.72)
	var ring_max := roundi(float(tier["min"]) + (float(tier["max"]) - float(tier["min"])) * min(1.0, phase_t + 0.22))
	return {
		"id": id,
		"name": "Fase %s" % id,
		"description": "Primeira arena neon com aberturas grandes." if id == 1 else String(tier["desc"]),
		"difficulty": String(tier["name"]),
		"ring_min": ring_min,
		"ring_max": max(ring_min + 2, ring_max),
		"base_hp": roundi(float(tier["hp"]) + id * 6 + pow(id, 1.32) * 5.2),
		"closing_speed": min(0.18, float(tier["close"]) + phase_t * 0.025 + id * 0.0011),
		"rotation_speed": min(0.048, float(tier["rotate"]) + phase_t * 0.0065 + id * 0.00034),
		"gap_size": max(PI / 9.5, PI / (float(tier["gap"]) + phase_t * 0.82)),
		"reward_coins": roundi(70 + id * 36 + pow(id, 1.18) * 6),
		"reward_xp": roundi(45 + id * 22 + pow(id, 1.12) * 4),
		"key_chance": min(0.34, 0.025 + id * 0.0058),
		"chest_chance": min(0.25, 0.015 + id * 0.0044),
		"color": COLORS[(id - 1) % COLORS.size()],
	}


static func get_solo_gameplay_config(phase_id: int, player_level: int, slow_ring_level := 0) -> Dictionary:
	var phase: Dictionary = get_phase_config(phase_id)
	var difficulty: float = 1.0 + float(phase_id - 1) * 0.13 + max(0.0, float(player_level - 1)) * 0.012
	return {
		"ring_count": min(45, floori((int(phase["ring_min"]) + int(phase["ring_max"])) / 2.0) + floori(player_level / 10.0)),
		"base_hp": roundi(float(phase["base_hp"]) * difficulty),
		"closing_speed": min(0.118, (float(phase["closing_speed"]) + player_level * 0.00022) * 0.82 * (1.0 - min(0.28, slow_ring_level * 0.018))),
		"rotation_speed": min(0.029, (float(phase["rotation_speed"]) + player_level * 0.00014) * 0.9),
		"gap_size": max(PI / 7.2, float(phase["gap_size"]) - player_level * 0.001),
	}


static func _tier_for_phase(id: int) -> Dictionary:
	if id <= 5:
		return { "min": 8, "max": 16, "hp": 12, "close": 0.018, "rotate": 0.0045, "gap": 2.4, "name": "Normal", "desc": "Arena inicial com aberturas grandes e pressão baixa." }
	if id <= 10:
		return { "min": 16, "max": 24, "hp": 34, "close": 0.03, "rotate": 0.007, "gap": 2.75, "name": "Difícil", "desc": "Rotação alternada e anéis um pouco mais resistentes." }
	if id <= 20:
		return { "min": 24, "max": 36, "hp": 68, "close": 0.045, "rotate": 0.01, "gap": 3.15, "name": "Avançado", "desc": "Mais padrões, aberturas menores e anéis resistentes." }
	if id <= 30:
		return { "min": 36, "max": 50, "hp": 128, "close": 0.067, "rotate": 0.014, "gap": 3.55, "name": "Extremo", "desc": "Arena exigente para skins e upgrades mais fortes." }
	if id <= 40:
		return { "min": 50, "max": 65, "hp": 220, "close": 0.092, "rotate": 0.019, "gap": 4.05, "name": "Insano", "desc": "Padrões complexos, fechamento perigoso e melhores baús." }
	return { "min": 65, "max": 80, "hp": 340, "close": 0.12, "rotate": 0.025, "gap": 4.6, "name": "Ultimate", "desc": "Arena premium com rotação intensa, justa e recompensas altas." }

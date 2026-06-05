extends RefCounted

const MAX_PHASE := 100
const COLORS := ["#00f0ff", "#b000ff", "#ff0055", "#00ff88", "#ffd700", "#ff8800", "#ff4fd8", "#60a5fa"]


static func get_phase_config(phase_id: int) -> Dictionary:
	var id := clampi(phase_id, 1, MAX_PHASE)
	var tier := _tier_for_phase(id)
	var tier_start: int = 1 if id <= 5 else 6 if id <= 15 else 16 if id <= 30 else 31 if id <= 45 else 46 if id <= 50 else 51 if id <= 75 else 76
	var tier_end: int = 5 if id <= 5 else 15 if id <= 15 else 30 if id <= 30 else 45 if id <= 45 else 50 if id <= 50 else 75 if id <= 75 else MAX_PHASE
	var phase_t: float = float(id - tier_start) / max(1.0, float(tier_end - tier_start))
	var ring_min := roundi(float(tier["min"]) + (float(tier["max"]) - float(tier["min"])) * phase_t * 0.68)
	var ring_max := roundi(float(tier["min"]) + (float(tier["max"]) - float(tier["min"])) * min(1.0, phase_t + 0.22))
	var late_scale: float = 1.0 + max(0.0, float(id - 50)) * 0.0045
	return {
		"id": id,
		"name": "Fase %s" % id,
		"description": "Primeira arena neon com aberturas grandes." if id == 1 else String(tier["desc"]),
		"difficulty": String(tier["name"]),
		"ring_min": ring_min,
		"ring_max": max(ring_min + 2, ring_max),
		"base_hp": roundi((float(tier["hp"]) + id * float(tier["hp_per_phase"]) + pow(id, 1.18) * float(tier["hp_curve"])) * late_scale),
		"closing_speed": min(0.148, float(tier["close"]) + phase_t * float(tier["close_curve"]) + id * 0.00044),
		"rotation_speed": min(0.038, float(tier["rotate"]) + phase_t * float(tier["rotate_curve"]) + id * 0.00018),
		"gap_size": max(PI / 13.2, PI / (float(tier["gap"]) + phase_t * 0.72) * 0.76),
		"reward_coins": roundi(float(tier["coin_base"]) + id * float(tier["coin_per_phase"]) + pow(id, 1.10) * float(tier["coin_curve"])),
		"reward_xp": roundi(float(tier["xp_base"]) + id * float(tier["xp_per_phase"]) + pow(id, 1.08) * float(tier["xp_curve"])),
		"diamond_chance": min(float(tier["diamond_cap"]), float(tier["diamond_base"]) + id * float(tier["diamond_growth"])),
		"key_chance": min(float(tier["key_cap"]), float(tier["key_base"]) + id * float(tier["key_growth"])),
		"chest_chance": min(float(tier["chest_cap"]), float(tier["chest_base"]) + id * float(tier["chest_growth"])),
		"color": COLORS[(id - 1) % COLORS.size()],
	}


static func get_solo_gameplay_config(phase_id: int, player_level: int, slow_ring_level := 0) -> Dictionary:
	var phase: Dictionary = get_phase_config(phase_id)
	var difficulty: float = 1.0 + float(phase_id - 1) * 0.052 + max(0.0, float(player_level - 1)) * 0.009
	return {
		"ring_count": max(8, min(100, floori((int(phase["ring_min"]) + int(phase["ring_max"])) / 2.0) + floori(player_level / 12.0))),
		"base_hp": roundi(float(phase["base_hp"]) * difficulty),
		"closing_speed": min(0.118, (float(phase["closing_speed"]) + player_level * 0.00016) * 0.78 * (1.0 - min(0.30, slow_ring_level * 0.017))),
		"rotation_speed": min(0.029, (float(phase["rotation_speed"]) + player_level * 0.00011) * 0.86),
		"gap_size": max(PI / 13.0, float(phase["gap_size"]) - player_level * 0.001),
	}


static func _tier_for_phase(id: int) -> Dictionary:
	if id <= 5:
		return { "min": 6, "max": 12, "hp": 8, "hp_per_phase": 2.2, "hp_curve": 1.5, "close": 0.010, "close_curve": 0.006, "rotate": 0.0030, "rotate_curve": 0.0018, "gap": 1.95, "coin_base": 130, "coin_per_phase": 44, "coin_curve": 5.0, "xp_base": 95, "xp_per_phase": 27, "xp_curve": 4.0, "diamond_base": 0.010, "diamond_growth": 0.0020, "diamond_cap": 0.030, "key_base": 0.000, "key_growth": 0.0010, "key_cap": 0.015, "chest_base": 0.000, "chest_growth": 0.0008, "chest_cap": 0.012, "name": "Tutorial", "desc": "Arena inicial com aberturas grandes, ritmo curto e recompensas fortes." }
	if id <= 15:
		return { "min": 10, "max": 22, "hp": 22, "hp_per_phase": 3.3, "hp_curve": 2.2, "close": 0.017, "close_curve": 0.010, "rotate": 0.0048, "rotate_curve": 0.0024, "gap": 2.30, "coin_base": 170, "coin_per_phase": 46, "coin_curve": 5.6, "xp_base": 110, "xp_per_phase": 29, "xp_curve": 4.6, "diamond_base": 0.018, "diamond_growth": 0.0026, "diamond_cap": 0.055, "key_base": 0.006, "key_growth": 0.0016, "key_cap": 0.035, "chest_base": 0.004, "chest_growth": 0.0014, "chest_cap": 0.030, "name": "Leve", "desc": "Comeca a exigir melhorias iniciais e mostra valor das primeiras skins." }
	if id <= 30:
		return { "min": 20, "max": 40, "hp": 58, "hp_per_phase": 4.4, "hp_curve": 3.0, "close": 0.030, "close_curve": 0.014, "rotate": 0.0076, "rotate_curve": 0.0032, "gap": 2.75, "coin_base": 240, "coin_per_phase": 50, "coin_curve": 6.4, "xp_base": 160, "xp_per_phase": 33, "xp_curve": 5.2, "diamond_base": 0.030, "diamond_growth": 0.0030, "diamond_cap": 0.090, "key_base": 0.012, "key_growth": 0.0020, "key_cap": 0.070, "chest_base": 0.010, "chest_growth": 0.0020, "chest_cap": 0.070, "name": "Medio", "desc": "Progressao real com upgrades e efeitos de skins fazendo diferenca." }
	if id <= 45:
		return { "min": 34, "max": 58, "hp": 120, "hp_per_phase": 5.5, "hp_curve": 3.8, "close": 0.047, "close_curve": 0.018, "rotate": 0.0115, "rotate_curve": 0.0040, "gap": 3.25, "coin_base": 340, "coin_per_phase": 56, "coin_curve": 7.4, "xp_base": 230, "xp_per_phase": 38, "xp_curve": 6.0, "diamond_base": 0.050, "diamond_growth": 0.0032, "diamond_cap": 0.130, "key_base": 0.025, "key_growth": 0.0024, "key_cap": 0.110, "chest_base": 0.020, "chest_growth": 0.0026, "chest_cap": 0.120, "name": "Alto", "desc": "Arena exigente para melhorias evoluidas, combos e skins com efeito." }
	if id <= 50:
		return { "min": 46, "max": 70, "hp": 205, "hp_per_phase": 6.6, "hp_curve": 4.6, "close": 0.067, "close_curve": 0.020, "rotate": 0.0160, "rotate_curve": 0.0048, "gap": 3.75, "coin_base": 520, "coin_per_phase": 66, "coin_curve": 8.8, "xp_base": 350, "xp_per_phase": 45, "xp_curve": 7.2, "diamond_base": 0.080, "diamond_growth": 0.0036, "diamond_cap": 0.170, "key_base": 0.045, "key_growth": 0.0028, "key_cap": 0.150, "chest_base": 0.040, "chest_growth": 0.0030, "chest_cap": 0.170, "name": "Dificil", "desc": "Fechamento perigoso, boas recompensas e marco especial da fase 50." }
	if id <= 75:
		return { "min": 56, "max": 86, "hp": 315, "hp_per_phase": 7.8, "hp_curve": 5.2, "close": 0.082, "close_curve": 0.022, "rotate": 0.0200, "rotate_curve": 0.0052, "gap": 4.20, "coin_base": 650, "coin_per_phase": 74, "coin_curve": 10.0, "xp_base": 455, "xp_per_phase": 52, "xp_curve": 8.2, "diamond_base": 0.100, "diamond_growth": 0.0038, "diamond_cap": 0.220, "key_base": 0.060, "key_growth": 0.0030, "key_cap": 0.200, "chest_base": 0.060, "chest_growth": 0.0034, "chest_cap": 0.220, "name": "Elite", "desc": "Desafio maior com recompensas altas e chance real de baus melhores." }
	return { "min": 70, "max": 106, "hp": 450, "hp_per_phase": 9.0, "hp_curve": 6.0, "close": 0.098, "close_curve": 0.024, "rotate": 0.0240, "rotate_curve": 0.0058, "gap": 4.70, "coin_base": 820, "coin_per_phase": 86, "coin_curve": 11.5, "xp_base": 620, "xp_per_phase": 62, "xp_curve": 9.6, "diamond_base": 0.130, "diamond_growth": 0.0040, "diamond_cap": 0.280, "key_base": 0.080, "key_growth": 0.0032, "key_cap": 0.260, "chest_base": 0.080, "chest_growth": 0.0036, "chest_cap": 0.280, "name": "Final", "desc": "Final neon com pressao alta, recompensas especiais e desafio de longa progressao." }

extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

const DAILY_MISSIONS = [
	{"id": "rings_50", "title": "Destruir 50 aneis", "metric": "rings_destroyed", "target": 50, "reward": {"type": "coins", "amount": 260}, "difficulty": 1},
	{"id": "rings_150", "title": "Destruir 150 aneis", "metric": "rings_destroyed", "target": 150, "reward": {"type": "keys", "amount": 1}, "difficulty": 2},
	{"id": "perfect_3", "title": "Fazer 3 Perfect Escapes", "metric": "perfect_escapes", "target": 3, "reward": {"type": "gems", "amount": 5}, "difficulty": 1},
	{"id": "perfect_10", "title": "Fazer 10 Perfect Escapes", "metric": "perfect_escapes", "target": 10, "reward": {"type": "gems", "amount": 14}, "difficulty": 2},
	{"id": "runs_3", "title": "Jogar 3 partidas", "metric": "runs_played", "target": 3, "reward": {"type": "profile_xp", "amount": 70}, "difficulty": 1},
	{"id": "runs_5", "title": "Jogar 5 partidas", "metric": "runs_played", "target": 5, "reward": {"type": "coins", "amount": 420}, "difficulty": 2},
	{"id": "win_1", "title": "Vencer 1 fase", "metric": "phase_wins", "target": 1, "reward": {"type": "gems", "amount": 8}, "difficulty": 1},
	{"id": "win_3", "title": "Vencer 3 fases", "metric": "phase_wins", "target": 3, "reward": {"type": "chest", "chest": "rare", "amount": 1}, "difficulty": 3},
	{"id": "chest_1", "title": "Abrir 1 bau", "metric": "chests_opened", "target": 1, "reward": {"type": "fragments", "amount": 12}, "difficulty": 1},
	{"id": "chest_3", "title": "Abrir 3 baus", "metric": "chests_opened", "target": 3, "reward": {"type": "keys", "amount": 1}, "difficulty": 2},
	{"id": "coins_500", "title": "Ganhar 500 moedas da rodada", "metric": "run_coins", "target": 500, "reward": {"type": "coins", "amount": 320}, "difficulty": 1},
	{"id": "coins_2000", "title": "Ganhar 2.000 moedas da rodada", "metric": "run_coins", "target": 2000, "reward": {"type": "gems", "amount": 12}, "difficulty": 3},
	{"id": "gems_5", "title": "Ganhar 5 diamantes", "metric": "diamonds_found", "target": 5, "reward": {"type": "profile_xp", "amount": 120}, "difficulty": 2},
	{"id": "temp_upgrades_3", "title": "Usar 3 upgrades temporarios", "metric": "run_upgrades", "target": 3, "reward": {"type": "coins", "amount": 260}, "difficulty": 1},
	{"id": "combo_5", "title": "Fazer combo x5", "metric": "best_combo", "target": 5, "reward": {"type": "gems", "amount": 5}, "difficulty": 1},
	{"id": "combo_10", "title": "Fazer combo x10", "metric": "best_combo", "target": 10, "reward": {"type": "keys", "amount": 1}, "difficulty": 2},
	{"id": "equip_skin", "title": "Equipar uma skin diferente", "metric": "skin_equips", "target": 1, "reward": {"type": "fragments", "amount": 10}, "difficulty": 1},
	{"id": "boss_run", "title": "Jogar Boss Mode 1 vez", "metric": "boss_runs", "target": 1, "reward": {"type": "coins", "amount": 360}, "difficulty": 1},
	{"id": "boss_win", "title": "Vencer Boss Mode 1 vez", "metric": "boss_wins", "target": 1, "reward": {"type": "gems", "amount": 16}, "difficulty": 3},
	{"id": "offline_claim", "title": "Coletar recompensa offline", "metric": "offline_claims", "target": 1, "reward": {"type": "coins", "amount": 220}, "difficulty": 1},
	{"id": "store_buy", "title": "Comprar algo na loja", "metric": "store_purchases", "target": 1, "reward": {"type": "gems", "amount": 6}, "difficulty": 1},
	{"id": "watch_ad", "title": "Usar anuncio 1 vez", "metric": "ads_watched", "target": 1, "reward": {"type": "coins", "amount": 240}, "difficulty": 1},
	{"id": "crit_5", "title": "Fazer 5 criticos", "metric": "criticals", "target": 5, "reward": {"type": "profile_xp", "amount": 90}, "difficulty": 1},
	{"id": "skin_effect_10", "title": "Quebrar 10 aneis com efeito de skin", "metric": "skin_effects", "target": 10, "reward": {"type": "fragments", "amount": 18}, "difficulty": 2},
	{"id": "no_revive", "title": "Concluir uma fase sem revive", "metric": "no_revive_wins", "target": 1, "reward": {"type": "gems", "amount": 10}, "difficulty": 2}
]

const ACHIEVEMENTS = [
	{"id": "first_steps", "name": "Primeiros Passos", "description": "Jogue a primeira partida.", "category": "progresso", "required": 1, "metric": "runs_played", "reward": {"type": "coins", "amount": 250}, "rarity": "common"},
	{"id": "first_perfect", "name": "Primeiro Escape", "description": "Faca 1 escape perfeito.", "category": "perfect escape", "required": 1, "metric": "perfect_escapes", "reward": {"type": "gems", "amount": 8}, "rarity": "rare"},
	{"id": "ring_breaker_1", "name": "Quebrador de Aneis I", "description": "Destrua 50 aneis.", "category": "combate", "required": 50, "metric": "rings_destroyed", "reward": {"type": "coins", "amount": 500}, "rarity": "common"},
	{"id": "ring_breaker_2", "name": "Quebrador de Aneis II", "description": "Destrua 250 aneis.", "category": "combate", "required": 250, "metric": "rings_destroyed", "reward": {"type": "keys", "amount": 1}, "rarity": "rare"},
	{"id": "ring_breaker_3", "name": "Quebrador de Aneis III", "description": "Destrua 1000 aneis.", "category": "combate", "required": 1000, "metric": "rings_destroyed", "reward": {"type": "chest", "chest": "rare", "amount": 1}, "rarity": "epic"},
	{"id": "perfect_hunter", "name": "Cacador de Perfect", "description": "Faca 25 escapes perfeitos.", "category": "perfect escape", "required": 25, "metric": "perfect_escapes", "reward": {"type": "gems", "amount": 35}, "rarity": "epic"},
	{"id": "diamond_miner", "name": "Garimpeiro de Diamantes", "description": "Ganhe 10 diamantes por Perfect Escape.", "category": "economia", "required": 10, "metric": "diamonds_found", "reward": {"type": "gems", "amount": 40}, "rarity": "rare"},
	{"id": "starter_collector", "name": "Colecionador Iniciante", "description": "Desbloqueie 5 skins.", "category": "colecao", "required": 5, "metric": "skins_unlocked", "reward": {"type": "chest", "chest": "common", "amount": 1}, "rarity": "rare"},
	{"id": "rare_collector", "name": "Colecionador Raro", "description": "Desbloqueie 5 skins raras.", "category": "skins", "required": 5, "metric": "skins_unlocked", "reward": {"type": "chest", "chest": "rare", "amount": 1}, "rarity": "epic"},
	{"id": "epic_luck", "name": "Sorte Epica", "description": "Obtenha 1 skin epica.", "category": "skins", "required": 1, "metric": "skins_unlocked", "reward": {"type": "gems", "amount": 30}, "rarity": "epic"},
	{"id": "legend_awake", "name": "Lenda Desperta", "description": "Obtenha 1 skin lendaria.", "category": "skins", "required": 1, "metric": "skins_unlocked", "reward": {"type": "chest", "chest": "epic", "amount": 1}, "rarity": "legendary"},
	{"id": "chest_opener_1", "name": "Abridor de Baus I", "description": "Abra 5 baus.", "category": "baus", "required": 5, "metric": "chests_opened", "reward": {"type": "coins", "amount": 600}, "rarity": "common"},
	{"id": "chest_opener_2", "name": "Abridor de Baus II", "description": "Abra 25 baus.", "category": "baus", "required": 25, "metric": "chests_opened", "reward": {"type": "keys", "amount": 2}, "rarity": "rare"},
	{"id": "survivor", "name": "Sobrevivente", "description": "Venca uma fase sem usar revive.", "category": "progresso", "required": 1, "metric": "no_revive_wins", "reward": {"type": "gems", "amount": 12}, "rarity": "rare"},
	{"id": "fearless", "name": "Sem Medo", "description": "Venca 5 fases sem usar revive.", "category": "progresso", "required": 5, "metric": "no_revive_wins", "reward": {"type": "chest", "chest": "epic", "amount": 1}, "rarity": "epic"},
	{"id": "stage_20_champion", "name": "Campeao dos 50 Estagios", "description": "Conclua todas as 50 fases principais.", "category": "especiais", "required": 50, "metric": "highest_phase", "reward": {"type": "skin", "skin_id": "cosmic_champion"}, "rarity": "special"},
	{"id": "first_duel", "name": "Primeiro Boss", "description": "Enfrente o Boss mensal pela primeira vez.", "category": "boss", "required": 1, "metric": "boss_runs", "reward": {"type": "coins", "amount": 300}, "rarity": "common"},
	{"id": "boss_victory", "name": "Vitoria Normal", "description": "Venca o Boss mensal no nivel Normal.", "category": "boss", "required": 1, "metric": "boss_wins", "reward": {"type": "gems", "amount": 20}, "rarity": "rare"},
	{"id": "impossible", "name": "Impossivel Vencido", "description": "Venca o Boss mensal no nivel Impossivel.", "category": "boss", "required": 5, "metric": "boss_wins", "reward": {"type": "legendaryKeys", "amount": 1}, "rarity": "ultimate"},
	{"id": "first_compete", "name": "Primeiro Competir", "description": "Jogue uma competicao da Liga Neon.", "category": "liga", "required": 1, "metric": "phase_wins", "reward": {"type": "coins", "amount": 400}, "rarity": "common"},
	{"id": "neon_streak", "name": "Sequencia Neon", "description": "Venca 5 competicoes seguidas.", "category": "liga", "required": 5, "metric": "phase_wins", "reward": {"type": "chest", "chest": "rare", "amount": 1}, "rarity": "epic"},
	{"id": "inf_survive_1", "name": "Pulso Infinito", "description": "Sobreviva 1 minuto no Modo Infinito.", "category": "infinito", "required": 60, "metric": "infinite_best_seconds", "reward": {"type": "skin", "skin_id": "infinite_pulse"}, "rarity": "common"},
	{"id": "inf_survive_5", "name": "Eclipse Neon", "description": "Sobreviva 5 minutos no Modo Infinito.", "category": "infinito", "required": 300, "metric": "infinite_best_seconds", "reward": {"type": "skin", "skin_id": "neon_eclipse"}, "rarity": "epic"},
	{"id": "inf_survive_20", "name": "Omega Infinito", "description": "Sobreviva 20 minutos no Modo Infinito.", "category": "infinito", "required": 1200, "metric": "infinite_best_seconds", "reward": {"type": "skin", "skin_id": "omega_infinity"}, "rarity": "ultimate"},
	{"id": "inf_rings_100", "name": "Prisma Sem Fim", "description": "Quebre 100 aneis em uma run infinita.", "category": "infinito", "required": 100, "metric": "infinite_best_rings", "reward": {"type": "skin", "skin_id": "endless_prism"}, "rarity": "epic"},
	{"id": "inf_level_10", "name": "Roguelike Neon II", "description": "Alcance nivel 10 em uma run infinita.", "category": "infinito", "required": 10, "metric": "infinite_best_level", "reward": {"type": "gems", "amount": 100}, "rarity": "legendary"}
]

const WHEEL_REWARDS = [
	{"type": "coins", "amount": 180, "label": "+180 moedas"},
	{"type": "coins", "amount": 420, "label": "+420 moedas"},
	{"type": "gems", "amount": 6, "label": "+6 diamantes"},
	{"type": "gems", "amount": 14, "label": "+14 diamantes"},
	{"type": "keys", "amount": 1, "label": "+1 chave"},
	{"type": "chest", "chest": "common", "amount": 1, "label": "+1 bau comum"},
	{"type": "chest", "chest": "rare", "amount": 1, "label": "+1 bau raro"},
	{"type": "fragments", "amount": 20, "label": "+20 fragmentos"},
	{"type": "profile_xp", "amount": 120, "label": "+120 XP"},
	{"type": "chest", "chest": "epic", "amount": 1, "label": "+1 bau epico"}
]

var feature = "missions"
var content
var message_label
var title_node

func setup(payload):
	feature = String(payload.get("feature", feature))
	if is_node_ready():
		_rebuild()

func _ready():
	SaveSystem.save_changed.connect(func(_save): _rebuild())
	_build_shell()
	_rebuild()

func _build_shell():
	NeonUI.add_main_background(self)
	var header = NeonUI.header(self, _title(), 56, 18, 18, 28)
	header.back.pressed.connect(func(): get_tree().current_scene.go_to("menu"))
	title_node = header.box.get_child(1)
	message_label = NeonUI.label("", 13, Color("#00ff88"), HORIZONTAL_ALIGNMENT_CENTER)
	header.box.add_child(message_label)
	content = NeonUI.make_scroll(self, 136, 16, 16, 16, 12)

func _rebuild():
	if content == null:
		return
	title_node.text = _title()
	message_label.text = ""
	NeonUI.clear_children(content)
	match feature:
		"missions":
			_build_missions()
		"event":
			_build_event()
		"wheel":
			_build_wheel()
		"daily_reward":
			_build_daily_reward()
		"boss":
			_build_boss()
		"league":
			_build_league()
		"achievements":
			_build_achievements()
		"settings":
			_build_settings()
		_:
			_build_missions()

func _build_missions():
	content.add_child(NeonUI.label("Rotacao diaria • %s" % TimeSystem.day_key(), 13, Color("#ffffff99")))
	for mission in _daily_missions_for_today():
		var value = _metric_value(mission.metric)
		var done = value >= int(mission.target)
		var claim_key = "%s_%s" % [TimeSystem.day_key(), mission.id]
		var claimed = bool(SaveSystem.get_save().timed.daily_mission_claims.get(claim_key, false))
		_add_mission_card(mission, value, done, claimed, func(): _claim_daily_mission(mission, claim_key), true)

func _build_event():
	var event = _weekly_event()
	content.add_child(_hero(event.name, event.description, "res://assets/ui/ui_event.png", Color(event.color)))
	content.add_child(NeonUI.label("Tempo restante: %s • %s" % [TimeSystem.format_timer(TimeSystem.seconds_until_next_day()), TimeSystem.week_key()], 13, Color("#ffffff99")))
	content.add_child(_simple_card("Premio principal", _reward_text(event.grand_reward), "res://assets/ui/ui_daily_reward.png", Color("#ffd700")))
	for mission in event.missions:
		var value = _metric_value(mission.metric)
		var done = value >= int(mission.target)
		var claim_key = "%s_%s" % [TimeSystem.week_key(), mission.id]
		var claimed = bool(SaveSystem.get_save().timed.event_mission_claims.get(claim_key, false))
		_add_mission_card(mission, value, done, claimed, func(): _claim_event_mission(mission, claim_key), false, Color(event.color))
	var grand_claimed = String(SaveSystem.get_save().timed.event_grand_claimed_week) == TimeSystem.week_key()
	var grand = NeonUI.main_button("COLETAR PREMIO PRINCIPAL" if not grand_claimed else "JA COLETADO", Color(event.color), Color("#0088ff"), 54)
	grand.disabled = grand_claimed
	grand.pressed.connect(func():
		SaveSystem.grant_reward(event.grand_reward)
		SaveSystem.get_save().timed.event_grand_claimed_week = TimeSystem.week_key()
		SaveSystem.save_game()
		AudioManager.play_sfx("button_confirm")
	)
	content.add_child(grand)

func _build_wheel():
	content.add_child(NeonUI.label("Giro gratis diario e ate 2 giros com anuncio.", 13, Color("#ffffff99")))
	var shell = CenterContainer.new()
	content.add_child(shell)
	var wheel = PanelContainer.new()
	wheel.custom_minimum_size = Vector2(292, 292)
	wheel.add_theme_stylebox_override("panel", NeonUI.neon_box(Color("#ffffff10"), Color("#00f0ffaa"), 4, 146, 0.65))
	shell.add_child(wheel)
	var center = CenterContainer.new()
	wheel.add_child(center)
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	center.add_child(grid)
	for reward in WHEEL_REWARDS:
		var segment = PanelContainer.new()
		segment.custom_minimum_size = Vector2(82, 48)
		segment.add_theme_stylebox_override("panel", NeonUI.flat(Color("#00f0ff33"), Color("#00f0ff"), 1, 10))
		grid.add_child(segment)
		segment.add_child(NeonUI.label(reward.label, 9, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))
	var result = _simple_card("Toque para girar", "Recompensas da roleta aparecem aqui.", "res://assets/ui/ui_wheel.png", Color("#00f0ff"))
	content.add_child(result)
	var save = SaveSystem.get_save()
	var free = NeonUI.main_button("GIRAR" if not bool(save.timed.wheel_free_used) else "GIRO GRATIS USADO", Color("#00f0ff"), Color("#0088ff"), 54)
	free.disabled = bool(save.timed.wheel_free_used)
	free.pressed.connect(_spin_wheel.bind(false))
	content.add_child(free)
	var ad = NeonUI.main_button("GIRAR NOVAMENTE COM ANUNCIO (%d/2)" % int(save.timed.wheel_ad_spins_used), Color("#ffd700"), Color("#ff8800"), 54)
	ad.disabled = int(save.timed.wheel_ad_spins_used) >= 2
	ad.pressed.connect(_spin_wheel.bind(true))
	content.add_child(ad)

func _build_daily_reward():
	content.add_child(_hero("Recompensa diaria", "Entre todo dia para coletar seu pacote.", "res://assets/ui/ui_daily_reward.png", Color("#ffd700")))
	var reward_box = PanelContainer.new()
	reward_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	reward_box.add_theme_stylebox_override("panel", NeonUI.neon_box(Color("#ffffff12"), Color("#ffd70088"), 1, 16, 0.3))
	content.add_child(reward_box)
	var box = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	reward_box.add_child(box)
	box.add_child(NeonUI.icon("res://assets/ui/ui_daily_reward.png", 72))
	box.add_child(NeonUI.label("Coletar recompensa de hoje" if SaveSystem.daily_reward_available() else "Ja coletado hoje", 24, Color("#ffd700"), HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(NeonUI.label("💎 18\n💰 350\n🔑 1", 22, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))
	var claim = NeonUI.main_button("COLETAR" if SaveSystem.daily_reward_available() else "VOLTE AMANHA", Color("#00f0ff"), Color("#0088ff"), 54)
	claim.disabled = not SaveSystem.daily_reward_available()
	claim.pressed.connect(_claim_daily)
	box.add_child(claim)

func _build_boss():
	var save = SaveSystem.get_save()
	var unlocked = int(save.lifetime_stats.highest_phase) >= 5 or int(save.profile_level) >= 5
	content.add_child(_hero("BOSS MODE", "Boss do mes: Fenix Solar", "res://assets/ui/ui_boss.png", Color("#ff0055")))
	if not unlocked:
		content.add_child(_simple_card("Bloqueado", "Complete a fase 5 ou alcance nivel de perfil 5 para desbloquear.", "res://assets/ui/ui_locked.png", Color("#ffd700")))
	content.add_child(_simple_card("Fenix Solar", "Tema: solar/vermelho\nUm Boss que renasce em aneis solidos.\nPassiva: Quebras solidas dao mais moedas ao Boss.", "res://assets/images/skins/neon_phoenix.png", Color("#ff0055")))
	content.add_child(_simple_card("Progresso", "Nivel atual: Normal\nVitorias hoje: %d/5\nMelhor nivel do mes: Nenhum\nReset diario: %s" % [int(save.lifetime_stats.get("boss_wins", 0)), TimeSystem.format_timer(TimeSystem.seconds_until_next_day())], "res://assets/ui/ui_xp.png", Color("#00f0ff")))
	var fight = NeonUI.main_button("ENFRENTAR", Color("#00f0ff"), Color("#0088ff"), 54)
	fight.disabled = not unlocked
	fight.pressed.connect(func():
		save.lifetime_stats.boss_runs = int(save.lifetime_stats.get("boss_runs", 0)) + 1
		SaveSystem.save_game()
		get_tree().current_scene.go_to("game", {"phase": max(5, int(save.current_phase)), "mode": "phase"})
	)
	content.add_child(fight)

func _build_league():
	var save = SaveSystem.get_save()
	var stats = save.lifetime_stats
	var trophies = max(80, int(stats.highest_phase) * 32 + int(stats.rings_destroyed) / 5 + int(stats.phase_wins) * 18)
	content.add_child(_summary_row([["Sua posicao", "#87/201"], ["Trofeus", str(trophies)], ["Temporada", "28d"]]))
	content.add_child(_simple_card("Bronze", "%d trofeus ate Prata\nSequencia: 0 • Melhor: 0" % max(0, 300 - trophies), "res://assets/ui/ui_league_neon.png", Color("#00ff88"), "COMPETIR", "game"))
	var podium = HBoxContainer.new()
	podium.add_theme_constant_override("separation", 8)
	content.add_child(podium)
	for item in [["🥇", "NeonFox", "10480"], ["🥈", "RingBreaker", "9820"], ["🥉", "LunaBot", "9340"]]:
		var card = PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_stylebox_override("panel", NeonUI.flat(Color("#ffffff10"), Color("#ffd70066"), 1, 10))
		podium.add_child(card)
		var box = VBoxContainer.new()
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(box)
		box.add_child(NeonUI.label(item[0], 24, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))
		box.add_child(NeonUI.label(item[1], 12, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))
		box.add_child(NeonUI.label("%s 🏆" % item[2], 12, Color("#ffd700"), HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_simple_card("Recompensa estimada", "Moedas, fragmentos e chave comum.\nFaltam 120 trofeus para subir uma posicao.", "res://assets/ui/ui_achievements.png", Color("#00ff88")))
	for i in range(12):
		var name = ["Voce", "NovaPulse", "RiftCore", "CyberPanda", "VoidCat", "PlasmaPig", "FrostByte", "FireOrb", "LuckySlime", "GhostRunner", "DiamondEye", "SolarKid"][i]
		content.add_child(_league_row(i + 1, name, max(0, trophies + 420 - i * 88), i == 0))

func _build_achievements():
	var completed = 0
	for achievement in ACHIEVEMENTS:
		if _metric_value(achievement.metric) >= int(achievement.required):
			completed += 1
	content.add_child(NeonUI.label("%d/%d concluidas • %d pendentes" % [completed, ACHIEVEMENTS.size(), _pending_achievements()], 14, Color("#ffffffaa")))
	content.add_child(_achievement_champion_box())
	for achievement in ACHIEVEMENTS:
		_add_achievement_card(achievement)

func _build_settings():
	var save = SaveSystem.get_save()
	content.add_child(_profile_card(save))
	content.add_child(_account_card(save))
	content.add_child(_toggle_card("SOM", [["Musica", "music"], ["Efeitos", "sound"], ["Master", "sound"]]))
	content.add_child(_options_card("DESEMPENHO", "FPS do jogo", ["30 FPS", "45 FPS", "60 FPS", "90 FPS", "120 FPS"]))
	content.add_child(_options_card("IDIOMA", "Selecione o idioma", ["Português", "English", "Español", "Français", "Deutsch", "日本語"]))
	content.add_child(_simple_card("LIGA NEON", "Posicao atual: #87/201\nDivisao atual: Bronze\nTrofeus: 80\nMelhor divisao: Bronze", "res://assets/ui/ui_league_neon.png", Color("#ffd700"), "ABRIR LIGA NEON", "league"))
	content.add_child(_simple_card("ESTATISTICAS", "Partidas: %d\nAneis destruidos: %d\nEscapes perfeitos: %d\nDiamantes encontrados: %d\nBaus abertos: %d\nSkins desbloqueadas: %d" % [save.lifetime_stats.runs_played, save.lifetime_stats.rings_destroyed, save.lifetime_stats.perfect_escapes, save.lifetime_stats.diamonds_found, save.lifetime_stats.chests_opened, save.unlocked_skins.size()], "res://assets/ui/ui_profile.png", Color("#00f0ff")))

func _add_mission_card(mission, value, done, claimed, action, show_ad_buttons, color = Color("#00f0ff")):
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#00ff8818") if done and not claimed else Color("#ffffff12"), Color("#00ff88aa") if done and not claimed else Color("#ffffff24"), 1, 12))
	content.add_child(panel)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	panel.add_child(box)
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	box.add_child(header)
	var title_box = VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_box)
	title_box.add_child(NeonUI.label(mission.title, 17, Color.WHITE))
	title_box.add_child(NeonUI.label(_reward_text(mission.reward), 13, Color("#ffd700")))
	header.add_child(NeonUI.label("★".repeat(int(mission.difficulty)), 13, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_RIGHT))
	box.add_child(NeonUI.progress_bar(value, int(mission.target), color, 22))
	var actions = HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	box.add_child(actions)
	if done and not claimed:
		var claim = NeonUI.main_button("COLETAR", Color("#00ff88"), Color("#008855"), 38)
		claim.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		claim.pressed.connect(action)
		actions.add_child(claim)
	else:
		var status = NeonUI.label("Coletado" if claimed else "Em progresso", 13, Color("#ffffff88"))
		status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		actions.add_child(status)
	if show_ad_buttons and not claimed:
		var reroll = NeonUI.ghost_button("Reroll 📺", Color("#ffffff66"), 36)
		reroll.pressed.connect(func(): _ad_action_message("Missao atualizada."))
		actions.add_child(reroll)
		var boost = NeonUI.ghost_button("+25% 📺", Color("#ffffff66"), 36)
		boost.pressed.connect(func(): _ad_action_message("Progresso acelerado."))
		actions.add_child(boost)

func _add_achievement_card(achievement):
	var value = _metric_value(achievement.metric)
	var done = value >= int(achievement.required)
	var claimed = achievement.id in SaveSystem.get_save().achievement_claims
	var color = _rarity_color(achievement.rarity)
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#ffffff12"), Color(color, 0.54), 1, 12))
	content.add_child(panel)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)
	var title_box = VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title_box)
	title_box.add_child(NeonUI.label(achievement.name, 18, Color.WHITE))
	title_box.add_child(NeonUI.label(String(achievement.category).to_upper(), 11, color))
	row.add_child(NeonUI.label(_reward_text(achievement.reward), 12, Color("#ffd700"), HORIZONTAL_ALIGNMENT_RIGHT))
	box.add_child(NeonUI.label(achievement.description, 13, Color("#ffffffbb")))
	box.add_child(NeonUI.progress_bar(value, int(achievement.required), color, 20))
	var footer = HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	box.add_child(footer)
	var status = NeonUI.label("Coletado" if claimed else "Disponivel" if done else "Em progresso", 12, Color("#ffffff88"))
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(status)
	if done and not claimed:
		var claim = NeonUI.main_button("COLETAR", Color("#00ff88"), Color("#008855"), 36)
		claim.pressed.connect(func(): _claim_achievement(achievement))
		footer.add_child(claim)

func _hero(title, text, icon_path, color):
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color(color, 0.18), Color(color, 0.78), 1, 14))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	row.add_child(NeonUI.icon(icon_path, 60))
	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(box)
	box.add_child(NeonUI.label(title, 22, Color.WHITE))
	box.add_child(NeonUI.label(text, 13, Color("#ffffffbb")))
	return panel

func _simple_card(title, text, icon_path, color, button_text = "", route = ""):
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#ffffff12"), Color(color, 0.42), 1, 12))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	row.add_child(NeonUI.icon(icon_path, 42))
	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(box)
	box.add_child(NeonUI.label(title, 17, Color.WHITE))
	box.add_child(NeonUI.label(text, 12, Color("#ffffffaa")))
	if button_text != "":
		var button = NeonUI.main_button(button_text, color, color.darkened(0.28), 42)
		button.custom_minimum_size.x = 108
		button.pressed.connect(func(): get_tree().current_scene.go_to(route))
		row.add_child(button)
	return panel

func _summary_row(items):
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	for item in items:
		var panel = PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#ffffff12"), Color("#00f0ff44"), 1, 12))
		row.add_child(panel)
		var box = VBoxContainer.new()
		panel.add_child(box)
		box.add_child(NeonUI.label(item[0], 11, Color("#ffffff88")))
		box.add_child(NeonUI.label(item[1], 18, Color.WHITE))
	return row

func _league_row(position, name, trophies, is_player):
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#00ff8820") if is_player else Color("#ffffff10"), Color("#00ff88") if is_player else Color("#ffffff22"), 1, 10))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)
	row.add_child(NeonUI.label("#%d" % position, 14, Color("#00f0ff")))
	row.add_child(NeonUI.icon("res://assets/ui/ui_profile.png", 34))
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	info.add_child(NeonUI.label("%s%s" % [name, " (Voce)" if is_player else ""], 14, Color.WHITE))
	info.add_child(NeonUI.label("Neon Azul • Fase %d • Comp %dV" % [max(1, int(trophies / 185)), max(0, int(trophies / 18))], 11, Color("#ffffff99")))
	row.add_child(NeonUI.label("%d 🏆\nBronze" % trophies, 12, Color("#ffd700"), HORIZONTAL_ALIGNMENT_RIGHT))
	return panel

func _achievement_champion_box():
	var progress = _metric_value("highest_phase")
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#ffffff12"), Color("#ffd70066"), 1, 12))
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(NeonUI.label("Campeao dos 50 Estagios", 14, Color("#ffd700")))
	box.add_child(NeonUI.progress_bar(progress, 50, Color("#ffd700"), 20))
	return panel

func _profile_card(save):
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#ffffff12"), Color("#ffffff22"), 1, 12))
	var box = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	box.add_child(NeonUI.icon("res://assets/ui/ui_profile.png", 86))
	box.add_child(NeonUI.label(String(save.nickname), 20, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))
	var resources = HBoxContainer.new()
	resources.add_theme_constant_override("separation", 8)
	resources.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(resources)
	resources.add_child(NeonUI.resource_badge("res://assets/ui/ui_coin.png", str(save.coins)))
	resources.add_child(NeonUI.resource_badge("res://assets/ui/ui_gem.png", str(save.gems)))
	resources.add_child(NeonUI.resource_badge("res://assets/ui/ui_key.png", str(save.keys)))
	return panel

func _account_card(save):
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#ffffff12"), Color("#ffffff22"), 1, 12))
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	box.add_child(NeonUI.label("CONTA", 13, Color("#ffffff88")))
	box.add_child(NeonUI.label("Nivel %d" % int(save.profile_level), 24, Color("#ffd700")))
	box.add_child(NeonUI.progress_bar(int(save.profile_xp), GameData.get_profile_xp_needed(int(save.profile_level)), Color("#00f0ff"), 20))
	return panel

func _toggle_card(title, toggles):
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#ffffff12"), Color("#ffffff22"), 1, 12))
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(NeonUI.label(title, 13, Color("#ffffff88")))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	box.add_child(row)
	for item in toggles:
		var key = item[1]
		var enabled = bool(SaveSystem.get_save().settings.get(key, true))
		var button = NeonUI.main_button("%s %s" % [item[0], "ON" if enabled else "OFF"], Color("#00f0ff") if enabled else Color("#ffffff33"), Color("#0088ff"), 42)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func(): SaveSystem.set_setting(key, not bool(SaveSystem.get_save().settings.get(key, true))))
		row.add_child(button)
	return panel

func _options_card(title, subtitle, options):
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#ffffff12"), Color("#ffffff22"), 1, 12))
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(NeonUI.label(title, 13, Color("#ffffff88")))
	box.add_child(NeonUI.label(subtitle, 14, Color.WHITE))
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)
	for option in options:
		var button = NeonUI.ghost_button(option, Color("#00ff88"), 42)
		grid.add_child(button)
	return panel

func _claim_daily_mission(mission, claim_key):
	SaveSystem.grant_reward(mission.reward)
	SaveSystem.get_save().timed.daily_mission_claims[claim_key] = true
	SaveSystem.save_game()
	message_label.text = _reward_text(mission.reward)
	AudioManager.play_sfx("button_confirm")

func _claim_event_mission(mission, claim_key):
	SaveSystem.grant_reward(mission.reward)
	SaveSystem.get_save().timed.event_mission_claims[claim_key] = true
	SaveSystem.save_game()
	message_label.text = _reward_text(mission.reward)
	AudioManager.play_sfx("button_confirm")

func _claim_achievement(achievement):
	SaveSystem.grant_reward(achievement.reward)
	if not (achievement.id in SaveSystem.get_save().achievement_claims):
		SaveSystem.get_save().achievement_claims.append(achievement.id)
	SaveSystem.save_game()
	AudioManager.play_sfx("button_confirm")

func _claim_daily():
	var result = SaveSystem.claim_daily_reward()
	message_label.text = result.get("message", "")
	AudioManager.play_sfx("diamond_gain" if result.get("ok", false) else "button_error")
	_rebuild()
	message_label.text = result.get("message", "")

func _spin_wheel(use_ad):
	var result = SaveSystem.spin_wheel(use_ad)
	message_label.text = result.get("message", "")
	AudioManager.play_sfx("coin_gain" if result.get("ok", false) else "button_error")
	_rebuild()
	message_label.text = result.get("message", "")

func _ad_action_message(text):
	SaveSystem.record_ad_use()
	message_label.text = text
	AudioManager.play_sfx("button_confirm")

func _weekly_event():
	var events = [
		{"id": "neon", "name": "Evento Neon", "description": "Ritmo alto, combos e baus brilhantes.", "bonus": "+10% moedas da rodada.", "color": "#00f0ff", "grand_reward": {"type": "chest", "chest": "rare", "amount": 1}, "missions": [
			{"id": "neon_rings", "title": "Destruir 500 aneis", "metric": "rings_destroyed", "target": 500, "reward": {"type": "coins", "amount": 900}, "difficulty": 3},
			{"id": "neon_combo", "title": "Fazer combo x10", "metric": "best_combo", "target": 10, "reward": {"type": "gems", "amount": 18}, "difficulty": 2},
			{"id": "neon_chests", "title": "Abrir 10 baus", "metric": "chests_opened", "target": 10, "reward": {"type": "keys", "amount": 2}, "difficulty": 3}
		]},
		{"id": "frost", "name": "Evento Gelado", "description": "Congelar, desacelerar e coletar fragmentos.", "bonus": "Mais chance de slow/freeze.", "color": "#9be8ff", "grand_reward": {"type": "fragments", "amount": 55}, "missions": [
			{"id": "frost_perfect", "title": "Fazer 35 Perfect Escapes", "metric": "perfect_escapes", "target": 35, "reward": {"type": "gems", "amount": 22}, "difficulty": 3},
			{"id": "frost_rings", "title": "Destruir 420 aneis", "metric": "rings_destroyed", "target": 420, "reward": {"type": "fragments", "amount": 30}, "difficulty": 2},
			{"id": "frost_chests", "title": "Abrir 6 baus", "metric": "chests_opened", "target": 6, "reward": {"type": "keys", "amount": 1}, "difficulty": 2}
		]},
		{"id": "boss_rush", "name": "Evento Boss Rush", "description": "Duelos mais valiosos.", "bonus": "Recompensas melhores no Boss Mode.", "color": "#ff0055", "grand_reward": {"type": "legendaryKeys", "amount": 1}, "missions": [
			{"id": "boss_runs", "title": "Jogar 5 Boss Modes", "metric": "boss_runs", "target": 5, "reward": {"type": "coins", "amount": 1400}, "difficulty": 2},
			{"id": "boss_wins", "title": "Vencer 3 Boss Modes", "metric": "boss_wins", "target": 3, "reward": {"type": "chest", "chest": "rare", "amount": 1}, "difficulty": 3},
			{"id": "boss_crits", "title": "Fazer 25 criticos", "metric": "criticals", "target": 25, "reward": {"type": "gems", "amount": 18}, "difficulty": 2}
		]}
	]
	return events[_seeded_index(TimeSystem.week_key(), events.size())]

func _daily_missions_for_today():
	var start = _seeded_index(TimeSystem.day_key(), DAILY_MISSIONS.size())
	var output = []
	for offset in range(4):
		output.append(DAILY_MISSIONS[(start + offset * 7) % DAILY_MISSIONS.size()])
	return output

func _metric_value(metric):
	var save = SaveSystem.get_save()
	if metric == "skins_unlocked":
		return save.unlocked_skins.size()
	return int(save.lifetime_stats.get(metric, 0))

func _pending_achievements():
	var count = 0
	for achievement in ACHIEVEMENTS:
		if _metric_value(achievement.metric) >= int(achievement.required) and not (achievement.id in SaveSystem.get_save().achievement_claims):
			count += 1
	return count

func _reward_text(reward):
	match String(reward.get("type", "")):
		"coins":
			return "💰 %d" % int(reward.amount)
		"gems":
			return "💎 %d" % int(reward.amount)
		"keys":
			return "🔑 %d" % int(reward.amount)
		"legendaryKeys", "legendary_keys":
			return "🗝️ %d" % int(reward.amount)
		"profile_xp", "profileXp":
			return "XP %d" % int(reward.amount)
		"fragments":
			return "🧩 %d" % int(reward.amount)
		"chest":
			return "🎁 Bau %s" % String(reward.get("chest", "common"))
		"skin":
			return "Skin %s" % String(reward.get("skin_id", ""))
	return "Recompensa"

func _rarity_color(rarity):
	if rarity == "special":
		return Color.WHITE
	return Color(GameData.get_skin_rarity_color(rarity))

func _seeded_index(seed, count):
	var hash = 0
	for i in range(seed.length()):
		hash = int(hash * 31 + seed.unicode_at(i)) & 0x7fffffff
	return hash % max(1, count)

func _title():
	match feature:
		"missions":
			return "MISSOES DIARIAS"
		"event":
			return "EVENTO"
		"wheel":
			return "ROLETA"
		"daily_reward":
			return "RECOMPENSA DIARIA"
		"boss":
			return "BOSS"
		"league":
			return "LIGA NEON"
		"achievements":
			return "CONQUISTAS"
		"settings":
			return "PERFIL"
	return "MENU"

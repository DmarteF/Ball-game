extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

const DAILY_MISSIONS = [
	{"id": "rings_50", "title": "Destruir 50 aneis", "metric": "rings_destroyed", "target": 50, "reward": "+260 moedas"},
	{"id": "rings_150", "title": "Destruir 150 aneis", "metric": "rings_destroyed", "target": 150, "reward": "+1 chave"},
	{"id": "perfect_3", "title": "Fazer 3 Perfect Escapes", "metric": "perfect_escapes", "target": 3, "reward": "+5 diamantes"},
	{"id": "perfect_10", "title": "Fazer 10 Perfect Escapes", "metric": "perfect_escapes", "target": 10, "reward": "+14 diamantes"},
	{"id": "runs_3", "title": "Jogar 3 partidas", "metric": "runs_played", "target": 3, "reward": "+70 XP"},
	{"id": "runs_5", "title": "Jogar 5 partidas", "metric": "runs_played", "target": 5, "reward": "+420 moedas"},
	{"id": "win_1", "title": "Vencer 1 fase", "metric": "phase_wins", "target": 1, "reward": "+8 diamantes"},
	{"id": "win_3", "title": "Vencer 3 fases", "metric": "phase_wins", "target": 3, "reward": "+1 bau raro"},
	{"id": "chest_1", "title": "Abrir 1 bau", "metric": "chests_opened", "target": 1, "reward": "+12 fragmentos"},
	{"id": "chest_3", "title": "Abrir 3 baus", "metric": "chests_opened", "target": 3, "reward": "+1 chave"},
	{"id": "coins_500", "title": "Ganhar 500 moedas da rodada", "metric": "run_coins", "target": 500, "reward": "+320 moedas"},
	{"id": "coins_2000", "title": "Ganhar 2.000 moedas da rodada", "metric": "run_coins", "target": 2000, "reward": "+12 diamantes"},
	{"id": "gems_5", "title": "Ganhar 5 diamantes", "metric": "diamonds_found", "target": 5, "reward": "+120 XP"},
	{"id": "temp_upgrades_3", "title": "Usar 3 upgrades temporarios", "metric": "run_upgrades", "target": 3, "reward": "+260 moedas"},
	{"id": "combo_5", "title": "Fazer combo x5", "metric": "best_combo", "target": 5, "reward": "+5 diamantes"},
	{"id": "combo_10", "title": "Fazer combo x10", "metric": "best_combo", "target": 10, "reward": "+1 chave"},
	{"id": "equip_skin", "title": "Equipar uma skin diferente", "metric": "skin_equips", "target": 1, "reward": "+10 fragmentos"},
	{"id": "boss_run", "title": "Jogar Boss Mode 1 vez", "metric": "boss_runs", "target": 1, "reward": "+360 moedas"},
	{"id": "boss_win", "title": "Vencer Boss Mode 1 vez", "metric": "boss_wins", "target": 1, "reward": "+16 diamantes"},
	{"id": "offline_claim", "title": "Coletar recompensa offline", "metric": "offline_claims", "target": 1, "reward": "+220 moedas"},
	{"id": "store_buy", "title": "Comprar algo na loja simulada", "metric": "store_purchases", "target": 1, "reward": "+6 diamantes"},
	{"id": "watch_ad", "title": "Usar anuncio 1 vez", "metric": "ads_watched", "target": 1, "reward": "+240 moedas"},
	{"id": "crit_5", "title": "Fazer 5 criticos", "metric": "criticals", "target": 5, "reward": "+90 XP"},
	{"id": "skin_effect_10", "title": "Quebrar 10 aneis com efeito de skin", "metric": "skin_effects", "target": 10, "reward": "+18 fragmentos"},
	{"id": "no_revive", "title": "Concluir uma fase sem revive", "metric": "no_revive_wins", "target": 1, "reward": "+10 diamantes"}
]

const WHEEL_LABELS = ["+180 moedas", "+420 moedas", "+6 diamantes", "+14 diamantes", "+1 chave", "+1 bau comum", "+1 bau raro", "+20 fragmentos", "+120 XP", "+1 bau epico"]

var feature = "inventory"
var content
var wallet_label
var message_label
var title_label

func setup(payload):
	feature = String(payload.get("feature", feature))
	if is_node_ready():
		_rebuild()

func _ready():
	SaveSystem.save_changed.connect(_on_save_changed)
	_build_shell()
	_rebuild()

func _build_shell():
	var bg = ColorRect.new()
	bg.color = Color("#080818")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)
	var back = NeonUI.ghost_button("VOLTAR", Color("#00f0ff"), 42)
	back.pressed.connect(func(): get_tree().current_scene.go_to("menu"))
	header.add_child(back)
	title_label = NeonUI.label(_title(), 25, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_RIGHT)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_label)

	wallet_label = NeonUI.label("", 12, Color("#ffd700"), HORIZONTAL_ALIGNMENT_RIGHT)
	box.add_child(wallet_label)

	message_label = NeonUI.label("", 13, Color("#00ff88"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(message_label)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)

func _rebuild():
	if content == null:
		return
	title_label.text = _title()
	wallet_label.text = NeonUI.wallet_text(SaveSystem.get_save())
	message_label.text = ""
	NeonUI.clear_children(content)
	match feature:
		"inventory":
			_build_inventory()
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
			_build_inventory()

func _build_inventory():
	var save = SaveSystem.get_save()
	_add_hero("Inventario Neon", "Baus, efeitos, skins e recursos guardados.", "res://assets/ui/ui_inventory.png", Color("#ffd700"))
	var chest_text = "Comum %d  Raro %d  Epico %d  Lendario %d" % [
		save.inventory_chests.common,
		save.inventory_chests.rare,
		save.inventory_chests.epic,
		save.inventory_chests.legendary
	]
	_add_card("Baus", chest_text, "res://assets/ui/ui_chest_epic.png", Color("#ffd700"), "ABRIR BAUS", "chests")
	_add_card("Skins", "%d desbloqueadas de %d. Favorita: %s" % [save.unlocked_skins.size(), GameData.get_skins().size(), GameData.get_skin(save.equipped_skin).name], "res://assets/ui/ui_skins.png", Color("#ff4fd8"), "VER SKINS", "skins")
	_add_card("Efeitos", "%d efeitos liberados. Trilha equipada pela skin atual." % save.unlocked_effects.size(), "res://assets/ui/ui_effect.png", Color("#00f0ff"))

func _build_missions():
	var stats = SaveSystem.get_save().lifetime_stats
	_add_hero("Missoes Diarias", "Quatro objetivos do dia, selecionados pelo relogio local.", "res://assets/ui/ui_missions.png", Color("#ff8800"))
	for mission in _daily_missions_for_today():
		_add_progress_card(mission.title, int(stats.get(mission.metric, 0)), int(mission.target), mission.reward, Color("#ff8800"))

func _build_event():
	var timed = SaveSystem.get_timed_status()
	var points = int(SaveSystem.get_save().timed.event_points)
	_add_hero("Evento", "Fenda semanal %s" % timed.event_id, "res://assets/ui/ui_event.png", Color("#ff4fd8"))
	_add_progress_card("Energia da Fenda", points, 350, "Skin/fragmentos sazonais", Color("#ff4fd8"))
	_add_card("Tempo", "Evento atual: %s\nSemana local: %s" % [timed.event_id, timed.week_key], "res://assets/ui/ui_event.png", Color("#00f0ff"))
	_add_card("Progresso", "Pontuacao ja sobe ao jogar. Recompensas finais seguem a estrutura da branch main.", "res://assets/ui/ui_locked.png", Color("#9ca3af"))

func _build_wheel():
	var timed = SaveSystem.get_timed_status()
	_add_hero("Roleta", "Giro gratis diario e ate 2 giros com anuncio.", "res://assets/ui/ui_wheel.png", Color("#b000ff"))
	var wheel_panel = PanelContainer.new()
	wheel_panel.add_theme_stylebox_override("panel", NeonUI.neon_box(Color("#ffffff10"), Color("#00f0ffaa"), 4, 146, 0.5))
	wheel_panel.custom_minimum_size = Vector2(292, 292)
	content.add_child(wheel_panel)
	var center = CenterContainer.new()
	wheel_panel.add_child(center)
	var wheel_grid = GridContainer.new()
	wheel_grid.columns = 2
	wheel_grid.add_theme_constant_override("h_separation", 8)
	wheel_grid.add_theme_constant_override("v_separation", 8)
	center.add_child(wheel_grid)
	for label in WHEEL_LABELS:
		var segment = NeonUI.label(label, 10, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
		segment.custom_minimum_size = Vector2(112, 32)
		wheel_grid.add_child(segment)
	_add_card("Disponivel", "Reseta em %s" % TimeSystem.format_timer(timed.seconds_until_next_day), "res://assets/ui/ui_daily_reward.png", Color("#00f0ff"))
	var free = NeonUI.button("GIRO GRATIS", Color("#00f0ff"), 52)
	free.disabled = bool(SaveSystem.get_save().timed.wheel_free_used)
	free.pressed.connect(_spin_wheel.bind(false))
	content.add_child(free)
	var ad = NeonUI.ghost_button("GIRO COM ANUNCIO", Color("#ffd700"), 52)
	ad.disabled = int(SaveSystem.get_save().timed.wheel_ad_spins_used) >= 2
	ad.pressed.connect(_spin_wheel.bind(true))
	content.add_child(ad)

func _build_daily_reward():
	var available = SaveSystem.daily_reward_available()
	_add_hero("Recompensa Diaria", "Volte todo dia para moedas, diamantes e chaves.", "res://assets/ui/ui_daily_reward.png", Color("#ffd700"))
	_add_card("Pacote de hoje", "+350 moedas\n+18 diamantes\n+1 chave", "res://assets/ui/ui_key.png", Color("#ffd700"))
	var claim = NeonUI.button("COLETAR AGORA", Color("#00ff88"), 54)
	claim.disabled = not available
	claim.text = "JA COLETADO" if not available else "COLETAR AGORA"
	claim.pressed.connect(_claim_daily)
	content.add_child(claim)
	_add_card("Proximo reset", TimeSystem.format_timer(TimeSystem.seconds_until_next_day()), "res://assets/ui/ui_daily_reward.png", Color("#00f0ff"))

func _build_boss():
	var save = SaveSystem.get_save()
	var attempts = 3 - int(save.timed.boss_attempts)
	_add_hero("Boss", "Guardiao diario %s" % TimeSystem.boss_id_for_day(), "res://assets/ui/ui_boss.png", Color("#ff0055"))
	_add_card("Tentativas", "%d restantes hoje. Reset em %s" % [attempts, TimeSystem.format_timer(TimeSystem.seconds_until_next_day())], "res://assets/ui/ui_boss.png", Color("#ff0055"), "DESAFIAR", "game")
	_add_card("Recompensas", "Moedas, chaves, fragments e chance de skin rara. Combate especial fica preparado.", "res://assets/ui/ui_chest_rare.png", Color("#ffd700"))

func _build_league():
	var stats = SaveSystem.get_save().lifetime_stats
	_add_hero("Liga Neon", "Ranking local preparado para placares online futuros.", "res://assets/ui/ui_league_neon.png", Color("#00f0ff"))
	var score = int(stats.rings_destroyed) + int(stats.phase_wins) * 40 + int(stats.best_combo) * 8
	_add_card("#1  Voce", "%d pontos neon" % score, "res://assets/ui/ui_profile.png", Color("#ffd700"))
	_add_card("#2  NovaPulse", "%d pontos neon" % max(0, score - 75), "res://assets/ui/ui_league_neon.png", Color("#00f0ff"))
	_add_card("#3  RiftCore", "%d pontos neon" % max(0, score - 140), "res://assets/ui/ui_league_neon.png", Color("#b000ff"))

func _build_achievements():
	var stats = SaveSystem.get_save().lifetime_stats
	_add_hero("Conquistas", "Metas permanentes ligadas ao progresso do jogador.", "res://assets/ui/ui_achievements.png", Color("#ffffff"))
	_add_progress_card("Primeira fuga", int(stats.phase_wins), 1, "+100 moedas", Color("#00ff88"))
	_add_progress_card("100 aneis", int(stats.rings_destroyed), 100, "+1 chave", Color("#00f0ff"))
	_add_progress_card("Mestre do combo", int(stats.best_combo), 20, "+30 diamantes", Color("#ff4fd8"))

func _build_settings():
	var settings = SaveSystem.get_save().settings
	_add_hero("Configuracoes", "Som, musica e resposta de toque.", "res://assets/ui/ui_settings.png", Color("#9ca3af"))
	_add_toggle("Som", "sound", bool(settings.sound), "res://assets/ui/ui_mute_off.png")
	_add_toggle("Musica", "music", bool(settings.music), "res://assets/ui/ui_mute_on.png")
	_add_toggle("Vibracao", "haptics", bool(settings.haptics), "res://assets/ui/ui_settings.png")
	_add_card("Dados locais", "Progresso salvo em user://neon_idle_escape_godot_save.json", "res://assets/ui/ui_profile.png", Color("#00f0ff"))

func _add_hero(title, text, icon_path, color):
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color(color, 0.18), Color(color, 0.78), 1, 16))
	content.add_child(panel)
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)
	row.add_child(NeonUI.icon(icon_path, 60))
	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(box)
	box.add_child(NeonUI.label(title, 22, Color.WHITE))
	box.add_child(NeonUI.label(text, 13, Color("#ffffffbb")))

func _add_card(title, text, icon_path, color, button_text = "", route = ""):
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#121228dd"), Color(color, 0.58), 1, 12))
	content.add_child(panel)
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)
	row.add_child(NeonUI.icon(icon_path, 42))
	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(box)
	box.add_child(NeonUI.label(title, 17, Color.WHITE))
	box.add_child(NeonUI.label(text, 12, Color("#ffffffaa")))
	if button_text != "":
		var button = NeonUI.ghost_button(button_text, color, 42)
		button.custom_minimum_size = Vector2(108, 42)
		button.pressed.connect(func(): get_tree().current_scene.go_to(route))
		row.add_child(button)

func _add_progress_card(title, value, target, reward, color):
	var pct = clamp(float(value) / max(1.0, float(target)), 0.0, 1.0)
	_add_card(title, "%d/%d  %.0f%%\nRecompensa: %s" % [value, target, pct * 100.0, reward], "res://assets/ui/ui_xp.png", color)

func _add_toggle(label, key, enabled, icon_path):
	var button = NeonUI.ghost_button("%s: %s" % [label, "ON" if enabled else "OFF"], Color("#00f0ff") if enabled else Color("#ffffff66"), 50)
	button.icon = load(icon_path) if ResourceLoader.exists(icon_path) else null
	button.expand_icon = true
	button.pressed.connect(func():
		SaveSystem.set_setting(key, not bool(SaveSystem.get_save().settings.get(key, true)))
		_rebuild()
	)
	content.add_child(button)

func _spin_wheel(use_ad):
	var result = SaveSystem.spin_wheel(use_ad)
	message_label.text = result.get("message", "")
	AudioManager.play_sfx("coin_gain" if result.get("ok", false) else "button_error")
	_rebuild()
	message_label.text = result.get("message", "")

func _claim_daily():
	var result = SaveSystem.claim_daily_reward()
	message_label.text = result.get("message", "")
	AudioManager.play_sfx("diamond_gain" if result.get("ok", false) else "button_error")
	_rebuild()
	message_label.text = result.get("message", "")

func _on_save_changed(_save):
	if wallet_label:
		wallet_label.text = NeonUI.wallet_text(SaveSystem.get_save())

func _daily_missions_for_today():
	var start = _seeded_index(TimeSystem.day_key(), DAILY_MISSIONS.size())
	var output = []
	for offset in range(4):
		output.append(DAILY_MISSIONS[(start + offset * 7) % DAILY_MISSIONS.size()])
	return output

func _seeded_index(seed, count):
	var hash = 0
	for i in range(seed.length()):
		hash = int(hash * 31 + seed.unicode_at(i)) & 0x7fffffff
	return hash % max(1, count)

func _title():
	match feature:
		"inventory":
			return "INVENTARIO"
		"missions":
			return "MISSOES"
		"event":
			return "EVENTO"
		"wheel":
			return "ROLETA"
		"daily_reward":
			return "RECOMPENSA"
		"boss":
			return "BOSS"
		"league":
			return "LIGA NEON"
		"achievements":
			return "CONQUISTAS"
		"settings":
			return "CONFIG"
	return "MENU"

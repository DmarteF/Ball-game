extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

var payload = {}
var summary = {}
var multiplier = 1
var saved = false
var collect_message = ""
var result_box
var collect_button
var double_button
var next_button

func setup(next_payload):
	payload = next_payload
	summary = payload.get("summary", {})
	if is_node_ready():
		_refresh()

func _ready():
	_build_ui()
	_refresh()

func _build_ui():
	var bg = ColorRect.new()
	bg.color = Color("#080818")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 34)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)
	var center = CenterContainer.new()
	margin.add_child(center)
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(360, 0)
	panel.add_theme_stylebox_override("panel", NeonUI.flat(Color("#121228"), Color("#00f0ff66"), 1, 14))
	center.add_child(panel)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	result_box = VBoxContainer.new()
	result_box.add_theme_constant_override("separation", 7)
	box.add_child(result_box)
	double_button = NeonUI.ghost_button("DOBRAR COM ANUNCIO", Color("#ffd700"), 50)
	double_button.pressed.connect(_double_rewards)
	box.add_child(double_button)
	collect_button = NeonUI.button("COLETAR", Color("#00f0ff"), 54)
	collect_button.pressed.connect(_collect)
	box.add_child(collect_button)
	next_button = NeonUI.ghost_button("PROXIMA FASE", Color("#00ff88"), 48)
	next_button.pressed.connect(_next_phase)
	box.add_child(next_button)
	var retry = NeonUI.ghost_button("TENTAR DE NOVO", Color("#b000ff"), 48)
	retry.pressed.connect(_retry)
	box.add_child(retry)
	var menu = NeonUI.ghost_button("MENU", Color("#ffffff99"), 48)
	menu.pressed.connect(_menu)
	box.add_child(menu)

func _refresh():
	if not is_node_ready():
		return
	NeonUI.clear_children(result_box)
	var won = bool(payload.get("won", summary.get("won", false)))
	result_box.add_child(NeonUI.label("VITORIA" if won else "FIM DE JOGO", 30, Color("#00ff88") if won else Color("#ff0055"), HORIZONTAL_ALIGNMENT_CENTER))
	result_box.add_child(NeonUI.label("Fase %d" % int(summary.get("phase", payload.get("phase", 1))), 18, Color("#00f0ff"), HORIZONTAL_ALIGNMENT_CENTER))
	result_box.add_child(NeonUI.label("Moedas da rodada: %d  x%d" % [int(summary.get("coins", 0)), multiplier], 15, Color("#ffd700"), HORIZONTAL_ALIGNMENT_CENTER))
	result_box.add_child(NeonUI.label("Diamantes: %d  | XP perfil: %d" % [int(summary.get("gems", 0)) * multiplier, int(summary.get("profile_xp", 0)) * multiplier], 15, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))
	result_box.add_child(NeonUI.label("Aneis quebrados %d  Perfects %d  Combo x%d" % [int(summary.get("rings_broken", 0)), int(summary.get("perfect_escapes", 0)), int(summary.get("best_combo", 0))], 14, Color("#ffffffbb"), HORIZONTAL_ALIGNMENT_CENTER))
	if collect_message != "":
		result_box.add_child(NeonUI.label(collect_message, 13, Color("#00ff88"), HORIZONTAL_ALIGNMENT_CENTER))
	collect_button.disabled = saved
	double_button.disabled = saved or multiplier > 1
	next_button.visible = won

func _double_rewards():
	AudioManager.play_sfx("button_click")
	await AdsService.show_rewarded("double_run_reward")
	SaveSystem.record_ad_use()
	multiplier = 2
	AudioManager.play_sfx("button_confirm")
	_refresh()

func _collect():
	if saved:
		return
	var result = SaveSystem.record_run(summary, multiplier)
	saved = true
	AudioManager.play_sfx("button_confirm")
	collect_message = "Coletado: +%d moedas globais, +%d diamantes, +%d XP" % [result.coins, result.gems, result.profile_xp]
	for bonus in result.bonuses:
		collect_message += "\n%s" % bonus
	_refresh()

func _retry():
	if not saved:
		SaveSystem.record_run(summary, multiplier)
		saved = true
	get_tree().current_scene.go_to("game", {"phase": int(summary.get("phase", 1))})

func _next_phase():
	if not saved:
		SaveSystem.record_run(summary, multiplier)
		saved = true
	get_tree().current_scene.go_to("game", {"phase": min(50, int(summary.get("phase", 1)) + 1)})

func _menu():
	if not saved:
		SaveSystem.record_run(summary, multiplier)
		saved = true
	get_tree().current_scene.go_to("menu")

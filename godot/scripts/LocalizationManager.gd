extends Node

signal language_changed(language: String)

const TEXT := {
	"en": {
		"back": "Back",
		"play": "Play",
		"upgrades": "Upgrades",
		"skins": "Skins",
		"shop": "Shop",
		"inventory": "Inventory",
		"missions": "Missions",
		"event": "Event",
		"wheel": "Wheel",
		"daily_reward": "Daily Reward",
		"boss": "Boss",
		"league": "Neon League",
		"achievements": "Achievements",
		"settings": "Settings",
		"profile": "Profile",
		"muted": "Muted",
		"audio_on": "Audio: On",
		"audio_off": "Audio: Muted",
		"language": "Language",
		"battle": "Battle",
		"quit": "Quit",
		"victory": "Victory",
		"defeat": "Defeat",
		"select": "Select",
		"locked": "Locked",
		"unlocked": "Unlocked",
	},
	"pt": {
		"back": "Voltar",
		"play": "Jogar",
		"upgrades": "Melhorias",
		"skins": "Skins",
		"shop": "Loja",
		"inventory": "Inventário",
		"missions": "Missões",
		"event": "Evento",
		"wheel": "Roleta",
		"daily_reward": "Recompensa diária",
		"boss": "Boss",
		"league": "Liga Neon",
		"achievements": "Conquistas",
		"settings": "Configurações",
		"profile": "Perfil",
		"muted": "Mudo",
		"audio_on": "Áudio: Ligado",
		"audio_off": "Áudio: Mudo",
		"language": "Idioma",
		"battle": "Batalhar",
		"quit": "Sair",
		"victory": "Vitória",
		"defeat": "Derrota",
		"select": "Selecionar",
		"locked": "Bloqueado",
		"unlocked": "Liberado",
	},
}


func current_language() -> String:
	var language := "en"
	if has_node("/root/GameState"):
		language = String(GameState.data.get("settings", {}).get("language", "en"))
	return "pt" if language.begins_with("pt") else "en"


func tr_key(key: String, fallback := "") -> String:
	var language := current_language()
	return String(Dictionary(TEXT.get(language, {})).get(key, fallback if not fallback.is_empty() else key))


func set_language(language: String) -> void:
	var normalized := "pt" if language.begins_with("pt") else "en"
	if has_node("/root/GameState"):
		GameState.set_language(normalized)
	language_changed.emit(normalized)

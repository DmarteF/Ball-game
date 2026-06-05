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
		"close": "Close",
		"buy": "Buy",
		"open": "Open",
		"claim": "Claim",
		"done": "Done",
		"used": "Used",
		"watch_ad": "Watch Ad",
		"free": "Free",
		"spin": "Spin",
		"go": "Go",
		"wait": "Wait",
		"continue": "Continue",
		"unavailable": "Unavailable",
		"insufficient": "Not enough resources",
		"chests": "Chests",
		"diamonds": "Diamonds",
		"keys": "Keys",
		"rewards": "Rewards",
		"free_chest": "Free Chest",
		"inventory_empty": "Inventory is empty",
		"inventory_empty_desc": "Chests, keys and saved rewards will appear here.",
		"no_chests": "No stored chests",
		"stored_chests_desc": "Purchased or earned chests will appear in Inventory.",
		"stored_reward": "Stored reward. Open when ready.",
		"stored_item": "Stored item.",
		"reward_obtained": "Reward obtained",
		"achievement_unlocked": "Achievement unlocked",
		"claim_your_reward": "Claim your reward",
		"free_spin": "Free Spin",
		"mock_ad_spin": "Mock Ad Spin",
		"spin_desc": "Spin once per day for coins, diamonds, keys or chests.",
		"ad_spin_desc": "Prepared rewarded-ad flow. Uses a mock reward for now.",
		"missions_reward": "Reward",
		"progress": "Progress",
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
		"close": "Fechar",
		"buy": "Comprar",
		"open": "Abrir",
		"claim": "Coletar",
		"done": "Concluído",
		"used": "Usado",
		"watch_ad": "Ver anúncio",
		"free": "Grátis",
		"spin": "Girar",
		"go": "Ir",
		"wait": "Aguardar",
		"continue": "Continuar",
		"unavailable": "Indisponível",
		"insufficient": "Recurso insuficiente",
		"chests": "Baús",
		"diamonds": "Diamantes",
		"keys": "Chaves",
		"rewards": "Recompensas",
		"free_chest": "Baú grátis",
		"inventory_empty": "Inventário vazio",
		"inventory_empty_desc": "Baús, chaves e recompensas guardadas aparecerão aqui.",
		"no_chests": "Nenhum baú guardado",
		"stored_chests_desc": "Baús comprados ou ganhos aparecerão no Inventário.",
		"stored_reward": "Recompensa guardada. Abra quando quiser.",
		"stored_item": "Item guardado.",
		"reward_obtained": "Recompensa obtida",
		"achievement_unlocked": "Conquista desbloqueada",
		"claim_your_reward": "Colete sua recompensa",
		"free_spin": "Giro grátis",
		"mock_ad_spin": "Giro por anúncio",
		"spin_desc": "Gire uma vez por dia para ganhar moedas, diamantes, chaves ou baús.",
		"ad_spin_desc": "Fluxo preparado de anúncio recompensado. Usa recompensa mockada por enquanto.",
		"missions_reward": "Recompensa",
		"progress": "Progresso",
	},
	"es": {
		"back": "Volver", "play": "Jugar", "upgrades": "Mejoras", "skins": "Skins", "shop": "Tienda", "inventory": "Inventario", "missions": "Misiones", "event": "Evento", "wheel": "Ruleta", "daily_reward": "Recompensa diaria", "boss": "Boss", "league": "Liga Neon", "achievements": "Logros", "settings": "Configuración", "profile": "Perfil",
		"muted": "Silencio", "audio_on": "Audio: Activado", "audio_off": "Audio: Silencio", "language": "Idioma", "battle": "Batalla", "quit": "Salir", "victory": "Victoria", "defeat": "Derrota", "select": "Seleccionar", "locked": "Bloqueado", "unlocked": "Desbloqueado", "close": "Cerrar",
		"buy": "Comprar", "open": "Abrir", "claim": "Cobrar", "done": "Completado", "used": "Usado", "watch_ad": "Ver anuncio", "free": "Gratis", "spin": "Girar", "go": "Ir", "wait": "Esperar", "continue": "Continuar", "unavailable": "No disponible", "insufficient": "Recursos insuficientes",
		"chests": "Cofres", "diamonds": "Diamantes", "keys": "Llaves", "rewards": "Recompensas", "free_chest": "Cofre gratis", "inventory_empty": "Inventario vacío", "inventory_empty_desc": "Los cofres, llaves y recompensas guardadas aparecerán aquí.", "no_chests": "No hay cofres guardados",
		"stored_chests_desc": "Los cofres comprados o ganados aparecerán en el Inventario.", "stored_reward": "Recompensa guardada. Ábrela cuando quieras.", "stored_item": "Objeto guardado.", "reward_obtained": "Recompensa obtenida", "achievement_unlocked": "Logro desbloqueado", "claim_your_reward": "Cobra tu recompensa",
		"free_spin": "Giro gratis", "mock_ad_spin": "Giro con anuncio", "spin_desc": "Gira una vez al día para ganar monedas, diamantes, llaves o cofres.", "ad_spin_desc": "Flujo de anuncio recompensado preparado. Usa recompensa simulada por ahora.", "missions_reward": "Recompensa", "progress": "Progreso",
	},
	"ja": {
		"back": "戻る", "play": "プレイ", "upgrades": "強化", "skins": "スキン", "shop": "ショップ", "inventory": "インベントリ", "missions": "ミッション", "event": "イベント", "wheel": "ルーレット", "daily_reward": "デイリー報酬", "boss": "ボス", "league": "ネオンリーグ", "achievements": "実績", "settings": "設定", "profile": "プロフィール",
		"muted": "ミュート", "audio_on": "音声: オン", "audio_off": "音声: ミュート", "language": "言語", "battle": "バトル", "quit": "終了", "victory": "勝利", "defeat": "敗北", "select": "選択", "locked": "ロック中", "unlocked": "解除済み", "close": "閉じる",
		"buy": "購入", "open": "開く", "claim": "受け取る", "done": "完了", "used": "使用済み", "watch_ad": "広告を見る", "free": "無料", "spin": "回す", "go": "進む", "wait": "待つ", "continue": "続ける", "unavailable": "利用不可", "insufficient": "リソース不足",
		"chests": "宝箱", "diamonds": "ダイヤ", "keys": "鍵", "rewards": "報酬", "free_chest": "無料宝箱", "inventory_empty": "インベントリは空です", "inventory_empty_desc": "宝箱、鍵、保存した報酬がここに表示されます。", "no_chests": "保存された宝箱はありません",
		"stored_chests_desc": "購入または獲得した宝箱がインベントリに表示されます。", "stored_reward": "保存された報酬。いつでも開けます。", "stored_item": "保存されたアイテム。", "reward_obtained": "報酬を獲得", "achievement_unlocked": "実績解除", "claim_your_reward": "報酬を受け取る",
		"free_spin": "無料スピン", "mock_ad_spin": "広告スピン", "spin_desc": "1日1回、コイン、ダイヤ、鍵、宝箱を獲得できます。", "ad_spin_desc": "報酬広告フロー準備済み。現在はモック報酬です。", "missions_reward": "報酬", "progress": "進行",
	},
	"zh": {
		"back": "返回", "play": "开始", "upgrades": "升级", "skins": "皮肤", "shop": "商店", "inventory": "背包", "missions": "任务", "event": "活动", "wheel": "转盘", "daily_reward": "每日奖励", "boss": "Boss", "league": "霓虹联赛", "achievements": "成就", "settings": "设置", "profile": "资料",
		"muted": "静音", "audio_on": "音频：开启", "audio_off": "音频：静音", "language": "语言", "battle": "战斗", "quit": "退出", "victory": "胜利", "defeat": "失败", "select": "选择", "locked": "未解锁", "unlocked": "已解锁", "close": "关闭",
		"buy": "购买", "open": "打开", "claim": "领取", "done": "完成", "used": "已使用", "watch_ad": "观看广告", "free": "免费", "spin": "旋转", "go": "前往", "wait": "等待", "continue": "继续", "unavailable": "不可用", "insufficient": "资源不足",
		"chests": "宝箱", "diamonds": "钻石", "keys": "钥匙", "rewards": "奖励", "free_chest": "免费宝箱", "inventory_empty": "背包为空", "inventory_empty_desc": "宝箱、钥匙和保存的奖励会显示在这里。", "no_chests": "没有保存的宝箱",
		"stored_chests_desc": "购买或获得的宝箱会显示在背包中。", "stored_reward": "已保存奖励，可随时打开。", "stored_item": "已保存物品。", "reward_obtained": "获得奖励", "achievement_unlocked": "成就解锁", "claim_your_reward": "领取奖励",
		"free_spin": "免费旋转", "mock_ad_spin": "广告旋转", "spin_desc": "每天旋转一次，获得金币、钻石、钥匙或宝箱。", "ad_spin_desc": "激励广告流程已准备好，目前使用模拟奖励。", "missions_reward": "奖励", "progress": "进度",
	},
}


func current_language() -> String:
	var language := "en"
	if has_node("/root/GameState"):
		language = String(GameState.data.get("settings", {}).get("language", "en"))
	if language.begins_with("pt"):
		return "pt"
	if language.begins_with("es"):
		return "es"
	if language.begins_with("ja"):
		return "ja"
	if language.begins_with("zh"):
		return "zh"
	return "en"


func tr_key(key: String, fallback := "") -> String:
	var language := current_language()
	return String(Dictionary(TEXT.get(language, {})).get(key, fallback if not fallback.is_empty() else key))


func set_language(language: String) -> void:
	var normalized := "en"
	if language.begins_with("pt"):
		normalized = "pt"
	elif language.begins_with("es"):
		normalized = "es"
	elif language.begins_with("ja"):
		normalized = "ja"
	elif language.begins_with("zh"):
		normalized = "zh"
	if has_node("/root/GameState"):
		GameState.set_language(normalized)
	language_changed.emit(normalized)

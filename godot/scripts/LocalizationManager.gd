extends Node

signal language_changed(language: String)

const UPGRADE_TEXT := {
	"damage": { "en": ["Damage+", "+15% damage"], "pt": ["Dano+", "+15% de dano"], "es": ["Daño+", "+15% de daño"], "ja": ["ダメージ+", "ダメージ +15%"], "zh": ["伤害+", "伤害 +15%"] },
	"speed": { "en": ["Speed+", "+20% speed"], "pt": ["Velocidade+", "+20% de velocidade"], "es": ["Velocidad+", "+20% de velocidad"], "ja": ["速度+", "速度 +20%"], "zh": ["速度+", "速度 +20%"] },
	"coinBoost": { "en": ["Coin Rain", "+50% coins"], "pt": ["Chuva de Moedas", "+50% de moedas"], "es": ["Lluvia de Monedas", "+50% monedas"], "ja": ["コインの雨", "コイン +50%"], "zh": ["金币雨", "金币 +50%"] },
	"critical": { "en": ["Critical+", "+5% critical chance"], "pt": ["Crítico+", "+5% chance crítica"], "es": ["Crítico+", "+5% probabilidad crítica"], "ja": ["クリティカル+", "クリティカル率 +5%"], "zh": ["暴击+", "暴击率 +5%"] },
	"xpBoost": { "en": ["XP Boost", "+50% XP"], "pt": ["Bônus de XP", "+50% de XP"], "es": ["Impulso de XP", "+50% XP"], "ja": ["XPブースト", "XP +50%"], "zh": ["经验加成", "经验 +50%"] },
	"bounce": { "en": ["Bounce", "+1 extra bounce"], "pt": ["Ricochete", "+1 ricochete extra"], "es": ["Rebote", "+1 rebote extra"], "ja": ["バウンド", "追加バウンド +1"], "zh": ["弹跳", "额外弹跳 +1"] },
	"perfectChance": { "en": ["Perfect Chance", "+1% diamond chance on Perfect"], "pt": ["Chance Perfect", "+1% chance de diamante no Perfect"], "es": ["Probabilidad Perfect", "+1% diamante en Perfect"], "ja": ["パーフェクト率", "Perfect時ダイヤ率 +1%"], "zh": ["完美概率", "Perfect时钻石率 +1%"] },
	"burn": { "en": ["Burn", "Deals fire damage over time"], "pt": ["Queimar", "Causa dano contínuo de fogo"], "es": ["Quemar", "Inflige daño de fuego continuo"], "ja": ["燃焼", "継続火炎ダメージ"], "zh": ["燃烧", "造成持续火焰伤害"] },
	"penetration": { "en": ["Poison", "Applies progressive damage"], "pt": ["Veneno", "Aplica dano progressivo"], "es": ["Veneno", "Aplica daño progresivo"], "ja": ["毒", "継続的にダメージを与える"], "zh": ["毒素", "施加递增伤害"] },
	"ricochet": { "en": ["Living Ricochet", "More direction and speed after impact"], "pt": ["Ricochete Vivo", "Mais variação e velocidade após impacto"], "es": ["Rebote Vivo", "Más variación y velocidad tras impacto"], "ja": ["ライブリバウンド", "衝突後の速度と角度が増える"], "zh": ["活性反弹", "碰撞后增加速度与变化"] },
	"shockwave": { "en": ["Shockwave", "Area damage on impact"], "pt": ["Onda de Choque", "Dano em área ao impacto"], "es": ["Onda de Choque", "Daño de área al impacto"], "ja": ["衝撃波", "衝突時に範囲ダメージ"], "zh": ["冲击波", "碰撞时造成范围伤害"] },
	"chainLightning": { "en": ["Chain Lightning", "Hits nearby targets"], "pt": ["Raio em Cadeia", "Ataca alvos próximos"], "es": ["Rayo en Cadena", "Golpea objetivos cercanos"], "ja": ["連鎖雷撃", "近くの対象に連鎖する"], "zh": ["连锁闪电", "攻击附近目标"] },
	"frost": { "en": ["Freeze", "Slows rings"], "pt": ["Congelamento", "Desacelera anéis"], "es": ["Congelación", "Ralentiza los anillos"], "ja": ["凍結", "リングを減速"], "zh": ["冻结", "减慢圆环"] },
	"bomb": { "en": ["Bomb", "Chance of massive explosion"], "pt": ["Bomba", "Chance de explosão massiva"], "es": ["Bomba", "Probabilidad de explosión masiva"], "ja": ["爆弾", "大爆発のチャンス"], "zh": ["炸弹", "有机会造成大型爆炸"] },
	"laser": { "en": ["Laser Beam", "Fires a laser beam"], "pt": ["Raio Laser", "Dispara raio laser"], "es": ["Rayo Láser", "Dispara un rayo láser"], "ja": ["レーザー", "レーザーを発射"], "zh": ["激光束", "发射激光"] },
	"multihit": { "en": ["Multi-Hit", "Multiple simultaneous attacks"], "pt": ["Multi-Hit", "Múltiplos ataques simultâneos"], "es": ["Multi-Golpe", "Múltiples ataques simultáneos"], "ja": ["マルチヒット", "複数同時攻撃"], "zh": ["多重打击", "多次同时攻击"] },
	"slowField": { "en": ["Slow Field", "Chance to slow all rings"], "pt": ["Campo Lento", "Chance de desacelerar todos os anéis"], "es": ["Campo Lento", "Probabilidad de ralentizar todos los anillos"], "ja": ["スローフィールド", "全リング減速のチャンス"], "zh": ["减速场", "有机会减慢所有圆环"] },
	"ringRepulse": { "en": ["Ring Repulse", "Pushes the hit ring outward"], "pt": ["Repulsão de Anel", "Empurra o anel atingido para fora"], "es": ["Repulsión de Anillo", "Empuja el anillo golpeado hacia fuera"], "ja": ["リング反発", "命中したリングを外へ押す"], "zh": ["圆环排斥", "将命中的圆环向外推"] },
	"laserCut": { "en": ["Laser Cut", "Chance of high ring damage"], "pt": ["Corte Laser", "Chance de dano alto no anel"], "es": ["Corte Láser", "Probabilidad de mucho daño al anillo"], "ja": ["レーザーカット", "リングに大ダメージのチャンス"], "zh": ["激光切割", "有机会对圆环造成高伤害"] },
	"chainBreak": { "en": ["Chain Break", "Breaking a ring hurts the next"], "pt": ["Quebra-Corrente", "Quebrar um anel fere o próximo"], "es": ["Ruptura en Cadena", "Romper un anillo daña al siguiente"], "ja": ["チェインブレイク", "リング破壊で次も傷つける"], "zh": ["连锁破坏", "破坏一个圆环会伤害下一个"] },
	"shieldPulse": { "en": ["Shield Pulse", "Short shield against crushing"], "pt": ["Pulso de Escudo", "Escudo curto contra esmagamento"], "es": ["Pulso de Escudo", "Escudo breve contra aplastamiento"], "ja": ["シールドパルス", "短時間の圧壊防御"], "zh": ["护盾脉冲", "短暂抵挡挤压"] },
	"timeFreeze": { "en": ["Time Freeze", "Freezes all rings briefly"], "pt": ["Congelar Tempo", "Congela todos os anéis por pouco tempo"], "es": ["Congelar Tiempo", "Congela todos los anillos brevemente"], "ja": ["時間凍結", "全リングを短時間停止"], "zh": ["时间冻结", "短暂冻结所有圆环"] },
	"magnetCoins": { "en": ["Coin Magnet", "Increases run coins"], "pt": ["Ímã de Moedas", "Aumenta moedas da rodada"], "es": ["Imán de Monedas", "Aumenta monedas de la partida"], "ja": ["コイン磁石", "ラン中のコイン増加"], "zh": ["金币磁铁", "增加本局金币"] },
	"criticalOverload": { "en": ["Critical Overload", "Criticals stack temporary damage"], "pt": ["Sobrecarga Crítica", "Críticos acumulam dano temporário"], "es": ["Sobrecarga Crítica", "Los críticos acumulan daño temporal"], "ja": ["クリティカル過負荷", "クリティカルで一時ダメージ蓄積"], "zh": ["暴击超载", "暴击叠加临时伤害"] },
	"chronoBreak": { "en": ["Chrono Break", "Small chance to freeze every ring"], "pt": ["Ruptura Cronal", "Pequena chance de congelar todos os anéis"], "es": ["Ruptura Cronal", "Pequeña probabilidad de congelar todos los anillos"], "ja": ["クロノブレイク", "全リング凍結の小確率"], "zh": ["时空破裂", "小概率冻结所有圆环"] },
	"voidPulse": { "en": ["Void Pulse", "Area damage when breaking a ring"], "pt": ["Pulso do Vazio", "Dano em área ao quebrar um anel"], "es": ["Pulso del Vacío", "Daño de área al romper un anillo"], "ja": ["虚空パルス", "リング破壊時に範囲ダメージ"], "zh": ["虚空脉冲", "破坏圆环时造成范围伤害"] },
	"diamondInstinct": { "en": ["Diamond Instinct", "More diamond chance on Perfect Escape"], "pt": ["Instinto de Diamante", "Aumenta chance de diamante em Perfect Escape"], "es": ["Instinto de Diamante", "Más probabilidad de diamante en Perfect Escape"], "ja": ["ダイヤ本能", "Perfect Escape時のダイヤ率増加"], "zh": ["钻石本能", "Perfect Escape时提高钻石概率"] },
	"comboOverdrive": { "en": ["Combo Overdrive", "High combos boost damage and coins"], "pt": ["Sobrecarga de Combo", "Combos altos aumentam dano e moedas"], "es": ["Sobrecarga de Combo", "Combos altos aumentan daño y monedas"], "ja": ["コンボオーバードライブ", "高コンボでダメージとコイン増加"], "zh": ["连击超载", "高连击提升伤害和金币"] },
	"lastShield": { "en": ["Last Shield", "Avoids one crushing death per run"], "pt": ["Último Escudo", "Evita uma morte por esmagamento por partida"], "es": ["Último Escudo", "Evita una muerte por aplastamiento por partida"], "ja": ["ラストシールド", "1ランに1回圧壊死を防ぐ"], "zh": ["最后护盾", "每局避免一次挤压死亡"] },
	"royalBreaker": { "en": ["Royal Breaker", "More damage against outer rings"], "pt": ["Quebrador Real", "Aumenta dano contra anéis externos"], "es": ["Rompedor Real", "Más daño contra anillos externos"], "ja": ["ロイヤルブレイカー", "外側リングへのダメージ増加"], "zh": ["皇家破坏者", "对外层圆环造成更多伤害"] },
	"bossHunter": { "en": ["Boss Hunter", "More damage and XP in competitive modes"], "pt": ["Caçador de Boss", "Aumenta dano e XP em modos competitivos"], "es": ["Cazador de Boss", "Más daño y XP en modos competitivos"], "ja": ["ボスハンター", "競技モードでダメージとXP増加"], "zh": ["Boss猎手", "竞技模式中提高伤害和经验"] },
	"secretMagnet": { "en": ["Secret Magnet", "More final coins"], "pt": ["Ímã Secreto", "Aumenta moedas gerais no final"], "es": ["Imán Secreto", "Aumenta monedas finales"], "ja": ["秘密の磁石", "最終コイン増加"], "zh": ["秘密磁铁", "提高结算金币"] },
	"trophyInstinct": { "en": ["Trophy Instinct", "Small trophy bonus on wins"], "pt": ["Instinto de Troféu", "Pequeno bônus de troféus ao vencer"], "es": ["Instinto de Trofeo", "Pequeño bono de trofeos al ganar"], "ja": ["トロフィー本能", "勝利時に小トロフィーボーナス"], "zh": ["奖杯本能", "胜利时获得少量奖杯加成"] },
	"rivalCrusher": { "en": ["Rival Crusher", "More damage and XP in competitive matches"], "pt": ["Esmagador de Rivais", "Aumenta dano e XP em partidas competitivas"], "es": ["Aplastarrivales", "Más daño y XP en partidas competitivas"], "ja": ["ライバルクラッシャー", "競技戦でダメージとXP増加"], "zh": ["对手粉碎者", "竞技比赛中提高伤害和经验"] },
}

const COMMON_PHRASES := {
	"SELECIONAR FASE": { "en": "SELECT LEVEL", "pt": "SELECIONAR FASE", "es": "SELECCIONAR NIVEL", "ja": "レベル選択", "zh": "选择关卡" },
	"Modo Infinito": { "en": "Infinite Mode", "pt": "Modo Infinito", "es": "Modo Infinito", "ja": "無限モード", "zh": "无限模式" },
	"ESPECIAL": { "en": "SPECIAL", "pt": "ESPECIAL", "es": "ESPECIAL", "ja": "特別", "zh": "特殊" },
	"PROGRESSÃO INFINITA": { "en": "ENDLESS PROGRESSION", "pt": "PROGRESSÃO INFINITA", "es": "PROGRESIÓN INFINITA", "ja": "無限進行", "zh": "无限进度" },
	"BLOQUEADA": { "en": "LOCKED", "pt": "BLOQUEADA", "es": "BLOQUEADA", "ja": "ロック中", "zh": "未解锁" },
	"FASE": { "en": "LEVEL", "pt": "FASE", "es": "NIVEL", "ja": "レベル", "zh": "关卡" },
	"DIFICULDADE": { "en": "DIFFICULTY", "pt": "DIFICULDADE", "es": "DIFICULTAD", "ja": "難易度", "zh": "难度" },
	"ANÉIS": { "en": "RINGS", "pt": "ANÉIS", "es": "ANILLOS", "ja": "リング", "zh": "圆环" },
	"UPGRADES PERMANENTES": { "en": "PERMANENT UPGRADES", "pt": "UPGRADES PERMANENTES", "es": "MEJORAS PERMANENTES", "ja": "永続強化", "zh": "永久升级" },
	"MELHORIAS DISPONIVEIS": { "en": "AVAILABLE UPGRADES", "pt": "MELHORIAS DISPONÍVEIS", "es": "MEJORAS DISPONIBLES", "ja": "利用可能な強化", "zh": "可用升级" },
	"COLEÇÃO": { "en": "COLLECTION", "pt": "COLEÇÃO", "es": "COLECCIÓN", "ja": "コレクション", "zh": "收藏" },
	"Raridade": { "en": "Rarity", "pt": "Raridade", "es": "Rareza", "ja": "レア度", "zh": "稀有度" },
	"Efeito": { "en": "Effect", "pt": "Efeito", "es": "Efecto", "ja": "効果", "zh": "效果" },
	"EQUIPAR MELHOR SKIN": { "en": "EQUIP BEST SKIN", "pt": "EQUIPAR MELHOR SKIN", "es": "EQUIPAR MEJOR SKIN", "ja": "最強スキン装備", "zh": "装备最佳皮肤" },
	"LIMPAR NOVAS": { "en": "CLEAR NEW", "pt": "LIMPAR NOVAS", "es": "LIMPIAR NUEVAS", "ja": "新着をクリア", "zh": "清除新标记" },
	"EQUIPAR": { "en": "EQUIP", "pt": "EQUIPAR", "es": "EQUIPAR", "ja": "装備", "zh": "装备" },
	"USANDO": { "en": "USING", "pt": "USANDO", "es": "USANDO", "ja": "使用中", "zh": "使用中" },
	"MELHORAR": { "en": "UPGRADE", "pt": "MELHORAR", "es": "MEJORAR", "ja": "強化", "zh": "升级" },
	"EQUIPADA": { "en": "EQUIPPED", "pt": "EQUIPADA", "es": "EQUIPADA", "ja": "装備中", "zh": "已装备" },
	"DESBLOQUEADA": { "en": "UNLOCKED", "pt": "DESBLOQUEADA", "es": "DESBLOQUEADA", "ja": "解除済み", "zh": "已解锁" },
	"VER ANÚNCIO": { "en": "WATCH AD", "pt": "VER ANÚNCIO", "es": "VER ANUNCIO", "ja": "広告を見る", "zh": "观看广告" },
	"COMPRAR": { "en": "BUY", "pt": "COMPRAR", "es": "COMPRAR", "ja": "購入", "zh": "购买" },
	"COLETAR": { "en": "CLAIM", "pt": "COLETAR", "es": "COBRAR", "ja": "受け取る", "zh": "领取" },
	"GIRAR": { "en": "SPIN", "pt": "GIRAR", "es": "GIRAR", "ja": "回す", "zh": "旋转" },
	"RESGATAR": { "en": "CLAIM", "pt": "RESGATAR", "es": "CANJEAR", "ja": "受け取る", "zh": "兑换" },
}

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
		"neon_pass": "Neon Pass",
		"season": "Season",
		"week": "Week",
		"time_remaining": "Time Remaining",
		"level": "Level",
		"pass_xp": "Pass XP",
		"claimed": "Claimed",
		"weekly_cap": "Weekly Cap",
		"weekly_cap_reached": "Weekly cap reached",
		"add_pass_xp": "Add Pass XP",
		"set_neon_pass_level": "Set Neon Pass Level",
		"reset_neon_pass": "Reset Neon Pass",
		"next_week": "Next Week",
		"next_season": "Next Season",
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
		"date": "Date",
		"difficulty": "Difficulty",
		"seed": "Seed",
		"best_score": "Best Score",
		"reward": "Reward",
		"time_until_reset": "Time until reset",
		"daily_challenge": "Daily Challenge",
		"today_challenge_status": "Challenge Status",
		"double_reward": "Double Reward",
		"double_reward_desc": "Watch a mock ad to claim today's reward doubled.",
		"ad_cancelled": "Ad cancelled",
			"missions_empty_desc": "Daily missions refresh automatically and will appear here.",
			"event_empty_desc": "Weekly events and daily challenges will appear here.",
			"daily_available": "Available today",
				"daily_claimed": "Already claimed",
				"first_win_of_day": "First Win of the Day",
				"win_any_battle_to_claim": "Win any battle to claim",
				"completed_today": "Completed Today",
				"available_today": "Available Today",
				"first_win_bonus": "First Win Bonus",
				"view_rewards": "View Rewards",
			"claim_all": "Claim All",
			"view_reward": "View Reward",
			"reward_claimed": "Reward Claimed",
			"pass_reward": "Pass Reward",
			"exclusive_skin": "Exclusive Skin",
			"neon_pass_reward": "Neon Pass Reward",
			"coins": "Coins",
			"fragments": "Fragments",
			"legendary_key": "Legendary Key",
			"chest_common": "Common Chest",
			"chest_rare": "Rare Chest",
			"chest_epic": "Epic Chest",
			"chest_legendary": "Legendary Chest",
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
		"neon_pass": "Passe Neon",
		"season": "Temporada",
		"week": "Semana",
		"time_remaining": "Tempo Restante",
		"level": "Nível",
		"pass_xp": "XP do Passe",
		"claimed": "Coletado",
		"weekly_cap": "Limite Semanal",
		"weekly_cap_reached": "Limite semanal atingido",
		"add_pass_xp": "Adicionar XP do Passe",
		"set_neon_pass_level": "Definir Nível do Passe",
		"reset_neon_pass": "Resetar Passe Neon",
		"next_week": "Próxima Semana",
		"next_season": "Próxima Temporada",
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
		"date": "Data",
		"difficulty": "Dificuldade",
		"seed": "Seed",
		"best_score": "Melhor pontuação",
		"reward": "Recompensa",
		"time_until_reset": "Tempo até resetar",
		"daily_challenge": "Desafio Diário",
		"today_challenge_status": "Status do desafio",
		"double_reward": "Dobrar recompensa",
		"double_reward_desc": "Assista um anúncio de teste para coletar a recompensa diária em dobro.",
		"ad_cancelled": "Anúncio cancelado",
			"missions_empty_desc": "Missões diárias atualizam automaticamente e aparecerão aqui.",
			"event_empty_desc": "Eventos semanais e desafios diários aparecerão aqui.",
			"daily_available": "Disponível hoje",
				"daily_claimed": "Já coletada",
				"first_win_of_day": "Primeira Vitória do Dia",
				"win_any_battle_to_claim": "Vença qualquer batalha para coletar",
				"completed_today": "Concluído Hoje",
				"available_today": "Disponível Hoje",
				"first_win_bonus": "Bônus de Primeira Vitória",
				"view_rewards": "Ver prêmios",
			"claim_all": "Coletar tudo",
			"view_reward": "Ver recompensa",
			"reward_claimed": "Recompensa coletada",
			"pass_reward": "Recompensa do Passe",
			"exclusive_skin": "Skin Exclusiva",
			"neon_pass_reward": "Recompensa do Passe Neon",
			"coins": "Moedas",
			"fragments": "Fragmentos",
			"legendary_key": "Chave Lendaria",
			"chest_common": "Bau Comum",
			"chest_rare": "Bau Raro",
			"chest_epic": "Bau Epico",
			"chest_legendary": "Bau Lendario",
		},
	"es": {
		"back": "Volver", "play": "Jugar", "upgrades": "Mejoras", "skins": "Skins", "shop": "Tienda", "inventory": "Inventario", "missions": "Misiones", "event": "Evento", "wheel": "Ruleta", "daily_reward": "Recompensa diaria", "boss": "Boss", "league": "Liga Neon", "achievements": "Logros", "settings": "Configuración", "profile": "Perfil", "neon_pass": "Pase Neon", "season": "Temporada", "week": "Semana", "time_remaining": "Tiempo Restante", "level": "Nivel", "pass_xp": "XP del Pase", "claimed": "Cobrado", "weekly_cap": "Límite Semanal", "weekly_cap_reached": "Límite semanal alcanzado", "add_pass_xp": "Añadir XP del Pase", "set_neon_pass_level": "Definir Nivel del Pase", "reset_neon_pass": "Resetear Pase Neon", "next_week": "Próxima Semana", "next_season": "Próxima Temporada",
		"muted": "Silencio", "audio_on": "Audio: Activado", "audio_off": "Audio: Silencio", "language": "Idioma", "battle": "Batalla", "quit": "Salir", "victory": "Victoria", "defeat": "Derrota", "select": "Seleccionar", "locked": "Bloqueado", "unlocked": "Desbloqueado", "close": "Cerrar",
		"buy": "Comprar", "open": "Abrir", "claim": "Cobrar", "done": "Completado", "used": "Usado", "watch_ad": "Ver anuncio", "free": "Gratis", "spin": "Girar", "go": "Ir", "wait": "Esperar", "continue": "Continuar", "unavailable": "No disponible", "insufficient": "Recursos insuficientes",
		"chests": "Cofres", "diamonds": "Diamantes", "keys": "Llaves", "rewards": "Recompensas", "free_chest": "Cofre gratis", "inventory_empty": "Inventario vacío", "inventory_empty_desc": "Los cofres, llaves y recompensas guardadas aparecerán aquí.", "no_chests": "No hay cofres guardados",
		"stored_chests_desc": "Los cofres comprados o ganados aparecerán en el Inventario.", "stored_reward": "Recompensa guardada. Ábrela cuando quieras.", "stored_item": "Objeto guardado.", "reward_obtained": "Recompensa obtenida", "achievement_unlocked": "Logro desbloqueado", "claim_your_reward": "Cobra tu recompensa",
			"free_spin": "Giro gratis", "mock_ad_spin": "Giro con anuncio", "spin_desc": "Gira una vez al día para ganar monedas, diamantes, llaves o cofres.", "ad_spin_desc": "Flujo de anuncio recompensado preparado. Usa recompensa simulada por ahora.", "missions_reward": "Recompensa", "progress": "Progreso", "date": "Fecha", "difficulty": "Dificultad", "seed": "Seed", "best_score": "Mejor puntuación", "reward": "Recompensa", "time_until_reset": "Tiempo hasta reinicio", "daily_challenge": "Desafío diario", "today_challenge_status": "Estado del desafío", "double_reward": "Duplicar recompensa", "double_reward_desc": "Mira un anuncio simulado para cobrar la recompensa diaria duplicada.", "ad_cancelled": "Anuncio cancelado", "missions_empty_desc": "Las misiones diarias se actualizan automáticamente y aparecerán aquí.", "event_empty_desc": "Los eventos semanales y desafíos diarios aparecerán aquí.", "daily_available": "Disponible hoy", "daily_claimed": "Ya cobrada", "first_win_of_day": "Primera victoria del día", "win_any_battle_to_claim": "Gana cualquier batalla para cobrar", "completed_today": "Completado hoy", "available_today": "Disponible hoy", "first_win_bonus": "Bono de primera victoria", "view_rewards": "Ver premios", "claim_all": "Cobrar todo", "view_reward": "Ver recompensa", "reward_claimed": "Recompensa cobrada", "pass_reward": "Recompensa del Pase", "exclusive_skin": "Skin exclusiva", "neon_pass_reward": "Recompensa del Pase Neon", "coins": "Monedas", "fragments": "Fragmentos", "legendary_key": "Llave legendaria", "chest_common": "Cofre común", "chest_rare": "Cofre raro", "chest_epic": "Cofre épico", "chest_legendary": "Cofre legendario",
	},
	"ja": {
		"back": "戻る", "play": "プレイ", "upgrades": "強化", "skins": "スキン", "shop": "ショップ", "inventory": "インベントリ", "missions": "ミッション", "event": "イベント", "wheel": "ルーレット", "daily_reward": "デイリー報酬", "boss": "ボス", "league": "ネオンリーグ", "achievements": "実績", "settings": "設定", "profile": "プロフィール", "neon_pass": "ネオンパス", "season": "シーズン", "week": "週", "time_remaining": "残り時間", "level": "レベル", "pass_xp": "パスXP", "claimed": "受取済み", "weekly_cap": "週間上限", "weekly_cap_reached": "週間上限に到達", "add_pass_xp": "パスXP追加", "set_neon_pass_level": "パスレベル設定", "reset_neon_pass": "ネオンパスリセット", "next_week": "次の週", "next_season": "次のシーズン",
		"muted": "ミュート", "audio_on": "音声: オン", "audio_off": "音声: ミュート", "language": "言語", "battle": "バトル", "quit": "終了", "victory": "勝利", "defeat": "敗北", "select": "選択", "locked": "ロック中", "unlocked": "解除済み", "close": "閉じる",
		"buy": "購入", "open": "開く", "claim": "受け取る", "done": "完了", "used": "使用済み", "watch_ad": "広告を見る", "free": "無料", "spin": "回す", "go": "進む", "wait": "待つ", "continue": "続ける", "unavailable": "利用不可", "insufficient": "リソース不足",
		"chests": "宝箱", "diamonds": "ダイヤ", "keys": "鍵", "rewards": "報酬", "free_chest": "無料宝箱", "inventory_empty": "インベントリは空です", "inventory_empty_desc": "宝箱、鍵、保存した報酬がここに表示されます。", "no_chests": "保存された宝箱はありません",
		"stored_chests_desc": "購入または獲得した宝箱がインベントリに表示されます。", "stored_reward": "保存された報酬。いつでも開けます。", "stored_item": "保存されたアイテム。", "reward_obtained": "報酬を獲得", "achievement_unlocked": "実績解除", "claim_your_reward": "報酬を受け取る",
			"free_spin": "無料スピン", "mock_ad_spin": "広告スピン", "spin_desc": "1日1回、コイン、ダイヤ、鍵、宝箱を獲得できます。", "ad_spin_desc": "報酬広告フロー準備済み。現在はモック報酬です。", "missions_reward": "報酬", "progress": "進行", "date": "日付", "difficulty": "難易度", "seed": "シード", "best_score": "ベストスコア", "reward": "報酬", "time_until_reset": "リセットまで", "daily_challenge": "デイリーチャレンジ", "today_challenge_status": "チャレンジ状況", "double_reward": "報酬2倍", "double_reward_desc": "モック広告を見て本日の報酬を2倍で受け取ります。", "ad_cancelled": "広告キャンセル", "missions_empty_desc": "デイリーミッションは自動更新され、ここに表示されます。", "event_empty_desc": "週間イベントとデイリーチャレンジがここに表示されます。", "daily_available": "本日利用可能", "daily_claimed": "受け取り済み", "first_win_of_day": "本日の初勝利", "win_any_battle_to_claim": "いずれかのバトルに勝利して受取", "completed_today": "本日完了", "available_today": "本日利用可能", "first_win_bonus": "初勝利ボーナス", "view_rewards": "報酬を見る", "claim_all": "すべて受け取る", "view_reward": "報酬を見る", "reward_claimed": "報酬受取済み", "pass_reward": "パス報酬", "exclusive_skin": "限定スキン", "neon_pass_reward": "ネオンパス報酬", "coins": "コイン", "fragments": "欠片", "legendary_key": "レジェンド鍵", "chest_common": "コモン宝箱", "chest_rare": "レア宝箱", "chest_epic": "エピック宝箱", "chest_legendary": "レジェンド宝箱",
	},
	"zh": {
		"back": "返回", "play": "开始", "upgrades": "升级", "skins": "皮肤", "shop": "商店", "inventory": "背包", "missions": "任务", "event": "活动", "wheel": "转盘", "daily_reward": "每日奖励", "boss": "Boss", "league": "霓虹联赛", "achievements": "成就", "settings": "设置", "profile": "资料", "neon_pass": "霓虹通行证", "season": "赛季", "week": "周", "time_remaining": "剩余时间", "level": "等级", "pass_xp": "通行证经验", "claimed": "已领取", "weekly_cap": "每周上限", "weekly_cap_reached": "已达到每周上限", "add_pass_xp": "添加通行证经验", "set_neon_pass_level": "设置通行证等级", "reset_neon_pass": "重置霓虹通行证", "next_week": "下一周", "next_season": "下一赛季",
		"muted": "静音", "audio_on": "音频：开启", "audio_off": "音频：静音", "language": "语言", "battle": "战斗", "quit": "退出", "victory": "胜利", "defeat": "失败", "select": "选择", "locked": "未解锁", "unlocked": "已解锁", "close": "关闭",
		"buy": "购买", "open": "打开", "claim": "领取", "done": "完成", "used": "已使用", "watch_ad": "观看广告", "free": "免费", "spin": "旋转", "go": "前往", "wait": "等待", "continue": "继续", "unavailable": "不可用", "insufficient": "资源不足",
		"chests": "宝箱", "diamonds": "钻石", "keys": "钥匙", "rewards": "奖励", "free_chest": "免费宝箱", "inventory_empty": "背包为空", "inventory_empty_desc": "宝箱、钥匙和保存的奖励会显示在这里。", "no_chests": "没有保存的宝箱",
		"stored_chests_desc": "购买或获得的宝箱会显示在背包中。", "stored_reward": "已保存奖励，可随时打开。", "stored_item": "已保存物品。", "reward_obtained": "获得奖励", "achievement_unlocked": "成就解锁", "claim_your_reward": "领取奖励",
			"free_spin": "免费旋转", "mock_ad_spin": "广告旋转", "spin_desc": "每天旋转一次，获得金币、钻石、钥匙或宝箱。", "ad_spin_desc": "激励广告流程已准备好，目前使用模拟奖励。", "missions_reward": "奖励", "progress": "进度", "date": "日期", "difficulty": "难度", "seed": "种子", "best_score": "最佳分数", "reward": "奖励", "time_until_reset": "重置倒计时", "daily_challenge": "每日挑战", "today_challenge_status": "挑战状态", "double_reward": "双倍奖励", "double_reward_desc": "观看模拟广告领取双倍每日奖励。", "ad_cancelled": "广告已取消", "missions_empty_desc": "每日任务会自动刷新并显示在这里。", "event_empty_desc": "每周活动和每日挑战会显示在这里。", "daily_available": "今日可用", "daily_claimed": "已领取", "first_win_of_day": "每日首胜", "win_any_battle_to_claim": "赢得任意战斗即可领取", "completed_today": "今日完成", "available_today": "今日可用", "first_win_bonus": "首胜奖励", "view_rewards": "查看奖励", "claim_all": "全部领取", "view_reward": "查看奖励", "reward_claimed": "奖励已领取", "pass_reward": "通行证奖励", "exclusive_skin": "限定皮肤", "neon_pass_reward": "霓虹通行证奖励", "coins": "金币", "fragments": "碎片", "legendary_key": "传奇钥匙", "chest_common": "普通宝箱", "chest_rare": "稀有宝箱", "chest_epic": "史诗宝箱", "chest_legendary": "传奇宝箱",
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


func text(en: String, pt := "", es := "", ja := "", zh := "") -> String:
	var language := current_language()
	match language:
		"pt":
			return pt if not pt.is_empty() else en
		"es":
			return es if not es.is_empty() else en
		"ja":
			return ja if not ja.is_empty() else en
		"zh":
			return zh if not zh.is_empty() else en
	return en


func phrase(value: String) -> String:
	var entry: Dictionary = COMMON_PHRASES.get(value, {})
	if entry.is_empty():
		return value
	return String(entry.get(current_language(), entry.get("en", value)))


func tr_key(key: String, fallback := "") -> String:
	var language := current_language()
	return String(Dictionary(TEXT.get(language, {})).get(key, fallback if not fallback.is_empty() else key))


func upgrade_name(id: String, fallback := "") -> String:
	var entry: Dictionary = UPGRADE_TEXT.get(id, {})
	if entry.is_empty():
		return fallback if not fallback.is_empty() else id
	var pair: Array = entry.get(current_language(), entry.get("en", []))
	return String(pair[0]) if pair.size() > 0 else fallback


func upgrade_description(id: String, fallback := "") -> String:
	var entry: Dictionary = UPGRADE_TEXT.get(id, {})
	if entry.is_empty():
		return fallback if not fallback.is_empty() else id
	var pair: Array = entry.get(current_language(), entry.get("en", []))
	return String(pair[1]) if pair.size() > 1 else fallback


func upgrade_unlock_requirement(value: String) -> String:
	var language := current_language()
	var text_value := value
	text_value = text_value.replace("Perfil nível", text("Profile level", "Perfil nível", "Perfil nivel", "プロフィールLv.", "玩家等级"))
	text_value = text_value.replace("Conquista secreta", text("Secret achievement", "Conquista secreta", "Logro secreto", "秘密実績", "秘密成就"))
	text_value = text_value.replace("Disponível desde o início", text("Available from the start", "Disponível desde o início", "Disponible desde el inicio", "最初から利用可能", "初始可用"))
	if language == "en":
		text_value = text_value.replace("fase", "level").replace("Fase", "Level").replace("nível", "level")
	elif language == "es":
		text_value = text_value.replace("fase", "nivel").replace("Fase", "Nivel").replace("nível", "nivel")
	elif language == "ja":
		text_value = text_value.replace("fase", "レベル").replace("Fase", "レベル").replace("nível", "Lv.")
	elif language == "zh":
		text_value = text_value.replace("fase", "关卡").replace("Fase", "关卡").replace("nível", "等级")
	return text_value


func rarity_name(id: String) -> String:
	match id:
		"common":
			return text("Common", "Comum", "Común", "コモン", "普通")
		"rare":
			return text("Rare", "Rara", "Rara", "レア", "稀有")
		"epic":
			return text("Epic", "Épica", "Épica", "エピック", "史诗")
		"legendary":
			return text("Legendary", "Lendária", "Legendaria", "レジェンド", "传奇")
		"mythic":
			return text("Mythic", "Mítica", "Mítica", "ミシック", "神话")
		"ultimate":
			return text("Ultimate", "Ultimate", "Ultimate", "アルティメット", "终极")
	return id.capitalize()


func effect_name(value: String) -> String:
	var lower := value.to_lower()
	match lower:
		"controle", "control":
			return text("Control", "Controle", "Control", "操作", "控制")
		"gelo", "ice", "congela", "freeze", "frost":
			return text("Ice", "Gelo", "Hielo", "氷", "冰")
		"fogo", "fire", "queima", "burn":
			return text("Fire", "Fogo", "Fuego", "炎", "火")
		"crítico", "critico", "critical", "mega crítico":
			return text("Critical", "Crítico", "Crítico", "クリティカル", "暴击")
		"moedas", "coins", "tesouro":
			return text("Coins", "Moedas", "Monedas", "コイン", "金币")
		"velocidade", "speed":
			return text("Speed", "Velocidade", "Velocidad", "速度", "速度")
		"corrente", "chain":
			return text("Chain", "Corrente", "Cadena", "連鎖", "连锁")
		"área", "area":
			return text("Area", "Área", "Área", "範囲", "范围")
		"fase", "phase":
			return text("Phase", "Fase", "Fase", "位相", "相位")
		"gravidade", "gravity":
			return text("Gravity", "Gravidade", "Gravedad", "重力", "重力")
		"lentidão", "slow":
			return text("Slow", "Lentidão", "Lentitud", "減速", "减速")
		"repulsão", "repulsao", "repulse":
			return text("Repulse", "Repulsão", "Repulsión", "反発", "排斥")
		"trilha", "trail":
			return text("Trail", "Trilha", "Rastro", "軌跡", "轨迹")
		"bônus", "bonus":
			return text("Bonus", "Bônus", "Bono", "ボーナス", "加成")
	return value


func achievement_name(achievement: Dictionary) -> String:
	var en := String(achievement.get("name", ""))
	if en.strip_edges().is_empty():
		en = String(achievement.get("id", "Achievement")).capitalize()
	var pt := String(achievement.get("name_pt", en))
	if current_language() == "pt":
		return pt if not pt.strip_edges().is_empty() else en
	if current_language() == "es":
		return _translate_achievement_phrase(en, true, "es")
	if current_language() == "ja":
		return _translate_achievement_phrase(en, true, "ja")
	if current_language() == "zh":
		return _translate_achievement_phrase(en, true, "zh")
	return en


func achievement_desc(achievement: Dictionary) -> String:
	var en := String(achievement.get("desc", ""))
	if en.strip_edges().is_empty():
		en = "Complete this achievement."
	var pt := String(achievement.get("desc_pt", en))
	if current_language() == "pt":
		return pt if not pt.strip_edges().is_empty() else en
	if current_language() == "es":
		return _translate_achievement_phrase(en, false, "es")
	if current_language() == "ja":
		return _translate_achievement_phrase(en, false, "ja")
	if current_language() == "zh":
		return _translate_achievement_phrase(en, false, "zh")
	return en


func _translate_achievement_phrase(value: String, is_title: bool, language: String) -> String:
	if value.begins_with("Unlock phase "):
		var number := value.replace("Unlock phase ", "").replace(".", "")
		match language:
			"es": return "Desbloquea el nivel %s" % number
			"ja": return "レベル%sを解除" % number
			"zh": return "解锁关卡%s" % number
	if value.begins_with("Complete ") and value.ends_with(" phase runs."):
		var number := value.replace("Complete ", "").replace(" phase runs.", "")
		match language:
			"es": return "Completa %s partidas de nivel." % number
			"ja": return "レベルランを%s回完了。" % number
			"zh": return "完成%s次关卡挑战。" % number
	if value.begins_with("Reach ") and value.ends_with(" seconds in Infinite Mode."):
		var number := value.replace("Reach ", "").replace(" seconds in Infinite Mode.", "")
		match language:
			"es": return "Alcanza %s segundos en Modo Infinito." % number
			"ja": return "無限モードで%s秒到達。" % number
			"zh": return "在无限模式达到%s秒。" % number
	if value.begins_with("Break ") and value.ends_with(" rings in one Infinite Mode run."):
		var number := value.replace("Break ", "").replace(" rings in one Infinite Mode run.", "")
		match language:
			"es": return "Rompe %s anillos en una partida infinita." % number
			"ja": return "1回の無限ランでリングを%s個破壊。" % number
			"zh": return "单次无限模式破坏%s个圆环。" % number
	var known := {
		"Play your first run.": ["Juega tu primera partida.", "初回プレイをする。", "完成第一局游戏。"],
		"Destroy 50 rings.": ["Destruye 50 anillos.", "リングを50個破壊。", "破坏50个圆环。"],
		"Play Infinite Mode once.": ["Juega Modo Infinito una vez.", "無限モードを1回プレイ。", "游玩一次无限模式。"],
		"Equip a skin.": ["Equipa una skin.", "スキンを装備。", "装备一个皮肤。"],
		"Claim a daily reward.": ["Cobra una recompensa diaria.", "デイリー報酬を受け取る。", "领取每日奖励。"],
		"Play one Daily Challenge.": ["Juega un Desafío Diario.", "デイリーチャレンジを1回プレイ。", "游玩一次每日挑战。"],
		"Defeat any boss.": ["Derrota cualquier Boss.", "任意のボスを倒す。", "击败任意Boss。"],
	}
	if known.has(value):
		var index := 0 if language == "es" else 1 if language == "ja" else 2
		return known[value][index]
	return value


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

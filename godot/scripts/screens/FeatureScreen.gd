extends Control

const NeonUI = preload("res://scripts/ui/NeonUI.gd")

const DAILY_MISSIONS = [
	{"id": "rings_50", "title": "Destruir 50 anéis", "metric": "rings_destroyed", "target": 50, "reward": {"type": "coins", "amount": 260}, "difficulty": 1},
	{"id": "rings_150", "title": "Destruir 150 anéis", "metric": "rings_destroyed", "target": 150, "reward": {"type": "keys", "amount": 1}, "difficulty": 2},
	{"id": "perfect_3", "title": "Fazer 3 Perfect Escapes", "metric": "perfect_escapes", "target": 3, "reward": {"type": "gems", "amount": 5}, "difficulty": 1},
	{"id": "perfect_10", "title": "Fazer 10 Perfect Escapes", "metric": "perfect_escapes", "target": 10, "reward": {"type": "gems", "amount": 14}, "difficulty": 2},
	{"id": "runs_3", "title": "Jogar 3 partidas", "metric": "runs_played", "target": 3, "reward": {"type": "profile_xp", "amount": 70}, "difficulty": 1},
	{"id": "runs_5", "title": "Jogar 5 partidas", "metric": "runs_played", "target": 5, "reward": {"type": "coins", "amount": 420}, "difficulty": 2},
	{"id": "win_1", "title": "Vencer 1 fase", "metric": "phase_wins", "target": 1, "reward": {"type": "gems", "amount": 8}, "difficulty": 1},
	{"id": "win_3", "title": "Vencer 3 fases", "metric": "phase_wins", "target": 3, "reward": {"type": "chest", "chest": "rare", "amount": 1}, "difficulty": 3},
	{"id": "chest_1", "title": "Abrir 1 baú", "metric": "chests_opened", "target": 1, "reward": {"type": "fragments", "amount": 12}, "difficulty": 1},
	{"id": "chest_3", "title": "Abrir 3 baús", "metric": "chests_opened", "target": 3, "reward": {"type": "keys", "amount": 1}, "difficulty": 2},
	{"id": "coins_500", "title": "Ganhar 500 moedas da rodada", "metric": "run_coins", "target": 500, "reward": {"type": "coins", "amount": 320}, "difficulty": 1},
	{"id": "coins_2000", "title": "Ganhar 2.000 moedas da rodada", "metric": "run_coins", "target": 2000, "reward": {"type": "gems", "amount": 12}, "difficulty": 3},
	{"id": "gems_5", "title": "Ganhar 5 diamantes", "metric": "diamonds_found", "target": 5, "reward": {"type": "profile_xp", "amount": 120}, "difficulty": 2},
	{"id": "temp_upgrades_3", "title": "Usar 3 upgrades temporários", "metric": "run_upgrades", "target": 3, "reward": {"type": "coins", "amount": 260}, "difficulty": 1},
	{"id": "combo_5", "title": "Fazer combo x5", "metric": "best_combo", "target": 5, "reward": {"type": "gems", "amount": 5}, "difficulty": 1},
	{"id": "combo_10", "title": "Fazer combo x10", "metric": "best_combo", "target": 10, "reward": {"type": "keys", "amount": 1}, "difficulty": 2},
	{"id": "equip_skin", "title": "Equipar uma skin diferente", "metric": "skin_equips", "target": 1, "reward": {"type": "fragments", "amount": 10}, "difficulty": 1},
	{"id": "boss_run", "title": "Jogar Boss Mode 1 vez", "metric": "boss_runs", "target": 1, "reward": {"type": "coins", "amount": 360}, "difficulty": 1},
	{"id": "boss_win", "title": "Vencer Boss Mode 1 vez", "metric": "boss_wins", "target": 1, "reward": {"type": "gems", "amount": 16}, "difficulty": 3},
	{"id": "offline_claim", "title": "Coletar recompensa offline", "metric": "offline_claims", "target": 1, "reward": {"type": "coins", "amount": 220}, "difficulty": 1},
	{"id": "store_buy", "title": "Comprar algo na loja", "metric": "store_purchases", "target": 1, "reward": {"type": "gems", "amount": 6}, "difficulty": 1},
	{"id": "watch_ad", "title": "Usar anúncio simulado 1 vez", "metric": "ads_watched", "target": 1, "reward": {"type": "coins", "amount": 240}, "difficulty": 1},
	{"id": "crit_5", "title": "Fazer 5 críticos", "metric": "criticals", "target": 5, "reward": {"type": "profile_xp", "amount": 90}, "difficulty": 1},
	{"id": "skin_effect_10", "title": "Quebrar 10 anéis com efeito de skin", "metric": "skin_effects", "target": 10, "reward": {"type": "fragments", "amount": 18}, "difficulty": 2},
	{"id": "no_revive", "title": "Concluir uma fase sem revive", "metric": "no_revive_wins", "target": 1, "reward": {"type": "gems", "amount": 10}, "difficulty": 2}
]

const ACHIEVEMENTS = [
	{"id": "first_steps", "name": "Primeiros Passos", "description": "Jogue a primeira partida.", "category": "progresso", "required": 1, "metric": "runs_played", "reward": {"type": "coins", "amount": 250}, "rarity": "common"},
	{"id": "first_perfect", "name": "Primeiro Escape", "description": "Faça 1 escape perfeito.", "category": "perfect escape", "required": 1, "metric": "perfect_escapes", "reward": {"type": "gems", "amount": 8}, "rarity": "rare"},
	{"id": "ring_breaker_1", "name": "Quebrador de Anéis I", "description": "Destrua 50 anéis.", "category": "combate", "required": 50, "metric": "rings_destroyed", "reward": {"type": "coins", "amount": 500}, "rarity": "common"},
	{"id": "ring_breaker_2", "name": "Quebrador de Anéis II", "description": "Destrua 250 anéis.", "category": "combate", "required": 250, "metric": "rings_destroyed", "reward": {"type": "keys", "amount": 1}, "rarity": "rare"},
	{"id": "ring_breaker_3", "name": "Quebrador de Anéis III", "description": "Destrua 1000 anéis.", "category": "combate", "required": 1000, "metric": "rings_destroyed", "reward": {"type": "chest", "chest": "rare", "amount": 1}, "rarity": "epic"},
	{"id": "perfect_hunter", "name": "Caçador de Perfect", "description": "Faça 25 escapes perfeitos.", "category": "perfect escape", "required": 25, "metric": "perfect_escapes", "reward": {"type": "gems", "amount": 35}, "rarity": "epic"},
	{"id": "diamond_miner", "name": "Garimpeiro de Diamantes", "description": "Ganhe 10 diamantes por Perfect Escape.", "category": "economia", "required": 10, "metric": "diamonds_found", "reward": {"type": "gems", "amount": 40}, "rarity": "rare"},
	{"id": "starter_collector", "name": "Colecionador Iniciante", "description": "Desbloqueie 5 skins.", "category": "coleção", "required": 5, "metric": "skins_unlocked", "reward": {"type": "chest", "chest": "common", "amount": 1}, "rarity": "rare"},
	{"id": "rare_collector", "name": "Colecionador Raro", "description": "Desbloqueie 5 skins raras.", "category": "skins", "required": 5, "metric": "rare_skins_unlocked", "reward": {"type": "chest", "chest": "rare", "amount": 1}, "rarity": "epic"},
	{"id": "epic_luck", "name": "Sorte Épica", "description": "Obtenha 1 skin épica.", "category": "skins", "required": 1, "metric": "epic_skins_unlocked", "reward": {"type": "gems", "amount": 30}, "rarity": "epic"},
	{"id": "legend_awake", "name": "Lenda Desperta", "description": "Obtenha 1 skin lendária.", "category": "skins", "required": 1, "metric": "legendary_skins_unlocked", "reward": {"type": "chest", "chest": "epic", "amount": 1}, "rarity": "legendary"},
	{"id": "chest_opener_1", "name": "Abridor de Baús I", "description": "Abra 5 baús.", "category": "baús", "required": 5, "metric": "chests_opened", "reward": {"type": "coins", "amount": 600}, "rarity": "common"},
	{"id": "chest_opener_2", "name": "Abridor de Baús II", "description": "Abra 25 baús.", "category": "baús", "required": 25, "metric": "chests_opened", "reward": {"type": "keys", "amount": 2}, "rarity": "rare"},
	{"id": "survivor", "name": "Sobrevivente", "description": "Vença uma fase sem usar revive.", "category": "progresso", "required": 1, "metric": "no_revive_wins", "reward": {"type": "gems", "amount": 12}, "rarity": "rare"},
	{"id": "fearless", "name": "Sem Medo", "description": "Vença 5 fases sem usar revive.", "category": "progresso", "required": 5, "metric": "no_revive_wins", "reward": {"type": "chest", "chest": "epic", "amount": 1}, "rarity": "epic"},
	{"id": "stage_20_champion", "name": "Campeão dos 50 Estágios", "description": "Conclua todas as 50 fases principais.", "category": "especiais", "required": 50, "metric": "highest_phase", "reward": {"type": "skin", "skin_id": "cosmic_champion"}, "rarity": "special"},
	{"id": "first_duel", "name": "Primeiro Boss", "description": "Enfrente o Boss mensal pela primeira vez.", "category": "boss", "required": 1, "metric": "boss_runs", "reward": {"type": "coins", "amount": 300}, "rarity": "common"},
	{"id": "boss_victory", "name": "Vitória Normal", "description": "Vença o Boss mensal no nível Normal.", "category": "boss", "required": 1, "metric": "boss_best_difficulty", "reward": {"type": "gems", "amount": 20}, "rarity": "rare"},
	{"id": "boss_elite", "name": "Chegou no Elite", "description": "Vença até o nível Elite do Boss mensal.", "category": "boss", "required": 3, "metric": "boss_best_difficulty", "reward": {"type": "keys", "amount": 1}, "rarity": "epic"},
	{"id": "boss_legendary", "name": "Lendário Derrotado", "description": "Vença o nível Lendário do Boss mensal.", "category": "boss", "required": 4, "metric": "boss_best_difficulty", "reward": {"type": "chest", "chest": "epic", "amount": 1}, "rarity": "legendary"},
	{"id": "impossible", "name": "Impossível Vencido", "description": "Vença o Boss mensal no nível Impossível.", "category": "boss", "required": 5, "metric": "boss_best_difficulty", "reward": {"type": "legendaryKeys", "amount": 1}, "rarity": "ultimate"},
	{"id": "monthly_hunter", "name": "Caçador Mensal", "description": "Vença o Impossível 5 vezes no mesmo mês.", "category": "boss", "required": 5, "metric": "boss_impossible_wins", "reward": {"type": "fragments", "skin_id": "divine_core", "amount": 20}, "rarity": "ultimate"},
	{"id": "month_dominator", "name": "Dominador do Mês", "description": "Vença o Impossível em 10 dias diferentes no mesmo mês.", "category": "boss", "required": 10, "metric": "boss_impossible_days", "reward": {"type": "chest", "chest": "legendary", "amount": 1}, "rarity": "ultimate"},
	{"id": "neon_top_10", "name": "Top 10 Neon", "description": "Finalize uma temporada da Liga Neon no top 10.", "category": "especiais", "required": 1, "metric": "league_top_10_finishes", "reward": {"type": "gems", "amount": 60}, "rarity": "epic"},
	{"id": "league_champion", "name": "Campeão da Liga", "description": "Termine uma temporada da Liga Neon em #1.", "category": "especiais", "required": 1, "metric": "league_first_place_finishes", "reward": {"type": "chest", "chest": "epic", "amount": 1}, "rarity": "legendary"},
	{"id": "supreme_champion", "name": "Campeão Supremo", "description": "Termine em #1 na divisão Ultimate da Liga Neon.", "category": "especiais", "required": 1, "metric": "league_ultimate_first_place_finishes", "reward": {"type": "fragments", "skin_id": "league_king_neon", "amount": 80}, "rarity": "ultimate"},
	{"id": "back_to_top", "name": "Retorno ao Topo", "description": "Volte ao #1 depois de uma temporada com rebaixamento.", "category": "especiais", "required": 2, "metric": "league_first_place_finishes", "reward": {"type": "gems", "amount": 70}, "rarity": "legendary"},
	{"id": "first_crown", "name": "Primeira Coroa", "description": "Primeira vez em #1 no rank inicial da Liga Neon.", "category": "especiais", "required": 1, "metric": "league_initial_crowns", "reward": {"type": "skin", "skin_id": "initial_neon_champion"}, "rarity": "ultimate"},
	{"id": "first_compete", "name": "Primeiro Competir", "description": "Jogue uma competição da Liga Neon.", "category": "liga", "required": 1, "metric": "league_competitions_played", "reward": {"type": "coins", "amount": 400}, "rarity": "common"},
	{"id": "first_compete_win", "name": "Primeira Vitória", "description": "Vença uma competição da Liga Neon.", "category": "liga", "required": 1, "metric": "league_competition_wins", "reward": {"type": "gems", "amount": 18}, "rarity": "rare"},
	{"id": "ranking_up_silver", "name": "Subindo no Ranking", "description": "Alcance a divisão Prata.", "category": "liga", "required": 300, "metric": "total_trophies_gained", "reward": {"type": "chest", "chest": "common", "amount": 1}, "rarity": "rare"},
	{"id": "trophy_hunter", "name": "Caçador de Troféus", "description": "Ganhe 500 troféus totais.", "category": "liga", "required": 500, "metric": "total_trophies_gained", "reward": {"type": "keys", "amount": 1}, "rarity": "rare"},
	{"id": "neon_streak", "name": "Sequência Neon", "description": "Vença 5 competições seguidas.", "category": "liga", "required": 5, "metric": "league_best_win_streak", "reward": {"type": "chest", "chest": "rare", "amount": 1}, "rarity": "epic"},
	{"id": "unstoppable", "name": "Imparável", "description": "Vença 10 competições seguidas.", "category": "liga", "required": 10, "metric": "league_best_win_streak", "reward": {"type": "chest", "chest": "epic", "amount": 1}, "rarity": "legendary"},
	{"id": "league_elite", "name": "Elite da Liga", "description": "Alcance Diamante na Liga Neon.", "category": "liga", "required": 1, "metric": "league_diamond_reached", "reward": {"type": "chest", "chest": "rare", "amount": 1}, "rarity": "epic"},
	{"id": "competitive_legend", "name": "Lenda Competitiva", "description": "Alcance Lendário na Liga Neon.", "category": "liga", "required": 1, "metric": "league_legendary_reached", "reward": {"type": "legendaryKeys", "amount": 1}, "rarity": "legendary"},
	{"id": "trophy_king", "name": "Rei dos Troféus", "description": "Alcance Ultimate na Liga Neon.", "category": "liga", "required": 1, "metric": "league_ultimate_reached", "reward": {"type": "fragments", "skin_id": "league_king_neon", "amount": 70}, "rarity": "ultimate"},
	{"id": "inf_survive_1", "name": "Pulso Infinito", "description": "Sobreviva 1 minuto no Modo Infinito.", "category": "infinito", "required": 60, "metric": "infinite_best_seconds", "reward": {"type": "skin", "skin_id": "infinite_pulse"}, "rarity": "common"},
	{"id": "inf_survive_3", "name": "Loop Estável", "description": "Sobreviva 3 minutos no Modo Infinito.", "category": "infinito", "required": 180, "metric": "infinite_best_seconds", "reward": {"type": "skin", "skin_id": "loop_flame"}, "rarity": "rare"},
	{"id": "inf_survive_5", "name": "Eclipse Neon", "description": "Sobreviva 5 minutos no Modo Infinito.", "category": "infinito", "required": 300, "metric": "infinite_best_seconds", "reward": {"type": "skin", "skin_id": "neon_eclipse"}, "rarity": "epic"},
	{"id": "inf_survive_10", "name": "Núcleo Eterno", "description": "Sobreviva 10 minutos no Modo Infinito.", "category": "infinito", "required": 600, "metric": "infinite_best_seconds", "reward": {"type": "skin", "skin_id": "cosmic_fragment"}, "rarity": "legendary"},
	{"id": "inf_survive_15", "name": "Vórtice Mítico", "description": "Sobreviva 15 minutos no Modo Infinito.", "category": "infinito", "required": 900, "metric": "infinite_best_seconds", "reward": {"type": "skin", "skin_id": "infinite_vortex_mythic"}, "rarity": "mythic"},
	{"id": "inf_survive_20", "name": "Ômega Infinito", "description": "Sobreviva 20 minutos no Modo Infinito.", "category": "infinito", "required": 1200, "metric": "infinite_best_seconds", "reward": {"type": "skin", "skin_id": "omega_infinity"}, "rarity": "ultimate"},
	{"id": "inf_survive_30", "name": "Meia Hora Sem Fim", "description": "Sobreviva 30 minutos no Modo Infinito.", "category": "infinito", "required": 1800, "metric": "infinite_best_seconds", "reward": {"type": "legendaryKeys", "amount": 1}, "rarity": "ultimate"},
	{"id": "inf_rings_25", "name": "Vórtice Azul", "description": "Quebre 25 anéis em uma run infinita.", "category": "infinito", "required": 25, "metric": "infinite_best_rings", "reward": {"type": "skin", "skin_id": "blue_vortex"}, "rarity": "common"},
	{"id": "inf_rings_50", "name": "Cometa Rubro", "description": "Quebre 50 anéis em uma run infinita.", "category": "infinito", "required": 50, "metric": "infinite_best_rings", "reward": {"type": "skin", "skin_id": "red_comet"}, "rarity": "rare"},
	{"id": "inf_rings_100", "name": "Prisma Sem Fim", "description": "Quebre 100 anéis em uma run infinita.", "category": "infinito", "required": 100, "metric": "infinite_best_rings", "reward": {"type": "skin", "skin_id": "endless_prism"}, "rarity": "epic"},
	{"id": "inf_rings_150", "name": "Cortador de Loop", "description": "Quebre 150 anéis em uma run infinita.", "category": "infinito", "required": 150, "metric": "infinite_best_rings", "reward": {"type": "gems", "amount": 80}, "rarity": "legendary"},
	{"id": "inf_rings_300", "name": "Coroa da Singularidade", "description": "Quebre 300 anéis em uma run infinita.", "category": "infinito", "required": 300, "metric": "infinite_best_rings", "reward": {"type": "skin", "skin_id": "singularity_crown"}, "rarity": "ultimate"},
	{"id": "inf_challenge_1", "name": "Primeiro Desafio", "description": "Complete 1 seção difícil no Modo Infinito.", "category": "infinito", "required": 1, "metric": "infinite_challenge_completions", "reward": {"type": "keys", "amount": 1}, "rarity": "rare"},
	{"id": "inf_challenge_5", "name": "Núcleo Eterno", "description": "Complete 5 seções difíceis no Modo Infinito.", "category": "infinito", "required": 5, "metric": "infinite_challenge_completions", "reward": {"type": "skin", "skin_id": "eternal_core"}, "rarity": "legendary"},
	{"id": "inf_challenge_10", "name": "Loop Cronal", "description": "Complete 10 seções difíceis no Modo Infinito.", "category": "infinito", "required": 10, "metric": "infinite_challenge_completions", "reward": {"type": "skin", "skin_id": "chrono_loop_mythic"}, "rarity": "mythic"},
	{"id": "inf_level_5", "name": "Roguelike Neon I", "description": "Alcance nível 5 em uma run infinita.", "category": "infinito", "required": 5, "metric": "infinite_best_level", "reward": {"type": "coins", "amount": 1200}, "rarity": "epic"},
	{"id": "inf_level_10", "name": "Roguelike Neon II", "description": "Alcance nível 10 em uma run infinita.", "category": "infinito", "required": 10, "metric": "infinite_best_level", "reward": {"type": "gems", "amount": 100}, "rarity": "legendary"}
]

const WHEEL_REWARDS = [
	{"type": "coins", "amount": 180, "label": "+180 moedas"},
	{"type": "coins", "amount": 420, "label": "+420 moedas"},
	{"type": "gems", "amount": 6, "label": "+6 diamantes"},
	{"type": "gems", "amount": 14, "label": "+14 diamantes"},
	{"type": "keys", "amount": 1, "label": "+1 chave"},
	{"type": "chest", "chest": "common", "amount": 1, "label": "+1 baú comum"},
	{"type": "chest", "chest": "rare", "amount": 1, "label": "+1 baú raro"},
	{"type": "fragments", "amount": 20, "label": "+20 fragmentos"},
	{"type": "profile_xp", "amount": 120, "label": "+120 XP"},
	{"type": "chest", "chest": "epic", "amount": 1, "label": "+1 baú épico"}
]

const WEEKLY_EVENTS = [
	{"id": "neon", "name": "Evento Neon", "description": "Ritmo alto, combos e baús brilhantes.", "bonus": "+10% moedas da rodada e chance maior de skins elétricas.", "color": "#00f0ff", "grand_reward": {"type": "chest", "chest": "rare", "amount": 1}, "missions": [
		{"id": "neon_ringsDestroyed_500", "title": "Destruir 500 anéis", "metric": "rings_destroyed", "target": 500, "reward": {"type": "coins", "amount": 900}, "difficulty": 3},
		{"id": "neon_bestCombo_10", "title": "Fazer combo x10 cinco vezes", "metric": "best_combo", "target": 10, "reward": {"type": "gems", "amount": 18}, "difficulty": 2},
		{"id": "neon_chestsOpened_10", "title": "Abrir 10 baús", "metric": "chests_opened", "target": 10, "reward": {"type": "keys", "amount": 2}, "difficulty": 3}
	]},
	{"id": "frost", "name": "Evento Gelado", "description": "Congelar, desacelerar e coletar fragmentos.", "bonus": "Mais chance de slow/freeze e fragmentos de gelo.", "color": "#9be8ff", "grand_reward": {"type": "fragments", "amount": 55}, "missions": [
		{"id": "frost_perfectEscapes_35", "title": "Fazer 35 Perfect Escapes", "metric": "perfect_escapes", "target": 35, "reward": {"type": "gems", "amount": 22}, "difficulty": 3},
		{"id": "frost_ringsDestroyed_420", "title": "Destruir 420 anéis", "metric": "rings_destroyed", "target": 420, "reward": {"type": "fragments", "amount": 30}, "difficulty": 3},
		{"id": "frost_chestsOpened_6", "title": "Abrir 6 baús", "metric": "chests_opened", "target": 6, "reward": {"type": "keys", "amount": 1}, "difficulty": 2}
	]},
	{"id": "cosmic", "name": "Evento Cósmico", "description": "Fragmentos raros e chances cósmicas.", "bonus": "Pequena chance extra de fragmentos raros.", "color": "#b000ff", "grand_reward": {"type": "chest", "chest": "epic", "amount": 1}, "missions": [
		{"id": "cosmic_phaseWins_5", "title": "Vencer 5 fases", "metric": "phase_wins", "target": 5, "reward": {"type": "gems", "amount": 28}, "difficulty": 2},
		{"id": "cosmic_gemsEarned_12", "title": "Ganhar 12 diamantes", "metric": "diamonds_found", "target": 12, "reward": {"type": "fragments", "amount": 45}, "difficulty": 2},
		{"id": "cosmic_runsPlayed_12", "title": "Jogar 12 partidas", "metric": "runs_played", "target": 12, "reward": {"type": "profile_xp", "amount": 260}, "difficulty": 2}
	]},
	{"id": "flame", "name": "Evento Flamejante", "description": "Dano explosivo e fragmentos de fogo.", "bonus": "Habilidades de fogo causam mais dano.", "color": "#ff6b00", "grand_reward": {"type": "fragments", "amount": 60}, "missions": [
		{"id": "flame_criticals_40", "title": "Fazer 40 críticos", "metric": "criticals", "target": 40, "reward": {"type": "coins", "amount": 1200}, "difficulty": 2},
		{"id": "flame_skinEffects_35", "title": "Quebrar 35 anéis com efeito de skin", "metric": "skin_effects", "target": 35, "reward": {"type": "gems", "amount": 20}, "difficulty": 2},
		{"id": "flame_ringsDestroyed_600", "title": "Destruir 600 anéis", "metric": "rings_destroyed", "target": 600, "reward": {"type": "keys", "amount": 2}, "difficulty": 3}
	]},
	{"id": "ghost", "name": "Evento Fantasma", "description": "Sombras, fases e Perfects.", "bonus": "Skins fantasma/sombra melhoradas e bônus em Perfect Escapes.", "color": "#dff7ff", "grand_reward": {"type": "chest", "chest": "rare", "amount": 1}, "missions": [
		{"id": "ghost_perfectEscapes_50", "title": "Fazer 50 Perfect Escapes", "metric": "perfect_escapes", "target": 50, "reward": {"type": "gems", "amount": 32}, "difficulty": 3},
		{"id": "ghost_noReviveWins_3", "title": "Vencer 3 fases sem revive", "metric": "no_revive_wins", "target": 3, "reward": {"type": "legendaryKeys", "amount": 1}, "difficulty": 2},
		{"id": "ghost_runsPlayed_10", "title": "Jogar 10 partidas", "metric": "runs_played", "target": 10, "reward": {"type": "profile_xp", "amount": 220}, "difficulty": 2}
	]},
	{"id": "gold", "name": "Evento Dourado", "description": "Economia e ofertas simuladas.", "bonus": "+15% moedas gerais no fim da partida.", "color": "#ffd700", "grand_reward": {"type": "coins", "amount": 2200}, "missions": [
		{"id": "gold_runCoins_8000", "title": "Ganhar 8.000 moedas da rodada", "metric": "run_coins", "target": 8000, "reward": {"type": "gems", "amount": 25}, "difficulty": 3},
		{"id": "gold_storePurchases_5", "title": "Comprar 5 itens na loja", "metric": "store_purchases", "target": 5, "reward": {"type": "keys", "amount": 2}, "difficulty": 2},
		{"id": "gold_adsWatched_4", "title": "Usar 4 anúncios simulados", "metric": "ads_watched", "target": 4, "reward": {"type": "coins", "amount": 900}, "difficulty": 2}
	]},
	{"id": "chests", "name": "Evento dos Baús", "description": "Chaves, baús e descontos simulados.", "bonus": "Chance maior de ganhar chaves.", "color": "#00ff88", "grand_reward": {"type": "chest", "chest": "epic", "amount": 1}, "missions": [
		{"id": "chests_chestsOpened_10", "title": "Abrir 10 baús", "metric": "chests_opened", "target": 10, "reward": {"type": "keys", "amount": 3}, "difficulty": 3},
		{"id": "chests_storePurchases_6", "title": "Coletar 6 chaves", "metric": "store_purchases", "target": 6, "reward": {"type": "gems", "amount": 20}, "difficulty": 2},
		{"id": "chests_ringsDestroyed_450", "title": "Destruir 450 anéis", "metric": "rings_destroyed", "target": 450, "reward": {"type": "fragments", "amount": 36}, "difficulty": 3}
	]},
	{"id": "boss_rush", "name": "Evento Boss Rush", "description": "Duelos mais valiosos.", "bonus": "Recompensas melhores no Boss Mode.", "color": "#ff0055", "grand_reward": {"type": "legendaryKeys", "amount": 1}, "missions": [
		{"id": "boss_rush_bossRuns_5", "title": "Jogar 5 Boss Modes", "metric": "boss_runs", "target": 5, "reward": {"type": "coins", "amount": 1400}, "difficulty": 2},
		{"id": "boss_rush_bossWins_3", "title": "Vencer 3 Boss Modes", "metric": "boss_wins", "target": 3, "reward": {"type": "chest", "chest": "rare", "amount": 1}, "difficulty": 3},
		{"id": "boss_rush_criticals_25", "title": "Fazer 25 críticos", "metric": "criticals", "target": 25, "reward": {"type": "gems", "amount": 18}, "difficulty": 2}
	]},
	{"id": "perfect", "name": "Evento Perfect", "description": "Aberturas precisas e diamantes.", "bonus": "+chance de diamante em Perfect Escape.", "color": "#ffffff", "grand_reward": {"type": "gems", "amount": 45}, "missions": [
		{"id": "perfect_perfectEscapes_60", "title": "Fazer 60 Perfect Escapes", "metric": "perfect_escapes", "target": 60, "reward": {"type": "gems", "amount": 35}, "difficulty": 3},
		{"id": "perfect_bestCombo_20", "title": "Fazer combo x20", "metric": "best_combo", "target": 20, "reward": {"type": "keys", "amount": 2}, "difficulty": 2},
		{"id": "perfect_noReviveWins_4", "title": "Vencer 4 fases sem revive", "metric": "no_revive_wins", "target": 4, "reward": {"type": "chest", "chest": "rare", "amount": 1}, "difficulty": 2}
	]},
	{"id": "collector", "name": "Evento Colecionador", "description": "Fragmentos e coleção em foco.", "bonus": "Mais fragmentos em skins repetidas e bônus ao abrir baús.", "color": "#ff4fd8", "grand_reward": {"type": "chest", "chest": "epic", "amount": 1}, "missions": [
		{"id": "collector_chestsOpened_12", "title": "Abrir 12 baús", "metric": "chests_opened", "target": 12, "reward": {"type": "fragments", "amount": 70}, "difficulty": 3},
		{"id": "collector_skinEquips_3", "title": "Equipar 3 skins diferentes", "metric": "skin_equips", "target": 3, "reward": {"type": "gems", "amount": 18}, "difficulty": 2},
		{"id": "collector_skinEffects_3", "title": "Ganhar 3 skins ou fragmentos", "metric": "skin_effects", "target": 3, "reward": {"type": "profile_xp", "amount": 260}, "difficulty": 2}
	]}
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
	content.add_child(NeonUI.label("Rodízio local • %s" % TimeSystem.day_key(), 13, Color("#ffffff99")))
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
	content.add_child(_simple_card("Prêmio principal", _reward_text(event.grand_reward), "res://assets/ui/ui_daily_reward.png", Color("#ffd700")))
	for mission in event.missions:
		var value = _metric_value(mission.metric)
		var done = value >= int(mission.target)
		var claim_key = "%s_%s" % [TimeSystem.week_key(), mission.id]
		var claimed = bool(SaveSystem.get_save().timed.event_mission_claims.get(claim_key, false))
		_add_mission_card(mission, value, done, claimed, func(): _claim_event_mission(mission, claim_key), false, Color(event.color))
	var grand_claimed = String(SaveSystem.get_save().timed.event_grand_claimed_week) == TimeSystem.week_key()
	var grand = NeonUI.main_button("COLETAR PRÊMIO PRINCIPAL" if not grand_claimed else "JÁ COLETADO", Color(event.color), Color("#0088ff"), 54)
	grand.disabled = grand_claimed
	grand.pressed.connect(func():
		SaveSystem.grant_reward(event.grand_reward)
		SaveSystem.get_save().timed.event_grand_claimed_week = TimeSystem.week_key()
		SaveSystem.save_game()
		AudioManager.play_sfx("button_confirm")
	)
	content.add_child(grand)

func _build_wheel():
	content.add_child(NeonUI.label("1 giro grátis por dia - até 2 extras com vídeo recompensado", 13, Color("#ffffff99")))
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
	var result = _simple_card("Toque para girar", "Prêmio da roleta", "res://assets/ui/ui_wheel.png", Color("#00f0ff"))
	content.add_child(result)
	var save = SaveSystem.get_save()
	var free = NeonUI.main_button("GIRAR" if not bool(save.timed.wheel_free_used) else "GIRO GRÁTIS USADO", Color("#00f0ff"), Color("#0088ff"), 54)
	free.disabled = bool(save.timed.wheel_free_used)
	free.pressed.connect(_spin_wheel.bind(false))
	content.add_child(free)
	var ad = NeonUI.main_button("GIRAR NOVAMENTE COM ANÚNCIO (%d/2)" % int(save.timed.wheel_ad_spins_used), Color("#ffd700"), Color("#ff8800"), 54)
	ad.disabled = int(save.timed.wheel_ad_spins_used) >= 2
	ad.pressed.connect(_spin_wheel.bind(true))
	content.add_child(ad)

func _build_daily_reward():
	content.add_child(_hero("Recompensa Diária", "Volte todos os dias para receber um novo prêmio.", "res://assets/ui/ui_daily_reward.png", Color("#ffd700")))
	var reward_box = PanelContainer.new()
	reward_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	reward_box.add_theme_stylebox_override("panel", NeonUI.neon_box(Color("#ffffff12"), Color("#ffd70088"), 1, 16, 0.3))
	content.add_child(reward_box)
	var box = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	reward_box.add_child(box)
	box.add_child(NeonUI.icon("res://assets/ui/ui_daily_reward.png", 72))
	box.add_child(NeonUI.label("Coletar hoje" if SaveSystem.daily_reward_available() else "Coletada hoje", 24, Color("#ffd700"), HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(NeonUI.label("💎 18\n💰 350\n🔑 1", 22, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))
	var claim = NeonUI.main_button("COLETAR HOJE" if SaveSystem.daily_reward_available() else "VOLTE AMANHÃ", Color("#00f0ff"), Color("#0088ff"), 54)
	claim.disabled = not SaveSystem.daily_reward_available()
	claim.pressed.connect(_claim_daily)
	box.add_child(claim)

func _build_boss():
	var save = SaveSystem.get_save()
	var unlocked = int(save.lifetime_stats.highest_phase) >= 5 or int(save.profile_level) >= 5
	content.add_child(_hero("BOSS MODE", "Boss do mês: Fênix Solar", "res://assets/ui/ui_boss.png", Color("#ff0055")))
	if not unlocked:
		content.add_child(_simple_card("Bloqueado", "Complete a fase 5 ou alcance nível de perfil 5 para desbloquear.", "res://assets/ui/ui_locked.png", Color("#ffd700")))
	content.add_child(_simple_card("Fênix Solar", "Tema: solar/vermelho\nUm Boss que renasce em anéis sólidos.\nPassiva: Quebras sólidas dão mais moedas ao Boss.", "res://assets/images/skins/neon_phoenix.png", Color("#ff0055")))
	content.add_child(_simple_card("Progresso", "Nível atual: Normal\nVitórias hoje: %d/5\nMelhor nível do mês: Nenhum\nReset diário: %s" % [int(save.lifetime_stats.get("boss_wins", 0)), TimeSystem.format_timer(TimeSystem.seconds_until_next_day())], "res://assets/ui/ui_xp.png", Color("#00f0ff")))
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
	content.add_child(_summary_row([["Sua posição", "#87/201"], ["Troféus", str(trophies)], ["Temporada", "28d"]]))
	content.add_child(_simple_card("Bronze", "%d troféus até Prata\nSequência: 0 • Melhor: 0" % max(0, 300 - trophies), "res://assets/ui/ui_league_neon.png", Color("#00ff88"), "COMPETIR", "game"))
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
	content.add_child(_simple_card("Recompensa estimada", "Moedas, fragmentos e chave comum.\nFaltam 120 troféus para subir uma posição.", "res://assets/ui/ui_achievements.png", Color("#00ff88")))
	for i in range(12):
		var name = ["Você", "NovaPulse", "RiftCore", "CyberPanda", "VoidCat", "PlasmaPig", "FrostByte", "FireOrb", "LuckySlime", "GhostRunner", "DiamondEye", "SolarKid"][i]
		content.add_child(_league_row(i + 1, name, max(0, trophies + 420 - i * 88), i == 0))

func _build_achievements():
	var completed = 0
	for achievement in ACHIEVEMENTS:
		if _metric_value(achievement.metric) >= int(achievement.required):
			completed += 1
	content.add_child(NeonUI.label("%d/%d concluídas • %d pendentes" % [completed, ACHIEVEMENTS.size(), _pending_achievements()], 14, Color("#ffffffaa")))
	content.add_child(_achievement_champion_box())
	for achievement in ACHIEVEMENTS:
		_add_achievement_card(achievement)

func _build_settings():
	var save = SaveSystem.get_save()
	content.add_child(_profile_card(save))
	content.add_child(_account_card(save))
	content.add_child(_toggle_card("SOM", [["Música", "music"], ["Efeitos", "sound"], ["Tudo", "sound"]]))
	content.add_child(_options_card("DESEMPENHO", "FPS do jogo", ["30 FPS", "45 FPS", "60 FPS", "90 FPS", "120 FPS"]))
	content.add_child(_options_card("IDIOMA", "Selecione o idioma", ["Português", "English", "Español", "Français", "Deutsch", "日本語"]))
	content.add_child(_simple_card("LIGA NEON", "Posição atual: #87/201\nDivisão atual: Bronze\nTroféus: 80\nMelhor divisão: Bronze", "res://assets/ui/ui_league_neon.png", Color("#ffd700"), "ABRIR LIGA NEON", "league"))
	content.add_child(_simple_card("ESTATÍSTICAS", "Partidas: %d\nAnéis destruídos: %d\nEscapes perfeitos: %d\nDiamantes encontrados: %d\nBaús abertos: %d\nSkins desbloqueadas: %d" % [save.lifetime_stats.runs_played, save.lifetime_stats.rings_destroyed, save.lifetime_stats.perfect_escapes, save.lifetime_stats.diamonds_found, save.lifetime_stats.chests_opened, save.unlocked_skins.size()], "res://assets/ui/ui_profile.png", Color("#00f0ff")))

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
		reroll.pressed.connect(func(): _ad_action_message("Missão atualizada."))
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
	info.add_child(NeonUI.label("%s%s" % [name, " (Você)" if is_player else ""], 14, Color.WHITE))
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
	box.add_child(NeonUI.label("Campeão dos 50 Estágios", 14, Color("#ffd700")))
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
	box.add_child(NeonUI.label("Nível %d" % int(save.profile_level), 24, Color("#ffd700")))
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
	return WEEKLY_EVENTS[_seeded_index(TimeSystem.week_key(), WEEKLY_EVENTS.size())]

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
	if metric in ["rare_skins_unlocked", "epic_skins_unlocked", "legendary_skins_unlocked"]:
		var rarity = metric.replace("_skins_unlocked", "")
		var total = 0
		for skin_id in save.unlocked_skins:
			if GameData.get_skin(skin_id).get("rarity", "") == rarity:
				total += 1
		return total
	if metric == "league_competitions_played":
		return int(save.lifetime_stats.get("league_competition_wins", 0)) + int(save.lifetime_stats.get("league_competition_losses", 0))
	if metric == "total_trophies_gained":
		return int(save.lifetime_stats.get("total_trophies_gained", 0))
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
			return "🎁 Baú %s" % String(reward.get("chest", "common"))
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
			return "MISSÕES DIÁRIAS"
		"event":
			return "EVENTO"
		"wheel":
			return "ROLETA"
		"daily_reward":
			return "RECOMPENSA DIÁRIA"
		"boss":
			return "BOSS"
		"league":
			return "LIGA NEON"
		"achievements":
			return "CONQUISTAS"
		"settings":
			return "PERFIL"
	return "MENU"

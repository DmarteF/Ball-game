extends Node


func get_all_upgrades() -> Array[Dictionary]:
	return GameState.get_all_upgrades()


func get_unlocked_upgrades() -> Array[Dictionary]:
	return GameState.get_unlocked_upgrades()


func get_locked_upgrades() -> Array[Dictionary]:
	return GameState.get_locked_upgrades()


func get_gameplay_upgrade_pool() -> Array[Dictionary]:
	return GameState.get_gameplay_upgrade_pool()


func unlock_upgrade(id: String) -> bool:
	return GameState.unlock_upgrade(id)


func upgrade_with_coins(id: String) -> Dictionary:
	return GameState.upgrade_with_coins(id)


func upgrade_with_diamonds(id: String) -> Dictionary:
	return GameState.upgrade_with_diamonds(id)


func debug_upgrade_state() -> Dictionary:
	return GameState.debug_upgrade_state()

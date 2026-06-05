extends Node

const STARTER_UPGRADE_IDS := ["damage", "speed", "coinBoost", "critical"]
const TOTAL_UPGRADES := 34


func get_all_upgrades() -> Array[Dictionary]:
	return MainPortData.run_upgrades()


func get_all_upgrade_ids() -> Array[String]:
	return MainPortData.all_run_upgrade_ids()


func get_upgrade(id: String) -> Dictionary:
	return MainPortData.upgrade_by_id(id)


func has_upgrade(id: String) -> bool:
	return MainPortData.is_run_upgrade_defined(id)


func starter_upgrade_ids() -> Array[String]:
	var result: Array[String] = []
	for id in STARTER_UPGRADE_IDS:
		result.append(String(id))
	return result


func total_upgrades() -> int:
	return get_all_upgrade_ids().size()

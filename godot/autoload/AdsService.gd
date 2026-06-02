extends Node

signal reward_started(placement)
signal reward_finished(placement)

var mock_delay_seconds = 0.35
var enabled = true

func show_rewarded(placement):
	if not enabled:
		return false
	reward_started.emit(placement)
	await get_tree().create_timer(mock_delay_seconds).timeout
	reward_finished.emit(placement)
	return true


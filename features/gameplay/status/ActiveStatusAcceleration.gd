extends ActiveStatus

class_name ActiveStatusAcceleration

func enable() -> void:
	_owner_character.on_acceleration_tick_phase.connect(_on_acceleration_tick_phase)

func _on_acceleration_tick_phase() -> void:
	if _owner_character is EnemyCharacter:
		if not BattleStageManager.enemies_waiting_to_perform_move.has(_owner_character):
			_owner_character.update_move_points(1)
			remove(1)
	else:
		_owner_character.hand.draw_cards(1)
		remove(1)

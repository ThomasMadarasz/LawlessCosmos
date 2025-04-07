extends EnemyMoveTargets

class_name EnemyMoveTargetsRandomPlayer

func get_targeted_slots(move : Move) -> Array[int]:
	if move.current_slot_target == null: move.current_slot_target = CharactersManager.get_player_filled_slots().pick_random()
	return [move.current_slot_target]

func get_formatted_name() -> String:
	return tr("RANDOM_PLAYER")

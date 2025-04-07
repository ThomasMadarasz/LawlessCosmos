extends EnemyMoveTargets

class_name EnemyMoveTargetsClosestPlayer

func get_targeted_slots(_move : Move) -> Array[int]:
	return [CharactersManager.get_player_filled_slots().front()]

func get_formatted_name() -> String:
	return tr("CLOSEST_PLAYER")

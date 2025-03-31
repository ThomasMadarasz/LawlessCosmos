extends EnemyMoveTargets

class_name EnemyMoveTargetsSelf

func get_targeted_slots(move : Move) -> Array[int]:
	return [move.owner_character.position_id]

func get_formatted_name() -> String:
	return tr("SELF")

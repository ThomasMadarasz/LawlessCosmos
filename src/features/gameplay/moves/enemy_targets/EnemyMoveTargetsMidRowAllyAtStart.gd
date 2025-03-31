extends EnemyMoveTargets

class_name EnemyMoveTargetsMidRowAllyAtStart

func get_targeted_slots(move : Move) -> Array[int]:
	var target = move.owner_character.enemies_by_position_at_start[1] if not move.owner_character.enemies_by_position_at_start[1].is_dead else null
	if target == null:
		target = CharactersManager.enemy_characters.pick_random()
	return [target.position_id]

func get_formatted_name() -> String:
	return tr("MID_ROW_ALLY_AT_START")

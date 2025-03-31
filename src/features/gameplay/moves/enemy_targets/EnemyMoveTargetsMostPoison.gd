extends EnemyMoveTargets

class_name EnemyMoveTargetsMostPoison

func get_targeted_slots(move : Move) -> Array[int]:
	var target = CharactersManager.player_characters.pick_random() if move.current_slot_target == null else CharactersManager.players_positions_by_id[move.current_slot_target]
	var current_top_poison = target.status.current_status.count(CharacterStatus.Status.POISON)
	for n in CharactersManager.player_characters:
		if n.status.current_status.count(CharacterStatus.Status.POISON) > current_top_poison:
			target = n
	move.current_slot_target = target.position_id
	return[move.current_slot_target]

func get_formatted_name() -> String:
	return tr("MOST_BLEED")

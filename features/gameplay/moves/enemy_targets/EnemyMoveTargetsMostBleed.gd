extends EnemyMoveTargets

class_name EnemyMoveTargetsMostBleed

func get_targeted_slots(move : Move) -> Array[int]:
	var target: Character = CharactersManager.player_characters.pick_random() if move.current_slot_target == null else CharactersManager.players_positions_by_id[move.current_slot_target]
	var current_top_bleed: int = target.status.get_status_count("bleed")
	for n: Character in CharactersManager.player_characters:
		if n.status.get_status_count("bleed") > current_top_bleed:
			target = n
	move.current_slot_target = target.position_id
	return[move.current_slot_target]

func get_formatted_name() -> String:
	return tr("MOST_BLEED")

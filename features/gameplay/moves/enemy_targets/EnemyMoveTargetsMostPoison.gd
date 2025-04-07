extends EnemyMoveTargets

class_name EnemyMoveTargetsMostPoison

func get_targeted_slots(move : Move) -> Array[int]:
	var target: Character = CharactersManager.player_characters.pick_random() if move.current_slot_target == null else CharactersManager.players_positions_by_id[move.current_slot_target]
	var current_top_poison: int =  target.status.active_statuses_ids["poison"].count if target.has_status("poison") else 0
	for n: Character in CharactersManager.player_characters:
		if n.status.active_statuses_ids["poison"].count if target.has_status("poison") else 0 > current_top_poison:
			target = n
	move.current_slot_target = target.position_id
	return[move.current_slot_target]

func get_formatted_name() -> String:
	return tr("MOST_BLEED")

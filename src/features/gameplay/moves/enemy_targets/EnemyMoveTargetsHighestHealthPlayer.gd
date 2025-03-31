extends EnemyMoveTargets

class_name EnemyMoveTargetsHighestHealthPlayer

## Dynamic

func get_targeted_slots(move : Move) -> Array[int]:
	var highest_player = null
	for n in CharactersManager.player_characters:
		if n == null: continue
		if highest_player == null or float(highest_player.character_resource.current_health) / float(highest_player.max_health) < float(n.character_resource.current_health) / float(n.max_health): 
			highest_player = n
	move.current_slot_target = highest_player.position_id
	return [move.current_slot_target]

func get_formatted_name() -> String:
	return tr("LOWEST_HEALTH_PLAYER")

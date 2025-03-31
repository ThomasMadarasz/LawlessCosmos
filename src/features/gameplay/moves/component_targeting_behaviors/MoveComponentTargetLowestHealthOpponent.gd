extends MoveComponentTargetingBehavior

class_name MoveComponentTargetLowestHealthOpponent

func get_targets(move_solver : MoveSolver) -> Array[Character]:
	var lowest_enemy = null
	var characters = CharactersManager.get_opponents_characters(move_solver.owner_character)
	for n in characters:
		if n == null: continue
		if lowest_enemy == null or lowest_enemy.character_resource.current_health / float(lowest_enemy.character_resource.max_health) > n.character_resource.current_health / float(n.character_resource.max_health) : 
			lowest_enemy = n
	return [lowest_enemy]

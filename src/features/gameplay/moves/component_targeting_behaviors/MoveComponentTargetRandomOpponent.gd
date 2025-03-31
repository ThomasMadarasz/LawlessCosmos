extends MoveComponentTargetingBehavior

class_name MoveComponentTargetRandomOpponent

func get_targets(move_solver : MoveSolver) -> Array[Character]:
	return [CharactersManager.get_opponents_characters(move_solver.owner_character).pick_random()]

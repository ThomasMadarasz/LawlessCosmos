extends MoveComponentTargetingBehavior

class_name MoveComponentTargetAllAllies

func get_targets(move_solver : MoveSolver) -> Array[Character]:
	return CharactersManager.get_allies_characters(move_solver.owner_character).duplicate()

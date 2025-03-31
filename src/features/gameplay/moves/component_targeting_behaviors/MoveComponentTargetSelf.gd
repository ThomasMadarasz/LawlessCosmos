extends MoveComponentTargetingBehavior

class_name MoveComponentTargetSelf

func get_targets(move_solver : MoveSolver) -> Array[Character]:
	return [move_solver.owner_character]

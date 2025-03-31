extends MoveComponentTargetingBehavior

class_name MoveComponentTargetMain

func get_targets(move_solver : MoveSolver) -> Array[Character]:
	return move_solver.initial_targets.duplicate()

extends MoveComponentTargetingBehavior

class_name MoveComponentTargetCrossed

func get_targets(move_solver : MoveSolver) -> Array[Character]:
	return move_solver.crossed_characters.duplicate()

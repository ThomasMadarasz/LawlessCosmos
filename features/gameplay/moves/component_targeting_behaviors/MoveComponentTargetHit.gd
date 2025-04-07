extends MoveComponentTargetingBehavior

class_name MoveComponentTargetHit

func get_targets(move_solver : MoveSolver) -> Array[Character]:
	return move_solver.hit_targets.duplicate()

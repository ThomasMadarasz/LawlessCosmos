extends MoveComponent

class_name MoveComponentMoveToBack

func perform() -> void:
	_move_solver.crossed_characters.clear()
	for _n: int in _targets.size():
		var target: Character = _targets[0]
		_targets.erase(target)
		_move_solver.crossed_characters = target.move_to_back_row()
	return

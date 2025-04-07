extends MoveComponent

class_name MoveComponentSwitchPosition

func perform() -> void:
	for _n: int in _targets.size():
		var target: Character = _targets[0]
		_targets.erase(target)
		_move_solver.owner_character.switch_with_target(target)
	return

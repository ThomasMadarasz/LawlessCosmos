extends MoveComponent

class_name MoveComponentAddBleed

@export var _bleed_percentage: float = 0.1

func perform() -> void:
	for n: int in _targets.size():
		var target: Character = _targets[0]
		_targets.erase(target)
		target.status.add_status("bleed", roundi(_move_solver.health_lost * _bleed_percentage), _owner_character)
	return

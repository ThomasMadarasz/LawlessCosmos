extends MoveComponent

class_name MoveComponentAddShield

func perform() -> void:
	for _n: int in _targets.size():
		var target: Character = _targets[0]
		_targets.erase(target)
		target.add_shield(_move.final_power)
	return

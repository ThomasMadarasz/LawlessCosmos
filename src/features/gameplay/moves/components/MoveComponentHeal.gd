extends MoveComponent

class_name MoveComponentHeal

func perform() -> void:
	for n in _targets.size():
		var target = _targets[0]
		_targets.erase(target)
		target.heal(_move.final_power)
	return

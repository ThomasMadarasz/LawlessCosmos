extends MoveComponent

class_name MoveComponentDamage

@export var _damage_multiplier : float

func perform() -> void:
	_move_solver.health_lost = 0
	for n in _targets.size():
		var target = _targets[0]
		_targets.erase(target)
		_move_solver.health_lost += target.take_damage(roundi(_move.final_power * _damage_multiplier), _owner_character)
	return

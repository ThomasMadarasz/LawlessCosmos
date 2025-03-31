extends MoveComponent

class_name MoveComponentAttackDistanceFactor

@export var _distance_factor : float = 0.2

func perform() -> void:
	_move_solver.hit_targets.clear()
	_move_solver.health_lost = 0
	for n in _targets.size():
		var target = _targets[0]
		_targets.erase(target)
		var damage_multiplier = 1.0 - ((_owner_character.position_id + target.position_id) * _distance_factor)
		var results = _move.attack_target(_move.final_power * damage_multiplier, target, not _move.current_targets_count == 1)
		if not _move_solver.hit_targets.has(results[0]): _move_solver.hit_targets.push_back(results[0])
		_move_solver.health_lost += results[1]
	return

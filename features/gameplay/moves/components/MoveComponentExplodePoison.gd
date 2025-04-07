extends MoveComponent

class_name MoveComponentExplodePoison

@export var _damage_percentage_per_poison_stack: float = 0.1

func perform() -> void:
	for _n: int in _targets.size():
		var target: Character = _targets[0]
		_targets.erase(target)
		var poison_amount: int = target.status.active_statuses_ids["poison"].count if target.has_status("poison") else 0
		target.status.consume_status("poison", poison_amount)
		target.take_damage(roundi(target.max_health * _damage_percentage_per_poison_stack * poison_amount), target, true)
	return

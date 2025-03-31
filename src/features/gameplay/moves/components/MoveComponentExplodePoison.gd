extends MoveComponent

class_name MoveComponentExplodePoison

@export var _damage_percentage_per_poison_stack: float = 0.1

func perform() -> void:
	for n in _targets.size():
		var target = _targets[0]
		_targets.erase(target)
		var poison_amount = target.status.current_status.count(CharacterStatus.Status.POISON)
		target.status.consume_status(CharacterStatus.Status.POISON, poison_amount)
		target.take_damage(roundi(target.max_health * _damage_percentage_per_poison_stack * poison_amount), target, true)
	return

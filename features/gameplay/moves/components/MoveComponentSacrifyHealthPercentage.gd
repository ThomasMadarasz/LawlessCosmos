extends MoveComponent

class_name MoveComponentSacrifyHealthPercentage

@export var _health_percentage : float

func perform() -> void:
	for _n: int in _targets.size():
		var target: Character = _targets[0]
		_targets.erase(target)
		target.take_damage(roundi(target.character_resource.current_health * _health_percentage), target, true)
	return

extends MoveComponent

class_name MoveComponentDie

func perform() -> void:
	for n in _targets.size():
		var target = _targets[0]
		_targets.erase(target)
		target.take_damage(target.character_resource.current_health, _move.owner_character, true)

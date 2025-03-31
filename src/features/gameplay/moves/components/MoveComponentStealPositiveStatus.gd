extends MoveComponent

class_name MoveComponentStealPositiveStatus

@export var _max_status : MoveComponentValue

func perform() -> void:
	for n in _targets.size():
		var target = _targets[0]
		_targets.erase(target)
		_steal_positive_status(target, _max_status.get_value(_owner_character))
	return

func _steal_positive_status(target: Character, amount: int) -> void:
	var target_positive_status = target.status.get_positive_status()
	for i in amount:
		if target_positive_status.size() > 0:
			var status = target_positive_status.pick_random()
			if target.status.current_status.has(status):
				_owner_character.status.add_status(status, 1, _owner_character)
				target.status.consume_status(status)

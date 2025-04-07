extends MoveComponent

class_name MoveComponentAddAcceleration

@export var _acceleration_amount : MoveComponentValue

func perform() -> void:
	for n: int in _targets.size():
		var target: Character = _targets[0]
		_targets.erase(target)
		target.status.add_status("acceleration", _acceleration_amount.get_value(_owner_character), _owner_character)
	return

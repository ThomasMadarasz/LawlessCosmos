extends MoveComponent

class_name MoveComponentAddParalysis

@export var _paralysis_amount : MoveComponentValue

func perform() -> void:
	for _n: int in _targets.size():
		var target: Character = _targets[0]
		_targets.erase(target)
		target.status.add_status("paralysis", _paralysis_amount.get_value(_owner_character), _owner_character)
	return

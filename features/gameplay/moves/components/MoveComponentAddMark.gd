extends MoveComponent

class_name MoveComponentAddMark

@export var _mark_amount : MoveComponentValue

func perform() -> void:
	for _n: int in _targets.size():
		var target: Character = _targets[0]
		_targets.erase(target)
		target.status.add_status("mark", _mark_amount.get_value(_owner_character), _owner_character)
	return

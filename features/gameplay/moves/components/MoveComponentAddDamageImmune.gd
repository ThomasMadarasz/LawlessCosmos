extends MoveComponent

class_name MoveComponentAddDamageImmune

@export var _damage_immune_amount : MoveComponentValue

func perform() -> void:
	for _n: int in _targets.size():
		var target: Character = _targets[0]
		_targets.erase(target)
		target.status.add_status("damage_immune", _damage_immune_amount.get_value(_owner_character), _owner_character)
	return

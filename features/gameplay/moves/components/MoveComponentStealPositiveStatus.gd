extends MoveComponent

class_name MoveComponentStealPositiveStatus

@export var _max_status : MoveComponentValue

func perform() -> void:
	for n: int in _targets.size():
		var target: Character = _targets[0]
		_targets.erase(target)
		_steal_positive_status(target, _max_status.get_value(_owner_character))
	return

func _steal_positive_status(target: Character, amount: int) -> void:
	for i: int  in amount:
		var target_positive_status_ids: Dictionary = target.status.get_positive_statuses_ids()
		if target_positive_status_ids.size() > 0:
			var status_key: StringName = target_positive_status_ids.keys().pick_random()
			_owner_character.status.add_status(status_key, 1, _owner_character)
			target.status.consume_status(status_key)

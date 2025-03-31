extends MoveComponent

class_name MoveComponentMultiHits

@export var _hit_amount : MoveComponentValue
@export var _time_between_hits : float

func get_hit_amount() -> int:
	return _hit_amount.get_value(_owner_character)

func get_time_between_hits() -> float:
	return _time_between_hits

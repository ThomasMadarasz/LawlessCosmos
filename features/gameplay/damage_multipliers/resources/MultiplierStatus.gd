extends DamageMultiplierEvaluator

class_name MultiplierStatus

@export var _status_id: StringName

func get_damage_multiplier(_character: Character = null, target : Character = null) -> float:
	var value : bool = not target == null and target.has_status(_status_id)
	return _multiplier_value if value else 1.0

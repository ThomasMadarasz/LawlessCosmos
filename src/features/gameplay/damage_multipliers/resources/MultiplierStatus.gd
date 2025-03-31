extends DamageMultiplierEvaluator

class_name MultiplierStatus

@export var _status: CharacterStatus.Status

func get_damage_multiplier(_character: Character = null, target : Character = null) -> float:
	var value = not target == null and target.status.current_status.has(_status)
	return _multiplier_value if value else 1.0

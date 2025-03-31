extends Resource

class_name DamageMultiplierEvaluator

@export var _multiplier_value : float

func get_damage_multiplier(_character: Character = null, _target : Character = null) -> float:
	return _multiplier_value

func format_name(name: String) -> String:
	return name

func format_description(description: String) -> String:
	return description

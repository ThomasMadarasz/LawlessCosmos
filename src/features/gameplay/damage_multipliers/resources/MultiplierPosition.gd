extends DamageMultiplierEvaluator

class_name MultiplierPosition

@export var _position_id: int

func get_damage_multiplier(character: Character = null, _target : Character = null) -> float:
	return _multiplier_value if character.position_id == _position_id else 1.0

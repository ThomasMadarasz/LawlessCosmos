extends DamageMultiplierEvaluator

class_name MultiplierSuitCombinations

@export var _suit: Enums.Suits

func get_damage_multiplier(character: Character = null, target : Character = null) -> float:
	var current_hand = character.hand.current_final_hand
	var value = _multiplier_value if current_hand.available_suits.has(_suit) else 1.0
	return value

#Not working as intended. It is multiplying all moves when there is the suit in the combinations even if this isn't the suit of the move.

extends DamageMultiplierEvaluator

class_name MultiplierRankingCombinations

@export var _ranking : Enums.HandRankings

func get_damage_multiplier(character: Character = null, _target : Character = null) -> float:
	var current_hand = character.hand.current_final_hand
	var value = _multiplier_value if current_hand.hand_ranking == _ranking else 1.0
	return value

func format_name(name: String) -> String:
	return name.format({"HAND_RANKING" : tr(Enums.HandRankings.keys()[_ranking])})

func format_description(description: String) -> String:
	return description.format({"HAND_RANKING" : tr(Enums.HandRankings.keys()[_ranking])})

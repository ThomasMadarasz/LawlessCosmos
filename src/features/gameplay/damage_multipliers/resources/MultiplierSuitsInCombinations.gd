extends DamageMultiplierEvaluator

class_name MultiplierSuitsInCombinations

@export var _increasing_suit: Enums.Suits
@export var _decreasing_suit: Enums.Suits

@export var _decreasing_value: float = 0.05

func get_damage_multiplier(character: Character = null, _target : Character = null) -> float:
	var current_multiplier_value = 1.0
	var final_hand = character.hand.current_final_hand
	for n in final_hand.counting_cards.keys():
		if final_hand.counting_cards[n]:
			if n.suit == _increasing_suit: current_multiplier_value += _multiplier_value
			elif n.suit == _decreasing_suit: current_multiplier_value -= _decreasing_value
	return current_multiplier_value

func format_name(name: String) -> String:
	return name.format({"SUIT_1" : tr(Enums.Suits.keys()[_increasing_suit] + "S"), "SUIT_2" : tr(Enums.Suits.keys()[_decreasing_suit] + "S")})

func format_description(description: String) -> String:
	return description.format({"SUIT_1" : tr(Enums.Suits.keys()[_increasing_suit]), "SUIT_2" : tr(Enums.Suits.keys()[_decreasing_suit])})

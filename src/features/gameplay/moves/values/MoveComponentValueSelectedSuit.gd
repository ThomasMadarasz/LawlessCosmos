extends MoveComponentValue

class_name MoveComponentValueSelectedSuit

func get_value(character: Character) -> int:
	if character is EnemyCharacter: printerr("Trying to get selected suit amount on Enemy Character")
	var final_hand_data = character.hand.current_final_hand
	return final_hand_data.get_suit_amount(final_hand_data.chosen_suit)

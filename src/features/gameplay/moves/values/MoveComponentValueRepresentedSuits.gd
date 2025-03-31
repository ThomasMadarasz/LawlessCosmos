extends MoveComponentValue

class_name MoveComponentValueRepresentedSuits

func get_value(character: Character) -> int:
	if character is EnemyCharacter: printerr("Trying to get represented suits amount on Enemy Character")
	var final_hand_data = character.hand.current_final_hand
	return final_hand_data.available_suits.size()

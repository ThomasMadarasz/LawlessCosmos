extends MoveComponentValue

class_name MoveComponentValueUnusedCards

func get_value(character: Character) -> int:
	if character is EnemyCharacter: printerr("Trying to get represented suits amount on Enemy Character")
	return 5 - character.hand.current_final_hand.counting_cards.values().size()

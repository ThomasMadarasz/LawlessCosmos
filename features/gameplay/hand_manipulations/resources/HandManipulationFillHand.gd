extends HandManipulationResource

class_name HandManipulationFillHand

func activate_hand_manipulation() -> void:
	var selected_character: Character = CharactersManager.selected_character
	super.activate_hand_manipulation()
	var amount: int = selected_character.character_resource.hand_data.draw_limit - selected_character.hand.current_cards.size()
	if amount <= 0:
		disable_hand_manipulation()
		return
	for _n: int in amount:
		selected_character.hand.draw_cards(1)
	super.use_hand_manipulation()

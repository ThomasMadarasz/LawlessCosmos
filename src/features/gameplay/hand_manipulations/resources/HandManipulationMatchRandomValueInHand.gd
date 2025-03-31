extends HandManipulationResource

class_name HandManipulationMatchRandomValueInHand

func activate_hand_manipulation() -> void:
	super.activate_hand_manipulation()
	CharactersManager.is_a_hand_manipulation_enabled = true
	InputManager.on_card_clicked.connect(_on_card_clicked)

func _on_card_clicked(card: Card) -> void:
	var cards = card.owner_hand.current_cards.keys().duplicate()
	cards.erase(card)
	var new_value = cards.pick_random().card_resource.value_id
	_modify_value(card, new_value)
	CharactersManager.set_selected_character(card.owner_hand.owner_character)
	super.use_hand_manipulation()


func disable_hand_manipulation() -> void:
	for n in InputManager.on_card_clicked.get_connections():
		if n["callable"] == _on_card_clicked: InputManager.on_card_clicked.disconnect(_on_card_clicked)
	super.disable_hand_manipulation()

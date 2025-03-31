extends HandManipulationResource

class_name HandManipulationMagnetValue

func activate_hand_manipulation() -> void:
	super.activate_hand_manipulation()
	InputManager.on_card_clicked.connect(_on_card_clicked)

func _on_card_clicked(card: Card) -> void:
	var hands_to_search = []
	for n in CharactersManager.player_characters:
		if not n.hand == card.owner_hand:
			hands_to_search.push_back(n.hand)
	var cards_to_attract = []
	for hand in hands_to_search:
		for n in hand.current_cards.keys():
			if n.card_resource.value_id == card.card_resource.value_id:
				cards_to_attract.push_back(n)
	if card.owner_hand.current_cards.size() + cards_to_attract.size() > card.owner_hand.owner_character.character_resource.hand_data.max_hand_size:
		card.owner_hand.show_hand_full_pop_up()
		disable_hand_manipulation()
		return
	for n in cards_to_attract:
		var ex_owner_hand = n.owner_hand
		var new_owner_hand = card.owner_hand
		if new_owner_hand.is_hand_full(true):
			disable_hand_manipulation()
			return
		ex_owner_hand.current_cards_order.erase(n)
		ex_owner_hand.current_cards.erase(n)
		n.get_parent().remove_child(n)
		new_owner_hand.cards_holder.add_child(n)
		n.owner_hand = new_owner_hand
		new_owner_hand.current_cards_order.append(n)
		new_owner_hand.current_cards[n] = n.card_resource
	super.use_hand_manipulation()

func disable_hand_manipulation() -> void:
	for n in InputManager.on_card_clicked.get_connections():
			if n["callable"] == _on_card_clicked: InputManager.on_card_clicked.disconnect(_on_card_clicked)
	super.disable_hand_manipulation()

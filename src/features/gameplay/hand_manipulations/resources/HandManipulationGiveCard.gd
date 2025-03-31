extends HandManipulationResource

class_name HandManipulationGiveCard

func activate_hand_manipulation() -> void:
	super.activate_hand_manipulation()
	InputManager.on_card_dropped.connect(_on_card_dropped)

func _on_card_dropped(card: Card, target_hand: Hand) -> void:
	if target_hand == null: return
	var ex_owner_hand = card.owner_hand
	var new_owner_hand = target_hand
	if new_owner_hand.is_hand_full(true):
		disable_hand_manipulation()
		return
	if target_hand == null or card.is_locked or ex_owner_hand == new_owner_hand: 
		disable_hand_manipulation()
		return
	ex_owner_hand.current_cards_order.erase(card)
	ex_owner_hand.current_cards.erase(card)
	card.get_parent().remove_child(card)
	new_owner_hand.cards_holder.add_child(card)
	card.owner_hand = new_owner_hand
	new_owner_hand.current_cards_order.append(card)
	new_owner_hand.current_cards[card] = card.card_resource
	CharactersManager.set_selected_character(target_hand.owner_character)
	super.use_hand_manipulation()


func disable_hand_manipulation() -> void:
	for n in InputManager.on_card_dropped.get_connections():
		if n["callable"] == _on_card_dropped: InputManager.on_card_dropped.disconnect(_on_card_dropped)
	super.disable_hand_manipulation()

extends HandManipulationResource

class_name HandManipulationMagnetValuePile

@export var _is_discard_pile: bool #false is deck
@export var _is_only_first_card: bool #false is all available cards

func activate_hand_manipulation() -> void:
	super.activate_hand_manipulation()
	InputManager.on_card_clicked.connect(_on_card_clicked)

func _on_card_clicked(card: Card) -> void:
	var cards_resources_list = BattleStageManager.current_deck.deck_resource.discarded_cards_resources if _is_discard_pile else BattleStageManager.current_deck.deck_resource.cards_resources
	var pile_label = BattleStageManager.current_deck.discard_pile_label if _is_discard_pile else BattleStageManager.current_deck.deck_label
	var cards_to_attract = []
	for card_resource in cards_resources_list:
		if card_resource.value_id == card.card_resource.value_id:
			cards_to_attract.push_back(card_resource)
			if _is_only_first_card:
				break
	if cards_to_attract.size() == 0:
		#add feedback that there is no cards with this value in pile
		disable_hand_manipulation()
		return
		
	if card.owner_hand.current_cards.size() + cards_to_attract.size() > card.owner_hand.owner_character.character_resource.hand_data.max_hand_size:
		card.owner_hand.show_hand_full_pop_up()
		disable_hand_manipulation()
		return
	for n in cards_to_attract:
		cards_resources_list.erase(n)
		pile_label.text = str(cards_resources_list.size())
		card.owner_hand.draw_specific_card(n, BattleStageManager.current_deck.discard_pile.global_position if _is_discard_pile else BattleStageManager.current_deck.global_position)
	super.use_hand_manipulation()

func disable_hand_manipulation() -> void:
	for n in InputManager.on_card_clicked.get_connections():
			if n["callable"] == _on_card_clicked: InputManager.on_card_clicked.disconnect(_on_card_clicked)
	super.disable_hand_manipulation()

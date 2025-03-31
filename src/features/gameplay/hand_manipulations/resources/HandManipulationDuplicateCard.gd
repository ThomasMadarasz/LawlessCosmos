extends HandManipulationResource

class_name HandManipulationDuplicateCard

@export var _amount := 1
@export var _location : Enums.CardLocations

var _other_players : Array[Character]

func activate_hand_manipulation() -> void:
	super.activate_hand_manipulation()
	InputManager.on_card_clicked.connect(duplicate_card)

func duplicate_card(card: Card) -> void:
	if _location == Enums.CardLocations.OWN_HAND and card.owner_hand.current_cards.size() + _amount > card.owner_hand.owner_character.character_resource.hand_data.max_hand_size:
		card.owner_hand.show_hand_full_pop_up()
		disable_hand_manipulation()
		return
	if _location == Enums.CardLocations.OTHER_HANDS:
		_other_players = CharactersManager.player_characters.duplicate()
		_other_players.erase(card.owner_hand.owner_character)
		for player in _other_players:
			if player.hand.current_cards.size() + _amount > player.character_resource.hand_data.max_hand_size:
				player.hand.show_hand_full_pop_up()
				disable_hand_manipulation()
				return
		
	for n in _amount:
		var duplicated_card_resource
		if not _location == Enums.CardLocations.OTHER_HANDS:
			duplicated_card_resource = card.card_resource._duplicate(true)
			duplicated_card_resource.base_value_id = card.card_resource.value_id
			duplicated_card_resource.base_suit = card.card_resource.suit
			duplicated_card_resource.refresh_values()
		match _location:
			Enums.CardLocations.DECK:
				BattleStageManager.current_deck.deck_resource.cards_resources.push_back(duplicated_card_resource)
				BattleStageManager.current_deck.shuffle_cards(false)
				#add feedback
			Enums.CardLocations.DISCARD_PILE:
				BattleStageManager.current_deck.deck_resource.discarded_cards_resources.push_back(duplicated_card_resource)
				BattleStageManager.current_deck.update_labels()
				#add feedback
			Enums.CardLocations.OWN_HAND:
				card.owner_hand.draw_specific_card(duplicated_card_resource, card.global_position)
			Enums.CardLocations.OTHER_HANDS:
				for player in _other_players:
					duplicated_card_resource = card.card_resource._duplicate(true)
					duplicated_card_resource.base_value_id = card.card_resource.value_id
					duplicated_card_resource.base_suit = card.card_resource.suit
					duplicated_card_resource.refresh_values()
					player.hand.draw_specific_card(duplicated_card_resource, card.global_position)
	super.use_hand_manipulation()

func disable_hand_manipulation() -> void:
	for n in InputManager.on_card_clicked.get_connections():
		if n["callable"] == duplicate_card: InputManager.on_card_clicked.disconnect(duplicate_card)
	super.disable_hand_manipulation()

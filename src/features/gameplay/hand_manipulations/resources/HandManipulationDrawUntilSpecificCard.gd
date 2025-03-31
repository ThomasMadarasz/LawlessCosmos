extends HandManipulationResource

class_name HandManipulationDrawUntilSpecificCard

@export var _values_ids : Array[int]
@export var _suits : Array[Enums.Suits]

func activate_hand_manipulation() -> void:
	super.activate_hand_manipulation()
	var selected_character = CharactersManager.selected_character
	if selected_character.hand.is_hand_full(true):
		BattleStageManager.level_manager.hand_manipulation_vfx.emitting = false
		return
	var card = selected_character.hand.draw_single_card()
	await BattleStageManager.get_tree().create_timer(1).timeout
	while not _values_ids.has(card.card_resource.value_id) or not _suits.has(card.card_resource.suit):
		selected_character.hand.discard_card(card, false)
		card = selected_character.hand.draw_single_card()
		await BattleStageManager.get_tree().create_timer(1).timeout
	super.use_hand_manipulation()

#USE CASE : What if there aren't an eligible cards in the deck? Need to avoid infinite loop
#USE CASE : Some interactions could break the game while this manipulation is operating

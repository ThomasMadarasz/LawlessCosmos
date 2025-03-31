extends HandManipulationResource

class_name HandManipulationDrawIfCorresponding


func activate_hand_manipulation() -> void:
	super.activate_hand_manipulation()
	var selected_character = CharactersManager.selected_character
	if selected_character.hand.is_hand_full(true):
		BattleStageManager.level_manager.hand_manipulation_vfx.emitting = false
		return
	var card_1 = selected_character.hand.draw_single_card()
	await BattleStageManager.get_tree().create_timer(0.25).timeout
	var card_2 = selected_character.hand.draw_single_card()
	await BattleStageManager.get_tree().create_timer(1).timeout
	if not card_1.card_resource.value_id == card_2.card_resource.value_id and not card_1.card_resource.suit == card_2.card_resource.suit:
		selected_character.hand.discard_card(card_1, false)
		selected_character.hand.discard_card(card_2, false)
	super.use_hand_manipulation()

#USE CASE : Some interactions could break the game while this manipulation is operating

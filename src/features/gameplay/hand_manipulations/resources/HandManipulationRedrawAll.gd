extends HandManipulationResource

class_name HandManipulationRedrawAll

func activate_hand_manipulation() -> void:
	var selected_character = CharactersManager.selected_character
	if not selected_character is PlayerCharacter or selected_character.hand.current_cards.size() == 0: 
		BattleStageManager.level_manager.hand_manipulation_vfx.emitting = false
		return
	super.activate_hand_manipulation()
	var cards_to_draw = selected_character.hand.current_cards.size()
	selected_character.hand.discard_all_cards(false)
	selected_character.hand.draw_cards(cards_to_draw)
	super.use_hand_manipulation()

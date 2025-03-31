extends HandManipulationResource

class_name HandManipulationDrawCard

@export var _amount := 2

func activate_hand_manipulation() -> void:
	super.activate_hand_manipulation()
	var selected_character = CharactersManager.selected_character
	for i in _amount:
		if selected_character.hand.is_hand_full(true):
			BattleStageManager.level_manager.hand_manipulation_vfx.emitting = false
			return
		selected_character.hand.draw_cards(1)
	super.use_hand_manipulation()

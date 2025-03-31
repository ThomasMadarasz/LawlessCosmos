extends HandManipulationResource

class_name HandManipulationDrawSpecificCard

@export var _values_ids : Array[int]
@export var _suits : Array[Enums.Suits]

func activate_hand_manipulation() -> void:
	super.activate_hand_manipulation()
	var selected_character = CharactersManager.selected_character
	if selected_character.hand.is_hand_full(true):
		BattleStageManager.level_manager.hand_manipulation_vfx.emitting = false
		return
	var is_used = false
	for n in BattleStageManager.current_deck.deck_resource.cards_resources:
		if _values_ids.has(n.value_id) and _suits.has(n.suit):
			selected_character.hand.draw_specific_card(n)
			BattleStageManager.current_deck.remove_specific_cards_resources([n])
			is_used = true
			break
	if not is_used: 
		BattleStageManager.level_manager.hand_manipulation_vfx.emitting = false
		return
	super.use_hand_manipulation()

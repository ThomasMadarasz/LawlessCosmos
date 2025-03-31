extends RewardResource

class_name HandManipulationResource

@export var cooldown : int = 2

var manager : HandManipulationsManager
var slot : HandManipulation

var current_cooldown : int

#region Main

func activate_hand_manipulation() -> void:
	CharactersManager.is_a_hand_manipulation_enabled = true

func use_hand_manipulation() -> void:
	for n in CharactersManager.player_characters:
		n.hand.cards_holder.update_cards_positions(true)
		n.hand.ui.update_hand_labels()
	disable_hand_manipulation()
	manager.on_hand_manipulation_used.emit()
	current_cooldown = cooldown
	slot.update_cooldown()

func disable_hand_manipulation() -> void:
	BattleStageManager.level_manager.hand_manipulation_vfx.emitting = false
	await BattleStageManager.get_tree().process_frame # Ensure that is_a_hand_manipulation_enabled is still true until the end of this frame
	CharactersManager.is_a_hand_manipulation_enabled = false

func _update_owner_hand(owner_hand: Hand) -> void:
	var final_hand = owner_hand.calculate_current_final_hand()
	owner_hand.update_preview(final_hand)

#endregion


#region Reccurent Methods

func _modify_value(card: Card, new_value: int) -> void:
	card.card_resource.value_id = new_value
	if card.card_resource.value_id == 13:
		card.card_resource.value_id = 0
	if card.card_resource.value_id < 0:
		card.card_resource.value_id += 13
	_update_owner_hand(card.owner_hand)

func _change_suit(card: Card, suit: Enums.Suits) -> bool:
	if card.card_resource.suit == suit: return false
	card.card_resource.suit = suit
	_update_owner_hand(card.owner_hand)
	return true

#endregion

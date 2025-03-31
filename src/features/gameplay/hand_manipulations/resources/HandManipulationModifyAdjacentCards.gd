extends HandManipulationResource

class_name HandManipulationModifyAdjacentCards

@export var _is_modifying_next_card: bool = true
@export var _is_modifying_previous_card: bool = true

func activate_hand_manipulation() -> void:
	super.activate_hand_manipulation()
	InputManager.on_card_clicked.connect(_on_card_clicked)

func _on_card_clicked(card: Card) -> void:
	var is_valid = false
	var card_index = card.owner_hand.current_cards_order.find(card)
	if _is_modifying_previous_card and card_index < card.owner_hand.current_cards_order.size() - 1:
		var previous_card = card.owner_hand.current_cards_order[card_index + 1]
		_modify_value(previous_card, card.card_resource.value_id - 1)
		is_valid = true
	if _is_modifying_next_card and card_index > 0:
		var next_card = card.owner_hand.current_cards_order[card_index - 1]
		_modify_value(next_card, card.card_resource.value_id + 1)
		is_valid = true
	if not is_valid:
		disable_hand_manipulation()
		return
	super.use_hand_manipulation()


func disable_hand_manipulation() -> void:
	for n in InputManager.on_card_clicked.get_connections():
		if n["callable"] == _on_card_clicked: InputManager.on_card_clicked.disconnect(_on_card_clicked)
	super.disable_hand_manipulation()

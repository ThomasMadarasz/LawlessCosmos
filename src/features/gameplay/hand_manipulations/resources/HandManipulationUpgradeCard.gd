extends HandManipulationResource

class_name HandManipulationUpgradeCard

func activate_hand_manipulation() -> void:
	super.activate_hand_manipulation()
	InputManager.on_card_clicked.connect(_on_card_clicked)

func _on_card_clicked(card: Card) -> void:
	_modify_value(card, card.card_resource.value_id + 1)
	CharactersManager.set_selected_character(card.owner_hand.owner_character)
	super.use_hand_manipulation()

func disable_hand_manipulation() -> void:
	for n in InputManager.on_card_clicked.get_connections():
			if n["callable"] == _on_card_clicked: InputManager.on_card_clicked.disconnect(_on_card_clicked)
	super.disable_hand_manipulation()

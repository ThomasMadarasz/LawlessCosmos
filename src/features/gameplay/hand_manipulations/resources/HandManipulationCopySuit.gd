extends HandManipulationResource

class_name HandManipulationCopySuit

var _card_to_modify_suit : Card = null

func activate_hand_manipulation() -> void:
	super.activate_hand_manipulation()
	InputManager.on_card_clicked.connect(_on_card_clicked)

func _on_card_clicked(card: Card) -> void:
	if _card_to_modify_suit == null:
		_card_to_modify_suit = card
		return
	if _change_suit(_card_to_modify_suit, card.card_resource.suit):
		CharactersManager.set_selected_character(_card_to_modify_suit.owner_hand.owner_character)
		super.use_hand_manipulation()
	else:
		disable_hand_manipulation()


func disable_hand_manipulation() -> void:
	_card_to_modify_suit = null
	for n in InputManager.on_card_clicked.get_connections():
		if n["callable"] == _on_card_clicked: InputManager.on_card_clicked.disconnect(_on_card_clicked)
	super.disable_hand_manipulation()

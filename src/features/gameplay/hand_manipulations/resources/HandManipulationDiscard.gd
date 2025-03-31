extends HandManipulationResource

class_name HandManipulationDiscard

@export var _draw_card_rate : float

func activate_hand_manipulation() -> void:
	super.activate_hand_manipulation()
	InputManager.on_card_clicked.connect(_on_card_clicked)

func _on_card_clicked(card: Card) -> void:
	if InputManager.is_dragging or card.is_discarding: return
	var hand = card.owner_hand
	if not card.is_locked:
		card.is_discarding = true
		hand.discard_card(card, false)
		if randi_range(0, 100) <= roundi(_draw_card_rate * 100):
			hand.draw_cards(1)
		super.use_hand_manipulation()

func disable_hand_manipulation() -> void:
	for n in InputManager.on_card_clicked.get_connections():
		if n["callable"] == _on_card_clicked: InputManager.on_card_clicked.disconnect(_on_card_clicked)
	super.disable_hand_manipulation()

extends HandManipulationResource

class_name HandManipulationDiscardReduceCooldown

func activate_hand_manipulation() -> void:
	super.activate_hand_manipulation()
	InputManager.on_card_clicked.connect(_on_card_clicked)

func _on_card_clicked(card: Card) -> void:
	if InputManager.is_dragging or card.is_discarding: return
	var hand = card.owner_hand
	if not card.is_locked:
		card.is_discarding = true
		hand.discard_card(card, false)
		var eligible_manipulations = []
		for n in manager.hand_manipulations:
			if not n.resource == null and not n.resource == self and n.resource.current_cooldown > 0:
				eligible_manipulations.push_back(n)
		if eligible_manipulations.size() > 0:
			var manipulation_to_reduce = eligible_manipulations.pick_random()
			manipulation_to_reduce.resource.current_cooldown -= 1
			manipulation_to_reduce.update_cooldown()
		else:
			print("no manipulations to reduce cooldown")
			
		super.use_hand_manipulation()

func disable_hand_manipulation() -> void:
	for n in InputManager.on_card_clicked.get_connections():
		if n["callable"] == _on_card_clicked: InputManager.on_card_clicked.disconnect(_on_card_clicked)
	super.disable_hand_manipulation()

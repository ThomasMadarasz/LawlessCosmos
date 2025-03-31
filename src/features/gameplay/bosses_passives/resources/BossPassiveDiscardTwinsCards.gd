extends BossPassiveResource

class_name BossPassiveDiscardTwinsCards

func enable() -> void:
	BattleStageManager.on_new_turn.connect(_on_new_turn)

func _on_new_turn() -> void:
	for character in CharactersManager.player_characters:
		var cards = character.hand.current_cards.keys().duplicate()
		var eligible_cards = []
		for card in cards:
			var twins_cards_amount = 0
			for n in cards:
				if card.card_resource.value_id == n.card_resource.value_id: twins_cards_amount += 1
			if twins_cards_amount > 1: eligible_cards.push_back(card)
		if eligible_cards.size() >= 2:
			character.hand.discard_card(eligible_cards.pick_random(), false)

func disable() -> void:
	for n in BattleStageManager.on_new_turn.get_connections():
		if n["callable"] == _on_new_turn: 
			BattleStageManager.on_new_turn.disconnect(_on_new_turn)
	super.disable()

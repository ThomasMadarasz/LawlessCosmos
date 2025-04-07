extends MoveComponent

class_name MoveComponentDiscardCards

@export var _cards_amount : MoveComponentValue

func perform() -> void:
	for _n: int in _targets.size():
		var target: Character = _targets[0]
		_targets.erase(target)
		for _i: int in _cards_amount.get_value(_owner_character): #BUG: Is always 0
			if target.hand.current_cards.size() > 0:
				target.hand.discard_card(target.hand.current_cards.keys().pick_random(), false)
	return

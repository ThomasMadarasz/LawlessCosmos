extends MoveComponent

class_name MoveComponentDrawCards

@export var _cards_amount : MoveComponentValue

func perform() -> void:
	for n in _targets.size():
		var target = _targets[0]
		_targets.erase(target)
		_move_solver.owner_character.hand.draw_cards(_cards_amount.get_value(_move_solver.owner_character))
	return

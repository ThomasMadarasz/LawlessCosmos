extends MoveComponentTargetingBehavior

class_name MoveComponentTargetPositionAlly

@export var _position : Enums.Slots

func get_targets(move_solver : MoveSolver) -> Array[Character]:
	var ally = CharactersManager.get_allies_characters_ordered(move_solver.owner_character)[_position]
	if ally == null:
		ally = CharactersManager.get_allies_characters(move_solver.owner_character).pick_random()
	return [ally]

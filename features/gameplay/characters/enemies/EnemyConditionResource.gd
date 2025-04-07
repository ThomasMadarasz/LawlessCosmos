extends BaseResource

class_name EnemyConditionResource

var is_enabled : bool

var owner_character : EnemyCharacter

func initialize(character : EnemyCharacter) -> void:
	owner_character = character
	_connect_signals()

func _connect_signals() -> void:
	pass

func check_condition() -> void:
	if not is_enabled and _is_valid():
		_set_new_moves()

func _set_new_moves() -> void:
	if owner_character.character_resource.conditional_moves.size() == 0:
		printerr("Trying to access conditional moves but conditional moves array is empty")
	owner_character.current_moves = owner_character.character_resource.conditional_moves
	owner_character.current_move_index = 0

func _is_valid() -> bool:
	return false

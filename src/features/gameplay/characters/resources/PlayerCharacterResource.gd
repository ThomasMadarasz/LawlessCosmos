extends CharacterResource

class_name PlayerCharacterResource

@export var character_portrait_texture : Texture2D
@export var gradient: Gradient
@export var character_id: Enums.PlayerCharacters
@export var move_rewards: Array[Move]
@export var _base_moves: Array[Move]

func initialize(character: Character) -> void:
	super.initialize(character)
	_initialize_moves(character)

func _initialize_moves(character: Character) -> void:
	if not _base_moves.size() == 4:
		printerr("%s has %s base moves and should have 4" % [display_name, _base_moves.size()])
	for i in _base_moves.size():
		_base_moves[i] = _base_moves[i]._duplicate(true)
	for n in _base_moves:
		n.register_owner_character(character)
	current_moves = _base_moves

extends ArtifactResource

class_name ArtifactCrossAllyAcceleration

@export var _acceleration_turn_amount : int = 1

func enable(character : PlayerCharacter = null) -> void:
	super.enable(character)
	owner_character.on_allied_crossed.connect(_on_allied_crossed)

func _on_allied_crossed(crossed: Character, _crosser: Character, _is_from_left : bool) -> void:
	crossed.status.add_status(CharacterStatus.Status.ACCELERATED, _acceleration_turn_amount, owner_character)

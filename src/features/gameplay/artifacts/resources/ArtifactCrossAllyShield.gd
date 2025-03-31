extends ArtifactResource

class_name ArtifactCrossAllyShield

@export var _shield_amount : int

func enable(character : PlayerCharacter = null) -> void:
	super.enable(character)
	owner_character.on_allied_crossed.connect(_on_allied_crossed)

func _on_allied_crossed(crossed: Character, _crosser: Character, _is_from_left : bool) -> void:
	crossed.add_shield(_shield_amount)

func _get_formatted_description() -> String:
	var formated_description = super._get_formatted_description()
	return formated_description.format({"AMOUNT": str(_shield_amount)})

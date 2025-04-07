extends ArtifactResource

class_name ArtifactIncreaseMaxHealth

@export var _amount: int

func enable(character: PlayerCharacter = null) -> void:
	character.max_health+= _amount
	character.character_resource.max_health += _amount
	character.ui.update_health(character.character_resource)
	super.enable()

func _get_formatted_description() -> String:
	var formated_description: String = super._get_formatted_description()
	return formated_description.format({"AMOUNT": str(_amount)})

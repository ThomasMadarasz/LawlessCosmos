extends ArtifactResource

class_name ArtifactIncreaseStartHandAndDrawLimit

@export var _amount : int

func enable(character : PlayerCharacter = null) -> void:
	character.character_resource.hand_data.draw_limit += _amount
	character.character_resource.hand_data.initial_draw_amount += _amount
	character.hand.ui.update_hand_labels()
	super.enable()

func _get_formatted_description() -> String:
	var formated_description = super._get_formatted_description()
	return formated_description.format({"AMOUNT": str(_amount)})

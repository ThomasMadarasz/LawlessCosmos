extends ArtifactResource

class_name ArtifactSuitBonus

@export var _suit: Enums.Suits

func enable(character : PlayerCharacter = null) -> void:
	character.suit_amount_bonus[_suit] = 1

func _get_formatted_name() -> String :
	var new_name = super._get_formatted_name()
	return new_name.format({"SUIT": tr(Enums.Suits.keys()[_suit])})

func _get_formatted_description() -> String:
	var new_description = super._get_formatted_description()
	return new_description.format({"SUIT": tr(Enums.Suits.keys()[_suit])})

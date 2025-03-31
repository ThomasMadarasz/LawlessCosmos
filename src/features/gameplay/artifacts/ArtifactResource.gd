extends RewardResource

class_name ArtifactResource

var current_stack : int

var owner_character : Character

func enable(character : PlayerCharacter = null) -> void:
	owner_character = character

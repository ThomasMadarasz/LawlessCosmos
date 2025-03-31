extends ArtifactResource

class_name ArtifactBleedOnAttack

@export var _bleed_percentage : float

func enable(character: PlayerCharacter = null) -> void:
	super.enable(character)
	owner_character.on_attack.connect(_on_attack)

func _on_attack(target: Character, health_lost_amount: int) -> void:
	var bleed_amount = roundi(_bleed_percentage * health_lost_amount)
	if bleed_amount > 0:
		target.status.add_status(CharacterStatus.Status.BLEED, bleed_amount, owner_character)

func _get_formatted_description() -> String:
	var formated_description = super._get_formatted_description()
	return formated_description.format({"PERCENTAGE": str(int(_bleed_percentage * 100)) + "%"})

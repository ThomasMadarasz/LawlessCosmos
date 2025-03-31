extends ArtifactResource

class_name ArtifactLifeStealBleed

@export var _life_steal_percentage: float

func enable(character: PlayerCharacter = null) -> void:
	super.enable(character)
	owner_character.on_attack.connect(_on_attack)

func _on_attack(target: Character, health_lost_amount: int) -> void:
	if not target.status.current_status.has(CharacterStatus.Status.BLEED): return
	owner_character.heal(roundi(health_lost_amount * _life_steal_percentage))


func _get_formatted_description() -> String:
	var formated_description = super._get_formatted_description()
	return formated_description.format({"PERCENTAGE": str(int(abs((_life_steal_percentage - 1)) * 100)) + "%"})

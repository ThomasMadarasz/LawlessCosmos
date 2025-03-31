extends ArtifactResource

class_name ArtifactMultiplier

enum MultiplierType { OFFENSE, DEFENSE, BOTH}

@export var multiplier_type: MultiplierType
@export var multiplier: DamageMultiplierEvaluator

func enable(character : Character = null) -> void:
	super.enable(character)
	if multiplier_type == MultiplierType.OFFENSE or multiplier_type == MultiplierType.BOTH:
		character.inflicted_damage_multiplier.push_back(multiplier)
	if multiplier_type == MultiplierType.DEFENSE or multiplier_type == MultiplierType.BOTH:
		character.received_damage_multiplier.push_back(multiplier)

func _get_formatted_name() -> String:
	var current_formatted_name = super._get_formatted_name()
	return multiplier.format_name(current_formatted_name)

func _get_formatted_description() -> String:
	var formated_description = super._get_formatted_description()
	formated_description = multiplier.format_description(formated_description)
	return formated_description.format({"PERCENTAGE": str(int(abs((multiplier._multiplier_value - 1)) * 100)) + "%"})

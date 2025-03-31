extends RewardResource

class_name HealRewardResource

@export var min_heal_value: int
@export var max_heal_value: int


func _get_formatted_description() -> String:
	var new_formated_description = super._get_formatted_description()
	return new_formated_description.format({"VALUE_RANGE_1" : str(min_heal_value), "VALUE_RANGE_2" : str(max_heal_value)})

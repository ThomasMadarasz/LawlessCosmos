extends MoveComponent

class_name MoveComponentBalanceHealth

func perform() -> void:
	for n in _targets.size():
		var target = _targets[0]
		_targets.erase(target)
		var ally_target = _get_lowest_health_ally(_owner_character)
		var efficiency_percentage = _calculate_health_difference_percentage(target, ally_target)
		if efficiency_percentage > 0:
			target.take_damage(roundi(efficiency_percentage * target.max_health), target, true)
			ally_target.heal(roundi(efficiency_percentage * ally_target.max_health))
		else:
			target.heal(roundi((-efficiency_percentage) * target.max_health))
			ally_target.take_damage(roundi((-efficiency_percentage) * ally_target.max_health), ally_target, true)
	return

func _get_lowest_health_ally(owner_character: Character) -> Character:
	var characters = CharactersManager.player_characters if owner_character is PlayerCharacter else CharactersManager.enemy_characters
	var lowest_health_character = owner_character
	for n in characters:
		if n == null: continue
		if float(lowest_health_character.character_resource.current_health) / float(lowest_health_character.max_health) > float(n.character_resource.current_health) / float(n.max_health) : 
			lowest_health_character = n
	return lowest_health_character

func _calculate_health_difference_percentage(target_1 : Character, target_2 : Character) -> float:
	var target_1_percentage = float(target_1.character_resource.current_health) / float(target_1.max_health)
	var target_2_percentage = float(target_2.character_resource.current_health) / float(target_2.max_health)
	return (target_1_percentage - target_2_percentage) / 2.0

extends EnemyMoveTargets

class_name EnemyMoveTargetsBoss

func get_targeted_slots(move : Move) -> Array[int]:
	var boss = null
	for n in CharactersManager.enemy_characters:
		if n.character_resource.is_boss:
			boss = n
	if boss == null: boss = move.owner_character
	return [boss.position_id]

func get_formatted_name() -> String:
	return tr("BOSS")

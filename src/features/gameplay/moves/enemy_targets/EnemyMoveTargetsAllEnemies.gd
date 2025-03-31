extends EnemyMoveTargets

class_name EnemyMoveTargetsAllEnemies

func get_targeted_slots(_move : Move) -> Array[int]:
	return CharactersManager.get_enemy_filled_slots()

func get_formatted_name() -> String:
	return tr("ALL_ENEMIES")

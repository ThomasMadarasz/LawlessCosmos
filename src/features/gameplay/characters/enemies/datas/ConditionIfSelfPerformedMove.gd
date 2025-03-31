extends EnemyConditionResource

class_name ConditionIfSelfPerformedMove

func _connect_signals() -> void:
	super._connect_signals()
	owner_character.on_character_performed_move.connect(_on_character_performed_move)

func _on_character_performed_move(_character : Character) -> void:
	check_condition()

func _is_valid() -> bool:
	return true

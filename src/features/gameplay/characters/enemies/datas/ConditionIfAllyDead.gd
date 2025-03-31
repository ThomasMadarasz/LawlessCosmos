extends EnemyConditionResource

class_name ConditionIfAllyDead

@export var _allies_to_watch : Array[Enums.Slots]

func _connect_signals() -> void:
	super._connect_signals()
	BattleStageManager.on_initial_draw.connect(_on_initial_draw)

func _on_initial_draw() -> void:
	for i in _allies_to_watch :
		var ally = owner_character.enemies_by_position_at_start[i]
		if not ally == null and not ally == owner_character and not ally.is_dead:
			ally.on_character_death.connect(_on_character_death)
	BattleStageManager.on_initial_draw.disconnect(_on_initial_draw)

func _on_character_death(_character : Character) -> void:
	check_condition()

func _is_valid() -> bool:
	var is_valid = true
	for i in _allies_to_watch :
		if not owner_character.enemies_by_position_at_start[i].is_dead:
			is_valid = false
	return is_valid

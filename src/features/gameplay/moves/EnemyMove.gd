extends Move

class_name EnemyMove

@export var move_targets : EnemyMoveTargets
@export var move_points_required : int
@export var _enemy_power_range : Vector2

var enemy_target_string: String
var enemy_power: int

func register_owner_character(character : Character) -> void:
	super.register_owner_character(character)
	owner_character.on_character_performed_move.connect(_on_character_performed_move)

func _on_character_performed_move(_character : Character) -> void:
	owner_character.on_character_performed_move.disconnect(_on_character_performed_move)
	current_slot_target = null
	current_targets_count = 0
	enemy_power = 0

func get_final_power() -> int:
	if enemy_power == 0 and _enemy_power_range.x > 0:
		var multiplier = BattleStageManager.difficulty_multiplier if BattleStageManager.current_wave_data.is_boss_wave else BattleStageManager.difficulty_multiplier * BattleStageManager.wave_efficiency_multiplier
		enemy_power = randi_range(roundi(_enemy_power_range.x * multiplier), roundi(_enemy_power_range.y * multiplier))
	return enemy_power

func _get_formatted_description() -> String:
	var new_formated_description = super._get_formatted_description()
	if iteration > 0:
		new_formated_description = new_formated_description.format({"UPGRADE_1" : tr(description + "_1")})
		if iteration > 1:
			new_formated_description = new_formated_description.format({"UPGRADE_2" : tr(description + "_2")})
			if iteration > 2:
				new_formated_description = new_formated_description.format({"UPGRADE_3" : tr(description + "_3")})
			else:  
				new_formated_description = new_formated_description.format({"UPGRADE_3" : ""})
		else : 
			new_formated_description = new_formated_description.format({"UPGRADE_2" : "", "UPGRADE_3" : ""})
	else: 
		new_formated_description = new_formated_description.format({"UPGRADE_1" : "", "UPGRADE_2" : "", "UPGRADE_3" : ""})
	return new_formated_description.format({"TARGET" : enemy_target_string})

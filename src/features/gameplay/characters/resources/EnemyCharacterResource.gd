extends CharacterResource

class_name EnemyCharacterResource

@export var moves : Array[EnemyMove]
@export var condition : EnemyConditionResource
@export var conditional_moves : Array[EnemyMove]
@export var is_boss: bool
@export var boss_passive: BossPassiveResource


func initialize(character: Character) -> void:
	super.initialize(character)
	current_health = roundi(current_health * BattleStageManager.difficulty_multiplier)
	max_health = roundi(max_health * BattleStageManager.difficulty_multiplier)
	current_shield = roundi(_base_shield * BattleStageManager.difficulty_multiplier)
	if not BattleStageManager.current_wave_data.is_boss_wave:
		current_health = roundi(current_health * BattleStageManager.wave_durability_multiplier)
		max_health = roundi(max_health * BattleStageManager.wave_durability_multiplier)
		current_shield = roundi(_base_shield * BattleStageManager.wave_durability_multiplier)
	if is_boss and not boss_passive == null:
		boss_passive.enable()
		boss_passive.owner_character = character

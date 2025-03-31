extends MoveComponent

class_name MoveComponentSummon

@export var _summon_slot : Enums.Slots
@export var _enemy_to_spawn : EnemyCharacterResource

func perform() -> void:
	if _owner_character is PlayerCharacter: printerr("MoveSpawnCharacter shouldn't be used on a PlayerCharacter")
	if _summon_slot == Enums.Slots.BACK_ROW: _owner_character.move_to_front_row()
	else: _owner_character.move_to_back_row()
	if not CharactersManager.get_enemy_character_with_position_id(_summon_slot) == null: return
	var spawned_enemy = BattleStageManager.level_manager.instantiate_enemy(_enemy_to_spawn, _summon_slot)
	CharactersManager.show_characters([spawned_enemy] as Array[Character])
	spawned_enemy.set_target()
	return

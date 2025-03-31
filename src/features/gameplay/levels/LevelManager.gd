extends Node

class_name LevelManager

@export var hands_positions : Array[Node2D]
@export var player_characters_parent : Node2D
@export var player_characters_positions : Array[Slot]
@export var _enemy_characters_parent: Node2D
@export var enemy_characters_positions: Array[Slot]
@export var player_hands: Array[Hand]
@export var rewards_manager: RewardsManager
@export var hand_manipulations_manager: HandManipulationsManager
@export var hand_manipulation_vfx: CPUParticles2D

var _level_data : LevelResource :
	get:
		return BattleStageManager.current_level_resource

func _ready() -> void:
	_connect_signals()
	await ResourcesManager.load_enemies_characters(_level_data)
	await _instantiate_enemies(0)

func _connect_signals():
	BattleStageManager.on_player_won_wave.connect(_on_player_won_wave)

func _on_player_won_wave() -> void:
	CharactersManager.clear_dead_enemy_characters()

func _instantiate_enemies(wave_index : int) -> Array[EnemyCharacter]:
	var new_enemies: Array[EnemyCharacter] = []
	for i in 3:
		var enemy_resource = null
		match i:
			0:
				if not _level_data.waves_array[wave_index].enemy_1 == null:
					enemy_resource = _level_data.waves_array[wave_index].enemy_1._duplicate(true)
			1:
				if not _level_data.waves_array[wave_index].enemy_2 == null:
					enemy_resource = _level_data.waves_array[wave_index].enemy_2._duplicate(true)
			2: 
				if not _level_data.waves_array[wave_index].enemy_3 == null:
					enemy_resource = _level_data.waves_array[wave_index].enemy_3._duplicate(true)
		if enemy_resource == null: continue
		var enemy_character = instantiate_enemy(enemy_resource, i)
		new_enemies.push_back(enemy_character)
		await get_tree().create_timer(0.1).timeout
	return new_enemies

func instantiate_enemy(enemy_resource : EnemyCharacterResource, position_id: int) -> EnemyCharacter:
	var enemy_prefab = ResourceLoader.load_threaded_get(enemy_resource.file_path)
	var enemy_character = enemy_prefab.instantiate() as EnemyCharacter
	_enemy_characters_parent.add_child(enemy_character)
	enemy_character.global_position = enemy_characters_positions[position_id].global_position
	enemy_character.scale = enemy_characters_positions[position_id].scale
	enemy_character.position_id = position_id
	CharactersManager.enemies_positions_by_id[enemy_character.position_id] = enemy_character
	enemy_character.character_resource = enemy_resource
	enemy_character.initialize()
	return enemy_character

func start_next_wave() -> void:
	await _instantiate_enemies(BattleStageManager.current_wave_index)
	await CharactersManager.show_characters(CharactersManager.enemies_positions_by_id)
	for n in CharactersManager.enemy_characters:
		n.set_target()
	CharactersManager.is_wave_dead = false

func get_hand_position(hand_id: int, is_all_folded: int = false) -> Vector2:
	if is_all_folded: return hands_positions[hand_id].get_node("2").global_position
	return hands_positions[hand_id].get_node(str(CharactersManager.selected_character.position_id+1)).global_position

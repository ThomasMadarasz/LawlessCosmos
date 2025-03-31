extends Node

signal on_battle_stage_initialized()
signal on_new_wave_started()
signal on_initial_draw()
signal on_hands_drawn()
signal on_hand_combination_phase_started()
signal on_targeting_phase_started()
signal on_targeting_phase_stopped()
signal on_moves_solving_phase_started()
signal on_new_turn()
signal on_turn_skipped()

signal on_player_lost()
signal on_player_won_wave()
signal on_player_won_level()

enum BattleState {INITIALIZING, DRAWING_PHASE, HANDS_COMBINATIONS_PHASE, TARGETING_PHASE, ACTIONS_SOLVING_PHASE, REWARD_PHASE}

var level_manager: LevelManager
var current_deck: Deck
var current_level_resource : LevelResource

var enemies_waiting_to_perform_move: Array[EnemyCharacter]

var current_battle_state: BattleState
var current_wave_index : int
var turn_count:= -1
var is_player_turn := true

var current_wave_data : WaveData :
	get :
		if current_level_resource == null: return null
		return current_level_resource.waves_array[current_wave_index]

var is_tutorial := false
var is_battle_stage_initialized := false
var is_upgrading_phase := false

var difficulty_multiplier := 1.0
var wave_durability_multiplier := 1.0
var wave_efficiency_multiplier := 1.0

const _GAME_UI_PATH = "res://datas/prefabs/ui/game_ui.tscn"

func _ready() -> void:
	current_battle_state = BattleState.INITIALIZING
	_connect_signals()

#region Signals

func _connect_signals() -> void:
	SceneManager.on_game_scene_instantiated.connect(_on_game_scene_instantiated)
	CharactersManager.on_characters_manager_initialized.connect(_on_characters_manager_initialized)
	on_battle_stage_initialized.connect(_on_battle_stage_initialized)
	on_hands_drawn.connect(start_hands_combinations_phase)
	on_initial_draw.connect(_on_initial_draw)
	BattleStageManager.on_player_won_wave.connect(_on_player_won_wave)
	on_new_wave_started.connect(_on_new_wave_started)

func _on_game_scene_instantiated(current_scene : LevelManager) -> void:
	level_manager = current_scene
	level_manager.rewards_manager.on_upgrades_chosen.connect(_start_next_wave)
	current_scene.get_node("Tutorial").start_tutorial(is_tutorial)

func _on_characters_manager_initialized() -> void:
	await get_tree().process_frame
	if CharactersManager.is_initialized and not current_deck == null:
		for n in CharactersManager.player_characters:
			n.on_character_death.connect(_on_player_character_death)
			n.on_character_performed_move.connect(_on_character_performed_move)
		is_battle_stage_initialized = true
		on_battle_stage_initialized.emit()
		CharactersManager.on_enemy_characters_initialized.connect(_start_drawing_phase)

func _on_battle_stage_initialized() -> void:
	_start_drawing_phase()

func _on_initial_draw() -> void:
	if current_wave_data.deck_resource == null: #Avoid shuffling scripted decks in tutorial
		current_deck.shuffle_cards()
	for n in CharactersManager.player_characters:
		n.hand.fill_hand(true)
	for n in CharactersManager.enemy_characters:
		n.set_target()
	on_hands_drawn.emit()

func _on_player_won_wave() -> void:
	current_battle_state = BattleState.REWARD_PHASE

func _on_character_performed_move(character: Character) -> void:
	CharactersManager.hide_slots()
	if character is PlayerCharacter:
		character.reset_preview()
		play_enemies_turn()

func _on_new_wave_started() -> void:
	turn_count = -1

func _on_player_character_death(_character: Character) -> void:
	on_player_lost.emit()

#endregion


#region Game States

func _start_next_wave() -> void:
	current_wave_index += 1
	is_player_turn = true
	wave_durability_multiplier += current_level_resource.wave_durability_multiplier_increment
	wave_efficiency_multiplier += current_level_resource.wave_efficiency_multiplier_increment
	if not current_level_resource.waves_array[current_wave_index].deck_resource == null: 
		current_deck.deck_resource = current_level_resource.waves_array[current_wave_index].deck_resource
		current_deck.deck_resource.initialize()
	await level_manager.start_next_wave()
	on_new_wave_started.emit()

func start_new_turn() -> void:
	if CharactersManager.is_wave_dead: return
	on_new_turn.emit()
	start_hands_combinations_phase()

func _start_drawing_phase() -> void:
	await get_tree().process_frame
	turn_count += 1
	current_battle_state = BattleState.DRAWING_PHASE
	on_initial_draw.emit()

func start_hands_combinations_phase() -> void:
	current_battle_state = BattleState.HANDS_COMBINATIONS_PHASE
	on_hand_combination_phase_started.emit()

func start_targeting_phase() -> void:
	current_battle_state = BattleState.TARGETING_PHASE
	on_targeting_phase_started.emit()

func stop_targeting_phase(is_canceled: bool) -> void:
	on_targeting_phase_stopped.emit()
	if is_canceled: start_hands_combinations_phase()

func start_moves_solving_phase() -> void:
	current_battle_state = BattleState.ACTIONS_SOLVING_PHASE
	on_moves_solving_phase_started.emit()

func skip_turn() -> void:
	on_turn_skipped.emit()
	play_enemies_turn()

func play_enemies_turn() -> void:
	start_moves_solving_phase()
	for n in CharactersManager.enemy_characters:
		n.gain_move_points()
	while enemies_waiting_to_perform_move.size() > 0:
		await get_tree().create_timer(1).timeout
		enemies_waiting_to_perform_move.sort_custom(sort_by_position_id)
		var enemy_performing_move = enemies_waiting_to_perform_move.front()
		enemy_performing_move.perform_move()
		enemies_waiting_to_perform_move.remove_at(0)
		await enemy_performing_move.on_character_performed_move
		print(enemy_performing_move, " has performed its move")
	await get_tree().create_timer(1).timeout
	is_player_turn = true
	start_new_turn()

func complete_wave() -> void:
	if current_wave_index + 1 >= current_level_resource.waves_array.size():
		on_player_won_level.emit()
	else:
		on_player_won_wave.emit()

#endregion


#region Utils

func set_level_data(level_data: LevelResource) -> void:
	current_level_resource = level_data
	current_level_resource.initialize_waves_array()

func reset_battle_stage_manager() -> void:
	current_deck = null
	current_battle_state = BattleState.INITIALIZING
	is_battle_stage_initialized = false
	BattleStageManager.is_player_turn = true
	current_wave_index = 0
	level_manager = null
	CharactersManager.on_enemy_characters_initialized.disconnect(_start_drawing_phase)

func is_hand_combination_phase() -> bool:
	return current_battle_state == BattleState.HANDS_COMBINATIONS_PHASE

func is_targeting_phase() -> bool:
	return current_battle_state == BattleState.TARGETING_PHASE

func is_moves_solving_phase() -> bool:
	return current_battle_state == BattleState.ACTIONS_SOLVING_PHASE

func sort_by_position_id(a: Character, b: Character):
	if a.position_id < b.position_id:
		return true
	return false

func get_allies_slots_positions(character: Character) -> Array[Slot]:
	return level_manager.player_characters_positions if character is PlayerCharacter else level_manager.enemy_characters_positions

func get_opponents_slots_positions(character: Character) -> Array[Slot]:
	return level_manager.enemy_characters_positions if character is PlayerCharacter else level_manager.player_characters_positions


#endregion

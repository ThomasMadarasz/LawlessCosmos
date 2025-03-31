extends Node

signal on_player_characters_initialized()
signal on_enemy_characters_initialized()
signal on_characters_manager_initialized()
signal on_character_selected(character: Character)

var player_characters: Array[Character]
var enemy_characters: Array[Character]
var characters: Array[Character]:
	get :
		return player_characters + enemy_characters
var dead_enemy_characters: Array[Character]

var players_positions_by_id : Array[Character] = [null, null, null]
var enemies_positions_by_id : Array[Character] = [null, null, null]
var characters_positions_by_id: Array[Character]:
	get :
		return players_positions_by_id + enemies_positions_by_id

var is_initialized: bool

var selected_character: Character
var is_a_character_performing_move := false
var is_a_hand_manipulation_enabled := false

var is_wave_dead := false

var _are_player_characters_initialized: bool
var _are_enemy_characters_initialized: bool

func _ready() -> void:
	_connect_signals()

#region Initialization

func check_initialization() -> void:
	if is_initialized: return
	if not _are_enemy_characters_initialized or not _are_player_characters_initialized: return
	if BattleStageManager.current_deck == null: return
	is_initialized = true
	player_characters.sort_custom(sort_by_position)
	_set_players_positions_by_id()
	set_selected_character(player_characters.back())
	await show_characters(characters_positions_by_id)
	on_characters_manager_initialized.emit()

#endregion

#region Signals

func _connect_signals() -> void:
	SceneManager.on_game_scene_instantiated.connect(_on_game_scene_instantiated)
	InputManager.on_character_clicked.connect(set_selected_character)
	on_enemy_characters_initialized.connect(check_initialization)
	on_player_characters_initialized.connect(check_initialization)
	BattleStageManager.on_player_won_wave.connect(_on_player_won_wave)
	

func _on_game_scene_instantiated(_level_manager : LevelManager) -> void:
	_level_manager.rewards_manager.on_upgrades_chosen.connect(_on_upgrades_chosen)
	await get_tree().create_timer(0.1).timeout
	for i in BattleStageManager.current_level_resource.player_characters_resources.size():
		if BattleStageManager.current_level_resource.player_characters_resources[i] == null: continue
		instantiate_player_character(i)
		await get_tree().create_timer(0.1).timeout

func _on_character_death(character: Character) -> void:
	if character is EnemyCharacter:
		enemy_characters.erase(character)
		var enemy_index = enemies_positions_by_id.find(character)
		print(character)
		if enemy_index == -1:
			print(character)
			print("error")
		enemies_positions_by_id.erase(character)
		enemies_positions_by_id.insert(enemy_index, null)
		dead_enemy_characters.push_back(character)
	if enemy_characters.size() == 0:
		is_wave_dead = true
		await get_tree().create_timer(2).timeout
		BattleStageManager.complete_wave()

func _on_player_won_wave() -> void:
	_are_enemy_characters_initialized = false

func _on_upgrades_chosen() -> void:
	set_selected_character(selected_character)

#endregion

#region Instantiation

func instantiate_player_character(i : int) -> void:
	var player_prefab = null
	player_prefab = ResourceLoader.load_threaded_get(BattleStageManager.current_level_resource.player_characters_resources[i].file_path)
	var player_character = player_prefab.instantiate() as PlayerCharacter
	BattleStageManager.level_manager.player_characters_parent.add_child(player_character)
	player_character.character_resource = BattleStageManager.current_level_resource.player_characters_resources[i]
	player_character.position_id = i
	player_character.initialize()

#endregion

#region Character Registration

func register_player_character(player_character:PlayerCharacter) -> void:
	player_character.on_character_death.connect(_on_character_death)
	player_characters.push_back(player_character)
	if player_characters.size() == BattleStageManager.current_level_resource.player_count:
		_are_player_characters_initialized = true
		on_player_characters_initialized.emit()

func register_enemy_character(enemy_character:EnemyCharacter, _parent: Node) -> void:
	enemy_character.on_character_death.connect(_on_character_death)
	enemy_characters.push_back(enemy_character)
	if enemy_characters.size() == BattleStageManager.current_level_resource.get_wave_enemy_count(BattleStageManager.current_wave_index):
		_are_enemy_characters_initialized = true
		on_enemy_characters_initialized.emit()

func clear_dead_enemy_characters() -> void:
	for n in dead_enemy_characters:
		n.queue_free()
	dead_enemy_characters.clear()

#endregion

#region Character Selection

func set_selected_character(character: Character, force_switch := false) -> void:
	if selected_character == character: return
	if not character is PlayerCharacter: return
	if not selected_character == null and selected_character.is_choosing_target_to_perform_move and not force_switch: return
	if not selected_character == null and selected_character is PlayerCharacter: selected_character.ui.play_selection_feedback(false)
	character.ui.play_selection_feedback(true)
	selected_character = character
	on_character_selected.emit(character)

func unselect_character() -> void:
	if not selected_character == null: selected_character.feedback.play_selection_feedback(false)
	selected_character = null

#endregion

#region Slots

func hide_slots(only_targeted : bool = false) -> void:
	for n in BattleStageManager.level_manager.player_characters_positions + BattleStageManager.level_manager.enemy_characters_positions:
		n.set_targeted(false)
		if not only_targeted: 
			n.set_targetable(Color.WHITE, false)

func get_player_filled_slots() -> Array[int]:
	var slots_id = [] as Array[int]
	player_characters.sort_custom(sort_by_position)
	for n in player_characters:
		slots_id.push_back(n.position_id)
	return slots_id

func get_enemy_filled_slots() -> Array[int]:
	var slots_id = [] as Array[int]
	enemy_characters.sort_custom(sort_by_position)
	for n in enemy_characters:
		slots_id.push_back(n.position_id)
	return slots_id

#endregion

#region Character Visuals

func reset_characters_colors() -> void:
	for n in player_characters + enemy_characters:
		n.feedback.reset_target_feedback()

func show_characters(characters_array: Array[Character]) -> void:
	var tween = get_tree().create_tween()
	for n in characters_array:
		if not n == null:
			tween.parallel().tween_method(n.set_character_alpha_shader_value, 0.0, 1.0, 1.0)
	await tween.finished
	return

#endregion

#region Utils

func sort_by_position(a: Character, b: Character):
	if a.position_id < b.position_id:
		return true
	return false

func order_enemies_positions() -> void:
	for i in enemies_positions_by_id.size():
		if enemies_positions_by_id[i]== null: continue
		enemies_positions_by_id[i].position_id = i
		enemies_positions_by_id[i].set_target()

func order_players_positions() -> void:
	for i in players_positions_by_id.size():
		if players_positions_by_id[i]== null: continue
		players_positions_by_id[i].position_id = i
	for n in enemies_positions_by_id:
		if not n == null:
			n.set_target()

func move_characters_to_their_respective_slots(slots_positions : Array[Slot], characters_order : Array[Character]) -> void:
	for i in slots_positions.size():
		var character = characters_order[i]
		if character == null: continue
		character.move_character(slots_positions[i].global_position)

func order_characters(characters_order : Array[Character], is_updating_hand_positions: bool) -> void:
	for i in characters_order.size():
		if characters_order[i]== null: continue
		characters_order[i].position_id = i
		if is_updating_hand_positions: 
			characters_order[i].hand.cards_holder.set_destination_size_and_pos()

func _set_players_positions_by_id() -> void:
	for n in player_characters:
		players_positions_by_id[n.position_id] = n

func get_default_player_character() -> PlayerCharacter:
	return player_characters[0]

func get_character_with_position_id(id : int) -> Character:
	return characters_positions_by_id[id]

func get_player_character_with_position_id(id : int) -> PlayerCharacter:
	return players_positions_by_id[id]
	
func get_enemy_character_with_position_id(id : int) -> EnemyCharacter:
	return enemies_positions_by_id[id]

func get_next_player_by_position(set_as_selected: bool) -> PlayerCharacter:
	var wanted_id = selected_character.position_id + 1
	if wanted_id >= player_characters.size(): wanted_id = 0
	var player_character = player_characters[wanted_id]
	if set_as_selected: set_selected_character(player_character)
	return player_character

func get_previous_player_by_position(set_as_selected: bool) -> PlayerCharacter:
	var wanted_id = selected_character.position_id - 1
	if wanted_id <= -1: wanted_id = player_characters.size() - 1
	var player_character = player_characters[wanted_id]
	if set_as_selected: set_selected_character(player_character)
	return player_character

func reset_characters_manager() -> void:
	player_characters.clear()
	enemy_characters.clear()
	players_positions_by_id = [null, null, null]
	enemies_positions_by_id= [null, null, null]
	dead_enemy_characters.clear()
	is_initialized = false
	selected_character = null
	is_a_character_performing_move = false
	is_a_hand_manipulation_enabled = false
	is_wave_dead = false
	_are_player_characters_initialized = false
	_are_enemy_characters_initialized = false

func get_allies_characters_ordered(character: Character) -> Array[Character]:
	return players_positions_by_id if character is PlayerCharacter else enemies_positions_by_id

func get_opponents_characters_ordered(character: Character) -> Array[Character]:
	return enemies_positions_by_id if character is PlayerCharacter else players_positions_by_id

func get_allies_characters(character: Character) -> Array[Character]:
	return player_characters if character is PlayerCharacter else enemy_characters

func get_opponents_characters(character: Character) -> Array[Character]:
	return enemy_characters if character is PlayerCharacter else player_characters
	
#endregion

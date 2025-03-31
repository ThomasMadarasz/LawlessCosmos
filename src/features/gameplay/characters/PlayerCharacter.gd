extends Character

class_name PlayerCharacter

signal on_move_chosen(move_name: String, character_name: String)
signal on_player_character_perfoms_move()

var artifacts = {}

var remaining_discards_amount_this_turn: int
var is_choosing_target_to_perform_move: bool = false

var suit_amount_bonus = {0:0, 1:0, 2:0, 3:0}

func initialize() -> void:
	super.initialize()
	_initialize_hand()
	_initalize_visuals()
	global_position = BattleStageManager.level_manager.player_characters_positions[position_id].global_position
	scale = BattleStageManager.level_manager.player_characters_positions[position_id].scale
	CharactersManager.register_player_character(self)

func _initialize_hand() -> void:
	hand = BattleStageManager.level_manager.player_hands[position_id]
	hand.initialize(self)
	hand.show()
	hand.artifacts_ui.owner_character = self
	hand.ui.register_owner_character(self)
	hand.ui.initialize_colors(character_resource.gradient.colors[0])

func _initalize_visuals() -> void:
	set_character_alpha_shader_value(0)
	ui.selection_arrow.self_modulate = character_resource.gradient.colors[0]

#region Signals

func _connect_signals() -> void:
	CharactersManager.on_characters_manager_initialized.connect(_on_characters_manager_initialized)
	super._connect_signals()

func _on_characters_manager_initialized() -> void:
	var moves_textures = [null, null, null, null]
	for n in character_resource.current_moves.size():
		moves_textures[n] = character_resource.current_moves[n].texture
	hand.ui.set_moves_descriptions()

func _on_move_logic_ended(move: Move) -> void:
	super._on_move_logic_ended(move)
	hand.current_final_hand = FinalHandData.new(self)

#endregion

func choose_target(character: Character) -> void:
	var move = character_resource.current_moves[hand.current_final_hand.chosen_suit]
	if not move.is_target_valid(character): return
	_perform_move(move, character)


func select_suit(suit_id : int) -> void:
	if CharactersManager.is_a_character_performing_move == true: return
	if status.check_for_stun(): return
	show_targets(suit_id)
	BattleStageManager.start_targeting_phase()
	hand.current_final_hand.chosen_suit = suit_id as Enums.Suits
	is_choosing_target_to_perform_move = true
	var move = character_resource.current_moves[hand.current_final_hand.chosen_suit]
	InputManager.current_move = move
	var available_targets = move.get_allowed_targets()
	for n in available_targets.keys():
		n.feedback.play_target_feedback(false)
	InputManager.register_available_targets(available_targets)
	on_move_chosen.emit(move.formatted_name, character_resource.display_name)
	#if available_targets.size() < 1:
		#perform_move(null)
		#stop_target_choice()

func stop_target_choice(is_canceled := true) -> void:
	is_choosing_target_to_perform_move = false
	CharactersManager.hide_slots()
	for n in hand.ui.moves_ui.moves_buttons:
		n.set_selected(false)
	for n in CharactersManager.player_characters + CharactersManager.enemy_characters:
		n.feedback.reset_target_feedback()
	InputManager.move_targetable_characters.clear()
	BattleStageManager.stop_targeting_phase(is_canceled)

func _perform_move(move: Move, target: Character) -> void:
	on_player_character_perfoms_move.emit()
	stop_target_choice(false)
	super._perform_move(move, target)

func _complete_move() -> void:
	hand.discard_selected_cards(true)
	super._complete_move()


func add_artifact(artifact_resource : ArtifactResource) -> void:
	var current_stack = 1 if not artifacts.keys().has(artifact_resource) else artifacts[artifact_resource] + 1
	artifacts[artifact_resource] = current_stack
	artifact_resource.enable(self)

func show_targets(id: int = 0) -> void:
	var move = character_resource.current_moves[id]
	var available_targets = move.get_allowed_targets()
	for n in available_targets.values():
		for character in n:
			var slot = _level_manager.player_characters_positions[character.position_id] if character is PlayerCharacter else _level_manager.enemy_characters_positions[character.position_id] as Slot
			slot.set_targetable(move.color)

func reset_preview() -> void:
	var moves_to_preview: Array[bool] = [false, false, false, false]
	hand.ui.moves_ui.update_moves_preview(moves_to_preview, character_resource.current_moves)

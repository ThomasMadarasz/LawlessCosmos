extends Node2D

signal on_character_clicked(character : Character)
signal on_card_clicked(card: Card)
signal on_card_selected(card: Card)
signal on_hand_clicked(hand: Hand)
signal on_card_dropped(dropped_card: Card, target_hand: Hand)
signal on_move_canceled()

const _INPUT_DATA: InputManagerData = preload("res://datas/resources/managers/d_input_manager.tres")

var move_targetable_characters = {} #Character : Array[Character]

var is_dragging : bool
var current_move: Move
var current_dragged_card: Card

var _current_selected_card: Card

var _space_state : PhysicsDirectSpaceState2D
var _results : Array[Dictionary]

var _hit_obj: Node:
	get:
		if not is_instance_valid(_hit_obj):  
			return null
		return _hit_obj
	set(new_obj):
		_is_hit_obj_new = not _hit_obj == new_obj
		_hit_obj = new_obj

var _drag_hold_timer: Timer

var _current_move_target: Character

var _is_hit_obj_new: bool

#region Godot API

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_initialize_timers()
	_connect_signals()

func _physics_process(_delta) -> void:
	if SettingsManager.is_settings_visible or SceneManager.is_switching_scene: return
	if BattleStageManager.is_battle_stage_initialized:
		_calculate_mouse_point_results()
	if _is_hands_combination_phase():
		_set_hit_obj()
	elif _is_targeting_phase():
		_set_hit_obj()
		_handle_mouse_character_move_preview()

func _process(_delta) -> void:
	if not BattleStageManager.is_battle_stage_initialized or SettingsManager.is_settings_visible: return
	if is_dragging: update_dragged_card()

func _input(_event) -> void:
	#Prevents gameplay related inputs while settings are opened or if battle stage is not initialized
	if SettingsManager.is_settings_visible or not BattleStageManager.is_battle_stage_initialized: return
	if _is_targeting_phase(): _handle_power_previews()

#endregion


#region Init

func _initialize_timers() -> void:
	_drag_hold_timer = Timer.new()
	_drag_hold_timer.wait_time = _INPUT_DATA.drag_hold_time
	_drag_hold_timer.one_shot = true
	_drag_hold_timer.autostart = false
	_drag_hold_timer.timeout.connect(_drag_card)
	add_child(_drag_hold_timer)

#endregion


#region Signals

func _connect_signals() -> void:
	BattleStageManager.on_hands_drawn.connect(_on_hands_drawn)
	InputHandler.on_action_select_pressed.connect(_on_action_select_pressed)
	InputHandler.on_action_select_released.connect(_on_action_select_released)
	InputHandler.on_action_cancel_pressed.connect(_on_action_cancel_pressed)
	InputHandler.on_action_escape_pressed.connect(_on_action_escaped_pressed)
	InputHandler.on_action_debug_pause_pressed.connect(_on_action_debug_pause_pressed)

func _on_action_select_pressed() -> void:
	if _is_hands_combination_phase() or _is_targeting_phase():
		_check_for_dragged_card(_hit_obj)

func _on_action_select_released() -> void:
	if _is_hands_combination_phase() or _is_targeting_phase():
		if not is_dragging: _send_click_event(_hit_obj)
		if is_dragging: _drop_card()
		elif _results.size() > 0 and _hit_obj is Card and not CharactersManager.is_a_hand_manipulation_enabled:
			on_card_selected.emit(_hit_obj)
		_stop_dragging()
	
	if _is_hands_combination_phase():
		if _results.size() > 0 and _hit_obj is Card and not CharactersManager.is_a_hand_manipulation_enabled: 
			_hit_obj.lock()
		elif _hit_obj is Hand: 
			CharactersManager.set_selected_character(_hit_obj.owner_character)
	
	elif _is_targeting_phase():
		if not _hit_obj == null and _hit_obj is Character and not CharactersManager.selected_character == null and CharactersManager.selected_character is PlayerCharacter:
				CharactersManager.selected_character.choose_target(_hit_obj)
		elif _results.size() > 0 and _hit_obj is Card:
			if _is_targeting_phase(): _cancel_move()

func _on_action_cancel_pressed() -> void:
	if _is_hands_combination_phase(): _cancel_hand_manipulation()
	elif _is_targeting_phase():  _cancel_move()

func _on_action_escaped_pressed() -> void:
	if _is_hands_combination_phase(): _cancel_hand_manipulation()
	elif _is_targeting_phase():  _cancel_move()

func _on_action_debug_pause_pressed() -> void:
	_resume_pause_game()

func _on_hands_drawn() -> void:
	_current_selected_card = CharactersManager.get_default_player_character().hand.current_cards_order[0]
	_current_selected_card.preview_focus(true)

#endregion



#region Main

func _calculate_mouse_point_results() -> void:
	_space_state = get_world_2d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	_results = _space_state.intersect_point(query, 6)

func _set_hit_obj() -> void:
	var new_obj = null
	if _results.size() < 1: 
		_hit_obj = new_obj
		return
	if not is_dragging:
		var collider_parent = null
		for i in _results.size():
			var parent = _results[i].collider.get_parent()
			if collider_parent == null or i == 0: 
				collider_parent = parent
			elif parent is Card: 
				if not collider_parent is Card or parent.input_priority > collider_parent.input_priority:
					collider_parent = parent
		if collider_parent is Card: new_obj = collider_parent
		elif new_obj == null:
			if collider_parent is Character or collider_parent is Hand : new_obj = collider_parent
		if is_instance_valid(new_obj) and new_obj is Card and not new_obj.owner_hand == null:
			set_new_selected_card(new_obj)
	_hit_obj = new_obj

func _handle_mouse_character_move_preview() -> void:
	if _hit_obj == null:
		CharactersManager.reset_characters_colors()
		for n in move_targetable_characters.keys():
			n.feedback.play_target_feedback(false)
		CharactersManager.hide_slots(true)
		return
	if not CharactersManager.selected_character == null and CharactersManager.selected_character is PlayerCharacter and _hit_obj is Character and move_targetable_characters.has(_hit_obj):
		for n in move_targetable_characters[_hit_obj]:
			_current_move_target = n
			_current_move_target.feedback.play_target_feedback(true)
			var slot = BattleStageManager.level_manager.player_characters_positions[_current_move_target.position_id] if _current_move_target is PlayerCharacter else BattleStageManager.level_manager.enemy_characters_positions[_current_move_target.position_id]
			slot.set_targetable(current_move.color)
			slot.set_targeted()

func _drag_card() -> void: 
	is_dragging = true
	current_dragged_card.is_dragged = true
	current_dragged_card.input_priority = 100
	current_dragged_card.z_index = 10
	if current_dragged_card.owner_hand is Hand: 
		CharactersManager.set_selected_character(current_dragged_card.owner_hand.owner_character)

func _drop_card() -> void:
	current_dragged_card.reset_to_rest_pos()
	current_dragged_card.is_dragged = false
	current_dragged_card.z_index = 0
	current_dragged_card.owner_hand.cards_holder.update_cards_positions()
	var target_hand = null
	for n in _results:
		var n_collider_parent = n.collider.get_parent()
		if not n_collider_parent == current_dragged_card:
			if n_collider_parent is Card: 
				target_hand = n_collider_parent.owner_hand
			if n_collider_parent is Hand:
				target_hand = n_collider_parent
	on_card_dropped.emit(current_dragged_card, target_hand)

func _stop_dragging() -> void:
	current_dragged_card = null
	_drag_hold_timer.stop()
	is_dragging = false

func update_dragged_card() -> void:
	if current_dragged_card == null: return
	var mouse_pos = get_viewport().get_mouse_position()
	current_dragged_card.set_destination(mouse_pos, false)
	current_dragged_card.owner_hand.cards_holder.update_cards_positions_on_card_dragged(current_dragged_card)

func set_new_selected_card(new_card: Card) -> void:
	if _current_selected_card == new_card: return
	if is_instance_valid(_current_selected_card): _current_selected_card.preview_focus(false)
	_current_selected_card = new_card

func _send_click_event(current_hit_obj) -> void:
		if current_hit_obj is Character: 
			on_character_clicked.emit(current_hit_obj)
		elif current_hit_obj is Hand:
			on_hand_clicked.emit(current_hit_obj)
		elif current_hit_obj is Card:
			on_card_clicked.emit(current_hit_obj)

func _check_for_dragged_card(current_hit_obj) -> void:
	if _results and _results.size() > 0:
		if _current_selected_card and _current_selected_card == current_hit_obj and not is_dragging and _drag_hold_timer.is_stopped():
			_drag_hold_timer.start()
			current_dragged_card = _current_selected_card

func _cancel_move() -> void:
	CharactersManager.selected_character.stop_target_choice()
	on_move_canceled.emit()

func _cancel_hand_manipulation() -> void:
	if not CharactersManager.is_a_hand_manipulation_enabled: return
	BattleStageManager.level_manager.hand_manipulations_manager.current_manipulation.resource.disable_hand_manipulation()

func _handle_power_previews() -> void:
	if _is_hit_obj_new:
		for n in CharactersManager.characters:
			n.ui.hide_efficiency_preview()
		if _hit_obj is Character:
			var move = CharactersManager.selected_character.get_current_move()
			var allowed_targets = move.get_allowed_targets()
			if allowed_targets.has(_hit_obj):
				for n in allowed_targets[_hit_obj]:
					n.ui.show_efficiency_preview(move)
		_is_hit_obj_new = false


func register_available_targets(targets: Dictionary) -> void:
	move_targetable_characters = targets

#endregion

#region Utils

func _resume_pause_game() -> void:
	get_tree().paused = not get_tree().paused

func _is_hands_combination_phase() -> bool: return BattleStageManager.is_hand_combination_phase()

func _is_targeting_phase() -> bool: return BattleStageManager.is_targeting_phase()

func _is_moves_solving_phase() -> bool: return BattleStageManager.is_moves_solving_phase()

#endregion

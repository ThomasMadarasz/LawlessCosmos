extends Node2D

class_name CardHolder

signal on_sort_custom()

@export var _hand_stroke: NinePatchRect
@export var _y_drag_detection_distance: float

@export var _displacement_lerp_speed: float = 5

@export var _cards_margin_x : float = 34
@export var _cards_offset_y : float = 30

var _cards_length_offset: Vector2
var _destination_size: Vector2 
var _destination_pos: Vector2
var _current_space_between_cards : float

@onready var _cards_center_x : float = Card.CARD_WIDTH - (2 * _cards_margin_x)
@onready var _hand_stroke_base_size: Vector2 = _hand_stroke.size
@onready var _hand_stroke_destination_size: Vector2 = _hand_stroke.size

const _MAX_HAND_SIZE = 600.0
const _MIN_HAND_SIZE = 460.0

var _is_initialized : bool = false

var hand : Hand
var owner_character : PlayerCharacter

func initialize(hand_arg : Hand) -> void:
	hand = hand_arg
	owner_character = hand.owner_character
	_destination_size = hand.hand_container.size
	_destination_pos = hand.global_position
	_connect_signals()
	_is_initialized = true

func _process(delta) -> void:
	if not _is_initialized: return
	move_and_resize(delta)


#region Signals

func _connect_signals() -> void:
	BattleStageManager.on_player_won_wave.connect(on_player_won_wave)
	BattleStageManager.level_manager.rewards_manager.on_upgrades_chosen.connect(_on_upgrades_chosen)
	CharactersManager.on_character_selected.connect(_on_character_selected)
	owner_character.on_character_performed_move.connect(_on_character_performed_move)

func on_player_won_wave() -> void:
	var hand_size = _MIN_HAND_SIZE 
	_destination_size = Vector2(hand_size, hand.hand_container.size.y)
	_destination_pos = BattleStageManager.level_manager.get_hand_position(owner_character.position_id, true) - (_destination_size/2)

func _on_upgrades_chosen() -> void:
	_hand_stroke_destination_size = _hand_stroke_base_size
	set_destination_size_and_pos()

func _on_character_selected(_character: Character) -> void:
	if BattleStageManager.is_upgrading_phase: return
	set_destination_size_and_pos()
	update_cards_positions(true)

func _on_character_performed_move(_character: Character) -> void:
	update_cards_positions(true)

#endregion


#region Position & Rotation

func _set_cards_position_and_rotation_spots() -> void:
	hand.current_cards_order_position.clear()
	_current_space_between_cards = _cards_margin_x if not owner_character == CharactersManager.selected_character else _cards_center_x + _cards_margin_x
	if _current_space_between_cards * (hand.current_cards_order.size()-1) > _MAX_HAND_SIZE:
		_current_space_between_cards = _MAX_HAND_SIZE / float(hand.current_cards_order.size())
	for i in range(hand.current_cards_order.size()):
		hand.current_cards_order_position[i] = Vector2(_current_space_between_cards * i, _cards_offset_y)

func update_cards_positions(are_positions_and_rotations_to_update : bool = false) -> void:
	if are_positions_and_rotations_to_update or not hand.current_cards_order.size() == hand.current_cards_order_position.size() : _set_cards_position_and_rotation_spots()
	_cards_length_offset = Vector2(((hand.current_cards_order.size()-1) * _current_space_between_cards)/2, 0)
	for n in hand.current_cards_order.size(): 
		if hand.current_cards_order[n].is_dragged: continue
		move_child(hand.current_cards_order[n], n)
		hand.current_cards_order[n].input_priority = n
		var destination = hand.current_cards_order_position[n] - _cards_length_offset + hand.global_position + (_destination_size/2)
		hand.current_cards_order[n].set_destination(destination, true)
		if BattleStageManager.current_battle_state == BattleStageManager.BattleState.DRAWING_PHASE: 
			await get_tree().create_timer(hand.current_cards_order[n].origin_deck.draw_speed).timeout

func set_destination_size_and_pos() -> void:
	var hand_size = _MIN_HAND_SIZE if not CharactersManager.selected_character == owner_character else _MAX_HAND_SIZE + Card.CARD_WIDTH
	_destination_size = Vector2(hand_size, hand.hand_container.size.y)
	_destination_pos = BattleStageManager.level_manager.get_hand_position(owner_character.position_id) - (_destination_size/2)

func move_and_resize(delta: float) -> void:
	hand.hand_container.size = hand.hand_container.size.lerp(_destination_size, delta * _displacement_lerp_speed)
	hand.hand_container.get_parent().size = hand.hand_container.size
	hand.size = hand.hand_container.size
	if not hand.global_position == _destination_pos:
		hand.global_position = hand.global_position.lerp(_destination_pos, delta * _displacement_lerp_speed)
		if hand.global_position.distance_to(_destination_pos) < 0.1: 
			hand.global_position = _destination_pos
	if not _hand_stroke.custom_minimum_size == _hand_stroke_destination_size:
		_hand_stroke.custom_minimum_size = _hand_stroke.custom_minimum_size.lerp(_hand_stroke_destination_size, delta * _displacement_lerp_speed)
		_hand_stroke.size.y = _hand_stroke.custom_minimum_size.y
		if abs(_hand_stroke.custom_minimum_size.y - _hand_stroke_destination_size.y) < 0.1: 
			_hand_stroke.custom_minimum_size = _hand_stroke_destination_size


func update_cards_positions_on_card_dragged(dragged_card: Card) -> void:
	if abs(dragged_card.global_position.y - hand.global_position.y) <= _y_drag_detection_distance:
		var current_pos_order = hand.current_cards_order.find(dragged_card)
		var closest_pos_order = hand.current_cards_order.find(dragged_card)
		var current_card_distance = abs(hand.current_cards_order_position[closest_pos_order].x - _cards_length_offset.x + hand.global_position.x + (_destination_size/2).x - dragged_card.global_position.x)
		for n in hand.current_cards_order_position.size():
			var challenged_card_distance = abs(hand.current_cards_order_position[n].x - _cards_length_offset.x + hand.global_position.x + (_destination_size/2).x - dragged_card.global_position.x)
			if challenged_card_distance < current_card_distance:
				current_card_distance = challenged_card_distance
				closest_pos_order = n
		if current_pos_order == closest_pos_order: return
		hand.current_cards_order.remove_at(current_pos_order)
		hand.current_cards_order.insert(closest_pos_order, dragged_card)
		hand.current_sort_mode = Enums.SortModes.CUSTOM
		on_sort_custom.emit()
		update_cards_positions()

#endregion

extends Sprite2D

class_name Card

@export var _displacement_lerp_speed: float

var card_resource: CardResource

var is_active := false

var mat: Material
var is_locked: bool
var is_dragged: bool

var owner_hand: Hand
var origin_deck: Deck

var current_color: Color

var destination: Vector2
var _rest_pos: Vector2

var input_priority: int
var is_discarding := false

const CARD_WIDTH = 144
const CARD_HEIGHT = 196
const _POKER_HAND_MAX_SIZE = 5

func _ready() -> void:
	add_to_group("cards")
	mat = self.material
	_connect_signals()

func _connect_signals() -> void:
	BattleStageManager.on_player_won_wave.connect(reset)

func _process(delta) -> void:
	if not is_active: return
	_update_material()
	_move(delta)

func _move(delta: float) -> void:
	if position.distance_to(destination) > 0.01:
		position = position.lerp(destination, delta * _displacement_lerp_speed)
		if position.distance_to(destination) <= 0.01:
			position = destination

func _update_material() -> void:
	region_rect = Rect2(card_resource.value_id * CARD_WIDTH, card_resource.suit * CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT)

func set_destination(pos: Vector2, is_rest_pos: bool) -> void:
	destination = get_parent().to_local(pos)
	if is_rest_pos: 
		_rest_pos = pos

func reset_to_rest_pos() -> void: 
	destination = _rest_pos

func lock() -> void:
	if not is_active or is_discarding: return
	if owner_hand is Hand: CharactersManager.set_selected_character(owner_hand.owner_character)
	var hand = CharactersManager.selected_character.hand
	if not hand.current_selected_cards.has(self):
		if hand.current_selected_cards.size() >= _POKER_HAND_MAX_SIZE: return
		hand.current_selected_cards.push_back(self)
	else: hand.current_selected_cards.remove_at(hand.current_selected_cards.find(self))
	is_locked = not is_locked
	owner_hand = hand
	current_color = hand.owner_character.character_resource.gradient.colors[hand.owner_character.character_resource.gradient.colors.size() - 1]
	mat.set_shader_parameter('selection_color', CharactersManager.selected_character.character_resource.gradient.colors[CharactersManager.selected_character.character_resource.gradient.colors.size() - 1])
	mat.set_shader_parameter('is_selected', is_locked)
	var final_hand = hand.calculate_current_final_hand()
	hand.update_preview(final_hand)


func preview_focus(is_enabled: bool) -> void:
	if not is_active: return
	mat.set_shader_parameter('is_focus', is_enabled)
	if is_enabled: mat.set_shader_parameter('focus_color', owner_hand.owner_character.character_resource.gradient.colors[0])

func discard() -> void:
	is_discarding = true
	reset()

func reset() -> void:
	if not is_active: return
	is_active = false
	get_parent().remove_child(self)
	ResourcesManager.available_cards.push_back(self)
	ResourcesManager.cards_pool.add_child(self)
	global_position = ResourcesManager.cards_pool.global_position
	set_destination(global_position, true)
	card_resource = null
	is_locked = false
	is_dragged = false
	if not owner_hand == null:
		if owner_hand.current_cards.has(self): owner_hand.current_cards.erase(self)
		if owner_hand.current_cards_order.has(self): owner_hand.current_cards_order.erase(self)
	owner_hand = null
	destination = Vector2.ZERO
	_rest_pos = Vector2.ZERO
	input_priority = 0
	is_discarding = false
	mat.set_shader_parameter('is_selected', false)
	mat.set_shader_parameter('is_focus', false)
	hide()

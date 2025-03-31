extends Node

class_name Deck

const _CARD_PREFAB = preload("res://datas/prefabs/cards/p_card.tscn")

@export var deck_resource: DeckResource
@export var draw_speed: float
@export var deck_label: Label
@export var discard_pile_label: Label
@export var discard_pile: Control

@export var _is_current_deck: bool
@export var _piles_label: Label
@export var _cards_parent: Node2D
@export var _deck_texture_rect: TextureRect
@export var _cards_panel: Panel

var _displayed_cards: Array[Card]
var _open_deck_timer: Timer
var _open_discard_pile_timer: Timer
var _is_deck_opened: bool
var _is_discard_pile_opened: bool

const _SPACE_HEIGHT = 150
const _SPACE_WIDTH = 100
const _MARGIN = 125
const _HOVER_TIME = 1.0

#region Inititalization

func _ready() -> void:
	_connect_signals()
	if not BattleStageManager.current_level_resource.waves_array[BattleStageManager.current_wave_index].deck_resource == null: 
		deck_resource = BattleStageManager.current_level_resource.waves_array[BattleStageManager.current_wave_index].deck_resource
	deck_resource.initialize()
	if BattleStageManager.current_level_resource.waves_array[BattleStageManager.current_wave_index].deck_resource == null: 
		shuffle_cards(false)
	_register_to_characters_manager()
	_set_up_timers()

func _set_up_timers() -> void:
	_open_deck_timer = Timer.new()
	add_child(_open_deck_timer)
	_open_deck_timer.wait_time = _HOVER_TIME
	_open_deck_timer.one_shot = true
	_open_deck_timer.autostart = false
	_open_deck_timer.timeout.connect(_show_deck)
	_open_discard_pile_timer = Timer.new()
	add_child(_open_discard_pile_timer)
	_open_discard_pile_timer.wait_time = _HOVER_TIME
	_open_discard_pile_timer.one_shot = true
	_open_discard_pile_timer.autostart = false
	_open_discard_pile_timer.timeout.connect(_show_discard_pile)

#endregion


#region Signals

func _connect_signals() -> void:
	SceneManager.on_game_scene_instantiated.connect(_on_game_scene_instantiated)

func _on_game_scene_instantiated(_level_manager : LevelManager) -> void:
	BattleStageManager.on_player_won_wave.connect(deck_resource.reset)

func _on_mouse_entered_deck() -> void:
	if not BattleStageManager.is_hand_combination_phase(): return
	_open_deck_timer.start()

func _on_mouse_entered_discard_pile() -> void:
	if not BattleStageManager.is_hand_combination_phase(): return
	_open_discard_pile_timer.start()

func _on_mouse_exited_pile() -> void:
	_open_deck_timer.stop()
	_open_discard_pile_timer.stop()
	if _is_deck_opened or _is_discard_pile_opened:
		_cards_panel.hide()
		for n in _displayed_cards:
			n.reset()
		_displayed_cards.clear()
		_is_deck_opened = false
		_is_discard_pile_opened = false

#endregion

#region Main

func shuffle_cards(is_discarded_cards_added: bool = true) -> void:
	if is_discarded_cards_added:
		deck_resource.cards_resources.append_array(deck_resource.discarded_cards_resources)
		deck_resource.discarded_cards_resources.clear()
	deck_resource.cards_resources.shuffle()
	update_labels()

func update_labels() -> void:
	deck_label.text = str(deck_resource.cards_resources.size())
	discard_pile_label.text = str(deck_resource.discarded_cards_resources.size())

func draw_cards_resources(amount: int) -> Array[CardResource]:
	var drawn_cards_resources: Array[CardResource] = []
	if deck_resource.cards_resources.size() <= 0:
		shuffle_cards(true)
	for i in amount:
		var card_resource = deck_resource.cards_resources[0]
		drawn_cards_resources.push_back(card_resource)
		deck_resource.cards_resources.remove_at(0)
		deck_label.text = str(deck_resource.cards_resources.size())
		if deck_resource.cards_resources.size() <= 0:
			shuffle_cards(true)
	return drawn_cards_resources

func display_card(resource: CardResource, parent: Node, start_position : Vector2 = _deck_texture_rect.global_position) -> Card:
	var card_instance = null
	if ResourcesManager.available_cards.size() > 0:
		card_instance = ResourcesManager.available_cards.front()
		ResourcesManager.available_cards.erase(card_instance)
		card_instance.get_parent().remove_child(card_instance)
	else:
		card_instance = _CARD_PREFAB.instantiate() as Card
	parent.add_child(card_instance)
	card_instance.show()
	card_instance.is_active = true
	card_instance.card_resource = resource
	card_instance.destination = start_position
	card_instance.global_position = start_position
	return card_instance

func remove_specific_cards_resources(cards_resources : Array[CardResource]) -> void:
	for n in cards_resources:
		if deck_resource.cards_resources.size() <= 0:
			shuffle_cards(true)
		if deck_resource.cards_resources.has(n) : deck_resource.cards_resources.erase(n)
		deck_label.text = str(deck_resource.cards_resources.size())

func discard_card(card: CardResource) -> void: 
	deck_resource.discarded_cards_resources.push_back(card)
	discard_pile_label.text = str(deck_resource.discarded_cards_resources.size())

func _register_to_characters_manager() -> void:
	if _is_current_deck: 
		BattleStageManager.current_deck = self
	CharactersManager.check_initialization()

func _show_deck() -> void:
	_is_deck_opened = true
	_show_cards(deck_resource.cards_resources, _deck_texture_rect.global_position)
	_piles_label.text = tr("DECK_LIST")


func _show_discard_pile() -> void:
	_is_discard_pile_opened = true
	_show_cards(deck_resource.discarded_cards_resources, discard_pile.global_position)
	_piles_label.text = tr("DISCARD_PILE_LIST")

func _show_cards(cards: Array[CardResource], start_position: Vector2) -> void:
	_cards_panel.show()
	var duplicated_card_resources = cards.duplicate()
	for n in duplicated_card_resources:
		if not is_instance_valid(n):
			duplicated_card_resources.erase(n)
	duplicated_card_resources.sort_custom(sort_cards)
	var array_of_suit_arrays_of_cards = [[], [], [], []]
	_displayed_cards = []
	for n in duplicated_card_resources:
		var card_instance = display_card(n, _cards_parent, start_position)
		array_of_suit_arrays_of_cards[n.suit].push_back(card_instance)
		_displayed_cards.push_back(card_instance)
	for i in array_of_suit_arrays_of_cards.size():
		for j in array_of_suit_arrays_of_cards[i].size():
			array_of_suit_arrays_of_cards[i][j].set_destination(Vector2(j * _SPACE_WIDTH + _MARGIN, i * _SPACE_HEIGHT + _MARGIN) + _cards_panel.global_position, true)

#endregion

#region Utils

func sort_cards(a: CardResource, b: CardResource):
	if a.suit < b.suit:
		return true
	elif a.suit == b.suit:
		if b.value_id == 0: return false
		elif a.value_id > b.value_id or a.value_id == 0:
			return true
	return false

#endregion

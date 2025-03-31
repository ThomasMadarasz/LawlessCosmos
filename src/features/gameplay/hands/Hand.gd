extends Control

class_name Hand

signal on_card_drawn(card: Card)
signal on_card_discarded(card: Card, is_played : bool)

var current_cards_order: Array[Card]
var current_cards = {} # Card:CardResource
var current_cards_order_position = {} # int : Vector2
var current_sort_mode: Enums.SortModes

var deck : Deck

@export var cards_holder: CardHolder
@export var hand_container : VBoxContainer
@export var _hand_full_pop_up: Control
@export var ui: HandUi
@export var artifacts_ui : ArtifactsUi


var current_final_hand: FinalHandData

var current_selected_cards: Array[Card]

var owner_character: Character

func initialize(character: Character) -> void:
	owner_character = character
	current_final_hand = FinalHandData.new(owner_character)
	current_sort_mode = Enums.SortModes.VALUES
	_connect_signals()
	ui.initialize()
	cards_holder.initialize(self)
	deck = BattleStageManager.current_deck

#region Signals

func _connect_signals() -> void:
	BattleStageManager.on_new_turn.connect(_on_new_turn)
	InputHandler.on_action_sort_pressed.connect(_change_sort_cards_mode)
	InputHandler.on_action_sort_values_pressed.connect(_sort_by_values)
	InputHandler.on_action_sort_suits_pressed.connect(_sort_by_suits)
	BattleStageManager.on_player_won_wave.connect(discard_all_cards)

func _on_new_turn() -> void:
	if not owner_character.status.check_for_paralysis():
		var cards_amount = owner_character.character_resource.hand_data.reload_size
		if not current_cards.size() >= owner_character.character_resource.hand_data.draw_limit:
			draw_cards(cards_amount)
	if owner_character.status.check_for_acceleration():
		draw_cards(1)


#endregion

#region Draw

func draw_cards(amount: int) -> Array[Card]:
	var drawn_cards = [] as Array[Card]
	for i in amount:
		var n = deck.draw_cards_resources(1)[0]
		var card = _instantiate_card(n)
		drawn_cards.push_back(card)
	return drawn_cards

func draw_single_card() -> Card:
	return draw_cards(1)[0]

func draw_specific_card(card_resource: CardResource, draw_position: Vector2 = BattleStageManager.current_deck.position) -> Card:
	var card = _instantiate_card(card_resource)
	card.global_position = draw_position
	return card

func _instantiate_card(card_resource : CardResource) -> Card:
	var instantiated_card = deck.display_card(card_resource, cards_holder)
	add_card(instantiated_card)
	instantiated_card.set_destination(self.global_position + (hand_container.size/2), false)
	instantiated_card.origin_deck = deck
	on_card_drawn.emit(instantiated_card)
	sort_cards()
	return instantiated_card

func fill_hand(is_initial_draw := false) -> void:
	var card_amount = owner_character.hand_data.initial_draw_amount if is_initial_draw else owner_character.hand_data.draw_limit
	if len(current_cards) < card_amount: 
		draw_cards(card_amount - len(current_cards))

func add_card(added_card: Card) -> void:
	current_cards[added_card] = added_card.card_resource
	current_cards_order.push_back(added_card)
	added_card.owner_hand = self

#endregion

#region Discard

func discard_card(discarded_card: Card, is_played := true) -> void:
	if not discarded_card.owner_hand == self: return
	if current_selected_cards.has(discarded_card):
		current_selected_cards.erase(discarded_card)
	discarded_card.preview_focus(false)
	discarded_card.is_locked = false
	current_cards_order.erase(discarded_card)
	current_cards.erase(discarded_card)
	discarded_card.origin_deck.discard_card(discarded_card.card_resource)
	discarded_card.discard()
	on_card_discarded.emit(discarded_card, is_played)

func discard_cards(cards: Array[Card], is_played := true) -> void:
	var discarded_cards = cards.duplicate(true)
	for n in discarded_cards:
		discard_card(n, is_played)

func discard_all_cards(is_played := true) -> void:
	var cards_to_discard = current_cards_order
	if cards_to_discard.size() > 0 : discard_cards(cards_to_discard, is_played)
	current_selected_cards.clear()

func discard_selected_cards(is_played := true) -> void:
	discard_cards(current_selected_cards, is_played)
	current_selected_cards.clear()

#endregion



#region Sort Cards

func _change_sort_cards_mode() -> void:
	match current_sort_mode:
		Enums.SortModes.CUSTOM: _sort_by_values()
		Enums.SortModes.VALUES: _sort_by_suits()
		Enums.SortModes.SUITS: _sort_by_values()
		_: _sort_by_values()

func sort_cards() -> void:
	match current_sort_mode:
		Enums.SortModes.CUSTOM: _sort_by_values()
		Enums.SortModes.VALUES: _sort_by_values()
		Enums.SortModes.SUITS: _sort_by_suits()

func _sort_by_values() -> void:
	current_sort_mode = Enums.SortModes.VALUES
	current_cards_order.sort_custom(sort_ascending_card_value)
	cards_holder.update_cards_positions()

func _sort_by_suits() -> void:
	current_sort_mode = Enums.SortModes.SUITS
	current_cards_order.sort_custom(sort_descending_suits)
	cards_holder.update_cards_positions()

#endregion

func reset_preview() -> void:
	current_final_hand = FinalHandData.new(owner_character)
	update_preview(current_final_hand)

func update_preview(hand: FinalHandData) -> void:
	ui.update_preview(hand)

func show_hand_full_pop_up() -> void:
	_hand_full_pop_up.show()
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	tween.tween_method(fade_out_hand_full_pop_up, 1.0, 0.0, 2.5)
	tween.tween_callback(_hand_full_pop_up.hide)

func fade_out_hand_full_pop_up(given_number: float) -> void:
	_hand_full_pop_up.modulate.a = given_number

func calculate_current_final_hand() -> FinalHandData:
	var selected_card_resources: Array[CardResource] = []
	current_selected_cards.sort_custom(sort_ascending_card_value)
	var cards = {}
	for n in current_selected_cards: 
		selected_card_resources.push_back(n.card_resource)
		cards[n.card_resource] = n
	current_final_hand = FinalHandCalculator.get_final_hand(selected_card_resources, cards, owner_character)
	return current_final_hand

#region Utils

func is_hand_full(play_feedback: bool) -> bool:
	var is_hand_full_value = current_cards.size() >= owner_character.character_resource.hand_data.max_hand_size
	if play_feedback and is_hand_full_value:
		show_hand_full_pop_up()
	return is_hand_full_value

func sort_descending_suits(a: Card, b: Card):
	if a.card_resource.suit < b.card_resource.suit:
		return true
	elif a.card_resource.suit == b.card_resource.suit:
		if b.card_resource.value_id == 0: return false
		elif a.card_resource.value_id > b.card_resource.value_id or a.card_resource.value_id == 0:
			return true
	return false

func sort_ascending_card_value(a: Card, b: Card):
	if b.card_resource.value_id == 0: 
		if a.card_resource.value_id == 0 and a.card_resource.suit < b.card_resource.suit:
			return true
		return false
	elif a.card_resource.value_id > b.card_resource.value_id or a.card_resource.value_id == 0:
		return true
	elif a.card_resource.value_id > b.card_resource.value_id:
		if a.card_resource.suit < b.card_resource.suit:
			return true
	return false

#endregion

extends Node

class_name HandUi

@export var _hand_stroke: NinePatchRect
@export var _hand_bg: NinePatchRect
@export var _cards_count_label: Label
@export var _draw_limit_label: Label
@export var _character_profile: CharacterProfile

@export var moves_ui: MovesUI

var current_final_hand: FinalHandData

var owner_character: Character


#region Initialization

func initialize() -> void:
	_connect_signals()

func register_owner_character(character: Character) -> void: 
	owner_character = character
	owner_character.hand.on_card_discarded.connect(_on_card_discarded)
	owner_character.hand.on_card_drawn.connect(_on_card_drawn)
	_character_profile.initialize(character)
	for n in moves_ui.moves_buttons:
		n.register_owner_character(character)

func initialize_colors(color: Color) -> void:
	_hand_stroke.self_modulate = color
	var transparent_color = Color(color.r, color.g, color.b, 5.0/255.0)
	_hand_bg.self_modulate = transparent_color
	_character_profile.self_modulate = color

#endregion


#region Signals

func _connect_signals() -> void:
	SettingsManager.on_localization_changed.connect(set_moves_descriptions)
	BattleStageManager.level_manager.rewards_manager.on_upgrades_chosen.connect(set_moves_descriptions)

func _on_card_drawn(_card) -> void:
	update_hand_labels()

func _on_card_discarded(_card, _is_played) -> void:
	update_hand_labels()

#endregion


#region Main

func set_moves_descriptions() -> void:
	for i in 4:
		var move = owner_character.character_resource.current_moves[i]
		moves_ui.moves_buttons[i].update_move_description(move, true)

func update_preview(hand: FinalHandData) -> void:
	var moves_to_preview: Array[bool] = []
	for n in 4:
		if hand.available_suits.has(n): 
			moves_to_preview.push_back(not (owner_character.character_resource.current_moves[n].is_disable_forced or owner_character.status.current_status.has(CharacterStatus.Status.STUN)))
		else: 
			moves_to_preview.push_back(false)
	if hand.cards_resources.size() == 0: moves_to_preview = [false, false, false, false]
	moves_ui.update_moves_preview(moves_to_preview, owner_character.character_resource.current_moves)

func update_hand_labels() -> void:
	_cards_count_label.text = str(owner_character.hand.current_cards.keys().size())
	_draw_limit_label.text = str(owner_character.character_resource.hand_data.draw_limit)

#endregion


#region Utils

func sort_counting_and_ascending(a: CardResource, b: CardResource):
	if current_final_hand.hand_ranking == Enums.HandRankings.FULL_HOUSE or current_final_hand.hand_ranking == Enums.HandRankings.FULL_HOUSE_FLUSH:
		var values: Array[int] = []
		for n in current_final_hand.cards_resources:
			values.push_back(n.value)
		if values.count(a.value) == 3: return true
	if current_final_hand.counting_cards[a] == true and current_final_hand.counting_cards[b] == false: return true
	if a.value > b.value:
		return true
	return false

#endregion

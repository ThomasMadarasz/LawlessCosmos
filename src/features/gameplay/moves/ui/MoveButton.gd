extends Button

class_name MoveButton

@export var _id: int

@export_category("Preview")
@export var _background_panel: PanelContainer
@export var _move_texture_rect: TextureRect
@export var _power_label: Label

@export_category("Hover")
@export var _hover_move_texture_rect: TextureRect
@export var _name_label: Label
@export var _description_label: RichTextLabel
@export var _multiplier_label: Label
@export var _suit_texture_rect: TextureRect
@export var _suits_array: Array[Texture]

var _current_move : Move
var _current_description : String
var _current_name : String
var _current_color : Color

var is_forced_disable: bool

var owner_character : Character

func _ready() -> void:
	if _background_panel == null: return
	_connect_signals()

func register_owner_character(character: Character):
	owner_character = character
	owner_character.on_character_performed_move.connect(_reset_selection_feedback)

#region Signals

func _connect_signals() -> void:
	InputManager.on_move_canceled.connect(_reset_selection_feedback)
	BattleStageManager.on_hand_combination_phase_started.connect(_on_hand_combination_phase_started)
	BattleStageManager.on_moves_solving_phase_started.connect(_on_moves_solving_phase_started)
	BattleStageManager.on_player_won_wave.connect(_on_player_won_wave)

func _on_hand_combination_phase_started() -> void:
	if owner_character is EnemyCharacter: return
	if not is_forced_disable and not _current_move == null and _current_move.owner_character.hand.current_final_hand.available_suits.has(_current_move.suit):
		disabled = false

func _on_moves_solving_phase_started() -> void:
	if owner_character is EnemyCharacter: return
	disabled = true

func _on_player_won_wave() -> void:
	if owner_character is EnemyCharacter: return
	disabled = true
	is_forced_disable = false

func _on_mouse_entered() -> void:
	if BattleStageManager.is_targeting_phase(): return
	CharactersManager.hide_slots()
	if not owner_character == null: 
		owner_character.show_targets(_id)
		if owner_character is EnemyCharacter and not _current_move == null:
			var allowed_targets = _current_move.get_allowed_targets()
			for n in allowed_targets[owner_character.get_current_target()]:
				n.ui.show_efficiency_preview(_current_move, owner_character)

func _on_mouse_exited() -> void:
	if BattleStageManager.is_targeting_phase(): return
	if owner_character is EnemyCharacter:
		for n in CharactersManager.characters:
			n.ui.hide_efficiency_preview()
	CharactersManager.hide_slots()
	if BattleStageManager.is_moves_solving_phase():
		var character = CharactersManager.selected_character
		if character.hand.current_final_hand == null: return
		character.show_targets(character.hand.current_final_hand.chosen_suit)

func _on_move_button_down() -> void:
	if owner_character is EnemyCharacter: return
	if BattleStageManager.is_targeting_phase():
		for n in CharactersManager.player_characters:
			n.stop_target_choice(false)
	CharactersManager.set_selected_character(owner_character, true)
	owner_character.select_suit(_id)
	for n in CharactersManager.player_characters:
		for preview in n.hand.ui.moves_ui.moves_buttons:
			preview.set_selected(false)


#endregion


#region Main

func update_move_description(move: Move, is_color_required := false) -> void:
	_current_move = move
	if not _hover_move_texture_rect == null : _hover_move_texture_rect.texture = move.texture
	_move_texture_rect.texture = move.texture
	_current_color = move.color
	if is_color_required: $BorderPanel.get("theme_override_styles/panel").border_color = move.color
	_current_name = move.formatted_name
	_name_label.text = _current_name
	_current_description = move.formatted_description
	_description_label.text = move.replace_keys(_current_description)
	_multiplier_label.text = " - " + tr("POWER")  + ": " + str(move.move_power_multiplier)
	_suit_texture_rect.texture = _suits_array[move.suit]

func update_move_stats(move : Move, power: int, suit_amount: int) -> void:
	if move == null: return
	_move_texture_rect.texture = move.texture
	var hit_amount = move.get_hit_amount()
	_power_label.text = str(power) if hit_amount <= 1 else str(hit_amount) + " x " + str(power)
	if power == 0:
		_power_label.text = ""
	if owner_character is EnemyCharacter or owner_character.hand.current_final_hand.available_suits.has(move.suit):
		_description_label.text = move.get_description(_current_description, suit_amount, power)
	else:
		_description_label.text = move.replace_keys(_current_description)

func set_selected(is_selected := true) -> void:
	_background_panel.get("theme_override_styles/panel").bg_color = _current_color if is_selected else Color(0,0,0, 0.85)

func _reset_selection_feedback(character: Character = owner_character) -> void:
	if character is PlayerCharacter:
		set_selected(false)

#endregion

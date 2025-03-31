extends Node

class_name InGameUiManager

@export var _poker_hands_reminder_panel: Control

@export var _loss_control: Control
@export var _victory_control: Control

@export var _sort_values_button: Button
@export var _sort_suits_button: Button
@export var _skip_button: Button

@onready var _turn_label = $TurnLabel

func _ready() -> void:
	_connect_signals()

func _connect_signals() -> void:
	BattleStageManager.on_hands_drawn.connect(_enable_skip_button)
	BattleStageManager.on_player_won_wave.connect(_disable_skip_button)
	BattleStageManager.on_new_turn.connect(_update_turn_count)
	BattleStageManager.on_new_turn.connect(_enable_skip_button)
	BattleStageManager.on_player_lost.connect(_show_loss_control)
	BattleStageManager.on_player_won_level.connect(_show_victory_control)
	InputManager.on_move_canceled.connect(_on_move_canceled)
	BattleStageManager.on_targeting_phase_started.connect(_disable_skip_button)
	CharactersManager.on_characters_manager_initialized.connect(_on_characters_manager_initialized)

func _on_characters_manager_initialized() -> void:
	for n in CharactersManager.player_characters:
		n.hand.cards_holder.on_sort_custom.connect(_on_sort_custom)

func _show_loss_control() -> void:
	_loss_control.show()

func _show_victory_control() -> void:
	_victory_control.show()

func _update_turn_count() -> void:
	_turn_label.text = "Wave " + str(BattleStageManager.current_wave_index + 1) + " - Turn " + str(BattleStageManager.turn_count + 1)

func _enable_skip_button() -> void:
	_skip_button.disabled = false

func _disable_skip_button() -> void:
	_skip_button.disabled = true

func _on_move_canceled() -> void:
	_skip_button.disabled = false

func _on_sort_by_values_button_down() -> void:
	if BattleStageManager.current_battle_state == BattleStageManager.BattleState.DRAWING_PHASE: return
	InputHandler.on_action_sort_values_pressed.emit()
	_sort_suits_button.button_pressed = false

func _on_sort_by_suits_button_down() -> void:
	if BattleStageManager.current_battle_state == BattleStageManager.BattleState.DRAWING_PHASE: return
	InputHandler.on_action_sort_suits_pressed.emit()
	_sort_values_button.button_pressed = false

func _on_sort_custom() -> void:
	_sort_values_button.button_pressed = false
	_sort_suits_button.button_pressed = false

func _on_poker_hands_reminder_button_button_down() -> void:
	_poker_hands_reminder_panel.show()

func on_close_poker_hands_reminder_button_down() -> void:
	_poker_hands_reminder_panel.hide()

func _on_settings_button_button_down() -> void:
	SettingsManager.show_settings()

func _return_to_main_menu() -> void:
	InputManager.current_dragged_card = null
	ResourcesManager.call_deferred("recover_cards")
	CharactersManager.reset_characters_manager()
	BattleStageManager.reset_battle_stage_manager()
	SceneManager.go_to_main_menu()

func _on_main_menu_button_pressed() -> void:
	SettingsManager.is_settings_visible = true

func _on_main_menu_confirmation_closed() -> void:
	SettingsManager.is_settings_visible = false

func _on_skip_button_pressed() -> void:
	if not BattleStageManager.is_player_turn: return
	_disable_skip_button()
	BattleStageManager.skip_turn()

extends Button

class_name RewardCharacterButton

signal on_character_button_dropped(char: PlayerCharacter)

@export var _position_id: int
@export var _displacement_lerp_speed:= 5.0

var current_character : PlayerCharacter

var _current_character_resource : PlayerCharacterResource
var _current_reel: RewardReel

var _destination : Vector2
var _base_position: Vector2

var _is_dragged: bool

#region Godot API

func _ready() -> void:
	_connect_signals()

func _process(delta: float) -> void:
	if not BattleStageManager.current_battle_state == BattleStageManager.BattleState.REWARD_PHASE: return
	if _is_dragged:
		_destination = get_viewport().get_mouse_position() - (size/2)
	else:
		if _destination == Vector2.ZERO: 
			_set_base_position()
	_move(delta)

#endregion

#region Signals

func connect_rewards_signals(manager: RewardsManager):
	manager.on_reward_assigned.connect(_on_reward_assigned)
	manager.on_upgrades_chosen.connect(_on_rewards_chosen)

func _connect_signals() -> void:
	BattleStageManager.on_player_won_wave.connect(_on_player_won_wave)

func _on_player_won_wave() -> void:
	current_character = CharactersManager.get_player_character_with_position_id(_position_id)
	if current_character == null:
		hide()
		return
	else: show()
	_current_character_resource = current_character.character_resource
	icon = _current_character_resource.character_portrait_texture
	if CharactersManager.selected_character == current_character:
		grab_focus()

func _on_reward_assigned(character: PlayerCharacter, reel: RewardReel) -> void:
	if not character == current_character: 
		if _current_reel == reel:
			_destination = _base_position
		return
	_current_reel = reel
	_destination = reel.character_selection_position.global_position

func _on_rewards_chosen() -> void:
	_set_base_position()

func _on_button_down() -> void:
	CharactersManager.set_selected_character(current_character)
	_is_dragged = true

func _on_button_up() -> void:
	_is_dragged = false
	_set_base_position()
	on_character_button_dropped.emit(current_character)


#endregion

#region Main

func _move(delta: float) -> void:
	global_position = global_position.lerp(_destination, delta * _displacement_lerp_speed)

func _set_base_position() -> void:
	_base_position = get_parent().global_position + (get_parent().size/2)
	_destination = _base_position

#endregion

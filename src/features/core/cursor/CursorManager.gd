extends Node

const _SELECT_CURSOR_TEXTURE = preload("res://content/2d/textures/cursors/hand_small_point_n.svg")
const _CURSOR_ABILITY_TEXTURE = preload("res://content/2d/textures/cursors/hand_small_open.svg")
const _CURSOR_MOVE_TEXTURE = preload("res://content/2d/textures/cursors/target_round_b.svg")
const _CURSOR_HELP_TEXTURE = preload("res://content/2d/textures/cursors/mark_question.svg")
const _CURSOR_HELP_CLICK_TEXTURE = preload("res://content/2d/textures/cursors/mark_question_pointer_b.svg")


func _ready() -> void:
	_set_custom_cursors()
	_connect_signals()


func _set_custom_cursors() -> void:
	Input.set_custom_mouse_cursor(_SELECT_CURSOR_TEXTURE, Input.CURSOR_POINTING_HAND, Vector2(16,0))
	Input.set_custom_mouse_cursor(_CURSOR_ABILITY_TEXTURE, Input.CURSOR_DRAG, Vector2(16,16))
	Input.set_custom_mouse_cursor(_CURSOR_MOVE_TEXTURE, Input.CURSOR_CROSS, Vector2(16,16))
	Input.set_custom_mouse_cursor(_CURSOR_HELP_TEXTURE, Input.CURSOR_HELP, Vector2(16,16))
	Input.set_custom_mouse_cursor(_CURSOR_HELP_CLICK_TEXTURE, Input.CURSOR_VSIZE, Vector2(8,0))


func _connect_signals() -> void:
	BattleStageManager.on_targeting_phase_started.connect(_on_targeting_phase_started)
	BattleStageManager.on_targeting_phase_stopped.connect(_on_targeting_phase_stopped)

func _on_targeting_phase_started() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_CROSS)

func _on_targeting_phase_stopped() -> void:
	Input.set_default_cursor_shape()

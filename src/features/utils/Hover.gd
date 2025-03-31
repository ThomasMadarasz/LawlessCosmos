extends Control

class_name Hover

enum Positions {UP, BOTTOM, LEFT, RIGHT}

@export var _is_enabled := true
@export var _main_control: Control
@export var _panel: PanelContainer
@export var _hover_time: float = 1.0
@export var _position_from_control : Positions

var _hover_timer : Timer

const _SCREEN_SIZE = Vector2(1920, 1080)
const _OFFSET_FROM_SCREEN_BORDER = Vector2(4,2)

var _panel_parent: Node

func _initialize_timer() -> void:
	_hover_timer = Timer.new()
	add_child(_hover_timer)
	_hover_timer.wait_time = _hover_time
	_hover_timer.one_shot = true
	_hover_timer.autostart = false
	_hover_timer.timeout.connect(_show_panel)

func _ready() -> void:
	if not _is_enabled: return
	_connect_signals()
	_initialize_timer()

func _physics_process(_delta) -> void:
	if not _is_enabled: return
	if _panel.visible:
		if not is_mouse_inside_control(_panel) and not is_mouse_inside_control(_main_control):
			_hide_panel()
			_hover_timer.stop()

#region Signals

func _connect_signals() -> void:
	_main_control.mouse_entered.connect(_on_mouse_entered)
	_main_control.mouse_exited.connect(_on_mouse_exited)
	_panel.mouse_exited.connect(_on_mouse_exited_panel)

func _on_mouse_entered() -> void:
	if get_tree().paused: return
	_hover_timer.start()

func _on_mouse_exited() -> void:
	if get_tree().paused: return
	if is_mouse_inside_control(_panel): return
	_hide_panel()
	_hover_timer.stop()

func _on_mouse_exited_panel() -> void:
	if get_tree().paused: return
	if is_mouse_inside_control(_main_control): return
	_hide_panel()
	_hover_timer.stop()

func _show_panel() -> void:
	_panel_parent = _panel.get_parent()
	_panel_parent.remove_child(_panel)
	CharactersManager.get_tree().get_root().add_child(_panel)
	_panel.show()
	_panel.global_position = _calculate_position()

#endregion

func _hide_panel() -> void:
	if not _panel.visible: return
	_panel.hide()
	get_tree().get_root().remove_child.call_deferred(_panel)
	_panel_parent.add_child.call_deferred(_panel)

#region Utils

func _calculate_position() -> Vector2:
	var targeted_position = Vector2(0,0)
	
	var panel_size = Vector2(_panel.size.x, _panel.size.y)
	
	match _position_from_control:
		Positions.UP:
			targeted_position = _main_control.global_position + Vector2(_main_control.size.x / 2 - _panel.size.x / 2,  - _panel.size.y)
		Positions.BOTTOM:
			targeted_position = _main_control.global_position + Vector2(_main_control.size.x / 2 - _panel.size.x / 2, _main_control.size.y) 
		Positions.LEFT:
			targeted_position = _main_control.global_position + Vector2( - _panel.size.x, _main_control.size.y / 2 - _panel.size.y / 2) 
		Positions.RIGHT:
			targeted_position = _main_control.global_position + Vector2(_main_control.size.x, _main_control.size.y / 2 - _panel.size.y / 2)
	
	var left_border_x = targeted_position.x
	if left_border_x < 0 + _OFFSET_FROM_SCREEN_BORDER.x:
		targeted_position.x -= left_border_x - _OFFSET_FROM_SCREEN_BORDER.x
		
	var right_border_x = targeted_position.x + panel_size.x
	if right_border_x > _SCREEN_SIZE.x - _OFFSET_FROM_SCREEN_BORDER.x :
		targeted_position.x -= right_border_x - _SCREEN_SIZE.x + _OFFSET_FROM_SCREEN_BORDER.x
		
	var up_border_y = targeted_position.y
	if up_border_y < 0 + _OFFSET_FROM_SCREEN_BORDER.y:
		targeted_position.y -= up_border_y - _OFFSET_FROM_SCREEN_BORDER.y
		
	var down_border_y = targeted_position.y + panel_size.y
	if down_border_y > _SCREEN_SIZE.y - _OFFSET_FROM_SCREEN_BORDER.y:
		targeted_position.y -= down_border_y - _SCREEN_SIZE.y + _OFFSET_FROM_SCREEN_BORDER.y
	
	return targeted_position

func is_mouse_inside_control(control: Control) -> bool:
	var mouse_pos = get_viewport().get_mouse_position()
	var control_pos = control.global_position
	var control_size = control.size 
	return mouse_pos.x >= control_pos.x and mouse_pos.x <= control_pos.x + control_size.x and mouse_pos.y >= control_pos.y and mouse_pos.y <= control_pos.y + control_size.y

#endregion

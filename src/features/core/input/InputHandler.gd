extends Node

signal on_action_select_pressed
signal on_action_select_released

signal on_action_cancel_pressed
signal on_action_escape_pressed

signal on_action_sort_pressed
signal on_action_sort_values_pressed
signal on_action_sort_suits_pressed

signal on_action_debug_pause_pressed

func _input(event) -> void:
	if event.is_action_pressed("select"): on_action_select_pressed.emit()
	elif event.is_action_released("select"): on_action_select_released.emit()
	elif event.is_action_pressed("cancel"): on_action_cancel_pressed.emit()
	elif event.is_action_pressed("escape"): on_action_escape_pressed.emit()
	elif event.is_action_pressed("sort"): on_action_sort_pressed.emit()
	elif event.is_action_pressed("sort_values"): on_action_sort_values_pressed.emit()
	elif event.is_action_pressed("sort_suits"): on_action_sort_suits_pressed.emit()
	elif event.is_action_pressed("debug_pause"): on_action_debug_pause_pressed.emit()

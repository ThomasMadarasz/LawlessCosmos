extends Node

class_name Slot

@export var _slot_texture_rect : TextureRect
@export var _targeted_slot_texture_rect : TextureRect

var _is_currently_targeted: bool

const _FLICKERING_SPEED = 0.005


func _process(_delta: float) -> void:
	if _is_currently_targeted:
		self.modulate.a = (sin(Time.get_ticks_msec() * _FLICKERING_SPEED) + 1)/2.0

func set_targetable(color: Color = Color.WHITE, is_targetable : bool = true) -> void:
	_slot_texture_rect.visible = is_targetable
	_slot_texture_rect.self_modulate = color

func set_targeted(is_targeted: bool = true) -> void:
	if _is_currently_targeted == is_targeted: return
	_is_currently_targeted = is_targeted
	if not is_targeted:
		self.modulate.a = 1
	_targeted_slot_texture_rect.visible = is_targeted

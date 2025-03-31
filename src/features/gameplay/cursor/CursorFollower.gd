extends Node2D

func _physics_process(_delta) -> void:
	self.global_position = get_viewport().get_mouse_position()

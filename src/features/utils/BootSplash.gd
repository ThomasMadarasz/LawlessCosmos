extends Control

class_name BootSplash

@export var _logo_texture : TextureRect
@export var _enable_boot_splash_in_debug: bool = false

func _ready() -> void:
	if not OS.has_feature("debug") or _enable_boot_splash_in_debug: 
		var tween = get_tree().create_tween().set_ease(Tween.EASE_IN)
		tween.tween_interval(1)
		tween.tween_property(_logo_texture, "modulate:a", 1, 1.5)
		tween.tween_interval(1)
		tween.tween_property(_logo_texture, "modulate:a", 0, 1.5)
		tween.tween_interval(0.1)
		tween.tween_property(self, "modulate:a", 0, 1)
		tween.tween_callback(queue_free)
	else:
		queue_free()

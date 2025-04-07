extends TextureRect

class_name StatusUI

@export var name_label: Label
@export var description_label: RichTextLabel

var is_free : bool = true

func set_data(status_data : StatusData) -> void:
	texture = status_data.texture
	name_label.text = status_data.display_name
	description_label.text = status_data.description
	is_free = false

func reset() -> void:
	hide()
	is_free = true
	get_parent().move_child(self, get_parent().get_child_count() - 1)

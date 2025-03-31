extends TextureRect

class_name StatusUI

@export var _texture_2d: Texture2D
@export var _display_name: String
@export_multiline var _description: String

@export var name_label: Label
@export var description_label: RichTextLabel

func _ready() -> void:
	texture = _texture_2d
	name_label.text = _display_name
	description_label.text = _description

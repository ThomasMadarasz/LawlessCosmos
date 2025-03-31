extends Node

class_name CharacterProfile

@export var _texture_rect : TextureRect

var owner_character : Character

func initialize(character : Character) -> void:
	owner_character = character
	_texture_rect.texture = owner_character.character_resource.character_portrait_texture

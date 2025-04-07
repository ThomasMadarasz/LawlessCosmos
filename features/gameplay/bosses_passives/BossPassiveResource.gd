extends Resource

class_name BossPassiveResource

@export var name: String
@export var texture: Texture
@export_multiline var description: String

var owner_character: Character

func enable() -> void:
	pass

func disable() -> void:
	pass

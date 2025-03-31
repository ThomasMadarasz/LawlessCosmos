extends Node

class_name ArtifactsUi

var _artifacts = {} #ArtifactUI : ArtifactResource

var owner_character : PlayerCharacter

func _ready() -> void:
	for n in get_children():
		_artifacts[n] = null

func add_artifact(resource : ArtifactResource) -> void:
	for n in _artifacts.keys():
		if _artifacts[n] == null or _artifacts[n] == resource:
			_artifacts[n] = resource
			n.set_artifact(resource)
			var label = n.get_node("Label")
			label.text = str(owner_character.artifacts[resource])
			label.self_modulate = Color.RED if owner_character.artifacts[resource] == resource.max_stack else Color.WHITE
			n.show()
			return
	print("No more space for artifacts")

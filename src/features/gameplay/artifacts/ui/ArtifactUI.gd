extends TextureRect

class_name ArtifactUi

@export var _name_label: Label
@export var _description_label: RichTextLabel

var _current_artifact_resource: ArtifactResource

func set_artifact(resource: ArtifactResource) -> void:
	_current_artifact_resource = resource
	_name_label.text = _current_artifact_resource.formatted_name
	_description_label.text = _current_artifact_resource.formatted_description
	texture = resource.texture

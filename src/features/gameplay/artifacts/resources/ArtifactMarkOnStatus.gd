extends ArtifactResource

class_name ArtifactMarkOnStatus

func enable(character : PlayerCharacter = null) -> void:
	super.enable(character)
	owner_character.on_status_added.connect(_on_status_added)

func _on_status_added(status_id, caster: Character) -> void:
	if owner_character.status.POSITIVE_STATUS.has(status_id):
		return
	caster.status.add_status(CharacterStatus.Status.MARK, 1, owner_character)

#If more than 1 of this item, we can have an infinite loop

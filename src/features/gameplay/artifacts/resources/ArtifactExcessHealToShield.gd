extends ArtifactResource

class_name ArtifactExcessHealToShield

func enable(character : PlayerCharacter = null) -> void:
	super.enable(character)
	owner_character.on_excess_heal.connect(_on_excess_heal)

func _on_excess_heal(amount: int) -> void:
	owner_character.add_shield(amount)

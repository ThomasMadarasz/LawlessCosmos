extends ArtifactResource

class_name ArtifactStartFullHealth

func enable(character : PlayerCharacter = null) -> void:
	super.enable(character)
	BattleStageManager.on_new_wave_started.connect(_on_new_wave_started)

func _on_new_wave_started() -> void:
	var amount = owner_character.character_resource.max_health - owner_character.character_resource.current_health
	if amount <= 0: return
	owner_character.heal(amount)

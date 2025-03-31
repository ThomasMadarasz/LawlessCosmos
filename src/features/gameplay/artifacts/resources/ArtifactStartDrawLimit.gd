extends ArtifactResource

class_name ArtifactStartDrawLimit

func enable(character : PlayerCharacter = null) -> void:
	super.enable(character)
	owner_character.character_resource.hand_data.initial_draw_amount = owner_character.character_resource.hand_data.draw_limit
	BattleStageManager.level_manager.rewards_manager.on_upgrades_chosen.connect(_on_upgrades_chosen)

func _on_upgrades_chosen() -> void:
	owner_character.character_resource.hand_data.initial_draw_amount = owner_character.character_resource.hand_data.draw_limit

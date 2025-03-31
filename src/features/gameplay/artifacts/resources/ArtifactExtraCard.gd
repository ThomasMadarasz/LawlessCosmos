extends ArtifactResource

class_name ArtifactExtraCard

func enable(character : PlayerCharacter = null) -> void:
	super.enable(character)
	BattleStageManager.on_new_turn.connect(_on_new_turn)

func _on_new_turn() -> void:
	if owner_character.hand.current_cards.size() < owner_character.character_resource.hand_data.max_hand_size:
		owner_character.hand.draw_cards(1)

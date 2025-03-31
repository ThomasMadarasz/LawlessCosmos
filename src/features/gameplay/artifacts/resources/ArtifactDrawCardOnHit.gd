extends ArtifactResource

class_name ArtifactDrawCardOnHit

func enable(character : PlayerCharacter = null) -> void:
	super.enable(character)
	owner_character.on_got_attacked.connect(_on_got_attacked)

func _on_got_attacked(_attacker: Character, _health_lost_amount: int) -> void:
	if owner_character.hand.current_cards.size() < owner_character.character_resource.hand_data.max_hand_size:
		owner_character.hand.draw_cards(1)

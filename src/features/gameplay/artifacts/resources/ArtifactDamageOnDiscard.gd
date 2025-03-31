extends ArtifactResource

class_name ArtifactDamageOnDiscard

func enable(character : PlayerCharacter = null) -> void:
	super.enable(character)
	owner_character.hand.on_card_discarded.connect(_on_card_discarded)

func _on_card_discarded(card: Card, _hand: Hand, _is_played : bool) -> void:
	var damage_amount = card.card_resource.value
	var potential_targets = CharactersManager.enemy_characters if owner_character is PlayerCharacter else CharactersManager.player_characters
	potential_targets.pick_random().take_damage(damage_amount, owner_character)

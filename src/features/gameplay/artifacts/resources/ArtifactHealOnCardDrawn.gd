extends ArtifactResource

class_name ArtifactHealOnCardDrawn

func enable(character : PlayerCharacter = null) -> void:
	super.enable(character)
	owner_character.hand.on_card_drawn.connect(_on_card_drawn)

func _on_card_drawn(card: Card) -> void:
	var amount = card.card_resource.value
	if amount <= 0: return
	owner_character.heal(amount)

extends ArtifactResource

class_name ArtifactPoisonHit

func enable(character: PlayerCharacter = null) -> void:
	super.enable(character)
	owner_character.on_attack.connect(_on_attack)

func _on_attack(target: Character, _health_lost_amount : int) -> void:
	if target is EnemyCharacter:
		target.status.add_status(CharacterStatus.Status.POISON, 1, owner_character)

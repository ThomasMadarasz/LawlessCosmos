extends ArtifactResource

class_name ArtifactStartAddShield

@export var _shield_value: int = 1

func enable(character : PlayerCharacter = null) -> void:
	super.enable(character)
	BattleStageManager.on_new_wave_started.connect(_on_new_wave_started)

func _on_new_wave_started() -> void:
	owner_character.add_shield(_shield_value)

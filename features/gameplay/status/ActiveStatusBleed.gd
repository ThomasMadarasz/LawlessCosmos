extends ActiveStatus

class_name ActiveStatusBleed

func enable() -> void:
	_owner_character.on_bleed_tick_phase.connect(_on_bleed_tick_phase)

func _on_bleed_tick_phase() -> void:
	_owner_character.take_damage(count, _owner_character, true)

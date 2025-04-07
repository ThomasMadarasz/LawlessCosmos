extends ActiveStatus

class_name ActiveStatusHealPack

const _HEAL_PERCENTAGE : float = 0.1

func enable() -> void:
	_owner_character.on_heal_pack_tick_phase.connect(_on_heal_pack_tick_phase)

func _on_heal_pack_tick_phase(is_healing_once: bool) -> void:
	var heal_amount: int = 1 if is_healing_once else count
	for _i: int in heal_amount:
		if _owner_character.character_resource.current_health == _owner_character.max_health: return
		_owner_character.heal(roundi(_HEAL_PERCENTAGE * _owner_character.character_resource.max_health))
		remove(1)

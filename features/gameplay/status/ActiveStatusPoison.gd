extends ActiveStatus

class_name ActiveStatusPoison

const _POISON_PERCENTAGE : float = 0.1

func enable() -> void:
	_owner_character.on_poison_tick_phase.connect(_on_poison_tick_phase)

func _on_poison_tick_phase() -> void:
	_owner_character.take_damage(roundi(_owner_character.max_health * _POISON_PERCENTAGE), _owner_character, true)
	remove(1)

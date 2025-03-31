extends DamageMultiplierEvaluator

class_name MultiplierTurnSpendWithoutPlay

var _current_multiplier_value := 1.0

func _init() -> void:
	BattleStageManager.on_new_turn.connect(_on_new_turn)
	BattleStageManager.on_new_wave_started.connect(_on_new_wave_started)

func _on_new_turn() -> void:
	_current_multiplier_value += _multiplier_value

func _on_new_wave_started() -> void:
	_current_multiplier_value = 1.0

func get_damage_multiplier(_character: Character = null, _target : Character = null) -> float:
	var returned_value = _current_multiplier_value
	_current_multiplier_value = 1.0 - _multiplier_value
	return returned_value

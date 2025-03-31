extends Label

class_name RankingValueLabel

@export var id: int

var base_value : int

func _ready() -> void:
	base_value = FinalHandCalculator._FINAL_HAND_CALCULATOR_DATA.hand_rankings_values[id]
	_update_value_label()

func _update_value_label() -> void:
	var value = FinalHandCalculator._FINAL_HAND_CALCULATOR_DATA.hand_rankings_values[id]
	self.text = str(value)
	var label_color = Color.WHITE
	if value > base_value:
		label_color = Color.GREEN
	elif value < base_value:
		label_color = Color.RED
	self.self_modulate = label_color

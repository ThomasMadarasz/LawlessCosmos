extends BaseResource

class_name CardResource

@export var base_value_id: int
@export var base_suit: Enums.Suits

var name: String
var value_id: int

var value: int:
	get:
		value = 10 if value_id + 1 > 10 and value_id + 1 < 14 else value_id + 1
		if value_id == 0:
			value = 11
		return value

var suit: Enums.Suits

func refresh_values() -> void:
	value_id = base_value_id
	suit = base_suit
	generate_name()

func generate_name() -> void:
	name = "{value_id}_{suit}".format({"value_id": value_id, "suit": suit})

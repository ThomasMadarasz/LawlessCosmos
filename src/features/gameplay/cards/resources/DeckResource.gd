extends Resource

class_name DeckResource

@export var _is_a_classic_52_cards_deck: bool = true
@export var _base_cards_resources: Array[CardResource]

var cards_resources: Array[CardResource]
var discarded_cards_resources: Array[CardResource]

func initialize() -> void:
	reset()
	if _is_a_classic_52_cards_deck:
		_base_cards_resources.clear()
		_base_cards_resources = _generate_cards_resources()
	_set_base_cards_resources_as_cards_resources()

func reset() -> void:
	discarded_cards_resources.clear()
	cards_resources.clear()
	_set_base_cards_resources_as_cards_resources()

func _set_base_cards_resources_as_cards_resources() -> void:
	for n in _base_cards_resources:
		var resource_to_push = n._duplicate(false)
		resource_to_push.refresh_values()
		cards_resources.push_back(resource_to_push)


func _generate_cards_resources() -> Array[CardResource]:
	var resources: Array[CardResource] = []
	resources.resize(52)
	for i in 4:
		for j in 13:
			var n = j
			var card_index = (i * 13) + (j + 1) - 1
			resources[card_index] = CardResource.new()
			resources[card_index].base_value_id = n
			match i:
				0: resources[card_index].base_suit = Enums.Suits.SPADE
				1: resources[card_index].base_suit = Enums.Suits.HEART
				2: resources[card_index].base_suit = Enums.Suits.DIAMOND
				3: resources[card_index].base_suit = Enums.Suits.CLUB
			resources[card_index].refresh_values()
	return resources

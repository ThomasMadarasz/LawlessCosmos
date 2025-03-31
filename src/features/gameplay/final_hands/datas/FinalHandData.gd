extends BaseResource

class_name FinalHandData

var cards_resources: Array[CardResource]
var cards = {}
var counting_cards = {} #card_resource:bool
var hand_ranking: Enums.HandRankings
var power: float
var available_suits: Array[Enums.Suits]
var chosen_suit: Enums.Suits
var suits_amount = {}
var owner_character : Character

func _init(character: Character) -> void:
	owner_character = character
	resource_local_to_scene = true

func get_suit_amount(suit: Enums.Suits) -> int:
	return suits_amount[suit] + owner_character.suit_amount_bonus[suit]

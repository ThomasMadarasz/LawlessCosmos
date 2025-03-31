extends Resource

class_name RewardResourceList

@export var _rewards_tier_1 : Array[RewardResource]
@export var _rewards_tier_2 : Array[RewardResource]
@export var _rewards_tier_3 : Array[RewardResource]
@export var _rewards_tier_4 : Array[RewardResource]

var rewards_array:
	get: return _rewards_tier_1 + _rewards_tier_2 + _rewards_tier_3 + _rewards_tier_4

func initialize() -> void:
	for n in _rewards_tier_1:
		n.rarity = Enums.Tiers.TIER_1
	for n in _rewards_tier_2:
		n.rarity = Enums.Tiers.TIER_2
	for n in _rewards_tier_3:
		n.rarity = Enums.Tiers.TIER_3
	for n in _rewards_tier_4:
		n.rarity = Enums.Tiers.TIER_4
	

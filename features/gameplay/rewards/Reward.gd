extends RefCounted

class_name Reward

var type: Enums.RewardsTypes
var rarity: Enums.Tiers

func _init( reward_type: Enums.RewardsTypes, tier_rarity: Enums.Tiers) -> void:
	type = reward_type
	rarity = tier_rarity

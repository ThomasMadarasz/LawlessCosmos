@tool
extends BaseResource

class_name RewardProbabilitiesData

@export var reward_probabilities: Dictionary:
	set(dic):
		if dic is Dictionary:
			reward_probabilities = dic.duplicate(true)

@export var tier_probabilities: Dictionary:
	set(dic):
		if dic is Dictionary:
			tier_probabilities = dic.duplicate(true)

func _init() -> void:
	reward_probabilities = {}
	tier_probabilities = {}

func initialize_probabilities() -> void:
	if reward_probabilities.size() < Enums.RewardsTypes.keys().size():
		for n in Enums.RewardsTypes.keys():
			if not reward_probabilities.has(n):
				reward_probabilities[n] = 0
	if tier_probabilities.size() < Enums.Tiers.keys().size():
		for n in Enums.Tiers.keys():
			if not tier_probabilities.has(n):
				tier_probabilities[n] = 0

func check_probabilities_values() -> bool:
	var are_values_ok = true
	var reward_value = 0
	for n in reward_probabilities.values():
		reward_value += n
	var tier_value = 0
	for n in tier_probabilities.values():
		tier_value += n
	if not reward_value == 100 or not tier_value == 100: are_values_ok = false
	if not are_values_ok:
		printerr("Probability values do not add up to 100 in one or several of those dictionaries : \n", reward_probabilities, "\n", tier_probabilities)
	return are_values_ok

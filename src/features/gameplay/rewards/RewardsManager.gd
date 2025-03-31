extends Control

class_name RewardsManager

signal on_upgrades_chosen()
signal on_reward_assigned(char: PlayerCharacter, reel: RewardReel)
signal on_rewards_drafted()

@export var characters_buttons : Array[RewardCharacterButton]

@export var _upgrades_panel : Control
@export var _reward_reels : Array[RewardReel]
@export var _choose_reward_label: Label

@export var _hand_manipulations_manager : HandManipulationsManager

@export var _hand_manipulations_array : RewardResourceList
@export var _artifacts_array : RewardResourceList
@export var _heals_array : RewardResourceList

@export var _specific_rewards_control: Control
@export var _specific_rewards_label: Label

var _rewards_types_and_rarities : Array[Reward] = []

var available_rewards = {} #Reward : Array[RewardResource]

func _ready() -> void:
	_connect_signals()
	for i in _reward_reels.size():
		_reward_reels[i].register_rewards_manager(self)
	for n in characters_buttons:
		n.connect_rewards_signals(self)
	_hand_manipulations_array.initialize()
	_artifacts_array.initialize()
	_heals_array.initialize()

#region Signals

func _connect_signals() -> void:
	CharactersManager.on_characters_manager_initialized.connect(_on_characters_manager_initialized)
	BattleStageManager.on_player_won_wave.connect(_on_player_won_wave)

func _on_characters_manager_initialized()-> void:
	_set_rewards_types_and_rarities()
	_set_available_rewards()

func _on_player_won_wave()-> void:
	_upgrades_panel.show()
	BattleStageManager.is_upgrading_phase = true
	mouse_filter = Control.MOUSE_FILTER_PASS
	var wave_reward_resource = BattleStageManager.current_level_resource.rewards_array[BattleStageManager.current_wave_index]
	if _check_for_specific_rewards(wave_reward_resource): return
	_specific_rewards_control.hide()
	_choose_reward_label.show()
	on_rewards_drafted.emit()
	for n in _reward_reels:
		n.show()
	var probabilities = _calculate_probabilities(wave_reward_resource)
	_draft(probabilities)

func _on_validate_upgrades_button_pressed()-> void:
	for reel in _reward_reels:
		if not reel.current_character == null and not reel.reward_resource == null:
			if reel.reward_resource is Move:
				_add_move(reel)
			elif reel.reward_resource is ArtifactResource:
				_add_artifact(reel)
			elif reel.reward_resource is HandManipulationResource:
				_add_manipulation(reel)
			elif reel.reward_resource is HealRewardResource:
				_add_heal(reel)
	for reel in _reward_reels: reel.reset_reel()
	_upgrades_panel.hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	BattleStageManager.is_upgrading_phase = false
	on_upgrades_chosen.emit()

#endregion


#region Main

func _set_rewards_types_and_rarities()-> void:
	for type in Enums.RewardsTypes:
		for rarity in Enums.Tiers:
			var reward = Reward.new(type, rarity)
			_rewards_types_and_rarities.push_back(reward)

func _set_available_rewards()-> void:
	for reward in _rewards_types_and_rarities:
		var array_of_type = []
		match Enums.RewardsTypes[reward.type]:
			Enums.RewardsTypes.MOVES:
				for n in CharactersManager.player_characters:
					array_of_type.append_array(n.character_resource.move_rewards as Array[RewardResource])
			Enums.RewardsTypes.ARTIFACTS:
				array_of_type = _artifacts_array.rewards_array
			Enums.RewardsTypes.HAND_MANIPULATIONS:
				array_of_type = _hand_manipulations_array.rewards_array
			Enums.RewardsTypes.HEAL:
				array_of_type = _heals_array.rewards_array
		var array_of_rewards = []
		if array_of_type == null: continue
		for n in array_of_type:
			if n.rarity == Enums.Tiers[reward.rarity]:
				array_of_rewards.push_back(n)
				n.reward = reward
		available_rewards[reward] = array_of_rewards

func _calculate_probabilities(reels_probabilities : WaveRewardResource) -> Array:
	for n in reels_probabilities.reels: n.check_probabilities_values()
	var reels_probabilities_data = []
	for i in reels_probabilities.reels.size():
		reels_probabilities_data.push_back({})
		for reward in _rewards_types_and_rarities:
			var value = reels_probabilities.reels[i].reward_probabilities[reward.type] * (float(reels_probabilities.reels[i].tier_probabilities[reward.rarity])/100.0)
			if value > 0: reels_probabilities_data[i][reward] = value
	return reels_probabilities_data

func _draft(probabilities)-> void:
	for i in probabilities.size():
		_reward_reels[i].draft(probabilities[i])

func _check_for_specific_rewards(wave_reward_resource: WaveRewardResource) -> bool:
	var specific_reward_text = "Received "
	if not wave_reward_resource.character == null:
		for i in BattleStageManager.current_level_resource.player_characters_resources.size():
			if BattleStageManager.current_level_resource.player_characters_resources[i] == null:
				BattleStageManager.current_level_resource.player_characters_resources[i] = wave_reward_resource.character
				CharactersManager.instantiate_player_character(i)
				specific_reward_text += "new character : " + tr(Enums.PlayerCharacters.keys()[wave_reward_resource.character.character_id])
				break
	if not wave_reward_resource.manipulation == null:
		_hand_manipulations_manager.add_manipulation(wave_reward_resource.manipulation)
		specific_reward_text += " and new hand manipulation : " + tr(wave_reward_resource.manipulation.name)
	if wave_reward_resource.skip_reward:
		for n in _reward_reels:
			n.hide()
		_choose_reward_label.hide()
		_specific_rewards_control.show()
		_specific_rewards_label.text = specific_reward_text
		return true
	else: return false

func _add_move(reel : RewardReel) -> void:
	var reward_class = reel.reward_resource.get_script().get_global_name()
	reel.reward_resource.owner_character = reel.current_character
	reel.current_character.character_resource.current_moves[reel.reward_resource.suit] = reel.reward_resource
	for key in available_rewards.keys():
		if key.type == "MOVES":
			for reward_resource in available_rewards[key]:
				if reward_resource.get_script().get_global_name() == reward_class and reward_resource.rarity <= reel.reward_resource.rarity:
					available_rewards[key].erase(reward_resource)

func _add_artifact(reel : RewardReel) -> void:
	reel.current_character.add_artifact(reel.reward_resource)
	reel.current_character.hand.artifacts_ui.add_artifact(reel.reward_resource)

func _add_manipulation(reel : RewardReel) -> void:
	_hand_manipulations_manager.add_manipulation(reel.reward_resource)

func _add_heal(reel : RewardReel) -> void:
	reel.current_character.heal(randi_range(reel.reward_resource.min_heal_value, reel.reward_resource.max_heal_value))


#endregion

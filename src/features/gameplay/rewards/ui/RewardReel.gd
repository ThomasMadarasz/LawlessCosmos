extends Button

class_name RewardReel

@export var _type_label : Label
@export var _reward_texture : TextureRect
@export var _name_label : Label
@export var _description_label : RichTextLabel

@export var character_selection_position: Marker2D

var _rewards_manager : RewardsManager

var current_character: PlayerCharacter
var reward_resource: RewardResource
var current_reward : Reward

func _ready() -> void:
	_connect_signals()

func register_rewards_manager(manager : RewardsManager):
	_rewards_manager = manager
	_rewards_manager.on_reward_assigned.connect(_on_reward_assigned)
	for n in _rewards_manager.characters_buttons:
		n.on_character_button_dropped.connect(_on_character_button_dropped)
	

#region Signals

func _connect_signals() -> void:
	BattleStageManager.on_player_won_wave.connect(_on_player_won_wave)
	SettingsManager.on_localization_changed.connect(_on_localization_changed)

func _on_player_won_wave() -> void:
	current_character = null

func _on_button_down() -> void:
	if reward_resource is Move and not reward_resource.linked_character == CharactersManager.selected_character.character_resource.character_id: 
			print("Character id is not matching the id of the linked character. Expected character : ", Enums.PlayerCharacters.keys()[reward_resource.linked_character])
			return
	if reward_resource is ArtifactResource and CharactersManager.selected_character.artifacts.keys().has(reward_resource) and CharactersManager.selected_character.artifacts[reward_resource] >= reward_resource.max_stack: return
	if current_character == CharactersManager.selected_character:
		current_character = null
	else:
		current_character = CharactersManager.selected_character
		_rewards_manager.on_reward_assigned.emit(current_character, self)

func _on_reward_assigned(character : PlayerCharacter, reel : RewardReel) -> void:
	if character == current_character and not reel == self:
		current_character = null

func _on_character_button_dropped(character: PlayerCharacter) -> void:
	if is_mouse_inside_control(self):
		if reward_resource is Move and not reward_resource.linked_character == CharactersManager.selected_character.character_resource.character_id:
			print("Character id is not matching the id of the linked character. Expected character : ", Enums.PlayerCharacters.keys()[reward_resource.linked_character])
			return
		if reward_resource is ArtifactResource and CharactersManager.selected_character.artifacts.keys().has(reward_resource) and CharactersManager.selected_character.artifacts[reward_resource] >= reward_resource.max_stack: return
		current_character = character
		_rewards_manager.on_reward_assigned.emit(character, self)
	else:
		if character == current_character:
			current_character = null

func _on_localization_changed() -> void:
	if reward_resource == null: return
	_name_label.text = reward_resource.formatted_name
	_reward_texture.texture = reward_resource.texture
	_description_label.text = "[center]%s[/center]" % reward_resource.reward_description

#endregion


#region Main

func draft(probabilities) -> void:
	var random_value = randi() % 100
	var cumulative = 0
	for key in probabilities.keys():
		cumulative += probabilities[key]
		if random_value < cumulative:
			current_reward = key
			break
	print(_rewards_manager.available_rewards[current_reward].size())
	if _rewards_manager.available_rewards.keys().has(current_reward) and _rewards_manager.available_rewards[current_reward].size() > 0:
		reward_resource = _rewards_manager.available_rewards[current_reward].pick_random() as RewardResource
		if reward_resource.is_unique: _rewards_manager.available_rewards[current_reward].erase(reward_resource)
		_name_label.text = reward_resource.formatted_name
		_reward_texture.texture = reward_resource.texture
		_description_label.text = "[center]%s[/center]" % reward_resource.reward_description
		var type_text = ""
		if reward_resource is Move: type_text = "MOVE"
		elif reward_resource is ArtifactResource: type_text = "ARTIFACT"
		elif reward_resource is HandManipulationResource: type_text = "MANIPULATION"
		elif reward_resource is HealRewardResource: type_text = "HEAL_REWARD"
		
		_type_label.text = type_text
	else:
		reward_resource = null
		_name_label.text = "invalid key or empty array"
		_reward_texture.texture = null
		_description_label.text = ""
		_type_label.text = ""

func reset_reel() -> void:
	if not reward_resource == null:
		var is_available = false
		for n in CharactersManager.player_characters:
			if not n.artifacts.keys().has(reward_resource) or n.artifacts[reward_resource] < reward_resource.max_stack:
				print(n.character_resource.display_name, reward_resource.name)
				is_available = true
				break
				
		if current_character == null and reward_resource.is_unique: 
			_rewards_manager.available_rewards[current_reward].push_back(reward_resource)
			print(reward_resource.name + "is unique and hasn't been validated so it is pushed back in the pool")
		if not is_available:
			_rewards_manager.available_rewards[reward_resource.reward].erase(reward_resource)
			print(reward_resource.name + "has been erased")
	reward_resource = null

#endregion


#region Utils

func is_mouse_inside_control(control: Control) -> bool:
	var mouse_pos = get_viewport().get_mouse_position()
	var control_pos = control.global_position
	var control_size = control.size 
	return mouse_pos.x >= control_pos.x and mouse_pos.x <= control_pos.x + control_size.x and mouse_pos.y >= control_pos.y and mouse_pos.y <= control_pos.y + control_size.y

#endregion

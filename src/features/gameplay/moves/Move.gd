extends RewardResource

class_name Move

enum MoveTags { DAMAGE, HEAL, SHIELD, SUPPORT }

enum AllowedTargets { SELF, ANY_OPPONENT, CLOSEST_OPPONENT, FARTHEST_OPPONENT, ALL_OPPONENTS, ANY_ALLY, ALL_ALLIES }

signal on_move_logic_ended(move: Move)

@export_category("Gameplay")
@export var components: Array[MoveComponent]
@export var _allowed_targets: AllowedTargets
@export var move_power_multiplier = 1.0
@export var move_tags: Array[MoveTags]
@export var suit : Enums.Suits

@export_category("Visuals")
@export var anim_name: String = "attacking"
@export var _move_anim_data: MoveAnimData = preload("res://datas/resources/anims/move/ph_move_anim.tres")
@export var color: Color = Color.RED

var owner_character: Character
var ally_characters: Array[Character]
var is_disable_forced : bool

var current_targets_count : int
var current_slot_target

var final_power: int:
	get: return get_final_power()


const PERCENTAGE_DIVIDER = 100.0
const MAX_CARDS_IN_COMBINATION = 5

var _allowed_targets_callables : Dictionary = { 
	AllowedTargets.SELF : get_self_target,
	AllowedTargets.ANY_OPPONENT : get_any_opponent,
	AllowedTargets.CLOSEST_OPPONENT : get_closest_opponent,
	AllowedTargets.FARTHEST_OPPONENT : get_farthest_opponent,
	AllowedTargets.ALL_OPPONENTS : get_all_opponents,
	AllowedTargets.ANY_ALLY : get_any_ally,
	AllowedTargets.ALL_ALLIES : get_all_allies
	}

func init() -> void:
	resource_local_to_scene = true
	for n in components:
		n.set_move(self)

func register_owner_character(character : Character):
	owner_character = character
	ally_characters = CharactersManager.player_characters.duplicate()
	if character is PlayerCharacter: ally_characters.erase(character)



#region Main

func perform(target : Character) -> void:
	await BattleStageManager.get_tree().process_frame # Ensure that on_move_logic_ended isn't called before the await for itself in perform_move in the Characters classes
	if not _move_anim_data == null: owner_character.animation_player.move(_move_anim_data)
	var move_solver = MoveSolver.new(self)
	await move_solver.solve(get_targets_from_target(target))
	on_move_logic_ended.emit(self)


func attack_target(power: float, target : Character, is_group_attack := false) -> Array:
	if not is_group_attack:
		var characters = CharactersManager.players_positions_by_id if target is PlayerCharacter else CharactersManager.enemies_positions_by_id
		for n in characters:
			if n == null: continue
			if n.status.check_for_barricade(target):
				target = n
				break
	else:
		target.status.check_for_barricade(target)
	power = calculate_power_with_damage_multiplier(power, target)
	var health_lost = target.take_damage(roundi(power), owner_character)
	owner_character.on_attack.emit(target, health_lost)
	return [target, health_lost]

#endregion

#region Utils

func get_final_power() -> int:
	if owner_character == null: return 0
	return roundi(owner_character.hand.current_final_hand.power * move_power_multiplier)

func calculate_power_with_damage_multiplier(power: float, target : Character = null) -> int:
	var allowed_targets_dic = get_allowed_targets()
	if not target == null and not allowed_targets_dic.keys().has(target):
		target = null
	for n in owner_character.inflicted_damage_multiplier:
		power *= n.get_damage_multiplier(owner_character, target)
	if not target == null:
		for n in target.received_damage_multiplier:
			power *= n.get_damage_multiplier(target)
	return roundi(power)

func get_hit_amount() -> int:
	return 1

func get_targets_from_target(target: Character) -> Array[Character]:
	var allowed_targets_dic = get_allowed_targets()
	var targets = [] as Array[Character]
	for n in allowed_targets_dic[target]:
		targets.push_back(n)
	current_targets_count = targets.size()
	return targets

#endregion

#region Targeting

func is_target_valid(target: Character) -> bool:
	var allowed_targets = get_allowed_targets()
	if allowed_targets.keys().has(target):
		return true
	else:
		print("Invalid target choice ", self, " on ", owner_character.character_resource.display_name, " with target ", target.character_resource.display_name)
		return false

func get_allowed_targets() -> Dictionary:
	return _allowed_targets_callables[_allowed_targets].call()

func get_self_target() -> Dictionary:
	return {owner_character : [owner_character] as Array[Character]}

func get_any_opponent() -> Dictionary:
	var targets = {}
	for i in range(0,3):
		var character_key = CharactersManager.get_player_character_with_position_id(i) as Character if owner_character is EnemyCharacter else CharactersManager.get_enemy_character_with_position_id(i) as Character
		if not character_key == null: 
			targets[character_key] = [character_key] as Array[Character]
	return targets

func get_closest_opponent() -> Dictionary:
	var targets = {}
	for i in range(0,3):
		var character_key = CharactersManager.get_player_character_with_position_id(i) as Character if owner_character is EnemyCharacter else CharactersManager.get_enemy_character_with_position_id(i) as Character
		if not character_key == null: 
			targets[character_key] = [character_key] as Array[Character]
			break
	return targets

func get_farthest_opponent() -> Dictionary:
	var targets = {}
	for i in range(2, -1, -1):
		var character_key = CharactersManager.get_enemy_character_with_position_id(i) as Character if owner_character is PlayerCharacter else CharactersManager.get_player_character_with_position_id(i) as Character
		if not character_key == null: 
			targets[character_key] = [character_key] as Array[Character]
			break
	return targets

func get_all_opponents() -> Dictionary:
	var targets = {}
	var characters = CharactersManager.enemy_characters if owner_character is PlayerCharacter else CharactersManager.player_characters
	for n in characters:
		targets[n] = characters
	return targets

func get_any_ally() -> Dictionary:
	var targets = {}
	for i in range(0,3):
		var character_key = CharactersManager.get_player_character_with_position_id(i) as Character if owner_character is PlayerCharacter else CharactersManager.get_enemy_character_with_position_id(i) as Character
		if not character_key == null: 
			targets[character_key] = [character_key] as Array[Character]
	return targets

func get_all_allies() -> Dictionary:
	var targets = {}
	var characters = CharactersManager.player_characters if owner_character is PlayerCharacter else CharactersManager.enemy_characters
	for n in characters:
		targets[n] = characters
	return targets

func is_move_targeting_an_opponent() -> bool:
	var value = not (_allowed_targets == AllowedTargets.SELF or _allowed_targets == AllowedTargets.ANY_ALLY or _allowed_targets == AllowedTargets.ALL_ALLIES )
	return value

#endregion

#region Formating

func _get_formatted_description() -> String:
	var new_formated_description = super._get_formatted_description()
	if iteration > 0:
		new_formated_description = new_formated_description.format({"UPGRADE_1" : tr(description + "_1")})
		if iteration > 1:
			new_formated_description = new_formated_description.format({"UPGRADE_2" : tr(description + "_2")})
			if iteration > 2:
				new_formated_description = new_formated_description.format({"UPGRADE_3" : tr(description + "_3")})
			else:  
				new_formated_description = new_formated_description.format({"UPGRADE_3" : ""})
		else : 
			new_formated_description = new_formated_description.format({"UPGRADE_2" : "", "UPGRADE_3" : ""})
	else: 
		new_formated_description = new_formated_description.format({"UPGRADE_1" : "", "UPGRADE_2" : "", "UPGRADE_3" : ""})
	return new_formated_description.format({"TARGET" : tr(AllowedTargets.keys()[_allowed_targets])})

func get_description(current_description, suit_amount, power) -> String:
	var description_to_return = current_description
	description_to_return = description_to_return.format({"SUIT_AMOUNT": suit_amount_value_string % suit_amount})
	description_to_return = description_to_return.format({"EFFICIENCY": efficiency_value_string % [get_character_hand_power(), move_power_multiplier, power]} if owner_character is PlayerCharacter else {"EFFICIENCY": efficiency_enemy_string % power})
	description_to_return = description_to_return.format({"UNUSED_CARDS": unused_cards_value_string % str(get_unused_cards_count())})
	if owner_character is PlayerCharacter:
		description_to_return = description_to_return.format({"DIFFERENT_SUITS_AMOUNT": different_suits_amount_value_string % str(owner_character.hand.current_final_hand.available_suits.size())})
	return description_to_return

func get_character_hand_power() -> int:
	return roundi(owner_character.hand.current_final_hand.power) if owner_character is PlayerCharacter else 0

func get_unused_cards_count()-> int:
	if owner_character == null or not owner_character is PlayerCharacter:
		return 0
	return 5 - owner_character.hand.current_final_hand.counting_cards.values().size()

#endregion

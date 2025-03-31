extends BaseResource

class_name EnemyMoveResource

enum EnemyTargets { SELF, RANDOM_PLAYER, CLOSEST_PLAYER, FARTHEST_PLAYER, ALL_PLAYERS, FARTHEST_ENEMY, LOWEST_PLAYER, LOWEST_HEALTH_ENEMY, BOSS, HIGHEST_PLAYER, MOST_CARDS_PLAYER, FRONT_ROW_ALLY_AT_START, MID_ROW_ALLY_AT_START, BACK_ROW_ALLY_AT_START, MOST_BLEED, ALL_ENEMIES, MOST_POISON, HIGHEST_PLAYER_HEALTH_PERCENTAGE }

var _target_callables : Dictionary = { 
	EnemyTargets.SELF : target_self,
	EnemyTargets.RANDOM_PLAYER : target_random_player_character,
	EnemyTargets.CLOSEST_PLAYER : target_closest_player,
	EnemyTargets.FARTHEST_PLAYER : target_farthest_player,
	EnemyTargets.ALL_PLAYERS : target_all_players,
	EnemyTargets.FARTHEST_ENEMY : target_farthest_enemy,
	EnemyTargets.LOWEST_PLAYER : target_lowest_player,
	EnemyTargets.LOWEST_HEALTH_ENEMY : target_lowest_health_enemy,
	EnemyTargets.BOSS: target_boss,
	EnemyTargets.HIGHEST_PLAYER: target_highest_player,
	EnemyTargets.MOST_CARDS_PLAYER: target_most_cards_player,
	EnemyTargets.FRONT_ROW_ALLY_AT_START: target_front_row_ally_at_start,
	EnemyTargets.MID_ROW_ALLY_AT_START: target_mid_row_ally_at_start,
	EnemyTargets.BACK_ROW_ALLY_AT_START: target_back_row_ally_at_start,
	EnemyTargets.MOST_BLEED: target_most_bleed,
	EnemyTargets.ALL_ENEMIES: target_all_enemies,
	EnemyTargets.MOST_POISON: target_most_poison,
	EnemyTargets.HIGHEST_PLAYER_HEALTH_PERCENTAGE: target_highest_player_health_percentage
	
	}

@export var move : Move
@export var target_key : EnemyTargets
@export var secondary_effect_amount : int
@export var move_points_required : int
@export var _efficiency_range : Vector2

var _current_slot_target

var efficiency: int:
	get:
		if efficiency == 0 and _efficiency_range.x > 0:
			var multiplier = BattleStageManager.difficulty_multiplier if BattleStageManager.current_wave_data.is_boss_wave else BattleStageManager.difficulty_multiplier * BattleStageManager.wave_efficiency_multiplier
			efficiency = randi_range(roundi(_efficiency_range.x * multiplier), roundi(_efficiency_range.y * multiplier))
		return efficiency

var owner_character : EnemyCharacter:
	get:
		if owner_character == null: owner_character = move.owner_character
		return owner_character


#region Enemy Targeting

func get_default_target_slot_for_enemy() -> Array[int]:
	return _target_callables[target_key].call()

func target_self() -> Array[int]:
	return [owner_character.position_id]

func target_random_player_character() -> Array[int]:
	if _current_slot_target == null: _current_slot_target = CharactersManager.get_player_filled_slots().pick_random()
	return [_current_slot_target]

func target_closest_player() -> Array[int]:
	return [CharactersManager.get_player_filled_slots().front()]

func target_farthest_player() -> Array[int]:
	return [CharactersManager.get_player_filled_slots().back()]

func target_all_players() -> Array[int]:
	return CharactersManager.get_player_filled_slots()

func target_farthest_enemy() -> Array[int]:
	return [CharactersManager.get_enemy_filled_slots().back()]

func target_lowest_player() -> Array[int]:
	var lowest_player = null
	for n in CharactersManager.player_characters:
		if n == null: continue
		if lowest_player == null or lowest_player.character_resource.current_health + lowest_player.character_resource.current_shield > n.character_resource.current_health + n.character_resource.current_shield : 
			lowest_player = n
	return [lowest_player.position_id]

func target_highest_player() -> Array[int]:
	if _current_slot_target == null:
		var highest_player = null
		for n in CharactersManager.player_characters:
			if n == null: continue
			if highest_player == null or highest_player.character_resource.current_health + highest_player.character_resource.current_shield < n.character_resource.current_health + n.character_resource.current_shield : 
				highest_player = n
		_current_slot_target = highest_player.position_id
	return [_current_slot_target]

func target_lowest_health_enemy() -> Array[int]:
	var lowest_enemy = null
	for n in CharactersManager.enemy_characters:
		if n == null: continue
		if lowest_enemy == null or lowest_enemy.character_resource.current_health / float(lowest_enemy.character_resource.max_health) > n.character_resource.current_health / float(n.character_resource.max_health) : 
			lowest_enemy = n
	return [lowest_enemy.position_id]

func target_boss() -> Array[int]:
	var boss = null
	for n in CharactersManager.enemy_characters:
		if n.character_resource.is_boss:
			boss = n
	if boss == null: boss = owner_character
	return [boss.position_id]

func target_most_cards_player() -> Array[int]:
	if _current_slot_target == null:
		var most_cards_player = null
		for n in CharactersManager.player_characters:
			if n == null: continue
			if most_cards_player == null or most_cards_player.hand.current_cards.size() < n.hand.current_cards.size() : 
				most_cards_player = n
		_current_slot_target = most_cards_player.position_id
	return [_current_slot_target]

func target_front_row_ally_at_start() -> Array[int]:
	var target = owner_character.enemies_by_position_at_start[0] if not owner_character.enemies_by_position_at_start[1].is_dead else null
	if target == null:
		target = CharactersManager.enemy_characters.pick_random()
	return [target.position_id]

func target_mid_row_ally_at_start() -> Array[int]:
	var target = owner_character.enemies_by_position_at_start[1] if not owner_character.enemies_by_position_at_start[1].is_dead else null
	if target == null:
		target = CharactersManager.enemy_characters.pick_random()
	return [target.position_id]

func target_back_row_ally_at_start() -> Array[int]:
	var target = owner_character.enemies_by_position_at_start[2] if not owner_character.enemies_by_position_at_start[1].is_dead else null
	if target == null:
		target = CharactersManager.enemy_characters.pick_random()
	return [target.position_id]

func target_most_bleed() -> Array[int]:
	var target = CharactersManager.player_characters.pick_random() if _current_slot_target == null else CharactersManager.players_positions_by_id[_current_slot_target]
	var current_top_bleed = target.status.current_bleed
	for n in CharactersManager.player_characters:
		if n.status.current_bleed > current_top_bleed:
			target = n
	_current_slot_target = target.position_id
	return[_current_slot_target]

func target_all_enemies() -> Array[int]:
	return CharactersManager.get_enemy_filled_slots()

func target_most_poison() -> Array[int]:
	var target = CharactersManager.player_characters.pick_random() if _current_slot_target == null else CharactersManager.players_positions_by_id[_current_slot_target]
	var current_top_poison = target.status.current_status.count(CharacterStatus.Status.POISON)
	for n in CharactersManager.player_characters:
		if n.status.current_status.count(CharacterStatus.Status.POISON) > current_top_poison:
			target = n
	_current_slot_target = target.position_id
	return[_current_slot_target]

func target_highest_player_health_percentage() -> Array[int]:
	if _current_slot_target == null:
		var highest_player = null
		for n in CharactersManager.player_characters:
			if n == null: continue
			if highest_player == null or float(highest_player.character_resource.current_health) / float(highest_player.max_health) < float(n.character_resource.current_health) / float(n.max_health): 
				highest_player = n
		_current_slot_target = highest_player.position_id
	return [_current_slot_target]

func reset_targeting() -> void:
	_current_slot_target = null

#endregion

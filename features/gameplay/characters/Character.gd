extends Node2D

class_name Character

signal on_attack(target: Character, health_lost_amount: int)
signal on_got_attacked(attacker: Character, health_lost_amount: int)
signal on_excess_heal(amount: int)
signal on_character_death(char: Character)
signal on_character_performed_move(char: Character)
signal on_allied_crossed(crossed : Character, crosser : Character, is_from_the_left: bool)

#region statuts signals

signal on_poison_tick_phase()
signal on_acceleration_tick_phase()
signal on_bleed_tick_phase()
signal on_heal_pack_tick_phase(is_healing_once: bool)

#endregion

@export var character_resource: CharacterResource
@export var hand: Hand
@export var ui: CharacterUi
@export var feedback: CharacterFeedback
@export var status: CharacterStatus
@export var position_id: int

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: CharacterAnimations = $AnimationPlayer

var inflicted_damage_multiplier: Array[DamageMultiplierEvaluator]
var received_damage_multiplier: Array[DamageMultiplierEvaluator]

var hand_data: HandData

var is_dead: bool = false

var max_health: int

var mat: Material:
	get:
		if mat == null: mat = sprite.material
		return mat

var _level_manager: LevelManager:
	get: 
		if _level_manager == null:
			return BattleStageManager.level_manager
		return _level_manager

var is_move_logic_ended: bool = false
var is_animation_finished: bool = false

#region Initialization

func _ready() -> void:
	_connect_signals()

func initialize() -> void:
	_initialize_character_data()
	sprite.sprite_frames = character_resource.sprite_frames
	hand_data = character_resource.hand_data
	if ui:
		ui.register_owner_character(self)
	animation_player.initialize(self)
	feedback.register_owner(self)
	status.owner_character = self
	_initialize_health_and_shield()

func _initialize_character_data() -> void:
	character_resource.initialize(self)

func _initialize_health_and_shield() -> void:
	max_health = character_resource.max_health
	if not ui: return
	ui.update_health(character_resource)
	ui.update_shield(character_resource)

#endregion


#region Signals

func _connect_signals() -> void:
	BattleStageManager.on_new_turn.connect(on_new_turn)
	BattleStageManager.on_player_won_wave.connect(_on_player_won_wave)

func on_new_turn() -> void:
	if is_dead: return
	on_heal_pack_tick_phase.emit(true)
	if self is PlayerCharacter: on_poison_tick_phase.emit()

func _on_player_won_wave() -> void:
	character_resource.current_shield = 0
	ui.update_shield()

func _on_move_logic_ended(move: Move) -> void:
	move.on_move_logic_ended.disconnect(_on_move_logic_ended)
	is_move_logic_ended = true

func _on_move_anim_finished(_anim_name: StringName) -> void:
	animation_player.animation_finished.disconnect(_on_move_anim_finished)
	is_animation_finished = true
	animation_player.set_default_anim()

#endregion


#region Main

func _perform_move(move: Move, target: Character) -> void:
	if is_dead: return
	on_heal_pack_tick_phase.emit(false)
	CharactersManager.is_a_character_performing_move = true
	print("Before animation will be played", Time.get_ticks_msec())
	animation_player.play(move.anim_name)
	animation_player.animation_finished.connect(_on_move_anim_finished)
	await animation_player.on_move_anim_hit
	print("Animation Hit", Time.get_ticks_msec())
	
	move.on_move_logic_ended.connect(_on_move_logic_ended) 
	move.perform(target)
	
	while(not is_move_logic_ended or not is_animation_finished):
		await get_tree().process_frame
	
	print("Animation and Logic ended", Time.get_ticks_msec())
	_complete_move()

func _complete_move() -> void:
	is_move_logic_ended = false
	is_animation_finished = false
	CharactersManager.is_a_character_performing_move = false
	on_bleed_tick_phase.emit()
	on_character_performed_move.emit(self)

func take_damage(damage_amount: int, attacker : Character, is_piercing_shield: bool = false) -> int:
	if is_dead or status.check_for_damage_immune(): return 0
	if not attacker == self and status.check_for_mark(attacker):
		damage_amount = roundi(damage_amount * status.MARK_PERCENTAGE)
	var health_lost : int = character_resource.take_damage(damage_amount, is_piercing_shield)
	on_got_attacked.emit(attacker, health_lost)
	if health_lost > 0: feedback.play_damage_feedback(health_lost)
	return health_lost

func add_shield(shield_amount: int) -> void:
	character_resource.add_shield(shield_amount)
	if shield_amount > 0: feedback.play_shield_feedback(shield_amount)

func heal(heal_amount : int) -> int:
	var heal_received: int = character_resource.heal(heal_amount)
	if heal_received > 0: feedback.play_heal_feedback(heal_received)
	if heal_amount - heal_received > 0: on_excess_heal.emit(heal_amount - heal_received)
	return heal_received

func die() -> void:
	on_character_death.emit(self)


#endregion


#region Displacements

func move_to_front_row() -> Array[Character]:
	var start_position_id: int = position_id 
	var allies_character_ordered: Array[Character] = CharactersManager.get_allies_characters_ordered(self)
	var allies_crossed: Array[Character] = [] as Array[Character]
	for n: Character in allies_character_ordered:
		if n == null: continue
		if abs(n.position_id) < abs(start_position_id):
			allies_crossed.push_back(n)
			on_allied_crossed.emit(n, self, self is PlayerCharacter)
	position_id = 0
	allies_character_ordered.erase(self)
	allies_character_ordered.insert(position_id, self)
	
	CharactersManager.move_characters_to_their_respective_slots(BattleStageManager.get_allies_slots_positions(self), allies_character_ordered)
	CharactersManager.order_characters(allies_character_ordered, self is PlayerCharacter)
	return allies_crossed

func move_to_back_row() -> Array[Character]:
	var start_position_id: int = position_id
	var allies_character_ordered: Array[Character] = CharactersManager.get_allies_characters_ordered(self)
	var allies_crossed: Array[Character] = [] as Array[Character]
	for n: Character in allies_character_ordered:
		if n == null: continue
		if abs(n.position_id) > abs(start_position_id):
			allies_crossed.push_back(n)
			on_allied_crossed.emit(n, self, self is PlayerCharacter)
	if allies_character_ordered.back() == null:
		allies_character_ordered.remove_at(2)
		allies_character_ordered.push_front(null)
	position_id = 2
	allies_character_ordered.erase(self)
	allies_character_ordered.insert(position_id, self)
	CharactersManager.move_characters_to_their_respective_slots(BattleStageManager.get_allies_slots_positions(self), allies_character_ordered)
	CharactersManager.order_characters(allies_character_ordered, self is PlayerCharacter)
	return allies_crossed

func switch_with_target(target: Character) -> void:
	if target == self: return
	var owner_new_pos_id: int = target.position_id
	var target_new_pos_id: int = position_id
	position_id = owner_new_pos_id
	target.position_id = target_new_pos_id
	if target is PlayerCharacter :
		var allies_character_ordered: Array[Character] = CharactersManager.get_allies_characters_ordered(self)
		allies_character_ordered.erase(self)
		allies_character_ordered.insert(position_id, self)
		allies_character_ordered.erase(target)
		allies_character_ordered.insert(target.position_id, target)
		var slots_positions: Array[Slot] = BattleStageManager.get_allies_slots_positions(self)
		for i: int in slots_positions.size():
			var character: Character = allies_character_ordered[i]
			if character == null: continue
			character.move_character(slots_positions[i].global_position)
			character.hand.cards_holder.set_destination_size_and_pos()


#endregion


#region Feedback and Visuals

func set_character_alpha_shader_value(value: float) -> void:
	mat.set_shader_parameter("alpha_main",value)
	modulate.a = value

func show_targets(_id: int = 0) -> void:
	pass

func move_character(destination: Vector2) -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_method(_update_position, global_position, destination, 0.4)

#endregion


#region Utils

func has_status(status_id : StringName) -> bool:
	return status.active_statuses_ids.keys().has(status_id)

func _update_position(given_position: Vector2) -> void:
	global_position = given_position

func get_current_move() -> Move:
	return character_resource.current_moves[hand.current_final_hand.chosen_suit]

#endregion

extends Character

class_name EnemyCharacter

@export var cards_parent: HBoxContainer
@export var _collision_shape: CollisionPolygon2D

@export var _boss_passive_texture_rect: TextureRect
@export var _boss_passive_name_label: Label
@export var _boss_passive_description_label: RichTextLabel

var current_moves : Array[EnemyMove]
var current_move : EnemyMove
var current_move_index : int = 0
var _current_move_points : int = 0

var enemies_by_position_at_start : Array[Character]

#region Initialization

func initialize() -> void:
	if character_resource.moves.size() == 0:
		printerr("%s has no moves" % character_resource.display_name)
	current_moves = character_resource.moves
	_set_current_move()
	set_condition()
	if character_resource.is_boss and not character_resource.boss_passive == null: display_boss_passive()
	set_enemy_alpha_shader_value(0)
	_update_cards()
	super.initialize()
	CharactersManager.on_enemy_characters_initialized.connect(_on_enemy_characters_initalized)
	CharactersManager.register_enemy_character(self, get_parent())

func set_condition() -> void:
	if not character_resource.condition == null:
		character_resource.condition.initialize(self)

#endregion

#region Signals

func _connect_signals() -> void:
	SettingsManager.on_localization_changed.connect(set_target)
	CharactersManager.on_characters_manager_initialized.connect(_on_characters_manager_initialized)
	super._connect_signals()

func _on_enemy_characters_initalized() -> void:
	enemies_by_position_at_start = CharactersManager.enemies_positions_by_id.duplicate()

func _on_characters_manager_initialized() -> void:
	enemies_by_position_at_start = CharactersManager.enemies_positions_by_id.duplicate()


func _on_move_anim_finished(_anim_name) -> void:
	super._on_move_anim_finished(_anim_name)
	_current_move_points = 0
	if current_move_index >= current_moves.size() - 1:
		current_move_index = 0
	else:
		current_move_index += 1
	_set_current_move()
	set_target()
	_update_cards()

#endregion

#region Turn & Moves

func gain_move_points() -> void:
	if is_dead: return
	status.check_for_poison()
	if is_dead: return
	if status.check_for_paralysis(): return
	var points_gain = character_resource.hand_data.reload_size
	if status.check_for_acceleration():
		points_gain += 1
	update_move_points(points_gain)

func update_move_points(value : int) -> void:
	_current_move_points += value
	if _current_move_points < 0: _current_move_points = 0
	if _current_move_points >= current_move.move_points_required:
		if is_dead: return
		BattleStageManager.enemies_waiting_to_perform_move.push_back(self)
	_update_cards()

func _update_cards() -> void:
	var cards = cards_parent.get_children().duplicate()
	cards.reverse()
	for i in cards.size():
		if i < current_move.move_points_required:
			cards[i].show()
			cards[i].modulate = Color("fab03b") if i < _current_move_points else Color("272727")
		else:
			cards[i].hide()

func perform_move() -> void:
	current_move.ally_characters = CharactersManager.player_characters.duplicate()
	var target = get_current_target()
	if not current_move.is_target_valid(target): printerr("wrong target for enemy character")
	_perform_move(current_move, target)

func _set_current_move() -> void:
	current_move = current_moves[current_move_index]._duplicate(true)
	current_move.register_owner_character(self)

#endregion

#region Targeting

func set_target() -> void:
	current_move.enemy_target_string = current_move.move_targets.get_formatted_name()
	ui.moves_ui.moves_buttons[0].update_move_description(current_move, true)
	ui.moves_ui.update_moves_preview([true, false,false, false] as Array[bool], [current_move, null, null, null] as Array[Move])

func show_targets(_id : int = 0) -> void:
	var targeted_slots = current_move.move_targets.get_targeted_slots(current_move)
	var positions = BattleStageManager.level_manager.player_characters_positions if current_move.is_move_targeting_an_opponent() else BattleStageManager.level_manager.enemy_characters_positions
	for n in targeted_slots:
		var slot = positions[n] as Slot
		slot.set_targetable(current_move.color)
		slot.set_targeted()

func get_current_target() -> Character:
	var targeted_slots = current_move.move_targets.get_targeted_slots(current_move)
	var target = CharactersManager.get_player_character_with_position_id(targeted_slots[0]) as Character if current_move.is_move_targeting_an_opponent() else CharactersManager.get_enemy_character_with_position_id(targeted_slots[0]) as Character
	return target

#endregion

#region Visuals

func display_boss_passive() -> void:
	_boss_passive_texture_rect.show()
	_boss_passive_texture_rect.texture = character_resource.boss_passive.texture
	_boss_passive_name_label.text = character_resource.boss_passive.name
	_boss_passive_description_label.text = character_resource.boss_passive.description

func set_enemy_alpha_shader_value(value: float) -> void:
	mat.set_shader_parameter("alpha_main",value)

#endregion

func die() -> void:
	is_dead = true
	animation_player.stop()
	animation_player.kill_idle()
	sprite.animation = "busted"
	ui.visible = false
	if character_resource.is_boss and not character_resource.boss_passive == null:
		character_resource.boss_passive.disable()
	_collision_shape.disabled = true
	var tween = get_tree().create_tween()
	tween.tween_method(set_enemy_alpha_shader_value, 1.0, 0.0, 2)
	tween.set_parallel().tween_property(sprite, "modulate:a", 0, 2)
	tween.set_parallel().tween_property(animation_player.shadow, "modulate:a", 0, 2)
	super.die()

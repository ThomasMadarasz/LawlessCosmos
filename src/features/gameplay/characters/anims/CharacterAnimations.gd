extends AnimationPlayer

class_name CharacterAnimations

signal on_move_anim_hit()

@export var shadow: Sprite2D
@export var _animated_sprite : AnimatedSprite2D

var _idle_data : IdleData

var _scale_idle_tween : Tween
var _position_idle_tween : Tween
var _shadow_idle_tween : Tween

var owner_character: Character

@onready var _animated_sprite_base_position : Vector2 = _animated_sprite.position
@onready var _animated_sprite_scale: Vector2 = _animated_sprite.scale
@onready var _shadow_scale: Vector2 = shadow.scale
@onready var _shadow_base_position: Vector2 = shadow.position

func initialize(character: Character) -> void:
	owner_character = character
	_idle_data = owner_character.character_resource.idle_data
	set_idle()

func set_default_anim() -> void:
	play("idle")

func set_idle() -> void:
	var idle_speed = randf_range(_idle_data.idle_duration_min, _idle_data.idle_duration_max)
	if not _idle_data.idle_scale_ratio == 1:
		var full_size_y = _animated_sprite_scale.y
		var min_size_y = full_size_y * _idle_data.idle_scale_ratio
		_scale_idle_tween = create_tween().set_loops()
		_scale_idle_tween.tween_property(_animated_sprite, "scale:y", min_size_y, idle_speed)
		_scale_idle_tween.tween_property(_animated_sprite, "scale:y", full_size_y, idle_speed)
	
	if not _idle_data.idle_floating_displacement_y == 0:
		var base_pos_y = _animated_sprite_base_position.y - (_idle_data.idle_floating_displacement_y/2)
		_position_idle_tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		_position_idle_tween.tween_property(_animated_sprite, "position:y", base_pos_y, idle_speed)
		_position_idle_tween.tween_property(_animated_sprite, "position:y", base_pos_y + _idle_data.idle_floating_displacement_y, idle_speed)
	
	if not _idle_data.idle_shadow_scale_ratio == 1:
		var full_size = _shadow_scale
		var min_size = full_size * _idle_data.idle_shadow_scale_ratio
		_shadow_idle_tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		_shadow_idle_tween.tween_property(shadow, "scale", min_size, idle_speed)
		_shadow_idle_tween.tween_property(shadow, "scale", full_size, idle_speed)

func kill_idle() -> void:
	if _scale_idle_tween: 
		_scale_idle_tween.stop()
		_scale_idle_tween.kill()
	if _position_idle_tween:
		_position_idle_tween.stop()
		_position_idle_tween.kill()
	if _shadow_idle_tween: 
		_shadow_idle_tween.stop()
		_shadow_idle_tween.kill()

func move(move_anim_data: MoveAnimData) -> void:
	kill_idle()
	var base_pos_x = _animated_sprite_base_position.x
	var move_tween = create_tween()
	move_tween.tween_property(_animated_sprite, "position:x", base_pos_x + move_anim_data.displacement_x if owner_character is PlayerCharacter else base_pos_x - move_anim_data.displacement_x, move_anim_data.step_duration)
	move_tween.parallel().tween_property(shadow, "position:x", _shadow_base_position.x + move_anim_data.displacement_x if owner_character is PlayerCharacter else _shadow_base_position.x - move_anim_data.displacement_x, move_anim_data.step_duration)
	move_tween.tween_property(_animated_sprite, "position:x", base_pos_x, move_anim_data.replacement_duration)
	move_tween.parallel().tween_property(shadow, "position:x", _shadow_base_position.x, move_anim_data.replacement_duration)
	move_tween.tween_callback(set_idle)
	move_tween.tween_callback(move_tween.kill)

func on_move_hit() -> void:
	set("parameters/conditions/is_performing_move", false)
	print("Animation Hit Emit", Time.get_ticks_msec())
	on_move_anim_hit.emit()

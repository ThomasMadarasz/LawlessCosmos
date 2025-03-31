extends Node

class_name CharacterFeedback

@export var _center_character_marker: Marker2D
@export var _bottom_character_marker: Marker2D

@export var _base_color: Color

@export var _animated_sprite : AnimatedSprite2D

@onready var _animated_sprite_base_position : Vector2 = _animated_sprite.position


var _shake_time : float

var owner_character: Character

var _mat : Material :
	get :
		if owner_character == null: return null
		if _mat == null: return owner_character.mat
		return _mat

func register_owner(character: Character) -> void:
	owner_character = character

#region Selection & Targeting

func play_selection_feedback(is_selected: bool) -> void:
	if not owner_character is PlayerCharacter: return
	_mat.set_shader_parameter("is_selected", is_selected)
	_mat.set_shader_parameter("ColorParameter", owner_character.character_resource.gradient.colors[0])

func play_target_feedback(is_targeted: bool) -> void:
	_mat.set_shader_parameter("is_selected", is_targeted)
	_mat.set_shader_parameter("ColorParameter", CharactersManager.selected_character.character_resource.current_moves[CharactersManager.selected_character.hand.current_final_hand.chosen_suit].color)
	_mat.set_shader_parameter("outline_thickness", 2 if is_targeted else 1)

func reset_target_feedback() -> void:
	_mat.set_shader_parameter("is_selected", false)
	_mat.set_shader_parameter("ColorParameter", _base_color)
	_mat.set_shader_parameter("outline_thickness", 2)

#endregion

#region Health and Shield

func play_damage_feedback(health_lost: int) -> void:
	_set_shake(owner_character.character_resource.damage_shake_data)
	var tween = create_tween().set_ease(Tween.EASE_IN)
	var damage_vfx = _set_up_particles(ResourcesManager.damage_vfx)
	damage_vfx.global_position = _center_character_marker.global_position
	damage_vfx.amount = health_lost
	damage_vfx.restart()
	tween.tween_callback(owner_character.ui.update_health)
	tween.tween_interval(damage_vfx.lifetime - 1)
	tween.tween_property(damage_vfx, "modulate:a", 0, 0.5)

func play_shield_feedback(current_shield_amount_received: int) -> void:
	var shield_vfx = _set_up_particles(ResourcesManager.shield_vfx)
	shield_vfx.global_position = _center_character_marker.global_position
	shield_vfx.amount = current_shield_amount_received
	shield_vfx.emission_sphere_radius = clampi(roundi(current_shield_amount_received * 1.5), 40, 100)
	shield_vfx.restart()
	owner_character.ui.update_shield()

func play_shield_lost_feedback(value : int) -> void:
	if value > 0: 
		var shield_damage_vfx = _set_up_particles(ResourcesManager.shield_damage_vfx)
		shield_damage_vfx.global_position = _center_character_marker.global_position
		shield_damage_vfx.amount = value
		shield_damage_vfx.modulate = Color.TRANSPARENT
		shield_damage_vfx.restart()
		var tween = create_tween().set_ease(Tween.EASE_IN)
		tween.tween_callback(owner_character.ui.update_shield)
		tween.tween_interval(0.01)
		tween.tween_callback(_pause_particles.bind(shield_damage_vfx))
		tween.tween_property(shield_damage_vfx, "modulate", Color.WHITE, 0.5)
		tween.tween_callback(_resume_particles.bind(shield_damage_vfx))

func play_heal_feedback(heal_received: int) -> void: 
	var heal_vfx = _set_up_particles(ResourcesManager.heal_vfx)
	heal_vfx.global_position = _bottom_character_marker.global_position
	heal_vfx.amount = heal_received
	heal_vfx.restart()
	owner_character.ui.update_health()

#endregion

#region Status

func play_status_application_feedback(status_id: CharacterStatus.Status) -> void:
	match status_id:
		CharacterStatus.Status.STUN:
			pass
		CharacterStatus.Status.POISON:
			_set_shake(owner_character.character_resource.poison_shake_data)
			_play_poison_particles()
		CharacterStatus.Status.BLEED:
			pass
		CharacterStatus.Status.PARALYZIS:
			pass
		CharacterStatus.Status.ACCELERATED:
			pass
		CharacterStatus.Status.DAMAGE_IMMUNE:
			pass
		CharacterStatus.Status.FOCUS:
			pass
		CharacterStatus.Status.HEAL:
			pass
		CharacterStatus.Status.BARRICADE:
			pass
		CharacterStatus.Status.MARK:
			pass

func play_status_trigger_feedback(status_id: CharacterStatus.Status) -> void:
	match status_id:
		CharacterStatus.Status.STUN:
			pass
		CharacterStatus.Status.POISON:
			_play_poison_particles()
		CharacterStatus.Status.BLEED:
			pass
		CharacterStatus.Status.PARALYZIS:
			pass
		CharacterStatus.Status.ACCELERATED:
			pass
		CharacterStatus.Status.DAMAGE_IMMUNE:
			pass
		CharacterStatus.Status.FOCUS:
			pass
		CharacterStatus.Status.HEAL:
			pass
		CharacterStatus.Status.BARRICADE:
			pass
		CharacterStatus.Status.MARK:
			pass

func _play_poison_particles() -> void:
	var poison_particles = _set_up_particles(ResourcesManager.poison_vfx)
	poison_particles.global_position = _bottom_character_marker.global_position
	poison_particles.restart()

#endregion

#region shake

func _process(delta) -> void:
	_shake_time += delta

func _set_shake(shake_data: ShakeData) -> void:
	_shake_time = 0
	owner_character.animation_player.kill_idle()
	var shake_tween = create_tween()
	shake_tween.tween_method(_shake.bind(shake_data), 0, 1, shake_data.duration)
	shake_tween.tween_callback(owner_character.animation_player.set_idle)
	shake_tween.tween_callback(shake_tween.kill)

func _shake(time: float, shake_data: ShakeData) -> void:
	var frequency_weight = ease(time, shake_data.frequency_curve)
	var frequency = lerpf(shake_data.frequency_start, shake_data.frequency_end, frequency_weight)
	if _shake_time < frequency: return
	var decay_weight = ease(time, shake_data.decay_curve)
	var decay = lerpf(shake_data.decay_start, shake_data.decay_end, decay_weight)
	if not frequency == 0: _shake_time = fmod(_shake_time, frequency) 
	var amplitude = shake_data.amplitude * decay
	_animated_sprite.position = _animated_sprite_base_position + Vector2(randf_range(-amplitude, amplitude), randf_range(-amplitude, amplitude))

#endregion

#region Particles Utils

func _set_up_particles(particles_resource: PackedScene) -> CPUParticles2D:
	var particles = particles_resource.instantiate() as CPUParticles2D
	add_child(particles)
	particles.finished.connect(particles.queue_free)
	return particles

func _pause_particles(particles: CPUParticles2D) -> void:
	particles.speed_scale = 0

func _resume_particles(particles: CPUParticles2D) -> void:
	particles.speed_scale = 1

#endregion

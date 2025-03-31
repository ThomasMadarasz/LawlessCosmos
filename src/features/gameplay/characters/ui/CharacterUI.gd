extends Control

class_name CharacterUi

signal on_health_bar_updated()

@export var _efficiency_preview_label: Label

@export_category("Stats")
@export var _health_bar: TextureProgressBar
@export var _health_label: Label
@export var _shield_label: Label

var _current_displayed_health_value : int
var _current_displayed_shield_value : int

var owner_character: Character

func _ready() -> void:
	_connect_signals()

func register_owner_character(character: Character) -> void: 
	owner_character = character

#region Signals

func _connect_signals() -> void:
	BattleStageManager.on_targeting_phase_started.connect(_on_targeting_phase_started)
	BattleStageManager.on_targeting_phase_stopped.connect(_on_targeting_phase_stopped)

func _on_targeting_phase_started() -> void:
	mouse_default_cursor_shape = CURSOR_CROSS

func _on_targeting_phase_stopped() -> void:
	mouse_default_cursor_shape = CURSOR_ARROW
	hide_efficiency_preview()



#endregion


#region Main

func show_efficiency_preview(move: Move, performer: Character = CharactersManager.selected_character)  -> void:
	var power = performer.hand.current_final_hand.power if performer is PlayerCharacter else performer.current_move.enemy_power
	var value = move.calculate_power_with_damage_multiplier(power * move.move_power_multiplier, owner_character)
	var hit_amount = move.get_hit_amount()
	_efficiency_preview_label.text = str(value) if hit_amount <= 1 else str(hit_amount) + " x " + str(value)
	if move.move_tags.has(Move.MoveTags.DAMAGE): _efficiency_preview_label.modulate = Color.FIREBRICK
	elif move.move_tags.has(Move.MoveTags.HEAL): _efficiency_preview_label.modulate = Color.LIME_GREEN
	elif move.move_tags.has(Move.MoveTags.SHIELD): _efficiency_preview_label.modulate = Color.SKY_BLUE
	elif move.move_tags.has(Move.MoveTags.SUPPORT): _efficiency_preview_label.modulate = Color.GOLD
	else: _efficiency_preview_label.modulate = Color.WHITE

func hide_efficiency_preview() -> void:
	_efficiency_preview_label.text = ""

func update_shield(resource: CharacterResource = owner_character.character_resource) -> void:
	var tween_shield = create_tween()
	tween_shield.tween_method(count_shield_label.bind(_shield_label), _current_displayed_shield_value, resource.current_shield, 0.5)
	_current_displayed_shield_value = resource.current_shield

func update_health(resource: CharacterResource = owner_character.character_resource) -> void:
	var health_start_value = _current_displayed_health_value
	var tween_health = create_tween()
	tween_health.tween_method(count_health_label.bind(_health_label), _current_displayed_health_value, resource.current_health, 0.5)
	_health_bar.max_value = resource.max_health
	var tween_health_bar = create_tween()
	tween_health_bar.tween_method(count_health_bar, health_start_value, resource.current_health, 1.5)
	_current_displayed_health_value = resource.current_health
	await tween_health_bar.finished
	on_health_bar_updated.emit()

#endregion

#region Utils

func count_health_label(given_number, label: Label) -> void:
	var rounded_number = roundi(given_number)
	label.text = str(rounded_number) + "/" + str(owner_character.max_health)

func count_shield_label(given_number, label: Label) -> void:
	var rounded_number = roundi(given_number)
	label.text = str(rounded_number)

func count_health_bar(given_number) -> void:
	_health_bar.value = given_number

#endregion

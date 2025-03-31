extends Button

class_name HandManipulation

@export var resource : HandManipulationResource

@export_category("Hover")
@export var _name_label: Label
@export var _description_label: RichTextLabel
@export var _hover_cooldown_label: Label

@onready var _cooldown_label : Label = $Label

var manager : HandManipulationsManager

#region Godot API

func _ready() -> void:
	if not resource == null: resource.slot = self
	update_displayed_infos()
	_connect_signals()

func _process(_delta) -> void:
	if manager.is_deleting_hand_manipulation:
		var value = Time.get_ticks_msec() * 0.002
		self_modulate = Color(Color.RED * (abs(sin(value) / 2) + 0.5) + Color("558287") * (abs(cos(value) /2) + 0.5) , 1)
	else:
		self_modulate = Color.WHITE

#endregion


#region Signals

func _connect_signals() -> void:
	BattleStageManager.on_new_turn.connect(_on_new_turn)
	BattleStageManager.on_new_wave_started.connect(_on_new_wave_started)
	SettingsManager.on_localization_changed.connect(update_displayed_infos)

func _on_new_turn() -> void:
	if resource == null: return
	resource.current_cooldown -= 1
	update_cooldown()

func _on_new_wave_started() -> void:
	if resource == null: return
	resource.current_cooldown = 0
	update_cooldown()


func _on_hand_manipulation_button_pressed() -> void:
	if resource == null : return
	if CharactersManager.is_a_hand_manipulation_enabled: return
	if manager.is_deleting_hand_manipulation : 
		manager.delete_manipulation(self)
		return
	if not BattleStageManager.is_hand_combination_phase(): return
	if resource.current_cooldown <= 0:
		manager.current_manipulation = self
		BattleStageManager.level_manager.hand_manipulation_vfx.emitting = true
		resource.activate_hand_manipulation()

#endregion

#region Main

func update_displayed_infos() -> void:
	if resource == null :
		disabled = true 
		return
	disabled = false 
	_name_label.text = resource.formatted_name
	_description_label.text = resource.description
	_hover_cooldown_label.text = "%s : %s %s" % [tr("COOLDOWN"), resource.cooldown, tr("TURN")]
	update_cooldown()
	icon = resource.texture

func update_cooldown() -> void:
	_cooldown_label.text = str(resource.current_cooldown) if resource.current_cooldown > 0 else ""
	disabled = resource.current_cooldown > 0

#endregion

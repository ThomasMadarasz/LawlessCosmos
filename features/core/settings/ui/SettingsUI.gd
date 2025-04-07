extends Control

class_name SettingsUi

@export var _screen_mode_panel: PanelContainer
@export var _confirmation_label_count: Label
@export var _screen_mode_button: OptionButton
@export var _language_button: OptionButton
@export var _volume_slider: HSlider

const _CONFIRMATION_TIME: int = 15

var _confirmation_timer: Timer

var _current_screen_mode_index: int = 0
var _previous_screen_mode_index: int = 0

func _ready() -> void:
	_initialize_timer()
	load_settings()


func load_settings() -> void:
	if SaveManager.is_loaded != true:
		await SaveManager.save_is_ready
	
	if SaveManager.save_data.get(SaveManager.Saved_property.LANGUAGE):
		_on_languages_item_selected(SaveManager.save_data[SaveManager.Saved_property.LANGUAGE])
		_language_button.selected = SaveManager.save_data[SaveManager.Saved_property.LANGUAGE]
	
	if SaveManager.save_data.get(SaveManager.Saved_property.VOLUME):
		_on_volume_slider_value_changed(SaveManager.save_data[SaveManager.Saved_property.VOLUME])
		_volume_slider.value = SaveManager.save_data[SaveManager.Saved_property.VOLUME]
	
	if SaveManager.save_data.get(SaveManager.Saved_property.SCREEN_MODE):
		SettingsManager.set_screen_mode(SaveManager.save_data[SaveManager.Saved_property.SCREEN_MODE])
		_current_screen_mode_index = SaveManager.save_data[SaveManager.Saved_property.SCREEN_MODE]
		_screen_mode_button.selected = SaveManager.save_data[SaveManager.Saved_property.SCREEN_MODE]


func _initialize_timer() -> void:
	_confirmation_timer = Timer.new()
	add_child(_confirmation_timer)
	_confirmation_timer.wait_time = _CONFIRMATION_TIME
	_confirmation_timer.one_shot = true
	_confirmation_timer.timeout.connect(_screen_mode_reset)

func _process(_delta: float) -> void:
	if _confirmation_timer.is_stopped(): return
	_confirmation_label_count.text = str(round(_confirmation_timer.time_left))

func _on_quit_button_down() -> void:
	SettingsManager.hide_settings()

func _on_volume_slider_value_changed(value : float) -> void:
	AudioManager.modify_master_volume(value)
	SaveManager.save_property(SaveManager.Saved_property.VOLUME, value)

func _on_screen_mode_item_selected(index: int) -> void:
	SettingsManager.set_screen_mode(index)
	_current_screen_mode_index = index
	_screen_mode_panel.show()
	_confirmation_timer.start()
	SaveManager.save_property(SaveManager.Saved_property.SCREEN_MODE, index)

func _on_screen_panel_yes_button_down() -> void:
	_previous_screen_mode_index = _current_screen_mode_index
	_screen_mode_panel.hide()
	_confirmation_timer.stop()

func _on_screen_panel_no_button_down() -> void:
	_confirmation_timer.stop()
	_screen_mode_reset()

func _screen_mode_reset() -> void:
	_screen_mode_panel.hide()
	SettingsManager.set_screen_mode(_previous_screen_mode_index)
	SaveManager.save_property(SaveManager.Saved_property.SCREEN_MODE, _previous_screen_mode_index)

func _on_languages_item_selected(index: int) -> void:
	SettingsManager.set_locale_with_index(index)
	SaveManager.save_property(SaveManager.Saved_property.LANGUAGE, index)

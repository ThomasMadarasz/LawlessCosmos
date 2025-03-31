extends Node

signal on_localization_changed()

var is_settings_visible = false

const _SETTINGS_SCENE: = preload("res://datas/prefabs/settings/p_settings.tscn")

var _settings_panel : Control

func _ready() -> void:
	_set_window_size_and_screen()
	TranslationServer.set_locale("en")
	_instantiate_settings_panel()

func _set_window_size_and_screen() -> void:
	DisplayServer.window_set_size(DisplayServer.screen_get_size())
	DisplayServer.window_set_position(DisplayServer.screen_get_position(DisplayServer.get_primary_screen()))

func _instantiate_settings_panel() -> void:
	_settings_panel = _SETTINGS_SCENE.instantiate()
	add_child(_settings_panel)

func show_settings() -> void:
	_settings_panel.show()
	is_settings_visible = true

func hide_settings() -> void:
	_settings_panel.hide()
	is_settings_visible = false

func set_screen_mode(index: int):
	match index:
		0: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(DisplayServer.screen_get_size())
			DisplayServer.window_set_position(DisplayServer.screen_get_position(DisplayServer.get_primary_screen()) + Vector2i(0,30))
		2: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_size(DisplayServer.screen_get_size())
			DisplayServer.window_set_position(DisplayServer.screen_get_position(DisplayServer.get_primary_screen()))
		3: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func set_locale_with_index(index: int):
	match index:
		0: TranslationServer.set_locale("en")
		1: TranslationServer.set_locale("fr")
	on_localization_changed.emit()

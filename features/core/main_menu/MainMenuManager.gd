extends Node

@export var _demo_level : LevelResource
@export var _tuto_level : LevelResource

@export var _toggle_button_tutorial: CheckButton
@export var _difficulty_option_button: OptionButton

var _current_level_resource : LevelResource

var _difficulties_multiplier: Dictionary = {0:0.5, 1:0.8, 2:1, 3: 0.01}

func _ready() -> void:
	get_parent().move_child.call_deferred(self, 0)
	BattleStageManager.difficulty_multiplier = _difficulties_multiplier[2]
	BattleStageManager.is_tutorial = false
	_current_level_resource = _demo_level
	load_settings()


func load_settings() -> void:
	if SaveManager.is_loaded != true:
		await SaveManager.save_is_ready

	if SaveManager.save_data.get(SaveManager.Saved_property.TUTORIAL):
		_on_tutorial_button_toggled(SaveManager.save_data[SaveManager.Saved_property.TUTORIAL])
		_toggle_button_tutorial.button_pressed = SaveManager.save_data[SaveManager.Saved_property.TUTORIAL]

	if SaveManager.save_data.get(SaveManager.Saved_property.DIFFICULTY):
		_on_difficulty_option_button_item_selected(SaveManager.save_data[SaveManager.Saved_property.DIFFICULTY])
		_difficulty_option_button.selected = SaveManager.save_data[SaveManager.Saved_property.DIFFICULTY]


func _start_game() -> void:
	if SceneManager.is_switching_scene: return
	if ResourcesManager.is_resource_loading: return
	BattleStageManager.set_level_data(_current_level_resource)
	await ResourcesManager.load_player_characters(_current_level_resource.player_characters_resources)
	SceneManager.goto_scene(SceneManager.GAME_SCENE_PATH)

func _on_tutorial_button_toggled(toggled_on: bool) -> void:
	BattleStageManager.is_tutorial = toggled_on
	_current_level_resource = _tuto_level if toggled_on else _demo_level
	SaveManager.save_property(SaveManager.Saved_property.TUTORIAL, toggled_on)

func _on_difficulty_option_button_item_selected(index: int) -> void:
	BattleStageManager.difficulty_multiplier = _difficulties_multiplier[index]
	SaveManager.save_property(SaveManager.Saved_property.DIFFICULTY, index)

func _on_settings_button_down() -> void:
	SettingsManager.show_settings()

func _on_quit_button_down() -> void:
	get_tree().quit()

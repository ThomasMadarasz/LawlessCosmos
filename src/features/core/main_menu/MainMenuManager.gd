extends Node

@export var _demo_level : LevelResource
@export var _tuto_level : LevelResource

var _current_level_resource : LevelResource

var _difficulties_multiplier = {0:0.5, 1:0.8, 2:1}

func _ready() -> void:
	get_parent().move_child.call_deferred(self, 0)
	BattleStageManager.difficulty_multiplier = _difficulties_multiplier[2]
	BattleStageManager.is_tutorial = false
	_current_level_resource = _demo_level

func _start_game() -> void:
	if SceneManager.is_switching_scene: return
	if ResourcesManager.is_resource_loading: return
	BattleStageManager.set_level_data(_current_level_resource)
	await ResourcesManager.load_player_characters(_current_level_resource.player_characters_resources)
	SceneManager.goto_scene(SceneManager.GAME_SCENE_PATH)

func _on_tutorial_button_toggled(toggled_on: bool) -> void:
	BattleStageManager.is_tutorial = toggled_on
	_current_level_resource = _tuto_level if toggled_on else _demo_level

func _on_difficulty_option_button_item_selected(index: int) -> void:
	BattleStageManager.difficulty_multiplier = _difficulties_multiplier[index]

func _on_settings_button_down() -> void:
	SettingsManager.show_settings()

func _on_quit_button_down() -> void:
	get_tree().quit()

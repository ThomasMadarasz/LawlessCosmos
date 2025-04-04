extends Node

signal on_game_scene_instantiated(level_manager : LevelManager)

const MAIN_MENU_PATH: NodePath = "res://datas/scenes/sc_0_main.tscn"
const GAME_SCENE_PATH: NodePath = "res://datas/scenes/sc_1_game.tscn"

var is_switching_scene := false

var _current_scene = null

@onready var _current_scene_path = MAIN_MENU_PATH

func _ready() -> void:
	var root = get_tree().get_root()
	_current_scene = root.get_child(root.get_child_count() - 1)
	await ResourcesManager.load_resource(GAME_SCENE_PATH)

func goto_scene(path) -> void:
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior
	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	is_switching_scene = true
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path) -> void:
	# It is now safe to remove the current scene
	_current_scene.free()
	# Load the new scene.
	var s = ResourceLoader.load_threaded_get(path)
	# Instance the new scene.
	_current_scene = s.instantiate()
	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(_current_scene)
	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(_current_scene)
	get_tree().get_root().move_child(_current_scene, 0)
	ResourceLoader.load_threaded_request(_current_scene_path)
	_current_scene_path = path
	if path == GAME_SCENE_PATH:
		on_game_scene_instantiated.emit(_current_scene)
	is_switching_scene = false

func go_to_main_menu() -> void:
	goto_scene(MAIN_MENU_PATH)

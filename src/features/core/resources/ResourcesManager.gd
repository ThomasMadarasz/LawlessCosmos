extends Node

var available_cards: Array[Card]
var cards_pool : Node2D
var is_resource_loading = false

const CARD_PATH = "res://datas/prefabs/cards/p_card.tscn"

const _LOADING_ANIMATION_SCENE = preload("res://datas/prefabs/ui/loading_animation.tscn")

var _card_texture = preload("res://content/2d/textures/cards/atlas/tx_atlas_cards.png")
var _loading_animation : Node2D
var _current_loading_percentage = []
var _is_current_resource_loading = false
var _pathes_list = []


#region vfx 

var damage_vfx = load("res://datas/prefabs/vfx/p_debug_damage_vfx.tscn")
var shield_damage_vfx = load("res://datas/prefabs/vfx/p_debug_shield_damage_vfx.tscn")
var heal_vfx = load("res://datas/prefabs/vfx/p_debug_heal_vfx.tscn")
var shield_vfx = load("res://datas/prefabs/vfx/p_debug_shield_vfx.tscn")
var poison_vfx = load("res://datas/prefabs/vfx/p_debug_poison_vfx.tscn")

#endregion

#region Godot API

func _ready() -> void:
	_loading_animation = _LOADING_ANIMATION_SCENE.instantiate()
	add_child(_loading_animation)
	cards_pool = Node2D.new()
	add_child(cards_pool)
	cards_pool.position.x = -1000
	await load_resource(CARD_PATH)
	var card_prefab = ResourceLoader.load_threaded_get(CARD_PATH)
	for i in 52:
		available_cards.push_back(_instantiate_card(card_prefab))

func _process(delta) -> void:
	_loading_animation.modulate.a = clampf(_loading_animation.modulate.a + (delta * (1 if is_resource_loading else -1)),0,1)

#endregion

#region Loading Methods

func load_resource(path) -> void:
	_pathes_list.push_back(path)
	while _is_current_resource_loading:
		await get_tree().create_timer(0.1).timeout
	ResourceLoader.load_threaded_request(path)
	await _try_loaded(path)

func _try_loaded(path) -> void:
	is_resource_loading = true
	_is_current_resource_loading = true
	ResourceLoader.load_threaded_get_status(path, _current_loading_percentage)
	while _current_loading_percentage[0] < 1:
		ResourceLoader.load_threaded_get_status(path, _current_loading_percentage)
		await get_tree().create_timer(0.1).timeout
	_pathes_list.erase(path)
	if _pathes_list.size() < 1: is_resource_loading = false
	_is_current_resource_loading = false

#endregion

#region Cards

func _instantiate_card(card_prefab) -> Card:
	var new_card = card_prefab.instantiate() as Card
	cards_pool.add_child(new_card)
	new_card.global_position = cards_pool.global_position
	new_card.set_destination(new_card.global_position, true)
	new_card.texture = _card_texture
	return new_card

func recover_cards() -> void:
	var cards = get_tree().get_nodes_in_group("cards")
	for n in cards:
		if n.is_active:
			n.reset()
			n.get_parent().remove_child(n)
			cards_pool.add_child(n)

#endregion


#region Characters

func load_player_characters(characters_resources: Array[PlayerCharacterResource]) -> void:
	for n in characters_resources:
		await load_resource(n.file_path)
	return

func load_enemies_characters(level_data: LevelResource) -> void:
	for i in level_data.waves_array.size():
			if not level_data.waves_array[i].enemy_1 == null:
				await load_resource(level_data.waves_array[i].enemy_1.file_path)
			if not level_data.waves_array[i].enemy_2 == null:
				await load_resource(level_data.waves_array[i].enemy_2.file_path)
			if not level_data.waves_array[i].enemy_3 == null:
				await load_resource(level_data.waves_array[i].enemy_3.file_path)
	return

#endregion

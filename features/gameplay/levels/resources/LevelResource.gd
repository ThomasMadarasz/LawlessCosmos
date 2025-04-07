extends Resource

class_name LevelResource

@export var player_characters_resources : Array[PlayerCharacterResource] = [null, null, null]

## If not null, it is overriding other wave settings
@export var _test_wave : WaveData
@export var _normal_waves : Array[WaveData]
@export var _first_boss_waves : Array[WaveData]
@export var _final_boss_waves : Array[WaveData]

@export var rewards_array : Array[WaveRewardResource]

@export var wave_durability_multiplier_increment : float
@export var wave_efficiency_multiplier_increment : float

@export var AMOUNT_WAVE: int = 12
var waves_array : Array[WaveData] = []

var player_count: int:
	get: 
		if player_count > 0: 
			return player_count
		var i: int = 0
		for n: PlayerCharacterResource in player_characters_resources:
			if not n == null:
				i += 1
		return i

func initialize_waves_array() -> void:
	if not _test_wave == null:
		for n: int in AMOUNT_WAVE:
			waves_array.push_back(_test_wave.duplicate())
		return
	var normal_waves: Array[WaveData] = _normal_waves.duplicate(true)
	var first_boss_waves: Array[WaveData] = _first_boss_waves.duplicate(true)
	var final_boss_waves: Array[WaveData] = _final_boss_waves.duplicate(true)
	for i: int in 5: _pick_random_in_array_and_clear_picked(normal_waves, waves_array) #TODO: trmove magic number
	_pick_random_in_array_and_clear_picked(first_boss_waves, waves_array)
	for i: int in 5: _pick_random_in_array_and_clear_picked(normal_waves, waves_array) #TODO: trmove magic number
	_pick_random_in_array_and_clear_picked(final_boss_waves, waves_array)

func _pick_random_in_array_and_clear_picked(array_to_pick: Array, array_to_add: Array) -> void:
	if array_to_pick.size() == 0:
		printerr("Array to pick is empty")
	var element_to_add: Variant = array_to_pick.pick_random()
	array_to_add.push_back(element_to_add)
	array_to_pick.erase(element_to_add)

func get_wave_enemy_count(wave_index: int) -> int:
	var i: int = 0
	for n: EnemyCharacterResource in waves_array[wave_index].enemies:
		if not n == null:
			i += 1
	return i

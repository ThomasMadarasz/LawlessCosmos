extends Node

class_name CharacterStatus

signal on_status_added(status_id : StringName, caster : Character)

const MARK_PERCENTAGE: float = 1.2

var statuses_data: StatusesData = preload("res://datas/resources/status/_statuses_data.tres")

var statuses_data_ids : Dictionary ##StringName (status ids) : StatusData
var active_statuses_ids : Dictionary ##StringName (status ids) : ActiveStatus

var _status_uis: Array[StatusUI]:
	get:
		if _status_uis.size() > 0: return _status_uis
		_status_uis = [] as Array[StatusUI]
		for n: Node in get_children():
			_status_uis.push_back(n)
		return _status_uis 

var owner_character : Character

func _ready() -> void:
	_connect_signals()
	_initialize_statuses_datas()

func _initialize_statuses_datas() -> void:
	for n: StatusData in statuses_data.statuses_data:
		statuses_data_ids[n.id] = n

func _connect_signals() -> void:
	BattleStageManager.on_moves_solving_phase_started.connect(_on_moves_solving_phase_started)
	BattleStageManager.on_player_won_wave.connect(_on_player_won_wave)

func _on_moves_solving_phase_started() -> void:
	try_consume("stun")
	try_consume("damage_immune")

func _on_player_won_wave() -> void:
	clear_all_status()

#region Add and Remove Status

func add_status(status_id: StringName, amount: int, caster: Character) -> void:
	if amount <= 0: return
	elif status_id == "stun":
		for n: MoveButton in owner_character.hand.ui.moves_ui.moves_buttons:
			n.set_disabled(true)
	if not active_statuses_ids.has(status_id):
		var data : StatusData = statuses_data_ids[status_id]
		active_statuses_ids[status_id] = data.logic.new(data, _get_free_status_ui(), owner_character)
	active_statuses_ids[status_id].add(amount)
	owner_character.feedback.play_status_application_feedback(status_id)
	for _i: int in amount:
		on_status_added.emit(status_id, caster)

func consume_status(status_id: StringName, amount: int = 1) -> void:
	if amount <= 0: return
	active_statuses_ids[status_id].remove(amount)

func clear_all_status() -> void:
	for n: StatusUI in _status_uis:
		n.reset()
	active_statuses_ids.clear()

func clear_random_negative_status(amount: int) -> void:
	var negative_statuses: Dictionary = _get_negative_statuses_ids()
	for _i: int in amount:
		if negative_statuses.size() < 0:
			negative_statuses.values().pick_random().remove(1)

func clear_all_negative_status() -> void:
	for n: StringName in active_statuses_ids.keys():
		if not active_statuses_ids[n].is_positive_status:
			active_statuses_ids[n].status_ui.reset()
			active_statuses_ids.erase(n)

#endregion


#region Status Effects

func check_for_paralysis() -> bool:
	if active_statuses_ids.keys().has("paralysis"):
		consume_status("paralysis")
		return true
	return false

func check_for_barricade(target: Character) -> bool:
	if not  active_statuses_ids.keys().has("barricade"): return false
	if target == owner_character or owner_character.position_id < target.position_id:
		consume_status("barricade")
		return true
	return false

func check_for_mark(attacker: Character) -> bool:
	if not attacker == self and  active_statuses_ids.keys().has("mark"):
		consume_status("mark")
		return true
	return false

func check_for_stun() -> bool:
	if  active_statuses_ids.keys().has("stun"): return true
	return false

func check_for_damage_immune() -> bool:
	if  active_statuses_ids.keys().has("damage_immune"): 
		return true
	return false

func try_consume(status_id : StringName) -> void:
	if active_statuses_ids.keys().has(status_id): 
		consume_status(status_id)

#endregion


#region Utils

func get_status_count(status_id : StringName) -> int:
	return active_statuses_ids[status_id].count if active_statuses_ids.has(status_id) else 0

func _get_free_status_ui() -> StatusUI:
	var status_ui: StatusUI = null
	for n: StatusUI in _status_uis:
		if n.is_free:
			status_ui = n
			break
	if status_ui == null: printerr("No more free status ui")
	return status_ui

func _get_negative_statuses_ids() -> Dictionary:
	var negative_statuses : Dictionary
	for n: StringName in active_statuses_ids.keys():
		if not active_statuses_ids[n].is_positive_status:
			negative_statuses[n] = active_statuses_ids[n]
	return negative_statuses

func get_positive_statuses_ids() -> Dictionary:
	var positive_statuses : Dictionary
	for n: StringName in active_statuses_ids.keys():
		if not active_statuses_ids[n].is_positive_status:
			positive_statuses[n] = active_statuses_ids[n]
	return positive_statuses

#endregion

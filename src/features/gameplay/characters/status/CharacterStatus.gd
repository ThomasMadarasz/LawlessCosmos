extends Node

class_name CharacterStatus

signal on_status_added(status : CharacterStatus.Status, caster : Character)

enum Status {STUN, POISON, BLEED, PARALYZIS, ACCELERATED, DAMAGE_IMMUNE, FOCUS, HEAL, BARRICADE, MARK}

const POSITIVE_STATUS: Array[Status] = [Status.ACCELERATED, Status.FOCUS, Status.HEAL, Status.BARRICADE, Status.DAMAGE_IMMUNE]

const POISON_PERCENTAGE = 0.1
const HEAL_PERCENTAGE = 0.1
const MARK_PERCENTAGE = 1.2

var current_status : Array[Status]

var _status_controls: Array[Control]:
	get:
		if _status_controls.size() > 0: return _status_controls
		_status_controls = [] as Array[Control]
		for n in get_children():
			_status_controls.push_back(n)
		return _status_controls 

var current_bleed : int

var owner_character : Character

func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	BattleStageManager.on_moves_solving_phase_started.connect(_on_moves_solving_phase_started)
	BattleStageManager.on_player_won_wave.connect(_on_player_won_wave)

func _on_moves_solving_phase_started() -> void:
	try_consume(Status.STUN)
	try_consume(Status.DAMAGE_IMMUNE)

func _on_player_won_wave() -> void:
	clear_all_status()

#region Add and Remove Status

func add_status(status_id: int, amount: int, caster: Character) -> void:
	if amount <= 0: return
	if status_id == Status.BLEED:
		current_bleed += amount
	elif status_id == Status.STUN:
		for n in owner_character.hand.ui.moves_ui.moves_buttons:
			n.set_disabled(true)
	_status_controls[status_id].show()
	owner_character.feedback.play_status_application_feedback(status_id)
	for i in amount:
		current_status.push_back(status_id)
		on_status_added.emit(status_id, caster)
	update_status_label(status_id)

func consume_status(status_id: int, amount: int = 1) -> void:
	for i in amount:
		if status_id == Status.BLEED: current_bleed = 0
		current_status.erase(status_id)
		var status_duration = current_status.count(status_id)
		update_status_label(status_id)
		if status_duration <= 0: _status_controls[status_id].hide()

func clear_all_status() -> void:
	current_status.clear()
	current_bleed = 0
	for n in _status_controls:
		n.hide()

func clear_random_negative_status(amount: int) -> void:
	var current_status_copy = current_status.duplicate()
	for i in POSITIVE_STATUS:
		while current_status_copy.has(i):
			current_status_copy.erase(i)
	for i in amount:
		if current_status_copy.size() > 0:
			var random_status = current_status_copy.pick_random()
			consume_status(random_status, 1)
		else: break

func clear_all_negative_status() -> void:
	var status_to_remove = []
	for i in current_status.size():
		if not POSITIVE_STATUS.has(current_status[i]):
			status_to_remove.push_back(current_status[i])
	for i in status_to_remove.size():
		consume_status(status_to_remove[i])
	current_bleed = 0

#endregion


#region Status Effects

func check_for_heal(is_healing_once : bool) -> bool:
	if current_status.has(Status.HEAL) and owner_character.character_resource.current_health < owner_character.character_resource.max_health:
		var heal_amount = 1 if is_healing_once else current_status.count(Status.HEAL)
		owner_character.heal(HEAL_PERCENTAGE * owner_character.character_resource.max_health * heal_amount)
		consume_status(Status.HEAL, heal_amount)
		return true
	return false

func check_for_poison() -> bool:
	if current_status.has(Status.POISON):
		owner_character.take_damage(roundi(owner_character.max_health * POISON_PERCENTAGE), owner_character, true)
		consume_status(CharacterStatus.Status.POISON)
		return true
	return false

func check_for_bleed() -> bool:
	if current_status.has(CharacterStatus.Status.BLEED):
		owner_character.take_damage(current_bleed, owner_character, true)
		return true
	return false

func check_for_paralysis() -> bool:
	if current_status.has(Status.PARALYZIS):
		consume_status(Status.PARALYZIS)
		return true
	return false

func check_for_acceleration() -> bool:
	if current_status.has(Status.ACCELERATED):
		consume_status(Status.ACCELERATED)
		return true
	return false

func check_for_barricade(target: Character) -> bool:
	if not current_status.has(Status.BARRICADE): return false
	if target == owner_character or owner_character.position_id < target.position_id:
		consume_status(Status.BARRICADE)
		return true
	return false

func check_for_mark(attacker: Character) -> bool:
	if not attacker == self and current_status.has(Status.MARK):
		consume_status(Status.MARK, 1)
		return true
	return false

func check_for_stun() -> bool:
	if current_status.has(Status.STUN): return true
	return false

func check_for_damage_immune() -> bool:
	if current_status.has(Status.DAMAGE_IMMUNE): 
		return true
	return false

func try_consume(status : Status) -> void:
	if current_status.has(status): 
		consume_status(status)

#endregion


#region Utils

func update_status_label(status_id: int) -> void:
	var status_duration = current_status.count(status_id)
	if status_id == Status.BLEED: _status_controls[status_id].get_node("TurnDurationLabel").text = str(current_bleed)
	else: _status_controls[status_id].get_node("TurnDurationLabel").text = str(status_duration)

func get_positive_status() -> Array[Status]:
	var current_positive_status = [] as Array[Status]
	for n in current_status:
		if POSITIVE_STATUS.has(n): current_positive_status.push_back(n)
	return current_positive_status

#endregion

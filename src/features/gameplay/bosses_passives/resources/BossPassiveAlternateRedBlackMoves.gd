extends BossPassiveResource

class_name BossPassiveAlternateRedBlackMoves

@export var _turn_amount_to_switch : int
@export var _shield_gain_on_defense_form: int
@export var _damage_immune_amount_on_defense_form: int

var _current_turn_count: int

var _is_black_suits: bool

func enable() -> void:
	_disable_suits_moves()
	BattleStageManager.on_new_turn.connect(_on_new_turn)

func _on_new_turn() -> void:
	_current_turn_count += 1
	if _current_turn_count >= _turn_amount_to_switch:
		_is_black_suits = not _is_black_suits
		if _is_black_suits: _set_attack_form()
		else: _set_defense_form()
		_disable_suits_moves()
		_current_turn_count = 0

func _disable_suits_moves() -> void:
	var suits_to_disable = _get_suits_to_disable()
	for n in CharactersManager.player_characters:
		for move in n.character_resource.current_moves:
			if suits_to_disable.has(move.suit):
				move.is_disable_forced = true
			else:
				move.is_disable_forced = false
		n.hand.update_preview(n.hand.current_final_hand)

func _set_attack_form() -> void:
	owner_character.move_to_front_row()

func _set_defense_form() -> void:
	owner_character.move_to_back_row()
	owner_character.add_shield(_shield_gain_on_defense_form)
	owner_character.status.add_status(CharacterStatus.Status.DAMAGE_IMMUNE, _damage_immune_amount_on_defense_form, owner_character)

func _get_suits_to_disable() -> Array[int]:
	var array : Array[int] = []
	var black_array : Array[int] = [0,2]
	var red_array : Array[int] = [1,3]
	array = black_array if _is_black_suits else red_array
	return array

func disable() -> void:
	for n in BattleStageManager.on_new_turn.get_connections():
		if n["callable"] == _on_new_turn: 
			BattleStageManager.on_new_turn.disconnect(_on_new_turn)
	for n in CharactersManager.player_characters:
		for move in n.character_resource.current_moves:
			move.is_disable_forced = false
	super.disable()

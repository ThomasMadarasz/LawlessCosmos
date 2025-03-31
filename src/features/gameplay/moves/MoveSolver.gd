extends RefCounted

class_name MoveSolver

var _move : Move
var _move_components : Array[MoveComponent]

var owner_character : Character

var initial_targets : Array[Character]
var hit_targets : Array[Character]
var crossed_characters : Array[Character]
var health_lost : int

func _init(move : Move) -> void:
	_move = move
	owner_character = _move.owner_character
	_move_components = _move.components

func solve(targets : Array[Character]) -> void:
	initial_targets = targets
	var remaining_components = _move_components.duplicate(false)
	for n in _move_components:
		n.set_move(_move)
		n.set_move_solver(self)
		n.set_targets(n.targeting_behaviour.get_targets(self))
		await n.perform()
		remaining_components.erase(n)
		
		if n is MoveComponentMultiHits:
			for hit in n.get_hit_amount():
				var new_move_solver : MoveSolver = duplicate()
				new_move_solver._move_components = remaining_components.duplicate(false)
				await new_move_solver.solve(initial_targets)
				await BattleStageManager.get_tree().create_timer(n.get_time_between_hits()).timeout
			break
		
	return

func duplicate() -> MoveSolver:
	var new_move_solver = MoveSolver.new(_move)
	new_move_solver.initial_targets = initial_targets
	new_move_solver.hit_targets = hit_targets
	new_move_solver.crossed_characters = crossed_characters
	new_move_solver.health_lost = health_lost
	return new_move_solver

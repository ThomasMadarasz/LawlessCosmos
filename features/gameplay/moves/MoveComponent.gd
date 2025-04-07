extends BaseResource

class_name MoveComponent

@export var targeting_behaviour : MoveComponentTargetingBehavior

var _move: Move
var _move_solver : MoveSolver
var _targets: Array[Character]

var _owner_character: Character:
	get:
		if not _move_solver == null:
			return _move_solver.owner_character
		else: 
			return null

func perform() -> void:
	pass

func set_move(move: Move) -> void:
	_move = move

func set_move_solver(move_solver : MoveSolver) -> void:
	_move_solver = move_solver

func set_targets(targets : Array[Character]) -> void:
	_targets = targets

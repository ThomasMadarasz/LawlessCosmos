extends RefCounted

class_name ActiveStatus

var id : StringName
var count : int
var is_positive_status : bool
var status_ui : StatusUI

var _owner_character : Character

func _init(status_data: StatusData, ui: StatusUI, character: Character) -> void:
	id = status_data.id
	status_ui = ui
	is_positive_status = status_data.is_positive_status
	status_ui.set_data(status_data)
	status_ui.show()
	_owner_character = character
	enable()

func enable() -> void:
	pass

func add(amount : int) -> void:
	count += amount
	update_status_label()

func remove(amount : int) -> void:
	count -= amount
	if count <= 0: 
		count = 0
		status_ui.reset()
		_owner_character.status.active_statuses_ids.erase(id)
	update_status_label()


func update_status_label() -> void:
	status_ui.get_node("TurnDurationLabel").text = str(count)

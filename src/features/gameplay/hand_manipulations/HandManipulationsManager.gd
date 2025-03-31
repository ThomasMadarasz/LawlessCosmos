extends Node

class_name HandManipulationsManager

signal on_hand_manipulation_used()

@export var hand_manipulations : Array[HandManipulation]

@export var _delete_label : Label


var max_manipulations : int = 4
var is_deleting_hand_manipulation : bool = false
var current_manipulation: HandManipulation

var _hand_manipulation_count : int


func _ready() -> void:
	if BattleStageManager.is_tutorial:
		for n in hand_manipulations:
			n.resource = null
			n.hide()
	for n in hand_manipulations:
		n.manager = self
		if not n.resource == null:
			n.resource.manager = self
			_hand_manipulation_count += 1

func add_manipulation(resource : HandManipulationResource) -> void:
	for slot in hand_manipulations:
		if slot.resource == null:
			slot.resource = resource
			resource.slot = slot
			resource.manager = self
			slot.update_displayed_infos()
			slot.show()
			_hand_manipulation_count += 1
			break
	is_deleting_hand_manipulation = _hand_manipulation_count > max_manipulations
	_delete_label.visible = is_deleting_hand_manipulation
	_delete_label.text = "You can have up to %s manipulations. Choose %s to unequip them" % [max_manipulations, _hand_manipulation_count - max_manipulations]

func delete_manipulation(manipulation: HandManipulation) -> void:
	manipulation.resource = null
	manipulation.hide()
	_hand_manipulation_count -= 1
	is_deleting_hand_manipulation = _hand_manipulation_count > max_manipulations
	_delete_label.visible = is_deleting_hand_manipulation

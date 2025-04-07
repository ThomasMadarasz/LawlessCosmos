extends Node

var seed_name : String = ""

func _ready() -> void:
	var seed_to_use : int
	if seed_name:
		seed_to_use = hash( seed_name )
	else:
		seed_to_use = randi()
	seed( seed_to_use )
	print( seed_to_use, " is the seed being used" )

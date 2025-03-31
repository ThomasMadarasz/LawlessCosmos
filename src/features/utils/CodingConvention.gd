extends Node

class_name CodingConvention

#try to declare variable types as much as possible
var _private_int : int # starts with "_"
var public_int : int

const _PRIVATE_CONST = "private constante" # starts with "_"
const PUBLIC_CONST = "public constante"

signal on_something_happened # starts with "on"

enum ExampleEnum { ELEMENT_A, ELEMENT_B, ELEMENT_C }

#declare what functions are returning
func _private_function(used_int_param : int, _unused_int_param : int) -> void: # starts with "_"
	print(used_int_param)

func public_function() -> void:
	pass

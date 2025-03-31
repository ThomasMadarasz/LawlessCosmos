extends BaseResource

class_name CharacterResource

@export_file(".tscn") var file_path : String
@export var display_name: String
@export var sprite_frames: SpriteFrames
@export var hand_data: HandData
@export var idle_data: IdleData
@export var damage_shake_data: ShakeData
@export var poison_shake_data: ShakeData

@export var _base_shield : int
@export var _base_health: int

var owner_character: Character

var current_moves: Array[Move]
var current_health: int
var max_health : int
var current_shield: int


func initialize(character: Character) -> void:
	current_health = _base_health
	max_health = _base_health
	owner_character = character

func take_damage(damage_amount: int, is_piercing_shield: bool = false) -> int:
	var health_lost = 0
	var shield_lost = 0
	if damage_amount == 0: return damage_amount
	if not is_piercing_shield and current_shield > damage_amount: 
		current_shield -= damage_amount
		shield_lost = damage_amount
		owner_character.feedback.play_shield_lost_feedback(shield_lost)
	else:
		if not is_piercing_shield:
			damage_amount -= current_shield
			shield_lost = current_shield
			current_shield = 0
			owner_character.feedback.play_shield_lost_feedback(shield_lost)
		if current_health > damage_amount:
			health_lost = damage_amount
			current_health -= damage_amount
		else:
			health_lost = current_health
			current_health = 0
			owner_character.die()
			owner_character.feedback.reset_target_feedback()
	return health_lost

func heal(heal_amount) -> int:
	heal_amount = clamp(heal_amount, 0, max_health - current_health)
	current_health += heal_amount
	return heal_amount

func add_shield(shield_amount: int) -> void:
	current_shield += shield_amount

func get_global_health() -> int:
	return current_health + current_shield

func get_max_heal_amount() -> int:
	return max_health - current_health

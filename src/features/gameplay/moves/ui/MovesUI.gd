extends Node

class_name MovesUI

@export var moves_buttons: Array[MoveButton]

func _ready() -> void:
	BattleStageManager.on_player_won_wave.connect(hide_moves_preview)

func update_moves_preview(moves_to_preview: Array[bool], moves: Array[Move]) -> void:
	var owner_character = moves[0].owner_character
	for n in 4:
		var move_preview = moves_buttons[n] as MoveButton
		move_preview.set_disabled(not moves_to_preview[n])
		move_preview.is_forced_disable = not moves_to_preview[n]
		var suit_amount = 0
		var final_power = 0
		if not moves[n] == null:
			if moves_to_preview[n]: 
				suit_amount = owner_character.hand.current_final_hand.suits_amount[n] + owner_character.suit_amount_bonus[n] if owner_character is PlayerCharacter else 0
				final_power = moves[n].final_power
				if moves[n].move_tags.has(Move.MoveTags.DAMAGE): 
					final_power = moves[n].calculate_power_with_damage_multiplier(final_power)
				final_power = clampi(roundi(final_power), 1, 9223372036854775807) if moves[n].owner_character is PlayerCharacter else clampi(roundi(final_power), 0, 9223372036854775807)
		move_preview.update_move_stats(moves[n], final_power, suit_amount)

func hide_moves_preview() -> void:
	for i in 4:
		moves_buttons[i].set_disabled(true)

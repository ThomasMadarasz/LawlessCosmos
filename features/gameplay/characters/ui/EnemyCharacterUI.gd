extends CharacterUi

class_name EnemyCharacterUi

@export_category("Moves Preview")
@export var moves_ui: MovesUI

func register_owner_character(character: Character) -> void: 
	super.register_owner_character(character)
	for n: MoveButton in moves_ui.moves_buttons:
		n.register_owner_character(character)

func _connect_signals() -> void:
	super._connect_signals()
	SettingsManager.on_localization_changed.connect(_on_localization_changed)

func _on_localization_changed() -> void:
	set_moves_descriptions()

func set_moves_descriptions() -> void:
	for n: int in moves_ui.moves_buttons.size():
		var move: Move = owner_character.current_moves[0]
		moves_ui.moves_buttons[n].update_move_description(move, true)

func update_moves_preview(hand: FinalHandData)  -> void:
	var moves_to_preview: Array[bool]
	for n: int in 4: #TODO: Remove magic number
		if hand.available_suits.has(n): 
			moves_to_preview.push_back(not (owner_character.character_resource.current_moves[n].is_disable_forced or owner_character.has_status("stun")))
		else: 
			moves_to_preview.push_back(false)
	if hand.cards_resources.size() == 0: moves_to_preview = [false, false, false, false]
	moves_ui.update_moves_preview(moves_to_preview, [owner_character.current_move, null, null, null])

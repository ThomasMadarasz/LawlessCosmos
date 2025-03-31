extends CharacterUi

class_name PlayerCharacterUi

@export var selection_arrow: TextureRect

func _ready() -> void:
	BattleStageManager.on_player_won_wave.connect(_on_player_won_wave)
	super._ready()

func _on_player_won_wave() -> void:
	owner_character.hand.current_final_hand = FinalHandData.new(owner_character)


func play_selection_feedback(is_enabled := true) -> void:
	selection_arrow.visible = is_enabled

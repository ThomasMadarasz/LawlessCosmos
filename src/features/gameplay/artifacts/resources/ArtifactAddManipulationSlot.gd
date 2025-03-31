extends ArtifactResource

class_name ArtifactAddManipulationSlot

func enable(character : PlayerCharacter = null) -> void:
	super.enable(character)
	BattleStageManager.level_manager.hand_manipulations_manager.max_manipulations += 1

extends Resource

class_name TutorialElement

enum TutoType { NEXT, HANDS_COMBINATION, ACTIONS_SOLVING, ACTION_CHOSEN, ACTION_PERFORMED, ON_CARD_SELECTED, ON_CARD_DISCARDED, ON_NEW_WAVE, ON_PAIR_OR_HIGHER, ON_TARGETING_PHASE, ON_MANIPULATION, ON_STATUS_ADDED, ON_PLAYER_WON_WAVE, ON_REWARDS_DRAFTED, ON_HEALTH_BAR_UPDATED}

@export var type : Array[TutoType]
@export var previous_elements : Array[TutorialElement]
@export var delay : float

@export_file(".tscn") var tab_prefab_path: String

var is_available := false

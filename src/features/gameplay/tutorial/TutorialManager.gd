extends Control

class_name TutorialManager

@export var tuto_elements : Array[TutorialElement]

@export var _previous_button: Button
@export var _next_button: Button

@export var _tab_container: TabContainer

func start_tutorial(is_tutorial := false):
	if is_tutorial:
		_previous_button.disabled = true
		_connect_signals()
	else:
		for n in tuto_elements:
			var tuto_tab_prefab = load(n.tab_prefab_path)
			var tuto_tab = tuto_tab_prefab.instantiate()
			_tab_container.add_child(tuto_tab)
		_disable_buttons_if_extremities()

func _connect_signals() -> void:
	CharactersManager.on_characters_manager_initialized.connect(_on_characters_manager_initialized)
	_tab_container.tab_changed.connect(_on_tab_changed)
	InputManager.on_card_selected.connect(_on_card_selected)
	BattleStageManager.on_new_wave_started.connect(_on_new_wave)
	BattleStageManager.on_hand_combination_phase_started.connect(_on_hands_combinations_phase_started)
	FinalHandCalculator.on_pair_or_higher_combination.connect(_on_pair_or_higher_combination)
	BattleStageManager.on_targeting_phase_started.connect(_on_targeting_phase_started)
	BattleStageManager.on_player_won_wave.connect(_on_player_won_wave)

func _on_characters_manager_initialized() -> void:
	for n in CharactersManager.player_characters: 
		n.on_move_chosen.connect(_on_move_chosen)
		n.hand.on_card_discarded.connect(_on_card_discarded)
		n.status.on_status_added.connect(_on_status_added)
		n.on_character_performed_move.connect(_on_move_performed)
		n.ui.on_health_bar_updated.connect(_on_health_bar_updated)
	BattleStageManager.level_manager.hand_manipulations_manager.on_hand_manipulation_used.connect(_on_hand_manipulation_used)
	BattleStageManager.level_manager.rewards_manager.on_rewards_drafted.connect(_on_rewards_drafted)

func _on_tab_changed(_tab : int) -> void:
	_disable_buttons_if_extremities()

func _on_new_wave() -> void:
	_check_tuto_element(TutorialElement.TutoType.ON_NEW_WAVE)

func _on_card_discarded(_card: Card, _is_played) -> void:
	_check_tuto_element(TutorialElement.TutoType.ON_CARD_DISCARDED)

func _on_card_selected(_card: Card) -> void:
	_check_tuto_element(TutorialElement.TutoType.ON_CARD_SELECTED)

func _on_move_chosen(_move_name: String, _character_name: String) -> void:
	_check_tuto_element(TutorialElement.TutoType.ACTION_CHOSEN)

func _on_hands_combinations_phase_started() -> void:
	_check_tuto_element(TutorialElement.TutoType.HANDS_COMBINATION)

func _on_moves_solving_phase_started() -> void:
	_check_tuto_element(TutorialElement.TutoType.ACTIONS_SOLVING)

func _on_pair_or_higher_combination() -> void:
	_check_tuto_element(TutorialElement.TutoType.ON_PAIR_OR_HIGHER)

func _on_targeting_phase_started() -> void:
	_check_tuto_element(TutorialElement.TutoType.ON_TARGETING_PHASE)

func _on_hand_manipulation_used() -> void:
	_check_tuto_element(TutorialElement.TutoType.ON_MANIPULATION)

func _on_move_performed(_char : Character) -> void:
	_check_tuto_element(TutorialElement.TutoType.ACTION_PERFORMED)

func _on_status_added(_status, _caster) -> void:
	_check_tuto_element(TutorialElement.TutoType.ON_STATUS_ADDED)

func _on_player_won_wave() -> void:
	_check_tuto_element(TutorialElement.TutoType.ON_PLAYER_WON_WAVE)

func _on_rewards_drafted() -> void:
	_check_tuto_element(TutorialElement.TutoType.ON_REWARDS_DRAFTED)

func _on_health_bar_updated() -> void:
	_check_tuto_element(TutorialElement.TutoType.ON_HEALTH_BAR_UPDATED)

func _check_tuto_element(type : TutorialElement.TutoType) -> void:
	for i in tuto_elements.size():
		if tuto_elements[i].is_available or not tuto_elements[i].type.has(type): 
			continue
		var is_ready = true
		for n in tuto_elements[i].previous_elements:
			if not n.is_available:
				is_ready = false
		if not is_ready: continue
		tuto_elements[i].is_available = true
		await get_tree().create_timer(tuto_elements[i].delay).timeout
		var tuto_tab_prefab = load(tuto_elements[i].tab_prefab_path)
		var tuto_tab = tuto_tab_prefab.instantiate()
		_tab_container.add_child(tuto_tab)
		if not visible:
			show()
			_tab_container.current_tab = _tab_container.get_tab_idx_from_control(tuto_tab)
		if i + 1 < tuto_elements.size()  and tuto_elements[i + 1].type.has(TutorialElement.TutoType.NEXT):
			_check_tuto_element(TutorialElement.TutoType.NEXT)
		_disable_buttons_if_extremities()


func _display_previous_tuto_element() -> void:
	if _tab_container.current_tab > 0 : 
		_tab_container.current_tab += -1
		_disable_buttons_if_extremities()


func _display_next_tuto_element() -> void:
	if _tab_container.current_tab < _tab_container.get_tab_count() : 
		_tab_container.current_tab += 1
		_disable_buttons_if_extremities()


func _disable_buttons_if_extremities() -> void:
	_previous_button.disabled = _tab_container.current_tab == 0
	_next_button.disabled = _tab_container.current_tab == _tab_container.get_tab_count() - 1

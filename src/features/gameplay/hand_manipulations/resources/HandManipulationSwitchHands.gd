extends HandManipulationResource

class_name HandManipulationSwitchHands

var _character_1 : Character = null
var _character_2 : Character = null

func activate_hand_manipulation() -> void:
	super.activate_hand_manipulation()
	InputManager.on_character_clicked.connect(_on_character_clicked)
	InputManager.on_hand_clicked.connect(_on_hand_clicked)
	InputManager.on_card_clicked.connect(_on_card_clicked)

func _on_card_clicked(card: Card) -> void:
	switch_hands(card.owner_hand.owner_character)

func _on_hand_clicked(hand: Hand) -> void:
	switch_hands(hand.owner_character)

func _on_character_clicked(character: Character) -> void:
	switch_hands(character)

func switch_hands(character: Character) -> void:
	if _character_1 == null:
		_character_1 = character
		return
	if character == _character_1: return
	_character_2 = character
	var character_1_cards = _character_1.hand.current_cards.keys().duplicate()
	var character_2_cards = _character_2.hand.current_cards.keys().duplicate()
	for n in character_1_cards:
		_character_1.hand.current_cards_order.erase(n)
		_character_1.hand.current_cards.erase(n)
		_character_1.hand.current_selected_cards.erase(n)
		_character_1.hand.cards_holder.remove_child(n)
	for n in character_2_cards:
		_character_2.hand.current_cards_order.erase(n)
		_character_2.hand.current_cards.erase(n)
		_character_2.hand.current_selected_cards.erase(n)
		_character_2.hand.cards_holder.remove_child(n)
	for n in character_1_cards:
		_character_2.hand.current_cards_order.push_back(n)
		_character_2.hand.current_cards[n] = n.card_resource
		_character_2.hand.cards_holder.add_child(n)
		n.owner_hand = _character_2.hand
		n.is_locked = false
		n.mat.set_shader_parameter('is_selected', false)
		n.mat.set_shader_parameter('is_focus', false)
	for n in character_2_cards:
		_character_1.hand.current_cards_order.push_back(n)
		_character_1.hand.current_cards[n] = n.card_resource
		_character_1.hand.cards_holder.add_child(n)
		n.owner_hand = _character_1.hand
		n.is_locked = false
		n.mat.set_shader_parameter('is_selected', false)
		n.mat.set_shader_parameter('is_focus', false)
	_character_1.hand.reset_preview()
	_character_2.hand.reset_preview()
	super.use_hand_manipulation()


func disable_hand_manipulation() -> void:
	_character_1 = null
	_character_2 = null
	for n in InputManager.on_character_clicked.get_connections():
			if n["callable"] == _on_character_clicked: InputManager.on_character_clicked.disconnect(_on_character_clicked)
	for n in InputManager.on_hand_clicked.get_connections():
			if n["callable"] == _on_hand_clicked: InputManager.on_hand_clicked.disconnect(_on_hand_clicked)
	for n in InputManager.on_card_clicked.get_connections():
			if n["callable"] == _on_card_clicked: InputManager.on_card_clicked.disconnect(_on_card_clicked)
	super.disable_hand_manipulation()

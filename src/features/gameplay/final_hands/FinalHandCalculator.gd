extends Node

signal on_pair_or_higher_combination()

const _FINAL_HAND_CALCULATOR_DATA: FinalHandCalculatorData = preload("res://datas/resources/final_hand/d_final_hand_calculator_data.tres")

func get_final_hand(cards_resources: Array[CardResource], cards, character: Character) -> FinalHandData:
	var final_hand = FinalHandData.new(character)
	final_hand.cards = cards
	final_hand.cards_resources = cards_resources.duplicate(true)
	final_hand.hand_ranking = _calculate_ranking(final_hand)
	if final_hand.hand_ranking > Enums.HandRankings.HIGH_CARD: on_pair_or_higher_combination.emit()
	final_hand.available_suits = _calculate_available_suits(final_hand)
	final_hand.power = _calculate_power(final_hand)
	return final_hand

func _calculate_ranking(final_hand: FinalHandData) -> Enums.HandRankings:
	var amount_of_values = {}
	final_hand.suits_amount = {0:0, 1:0 , 2:0, 3:0}
	var highest_card = null
	var lowest_card = null
	var has_an_ace = false
	for n in final_hand.cards_resources:
		if amount_of_values.keys().has(n.value_id): amount_of_values[n.value_id] += 1
		else: amount_of_values[n.value_id] = 1
		final_hand.suits_amount[n.suit] += 1
		if n.value_id == 0: has_an_ace = true
		if highest_card == null or highest_card and n.value_id > highest_card.value_id: highest_card = n
		if lowest_card == null and not n.value_id == 0 or lowest_card and not n.value_id == 0 and n.value_id < lowest_card.value_id: lowest_card = n
	if has_an_ace:
			for n in final_hand.cards_resources:
				if n.value_id == 0: 
					if highest_card.value_id == 4: lowest_card = n
					else: highest_card = n
	
	var is_flush = false
	for n in final_hand.suits_amount.values():
		if n == 5:
			is_flush = true
			break
	
	for n in amount_of_values.keys():
		if amount_of_values[n] == 5:
			for card_resource in final_hand.cards_resources: final_hand.counting_cards[card_resource] = true
			return Enums.HandRankings.FIVE_OF_A_KIND if not is_flush else Enums.HandRankings.FIVE_OF_A_KIND_FLUSH
		elif amount_of_values[n] == 4:
			for card_resource in final_hand.cards_resources: final_hand.counting_cards[card_resource] = true if card_resource.value_id == n else false
			return Enums.HandRankings.FOUR_OF_A_KIND
		elif amount_of_values[n] == 3:
			if amount_of_values.values().has(2): 
				for card_resource in final_hand.cards_resources: final_hand.counting_cards[card_resource] = true
				return Enums.HandRankings.FULL_HOUSE if not is_flush else Enums.HandRankings.FULL_HOUSE_FLUSH
			else: 
				if is_flush: 
					final_hand.hand_ranking = Enums.HandRankings.FLUSH
					for card_resource in final_hand.cards_resources: final_hand.counting_cards[card_resource] = true
				else:
					for card_resource in final_hand.cards_resources: final_hand.counting_cards[card_resource] = true if card_resource.value_id == n else false
					return Enums.HandRankings.THREE_OF_A_KIND
	
	if amount_of_values.values().count(1) == 5:
		var is_straight = false
		var highest_value = highest_card.value_id if not highest_card.value_id == 0 else 13
		if highest_value - lowest_card.value_id == 4: is_straight = true
		
		if is_straight:
			if highest_value == 13: 
				for card_resource in final_hand.cards_resources: final_hand.counting_cards[card_resource] = true
				return Enums.HandRankings.ROYAL_FLUSH if is_flush else Enums.HandRankings.STRAIGHT
			else: 
				for card_resource in final_hand.cards_resources: final_hand.counting_cards[card_resource] = true
				return Enums.HandRankings.STRAIGHT_FLUSH if is_flush else Enums.HandRankings.STRAIGHT
	
	if is_flush: 
		for card_resource in final_hand.cards_resources: final_hand.counting_cards[card_resource] = true
		return Enums.HandRankings.FLUSH
	
	if amount_of_values.values().count(2) == 2: 
		for card_resource in final_hand.cards_resources: final_hand.counting_cards[card_resource] = true if amount_of_values[card_resource.value_id] == 2 else false
		return Enums.HandRankings.TWO_PAIR
	elif amount_of_values.values().count(2) == 1: 
		for card_resource in final_hand.cards_resources: final_hand.counting_cards[card_resource] = true if amount_of_values[card_resource.value_id] == 2 else false
		return Enums.HandRankings.PAIR
	else:
		for n in final_hand.cards_resources.size(): final_hand.counting_cards[final_hand.cards_resources[n]] = true if n == 0 else false
		return Enums.HandRankings.HIGH_CARD

func _calculate_available_suits(final_hand: FinalHandData) -> Array[Enums.Suits]:
	var dominant_colors: Array[Enums.Suits] = []
	final_hand.suits_amount = {0:0, 1:0 , 2:0, 3:0}
	for n in final_hand.counting_cards.keys():
		if final_hand.counting_cards[n] == true:
			final_hand.suits_amount[n.suit] += 1
	for n in final_hand.suits_amount:
		if final_hand.suits_amount[n] > 0:
			dominant_colors.push_back(n)
	return dominant_colors

func _calculate_power(final_hand: FinalHandData) -> float:
	var power = 0.0
	power += _FINAL_HAND_CALCULATOR_DATA.hand_rankings_values[final_hand.hand_ranking]
	for n in final_hand.counting_cards.keys():
		if final_hand.counting_cards[n] == true:
			power += n.value
	return power

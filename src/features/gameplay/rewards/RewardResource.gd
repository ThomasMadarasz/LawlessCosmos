extends BaseResource

class_name RewardResource

@export var name : String
@export var description : String
@export var texture : Texture2D
@export var rarity : Enums.Tiers = Enums.Tiers.BASE
@export var iteration: Enums.Iterations
@export var linked_character : Enums.PlayerCharacters
@export var is_unique := true
@export var max_stack := 1

var reward : Reward

var reward_description : String :
	get:
		var rarity_description = "\n" + "\n" + tr("RARITY") + " : " + tr(Enums.Tiers.keys()[rarity])
		if linked_character == Enums.PlayerCharacters.NONE:
			return replace_keys(formatted_description) + rarity_description
		else:
			var link_description = tr("REWARD_LINK") + Enums.PlayerCharacters.keys()[linked_character] + "\n" + "\n"
			return link_description + replace_keys(formatted_description) + rarity_description

var formatted_name: String :
	get:
		return _get_formatted_name()

var formatted_description : String :
	get:
		return _get_formatted_description()

func _get_formatted_name() -> String :
	var name_with_iteration = tr(name) + " " + Enums.Iterations.keys()[iteration].to_upper() if iteration > 0 else tr(name)
	return name_with_iteration

func _get_formatted_description() -> String:
	return tr(description)

func replace_keys(text : String) -> String:
	text = text.format(_key_strings)
	return text

var _suit_amount_string: String:
	get: return "[hint=%s][color=c400ff]%s[/color][/hint]"  % ["SUIT_AMOUNT_TOOLTIP", tr("SUIT_AMOUNT")]
var _efficiency_string: String:
	get: return "[hint=%s][color=yellow]%s[/color][/hint]" % ["EFFICIENCY_TOOLTIP", tr("EFFICIENCY")]
var _unused_cards_string: String:
	get: return "[hint=%s][color=green]%s[/color][/hint]" % ["UNUSED_CARDS_TOOLTIP", tr("UNUSED_CARDS")]
var _different_suits_amount_string: String:
	get: return "[hint=%s][color=orange]%s[/color][/hint]"  % ["DIFFERENT_SUITS_AMOUNT_TOOLTIP", tr("DIFFERENT_SUITS_AMOUNT")]

var suit_amount_value_string : String:
	get: return "[hint=%s][color=c400ff]%s[/color][/hint]"  % ["SUIT_AMOUNT_TOOLTIP", "%s"]
var efficiency_value_string : String:
	get: return "[hint=%s][color=yellow]%s[/color][/hint]" % [tr("EFFICIENCY_VALUE_TOOLTIP"), "%s"]
var efficiency_enemy_string : String:
	get: return "[hint=%s][color=yellow]%s[/color][/hint]" % ["ENEMY_MOVE_EFFICIENCY_TOOLTIP", "%s"]
var unused_cards_value_string: String:
	get: return "[hint=%s][color=green]%s[/color][/hint]" % ["UNUSED_CARDS_TOOLTIP", "%s"]
var different_suits_amount_value_string: String:
	get: return "[hint=%s][color=orange]%s[/color][/hint]"  % ["DIFFERENT_SUITS_AMOUNT_TOOLTIP", "%s"]

var _key_strings = {
	"SUIT_AMOUNT" : _suit_amount_string,
	"EFFICIENCY" : _efficiency_string,
	"UNUSED_CARDS" : _unused_cards_string,
	"DIFFERENT_SUITS_AMOUNT" : _different_suits_amount_string
	}

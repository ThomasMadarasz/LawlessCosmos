extends TextureRect

class_name CardPreviewUI

@export var _is_auto_enabled := false
@export var _base_value: int
@export var _base_suit: Enums.Suits

func _ready() -> void:
	self.material = self.material.duplicate(true)
	if _is_auto_enabled:
		_enable_preview(true)
		texture.region = Rect2(Card.CARD_WIDTH * _base_value, Card.CARD_HEIGHT * _base_suit, Card.CARD_WIDTH, Card.CARD_HEIGHT)

func _enable_preview(is_enabled: bool) -> void:
	if is_enabled: show()
	else: hide()

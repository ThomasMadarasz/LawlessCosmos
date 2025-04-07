extends Resource

class_name WaveData

@export var enemy_1 : EnemyCharacterResource
@export var enemy_2 : EnemyCharacterResource
@export var enemy_3 : EnemyCharacterResource

@export var is_boss_wave : bool

@export_category("Tutorial")
@export var deck_resource: DeckResource

var enemies: Array[EnemyCharacterResource]:
	get:
		return [enemy_1, enemy_2, enemy_3]

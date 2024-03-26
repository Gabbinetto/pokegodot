class_name GameMap extends Node2D

signal player_entered(map: GameMap, player: Player)
signal player_exited(map: GameMap, player: Player)

@export var map_area: Area2D
@export var map_id: String = "DEFAULT"
@export var map_name: String = "Mystery zone"
@export var neighbours: Array[GameMap]

func _ready() -> void:
	assert(is_instance_valid(map_area), "%s needs a map area" % name)
	map_area.body_entered.connect(func(body: CollisionObject2D):
		if body is Player:
			player_entered.emit(self, body)
	)
	map_area.body_exited.connect(func(body: CollisionObject2D):
		if body is Player:
			player_exited.emit(self, body)
	)

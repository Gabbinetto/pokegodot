class_name Map extends Node2D


signal map_entered(map: Map)
signal map_exited(map: Map)


@export var id: String = "DEFAULT"
@export var connections: Array[Map]
@export var area: Area2D


func _ready() -> void:
	name = id
	
	area.body_entered.connect(
		func(body: Node2D):
			if body == Globals.player:
				map_entered.emit(self)
	)
	area.body_exited.connect(
		func(body: Node2D):
			if body == Globals.player:
				map_exited.emit(self)
	)

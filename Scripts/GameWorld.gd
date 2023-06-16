extends Node2D
class_name GameWorld

@export var starting_map: GameMap

@onready var maps_container: Node = $Maps
@onready var maps: Array[Node] = maps_container.get_children()

var current_map: GameMap

func _ready() -> void:
	for map in maps:
		map.player_entered.connect(_load_map)
		map.player_exited.connect(_unload_map)
		maps_container.remove_child(map)
		
	maps_container.add_child(starting_map)

func _load_map(map: GameMap, player: Player) -> void:
	current_map = map
	for neighbour in map.neighbours:
		if neighbour.get_parent() == null:
			maps_container.add_child(neighbour)
	if map.get_parent() == null:
		maps_container.add_child(map)
	prints(map.map_id, "entered")

func _unload_map(map: GameMap, player: Player) -> void:
	for neighbour in map.neighbours:
		if !(neighbour in current_map.neighbours) or neighbour != current_map:
			maps_container.remove_child(neighbour)
	
	prints(map.map_id, "exited")

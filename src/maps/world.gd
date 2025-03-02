class_name World extends Node2D


@export var map_container: Node
@export var starting_map: Map

var maps: Array[Map]
var loaded_maps: Array[Map]


func _ready() -> void:
	Globals.game_world = self ## There can only be one game world

	for child: Node in map_container.get_children():
		if child is Map:
			maps.append(child)
			child.map_entered.connect(_on_map_entered)
	
	for map: Map in maps:
		if map != starting_map:
			unload_map(map)
		else:
			load_map(map)


func _on_map_entered(map: Map) -> void:
	for old_map: Map in loaded_maps:
		if not map.connections.has(old_map) and not old_map == map:
			unload_map(old_map)
	for connection: Map in map.connections:
		load_map(connection)


func load_map(map: Map) -> void:
	if not map_container.get_children().has(map):
		map_container.add_child.call_deferred(map)
	if not loaded_maps.has(map):
		loaded_maps.append(map)


func unload_map(map: Map) -> void:
	if map_container.get_children().has(map):
		map_container.remove_child.call_deferred(map)
	if loaded_maps.has(map):
		loaded_maps.erase(map)

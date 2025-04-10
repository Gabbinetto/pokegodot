class_name World extends Node2D


@export var map_container: Node
@export var instantiated_map_container: Node
@export var starting_map: Map

var maps: Array[Map]
var loaded_maps: Array[Map]
var current_map: Map
var instantiated_maps_ids: Array[String]
var instantiated_map: Map
var is_instantiated: bool:
	get: return instantiated_map != null


func _ready() -> void:
	Globals.game_world = self # There can only be one game world

	for child: Node in map_container.get_children():
		if child is Map:
			maps.append(child)
			child.map_entered.connect(_on_map_entered)
	
	for child: Node in instantiated_map_container.get_children():
		if child is Map:
			instantiated_maps_ids.append(child.id)
			child.queue_free()
	
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
	current_map = map


func get_map(id: String) -> Map:
	if instantiated_maps_ids.has(id):
		var scene: PackedScene = load(DB.instantiated_map_scenes[id])
		if not scene:
			push_error("Map ", id, " not found")
			return
		return scene.instantiate()
	for map: Map in maps:
		if map.id == id:
			return map
	return


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
	
	var check_current_map: Callable = func() -> void:
		if loaded_maps.is_empty():
			current_map = null
	check_current_map.call_deferred()


func instantiate_map(map: Map) -> void:
	dispose_map()
	
	if not instantiated_map_container.get_children().has(map):
		instantiated_map_container.add_child.call_deferred(map)
	if not is_instantiated:
		instantiated_map = map
		instantiated_map.map_entered.connect(_on_map_entered)
		set_meta("map_container_index", map_container.get_index())
		remove_child(map_container)
		instantiated_map_container.show()


func dispose_map() -> void:
	if is_instantiated:
		instantiated_map.queue_free()
		instantiated_map = null
		add_child(map_container)
		move_child(map_container, get_meta("map_container_index", 0))
		remove_meta("map_container_index")
		instantiated_map_container.hide()

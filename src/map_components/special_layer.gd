class_name SpecialMapLayer extends TileMapLayer

const GRASS_AREA: PackedScene = preload("res://src/map_components/grass_area.tscn")
const GRASS_DATA_LAYER: String = "grass"

@export var grass_encounters: Array[MapEncounter]
var grass_container: Node2D

func _ready() -> void:
	self_modulate.a = 0 # Make invisible (Disabling visibility would hide children)
	
	# Setup grass
	grass_container = Node2D.new()
	grass_container.name = "GrassContainer"
	add_child(grass_container)
	
	
	for coords: Vector2i in get_used_cells():
		var tile_data: TileData = get_cell_tile_data(coords)
		if tile_data.get_custom_data(GRASS_DATA_LAYER):
			var area: GrassArea = GRASS_AREA.instantiate()
			grass_container.add_child(area)
			area.name = "Grass%v" % coords
			area.position = coords * tile_set.tile_size
			area.encounters = grass_encounters

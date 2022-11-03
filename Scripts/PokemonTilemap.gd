extends TileMap
class_name PokemonTilemap

const SPECIAL_LAYER : = 0
const GrassArea = preload('res://Scenes/GrassArea.tscn')

var grass_areas : Node2D

func _ready() -> void:
	print(owner)
	
	grass_areas = Node2D.new()
	grass_areas.name = 'GrassAreas'
	grass_areas.position = Vector2(0, 0)
	add_child(grass_areas)
	
	for tile_coords in get_used_cells(SPECIAL_LAYER):
		var tile_data = get_cell_tile_data(SPECIAL_LAYER, tile_coords)
		if tile_data.get_custom_data('tall_grass'):
			_generate_grass_area(tile_coords)

func _generate_grass_area(grass_position : Vector2i):
	var area = GrassArea.instantiate()
	
	area.position = grass_position * GameVariables.TILE_SIZE
	area.z_index = 100
	area.connect('body_entered', owner._on_grass_entered)
	grass_areas.add_child(area)

@tool
extends TileMap
class_name PokemonTilemap

const SPECIAL_LAYER: = 0
const TILE_SET: = preload("res://Scenes/tileset.tres")
const GrassArea: = preload('res://Scenes/GrassArea.tscn')

var grass_areas: Node2D


func _ready() -> void:
	if Engine.is_editor_hint():
		_setup_layers()
		tile_set = TILE_SET
		return
	
	grass_areas = Node2D.new()
	grass_areas.name = 'GrassAreas'
	grass_areas.position = Vector2(0, 0)
	add_child(grass_areas)
	
	for tile_coords in get_used_cells(SPECIAL_LAYER):
		var tile_data = get_cell_tile_data(SPECIAL_LAYER, tile_coords)
		if tile_data.get_custom_data('tall_grass'):
			_generate_grass_area(tile_coords)
	
	set_layer_modulate(SPECIAL_LAYER, Color(0, 0, 0, 0))

func _setup_layers() -> void:
	# Setting the special layer
	set_layer_name(SPECIAL_LAYER, "Special")
	set_layer_modulate(SPECIAL_LAYER, Color(1, 0, 1))
	set_layer_z_index(SPECIAL_LAYER, -1)

	# Generating other layers
	add_layer(1)
	set_layer_name(1, "Ground")
	set_layer_z_index(1, 0)
	add_layer(2)
	set_layer_name(2, "Z-Index 1")
	set_layer_z_index(2, 1)
	for i in range(3, 6):
		add_layer(i)
		set_layer_name(i, "Z-Index %s" % i)
		set_layer_z_index(i, i)
		
	


func _generate_grass_area(grass_position: Vector2i):
	var area = GrassArea.instantiate()
	
	area.position = grass_position * GameVariables.TILE_SIZE
	area.z_index = 100
	area.connect('body_entered', owner._on_grass_entered)
	grass_areas.add_child(area)

class_name SpecialMapLayer extends TileMapLayer

const GRASS_AREA: PackedScene = preload("res://src/map_components/encounter_areas/grass_area.tscn")
const GRASS_DATA_LAYER: String = "grass"


@export var elevation: int = 0
@export var set_children_elevation: bool = true
@export_group("Wild pokemon")
@export var grass_encounters: EncounterPool
var grass_container: Node2D

func _ready() -> void:
	self_modulate.a = 0 # Make invisible (Disabling visibility would hide children)

	# Setup grass
	grass_container = Node2D.new()
	grass_container.name = "GrassContainer"
	add_child(grass_container)

	_setup_special_tiles()

	if set_children_elevation:
		_set_children_elevation.call_deferred(self)

	SignalRouter.elevation_changed.connect(_elevation_changed)



func _setup_special_tiles() -> void:
	for coords: Vector2i in get_used_cells():
		var tile_data: TileData = get_cell_tile_data(coords)
		if tile_data.get_custom_data(GRASS_DATA_LAYER):
			var area: EncounterArea = GRASS_AREA.instantiate()
			grass_container.add_child(area)
			area.name = "Grass%v" % coords
			area.position = coords * tile_set.tile_size
			area.pool = grass_encounters


func _set_children_elevation(node: Node) -> void:
	if node.get("elevation") != null:
		node.set("elevation", elevation)
	if node.get_child_count() == 0:
		return
	for child: Node in node.get_children():
		_set_children_elevation(child)


func _elevation_changed(new_elevation: int) -> void:
	enabled = elevation == new_elevation

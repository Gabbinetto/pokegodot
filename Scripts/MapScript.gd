extends Node2D
class_name GameMap

signal player_entered(map: GameMap, player: Player)
signal player_exited(map: GameMap, player: Player)

@onready var map_area: Area2D = $MapArea

@export var map_id: String = "DEFAULT"
@export var map_name: String = "Mystery zone"
@export var neighbours_paths: Array[NodePath]

@export_category('Wild encounters')
@export_group("Grass")
@export var grass_encounters : Array[WildPokemonData]
@export_range(0, 1, 0.001) var grass_encounter_chance : = 0.2

var neighbours: Array[GameMap]
var grass_pool : Array[Dictionary]

func _ready() -> void:
	assert(is_instance_valid(map_area), "%s needs a map area!" % name)
	map_area.body_entered.connect(func(body: CollisionObject2D):
		if body is Player:
			player_entered.emit(self, body)
	)
	map_area.body_exited.connect(func(body: CollisionObject2D):
		if body is Player:
			player_exited.emit(self, body)
	)
	
	
	for path in neighbours_paths:
		neighbours.append(get_node(path))
	
	for encounter in grass_encounters:
		grass_pool.append(GameFunctions.create_weighted_pool_element(encounter, encounter.chance))

func _on_grass_entered(_body):
	if randf() > grass_encounter_chance:
		return
	
	var random_pick : WildPokemonData = GameFunctions.weighted_random(grass_pool)
	var level : int = round(randf_range(random_pick.min_level, random_pick.max_level))
	var wild_pokemon : Pokemon = await GameFunctions.generate_random_pokemon(random_pick.pokemon_id.to_upper(), random_pick.form_number, level)

	
	GameFunctions.start_battle(wild_pokemon)

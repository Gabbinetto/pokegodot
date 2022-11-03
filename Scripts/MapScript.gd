extends Node2D
class_name GameMap

@export_category('Wild encounters')
@export var grass_encounters : Array[WildPokemonData]
@export_range(0, 1, 0.001) var grass_encounter_chance : = 0.2

var grass_pool : Array[Dictionary]

func _ready() -> void:
	for encounter in grass_encounters:
		grass_pool.append(GameFunctions.create_weighted_pool_element(encounter, encounter.chance))

func _on_grass_entered(_body):
	if randf() > grass_encounter_chance:
		return
	
	var random_pick : WildPokemonData = GameFunctions.weighted_random(grass_pool)
	var level : int = round(randf_range(random_pick.min_level, random_pick.max_level))
	var wild_pokemon : Pokemon = await GameFunctions.generate_random_pokemon(random_pick.pokemon_id.to_upper(), random_pick.form_number, level)

	
	GameFunctions.start_battle(wild_pokemon)

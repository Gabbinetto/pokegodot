extends Node

# Graphics paths
#const POKEMON_GRAPHICS_PATH: = "res://Graphics/Pokemon/"
const POKEMON_GRAPHICS_PATH: = "user://PokemonGraphics/"
const FRONT_SPRITES_PATH: = POKEMON_GRAPHICS_PATH + "Front/"
const BACK_SPRITES_PATH: = POKEMON_GRAPHICS_PATH + "Back/"
const ICONS_SPRITES_PATH: = POKEMON_GRAPHICS_PATH + "Icons/"
const SHINY_FRONT_SPRITES_PATH: = POKEMON_GRAPHICS_PATH + "Front shiny/"
const SHINY_BACK_SPRITES_PATH: = POKEMON_GRAPHICS_PATH + "Back shiny/"
const SHINY_ICONS_SPRITES_PATH: = POKEMON_GRAPHICS_PATH + "Icons shiny/"
const FOOTPRINTS_SPRITES_PATH: = POKEMON_GRAPHICS_PATH + "Footprints/"

# Map data
const TILE_SIZE: int = 32

# PBS data
var pokemons: = {}
var items: = {}
var abilities: = {}
var types: = {}
var forms: = {}
var moves: = {}

var type_chart: Array[Array] = [
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # NORMAL
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # FIGHTING
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # FLYING
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # POISON
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # GROUND
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # ROCK
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # BUG
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # GHOST
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # STEEL
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # QMARKS
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # FIRE
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # WATER
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # GRASS
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # ELECTRIC
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # PSYCHIC
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # ICE
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # DRAGON
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # DARK
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], # FAIRY
]

func _ready() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Dev/PBS.json"))
	pokemons = data.get("pokemon")
	items = data.get("items")
	abilities = data.get("abilities")
	types = data.get("types")
	forms = data.get("forms")
	moves = data.get("moves")
	
	# Setting the type chart
	for type_id in types:
		var type: Dictionary = types[type_id]
		if type.has("Weaknesses"):
			for weakness_id in type.Weaknesses.split(","):
				var weakness: Dictionary = types[weakness_id]
				type_chart[type.Index][weakness.Index] *= 2
		if type.has("Resistances"):
			for resistance_id in type.Resistances.split(","):
				var resistance: Dictionary = types[resistance_id]
				type_chart[type.Index][resistance.Index] *= 0.5
		if type.has("Immunities"):
			for immunity_id in type.Immunities.split(","):
				var immunity: Dictionary = types[immunity_id]
				type_chart[type.Index][immunity.Index] *= 0

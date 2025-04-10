extends Node

## Pokegodot's singleton for pokemon types.

## Enum with all the types. Must match type names in [member DB.types]. 
enum {
	NORMAL,
	FIGHTING,
	FLYING,
	POISON,
	GROUND,
	ROCK,
	BUG,
	GHOST,
	STEEL,
	QMARKS,
	FIRE,
	WATER,
	GRASS,
	ELECTRIC,
	PSYCHIC,
	ICE,
	DRAGON,
	DARK,
	FAIRY,
}

const WEAKNESS_MULTIPLIER: float = 2.0 ## Multiplier for weaknesses.
const RESISTANCE_MULTIPLIER: float = 0.5 ## Multiplier for resistances.
const IMMUNITY_MULTIPLIER: float = 0.0 ## Multiplier for immunities.
const ICONS: Dictionary[int, Texture2D] = {
	NORMAL: preload("res://assets/resources/type_textures/normal.tres"),
	FIGHTING: preload("res://assets/resources/type_textures/fighting.tres"),
	FLYING: preload("res://assets/resources/type_textures/flying.tres"),
	POISON: preload("res://assets/resources/type_textures/poison.tres"),
	GROUND: preload("res://assets/resources/type_textures/ground.tres"),
	ROCK: preload("res://assets/resources/type_textures/rock.tres"),
	BUG: preload("res://assets/resources/type_textures/bug.tres"),
	GHOST: preload("res://assets/resources/type_textures/ghost.tres"),
	STEEL: preload("res://assets/resources/type_textures/steel.tres"),
	QMARKS: preload("res://assets/resources/type_textures/qmarks.tres"),
	FIRE: preload("res://assets/resources/type_textures/fire.tres"),
	WATER: preload("res://assets/resources/type_textures/water.tres"),
	GRASS: preload("res://assets/resources/type_textures/grass.tres"),
	ELECTRIC: preload("res://assets/resources/type_textures/electric.tres"),
	PSYCHIC: preload("res://assets/resources/type_textures/psychic.tres"),
	ICE: preload("res://assets/resources/type_textures/ice.tres"),
	DRAGON: preload("res://assets/resources/type_textures/dragon.tres"),
	DARK: preload("res://assets/resources/type_textures/dark.tres"),
	FAIRY: preload("res://assets/resources/type_textures/fairy.tres"),
}

## The amount of types.
var count: int:
	get: return FAIRY + 1 # FAIRY should be the last type
var names: Dictionary[int, String] = {} ## Type names.
var _chart: Dictionary[int, Dictionary] = {}

func _ready() -> void:
	for type_1: int in count:
		_chart[type_1] = {}
		for type_2: int in count:
			_chart[type_1][type_2] = 1.0
	
	for type: String in DB.types:
		var type_enum: int = get(type)
		_chart[type_enum] = _chart.get(type_enum, {})
		
		var data: Dictionary[String, Variant]
		data.assign(DB.types[type])
		names[type_enum] = data.name
		for id: int in data.weaknesses:
			_chart[type_enum][id] = WEAKNESS_MULTIPLIER
		for id: int in data.resistances:
			_chart[type_enum][id] = RESISTANCE_MULTIPLIER
		for id: int in data.immunities:
			_chart[type_enum][id] = IMMUNITY_MULTIPLIER


## Gets the type effectiveness between two types as a multiplier (E.g. Fire is 1/4x effective on Water/rock, so 0.25).
func get_interaction(attacking: int, defending: Variant) -> float:
	var interaction: = 1.0
	if defending is int:
		interaction *= _chart[defending][attacking]
	elif defending is Array:
		for type: int in defending:
			interaction *= _chart[type][attacking]
	return interaction

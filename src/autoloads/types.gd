extends Node

## Pokegodot's singleton for pokemon types.

## Enum with all the types. Must match type names in [member DB.types]. 
enum List {
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


var names: Dictionary[List, String] = {} ## Type names.
var _chart: Dictionary[List, Dictionary] = {}

func _ready() -> void:
	for type_1: List in List.values():
		_chart[type_1] = {}
		for type_2: List in List.values():
			_chart[type_1][type_2] = 1.0
	
	for type: String in DB.types:
		var type_enum: List = List[type]
		_chart[type_enum] = _chart.get(type_enum, {})
		
		var data: Dictionary[String, Variant]
		data.assign(DB.types[type])
		names[type_enum] = data.name
		for id: List in data.weaknesses:
			_chart[type_enum][id] = WEAKNESS_MULTIPLIER
		for id: List in data.resistances:
			_chart[type_enum][id] = RESISTANCE_MULTIPLIER
		for id: List in data.immunities:
			_chart[type_enum][id] = IMMUNITY_MULTIPLIER


## Gets the type effectiveness between two types as a multiplier (E.g. Fire is 1/4x effective on Water/rock, so 0.25).
func get_interaction(attacking: List, defending: Variant) -> float:
	var interaction: = 1.0
	if defending is List:
		interaction *= _chart[defending][attacking]
	elif defending is Array:
		for type: List in defending:
			interaction *= _chart[type][attacking]
	return interaction

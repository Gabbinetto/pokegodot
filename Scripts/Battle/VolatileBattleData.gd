extends Resource
class_name VolatileBattleData

var pokemon : Pokemon

var ATTACK : = 0
var DEFENSE : = 0
var SPECIAL_ATTACK : = 0
var SPECIAL_DEFENSE : = 0
var SPEED : = 0

var boosts : = {
	'ATTACK': 0,
	'DEFENSE': 0,
	'SPECIAL_ATTACK': 0,
	'SPECIAL_DEFENSE': 0,
	'SPEED': 0,
	'ACCURACY': 0,
	'EVASION': 0,
	'CRITICAL_CHANCE': 0,
}

var type_1 : = '???'
var type_2  = null
var type_3  = null # Used only for moves like Trick-or-treat and Forest's curse

var ability = null

var substitute_hp : = 0 # If this is greater than 0 it means that a substitute is up

var locked_moves : Array[bool] = [false, false, false, false] # Locked move slots for moves like Disable

var volatile_statuses : = [] # For statuses like confusion, infatuation...

func _init(_pokemon : Pokemon) -> void:
	pokemon = _pokemon
	
	for stat in pokemon.stats.keys():
		set(stat, pokemon.stats.get(stat, 0))

	type_1 = pokemon.species.type_1
	type_2 = pokemon.species.type_2
	
	ability = pokemon.ability

func get_stat_boost(stat : String):
	var stage : int = boosts[stat]
	
	if stat == 'CRITICAL_CHANCE':
		match stage:
			0: return 1.0 / 24.0
			1: return 1.0 / 8.0
			2: return 1.0 / 2.0
			_: return 1.0 / 1.0
	
	var factor : = 3.0 if stat in ['ACCURACY', 'EVASION'] else 2.0
	
	var numerator : = factor if stage <= 0 else factor + stage
	var denominator : = factor if stage >= 0 else factor - stage

	return numerator / denominator

# If raw_stat is true then return the raw stat with no boost
func get_stat(stat : String, raw_stat : bool = false):
	if raw_stat:
		return get(stat.to_upper())
	
	return get(stat.to_upper()) * get_stat_boost(stat.to_upper())

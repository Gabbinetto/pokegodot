class_name BattlePokemon extends Resource

## Class that holds the data for a pokemon during battle.
##
## Used for temporary pokemon data during battle, mainly volatile
## effects such as confusion, substitute... But also stat changes.

var pokemon: Pokemon ## The pokemon bound to this class.
var trainer: BattleTrainer ## This pokemon's trainer.
var species: PokemonSpecies: ## Shorthand for [member Pokemon.species]
	get: return pokemon.species
	set(value): pokemon.species = value
var name: String: ## Shorthand for [member Pokemon.name]
	get: return pokemon.name
	set(value): pokemon.name = value
var hp: int: ## Shorthand for [member Pokemon.hp]
	get: return pokemon.hp
	set(value): pokemon.hp = value
var max_hp: int: ## Shorthand for [member Pokemon.max_hp]
	get: return pokemon.max_hp
	set(value): pokemon.max_hp = value
var attack: int: ## Shorthand for [method get_stat] with the attack stat.
	get: return get_stat(Globals.STATS.ATTACK)
	set(value): pokemon.attack = value
var defense: int: ## Shorthand for [method get_stat] with the defense stat.
	get: return get_stat(Globals.STATS.DEFENSE)
	set(value): pokemon.defense = value
var spattack: int: ## Shorthand for [method get_stat] with the special attack stat.
	get: return get_stat(Globals.STATS.SPECIAL_ATTACK)
	set(value): pokemon.spattack = value
var spdefense: int: ## Shorthand for [method get_stat] with the special defense stat.
	get: return get_stat(Globals.STATS.SPECIAL_DEFENSE)
	set(value): pokemon.spdefense = value
var speed: int: ## Shorthand for [method get_stat] with the speed stat.
	get: return get_stat(Globals.STATS.SPEED)
	set(value): pokemon.speed = value
var raw: Dictionary[String, int]: ## Shorthand for [member Pokemon.stats]. Mainly used to ignore stat boosts.
	get: return pokemon.stats
	set(value): pokemon.stats = value

var level: int: ## Shorthand for [member Pokemon.level]
	get: return pokemon.level
	set(value): pokemon.level = value
var boosts: Dictionary[String, int] = { ## Stat boosts.
	Globals.STATS.ATTACK: 0,
	Globals.STATS.DEFENSE: 0,
	Globals.STATS.SPECIAL_ATTACK: 0,
	Globals.STATS.SPECIAL_DEFENSE: 0,
	Globals.STATS.SPEED: 0,
}

func _init(_pokemon: Pokemon, _trainer: BattleTrainer) -> void:
	pokemon = _pokemon
	trainer = _trainer


## Returns a [param stat], accounting for stat boosts.
func get_stat(stat: String) -> int:
	if boosts[stat] > 0:
		return floor(raw[stat] * (float(2 + boosts[stat]) / 2.0))
	elif boosts[stat] < 0:
		return floor(raw[stat] * (2.0 / float(2 + boosts[stat])))
	else:
		return raw[stat]


## Adds a stat boost to the pokemon. Limits between its maximum and minimum,
## defined by [member Globals.MAX_BOOST] and [member Globals.MAX_OTHER_BOOST].
## If the [param stat] is already at its max/min, returns [code]false[/code], else [code]true[/code].
func add_boost(stat: String, amount: int) -> bool:
	var max: int = Globals.MAX_OTHER_BOOST if Globals.OTHER_STATS.values().has(stat) else Globals.MAX_BOOST
	if boosts[stat] >= max or boosts[stat] <= -max:
		return false
	boosts[stat] = clampi(boosts[stat], -max, max)
	return true


## Same as using [code]add_boost(stat, -amount)[/code].
func remove_boost(stat: String, amount: int) -> bool:
	return add_boost(stat, -amount)

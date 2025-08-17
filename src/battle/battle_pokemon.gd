class_name BattlePokemon extends Resource

## Class that holds the data for a pokemon during battle.
##
## Used for temporary pokemon data during battle, mainly volatile
## effects such as confusion, substitute... But also stat changes.

var battle: Battle

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
	Globals.OTHER_STATS.ACCURACY: 0,
	Globals.OTHER_STATS.EVASIVENESS: 0,
	Globals.OTHER_STATS.CRITICAL: 0,
}

func _init(_battle: Battle, _pokemon: Pokemon, _trainer: BattleTrainer) -> void:
	battle = _battle
	pokemon = _pokemon
	trainer = _trainer


## Damages this pokemon, substracting [param amount] from [member hp].
## If this pokemon faints, [method Battle.add_exp] will be called on [member battle].
func apply_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		battle.pokemon_fainted(self)


## Returns a [param stat], accounting for stat boosts.
func get_stat(stat: String) -> int:
	if boosts[stat] > 0:
		return floor(raw[stat] * (float(2 + boosts[stat]) / 2.0))
	elif boosts[stat] < 0:
		return floor(raw[stat] * (2.0 / float(2 + abs(boosts[stat]))))
	else:
		return raw[stat]


## Adds a stat boost to the pokemon. Limits between its maximum and minimum,
## defined by [member Globals.MAX_BOOST] and [member Globals.MAX_OTHER_BOOST].
## If the [param stat] is already at its max/min, returns [code]false[/code], else [code]true[/code]. [br][br]
## [b]NOTE[/b]: Does not play animations, only meant to be used in [method add_boosts].
func add_boost(stat: String, amount: int) -> bool:
	var max_boost: int = Globals.MAX_OTHER_BOOST if Globals.OTHER_STATS.values().has(stat) else Globals.MAX_BOOST
	if boosts[stat] >= max_boost or boosts[stat] <= -max_boost:
		return false
	boosts[stat] = clampi(boosts[stat] + amount, -max_boost, max_boost)
	return true


## Same as using [code]add_boost(stat, -amount)[/code].
func remove_boost(stat: String, amount: int) -> bool:
	return add_boost(stat, -amount)


func add_boosts(stat_changes: Dictionary[String, int]) -> void:
	var boost_happened: int = 0b000
	for stat: String in stat_changes:
		if stat_changes[stat] == 0:
			continue
		if add_boost(stat, stat_changes[stat]):
			boost_happened |= 0b001
			if stat_changes[stat] > 0:
				boost_happened |= 0b010
			else:
				boost_happened |= 0b100
		else:
			battle.show_text("%s's %s can't go %s!" % [
				name, stat.capitalize(), "lower" if stat_changes[stat] < 1 else "higher"
			])
	if boost_happened & 0b010 > 0:
		var up_animation: BattleAnimation = BattleAnimation.get_animation("stat_changes/stat_up", [battle.sprites[battle.get_slot(self)]], battle)
		battle.play_animation(up_animation)
		for stat: String in stat_changes:
			battle.show_text("%s's %s raises!" % [name, stat.capitalize()])
	if boost_happened & 0b100 > 0:
		var down_animation: BattleAnimation = BattleAnimation.get_animation("stat_changes/stat_down", [battle.sprites[battle.get_slot(self)]], battle)
		battle.play_animation(down_animation)
		for stat: String in stat_changes:
			battle.show_text("%s's %s drops!" % [name, stat.capitalize()])
	
	await battle.last_buffer_ran


static func get_accuracy_multiplier(accuracy: int, evasion: int) -> float:
	var total: int = accuracy - evasion
	if total == 0:
		return 1.0
	elif total < 0:
		return 3.0 / (3.0 + abs(total))
	else:
		return (3.0 + abs(total)) / 3.0

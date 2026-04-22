class_name DamageCalculation extends RefCounted

## Class used to hold values for damage calculations.
##
## As [BattleEffect]s work through callbacks, this allows to pass a reference to the
## damage calculation without depending too much on dictionaries.[br][br]
## The data is set outside of the class, in [method BattleServer.damage_calc].

var attack_stat: String ## The used attack stat.
var defense_stat: String ## The used defense stat.
var move: PokemonMove ## The used move.
var attacker: BattlePokemon ## The pokemon who attacks.
var target: BattlePokemon ## The pokemon who gets attacked.
var random: float = 1.0 ## The 15% random damage fluctuation.
var critical_multiplier: float = 1.0 ## Equals to [member Globals.CRITICAL_MULTIPLIER] when a critical hit lands.
var targets_multiplier: float = 1.0 ## Equals to [member Globals.MULTIPLE_TARGETS_MULTIPLIER] when there's more than one target.
var weather_multiplier: float = 1.0 ## Increases the move's power with a favorable weather.
var type_multiplier: float = 1.0 ## The multiplier for type interactions.
var stab_multiplier: float = 1.0 ## The multiplier for stab.
var other_multipliers: float = 1.0 ## Misc multipliers, often used by [BattleEffect]s.
var miss: bool = false ## True if missed.

## Calculates the values based on the data.
func value() -> int:
	if type_multiplier == 0.0 or move.category == PokemonMove.Categories.STATUS or miss:
		return 0
	var a: float = float(attacker.get_stat(attack_stat))
	var d: float = float(target.get_stat(defense_stat))
	if critical_multiplier > 1.0:
		if attacker.boosts[attack_stat] < 0:
			a = attacker.raw[attack_stat]
		if attacker.boosts[attack_stat] > 0:
			d = target.raw[defense_stat]
	var damage: float = roundf((roundf(2.0 * attacker.level / 5.0) + 2.0) * move.power * roundf(a / d) / 50.0) + 2
	damage = damage * random * critical_multiplier * targets_multiplier * weather_multiplier * type_multiplier * stab_multiplier * other_multipliers
	return max(floori(damage), 1)

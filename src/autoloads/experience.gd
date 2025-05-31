extends Node

## Pokegodot EXP calculation.
##
## Singleton to calculate experience points. The formulas are taken from [url]https://bulbapedia.bulbagarden.net/wiki/Experience[/url]

## The different types of growth rates.
enum GrowthRates {
	FAST,
	MEDIUM_FAST,
	SLOW,
	MEDIUM_SLOW,
	ERRATIC,
	FLUCTUATING,
}

const MAX_LEVEL: int = 100 ## Max level pokemon can reach.

## Pre-calculated tables for every growth rate.
var tables: Dictionary[GrowthRates, Array] = {
	GrowthRates.FAST: [] as Array[int],
	GrowthRates.MEDIUM_FAST: [] as Array[int],
	GrowthRates.SLOW: [] as Array[int],
	GrowthRates.MEDIUM_SLOW: [] as Array[int],
	GrowthRates.ERRATIC: [] as Array[int],
	GrowthRates.FLUCTUATING: [] as Array[int],
}


func _init() -> void:
	for rate: GrowthRates in GrowthRates.values():
		for level: int in range(1, MAX_LEVEL + 1):
			tables[rate].append(calculate_exp(level, rate))


## Returns the experience needed for a specific [param level] given a [param growth_rate]. [br]
## If [param level] is negative, it is subtracted from [constant MAX_LEVEL]. [br]
## If out of range (0 or greater than [constant MAX_LEVEL]), returns -1.
func get_exp_at_level(level: int, growth_rate: GrowthRates) -> int:
	if level < 0:
		level = MAX_LEVEL - level
	elif level > MAX_LEVEL or level == 0:
		push_error("Level %d is not in the range [1, MAX_LEVEL %d]. Check if the input is correct or use calculate_exp()." % [level, MAX_LEVEL])
		return -1
	return tables[growth_rate][level - 1]


## Returns the level a pokemon would be at with a specific amount of [param experience] given a [param growth_rate].[br]
## If [param experience] is negative, it is subtracted from the experience needed to be at [constant MAX_LEVEL]. [br]
## If [param experience] is greater than the amount needed for [constant MAX_LEVEL], the function will
## return [constant MAX_LEVEL], but it will also push an error.
func get_level_at_exp(experience: int, growth_rate: GrowthRates) -> int:
	if experience < 0:
		experience = tables[growth_rate][MAX_LEVEL - 1]
	elif experience > tables[growth_rate][MAX_LEVEL - 1]:
		push_error("Exp %d is over the max exp for growth rate %s" % [experience, GrowthRates.find_key(growth_rate)])
		return MAX_LEVEL
	var level: int = 1
	for i: int in MAX_LEVEL:
		var current: int = tables[growth_rate][i]
		if experience >= current:
			level = i + 1
		else:
			break
	return level


## Calculates the exp yield given the parameters.
## From [url=https://bulbapedia.bulbagarden.net/wiki/Experience#Gain_formula]the formula on Bulbapedia[/url].[br][br]
## [param base] is the base exp yield of a Pokemon.[br]
## [param target_level] is the level of the Pokemon gaining experience.
## [param defeated_level] is the level of the defeated/caught Pokemon yielding the exp.[br]
## [param participated] is true if the Pokemon fought in the battle. If not, [i]s[/i] (Check the formula on Bulbapedia) will be 2.[br]
## [param multipliers] is a list of multipliers coming from factors such as Lucky Egg or traded boost.
func exp_yield(base: int, target_level: int, defeated_level: int, participated: bool, multipliers: Array[float]) -> int:
	var s: float = 1.0 if participated else 2.0
	var multiplier_value: float = 1.0
	for val: float in multipliers:
		multiplier_value *= val

	return floori(
		(
			(base * defeated_level / 5.0) * (1.0 / s) * pow(((2 * defeated_level) + 10.0) / float(defeated_level + target_level + 10), 2.5) + 1
		) * multiplier_value
	)





## Shortand for every possible growth rate.
func calculate_exp(n: int, rate: GrowthRates) -> int:
	if n <= 1:
		return 0
	match rate:
		GrowthRates.FAST:
			return fast(n)
		GrowthRates.MEDIUM_FAST:
			return medium_fast(n)
		GrowthRates.SLOW:
			return slow(n)
		GrowthRates.MEDIUM_SLOW:
			return medium_slow(n)
		GrowthRates.ERRATIC:
			return erratic(n)
		GrowthRates.FLUCTUATING:
			return fluctuating(n)
		_:
			return 0


## Calculate fast growth rates
func fast(n: int) -> int:
	return floori((4.0 * (n ** 3.0)) / 5.0)


## Calculate medium fast growth rates
func medium_fast(n: int) -> int:
	return n ** 3


## Calculate slow rates
func slow(n: int) -> int:
	return floori((5.0 * (n ** 3.0)) / 4.0)

## Calculate medium slow growth rates
func medium_slow(n: int) -> int:
	return floori(
		(6.0 / 5.0) * (n ** 3.0) - 15.0 * (n ** 2) + 100.0 * n - 140.0
	)

## Calculate erratic growth rates
func erratic(n: int) -> int:
	if n < 50:
		return floori(
			(n ** 3.0) * (100.0 - n) / 50.0
		)
	elif n < 68:
		return floori(
			(n ** 3.0) * (150.0 - n) / 100.0
		)
	elif n < 98:
		return floori(
			(n ** 3.0) * floorf((1911.0 - 10.0 * n) / 3.0) / 500.0
		)
	else:
		return floori(
			(n ** 3.0) * (160.0 - n) / 100.0
		)

## Calculate fluctuating growth rates
func fluctuating(n: int) -> int:
	if n < 15:
		return floori(
			(n ** 3.0) * (floorf((n + 1.0) / 3.0) + 24.0) / 50.0
		)
	elif n < 36:
		return floori(
			(n ** 3.0) * (n + 14.0) / 50.0
		)
	else:
		return floori(
			(n ** 3.0) * (floorf(n / 2.0) + 32.0) / 50.0
		)

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

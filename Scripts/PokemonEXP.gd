class_name PokemonEXP extends Node

enum GrowthRates { Fast, Medium, Slow, Parabolic, Erratic, Fluctuating }

static func erratic(n: int):
	if n < 50:
		return int(((n ** 3) * (100 - n)) / 50.0)
	elif n < 68:
		return int(((n ** 3) * (150 - n)) / 100.0)
	elif n < 98:
		return int(((n ** 3) * ((1911 - 10 * n) / 3.0)) / 500.0)
	else:
		return int(((n ** 3) * (160 - n)) / 100.0)


static func fast(n: int):
	return int((4 * (n ** 3)) / 5.0)


static func medium_fast(n: int):
	return n ** 3


static func medium_slow(n: int):
	return (6.0 / 5.0) * (n ** 3) - 15 * (n ** 2) + 100 * n - 140


static func slow(n: int):
	return int((5 * (n ** 3)) / 4.0)


static func fluctuating(n: int):
	if n < 15:
		return int(((n ** 3) * (((n + 1) / 3.0) + 24)) / 50.0)
	elif n < 36:
		return int(((n ** 3) * (n + 14)) / 50.)
	else:
		return int(((n ** 3) * ((n / 2.0) + 32)) / 50.0)

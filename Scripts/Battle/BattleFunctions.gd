extends Node

# Based of Bulbapedia's formula: https://bulbapedia.bulbagarden.net/wiki/Damage#Generation_V_onward
func damage_calculation(move : PokemonMove, attacker : VolatileBattleData, defender : VolatileBattleData, weather = null, critical_boost = 0,  targets = 1.0, PB = 1.0, other = 1.0, z_move = 1.0):
	if move.category == 'STATUS':
		return 0
	
	# Compute critical hit
	var critical : = 1.0
	var crit_chance : = 0.0
	match critical_boost:
		0:
			crit_chance = 1.0 / 24.0
		1:
			crit_chance = 1.0 / 8.0
		2:
			crit_chance = 1.0 / 2.0
		_:
			crit_chance = 1.0
	critical = 1.5 if randf() <= crit_chance else 1.0
	if defender.ability in ['BATTLEARMOR', 'SHELLARMOR']:
		critical = 1.0
	
	# Compute the first factor (the one in the parenthesis on Bulbapedia)
	var attacking_stat = 'ATTACK' if move.category == 'PHYSICAL' else 'SPECIAL_ATTACK'
	var defensive_stat = 'DEFENSE' if move.category == 'PHYSICAL' else 'SPECIAL_DEFENSE'
	var A = attacker.get_stat(attacking_stat, critical != 1 and attacker.boosts.get(attacking_stat) < 0)
	var D = defender.get_stat(defensive_stat, critical != 1 and attacker.boosts.get(defensive_stat) < 0)
	
	var factor_1 = (((((2 * attacker.pokemon.level) / 5) + 2) * move.base_power * (A / D)) / 50) + 2
	
	# Compute same type attack bonus
	var stab = 1.5 if (move.type == attacker.type_1 or move.type == attacker.type_2 or move.type == attacker.type_3) else 1.0
	
	# Computes the burn factor (Sorry if it's so long)
	var burn = 0.25 if (attacker.pokemon.status == 'Burn' and attacker.ability != 'GUTS' and move.move_effect != 'DoublePowerIfUserPoisonedBurnedParalyzed' and move.category == 'PHYSICAL') else 1.0

	# Weather boost. If weather is Strong Winds then remove flying type weaknessessss
	var weather_boost : = 1.0
	if (weather == GameVariables.WEATHERS.RAIN and move.type == 'WATER') or (weather == GameVariables.WEATHERS.SUN and move.type == 'FIRE'):
		weather_boost = 2.0
	elif (weather == GameVariables.WEATHERS.RAIN and move.type == 'FIRE') or (weather == GameVariables.WEATHERS.SUN and move.type == 'WATER'):
		weather_boost = 0.5
	
	var random = randf_range(0.85, 1.0)

	
	var effectiveness = type_effectiveness(move.type, defender.type_1, defender.type_2, defender.type_3)
	
	return floor(factor_1 * PB * weather_boost * critical * random * stab * effectiveness * burn * other * z_move * 1.0) # Last one should be targets

func type_effectiveness(attacking : String, defending_1 : String, defending_2 = null, defending_3 = null, type_chart : = GameVariables.TYPE_CHART.duplicate()):
	if attacking == '???':
		return 1.0
	
	var att_index = GameVariables.TYPES_INDEX[attacking]
	var def_1_index = GameVariables.TYPES_INDEX[defending_1]
	var def_2_index : = -1
	if defending_2 != null:
		def_2_index = GameVariables.TYPES_INDEX[defending_2]
	var def_3_index : = -1
	if defending_3 != null:
		def_3_index = GameVariables.TYPES_INDEX[defending_3]
	
	var multiplier_1 = type_chart[att_index][def_1_index]
	var multiplier_2 = type_chart[att_index][def_2_index] if def_2_index != -1 else 1.0
	var multiplier_3 = type_chart[att_index][def_3_index] if def_3_index != -1 else 1.0

	return multiplier_1 * multiplier_2 * multiplier_3

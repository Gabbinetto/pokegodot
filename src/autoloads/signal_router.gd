extends Node

## Signal routing singleton
##
## Makes accessing and connecting signals between nodes much easier.

signal battle_step(battle: Battle, step: Battle.BattleSteps, data: Dictionary[String, Variant])
signal battle_ended(battle: Battle)

signal pokemon_level_up(pokemon: Pokemon)

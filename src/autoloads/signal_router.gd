extends Node

## Signal routing singleton
##
## Makes accessing and connecting signals between nodes much easier.

@warning_ignore_start("unused_signal")
signal battle_step(battle: Battle, step: Battle.BattleSteps, data: Dictionary[String, Variant])
signal battle_ended(battle: Battle)

signal pokemon_level_up(pokemon: Pokemon)

signal elevation_changed(new_elevation: int)

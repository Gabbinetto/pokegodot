extends Node


signal battle_step(battle: Battle, step: Battle.BattleSteps, data: Dictionary[String, Variant])
signal battle_ended(battle: Battle)

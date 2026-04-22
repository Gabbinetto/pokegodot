extends Node

## Signal routing singleton
##
## Makes accessing and connecting signals between nodes much easier.

@warning_ignore_start("unused_signal")
signal battle_step(battle: BattleServer, step: BattleServer.BattleSteps, data: Dictionary[String, Variant])
signal battle_ended(battle: BattleServer)
signal battle_client_received(data: Dictionary[String, Variant])
signal battle_server_received(data: Dictionary[String, Variant])

signal pokemon_level_up(pokemon: Pokemon)

signal elevation_changed(new_elevation: int)


func notify_battle_clients(data: Dictionary[String, Variant]) -> void:
	SignalRouter.battle_client_received.emit(data)


func notify_battle_server(data: Dictionary[String, Variant]) -> void:
	SignalRouter.battle_server_received.emit(data)

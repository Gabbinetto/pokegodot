@tool
extends Control

const PKDebug: GDScript = preload("res://addons/pkdebug/pkdebug.gd")

@export var battle_pokemon_explorers: Array[Control]
@export var update_timer: Range

var plugin: PKDebug

func setup(parent_plugin: PKDebug) -> void:
	plugin = parent_plugin

	for slot: Control in battle_pokemon_explorers:
		slot.setup(plugin)
	
	plugin.debugger.battle_update.connect(_on_battle_update)
	update_timer.value_changed.connect(
		func(value: float): plugin.send_message("set_battle_timer", [value])
	)


func _on_battle_update(data: Array[Dictionary]) -> void:
	for i: int in data.size():
		if data[i].is_empty():
			battle_pokemon_explorers[i].hide()
			continue
		battle_pokemon_explorers[i].update(data[i])
		battle_pokemon_explorers[i].show()
extends State


@export var battle: Battle


func enter() -> void:
	battle.end_battle()

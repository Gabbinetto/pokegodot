extends State


@export var battle: BattleServer


func enter() -> void:
	battle.close()

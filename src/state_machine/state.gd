class_name State extends Node

@warning_ignore("unused_signal")
signal transition(state: State, new_state_name: String)


func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func input(_event: InputEvent) -> void:
	pass


func unhandled_input(_event: InputEvent) -> void:
	pass

extends State


@export var battle: Battle


func enter() -> void:
	await get_tree().create_timer(0.1).timeout

	transition.emit(self, "ActionSelection")

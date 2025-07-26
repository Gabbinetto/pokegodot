@tool
class_name StairEvent extends Event


@export var elevation_delta: int = 1


func _run() -> void:
	Globals.player.elevation += elevation_delta

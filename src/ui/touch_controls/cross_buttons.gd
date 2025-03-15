@tool
class_name CrossButtons extends Node2D

const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

@export var buttons: Array[Node2D] = [null, null, null, null] ## The buttons to order. Should be clockwise starting from UP.
@export var distance: float = 46.0
@export var buttons_size: Vector2i = Vector2i.ONE
@export_tool_button("Set positions", "Marker2D")
var set_positions_button: Callable = set_positions

func set_positions() -> void:
	for i: int in 4:
		var dir: Vector2i = DIRECTIONS[i]
		var button: Node2D = buttons[i]
		var pos: Vector2 = Vector2(dir) * distance - (Vector2(buttons_size) / 2)
		if button:
			button.position = pos

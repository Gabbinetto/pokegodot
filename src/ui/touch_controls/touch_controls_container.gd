class_name TouchControlsContainer extends Control


@export var viewport: Control
var nodes: Array[Node2D]
var offsets: Dictionary[Node2D, Vector2]


func _ready() -> void:
	for node: Node in get_children():
		if node is Node2D:
			nodes.append(node)
	
	for node: Node2D in nodes:
		offsets[node] = node.position / size

	get_viewport().size_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var screen_size: Vector2 = get_viewport_rect().size
	if viewport.size.y < screen_size.y:
		position = Vector2(0, viewport.size.y)
		size = Vector2(screen_size.x, screen_size.y - viewport.size.y)
	else:
		global_position = Vector2.ZERO
		size = screen_size
	
	for node: Node2D in nodes:
		node.position = size * offsets[node]

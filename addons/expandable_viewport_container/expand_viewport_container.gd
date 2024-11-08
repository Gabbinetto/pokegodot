extends SubViewportContainer

@onready var viewport: SubViewport = get_child(0)

@export_group("Margins")
@export var margin_vertical: float = 0.0
@export var margin_horizontal: float = 0.0


func _ready() -> void:
	size = viewport.size
	pivot_offset = size / 2.0
	_refresh_size()


func _refresh_size() -> void:
	var container_size: Vector2
	if get_parent() is Control:
		container_size = get_parent().size
	else:
		container_size = get_viewport_rect().size
	
	container_size.x -= margin_horizontal
	container_size.y -= margin_vertical

	scale = container_size / Vector2(viewport.size)
	scale = Vector2.ONE * min(scale.x, scale.y)

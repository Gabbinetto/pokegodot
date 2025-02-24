class_name NPCMovement extends Resource

@export var direction: Vector2i = Vector2i.DOWN:
	set(value):
		direction = value.clampi(-1, 1)
@export var tiles_distance: int = 1
@export var turn_only: bool = false
@export var random_direction: bool = false
@export var end_time_range: PackedFloat32Array = [0.0, 0.0]

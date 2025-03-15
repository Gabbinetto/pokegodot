class_name NPCMovement extends Resource

## Resource describing an NPC movement step.
##
## Holds no methods whatsoever. Only useful in [NPC].

@export var direction: Vector2i = Vector2i.DOWN: ## The direction of this step. Clamps the vector coordinates between [code]-1[/code] and [code]1[/code]
	set(value):
		direction = value.clampi(-1, 1)
@export var tiles_distance: int = 1 ## The tiles this step covers.
@export var turn_only: bool = false ## Only turns and doesn't move.
@export var random_direction: bool = false ## If true, [member direction] is ignored and the step's direction is random.
## Delay at the end of the steps. Picks a random value between the first and last element, any element in between is ignored.
## Use two identical values to have a set time.
@export var end_time_range: PackedFloat32Array = [0.0, 0.0]

class_name NPC extends Actor

signal interact_changed

@export var movement: Array[NPCMovement]
@export var loop_movement: bool = true
var current_step: int = 0
var target_position: Vector2
var processing_movement: bool = false
var step_end_time: float = 0.0
## If this is true, the NPC won't advance in its movements,
## as it means that it is interacting with the player.
var interacting: bool = false:
	set(value):
		interacting = value
		interact_changed.emit()


func _ready() -> void:
	turn_frames = 1 # NPCs don't need frames to turn
	next_step()


func next_step() -> void:
	if current_step >= movement.size():
		return
	
	var step: NPCMovement = movement[current_step]
	var dir: Vector2i = step.direction
	if step.random_direction:
		dir = DIRECTIONS.values().pick_random()
	if step.turn_only:
		facing_direction = dir
		if step.end_time_range[0] + step.end_time_range[-1] <= 0:
			# Make sure that turning waits at least one frame
			# or else infinite recursion will happen
			step.end_time_range = PackedFloat32Array([1.0 / 60.0, 1.0 / 60.0])
	else:
		input_direction = dir
		for i: int in step.tiles_distance:
			await stopped_moving
		input_direction = Vector2.ZERO
	if step.end_time_range[0] + step.end_time_range[-1] > 0:
		# Use Globals as NPCs won't be in the tree when the map isn't loaded
		await Globals.get_tree().create_timer(
			Globals.rng.randf_range(step.end_time_range[0], step.end_time_range[-1])
		).timeout
	
	
	if interacting:
		await interact_changed

	current_step += 1
	if loop_movement and current_step >= movement.size():
		current_step = 0
	
	next_step()

class_name Actor extends CharacterBody2D

## Actor class.
##
## An actor, that is to say a game object that can move.


signal started_moving ## Emitted when starts to move.
## Emitted when a tile has been walked.
## Useful to wait for the [Player] or any [NPC] to stop moving and avoiding
## cases such as an NPC frozen between tiles.
signal stopped_moving

const ANIMATION_IDLE_PREFIX: String = "IDLE_" ## Prefix of the animations in the [SpriteFrames] when idle.
const ANIMATION_WALK_PREFIX: String = "WALK_" ## Prefix of the animations in the [SpriteFrames] when walking.

## The animated sprite that changes animation when walking or facing another direction.
@export var sprite: AnimatedSprite2D
@export var collision_ray: RayCast2D ## The raycast that checks for collisions.
@export var speed: float = 4.0 ## The walking speed (In tile percentage per frame)
@export var no_turning: bool = false ## If true, the actor doesn't turn when moving.
@export_enum("Down", "Left", "Right", "Up") var initial_direction: int = 0 ## The initial direction.
@export var disable_collision: bool = false
@export var elevation: int = 0:
	set = _set_elevation
@onready var initial_position: Vector2 = position ## The initial position. Gets updated everytime a tile is moved.
@onready var facing_direction: Vector2 = Globals.DIRECTIONS.values()[initial_direction] ## The direction this actor is facing.
var turn_frames: int = 4 ## Frames necessary to turn. Allows the [Player] to turn without moving.
var input_direction: Vector2 = Vector2.ZERO ## The input needed to move.
var is_turning: bool = false ## Whether the actor is turning or not.
var is_moving: bool = false ## Whether the actor is turning or not.
var can_move: bool = true: ## If false, the actor can't move.
	set(value):
		if position != position.snappedf(Globals.TILE_SIZE):
			await stopped_moving
		can_move = value
		if not can_move and is_moving:
			is_moving = false
			stopped_moving.emit()
var turning_frames: int = 0 ## Frames passed to turn.
var percent_moved: float = 0.0 ## Percentage of the tile moved.


func _ready() -> void:
	SignalRouter.elevation_changed.connect(_elevation_changed)


func _physics_process(delta: float) -> void:

	if facing_direction != input_direction and not no_turning and input_direction:
		turning_frames = turn_frames
	is_turning = turning_frames > 0
	is_moving = input_direction != Vector2.ZERO and not is_turning

	if input_direction:
		if is_turning:
			facing_direction = input_direction
		elif is_moving and can_move:
			move(delta)

	_animate()

	turning_frames = max(turning_frames - 1, 0)


func _set_elevation(value: int) -> void:
	z_index += value - elevation
	elevation = value


func _elevation_changed(new_elevation: int) -> void:
	set_collision_layer_value(1, elevation == new_elevation)
	set_collision_mask_value(1, elevation == new_elevation)


func update_initial_position() -> void:
	initial_position = position.snapped(Globals.TILE_SIZE * Vector2.ONE)



## Advances the actor. Meant to be called in [method Node._physics_process]
func move(delta: float) -> void:
	var target_position: Vector2 = (initial_position + (Globals.TILE_SIZE * input_direction)).snapped(Globals.TILE_SIZE * Vector2.ONE)
	collision_ray.target_position = input_direction * floori(Globals.TILE_SIZE / 2.0)
	collision_ray.force_raycast_update()
	if not collision_ray.is_colliding() or disable_collision:
		if percent_moved == 0.0:
			started_moving.emit()
		percent_moved += speed * delta
		if percent_moved >= 1.0:
			position = initial_position + (input_direction * Globals.TILE_SIZE)
			initial_position = position
			percent_moved = 0.0
			is_moving = false
			stopped_moving.emit()
		else:
			position = initial_position + (input_direction * Globals.TILE_SIZE * percent_moved)
	else:
		update_initial_position()
		percent_moved = 0.0
		is_moving = false
		stopped_moving.emit()


func _animate() -> void:
	var dir: String = Globals.DIRECTIONS.find_key(facing_direction)
	if not is_moving and not input_direction:
		sprite.animation = ANIMATION_IDLE_PREFIX + dir
	else:
		sprite.animation = ANIMATION_WALK_PREFIX + dir

	if not sprite.is_playing():
		sprite.play()

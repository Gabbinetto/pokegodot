class_name Actor extends Node2D

signal started_moving
signal stopped_moving

const ANIMATION_IDLE_PREFIX: String = "IDLE_"
const ANIMATION_WALK_PREFIX: String = "WALK_"
const TILE_SIZE: int = 32
const DIRECTIONS: Dictionary[String, Vector2] = {
	"DOWN": Vector2.DOWN,
	"LEFT": Vector2.LEFT,
	"RIGHT": Vector2.RIGHT,
	"UP": Vector2.UP,
}

@export var sprite: AnimatedSprite2D
@export var collision_ray: RayCast2D
@export var speed: float = 4.0
@export var no_turning: bool = false
@export_enum("Down", "Left", "Right", "Up") var initial_direction: int = 0

@onready var initial_position: Vector2 = position
@onready var facing_direction: Vector2 = DIRECTIONS.values()[initial_direction]
var turn_frames: int = 4
var input_direction: Vector2 = Vector2.ZERO
var is_turning: bool = false
var is_moving: bool = false
var can_move: bool = true:
	set(value):
		if position != position.snappedf(TILE_SIZE):
			await stopped_moving
		can_move = value
		if not can_move and is_moving:
			is_moving = false
			stopped_moving.emit()
var turning_frames: int = 0
var percent_moved: float = 0.0


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


func move(delta: float) -> void:
	var target_position: Vector2 = (initial_position + (TILE_SIZE * input_direction)).snapped(TILE_SIZE * Vector2.ONE)
	collision_ray.target_position = input_direction * floori(TILE_SIZE / 2.0)
	collision_ray.force_raycast_update()
	if not collision_ray.is_colliding():
		if percent_moved == 0.0:
			started_moving.emit()
		percent_moved += speed * delta
		if percent_moved >= 1.0:
			position = initial_position + (input_direction * TILE_SIZE)
			initial_position = position
			percent_moved = 0.0
			is_moving = false
			stopped_moving.emit()
		else:
			position = initial_position + (input_direction * TILE_SIZE * percent_moved)
	else:
		initial_position = position.snapped(TILE_SIZE * Vector2.ONE)
		percent_moved = 0.0
		is_moving = false
		stopped_moving.emit()


func _animate() -> void:
	var dir: String = DIRECTIONS.find_key(facing_direction)
	if not is_moving and not input_direction:
		sprite.animation = ANIMATION_IDLE_PREFIX + dir
	else:
		sprite.animation = ANIMATION_WALK_PREFIX + dir
	
	if not sprite.is_playing():
		sprite.play()

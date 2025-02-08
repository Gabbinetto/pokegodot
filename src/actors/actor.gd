class_name Actor extends Area2D

const ANIMATION_IDLE_PREFIX: String = "IDLE_"
const ANIMATION_WALK_PREFIX: String = "WALK_"
const TILE_SIZE: int = 32
const TURNING_FRAMES: int = 4
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
var input_direction: Vector2 = Vector2.ZERO
var is_turning: bool = false
var is_moving: bool = false
var turning_frames: int = 0
var percent_moved: float = 0.0


func _physics_process(delta: float) -> void:

	if facing_direction != input_direction and not no_turning and input_direction:
		turning_frames = TURNING_FRAMES
	is_turning = turning_frames > 0
	is_moving = input_direction != Vector2.ZERO and not is_turning

	if input_direction:
		if is_turning:
			facing_direction = input_direction
		elif is_moving:
			move(delta)

	_animate()
	
	turning_frames = max(turning_frames - 1, 0)


func move(delta: float) -> void:
	var target_position: Vector2 = initial_position + (TILE_SIZE * input_direction)
	collision_ray.target_position = input_direction * floori(TILE_SIZE / 2.0)
	collision_ray.force_raycast_update()
	if not collision_ray.is_colliding():
		percent_moved += speed * delta
		if percent_moved >= 1.0:
			position = initial_position + (input_direction * TILE_SIZE)
			initial_position = position
			percent_moved = 0.0
			is_moving = false
		else:
			position = initial_position + (input_direction * TILE_SIZE * percent_moved)
	else:
		initial_position = position.snapped(TILE_SIZE * Vector2.ONE)
		percent_moved = 0.0
		is_moving = false


func _animate() -> void:
	pass

class_name Player extends CharacterBody2D

@export var walk_speed: float = 4.0
@export var run_speed: float = 8.0
@export var sprite: AnimatedSprite2D
@export var collision_checker: RayCast2D

var is_moving: bool = false
var is_running: bool = false
var percent_to_next_tile: float = 0.0

var initial_position: Vector2
var input_direction: Vector2

func _ready() -> void:
	if not is_instance_valid(sprite):
		push_warning("Sprite is not set")
	
	initial_position = position

func _physics_process(delta: float) -> void:
	if not is_moving:
		_process_player_input()
	elif is_moving:
		_move(delta)
	
	is_running = Input.is_action_pressed("B")

func _process_player_input() -> void:
	
	if input_direction.y == 0:
		input_direction.x = int(Input.get_axis("Left", "Right"))
	if input_direction.x == 0:
		input_direction.y = int(Input.get_axis("Up", "Down"))

	if input_direction != Vector2.ZERO:
		initial_position = position
		is_moving = true


func _move(delta: float) -> void:
	if is_running:
		percent_to_next_tile += delta * run_speed
	else:
		percent_to_next_tile += delta * walk_speed
	
	var desired_step: Vector2 = input_direction * Global.TILE_SIZE / 2
	collision_checker.target_position = desired_step
	if collision_checker.is_colliding():
		is_moving = false
		percent_to_next_tile = 0.0
		sprite.frame = 0
	else:
		if percent_to_next_tile >= 1.0:
			position = initial_position + (Global.TILE_SIZE * input_direction)
			is_moving = false
			percent_to_next_tile = 0.0
		else:
			position = initial_position + (Global.TILE_SIZE * input_direction * percent_to_next_tile)

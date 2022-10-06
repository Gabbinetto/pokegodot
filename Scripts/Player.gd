extends CharacterBody2D

@export var move_speed : = 4.0
@export var run_speed : = 8.0
const TILE_SIZE : = 32

var is_moving : = false
var is_running : = false
var percent_to_next_tile : = 0.0

var initial_position : = Vector2()
var input_direction : = Vector2()
var sprite : AnimatedSprite2D 
var raycast : RayCast2D 

func _ready() -> void:
	initial_position = position
	sprite = $AnimatedSprite2d
	raycast = $RayCast2d

func _physics_process(delta: float) -> void:
	raycast.set_enabled(is_moving)
	if is_moving == false:
		_process_player_input()
	elif input_direction != Vector2.ZERO:
		_move(delta)
		
	_handle_animation()
	
	is_running = Input.is_action_pressed('B')


func _process_player_input():
	if input_direction.y == 0:
		input_direction.x = int(Input.get_axis('Left', 'Right'))
	if input_direction.x == 0:
		input_direction.y = int(Input.get_axis('Up', 'Down'))
	
	if input_direction != Vector2.ZERO:
		initial_position = position
		is_moving = true

func _move(delta):
	percent_to_next_tile += delta * ((move_speed * int(!is_running)) + (run_speed * int(is_running)))
	var desired_step : = input_direction * TILE_SIZE / 2 
	raycast.set_target_position(desired_step)
	raycast.force_raycast_update()
	if raycast.is_colliding():
		is_moving = false
		percent_to_next_tile = 0.0
	else:
		if percent_to_next_tile >= 1.0:
			position = initial_position + (TILE_SIZE * input_direction)
			percent_to_next_tile = 0.0
			is_moving = false
		else:
			position = initial_position + (TILE_SIZE * input_direction * percent_to_next_tile)
		
		
func _handle_animation():
	sprite.set_playing(is_moving)
	if !is_moving:
		if input_direction == Vector2.ZERO:
			sprite.set_frame(0)
	else:
		var anim_prefix = 'RUN' if is_running else 'WALK'
		match input_direction:
			Vector2.UP:
				sprite.set_animation(anim_prefix + '_UP')
			Vector2.DOWN:
				sprite.set_animation(anim_prefix + '_DOWN')
			Vector2.LEFT:
				sprite.set_animation(anim_prefix + '_LEFT')
			Vector2.RIGHT:
				sprite.set_animation(anim_prefix + '_RIGHT')






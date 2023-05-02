extends CharacterBody2D

@export var move_speed : = 4.0
@export var run_speed : = 8.0

var is_moving : = false
var is_running : = false
var percent_to_next_tile : = 0.0

var initial_position : = Vector2()
var input_direction : = Vector2()
var sprite : AnimatedSprite2D 
var collision_checker : RayCast2D
var event_checker : RayCast2D

func _ready() -> void:
	initial_position = position
	sprite = $AnimatedSprite2d
	collision_checker = $CollisionChecker
	event_checker = $EventChecker

func _physics_process(delta: float) -> void:
	if is_moving == false and Globals.movement_enabled:
		_process_player_input()
	elif is_moving:#input_direction != Vector2.ZERO:
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
	
	if is_running:
		percent_to_next_tile += delta * run_speed
	else:
		percent_to_next_tile += delta * move_speed
	
	var desired_step : Vector2 = input_direction * GameVariables.TILE_SIZE / 2 
	collision_checker.set_target_position(desired_step)
	collision_checker.force_raycast_update()
	event_checker.set_target_position(desired_step * 2)
	if collision_checker.is_colliding():
		is_moving = false
		percent_to_next_tile = 0.0
		sprite.set_frame(0)
	else:
		if percent_to_next_tile >= 1.0:
			position = initial_position + (GameVariables.TILE_SIZE * input_direction)# + (GameVariables.TILE_SIZE * input_direction / 2)
			percent_to_next_tile = 0.0
			is_moving = false
		else:
			position = initial_position + (GameVariables.TILE_SIZE * input_direction * percent_to_next_tile)# + (GameVariables.TILE_SIZE * input_direction / 2)
		
		
func _handle_animation():
	if !is_moving:
		sprite.stop()
	
	if !is_moving:
		if input_direction == Vector2.ZERO:
			# Set the frame to the first frame to have an idle "animation"
			sprite.set_frame(0)
			
			# If the player was running set the animation to the correspondent
			# walk animation. Like if the animation was 'RUN_UP' set to 'WALK_UP' to avoid
			# having running frames while idle
			if String(sprite.animation).contains('RUN'):
				sprite.animation = 'WALK' + String(sprite.animation).right(-3)
	else:
		# Set the animation according to the running state and direction
		var anim_prefix = 'RUN' if is_running else 'WALK'
		match input_direction:
			Vector2.UP:
				sprite.play(anim_prefix + '_UP')
			Vector2.DOWN:
				sprite.play(anim_prefix + '_DOWN')
			Vector2.LEFT:
				sprite.play(anim_prefix + '_LEFT')
			Vector2.RIGHT:
				sprite.play(anim_prefix + '_RIGHT')

func get_camera():
	return %Camera

func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed('A'):
		_check_event()

func _check_event():
	var event : Event = event_checker.get_collider()
	if event_checker.is_colliding() and Globals.movement_enabled:
		if !event.is_running:
			event.run()

class_name Player extends Actor

## The player actor.
##
## Actor controlled by the player. Accepts input and moves accordingly.[br][br]
## [b]Note[/b]: ignores [member Actor.speed] and uses [member walk_speed], [member run_speed] and [member bike_speed].

const MALE_FRAMES: SpriteFrames = preload("res://src/actors/player/boy_frames.tres") ## Male [SpriteFrames].
const FEMALE_FRAMES: SpriteFrames = preload("res://src/actors/player/girl_frames.tres") ## Female [SpriteFrames].

const ANIMATION_RUN_PREFIX: String = "RUN_" ## Prefix of the animations in the [SpriteFrames] when running.
const ANIMATION_BIKE_PREFIX: String = "BIKE_" ## Prefix of the animations in the [SpriteFrames] when on a bike.
const ANIMATION_BIKE_IDLE_PREFIX: String = "BIKE_IDLE_" ## Prefix of the animations in the [SpriteFrames] when idle on a bike.

@export var event_ray: RayCast2D ## Raycast that checks for interactable events in front of the player.
@export var area: Area2D ## The player detecting area.
@export var walk_speed: float = 4.0 ## Speed when walking.
@export var run_speed: float = 8.0 ## Speed when running.
@export var bike_speed: float = 12.0 ## Speed when biking.

var is_running: bool = false ## True if the player is running. By default, is true when B is pressed.
var on_bike: bool = false ## True if on a bike.
var input_enabled: bool = true ## If false, won't pick up input from the player. Useful for cutscenes.


func _ready() -> void:
	if PlayerData.gender == PlayerData.MALE:
		sprite.sprite_frames = MALE_FRAMES
	else:
		sprite.sprite_frames = FEMALE_FRAMES
		
	Globals.player = self


func _check_event_collision() -> void:
	var event: Area2D = event_ray.get_collider()
	if not event or not is_instance_valid(event) or not (event is Event):
		return

	event.collision(facing_direction)


func _physics_process(delta: float) -> void:
	is_running = Input.is_action_pressed("B")
	if on_bike:
		speed = bike_speed
	else:
		speed = run_speed if is_running else walk_speed
	
	if not is_moving and input_enabled:
		# Can only move horizontally or vertically, not both.
		if Input.get_axis("Left", "Right") == 0.0:
			input_direction.y = Input.get_axis("Up", "Down")
			input_direction.x = 0.0
		if Input.get_axis("Up", "Down") == 0.0:
			input_direction.x = Input.get_axis("Left", "Right")
			input_direction.y = 0.0
		input_direction = input_direction.abs().ceil() * input_direction.sign()

	if not Globals.movement_enabled:
		input_direction = Vector2.ZERO

	if input_direction:
		event_ray.target_position = input_direction * TILE_SIZE
		event_ray.force_raycast_update()
		if not is_moving and input_enabled:
			_check_event_collision()
	
	super(delta)


func _animate() -> void:
	var anim_prefix: String = ""
	var dir_string = DIRECTIONS.find_key(facing_direction)
	if on_bike:
		anim_prefix = ANIMATION_BIKE_PREFIX
	elif is_running:
		anim_prefix = ANIMATION_RUN_PREFIX
	else:
		anim_prefix = ANIMATION_WALK_PREFIX

	if not is_moving and not input_direction:
		if on_bike:
			anim_prefix = ANIMATION_BIKE_IDLE_PREFIX
		else:
			anim_prefix = ANIMATION_IDLE_PREFIX
	
	if anim_prefix:
		sprite.animation = anim_prefix + dir_string
	
	if not sprite.is_playing():
		sprite.play()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("A"):
		_on_event_input()


func _on_event_input() -> void:
	if not Globals.event_input_enabled:
		return
	
	var event: Area2D = event_ray.get_collider()
	if not event or not is_instance_valid(event) or not (event is Event):
		return
	
	if is_moving:
		await stopped_moving
	
	event.interact()

class_name Player extends Actor

const MALE_FRAMES: SpriteFrames = preload("res://src/actors/player/boy_frames.tres")
const FEMALE_FRAMES: SpriteFrames = preload("res://src/actors/player/girl_frames.tres")

const ANIMATION_RUN_PREFIX: String = "RUN_"
const ANIMATION_BIKE_PREFIX: String = "BIKE_"
const ANIMATION_BIKE_IDLE_PREFIX: String = "BIKE_IDLE_"

@export var event_ray: RayCast2D
@export var walk_speed: float = 4.0
@export var run_speed: float = 8.0
@export var bike_speed: float = 12.0

var is_running: bool = false
var on_bike: bool = false


func _ready() -> void:
	if PlayerData.gender == PlayerData.MALE:
		sprite.sprite_frames = MALE_FRAMES
	else:
		sprite.sprite_frames = FEMALE_FRAMES
		
	Globals.player = self


func _physics_process(delta: float) -> void:	
	is_running = Input.is_action_pressed("B")
	if on_bike:
		speed = bike_speed
	else:
		speed = run_speed if is_running else walk_speed
	
	if not is_moving:
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
		event_ray.target_position = input_direction * floori(TILE_SIZE / 2.0)
		event_ray.force_raycast_update()
	
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
	
	var event: Event = event_ray.get_collider()
	if not event or not is_instance_valid(event):
		return
	
	event.interact()

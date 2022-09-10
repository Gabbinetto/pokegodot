extends AnimatedSprite


export var speed : = 4.0
const TILE_SIZE : = Vector2(32, 32)

var input_direction : = Vector2.ZERO

func _ready() -> void:
	position = position.snapped(TILE_SIZE)

func _process(_delta: float) -> void:
	var moving = input_direction != Vector2.ZERO
	playing = moving
	if !moving:
		frame = 0

func _physics_process(_delta: float) -> void:
	if input_direction.y == 0:
		input_direction.x = round(Input.get_action_strength('right') - Input.get_action_strength('left'))
	if input_direction.x == 0:
		input_direction.y = round(Input.get_action_strength('down') - Input.get_action_strength('up'))

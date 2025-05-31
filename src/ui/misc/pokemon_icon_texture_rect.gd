class_name PokemonIconTextureRect extends TextureRect


@export var playing: bool = true:
	set(value):
		if not playing and value:
			_time_elapsed = 0.0
		playing = value
@export var frame_duration: float = 0.333
@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		_create_frames()


var _frame_1: AtlasTexture
var _frame_2: AtlasTexture

var _on_frame_2: bool = false
var _time_elapsed: float = 0.0



func _ready() -> void:
	_create_frames()


func _process(delta: float) -> void:
	if not playing:
		return

	if _time_elapsed > frame_duration:
		_swap_frame()
		_time_elapsed = 0.0

	_time_elapsed += delta


func _swap_frame() -> void:
	if _on_frame_2:
		texture = _frame_1
	else:
		texture = _frame_2
	_on_frame_2 = not _on_frame_2


func _create_frames() -> void:
	_frame_1 = AtlasTexture.new()
	_frame_2 = AtlasTexture.new()

	if not icon_texture:
		return

	var frame_width: int = floori(icon_texture.get_width() / 2.0)

	_frame_1.atlas = icon_texture
	_frame_2.atlas = icon_texture

	_frame_1.region = Rect2i(
		0, 0, frame_width, icon_texture.get_height()
	)
	_frame_2.region = Rect2i(
		frame_width, 0, frame_width, icon_texture.get_height()
	)

	texture = _frame_2 if _on_frame_2 else _frame_1

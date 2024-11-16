class_name DataboxNumbers extends HBoxContainer


@export var numbers_texture: Texture2D:
	set(value):
		numbers_texture = value
		_generate_textures()
@export var characters: String = "0123456789/"
@export var max_length: int = 9:
	set(value):
		max_length = value
		_generate_rects()
@export var text: String:
	set(value):
		text = value.substr(0, max_length)
		_refresh_text()


var rects: Array[TextureRect] = []
var _textures: Array[AtlasTexture] = []


func _ready() -> void:
	_generate_textures()
	_generate_rects()
	_refresh_text()


func _generate_textures() -> void:
	_textures.clear()

	var h_size: int = floori(numbers_texture.get_width() / float(characters.length()))
	for i: int in characters.length():
		var texture: AtlasTexture = AtlasTexture.new()
		texture.atlas = numbers_texture
		texture.region = Rect2(
			Vector2(h_size * i, 0),
			Vector2(h_size, numbers_texture.get_height())
		)
		_textures.append(texture)


func _generate_rects() -> void:
	for rect: TextureRect in rects:
		rect.queue_free()
	rects.clear()

	for i: int in max_length:
		var rect: TextureRect = TextureRect.new()
		rect.stretch_mode = TextureRect.STRETCH_KEEP
		add_child(rect)
		rects.append(rect)


func _refresh_text() -> void:
	if rects.is_empty() or _textures.is_empty():
		return
	for i: int in text.length():
		var character: String = text[i]
		var index: int = characters.find(character)
		rects[i].texture = _textures[index]
	if text.length() < max_length:
		for i: int in range(text.length(), max_length):
			rects[i].texture = null

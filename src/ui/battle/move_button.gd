class_name MoveButton extends TextureButton


@export var move: PokemonMove:
	set(value):
		move = value
		refresh()
@export var name_label: Label
@export var buttons_texture: Texture2D = preload("res://assets/graphics/ui/battle/move_buttons.png")


func _ready() -> void:
	refresh()


func refresh() -> void:
	if not move:
		return

	var button_size: Vector2 = buttons_texture.get_size() / Vector2(2.0, Types.List.size())

	var normal: AtlasTexture = AtlasTexture.new()
	normal.atlas = buttons_texture
	normal.region = Rect2(
		Vector2(0, button_size.y * move.type), button_size
	)
	var highlighted: AtlasTexture = AtlasTexture.new()
	highlighted.atlas = buttons_texture
	highlighted.region = Rect2(
		Vector2(button_size.x, button_size.y * move.type), button_size
	)

	texture_normal = normal
	texture_hover = normal
	texture_pressed = highlighted
	texture_focused = highlighted

	name_label.text = move.name

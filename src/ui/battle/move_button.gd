class_name MoveButton extends TextureButton

const FONT_TYPE_COLORS: Dictionary[int, Color] = {
	Types.NORMAL: Color8(80, 72, 88),
	Types.FIGHTING: Color8(120, 48, 0),
	Types.FLYING: Color8(24, 48, 104),
	Types.POISON: Color8(88, 32, 120),
	Types.GROUND: Color8(104, 56, 8),
	Types.ROCK: Color8(80, 48, 32),
	Types.BUG: Color8(88, 80, 8),
	Types.GHOST: Color8(72, 40, 64),
	Types.STEEL: Color8(88, 88, 72),
	Types.QMARKS: Color8(88, 48, 64),
	Types.FIRE: Color8(112, 40, 56),
	Types.WATER: Color8(8, 48, 80),
	Types.GRASS: Color8(48, 96, 24),
	Types.ELECTRIC: Color8(128, 104, 8),
	Types.PSYCHIC: Color8(120, 16, 120),
	Types.ICE: Color8(64, 96, 136),
	Types.DRAGON: Color8(48, 32, 136),
	Types.DARK: Color8(80, 40, 48),
	Types.FAIRY: Color8(208, 96, 184),
}


@export var move: PokemonMove:
	set(value):
		move = value
		refresh()
@export var name_label: Label
@export var buttons_texture: Texture2D = preload("res://assets/graphics/ui/battle/move_buttons.png")


func _ready() -> void:
	name_label.label_settings = name_label.label_settings.duplicate()
	
	refresh()


func refresh() -> void:
	if not move:
		return

	var button_size: Vector2 = buttons_texture.get_size() / Vector2(2.0, Types.count)

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
	name_label.label_settings.font_color = FONT_TYPE_COLORS.get(move.type, Color.BLACK)

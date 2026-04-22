class_name PokemonBodySprite extends Sprite2D

## Pokemon sprite.
##
## A pokemon's full body sprite. Takes in a [Pokemon] and shifts the sprite accordingly.

@export var id: String: ## The pokemon pokemon.
	set(value):
		id = value
		refresh()
@export var form_number: int = 0:
	set(value):
		form_number = value
		refresh()
@export var shiny: bool = false:
	set(value):
		shiny = value
		refresh()
@export var gender: Pokemon.Genders = Pokemon.Genders.MALE:
	set(value):
		gender = value
		refresh()
@export var back_sprite: bool = false:
	set(value):
		back_sprite = value
		refresh()


func _ready() -> void:
	refresh.call_deferred()


func refresh() -> void:
	if not id:
		texture = null
		return
	else:
		texture = DB.fetch_pokemon_sprite(id, form_number, shiny, gender, back_sprite)

	_shift()


func _shift() -> void:
	var metrics: Dictionary[String, int] = DB.fetch_pokemon_metrics(id, form_number)

	var new_offset: Vector2
	if back_sprite:
		new_offset = Vector2(metrics.get("back_sprite_x", 0), metrics.get("back_sprite_y", 0))
	else:
		new_offset = Vector2(metrics.get("front_sprite_x", 0), metrics.get("front_sprite_y", 0))

	offset = Vector2(0, -texture.get_height() / 2.0) + new_offset

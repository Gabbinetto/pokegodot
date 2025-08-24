class_name PokemonBodySprite extends Sprite2D

## Pokemon sprite.
##
## A pokemon's full body sprite. Takes in a [Pokemon] and shifts the sprite accordingly.

@export var pokemon: Pokemon: ## The pokemon pokemon.
	set(value):
		pokemon = value
		refresh()
@export var back_sprite: bool = false:
	set(value):
		back_sprite = value
		refresh()


func _ready() -> void:
	refresh.call_deferred()


func refresh() -> void:
	if not pokemon:
		texture = null
		return
	else:
		texture = pokemon.sprite_back if back_sprite else pokemon.sprite_front

	_shift()


func _shift() -> void:
	var metrics: Dictionary[String, int] = pokemon.species.metrics

	var new_offset: Vector2
	if back_sprite:
		new_offset = Vector2(metrics.get("back_sprite_x", 0), metrics.get("back_sprite_y", 0))
	else:
		new_offset = Vector2(metrics.get("front_sprite_x", 0), metrics.get("front_sprite_y", 0))
	
	offset = Vector2(0, -texture.get_height() / 2.0) + new_offset

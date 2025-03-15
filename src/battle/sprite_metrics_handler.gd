class_name SpriteMetricsHandler extends Node

## Sprite metrics handler.
##
## Shifts the parent [Sprite2D]'s texture every time it changes and on ready, according to the data in [code]pokemon_metrics.json[/code].

@export var battle: Battle ## The ongoing battle.
@export_range(0, 3) var pokemon_slot: int = 0 ## The parent sprite pokemon slot.
var parent: Sprite2D ## The parent, set on ready.
var base_offset: int ## The starting [member Sprite2D.offset].

func _ready() -> void:
	parent = get_parent()
	base_offset = parent.offset.y
	parent.texture_changed.connect(_shift)
	
	_shift.call_deferred()


func _shift() -> void:
	if not parent.texture:
		return
	var info: Battle.PokemonBattleInfo = battle.pokemons[pokemon_slot]
	if not info:
		return
	
	var metrics: Dictionary[String, int] = info.species.metrics
	
	var offset: Vector2i
	if pokemon_slot > 1:
		offset = Vector2i(metrics.front_sprite_x, metrics.front_sprite_y)
	else:
		offset = Vector2i(metrics.back_sprite_x, metrics.back_sprite_y)
	
	parent.offset += Vector2(offset)
	
	

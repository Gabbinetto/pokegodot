class_name PokemonFollowerFrames extends ActorFrames


@export var id: String = "BULBASAUR":
	set(value):
		id = value
		if id:
			generate_animations_from_id()
			remove_animation("default")
@export_range(0, 99, 1, "or_greater") var form: int = 0
@export var shiny: bool = false


func generate_animations_from_id() -> void:
	var file_name: String = id
	if form > 0:
		file_name += "_%d" % form
	file_name += ".png"
	
	texture = load(DB.POKEMON_FOLLOWERS_PATH + file_name)

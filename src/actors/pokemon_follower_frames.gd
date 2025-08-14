@tool
class_name PokemonFollowerFrames extends ActorFrames


@export var id: String = "BULBASAUR"
@export_range(0, 99, 1, "or_greater") var form: int = 0
@export var shiny: bool = false


func _validate_property(property: Dictionary) -> void:
	if property.name == "texture":
		property.usage &= ~PROPERTY_USAGE_EDITOR


func generate_animations() -> void:
	_generate_animations_from_id()
	super()


func _generate_animations_from_id() -> void:
	var file_name: String = id
	if form > 0:
		file_name += "_%d" % form
	file_name += ".png"
	
	texture = load(DB.POKEMON_FOLLOWERS_PATH + file_name)

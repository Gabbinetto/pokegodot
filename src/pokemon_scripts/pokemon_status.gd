class_name PokemonStatus extends Resource


func as_save_data() -> Dictionary[String, Variant]:
	return {}


static func from_save_data(data: Dictionary[String, Variant]) -> PokemonStatus:
	if data.is_empty():
		return
	return PokemonStatus.new()

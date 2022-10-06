extends Node


# File paths
const pokemon_file : = 'res://PBS/pokemon.txt'
const pokemon_forms_file : = 'res://PBS/pokemon_forms.txt'
const moves_file : = 'res://PBS/moves.txt'
const items_file : = 'res://PBS/items.txt'
const exp_file : = 'res://PBS/exp.txt'
const types_file : = 'res://PBS/types.txt'
const sprites_front : = 'res://Graphics/Pokemon/Front/'
const sprites_front_shiny : = 'res://Graphics/Pokemon/Front shiny/'
const sprites_back : = 'res://Graphics/Pokemon/Back/'
const sprites_back_shiny : = 'res://Graphics/Pokemon/Back shiny/'
const icons : = 'res://Graphics/Pokemon/Icons/'

# Get the lowest non-opaque pixel in an image
# Used to offset Pokemon sprites down to the ground
func get_lowest_pixel_position(image : Image) -> Vector2:
	var index = Vector2(image.get_size()) - Vector2.ONE
	
#	image.lock()
	for _i in range(image.get_width() * image.get_height()):
		var pixel = image.get_pixelv(index)
		if pixel.a > 0:
			return index
		index.x -= 1
		if index.x < 0:
			index.x = image.get_width() - 1
			index.y -= 1

	return Vector2(-1, -1)



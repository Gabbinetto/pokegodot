extends Node

const pokemon_file : = 'res://PBS/pokemon.txt'
const pokemon_forms_file : = 'res://PBS/pokemon_forms.txt'
const moves_file : = 'res://PBS/moves.txt'
const items_file : = 'res://PBS/items.txt'
const sprites_front : = 'res://Graphics/Pokemon/Front/'
const sprites_front_shiny : = 'res://Graphics/Pokemon/Front shiny/'
const sprites_back : = 'res://Graphics/Pokemon/Back/'
const sprites_back_shiny : = 'res://Graphics/Pokemon/Back shiny/'
const icons : = 'res://Graphics/Pokemon/Icons/'

const TYPES_INDEX = {
	'NORMAL': 0,
	'FIGHTING': 1,
	'FLYING': 2,
	'POISON': 3,
	'GROUND': 4,
	'ROCK': 5,
	'BUG': 6,
	'GHOST': 7,
	'STEEL': 8,
	'???': 9,
	'FIRE': 10,
	'WATER': 11,
	'GRASS': 12,
	'ELECTRIC': 13,
	'PSYCHIC': 14,
	'ICE': 15,
	'DRAGON': 16,
	'DARK': 17,
	'FAIRY': 18,
}

const NATURES = {
	'HARDY': null,
	'LONELY': {'ATTACK': 1.1, 'DEFENSE': 0.9},
	'BRAVE': {'ATTACK': 1.1, 'SPEED': 0.9},
	'ADAMANT': {'ATTACK': 1.1, 'SPECIAL_ATTACK': 0.9},
	'NAUGHTY': {'ATTACK': 1.1, 'SPECIAL_DEFENSE': 0.9},
	'BOLD': {'DEFENSE': 1.1, 'ATTACK': 0.9},
	'DOCILE': null,
	'RELAXED': {'DEFENSE': 1.1, 'SPEED': 0.9},
	'IMPISH': {'DEFENSE': 1.1, 'SPECIAL_ATTACK': 0.9},
	'LAX': {'DEFENSE': 1.1, 'SPECIAL_DEFENSE': 0.9},
	'TIMID': {'SPEED': 1.1, 'ATTACK': 0.9},
	'HASTY': {'SPEED': 1.1, 'DEFENSE': 0.9},
	'SERIOUS': null,
	'JOLLY': {'SPEED': 1.1, 'SPECIAL_ATTACK': 0.9},
	'NAIVE': {'SPEED': 1.1, 'SPECIAL_DEFENSE': 0.9},
	'MODEST': {'SPECIAL_ATTACK': 1.1, 'ATTACK': 0.9},
	'MILD': {'SPECIAL_ATTACK': 1.1, 'DEFENSE': 0.9},
	'QUIET': {'SPECIAL_ATTACK': 1.1, 'SPEED': 0.9},
	'BASHFUL': null,
	'RASH': {'SPECIAL_ATTACK': 1.1, 'SPECIAL_DEFENSE': 0.9},
	'CALM': {'SPECIAL_DEFENSE': 1.1, 'ATTACK': 0.9},
	'GENTLE': {'SPECIAL_DEFENSE': 1.1, 'DEFENSE': 0.9},
	'SASSY': {'SPECIAL_DEFENSE': 1.1, 'SPEED': 0.9},
	'CAREFUL': {'SPECIAL_DEFENSE': 1.1, 'SPECIAL_ATTACK': 0.9},
	'QUIRKY': null,
}

func get_lowest_pixel_position(image : Image) -> Vector2:
	var index = image.get_size() - Vector2.ONE
	
	image.lock()
	for i in range(image.get_width() * image.get_height()):
		var pixel = image.get_pixelv(index)
		if pixel.a > 0:
			return index
		index.x -= 1
		if index.x < 0:
			index.x = image.get_width() - 1
			index.y -= 1
#
	return Vector2(-1, -1)

extends Node

## Pokegodot's database
##
## Pokegodots's database, meant to hold various types of data, maily data held in files such as [code]pokemon.json[/code].

const DATA_PATH: String = "res://assets/data/"
const GRAPHICS_PATH: String = "res://assets/graphics/"
const POKEMON_SPRITES_PATH: String = GRAPHICS_PATH + "pokemon_sprites/"
# Fallback sprites
const DEFAULT_FRONT_SPRITE: Texture = preload("res://assets/graphics/pokemon_sprites/_default/front_n_m.png")
const DEFAULT_BACK_SPRITE: Texture = preload("res://assets/graphics/pokemon_sprites/_default/back_n_m.png")
const DEFAULT_ICON_SPRITE: Texture = preload("res://assets/graphics/pokemon_sprites/_default/icon_n.png")

var pokemon: Dictionary
var natures: Dictionary
var moves: Dictionary


func _init() -> void:
	# Load the pokemon sprites asset
	if ProjectSettings.load_resource_pack(GRAPHICS_PATH + "pokemon_sprites.pck"):
		print_debug("Pokemon sprites asset pack loaded.")
	else:
		push_error("Pokemon sprites asset pack loaded.")

	# Load JSON files
	pokemon = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH + "pokemon.json"))
	natures = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH + "natures.json"))
	moves = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH + "moves.json"))
extends Node

## Pokegodot's database
##
## Pokegodots's database, meant to hold various types of data, maily data held in files such as [code]pokemon.json[/code].

const DATA_PATH: String = "res://assets/data/"
const GRAPHICS_PATH: String = "res://assets/graphics/"
const POKEMON_SPRITES_PATH: String = GRAPHICS_PATH + "pokemon_sprites/"
const POKEMON_FOLLOWERS_PATH: String = GRAPHICS_PATH + "actors/pokemon/"

var default_front_sprite: Texture2D ## Fallback front sprite.
var default_back_sprite: Texture2D ## Fallback back sprite.
var default_icon_sprite: Texture2D ## Fallback icon sprite.

var pokemon: Dictionary[String, Dictionary] ## Holds the data in [code]pokemon.json[/code]
var natures: Dictionary[String, Array] ## Holds the data in [code]natures.json[/code]
var moves: Dictionary[String, Dictionary] ## Holds the data in [code]moves.json[/code]
var types: Dictionary[String, Dictionary] ## Holds the data in [code]types.json[/code]


func _init() -> void:
	# Load the pokemon graphics asset as the files slow down the editor
	if ProjectSettings.load_resource_pack(GRAPHICS_PATH + "pokemon_graphics.pck"):
		print_debug("Pokemon graphics asset pack loaded.")
	else:
		push_error("Failed loading pokemon graphics asset pack.")
	
	default_front_sprite = load(POKEMON_SPRITES_PATH + "_default/front_n_m.png")
	default_back_sprite = load(POKEMON_SPRITES_PATH + "_default/back_n_m.png")
	default_icon_sprite = load(POKEMON_SPRITES_PATH + "_default/icon_n.png")

	# Load JSON files
	pokemon.assign(JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH + "pokemon.json")))
	natures.assign(JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH + "natures.json")))
	moves.assign(JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH + "moves.json")))
	types.assign(JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH + "types.json")))

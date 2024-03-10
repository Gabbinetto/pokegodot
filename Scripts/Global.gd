extends Node

const FRONT_SPRITES_PATH: = "res://Graphics/Pokemon/Front/"
const BACK_SPRITES_PATH: = "res://Graphics/Pokemon/Back/"
const ICONS_SPRITES_PATH: = "res://Graphics/Pokemon/Icons/"
const SHINY_FRONT_SPRITES_PATH: = "res://Graphics/Pokemon/Front shiny/"
const SHINY_BACK_SPRITES_PATH: = "res://Graphics/Pokemon/Back shiny/"
const SHINY_ICONS_SPRITES_PATH: = "res://Graphics/Pokemon/Icons shiny/"
const FOOTPRINTS_SPRITES_PATH: = "res://Graphics/Pokemon/Footprints"

var pokemons: = {}
var items: = {}
var abilities: = {}
var forms: = {}

func _ready() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Dev/PBS.json"))
	pokemons = data.get("pokemon")
	items = data.get("items")
	abilities = data.get("abilities")
	forms = data.get("forms")

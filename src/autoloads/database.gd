extends Node


const DATA_PATH: String = "res://assets/data/"
const POKEMON_SPRITES_PATH: String = "res://assets/graphics/pokemon_sprites/"
# Fallback sprites
const DEFAULT_FRONT_SPRITE: Texture = preload("res://assets/graphics/pokemon_sprites/_default/front_n_m.png")
const DEFAULT_BACK_SPRITE: Texture = preload("res://assets/graphics/pokemon_sprites/_default/back_n_m.png")
const DEFAULT_ICON_SPRITE: Texture = preload("res://assets/graphics/pokemon_sprites/_default/icon_n.png")

var pokemon: Dictionary


func _init() -> void:
    pokemon = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH + "pokemon.json"))

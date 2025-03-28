extends Node

## Pokegodot's player data
##
## Singleton that holds all the player data.

enum {MALE, FEMALE} ## Player genders.

const MAX_PLAYER_NAME: int = 10 ## The max length of a player's name.

var player_name: String = "Red": ## The player's name.
	set(value):
		player_name = value.substr(0, MAX_PLAYER_NAME)
var team: PokemonTeam = PokemonTeam.new() ## The player's team.
var gender: int = MALE ## The player's selected gender. 0 is MALE, 1 is FEMALE.
var player_id: int
var secret_id: int

func _ready() -> void:
	player_id = Globals.rng.randi_range(0, 999999)
	secret_id = Globals.rng.randi_range(0, 9999)

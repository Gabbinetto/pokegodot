extends Node

## Pokegodot's player data and save data.
##
## Singleton that holds all the player data and the save slot data in
## general (Not flags, those are stored in the [Flags] singleton).

enum {MALE, FEMALE} ## Player genders.

const SAVE_PATH: String = "user://saves/" ## Directory of the save file.
const SAVE_FILE: String = "save.dat" ## Save file name.
const MAX_PLAYER_NAME: int = 10 ## The max length of a player's name.
const DEFAULT_MALE_NAME: String = "Red"
const DEFAULT_FEMALE_NAME: String = "Leaf"

var player_name: String = "Red": ## The player's name.
	set(value):
		player_name = value.substr(0, MAX_PLAYER_NAME)
var team: PokemonTeam = PokemonTeam.new() ## The player's team.
var gender: int = MALE ## The player's selected gender. 0 is MALE, 1 is FEMALE.
var player_id: int
var secret_id: int
var time_played: float = 0.0


func _ready() -> void:
	player_id = Globals.rng.randi_range(0, 999999)
	secret_id = Globals.rng.randi_range(0, 9999)


func _process(delta: float) -> void:
	if Globals.in_game:
		time_played += delta


func save_data() -> void:
	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(SAVE_PATH)
	)

	var data: Dictionary[String, Variant] = {
		"player_name": player_name,
		"gender": gender,
		"player_id": player_id,
		"secret_id": secret_id,
		"time_played": time_played,
		"flags": Flags.as_save_data(),
		"team": team.as_save_data(),
	}

	var file: FileAccess = FileAccess.open(SAVE_PATH + SAVE_FILE, FileAccess.WRITE)
	file.store_buffer(var_to_bytes(data))
	file.close()


func exists_data() -> bool:
	return DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(SAVE_PATH)) and FileAccess.file_exists(SAVE_PATH + SAVE_FILE)


func load_data() -> void:
	if not exists_data():
		return

	var data: Dictionary[String, Variant] = {}
	data.assign(
		bytes_to_var(FileAccess.get_file_as_bytes(SAVE_PATH + SAVE_FILE))
	)

	for key: String in data:
		match key:
			"team":
				team = PokemonTeam.from_save_data(data[key])
			"flags":
				Flags.from_save_data(data[key])
			_:
				set(key, data[key])


func load_save_info() -> Dictionary[String, Variant]:
	var output: Dictionary[String, Variant] = {}

	var data: Dictionary[String, Variant] = bytes_to_var(FileAccess.get_file_as_bytes(SAVE_PATH + SAVE_FILE))

	output["player_name"] = data.get("player_name", "")
	output["gender"] = data.get("gender", 0)
	output["team"] = []
	for pokemon: Dictionary[String, Variant] in data.get("team", []):
		output["team"].append(pokemon.get("species_id"))

	output["badges"] = data.get("flags", {}).get("f_badges", []).count(true)
	output["map_name"] = data.get("map_name", "Mystery Zone")
	output["time_played"] = data.get("time_played", 0)
	output["pokedex"] = data.get("pokedex", 0) # TODO: Add pokedex

	return output

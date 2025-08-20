class_name BattleTrainer extends Resource

## Class that holds the data for a trainer during battle.

var name: String = "Trainer" ## The trainer's name
var team: PokemonTeam ## The trainer's team
var is_player: bool = false ## True if the trainer is the player.
var is_wild: bool = false ## True if it's a wild pokemon.
var back_frames: SpriteFrames ## SpriteFrames to show if the trainer is an ally.
var front_sprite: Texture2D ## Sprite to show if the trainer is an enemy. Unused if [member is_wild] is true.


func _init(trainer_name: String, trainer_team: PokemonTeam, trainer_is_player: bool = false, trainer_is_wild: bool = false) -> void:
	name = trainer_name
	team = trainer_team
	is_player = trainer_is_player
	is_wild = trainer_is_wild

## Generates the trainer data for a wild pokemon with [member is_wild] on.
static func make_wild(pokemon: Pokemon) -> BattleTrainer:
	var pokemon_team: PokemonTeam = PokemonTeam.new([pokemon])
	var info: BattleTrainer = BattleTrainer.new("Wild %s" % pokemon.name, pokemon_team, false, true)
	return info

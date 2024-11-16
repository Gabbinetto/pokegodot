class_name Battle extends Node


const DEFAULT_BATTLE_SCENE: PackedScene = preload("res://src/battle/battle.tscn")


@export_group("Setting")
@export var background: TextureRect
@export var ui_message_bg: TextureRect
@export var player_ground: TextureRect
@export var enemy_ground: TextureRect
@export_group("Pokemon sprites")
@export var ally_pokemon_1_sprite: Sprite2D
@export var ally_pokemon_2_sprite: Sprite2D
@export var enemy_pokemon_1_sprite: Sprite2D
@export var enemy_pokemon_2_sprite: Sprite2D


var battleback: Battlebacks.Set = Battlebacks.loaded_sets[0]
var ally_trainers: Array[TrainerBattleInfo] = []
var enemy_trainers: Array[TrainerBattleInfo] = []
var trainers: Array[TrainerBattleInfo]:
	get: return ally_trainers + enemy_trainers
var ally_pokemon: Array[PokemonBattleInfo] = []
var enemy_pokemon: Array[PokemonBattleInfo] = []
var pokemons: Array[PokemonBattleInfo]:
	get: return ally_pokemon + enemy_trainers

func _ready() -> void:
	pass


func _setup(attributes: Dictionary = {}) -> void:
	battleback = Battlebacks.loaded_sets.get(attributes.get("battleback_set"), Battlebacks.loaded_sets[0])

	# Set battleback graphics
	background.texture = battleback.background
	ui_message_bg.texture = battleback.message
	player_ground.texture = battleback.player_base
	enemy_ground.texture = battleback.enemy_base


	# Set trainers and first pokemon
	ally_trainers.append(TrainerBattleInfo.new(
		PlayerData.player_name, PlayerData.team, true
	))
	if attributes.get("ally_trainer", null):
		ally_trainers.append(attributes.get("ally_trainer"))
	
	var enemies: Variant = attributes.get("enemy_trainers")
	if enemies is TrainerBattleInfo:
		enemy_trainers.append(enemies)
	else:
		enemy_trainers.assign(enemies)
	
	for trainer: TrainerBattleInfo in ally_trainers:
		ally_pokemon.append(PokemonBattleInfo.new(trainer.team.first_healthy()))

	for trainer: TrainerBattleInfo in enemy_trainers:
		enemy_pokemon.append(PokemonBattleInfo.new(trainer.team.first_healthy()))
	
	ally_pokemon_1_sprite.texture = ally_pokemon.front().pokemon.sprite_back
	ally_pokemon_2_sprite.texture = ally_pokemon.back().pokemon.sprite_back
	enemy_pokemon_1_sprite.texture = enemy_pokemon.front().pokemon.sprite_front
	enemy_pokemon_2_sprite.texture = enemy_pokemon.back().pokemon.sprite_front


static func start_battle(attributes: Dictionary = {}) -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	var battle: Battle = attributes.get("battle_scene", DEFAULT_BATTLE_SCENE).instantiate()
	layer.add_child(battle)
	layer.name = "BattleLayer"

	battle._setup(attributes)


	Globals.game_root.add_child(layer)


class TrainerBattleInfo:
	var name: String = "Trainer"
	var team: PokemonTeam
	var is_player: bool = false

	func _init(trainer_name: String, trainer_team: PokemonTeam, trainer_is_player: bool = false) -> void:
		name = trainer_name
		team = trainer_team
		is_player = trainer_is_player


class PokemonBattleInfo:
	var pokemon: Pokemon
	var hp: int:
		get: return pokemon.hp
		set(value): pokemon.hp = value

	func _init(_pokemon: Pokemon) -> void:
		pokemon = _pokemon
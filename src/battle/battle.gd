class_name Battle extends Node

enum Actions {
	FIGHT,
	SWITCH,
	ITEM,
}

enum BattleSteps {
	BEFORE_DAMAGE_CALC,
	AFTER_DAMAGE_CALC,
}

const DEFAULT_BATTLE_SCENE: PackedScene = preload("res://src/battle/battle.tscn")

@export_group("State machine")
@export var state_machine: StateMachine
@export var machine_starting_state: State
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
@export_group("UI")
@export var databox_ally_single: Databox
@export var databox_enemy_single: Databox
@export_subgroup("Base commands")
@export var base_commands: Control
@export var fight_button: BaseButton
@export var pokemon_button: BaseButton
@export var bag_button: BaseButton
@export var run_button: BaseButton
@export var selection_dialogue: DialogueManager
@export_subgroup("Fight commands")
@export var fight_commands: Control
@export var move_buttons: Array[MoveButton]
@export var fight_cancel_button: BaseButton
@export var move_info: RichTextLabel


var battleback: Battlebacks.Set = Battlebacks.loaded_sets[0]
var ally_trainers: Array[TrainerBattleInfo] = []
var enemy_trainers: Array[TrainerBattleInfo] = []
var trainers: Array[TrainerBattleInfo]:
	get: return ally_trainers + enemy_trainers
var ally_pokemon: Array[PokemonBattleInfo] = []
var enemy_pokemon: Array[PokemonBattleInfo] = []
var pokemons: Array[PokemonBattleInfo]:
	get:
		var arr: Array[PokemonBattleInfo]
		arr.append_array(ally_pokemon)
		arr.append_array(enemy_pokemon)
		return arr
var current_pokemon_index: int = 0
var current_pokemon: PokemonBattleInfo:
	get:
		if current_pokemon_index >= ally_pokemon.size(): return null
		else: return ally_pokemon[current_pokemon_index]
var turn_order: Array[int]
var turn_selections: Dictionary = {}

var last_move_button_pressed: MoveButton


func _ready() -> void:
	fight_button.grab_focus()

	state_machine.initial_state = machine_starting_state
	state_machine.start()

	
func setup(attributes: Dictionary[String, Variant] = {}) -> void:
	battleback = Battlebacks.loaded_sets.get(attributes.get("battleback"), Battlebacks.loaded_sets[0])

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
		ally_pokemon.append(PokemonBattleInfo.new(trainer.team.first_healthy(), trainer))

	for trainer: TrainerBattleInfo in enemy_trainers:
		enemy_pokemon.append(PokemonBattleInfo.new(trainer.team.first_healthy(), trainer))
	
	ally_pokemon_1_sprite.texture = ally_pokemon.front().pokemon.sprite_back
	ally_pokemon_2_sprite.texture = ally_pokemon.back().pokemon.sprite_back
	enemy_pokemon_1_sprite.texture = enemy_pokemon.front().pokemon.sprite_front
	enemy_pokemon_2_sprite.texture = enemy_pokemon.back().pokemon.sprite_front

	refresh_databoxes()
	refresh_move_buttons()

	#region Connect UI signals
	fight_button.pressed.connect(func():
		base_commands.hide()
		fight_commands.show()
		if last_move_button_pressed and last_move_button_pressed.visible:
			last_move_button_pressed.grab_focus()
		else:
			move_buttons.front().grab_focus()
	)

	fight_cancel_button.pressed.connect(func():
		if current_pokemon_index > 0:
			current_pokemon_index -= 1
			refresh_move_buttons()
			return

		base_commands.show()
		fight_commands.hide()
		fight_button.grab_focus()
	)

	fight_cancel_button.focus_entered.connect(func():
		move_info.text = ""
	)

	for button: MoveButton in move_buttons:
		button.focus_entered.connect(func():
			var text: String = "PP: "
			text += str(button.move.pp) + "/" + str(button.move.total_pp) + "\n"
			text += str(button.move.power) + " - " + str(button.move.accuracy) + "%"
			move_info.text = text
			fight_cancel_button.focus_neighbor_left = button.get_path()
		)
		button.pressed.connect(func():
			last_move_button_pressed = button
		)
	#endregion
	

func refresh_databoxes() -> void:
	if ally_pokemon.size() > 1:
		pass
	else:
		databox_ally_single.show()
		databox_ally_single.enabled = true
		databox_ally_single.pokemon = ally_pokemon.front().pokemon
	
	if enemy_pokemon.size() > 1:
		pass
	else:
		databox_enemy_single.show()
		databox_enemy_single.enabled = true
		databox_enemy_single.pokemon = enemy_pokemon.front().pokemon


func refresh_move_buttons() -> void:
	for i: int in 4:
		if i + 1 > ally_pokemon[current_pokemon_index].pokemon.moves.size():
			move_buttons[i].hide()
		else:
			move_buttons[i].show()
			move_buttons[i].move = ally_pokemon[current_pokemon_index].pokemon.moves[i]
		
		move_buttons[i].pressed.connect(
			func():
				print_debug("Move ", i + 1, " selected")
		)


func refresh_turn_order() -> void:
	pass


static func start_battle(attributes: Dictionary[String, Variant] = {}) -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	var battle: Battle = attributes.get("battle_scene", DEFAULT_BATTLE_SCENE).instantiate()
	layer.add_child(battle)
	layer.name = "BattleLayer"

	battle.setup(attributes)

	Globals.game_root.add_child(layer)


static func damage_calc(battle: Battle, move: PokemonMove, attacker: PokemonBattleInfo, targets: Array[PokemonBattleInfo]) -> Array[int]:
	var values: Array[int]

	for target: PokemonBattleInfo in targets:
		var calculation: DamageCalculation = DamageCalculation.new()
		calculation.battle = battle
		calculation.move = move
		calculation.attacker = attacker
		calculation.target = target

		if move.category == PokemonMove.Categories.PHYSICAL:
			calculation.attack = attacker.attack
			calculation.defense = target.defense
		elif move.category == PokemonMove.Categories.SPECIAL:
			calculation.attack = attacker.spattack
			calculation.defense = target.spdefense
		else:
			calculation.attack = 0

		SignalRouter.battle_step.emit(battle, BattleSteps.BEFORE_DAMAGE_CALC, {"damage": calculation} as Dictionary[String, Variant])

		calculation.random = randf_range(0.85, 1.0)
		calculation.critical_multiplier = Globals.CRITICAL_MULTIPLIER if randf_range(0.0, 1.0) <= (1.0 / 24.0) else 1.0
		calculation.targets_multiplier = 1.0 if targets.size() <= 1 else Globals.MULTIPLE_TARGETS_MULTIPLIER

		SignalRouter.battle_step.emit(battle, BattleSteps.AFTER_DAMAGE_CALC, {"damage": calculation} as Dictionary[String, Variant])

		values.append(calculation.value())

	return values


#region Utility subclasses
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
	var trainer: TrainerBattleInfo
	var hp: int:
		get: return pokemon.hp
		set(value): pokemon.hp = value
	var max_hp: int:
		get: return pokemon.max_hp
		set(value): pokemon.max_hp = value
	var attack: int:
		get: return pokemon.attack
		set(value): pokemon.attack = value
	var defense: int:
		get: return pokemon.defense
		set(value): pokemon.defense = value
	var spattack: int:
		get: return pokemon.spattack
		set(value): pokemon.spattack = value
	var spdefense: int:
		get: return pokemon.spdefense
		set(value): pokemon.spdefense = value
	var speed: int:
		get: return pokemon.speed
		set(value): pokemon.speed = value
	var level: int:
		get: return pokemon.level
		set(value): pokemon.level = value


	func _init(_pokemon: Pokemon, _trainer: TrainerBattleInfo) -> void:
		pokemon = _pokemon
		trainer = _trainer


class TurnAction:
	var type: Actions
	var properties: Dictionary[String, Variant]

	func _init(_type: Actions, _properties: Dictionary[String, Variant]) -> void:
		type = _type
		properties = _properties


## Subclass used to hold values for damage calculations and avoid too much dependency on dictionaries.
class DamageCalculation:
	var attack: int = 0
	var defense: int = 0
	var battle: Battle
	var move: PokemonMove
	var attacker: PokemonBattleInfo
	var target: PokemonBattleInfo
	var random: float = 1.0
	var critical_multiplier: float = 1.0
	var targets_multiplier: float = 1.0
	var weather_multiplier: float = 1.0
	var type_multiplier: float = 1.0
	var stab_multiplier: float = 1.0
	var other_multipliers: float = 1.0

	func value() -> int:
		var a: float = float(attack)
		var d: float = float(defense)
		if critical_multiplier > 1.0:
			pass # Ignore positive stat changes
		var damage: float = roundf((roundf(2.0 * attacker.level / 5.0) + 2.0) * move.power * roundf(a / d) / 50.0) + 2
		damage = damage * random * critical_multiplier * targets_multiplier * weather_multiplier * type_multiplier * stab_multiplier * other_multipliers
		return max(floori(damage), 1 if type_multiplier > 0.0 and move.category != PokemonMove.Categories.STATUS else 0)

#endregion

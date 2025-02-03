class_name Battle extends Node

enum Actions {
	FIGHT,
	ITEM,
	SWITCH,
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
@export_group("Animation")
@export var animation_player: AnimationPlayer
@export_group("UI")
@export var all_commands: Array[CanvasItem]
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
@export_group("Target selection")
@export var target_commands: Control
@export var target_buttons: Array[Button] ## Target buttons when choosing a target in double battles. Should select the allies first, then the foes.
@export var target_cancel_button: BaseButton
@export_group("Battle text")
@export var battle_dialogue_box: Control
@export var battle_dialogue: DialogueManager


var double_battle: bool = false
var trainer_battle: bool = false
var battleback: Battlebacks.Set = Battlebacks.loaded_sets[0]
var ally_trainers: Array[TrainerBattleInfo] = []
var enemy_trainers: Array[TrainerBattleInfo] = []
var trainers: Array[TrainerBattleInfo]:
	get: return ally_trainers + enemy_trainers
var pokemons: Array[PokemonBattleInfo] = [null, null, null, null]
var ally_pokemon: Array[PokemonBattleInfo]:
	get: return pokemons.slice(0, 2)
var enemy_pokemon: Array[PokemonBattleInfo]:
	get: return pokemons.slice(2, -1)
var current_pokemon_index: int = 0
var current_pokemon: PokemonBattleInfo:
	get: return ally_pokemon[current_pokemon_index]
var turn_order: Array[int]
var turn_selections: Dictionary[PokemonBattleInfo, TurnAction] = {}

var last_move_button_pressed: MoveButton


func _ready() -> void:
	fight_button.grab_focus()

	state_machine.initial_state = machine_starting_state
	state_machine.start()


func show_commands(command: CanvasItem) -> void:
	for child: CanvasItem in all_commands:
		if child == command:
			child.show()
		else:
			child.hide()


func show_text(dialogue: DialogueManager, text: String) -> void:
	dialogue.dialogues.front().text = (text)
	dialogue.start()


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
	

	pokemons[0] = PokemonBattleInfo.new(ally_trainers[0].team.first_healthy(), ally_trainers[0])
	pokemons[2] = PokemonBattleInfo.new(enemy_trainers[0].team.first_healthy(), enemy_trainers[0])
	# Set double battle
	double_battle = attributes.get("double_battle", false)
	if double_battle:
		if ally_trainers.size() > 1:
			pokemons[1] = PokemonBattleInfo.new(ally_trainers[1].team.first_healthy(), ally_trainers[1])
		else:
			pokemons[1] = PokemonBattleInfo.new(ally_trainers[0].team.second_healthy(), ally_trainers[0])
		if enemy_trainers.size() > 1:
			pokemons[1] = PokemonBattleInfo.new(enemy_trainers[1].team.first_healthy(), enemy_trainers[1])
		else:
			pokemons[1] = PokemonBattleInfo.new(enemy_trainers[0].team.second_healthy(), enemy_trainers[0])

	refresh_pokemon_sprites()
	refresh_databoxes()
	refresh_move_buttons()

	#region Connect UI signals
	base_commands.visibility_changed.connect(func():
		if not base_commands.visible:
			return
		fight_button.grab_focus()
	)
	
	#region Fight command signals
	fight_button.pressed.connect(func():
		show_commands(fight_commands)
	)
	fight_commands.visibility_changed.connect(func():
		if not fight_commands.visible:
			return
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
		show_commands(base_commands)
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
	
	#region Target select signals
	target_commands.visibility_changed.connect(func():
		if not target_commands.visible:
			return
		for button: Button in target_buttons:
			if not button.disabled:
				button.grab_focus()
				break
	)
	target_cancel_button.pressed.connect(func():
		show_commands(fight_commands)
	)
	#endregion
	#endregion


func end_battle() -> void:
	SignalRouter.battle_ended.emit(self)
	queue_free()


func refresh_pokemon_sprites() -> void:
	ally_pokemon_1_sprite.texture = ally_pokemon.front().pokemon.sprite_back if ally_pokemon.front() else null
	ally_pokemon_2_sprite.texture = ally_pokemon.back().pokemon.sprite_back if ally_pokemon.back() else null
	enemy_pokemon_1_sprite.texture = enemy_pokemon.front().pokemon.sprite_front if enemy_pokemon.front() else null
	enemy_pokemon_2_sprite.texture = enemy_pokemon.back().pokemon.sprite_front if enemy_pokemon.back() else null



func refresh_databoxes() -> void:
	if ally_pokemon.filter(func(item: PokemonBattleInfo): return item != null).size() > 1:
		pass
	else:
		databox_ally_single.show()
		databox_ally_single.enabled = true
		databox_ally_single.pokemon = ally_pokemon.front().pokemon
	
	if enemy_pokemon.filter(func(item: PokemonBattleInfo): return item != null).size() > 1:
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


func refresh_target_buttons() -> void:
	for i: int in pokemons.size():
		target_buttons[i].text = pokemons[i].pokemon.name if pokemons[i] else ""


func refresh_turn_order(acted: Array[PokemonBattleInfo] = []) -> void:
	turn_order.clear()
	for i: int in pokemons.size():
		if pokemons[i] and not acted.has(pokemons[i]):
			turn_order.append(i)

	turn_order.sort_custom(
		func(a: int, b: int):
			if turn_selections.get(pokemons[a]).type > turn_selections.get(pokemons[b]).type:
				return true
			if pokemons[a].speed == pokemons[b].speed:
				return randf() <= 0.5
			return pokemons[a].speed > pokemons[b].speed
	)


static func start_battle(attributes: Dictionary[String, Variant] = {}) -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	var battle: Battle = attributes.get("battle_scene", DEFAULT_BATTLE_SCENE).instantiate()
	layer.add_child(battle)
	layer.name = "BattleLayer"

	battle.setup(attributes)

	Globals.game_root.add_child(layer)
	
	var on_finish: Callable = func(finished_battle: Battle):
		if finished_battle == battle:
			layer.queue_free()
	
	SignalRouter.battle_ended.connect(on_finish, CONNECT_ONE_SHOT)


static func damage_calc(battle: Battle, move: PokemonMove, attacker: PokemonBattleInfo, targets: Array[PokemonBattleInfo]) -> Array[int]:
	var values: Array[int]
	values.resize(battle.pokemons.size())
	values.fill(-1)

	for target: PokemonBattleInfo in targets:
		var index: int = battle.pokemons.find(target)
		if index == -1:
			continue
			
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

		values[index] = calculation.value()

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
			pass # TODO: Ignore positive stat changes
		var damage: float = roundf((roundf(2.0 * attacker.level / 5.0) + 2.0) * move.power * roundf(a / d) / 50.0) + 2
		damage = damage * random * critical_multiplier * targets_multiplier * weather_multiplier * type_multiplier * stab_multiplier * other_multipliers
		return max(floori(damage), 1 if type_multiplier > 0.0 and move.category != PokemonMove.Categories.STATUS else 0)

#endregion

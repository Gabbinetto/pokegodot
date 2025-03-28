class_name Battle extends Node

## Type of actions that can be selected.
enum Actions {
	FIGHT,
	ITEM,
	SWITCH,
	RUN,
}

## All possible battle steps that can be useful for [BattleEffect]s and such.
enum BattleSteps {
	BEFORE_DAMAGE_CALC,
	AFTER_DAMAGE_CALC,
}

## The default battle scene.
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
@export var ui_layer: CanvasLayer
@export var all_commands: Array[CanvasItem]
@export var databox_ally_single: Databox
@export var databox_enemy_single: Databox
@export_subgroup("Base commands")
@export var base_commands: Control
@export var fight_button: BaseButton
@export var pokemon_button: BaseButton
@export var bag_button: BaseButton
@export var run_button: BaseButton
@export_subgroup("Fight commands")
@export var fight_commands: Control
@export var move_buttons: Array[MoveButton]
@export var fight_cancel_button: BaseButton
@export var move_info: RichTextLabel
@export_group("Target selection")
@export var target_commands: Control
@export var target_buttons: Array[Button] ## Target buttons when choosing a target in double battles. Should select the allies first, then the foes.
@export var target_cancel_button: BaseButton
@export_group("Dialogues")
@export var selection_dialogue: Dialogue
@export var battle_dialogue: Dialogue


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
	get: return pokemons.slice(2, 4)
var current_pokemon_index: int = 0
var current_pokemon: PokemonBattleInfo:
	get: return ally_pokemon[current_pokemon_index]
var turn_order: Array[int]
var turn_selections: Dictionary[int, TurnAction] = {}
var escape_attempts: int = 0

var last_move_button_pressed: MoveButton



func _ready() -> void:
	fight_button.grab_focus.call_deferred()

	state_machine.initial_state = machine_starting_state
	state_machine.start()
	
	Globals.current_battle = self


## Shows [param command] while hiding all other commands.
func show_commands(command: CanvasItem) -> void:
	for child: CanvasItem in all_commands:
		if child == command:
			child.show()
		else:
			child.hide()


## Shows a text in battle. If [param selection] is true, the text is shown in the small textbox near the battle commands.
func show_text(text: String, selection: bool = false) -> void:
	var dialogue: Dialogue = selection_dialogue if selection else battle_dialogue
	var manager: DialogueManager = dialogue.get_meta("manager") if dialogue.has_meta("manager") else null
	if not manager:
		for child: Node in dialogue.get_children():
			if child is DialogueManager:
				manager = child
				dialogue.set_meta("manager", manager)
				break
	# The dialogue manager first child should be a DialogueTextEvent
	manager.get_child(0).text = text
	dialogue.run_dialogue(manager)
	await dialogue.finished
	return
	

## Sets up the battle according to [param attributes].
## Possible attributes are: [br]
## - [code]double_battle[/code]: True if it is a double battle. False by default.[br]
## - [code]ally_trainer[/code]: The ally trainer for a double battle with an NPC ally.[br]
## - [code]enemy_trainers[/code]: The enemy trainers. If it is a single battle, it can be just [TrainerBattleInfo] instead of being an array of these.[br]
## - [code]battleback[/code]: A [member Battlebacks.Sets].[br]
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

	refresh_visuals()

	#region Connect UI signals
	base_commands.visibility_changed.connect(_on_base_commands_visibility_changed)
	
	#region Fight command signals
	fight_button.pressed.connect(show_commands.bind(fight_commands))
	fight_commands.visibility_changed.connect(_on_fight_commands_visibility_changed)

	fight_cancel_button.pressed.connect(_on_fight_cancel)

	fight_cancel_button.focus_entered.connect(move_info.set.bind("text", ""))

	for button: MoveButton in move_buttons:
		button.focus_entered.connect(_on_move_focus.bind(button))
		button.pressed.connect(set.bind("last_move_button_pressed", button))
	#endregion
	
	#region Target select signals
	target_commands.visibility_changed.connect(_on_target_commands_visibility_changed)
	target_cancel_button.pressed.connect(show_commands.bind(fight_commands))
	#endregion
	
	#endregion
	#endregion


#region Button functions
func _on_base_commands_visibility_changed() -> void:
	if not base_commands.visible:
		return
	fight_button.grab_focus.call_deferred()

func _on_fight_commands_visibility_changed() -> void:
	if not fight_commands.visible:
		return
	if last_move_button_pressed and last_move_button_pressed.visible:
		last_move_button_pressed.grab_focus.call_deferred()
	else:
		move_buttons.front().grab_focus.call_deferred()

func _on_fight_cancel() -> void:
	if current_pokemon_index > 0:
		current_pokemon_index -= 1
		refresh_move_buttons()
		return
	show_commands(base_commands)

func _on_move_focus(button: MoveButton) -> void:
	var text: String = "PP: "
	text += str(button.move.pp) + "/" + str(button.move.total_pp) + "\n"
	text += str(button.move.power) + " - " + str(button.move.accuracy) + "%"
	move_info.text = text
	fight_cancel_button.focus_neighbor_left = button.get_path()

func _on_target_commands_visibility_changed() -> void:
	if not target_commands.visible:
		return
	for button: Button in target_buttons:
		if not button.disabled:
			button.grab_focus.call_deferred()
			break

#endregion


## Ends the battle, emitting all the signals needed and showing the proper animations.
func end_battle() -> void:
	Globals.current_battle = null
	SignalRouter.battle_ended.emit(self)
	queue_free()


## Calls [method refresh_databoxes], [method refresh_move_buttons], [method refresh_pokemon_sprites] and [method refresh_target_buttons].
func refresh_visuals() -> void:
	refresh_databoxes()
	refresh_move_buttons()
	refresh_pokemon_sprites()
	refresh_target_buttons()


## Sets the pokemon sprites to the current pokemon in [member pokemons].
func refresh_pokemon_sprites() -> void:
	ally_pokemon_1_sprite.texture = ally_pokemon.front().pokemon.sprite_back if ally_pokemon.front() else null
	ally_pokemon_2_sprite.texture = ally_pokemon.back().pokemon.sprite_back if ally_pokemon.back() else null
	enemy_pokemon_1_sprite.texture = enemy_pokemon.front().pokemon.sprite_front if enemy_pokemon.front() else null
	enemy_pokemon_2_sprite.texture = enemy_pokemon.back().pokemon.sprite_front if enemy_pokemon.back() else null


## Assigns the current pokemon to the databoxes and hides them if needed.
func refresh_databoxes() -> void:
	if double_battle:
		pass
	else:
		databox_ally_single.show()
		databox_ally_single.enabled = true
		databox_ally_single.pokemon = ally_pokemon.front().pokemon
	
		databox_enemy_single.show()
		databox_enemy_single.enabled = true
		databox_enemy_single.pokemon = enemy_pokemon.front().pokemon


## Shows the current pokemon's moves in the move buttons.
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


## Update the target buttons with the current pokemon on the field.
func refresh_target_buttons() -> void:
	for i: int in pokemons.size():
		target_buttons[i].text = pokemons[i].pokemon.name if pokemons[i] else ""


## Refreshes the turn order, excluding the pokemon slots who have acted. [br][br]
## [param acted] Holds the indexes of the pokemon in [member pokemons].
func refresh_turn_order(acted: Array[int] = []) -> void:
	turn_order.clear()
	for i: int in pokemons.size():
		if pokemons[i] and not acted.has(i) and pokemons[i].hp > 0:
			turn_order.append(i)

	var sort_by_speed: Callable = func(a: int, b: int):
		if pokemons[a].speed == pokemons[b].speed:
			return Globals.rng.randf() <= 0.5
		return pokemons[a].speed > pokemons[b].speed
	
	turn_order.sort_custom(sort_by_speed)
	turn_order.sort_custom(func(a: int, b: int):
		return turn_selections.get(a).type > turn_selections.get(b).type
	)


## Performs a switch, refreshing databoxes, sprites and target buttons.
func switch(from_slot: int, to: Pokemon) -> void:
	var new_mon: PokemonBattleInfo = PokemonBattleInfo.new(
		to, pokemons[from_slot].trainer
	)
	pokemons[from_slot] = new_mon
	refresh_databoxes()
	refresh_pokemon_sprites()
	refresh_target_buttons()


## Calculates the chance to flee based on the first ally pokemon and the first enemy pokemon.
func calc_escape_chance() -> float:
	if ally_pokemon[0].speed >= enemy_pokemon[0].speed:
		return 1.0
	escape_attempts += 1
	return (floorf((ally_pokemon[0].speed * 32.0)/(enemy_pokemon[0].speed * 4.0)) + (30.0 * escape_attempts)) / 256.0
	


## Starts a battle by creating a dedicated [CanvasLayer] and adding it to [member Globals.game_root].
## Stops [member Globals.game_world] from processing while the battle is on.[br]
## When the battle ends, it is freed. Calls [method setup] with [param attributes].
static func start_battle(attributes: Dictionary[String, Variant] = {}) -> Battle:
	if PlayerData.team.get_array().is_empty() or not PlayerData.team.first_healthy():
		printerr("Can't start battle without a pokemon team or a healthy pokemon.")
		return
	var layer: CanvasLayer = CanvasLayer.new()
	var battle: Battle = attributes.get("battle_scene", DEFAULT_BATTLE_SCENE).instantiate()
	layer.add_child(battle)
	layer.name = "BattleLayer"

	battle.setup(attributes)

	Globals.game_root.add_child(layer)
	# Stop running the game world while the battle is happening
	Globals.game_world.process_mode = Node.PROCESS_MODE_DISABLED
	
	var on_finish: Callable = func(finished_battle: Battle):
		if finished_battle == battle:
			# Make sure movement and event input is enabled after battle.
			Globals.movement_enabled = true
			Globals.event_input_enabled = true
			Globals.game_world.process_mode = Node.PROCESS_MODE_PAUSABLE
			layer.queue_free()
	
	SignalRouter.battle_ended.connect(on_finish, CONNECT_ONE_SHOT)
	return battle


static func damage_calc(battle: Battle, move: PokemonMove, attacker: PokemonBattleInfo, targets: Array[PokemonBattleInfo]) -> Array[DamageCalculation]:
	var values: Array[DamageCalculation]
	values.resize(battle.pokemons.size())
	
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
		calculation.type_multiplier = Types.get_interaction(move.type, target.pokemon.species.types)

		SignalRouter.battle_step.emit(battle, BattleSteps.AFTER_DAMAGE_CALC, {"damage": calculation} as Dictionary[String, Variant])

		values[index] = calculation

	return values


#region Utility subclasses
## Subclass that holds the data for a trainer during battle.
class TrainerBattleInfo:
	var name: String = "Trainer" ## The trainer's name
	var team: PokemonTeam ## The trainer's team
	var is_player: bool = false ## True if the trainer is the player.
	var is_wild: bool = false ## True if it's a wild pokemon.

	func _init(trainer_name: String, trainer_team: PokemonTeam, trainer_is_player: bool = false, trainer_is_wild: bool = false) -> void:
		name = trainer_name
		team = trainer_team
		is_player = trainer_is_player
		is_wild = trainer_is_wild
	
	## Generates the trainer data for a wild pokemon with [member is_wild] on.
	static func make_wild(pokemon: Pokemon) -> TrainerBattleInfo:
		var pokemon_team: PokemonTeam = PokemonTeam.new([pokemon])
		var info: TrainerBattleInfo = TrainerBattleInfo.new("Wild %s" % pokemon.name, pokemon_team, false, true)
		return info


## Subclass that holds the data for a pokemon during battle. Mainly useful for volatile effects.
class PokemonBattleInfo:
	var pokemon: Pokemon ## The pokemon bound to this class.
	var trainer: TrainerBattleInfo ## This pokemon's trainer.
	var species: PokemonSpecies: ## Shorthand for [member Pokemon.species]
		get: return pokemon.species
		set(value): pokemon.species = value
	var hp: int: ## Shorthand for [member Pokemon.hp]
		get: return pokemon.hp
		set(value): pokemon.hp = value
	var max_hp: int: ## Shorthand for [member Pokemon.max_hp]
		get: return pokemon.max_hp
		set(value): pokemon.max_hp = value
	var attack: int: ## Shorthand for [member Pokemon.attack]
		get: return pokemon.attack
		set(value): pokemon.attack = value
	var defense: int: ## Shorthand for [member Pokemon.defense]
		get: return pokemon.defense
		set(value): pokemon.defense = value
	var spattack: int: ## Shorthand for [member Pokemon.spattack]
		get: return pokemon.spattack
		set(value): pokemon.spattack = value
	var spdefense: int: ## Shorthand for [member Pokemon.spdefense]
		get: return pokemon.spdefense
		set(value): pokemon.spdefense = value
	var speed: int: ## Shorthand for [member Pokemon.speed]
		get: return pokemon.speed
		set(value): pokemon.speed = value
	var level: int: ## Shorthand for [member Pokemon.level]
		get: return pokemon.level
		set(value): pokemon.level = value


	func _init(_pokemon: Pokemon, _trainer: TrainerBattleInfo) -> void:
		pokemon = _pokemon
		trainer = _trainer


## Subclass used to describe a turn action, with all the related properties.
class TurnAction:
	var type: Actions ## The type of action.
	var properties: Dictionary[String, Variant] ## Properties useful to the action, such as the switched in pokemon during a switch out.

	func _init(_type: Actions, _properties: Dictionary[String, Variant] = {}) -> void:
		type = _type
		properties = _properties


## Subclass used to hold values for damage calculations.
##
## As [BattleEffect]s work through signals, this allows to pass a reference to the
## damage calculation without depending too much on dictionaries. [br][br]
## The data is set outside of the class, in [method Battle.damage_calc]. 
class DamageCalculation:
	var attack: int = 0 ## The used attack stat.
	var defense: int = 0 ## The used defense stat.
	var battle: Battle ## A reference to the battle this is used in.
	var move: PokemonMove ## The used move.
	var attacker: PokemonBattleInfo ## The pokemon who attacks.
	var target: PokemonBattleInfo ## The pokemon who gets attacked.
	var random: float = 1.0 ## The 15% random damage fluctuation.
	var critical_multiplier: float = 1.0 ## Equals to [member Globals.CRITICAL_MULTIPLIER] when a critical hit lands.
	var targets_multiplier: float = 1.0 ## Equals to [member Globals.MULTIPLE_TARGETS_MULTIPLIER] when there's more than one target.
	var weather_multiplier: float = 1.0 ## Increases the move's power with a favorable weather.
	var type_multiplier: float = 1.0 ## The multiplier for type interactions.
	var stab_multiplier: float = 1.0 ## The multiplier for stab.
	var other_multipliers: float = 1.0 ## Misc multipliers, often used by [BattleEffect]s


	## Calculates the values based on the data.
	func value() -> int:
		if type_multiplier == 0.0 or move.category == PokemonMove.Categories.STATUS:
			return 0
		var a: float = float(attack)
		var d: float = float(defense)
		if critical_multiplier > 1.0:
			pass # TODO: Ignore positive stat changes
		var damage: float = roundf((roundf(2.0 * attacker.level / 5.0) + 2.0) * move.power * roundf(a / d) / 50.0) + 2
		damage = damage * random * critical_multiplier * targets_multiplier * weather_multiplier * type_multiplier * stab_multiplier * other_multipliers
		return max(floori(damage), 1)

#endregion

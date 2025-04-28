class_name Battle extends Node

signal buffer_ran(buffer: Dictionary)
signal last_buffer_ran(buffer: Dictionary)

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
	AFTER_MOVE_ANIMATION,
}

enum BufferType {TEXT, ANIMATION, DATABOX}

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
@export var sprites: Array[Sprite2D] = [null, null, null, null]
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
@export_subgroup("Target selection commands")
@export var target_commands: Control
@export var target_buttons: Array[Button] ## Target buttons when choosing a target in double battles. Should select the allies first, then the foes.
@export var target_cancel_button: BaseButton
@export_group("Dialogues")
@export var selection_dialogue: Dialogue
@export var battle_dialogue: Dialogue


var double_battle: bool = false
var trainer_battle: bool = false
var battleback: Battlebacks.Set = Battlebacks.loaded_sets[0]
var ally_trainers: Array[BattleTrainer] = []
var enemy_trainers: Array[BattleTrainer] = []
var trainers: Array[BattleTrainer]:
	get: return ally_trainers + enemy_trainers
var pokemons: Array[BattlePokemon] = [null, null, null, null]
var ally_pokemon: Array[BattlePokemon]:
	get: return pokemons.slice(0, 2)
var enemy_pokemon: Array[BattlePokemon]:
	get: return pokemons.slice(2, 4)
var current_pokemon_index: int = 0
var current_pokemon: BattlePokemon:
	get: return ally_pokemon[current_pokemon_index]
var turn_order: Array[int]
var turn_selections: Dictionary[int, TurnAction] = {}
var escape_attempts: int = 0
var is_buffering: bool:
	get: return _buffering
var _buffer: Array[Dictionary] = []
var _buffering: bool = false

var last_move_button_pressed: MoveButton



func _ready() -> void:
	if TransitionManager.transition:
		TransitionManager.play_out()
		await TransitionManager.finished
	
	fight_button.grab_focus.call_deferred()

	state_machine.initial_state = machine_starting_state
	state_machine.start()
	
	Globals.current_battle = self


func _process(_delta: float) -> void:
	if not _buffering:
		_execute_buffer()
	


## Shows [param command] while hiding all other commands.
func show_commands(command: CanvasItem) -> void:
	for child: CanvasItem in all_commands:
		if child == command:
			child.show()
		else:
			child.hide()

#region Buffer functions
## Shows a text in battle, adding it to the buffer.
func show_text(text: String) -> void:
	await add_buffer(BufferType.TEXT, text)


## Plays a [BattleAnimation], adding it to the buffer.
func play_animation(animation: BattleAnimation) -> void:
	await add_buffer(BufferType.ANIMATION, animation)


## Animates the given [param databox], adding it to the buffer.
func animate_databox(databox: Databox) -> void:
	await add_buffer(BufferType.DATABOX, databox)


## Returns the slot (the index) of [param pokemon], which can be either [BattlePokemon] or [Pokemon].
func get_slot(pokemon: Variant) -> int:
	if pokemon is BattlePokemon:
		return pokemons.find(pokemon)
	elif pokemon is Pokemon:
		for slot: BattlePokemon in pokemons:
			if slot and slot.pokemon == pokemon:
				return pokemons.find(slot)
	return -1


func add_buffer(type: BufferType, data: Variant = null) -> void:
	_buffer.append(
		{
			"type": type,
			"data": data,
		}
	)

func _execute_buffer() -> void:
	if _buffer.is_empty():
		return

	_buffering = true
	var buffer: Dictionary = _buffer.pop_front()
	match buffer.type:
		BufferType.TEXT:
			var data: String = buffer.data
			var manager: DialogueManager = battle_dialogue.get_meta("manager") if battle_dialogue.has_meta("manager") else null
			if not manager:
				for child: Node in battle_dialogue.get_children():
					if child is DialogueManager:
						manager = child
						battle_dialogue.set_meta("manager", manager)
						break
			manager.starting_sequence.text = data
			battle_dialogue.run_dialogue(manager)
			await battle_dialogue.finished
		BufferType.ANIMATION:
			var data: BattleAnimation = buffer.data
			data.play()
			await data.finished
		BufferType.DATABOX:
			var data: Databox = buffer.data
			await data.animate_hp_bar().finished
	_buffering = false
	buffer_ran.emit(buffer)
	if _buffer.is_empty():
		last_buffer_ran.emit(buffer)
#endregion

## Sets up the battle according to [param attributes].
## Possible attributes are: [br]
## - [code]double_battle[/code]: True if it is a double battle. False by default.[br]
## - [code]ally_trainer[/code]: The ally trainer for a double battle with an NPC ally.[br]
## - [code]enemy_trainers[/code]: The enemy trainers. If it is a single battle, it can be just [BattleTrainer] instead of being an array of these.[br]
## - [code]battleback[/code]: A [member Battlebacks.Sets].[br]
func setup(attributes: Dictionary[String, Variant] = {}) -> void:
	battleback = Battlebacks.loaded_sets.get(attributes.get("battleback"), Battlebacks.loaded_sets[0])

	# Set battleback graphics
	background.texture = battleback.background
	ui_message_bg.texture = battleback.message
	player_ground.texture = battleback.player_base
	enemy_ground.texture = battleback.enemy_base


	# Set trainers and first pokemon
	ally_trainers.append(BattleTrainer.new(
		PlayerData.player_name, PlayerData.team, true
	))
	if attributes.get("ally_trainer", null):
		ally_trainers.append(attributes.get("ally_trainer"))
	
	var enemies: Variant = attributes.get("enemy_trainers")
	if enemies is BattleTrainer:
		enemy_trainers.append(enemies)
	else:
		enemy_trainers.assign(enemies)
	

	pokemons[0] = BattlePokemon.new(self, ally_trainers[0].team.first_healthy(), ally_trainers[0])
	pokemons[2] = BattlePokemon.new(self, enemy_trainers[0].team.first_healthy(), enemy_trainers[0])
	# Set double battle
	double_battle = attributes.get("double_battle", false)
	if double_battle:
		if ally_trainers.size() > 1:
			pokemons[1] = BattlePokemon.new(self, ally_trainers[1].team.first_healthy(), ally_trainers[1])
		else:
			pokemons[1] = BattlePokemon.new(self, ally_trainers[0].team.second_healthy(), ally_trainers[0])
		if enemy_trainers.size() > 1:
			pokemons[1] = BattlePokemon.new(self, enemy_trainers[1].team.first_healthy(), enemy_trainers[1])
		else:
			pokemons[1] = BattlePokemon.new(self, enemy_trainers[0].team.second_healthy(), enemy_trainers[0])

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
		button.gui_input.connect(_on_move_gui_input)
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


func _on_move_gui_input(input: InputEvent) -> void:
	if input.is_action_pressed("ui_cancel"):
		_on_fight_cancel()


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
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	TransitionManager.finished.connect(
		func():
			Globals.current_battle = null
			SignalRouter.battle_ended.emit(self)
			queue_free()
	)


## Calls [method refresh_databoxes], [method refresh_move_buttons], [method refresh_pokemon_sprites] and [method refresh_target_buttons].
func refresh_visuals() -> void:
	refresh_databoxes()
	refresh_move_buttons()
	refresh_pokemon_sprites()
	refresh_target_buttons()


## Sets the pokemon sprites to the current pokemon in [member pokemons].
func refresh_pokemon_sprites() -> void:
	for i: int in sprites.size():
		var pokemon: BattlePokemon = pokemons[i]
		if not pokemon:
			sprites[i].texture = null
		elif pokemon in ally_pokemon:
			sprites[i].texture = pokemon.pokemon.sprite_back
		else:
			sprites[i].texture = pokemon.pokemon.sprite_front



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
		
		#move_buttons[i].pressed.connect()


## Update the target buttons with the current pokemon on the field.
func refresh_target_buttons() -> void:
	for i: int in pokemons.size():
		target_buttons[i].text = pokemons[i].name if pokemons[i] else ""


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
	var new_mon: BattlePokemon = BattlePokemon.new(
		self, to, pokemons[from_slot].trainer
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
	if Globals.in_battle:
		printerr("Can't start a battle while another one is in progress.")
		return
	
	if PlayerData.team.get_array().is_empty() or not PlayerData.team.first_healthy():
		printerr("Can't start battle without a pokemon team or a healthy pokemon.")
		return
	var layer: CanvasLayer = CanvasLayer.new()
	var battle: Battle = attributes.get("battle_scene", DEFAULT_BATTLE_SCENE).instantiate()
	layer.add_child(battle)
	layer.name = "BattleLayer"

	battle.setup(attributes)

	TransitionManager.layer += 5 # Make sure the transitions appear on top
	TransitionManager.play_in(TransitionManager.TransitionTypes.WILD_BATTLE)
	await TransitionManager.finished

	Globals.game_root.add_child(layer)
	# Stop running the game world while the battle is happening
	Globals.game_world.process_mode = Node.PROCESS_MODE_DISABLED
	
	var on_finish: Callable = func(finished_battle: Battle):
		if finished_battle == battle:
			# Make sure movement and event input is enabled after battle.
			layer.queue_free()
			layer.tree_exited.connect(
				func():
					if TransitionManager.transition:
						TransitionManager.play_out()
						await TransitionManager.finished
						TransitionManager.layer -= 5
					Globals.movement_enabled = true
			)
			Globals.movement_enabled = true
			Globals.event_input_enabled = true
			Globals.game_world.process_mode = Node.PROCESS_MODE_PAUSABLE

	
	SignalRouter.battle_ended.connect(on_finish, CONNECT_ONE_SHOT)
	return battle


static func damage_calc(battle: Battle, move: PokemonMove, attacker: BattlePokemon, targets: Array[BattlePokemon]) -> Array[DamageCalculation]:
	var values: Array[DamageCalculation]
	values.resize(battle.pokemons.size())

	for target: BattlePokemon in targets:
		var index: int = battle.pokemons.find(target)
		if index == -1:
			continue
			
		var calculation: DamageCalculation = DamageCalculation.new()
		calculation.battle = battle
		calculation.move = move
		calculation.attacker = attacker
		calculation.target = target

		if move.category == PokemonMove.Categories.PHYSICAL:
			calculation.attack_stat = Globals.STATS.ATTACK
			calculation.defense_stat = Globals.STATS.DEFENSE
		elif move.category == PokemonMove.Categories.SPECIAL:
			calculation.attack_stat = Globals.STATS.SPECIAL_ATTACK
			calculation.defense_stat = Globals.STATS.SPECIAL_DEFENSE
		
		# TODO: Complete accuracy check: https://bulbapedia.bulbagarden.net/wiki/Accuracy#Generation_V_onward
		var accuracy: float = move.accuracy * BattlePokemon.get_accuracy_multiplier(
			attacker.boosts[Globals.OTHER_STATS.ACCURACY], target.boosts[Globals.OTHER_STATS.ACCURACY]
		)
		calculation.miss = Globals.rng.randf_range(0.0, 100.0) > accuracy
		
		SignalRouter.battle_step.emit(battle, BattleSteps.BEFORE_DAMAGE_CALC, {"damage": calculation} as Dictionary[String, Variant])

		calculation.random = randf_range(0.85, 1.0)
		calculation.critical_multiplier = Globals.CRITICAL_MULTIPLIER if randf_range(0.0, 1.0) <= (1.0 / 24.0) else 1.0
		calculation.targets_multiplier = 1.0 if targets.size() <= 1 else Globals.MULTIPLE_TARGETS_MULTIPLIER
		calculation.type_multiplier = Types.get_interaction(move.type, target.pokemon.species.types)
		if calculation.type_multiplier == 0:
			calculation.miss = true

		SignalRouter.battle_step.emit(battle, BattleSteps.AFTER_DAMAGE_CALC, {"damage": calculation} as Dictionary[String, Variant])

		values[index] = calculation

	return values


#region Utility subclasses
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
## damage calculation without depending too much on dictionaries.[br][br]
## The data is set outside of the class, in [method Battle.damage_calc]. 
class DamageCalculation:
	var attack_stat: String ## The used attack stat.
	var defense_stat: String ## The used defense stat.
	var battle: Battle ## A reference to the battle this is used in.
	var move: PokemonMove ## The used move.
	var attacker: BattlePokemon ## The pokemon who attacks.
	var target: BattlePokemon ## The pokemon who gets attacked.
	var random: float = 1.0 ## The 15% random damage fluctuation.
	var critical_multiplier: float = 1.0 ## Equals to [member Globals.CRITICAL_MULTIPLIER] when a critical hit lands.
	var targets_multiplier: float = 1.0 ## Equals to [member Globals.MULTIPLE_TARGETS_MULTIPLIER] when there's more than one target.
	var weather_multiplier: float = 1.0 ## Increases the move's power with a favorable weather.
	var type_multiplier: float = 1.0 ## The multiplier for type interactions.
	var stab_multiplier: float = 1.0 ## The multiplier for stab.
	var other_multipliers: float = 1.0 ## Misc multipliers, often used by [BattleEffect]s.
	var miss: bool = false ## True if missed.

	## Calculates the values based on the data.
	func value() -> int:
		if type_multiplier == 0.0 or move.category == PokemonMove.Categories.STATUS or miss:
			return 0
		var a: float = float(attacker.get_stat(attack_stat))
		var d: float = float(target.get_stat(defense_stat))
		if critical_multiplier > 1.0:
			if attacker.boosts[attack_stat] < 0:
				a = attacker.raw[attack_stat]
			if attacker.boosts[attack_stat] > 0:
				d = target.raw[defense_stat]
		var damage: float = roundf((roundf(2.0 * attacker.level / 5.0) + 2.0) * move.power * roundf(a / d) / 50.0) + 2
		damage = damage * random * critical_multiplier * targets_multiplier * weather_multiplier * type_multiplier * stab_multiplier * other_multipliers
		return max(floori(damage), 1)
#endregion

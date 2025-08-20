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

## Possible battle outcomes.
enum Outcomes {
	NONE,
	RAN_AWAY,
	WIN,
	LOSS,
}

## All possible battle steps that can be useful for [BattleEffect]s and such.
enum BattleSteps {
	BEFORE_DAMAGE_CALC,
	AFTER_DAMAGE_CALC,
	AFTER_MOVE_ANIMATION,
}

## All possible events that gets processed in the buffer.
enum BufferType {
	TEXT, ## Show text.
	ANIMATION, ## Show a [BattleAnimation].
	DATABOX_HP, ## Update databoxes hp bar, animating them.
	DATABOX_LEVEL, ## Update databoxes levels, animating the exp bar once.
	POKEMON_FAINT, ## Add EXP to the player's pokemon after a KO, animating the databoxes and learning eventual moves.
	FUNCTION_CALL, ## Generic function call. Awaits the function in case of a couroutine.
	TURN_EXECUTION, ## Execute a [Battle.TurnAction].
	FAINTED_SWITCH, ## Prompt a switch when an ally pokemon faints.
}

## The default battle scene.
const DEFAULT_BATTLE_SCENE: PackedScene = preload("res://src/battle/battle.tscn")
const BOY_SPRITEFRAMES: SpriteFrames = preload("res://assets/resources/battle_back_sprites/boy.tres")
const GIRL_SPRITEFRAMES: SpriteFrames = preload("res://assets/resources/battle_back_sprites/girl.tres")

@export_group("State machine")
@export var state_machine: StateMachine
@export var machine_starting_state: State
@export_group("Setting")
@export var background: TextureRect
@export var player_ground: TextureRect
@export var enemy_ground: TextureRect
@export_group("Sprites")
@export var sprites: Array[PokemonBodySprite] = [null, null, null, null]
@export var ally_trainer_sprites: Array[AnimatedSprite2D] = []
@export var enemy_trainer_sprites: Array[Sprite2D] = []
@export_group("UI")
@export var ui: BattleUI


var double_battle: bool = false
var trainer_battle: bool = false
var exp_enabled: bool = true
var battleback: Battlebacks.Set = Battlebacks.loaded_sets[0]
var outcome: Outcomes = Outcomes.NONE
var ally_trainers: Array[BattleTrainer] = []
var enemy_trainers: Array[BattleTrainer] = []
var trainers: Array[BattleTrainer]:
	get: return ally_trainers + enemy_trainers
var player_trainer: BattleTrainer
var pokemons: Array[BattlePokemon] = [null, null, null, null]
@warning_ignore_start("integer_division")
var ally_pokemon: Array[BattlePokemon]:
	get: return pokemons.slice(0, pokemons.size() / 2)
var enemy_pokemon: Array[BattlePokemon]:
	get: return pokemons.slice(pokemons.size() / 2, pokemons.size())
@warning_ignore_restore("integer_division")
var current_pokemon_index: int = 0
var current_pokemon: BattlePokemon:
	get: return pokemons[current_pokemon_index] if current_pokemon_index in range(0, pokemons.size()) else null
var turn_order: Array[int]
var turn_selections: Dictionary[int, TurnAction] = {}
var acted: Array[int] = []
var escape_attempts: int = 0
var effects: Dictionary[BattleEffect, int] = {}
var is_buffering: bool:
	get: return _buffering
var _buffer: Array[Dictionary] = []
var _buffering: bool = false

var last_move_button_pressed: MoveButton


func _ready() -> void:
	if TransitionManager.transition:
		TransitionManager.play_out()

	state_machine.initial_state = machine_starting_state
	state_machine.start()

	Globals.current_battle = self


func _process(_delta: float) -> void:
	if not _buffering and not _buffer.is_empty():
		_execute_buffer()


#region Buffer functions
## Shows a text in battle, adding it to the buffer.
func show_text(text: String) -> void:
	add_buffer(BufferType.TEXT, text)


## Plays a [BattleAnimation], adding it to the buffer.
func play_animation(animation: BattleAnimation) -> void:
	add_buffer(BufferType.ANIMATION, animation)


## Animates the given [param databox]'s hp with [method Databox.animate_hp_bar], adding the process to the buffer.
func animate_hp(databox: Databox) -> void:
	add_buffer(BufferType.DATABOX_HP, databox)


## Animates the given [param databox]'s exp bar once with [method Databox.animate_level], adding the process to the buffer.
func animate_level(databox: Databox) -> void:
	add_buffer(BufferType.DATABOX_LEVEL, databox)


## Add exp to the player's pokemon, adding the process to the buffer. [param fainted_pokemon] is the fainted pokemon giving exp.
func pokemon_fainted(fainted_pokemon: BattlePokemon) -> void:
	add_buffer(BufferType.POKEMON_FAINT, fainted_pokemon)


## Executes a turn, adding it to the buffer.
func execute_turn(action: TurnAction, pokemon: BattlePokemon) -> void:
	add_buffer(BufferType.TURN_EXECUTION, {"action": action, "pokemon": pokemon})


## Adds a function call to the buffer. If [param callable] is a coroutine, it will be awaited.
func call_function(callable: Callable) -> void:
	add_buffer(BufferType.FUNCTION_CALL, callable)


## Prompts a switch when owned (not just ally) pokemon faint as a buffer element.
func switch_fainted() -> void:
	add_buffer(BufferType.FAINTED_SWITCH)


func add_buffer(type: BufferType, data: Variant = null) -> void:
	_buffer.append(
		{"type": type, "data": data}
	)


func _execute_buffer() -> void:
	if _buffer.is_empty():
		return

	_buffering = true
	var buffer: Dictionary = _buffer.pop_front()
	match buffer.type:
		BufferType.TEXT:
			await ui.show_text(buffer.data).finished
		BufferType.ANIMATION:
			var data: BattleAnimation = buffer.data
			data.play()
			await data.finished
		BufferType.DATABOX_HP:
			var data: Databox = buffer.data
			await data.animate_hp_bar().finished
		BufferType.POKEMON_FAINT:
			var fainted_pokemon: BattlePokemon = buffer.data
			turn_selections.erase(pokemons.find(fainted_pokemon))
			pokemons[pokemons.find(fainted_pokemon)] = null
			refresh_visuals()
			refresh_turn_order()
			show_text("%s fainted!" % fainted_pokemon.name)

			if fainted_pokemon.trainer in enemy_trainers:
				var player_pokemon_count: float = ally_pokemon.filter(func(pokemon: BattlePokemon): return pokemon and pokemon.trainer.is_player).size()
				for pokemon: BattlePokemon in ally_pokemon:
					if not pokemon or not pokemon.trainer.is_player:
						continue
					var exp_points: int = Experience.exp_yield(
						fainted_pokemon.species.base_exp, pokemon.level, fainted_pokemon.level, true, [1.0 / player_pokemon_count]
					)
					pokemon.pokemon.experience += exp_points
					show_text("%s gained %d experience points!" % [pokemon.name, exp_points])
					var slot: int = get_slot(pokemon)
				
					for i: int in pokemon.level - ui.used_databoxes[slot].shown_level + 1:
						animate_level(ui.used_databoxes[slot])
		BufferType.DATABOX_LEVEL:
			var data: Databox = buffer.data
			var old_level: int = data.shown_level
			await data.animate_level().finished
			if old_level != data.shown_level:
				show_text("%s grew to level %d!" % [data.pokemon.name, data.shown_level])
		BufferType.FUNCTION_CALL:
			var fun: Callable = buffer.data
			await fun.call()
		BufferType.TURN_EXECUTION:
			@warning_ignore("redundant_await")
			await _execute_turn(
				buffer.data.action,
				buffer.data.pokemon,
			)
		BufferType.FAINTED_SWITCH:
			var from: int = -1
			for i: int in pokemons.size():
				var pokemon: BattlePokemon = pokemons[i]
				if not pokemon or pokemon.trainer != player_trainer or pokemon.hp > 0:
					continue
				from = i
				break
			if from != -1:
				ui.prompt_switch(false)
				await ui.pokemon_selected
				switch(from, ui.last_selected_pokemon)
	
		_:
			push_error("Buffer type unknown: ", BufferType.find_key(buffer.type))
	_buffering = false
	buffer_ran.emit(buffer)
	if _buffer.is_empty():
		last_buffer_ran.emit(buffer)


func _execute_turn(action: TurnAction, pokemon: BattlePokemon) -> void:
	match action.type:
		Actions.FIGHT:
			_execute_fight_turn(action, pokemon)
		Actions.SWITCH:
			switch(action.properties.from, action.properties.to)
		Actions.RUN:
			var success: bool = Globals.rng.randf() <= calc_escape_chance()
			if success:
				show_text("Ran away!")
				call_function(set.bind("outcome", Outcomes.RAN_AWAY))
			else:
				show_text("Failed to run away!")


func _execute_fight_turn(action: TurnAction, pokemon: BattlePokemon) -> void:
	var targets: Array[BattlePokemon]
	var move: PokemonMove = action.properties.move
	move.register_effects(self)
	for i: int in action.properties.targets.size():
		if action.properties.targets[i] and pokemons[i]:
			targets.append(pokemons[i])
	
	var damage_list: Array[Battle.DamageCalculation] = damage_calc(move, pokemon, targets)

	show_text("%s used %s!" % [pokemon.name, move.name])
	
	var move_animation_sprites: Array[Node2D] # The sprites to be affected in the move animation

	for i: int in damage_list.size():
		var damage: Battle.DamageCalculation = damage_list[i]
		if not damage:
			continue
		if damage.miss:
			if damage.type_multiplier == 0:
				show_text("It has no effect on %s..." % damage.target.name)
			else:
				show_text("%s's attack failed." % pokemon.name)
			continue
		move_animation_sprites.append(sprites[i])
	
	if not move_animation_sprites.is_empty():
		var animation: BattleAnimation = BattleAnimation.get_animation("moves/" + move.name, move_animation_sprites, self)
		if not animation:
			animation = BattleAnimation.get_animation("moves/DEFAULT_" + Types.string_ids[move.type], move_animation_sprites, self)
		if animation:
			play_animation(animation)
	
	for damage: Battle.DamageCalculation in damage_list:
		if not damage:
			continue
		var slot: int = get_slot(damage.target)
		if damage.value() > 0:
			var hurt_flash: BattleAnimation = BattleAnimation.get_animation("hurt_flash", [sprites[slot]], self)
			play_animation(hurt_flash)
			call_function(damage.target.apply_damage.bind(damage.value()))
			animate_hp(ui.used_databoxes[slot])
			if damage.type_multiplier > 1:
				show_text("It's supereffective on %s!" % damage.target.name)
			elif damage.type_multiplier < 1:
				show_text("It's not very effective on %s..." % damage.target.name)
			call_function(check_battle_end)


	call_step(
		Battle.BattleSteps.AFTER_MOVE_ANIMATION,
		{
			"damage": damage_list,
			"move": move,
			"targets": targets,
		} as Dictionary[String, Variant]
	)
	move.unregister_effects(self)
#endregion


func call_step(step: BattleSteps, data: Dictionary[String, Variant] = {}) -> void:
	var sorted_effects: Array[BattleEffect] = effects.keys() as Array[BattleEffect]
	sorted_effects.sort_custom(_sort_effects)
	for effect: BattleEffect in sorted_effects:
		effect.apply(self, step, data)
	SignalRouter.battle_step.emit(self, step, data)


func _sort_effects(a: BattleEffect, b: BattleEffect) -> bool:
	return effects[a] > effects[b]


## Returns the slot (the index) of [param pokemon], which can be either [BattlePokemon] or [Pokemon].
func get_slot(pokemon: Variant) -> int:
	if pokemon is BattlePokemon:
		return pokemons.find(pokemon)
	elif pokemon is Pokemon:
		for slot: BattlePokemon in pokemons:
			if slot and slot.pokemon == pokemon:
				return pokemons.find(slot)
	else:
		push_error("Attempted call of Battle.get_slot without a Pokemon or BattlePokemon argument.")
	return -1


## Sets up the battle according to [param attributes].
## Possible attributes are: [br]
## - [code]double_battle[/code]: True if it is a double battle. False by default.[br]
## - [code]ally_trainer[/code]: The ally trainer for a double battle with an NPC ally.[br]
## - [code]enemy_trainers[/code]: The enemy trainers. If it is a single battle, it can be just [BattleTrainer] instead of being an array of these.[br]
## - [code]battleback[/code]: A [member Battlebacks.Sets].[br]
## - [code]exp_enabled[/code]: If false, the player's pokemon won't gain exp.[br]
func setup(attributes: Dictionary[String, Variant] = {}) -> void:
	battleback = Battlebacks.loaded_sets.get(attributes.get("battleback", Battlebacks.Sets.values()[0]))

	# Set battleback graphics
	background.texture = battleback.background
	ui.message_background.texture = battleback.message
	player_ground.texture = battleback.player_base
	enemy_ground.texture = battleback.enemy_base


	# Set trainers and first pokemon
	player_trainer = BattleTrainer.new(
		PlayerData.player_name, PlayerData.team, true
	)
	player_trainer.back_frames = BOY_SPRITEFRAMES if PlayerData.gender == PlayerData.MALE else GIRL_SPRITEFRAMES
	ally_trainers.append(player_trainer)
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
			pokemons[3] = BattlePokemon.new(self, enemy_trainers[1].team.first_healthy(), enemy_trainers[1])
		else:
			pokemons[3] = BattlePokemon.new(self, enemy_trainers[0].team.second_healthy(), enemy_trainers[0])

		# Set sprites positions
		sprites[0].position.x -= sprites[0].texture.get_width() * 0.25
		sprites[1].position.x += sprites[1].texture.get_width() * 0.25
		sprites[2].position.x -= sprites[2].texture.get_width() * 0.25
		sprites[3].position.x += sprites[3].texture.get_width() * 0.25

	# If any BattlePokemon has no pokemon set
	# (Might happen if the pokemon isn't healthy and team.second_healthy returns null)
	for i: int in pokemons.size():
		var pokemon: BattlePokemon = pokemons[i]
		if pokemon and not pokemon.pokemon:
			pokemons[i] = null

	# Set exp gain
	exp_enabled = attributes.get("exp_enabled", exp_enabled)

	refresh_visuals()


## Ends the battle, emitting all the signals needed and showing the proper animations.
func end_battle() -> void:
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	TransitionManager.finished.connect(
		func():
			Globals.current_battle = null
			SignalRouter.battle_ended.emit(self)
			queue_free(), CONNECT_ONE_SHOT
	)


## Check if the battle has ended and set [member outcome].
func check_battle_end() -> void:
	var lost: bool = true
	for trainer: BattleTrainer in ally_trainers:
		if trainer.team.is_healthy():
			lost = false
			break
	if lost:
		outcome = Outcomes.LOSS
		return
	var won: bool = true
	for trainer: BattleTrainer in enemy_trainers:
		if trainer.team.is_healthy():
			won = false
			break
	if won:
		outcome = Outcomes.WIN


## Checks if [b]any[/b] pokemon of [param trainer] has fainted.
func check_fainted_pokemon(trainer: BattleTrainer) -> bool:
	for pokemon: BattlePokemon in pokemons:
		if pokemon and pokemon.trainer == trainer and pokemon.hp <= 0:
			return true
	return false


## Calls [method refresh_databoxes], [method refresh_move_buttons], [method refresh_pokemon_sprites] and [method refresh_target_buttons].
func refresh_visuals() -> void:
	ui.refresh_databoxes()
	ui.refresh_move_buttons()
	refresh_pokemon_sprites()
	ui.refresh_target_buttons()


## Sets the pokemon sprites to the current pokemon in [member pokemons].
func refresh_pokemon_sprites() -> void:
	for i: int in sprites.size():
		var pokemon: BattlePokemon = pokemons[i]
		if not pokemon:
			sprites[i].pokemon = null
			continue
		sprites[i].pokemon = pokemon.pokemon
		if pokemon in ally_pokemon:
			sprites[i].back_sprite = true
		else:
			sprites[i].back_sprite = false


## Refreshes the turn order, excluding the pokemon slots who have acted. [br][br]
## [param acted] Holds the indexes of the pokemon in [member pokemons].
func refresh_turn_order() -> void:
	turn_order.clear()
	for i: int in pokemons.size():
		if turn_selections.keys().has(i) and pokemons[i] and not acted.has(i):
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
	ui.refresh_databoxes()
	refresh_pokemon_sprites()
	ui.refresh_target_buttons()


## Calculates the chance to flee based on the first ally pokemon and the first enemy pokemon.
func calc_escape_chance() -> float:
	var first_ally: BattlePokemon
	for pokemon: BattlePokemon in ally_pokemon:
		if pokemon:
			first_ally = pokemon
			break
	var first_enemy: BattlePokemon
	for pokemon: BattlePokemon in enemy_pokemon:
		if pokemon:
			first_enemy = pokemon
			break
	if not first_ally:
		return 0.0
	if not first_enemy or first_ally.speed >= first_enemy.speed:
		return 1.0
	escape_attempts += 1
	return (floorf((first_ally.speed * 32.0) / (first_enemy.speed * 4.0)) + (30.0 * escape_attempts)) / 256.0


## Starts a battle by creating a dedicated [CanvasLayer] and adding it to [member Globals.game_root].
## Stops [member Globals.game_world] from processing while the battle is on.[br]
## When the battle ends, it is freed. Calls [method setup] with [param attributes].
static func start_battle(attributes: Dictionary[String, Variant] = {}) -> Battle:
	if Globals.in_battle:
		printerr("Can't start a battle while another one is in progress.")
		return

	if PlayerData.team.array().is_empty() or not PlayerData.team.first_healthy():
		printerr("Can't start battle without a pokemon team or a healthy pokemon.")
		return
	var layer: CanvasLayer = CanvasLayer.new()
	var battle: Battle = attributes.get("battle_scene", DEFAULT_BATTLE_SCENE).instantiate()
	Globals.current_battle = battle
	layer.add_child(battle)
	layer.name = "BattleLayer"

	battle.setup(attributes)

	TransitionManager.layer += 5 # Make sure the transitions appear on top
	TransitionManager.play_in(TransitionManager.TransitionTypes.WILD_BATTLE)
	await TransitionManager.finished

	Globals.game_root.add_child(layer)
	# Stop running the game world while the battle is happening
	Globals.game_world.process_mode = Node.PROCESS_MODE_DISABLED

	var on_finish: Callable = func(_finished_battle: Battle):
		layer.queue_free()

	layer.tree_exited.connect(
		# Make sure movement and event input is enabled after battle.
		func():
			if TransitionManager.transition:
				TransitionManager.play_out()
				await TransitionManager.finished
				TransitionManager.layer -= 5
			Globals.movement_enabled = true
			Globals.event_input_enabled = true
			Globals.game_world.process_mode = Node.PROCESS_MODE_PAUSABLE
	)


	SignalRouter.battle_ended.connect(on_finish, CONNECT_ONE_SHOT)
	return battle


## Given the parameters, return a list of damage calculations to apply on the respective pokemon in that slot.
## The output [Array] has the same size as [member pokemons] and each element is [code]null[/code] if the damage is not to be applied
## to the pokemon in that slot, a [Battle.DamageCalculation] otherwise.
func damage_calc(move: PokemonMove, attacker: BattlePokemon, targets: Array[BattlePokemon]) -> Array[DamageCalculation]:
	var values: Array[DamageCalculation]
	values.resize(pokemons.size())

	for target: BattlePokemon in targets:
		var index: int = pokemons.find(target)
		if index == -1:
			continue

		var calculation: DamageCalculation = DamageCalculation.new()
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

		call_step(BattleSteps.BEFORE_DAMAGE_CALC, {"damage": calculation} as Dictionary[String, Variant])

		calculation.random = randf_range(0.85, 1.0)
		calculation.critical_multiplier = Globals.CRITICAL_MULTIPLIER if randf_range(0.0, 1.0) <= (1.0 / 24.0) else 1.0
		calculation.targets_multiplier = 1.0 if targets.size() <= 1 else Globals.MULTIPLE_TARGETS_MULTIPLIER
		calculation.type_multiplier = Types.get_interaction(move.type, target.pokemon.species.types)
		if calculation.type_multiplier == 0:
			calculation.miss = true

		call_step(BattleSteps.AFTER_DAMAGE_CALC, {"damage": calculation} as Dictionary[String, Variant])

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

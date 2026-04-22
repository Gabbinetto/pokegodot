class_name BattleServer extends Node

signal event_ran(event: Dictionary)
signal last_event_ran(event: Dictionary)

## Type of actions that can be selected.
enum Choices {
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
	AFTER_DAMAGE_APPLIED,
}

## All possible events that gets processed in the event queue.
enum EventType {
	POKEMON_FAINT, ## Add EXP to the player's pokemon after a KO, animating the databoxes and learning eventual moves.
	FUNCTION_CALL, ## Generic function call. Awaits the function in case of a couroutine.
	TURN_EXECUTION, ## Execute a [BattleServer.TurnChoice].
	FAINTED_SWITCH, ## Prompt a switch when an ally pokemon faints.
}

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
var turn_selections: Dictionary[int, TurnChoice] = {}
var acted: Array[int] = []
var escape_attempts: int = 0
var effects: Dictionary[BattleEffect, int] = {}
var event_running: bool:
	get: return _event_running
var _event_queue: Array[Dictionary] = []
var _event_running: bool = false
var _awaiting_input: bool = true


func _ready() -> void:
	SignalRouter.battle_server_received.connect(_on_battle_data_received)


func _process(_delta: float) -> void:
	if _awaiting_input:
		return
	if not _event_running and not _event_queue.is_empty():
		_run_event()


func _on_battle_data_received(data: Dictionary[String, Variant]) -> void:
	match data["type"]:
		"choice":
			var choice_type: Choices = data["choice_type"]
			var choice_properties: Dictionary[String, Variant]
			choice_properties.assign(data["choice_properties"])
			var choice: TurnChoice = TurnChoice.new(choice_type, choice_properties)
			_awaiting_input = false
			execute_turn(choice, data["pokemon_slot"])
		_:
			printerr("Unhandled data type: %s" % [data["type"]])


func _make_turn_state() -> Dictionary[String, Variant]:
	var data: Dictionary[String, Variant] = {}
	var pokemon_data: Array[Dictionary] = []
	for pokemon in pokemons:
		if pokemon:
			pokemon_data.push_back({
				"id": pokemon.species.id,
				"form_number": pokemon.species.form_number,
				"name": pokemon.name,
				"level": pokemon.level,
				"hp": pokemon.hp,
				"max_hp": pokemon.max_hp,
				"experience": pokemon.pokemon.experience,
				"gender": pokemon.pokemon.gender,
				"shiny": pokemon.pokemon.shiny
			})
		else:
			pokemon_data.push_back({})
	data["pokemons"] = pokemon_data

	return data


func send_data(data: Dictionary[String, Variant]) -> void:
	SignalRouter.notify_battle_clients(data)


func send_text(text: String) -> void:
	send_data({"type": "text", "text": text})


#region Event functions
## Add exp to the player's pokemon, adding the process to the event queue. [param fainted_pokemon] is the fainted pokemon giving exp.
func pokemon_fainted(fainted_pokemon: BattlePokemon) -> void:
	add_event(EventType.POKEMON_FAINT, fainted_pokemon)


## Executes a turn, adding it to the event queue.
func execute_turn(action: TurnChoice, pokemon: BattlePokemon) -> void:
	add_event(EventType.TURN_EXECUTION, {"action": action, "pokemon": pokemon})


## Adds a function call to the event queue. If [param callable] is a coroutine, it will be awaited.
func call_function(callable: Callable) -> void:
	add_event(EventType.FUNCTION_CALL, callable)


## Prompts a switch when owned (not just ally) pokemon faint as a event element.
func switch_fainted() -> void:
	add_event(EventType.FAINTED_SWITCH)


func add_event(type: EventType, data: Variant = null) -> void:
	_event_queue.append(
		{"type": type, "data": data}
	)


func _run_event() -> void:
	if _event_queue.is_empty():
		return

	_event_running = true
	var event: Dictionary = _event_queue.pop_front()
	match event.type:
		EventType.POKEMON_FAINT:
			var fainted_pokemon: BattlePokemon = event.data
			turn_selections.erase(pokemons.find(fainted_pokemon))
			refresh_turn_order()
			send_text("%s fainted!" % fainted_pokemon.name)

			if fainted_pokemon.trainer in enemy_trainers:
				var player_pokemon_count: float = ally_pokemon.filter(func(pokemon: BattlePokemon): return pokemon and pokemon.trainer.is_player).size()
				for pokemon: BattlePokemon in ally_pokemon:
					if not pokemon or not pokemon.trainer.is_player:
						continue
					var exp_points: int = Experience.exp_yield(
						fainted_pokemon.species.base_exp, pokemon.level, fainted_pokemon.level, true, [1.0 / player_pokemon_count]
					)
					pokemon.pokemon.experience += exp_points
					send_text("%s gained %d experience points!" % [pokemon.name, exp_points])
		EventType.FUNCTION_CALL:
			var fun: Callable = event.data
			await fun.call()
		EventType.TURN_EXECUTION:
			@warning_ignore("redundant_await")
			await _execute_turn(
				event.data.action,
				event.data.pokemon,
			)
		EventType.FAINTED_SWITCH:
			var from: int = -1
			for i: int in pokemons.size():
				var pokemon: BattlePokemon = pokemons[i]
				if not pokemon or pokemon.trainer != player_trainer or pokemon.hp > 0:
					continue
				from = i
				break
			if from != -1:
				pass

		_:
			push_error("Event type unknown: ", EventType.find_key(event.type))
	_event_running = false
	event_ran.emit(event)
	if _event_queue.is_empty():
		last_event_ran.emit(event)


func _execute_turn(action: TurnChoice, pokemon: BattlePokemon) -> void:
	match action.type:
		Choices.FIGHT:
			_execute_fight_turn(action, pokemon)
		Choices.SWITCH:
			switch(action.properties.from, action.properties.to)
		Choices.RUN:
			var success: bool = Globals.rng.randf() <= calc_escape_chance()
			if success:
				call_function(set.bind("outcome", Outcomes.RAN_AWAY))
			else:
				pass


func _execute_fight_turn(action: TurnChoice, pokemon: BattlePokemon) -> void:
	var targets: Array[BattlePokemon]
	var move: PokemonMove = action.properties.move
	move.register_effects(self)
	for i: int in action.properties.targets.size():
		if action.properties.targets[i] and pokemons[i]:
			targets.append(pokemons[i])

	var damage_list: Array[DamageCalculation] = damage_calc(move, pokemon, targets)

	send_text("%s used %s!" % [pokemon.name, move.name])

	for damage: DamageCalculation in damage_list:
		if not damage:
			continue
		if damage.miss:
			if damage.type_multiplier == 0:
				send_text("It has no effect on %s..." % damage.target.name)
			else:
				send_text("%s's attack failed." % pokemon.name)
			continue

	for damage: DamageCalculation in damage_list:
		if not damage:
			continue
		if damage.value() > 0:
			call_function(damage.target.apply_damage.bind(damage.value()))
			if damage.type_multiplier > 1:
				send_text("It's supereffective on %s!" % damage.target.name)
			elif damage.type_multiplier < 1:
				send_text("It's not very effective on %s..." % damage.target.name)
			call_function(check_battle_end)


	call_step(
		BattleServer.BattleSteps.AFTER_DAMAGE_APPLIED,
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
		push_error("Attempted call of BattleServer.get_slot without a Pokemon or BattlePokemon argument.")
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

	# Set trainers and first pokemon
	player_trainer = BattleTrainer.new(
		PlayerData.player_name, PlayerData.team, true
	)
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

	# If any BattlePokemon has no pokemon set
	# (Might happen if the pokemon isn't healthy and team.second_healthy returns null)
	for i: int in pokemons.size():
		var pokemon: BattlePokemon = pokemons[i]
		if pokemon and not pokemon.pokemon:
			pokemons[i] = null

	# Set exp gain
	exp_enabled = attributes.get("exp_enabled", exp_enabled)

	send_data({"type": "setup", "turn_state": _make_turn_state()})


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


## Starts a battle by creating a [BattleServer] and a [BattleClient].
## Stops [member Globals.game_world] from processing while the battle is on.[br]
## When the battle ends, it is freed. Calls [method setup] with [param attributes].
static func start_battle(attributes: Dictionary[String, Variant] = {}) -> BattleServer:
	if Globals.in_battle:
		printerr("Can't start a battle while another one is in progress.")
		return

	if PlayerData.team.array().is_empty() or not PlayerData.team.first_healthy():
		printerr("Can't start battle without a pokemon team or a healthy pokemon.")
		return

	# Create client
	var client: BattleClient = BattleClient.build({
		"double_battle": attributes.get("double_battle", false),
		"battleback": attributes.get("battleback", Battlebacks.Sets.values()[0]),
	})
	UIStack.push(client) # TODO: Add transition

	# Create server
	var battle: BattleServer = BattleServer.new()
	Globals.current_battle = battle
	Globals.add_child(battle)
	battle.setup(attributes)

	# Stop running the game world while the battle is happening
	Globals.game_world.process_mode = Node.PROCESS_MODE_DISABLED

	return battle


## Given the parameters, return a list of damage calculations to apply on the respective pokemon in that slot.
## The output [Array] has the same size as [member pokemons] and each element is [code]null[/code] if the damage is not to be applied
## to the pokemon in that slot, a [BattleServer.DamageCalculation] otherwise.
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
		calculation.miss = move.accuracy != 0 and Globals.rng.randf_range(0.0, 100.0) > accuracy

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
class TurnChoice:
	var type: Choices ## The type of action.
	var properties: Dictionary[String, Variant] ## Properties useful to the action, such as the switched in pokemon during a switch out.

	func _init(_type: Choices, _properties: Dictionary[String, Variant] = {}) -> void:
		type = _type
		properties = _properties
#endregion

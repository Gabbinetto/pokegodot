extends Node

var connected: bool = false
var battle_update_timer: Timer


func _ready() -> void:
	if EngineDebugger.is_active():
		EngineDebugger.register_message_capture("pkdebug", _capture)
	else:
		print("Debug not connected. Freeing PKDebug.")
		queue_free()


func _capture(message: String, data: Array) -> bool:
	match message:
		"get_tree":
			_data_send([get_tree()])
			return true
		"get_pokemon":
			var slot: int = data[0]
			var pokemon: Pokemon = PlayerData.team.slot(slot)
			if not pokemon:
				_data_send([])
				return true
			var new_data: Dictionary[String, Variant] = pokemon.as_save_data()
			new_data["level"] = pokemon.level
			_data_send([new_data])
			return true
		"set_pokemon":
			var slot: int = data[0]
			data[1].erase("level")
			var pokemon: Pokemon = Pokemon.from_save_data(data[1])
			PlayerData.team.set_pokemon(slot, pokemon)
			_toast("Pokemon updated")
			return true
		"heal_team":
			PlayerData.team.heal()
			_toast("Healed team")
			return true
		"calculate_stats":
			var stats: Dictionary[String, int]
			for stat: String in Globals.STATS.values():
				stats[stat] = Pokemon.calculate_stat(
					stat,
					data[0],
					data[1][stat],
					data[2][stat],
					data[3][stat],
					data[4],
					data[5],
				)
			_data_send([stats])
			return true
		"calculate_level":
			_data_send([Experience.get_level_at_exp(data[0], data[1])])
			return true
		"calculate_exp":
			_data_send([Experience.get_exp_at_level(data[0], data[1])])
			return true
		"get_max_exp":
			var limits: Dictionary[int, int] = {}
			for growth_rate: Experience.GrowthRates in Experience.GrowthRates.values():
				limits[growth_rate] = Experience.get_exp_at_level(Experience.MAX_LEVEL, growth_rate)
			_data_send([limits])
			return true
		"wild_battle":
			if Globals.in_battle:
				_toast("A battle is already happening.", 1)
				return true

			var id: String = data[0]
			var form: int = data[1]
			var level: int = data[2]

			if not DB.pokemon.has(id):
				_toast("There's no pokemon with id " + id + ".", 1)
				return true
			if form >= DB.pokemon[id]["forms"].size():
				_toast("%s has no form number %d." % [id, form], 1)
				return true
			
			Battle.start_battle(
				{
					"enemy_trainers": BattleTrainer.make_wild(
						Pokemon.generate(id, form, {"level": level})
					)
				}
			)
			_toast("Battle started.")
		"connect_battle":
			if not Globals.in_battle:
				_toast("There's no battle happening")
				return true
			EngineDebugger.send_message("pkdebug:battle_started", [])
			battle_update_timer = Timer.new()
			if not data.is_empty():
				battle_update_timer.wait_time = data[0]
			battle_update_timer.timeout.connect(_on_battle_update)
			add_child(battle_update_timer)
			battle_update_timer.start()
			_on_battle_update()
		"set_battle_timer":
			if battle_update_timer:
				battle_update_timer.wait_time = data[0]
		"battle_boost_pokemon":
			var slot: int = data[0]
			if slot == -1 or not Globals.current_battle.pokemons[slot]:
				_toast("There's no pokemon in slot %d." % slot)
				return true
			Globals.current_battle.pokemons[slot].add_boost(data[1], data[2])
			_toast("Boosted pokemon.")


	return false


func _data_send(data: Array) -> void:
	EngineDebugger.send_message("pkdebug:data_send", data)


func _toast(text: String, severity: int = 0) -> void:
	EngineDebugger.send_message("pkdebug:toast", [text, severity])


func _on_battle_update() -> void:
	if not Globals.in_battle:
		battle_update_timer.tree_exiting.connect(set.bind("battle_update_timer", null))
		battle_update_timer.queue_free()
		EngineDebugger.send_message("pkdebug:battle_ended", [])
		return
	
	var data: Array[Dictionary] = []
	for pokemon: BattlePokemon in Globals.current_battle.pokemons:
		var dict: Dictionary[String, Variant] = {}
		data.append(dict)
		if not pokemon:
			continue
		dict["slot"] = Globals.current_battle.get_slot(pokemon)
		dict["name"] = pokemon.name
		dict["level"] = pokemon.level
		dict["max_hp"] = pokemon.max_hp
		dict["hp"] = pokemon.hp
		dict["boosts"] = pokemon.boosts

	EngineDebugger.send_message("pkdebug:battle_update", data)

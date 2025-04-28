extends State

@export var battle: Battle

var current_pokemon: BattlePokemon
var acted: Array[int]
var switching: bool = false


func enter() -> void:
	acted.clear()
	battle.show_commands(battle.battle_dialogue)
	_process_turn()


func exit() -> void:
	for node: Node in battle.battle_dialogue.get_children():
		if node is DialogueManager:
			node.starting_sequence.text = ""


func _process_turn() -> void:
	if _is_battle_finished():
		if not battle.is_buffering:
			transition.emit(self, "BattleFinish")
		return
	
	_check_switch()
	if switching:
		return
	
	battle.refresh_turn_order(acted)
	if battle.turn_order.is_empty():
		if not battle.is_buffering:
			transition.emit(self, "ActionSelection")
		return
	
	current_pokemon = battle.pokemons[battle.turn_order.pop_front()]
	var action: Battle.TurnAction = battle.turn_selections.get(battle.pokemons.find(current_pokemon))
	acted.append(battle.pokemons.find(current_pokemon))
	if not action:
		return
	
	match action.type:
		Battle.Actions.FIGHT:
			var targets: Array[BattlePokemon]
			var move: PokemonMove = action.properties.move
			move.enable_effects()
			for i: int in action.properties.targets.size():
				var target_pokemon: BattlePokemon = battle.pokemons[i] if action.properties.targets[i] else null
				if target_pokemon:
					targets.append(target_pokemon)

			var damage_list: Array[Battle.DamageCalculation] = Battle.damage_calc(battle, move, current_pokemon, targets)
			targets.clear()
			for damage: Battle.DamageCalculation in damage_list:
				if damage and not damage.miss:
					targets.append(damage.target)

			await _start_damage_animation(damage_list, move)
			SignalRouter.battle_step.emit(
				battle,
				Battle.BattleSteps.AFTER_MOVE_ANIMATION,
				{
					"damage": damage_list,
					"move": move,
					"targets": targets,
				} as Dictionary[String, Variant]
			)
			move.disable_effects()
			_process_turn()
		Battle.Actions.SWITCH:
			battle.switch(action.properties.from, action.properties.to)
			_process_turn()
		Battle.Actions.RUN:
			var success: bool = Globals.rng.randf() <= battle.calc_escape_chance()
			if success:
				battle.show_text("Ran away!")
				await battle.last_buffer_ran
				battle.end_battle()
			else:
				battle.show_text("Failed to run away!")
				await battle.last_buffer_ran
				_process_turn()
	


func _start_damage_animation(damage_list: Array[Battle.DamageCalculation], move: PokemonMove) -> void:
	var hurt_flash_sprites: Array[Node2D]
	var move_animation_sprites: Array[Node2D]
	var pre_animation_texts: Array[String]
	var post_animation_texts: Array[String]

	for i: int in damage_list.size():
		var damage: Battle.DamageCalculation = damage_list[i]
		if not damage:
			continue
		if damage.type_multiplier != 0 and damage.miss:
			pre_animation_texts.append("Attack failed.")
		elif damage.type_multiplier == 0:
			pre_animation_texts.append("Does not affect %s." % damage.target.name)
		elif damage.type_multiplier > 0 and damage.type_multiplier < 1 and damage.move.category != PokemonMove.Categories.STATUS:
			post_animation_texts.append("It's not very effective on %s." % damage.target.name)
		elif damage.type_multiplier > 1 and damage.move.category != PokemonMove.Categories.STATUS:
			post_animation_texts.append("It's supereffective on %s." % damage.target.name)
		
		if not damage.miss:
			move_animation_sprites.append(battle.sprites[i])
		if damage.value() > 0:
			hurt_flash_sprites.append(battle.sprites[i])
		
	battle.show_text("%s used %s!" % [current_pokemon.name, move.name])
	await battle.last_buffer_ran
	
	# Show immune texts
	for text: String in pre_animation_texts:
		battle.show_text(text) 
	
	if not move_animation_sprites.is_empty():
		var move_animation: BattleAnimation = BattleAnimation.get_animation(
			"moves/" + move.id, move_animation_sprites, self
		)
		if not move_animation:
			move_animation = BattleAnimation.get_animation(
				"moves/DEFAULT_" + Types.string_ids[move.type], move_animation_sprites, self
			)
		if move_animation:
			battle.add_buffer(Battle.BufferType.ANIMATION, move_animation)
			await battle.last_buffer_ran
		
	if not hurt_flash_sprites.is_empty():
		var hurt_flash: BattleAnimation = BattleAnimation.get_animation("hurt_flash", hurt_flash_sprites, self)
		battle.add_buffer(Battle.BufferType.ANIMATION, hurt_flash)
	
	var damage_values: Array[int]
	for damage: Battle.DamageCalculation in damage_list:
		if damage:
			damage_values.append(damage.value())
		else:
			damage_values.append(-1)
	_apply_damage(damage_values)
	
	# Databoxes
	if damage_list[2]:
		if battle.double_battle:
			pass
		else:
			battle.animate_databox(battle.databox_enemy_single)
	if damage_list[3]:
		pass
	if damage_list[0]:
		if battle.double_battle:
			pass
		else:
			battle.animate_databox(battle.databox_ally_single)
	if damage_list[1]:
		pass
	
	# Show effectiveness texts
	for text: String in post_animation_texts:
		battle.show_text(text)
	await battle.last_buffer_ran


func _apply_damage(damage_list: Array[int]) -> void:
	for i: int in damage_list.size():
		if damage_list[i] != -1:
			battle.pokemons[i].hp -= damage_list[i]


func _check_switch() -> bool:
	var switch_to: Array = []
	
	if battle.ally_pokemon[0].hp <= 0:
		await _prompt_switch(battle.get_slot(battle.ally_pokemon[0]), switch_to)
	if battle.ally_pokemon[1] and battle.ally_pokemon[1].hp <= 0 and battle.ally_pokemon[1].trainer.is_player:
		await _prompt_switch(battle.get_slot(battle.ally_pokemon[1]), switch_to)
	
	if switch_to.is_empty(): return false
	battle.show_commands(battle.base_commands)
	
	for i: int in switch_to.size():
		if battle.ally_pokemon[i]:
			battle.switch(
				i,
				PlayerData.team.slot(switch_to[i])
			)
	switching = false

	return true


func _prompt_switch(slot: int, switch_to: Array) -> void:
	switching = true
	battle.show_commands(null)
	battle.turn_selections.erase(slot)
		
	var party: PartyMenu = PartyMenu.create(PlayerData.team, {"in_battle": true, "can_cancel": false})
	party.pokemon_selected.connect(
		func(pokemon: Pokemon):
			var index: int = PlayerData.team.get_array().find(pokemon)
			if pokemon.hp > 0 and not switch_to.has(index):
				switch_to.append(index)
				TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
				await TransitionManager.finished
				party.queue_free()
				await party.tree_exited
				TransitionManager.play_out()
				await TransitionManager.finished
	)
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished
	battle.ui_layer.add_child(party)
	await party.pokemon_selected


func _is_battle_finished() -> bool:
	var finished: bool = false
	for trainer: BattleTrainer in battle.trainers:
		if not trainer.team.first_healthy():
			finished = true
			break
	return finished

extends State


@export var battle: Battle
@export var sprite_list: Array[Node2D] ## Ordered in the same way of Battle.pokemons


var current_pokemon: Battle.PokemonBattleInfo
var animating: bool = false
var acted: Array[int]
var switching: bool = false

func enter() -> void:
	acted.clear()
	battle.show_commands(battle.battle_dialogue)


func exit() -> void:
	battle.show_text("")


func update(_delta: float) -> void:
	if animating:
		return
	
	if _is_battle_finished():
		transition.emit(self, "BattleFinish")
		return
	
	_check_switch()
	if switching:
		return
	
	battle.refresh_turn_order(acted)
	if battle.turn_order.is_empty():
		transition.emit(self, "ActionSelection")
		return
	
	current_pokemon = battle.pokemons[battle.turn_order.pop_front()]
	var action: Battle.TurnAction = battle.turn_selections.get(battle.pokemons.find(current_pokemon))
	acted.append(battle.pokemons.find(current_pokemon))
	if not action:
		return
	
	match action.type:
		Battle.Actions.FIGHT:
			var targets: Array[Battle.PokemonBattleInfo]
			for i: int in action.properties.targets.size():
				var target_pokemon: Battle.PokemonBattleInfo = battle.pokemons[i] if action.properties.targets[i] else null
				if target_pokemon:
					targets.append(target_pokemon)

			var damage_list: Array[Battle.DamageCalculation] = Battle.damage_calc(battle, action.properties.move, current_pokemon, targets)
			_start_damage_animation(damage_list, action.properties.move)
		Battle.Actions.SWITCH:
			battle.switch(action.properties.from, action.properties.to)
		Battle.Actions.RUN:
			var success: bool = Globals.rng.randf() <= battle.calc_escape_chance()
			animating = true
			if success:
				await battle.show_text("Ran away!")
				battle.end_battle()
			else:
				await battle.show_text("Failed to run away!")
			animating = false


func _start_damage_animation(damage_list: Array[Battle.DamageCalculation], move: PokemonMove) -> void:
	#region Databox animation lambda
	var databox_animation: Callable = func():
		if damage_list[2]:
			if battle.double_battle:
				pass
			else:
				await battle.databox_enemy_single.animate_hp_bar().finished
		if damage_list[3]:
			pass
		if damage_list[0]:
			if battle.double_battle:
				pass
			else:
				await battle.databox_ally_single.animate_hp_bar().finished
		if damage_list[1]:
			pass
	#endregion
	
	var target_sprites: Array[Node2D]
	var immune_texts: Array[String]
	var type_effectiveness_texts: Array[int]
	type_effectiveness_texts.resize(battle.pokemons.size())
	
	for i: int in damage_list.size():
		if not damage_list[i]:
			continue
		if damage_list[i].type_multiplier == 0:
			immune_texts.append("Does not affect %s." % damage_list[i].target.pokemon.name)
		elif damage_list[i].type_multiplier > 0 and damage_list[i].type_multiplier < 1:
			type_effectiveness_texts[
				battle.pokemons.find(damage_list[i].target)
			] = 1
		elif damage_list[i].type_multiplier > 1:
			type_effectiveness_texts[
				battle.pokemons.find(damage_list[i].target)
			] = 2
		if damage_list[i].value() <= 0:
			continue
		target_sprites.append(sprite_list[i])
	
	animating = true
	await battle.show_text("%s used %s!" % [current_pokemon.pokemon.name, move.name])
	
	# Show immune texts
	var show_immune_text: Callable = func(index: int, next_call: Callable):
		if index >= immune_texts.size():
			return
		await battle.show_text(immune_texts[index])
		await next_call.call(index + 1, next_call)
	await show_immune_text.call(0, show_immune_text)
	
	if not target_sprites.is_empty():
		var hurt_flash: BattleAnimation = BattleAnimation.get_animation("hurt_flash", target_sprites, self)
		hurt_flash.play()
		await hurt_flash.finished
	var damage_values: Array[int]
	for damage: Battle.DamageCalculation in damage_list:
		if damage:
			damage_values.append(damage.value())
		else:
			damage_values.append(-1)
	# Show effectiveness texts
	var show_effectiveness_text: Callable = func(index: int, next_call: Callable):
		if index >= type_effectiveness_texts.size():
			return
		if type_effectiveness_texts[index] == 0:
			await next_call.call(index + 1, next_call)
			return
		if type_effectiveness_texts[index] == 1:
			await battle.show_text("It's not very effective on\n%s." % [battle.pokemons[index].pokemon.name])
		elif type_effectiveness_texts[index] == 2:
			await battle.show_text("It's super effective on\n%s!" % [battle.pokemons[index].pokemon.name])
		await next_call.call(index + 1, next_call)
	await show_effectiveness_text.call(0, show_effectiveness_text)

	_apply_damage(damage_values)
	# TODO: Fix
	await databox_animation.call()

	animating = false


func _apply_damage(damage_list: Array[int]) -> void:
	for i: int in damage_list.size():
		if damage_list[i] != -1:
			battle.pokemons[i].hp -= damage_list[i]


func _check_switch() -> bool:
	var switch_to: Array = []
	
	if battle.ally_pokemon[0].hp <= 0:
		animating = true
		switching = true
		battle.show_commands(null)
		var slot: int = battle.pokemons.find(battle.ally_pokemon[0])
		battle.turn_selections.erase(slot)
		
		var party: PartyMenu = PartyMenu.create(PlayerData.team, {"in_battle": true, "can_cancel": false})
		party.pokemon_selected.connect(
			func(pokemon: Pokemon):
				var index: int = PlayerData.team.get_array().find(pokemon)
				if pokemon.hp > 0:
					switch_to.append(index)
					party.queue_free()
		)
		battle.ui_layer.add_child(party)
		await party.pokemon_selected
	if battle.ally_pokemon[1] and battle.ally_pokemon[1].hp <= 0 and battle.ally_pokemon[1].trainer.is_player:
		animating = true
		switching = true
		battle.show_commands(null)
		var slot: int = battle.pokemons.find(battle.ally_pokemon[1])
		battle.turn_selections.erase(slot)
		
		var party: PartyMenu = PartyMenu.create(PlayerData.team, {"in_battle": true, "can_cancel": false})
		party.pokemon_selected.connect(
			func(pokemon: Pokemon):
				var index: int = PlayerData.team.get_array().find(pokemon)
				if pokemon.hp > 0 and not switch_to.has(index):
					switch_to.append(index)
					party.queue_free()
		)
		battle.ui_layer.add_child(party)
		await party.pokemon_selected
	
	if switch_to.is_empty(): return false
	battle.show_commands(battle.base_commands)
	
	for i: int in switch_to.size():
		if battle.ally_pokemon[i]:
			battle.switch(
				PlayerData.team.get_array().find(battle.ally_pokemon[i].pokemon),
				PlayerData.team.slot(switch_to[i])
			)
	animating = false
	switching = false
	return true


func _is_battle_finished() -> bool:
	var finished: bool = false
	for trainer: Battle.TrainerBattleInfo in battle.trainers:
		if not trainer.team.first_healthy():
			finished = true
			break
	return finished

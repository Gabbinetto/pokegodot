extends State


@export var battle: Battle
@export var sprite_list: Array[Node2D] ## Ordered in the same way of Battle.pokemons


var current_pokemon: Battle.PokemonBattleInfo
var animating: bool = false
var acted: Array[int]

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
	
	battle.refresh_turn_order(acted)
	if battle.turn_order.is_empty():
		transition.emit(self, "ActionSelection")
		return
	
	current_pokemon = battle.pokemons[battle.turn_order.pop_front()]
	var action: Battle.TurnAction = battle.turn_selections[battle.pokemons.find(current_pokemon)]
	acted.append(battle.pokemons.find(current_pokemon))
	
	match action.type:
		Battle.Actions.FIGHT:
			var targets: Array[Battle.PokemonBattleInfo]
			for i: int in action.properties.targets.size():
				var target_pokemon: Battle.PokemonBattleInfo = battle.pokemons[i] if action.properties.targets[i] else null
				if target_pokemon:
					targets.append(target_pokemon)

			var damage_list: Array[int] = Battle.damage_calc(battle, action.properties.move, current_pokemon, targets)
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


func _start_damage_animation(damage_list: Array[int], move: PokemonMove) -> void:
	var target_sprites: Array[Node2D]
	for i: int in damage_list.size():
		if damage_list[i] <= 0:
			continue
		target_sprites.append(sprite_list[i])
	
	animating = true
	await battle.show_text("%s used %s!" % [current_pokemon.pokemon.name, move.name])
	
	# TODO: Fix flash not appearing on enemies
	var hurt_flash: BattleAnimation = BattleAnimation.get_animation("hurt_flash", target_sprites, self)
	hurt_flash.play()
	await hurt_flash.finished
	_apply_damage(damage_list)

	#region Databox animation
	if damage_list[2] != -1:
		if battle.double_battle:
			pass
		else:
			await battle.databox_enemy_single.animate_hp_bar().finished
	if damage_list[3] != -1:
		pass
	if damage_list[0] != -1:
		if battle.double_battle:
			pass
		else:
			await battle.databox_ally_single.animate_hp_bar().finished
	if damage_list[1] != -1:
		pass
	#endregion
	
	animating = false


func _apply_damage(damage_list: Array[int]) -> void:
	for i: int in damage_list.size():
		if damage_list[i] != -1:
			battle.pokemons[i].hp -= damage_list[i]


func _is_battle_finished() -> bool:
	var finished: bool = false
	for trainer: Battle.TrainerBattleInfo in battle.trainers:
		if not trainer.team.first_healthy():
			finished = true
			break
	return finished

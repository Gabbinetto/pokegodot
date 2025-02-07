extends State


@export var battle: Battle
@export var hurt_pivot: Node
@export var sprite_list: Array[Node2D] # Ordered in the same way of Battle.pokemons


var current_pokemon: Battle.PokemonBattleInfo
var animating: bool = false
var acted: Array[Battle.PokemonBattleInfo]

func enter() -> void:
	acted.clear()
	battle.show_commands(battle.battle_dialogue_box)

	#await get_tree().create_timer(0.1).timeout
	#transition.emit(self, "ActionSelection")


func exit() -> void:
	battle.show_text(battle.battle_dialogue, "")


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
	var action: Battle.TurnAction = battle.turn_selections[current_pokemon]
	acted.append(current_pokemon)
	
	match action.type:
		Battle.Actions.FIGHT:
			var targets: Array[Battle.PokemonBattleInfo]
			for i: int in action.properties.targets.size():
				var target_pokemon: Battle.PokemonBattleInfo = battle.pokemons[i] if action.properties.targets[i] else null
				if target_pokemon:
					targets.append(target_pokemon)

			var damage_list: Array[int] = Battle.damage_calc(battle, action.properties.move, current_pokemon, targets)
			_start_damage_animation(damage_list, action.properties.move)


func _start_damage_animation(damage_list: Array[int], move: PokemonMove) -> void:
	for i: int in damage_list.size():
		if damage_list[i] <= 0:
			continue
		var sprite: Node2D = sprite_list[i]
		sprite.set_meta("original_parent", sprite.get_parent())
		sprite.reparent(hurt_pivot)
	
	animating = true
	battle.show_text(battle.battle_dialogue, "%s used %s!" % [current_pokemon.pokemon.name, move.name])
	await battle.battle_dialogue.finished
	
	battle.animation_player.play("battle_scene_library/hurt")
	
	var on_animation_finish: Callable = func(_anim_name: String):
		for child: Node in hurt_pivot.get_children():
			child.reparent(child.get_meta("original_parent"))
		_apply_damage(damage_list)
		animating = false
	
	battle.animation_player.animation_finished.connect(on_animation_finish, CONNECT_ONE_SHOT | CONNECT_DEFERRED)


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

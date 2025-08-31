extends State


@export var battle: Battle
@export var ui: BattleUI

var tween: Tween
var _positions: Dictionary[Node, Vector2]


func enter() -> void:
	for databox: Databox in ui.databox_allies_double + ui.databox_enemies_double + [ui.databox_ally_single, ui.databox_enemy_single]:
		_positions[databox] = databox.position
	_positions[battle.player_ground] = battle.player_ground.position
	_positions[battle.enemy_ground] = battle.enemy_ground.position

	if battle.double_battle:
		for databox: Databox in ui.databox_allies_double:
			databox.position.x = get_viewport().get_visible_rect().size.x
		for databox: Databox in ui.databox_enemies_double:
			databox.position.x = - databox.size.x
	else:
		ui.databox_ally_single.position.x = get_viewport().get_visible_rect().size.x
		ui.databox_enemy_single.position.x = - ui.databox_enemy_single.size.x

	battle.player_ground.position.x = get_viewport().get_visible_rect().size.x
	battle.enemy_ground.position.x = - battle.enemy_ground.size.x

	ui.show_screen(BattleUI.Screens.NONE)

	for i: int in battle.ally_trainer_sprites.size():
		var sprite: AnimatedSprite2D = battle.ally_trainer_sprites[i]
		sprite.sprite_frames = battle.ally_trainers[i].back_frames
		# TODO: Set sprites positions based on how many trainers are there

	for sprite: Node2D in battle.sprites:
		sprite.hide()

	if TransitionManager.transition:
		await TransitionManager.finished

	if battle.trainer_battle:
		pass
	else:
		_animate_wild_battle()
	
	await tween.finished
	transition.emit(self, "ActionSelection")


func _animate_wild_battle() -> void:
	for pokemon: BattlePokemon in battle.enemy_pokemon:
		if not pokemon:
			continue
		var sprite: Node2D = battle.sprites[battle.get_slot(pokemon)]
		sprite.show()
		sprite.modulate = Color(0.5, 0.5, 0.5, 1)
	
	for pokemon: BattlePokemon in battle.ally_pokemon:
		if not pokemon:
			continue
		var sprite: Node2D = battle.sprites[battle.get_slot(pokemon)]
		sprite.scale = Vector2.ZERO


	tween = create_tween()

	tween.tween_property(battle.player_ground, "position", _positions[battle.player_ground], 0.8)
	tween.parallel().tween_property(battle.enemy_ground, "position", _positions[battle.enemy_ground], 0.8)
	tween.tween_interval(0.05)
	for pokemon: BattlePokemon in battle.enemy_pokemon:
		if not pokemon:
			continue
		var sprite: Node2D = battle.sprites[battle.get_slot(pokemon)]
		tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.3)

	tween.tween_interval(0.05)
	if battle.double_battle:
		for databox: Databox in ui.databox_enemies_double:
			tween.parallel().tween_property(databox, "position", _positions[databox], 0.3)
	else:
		tween.tween_property(ui.databox_enemy_single, "position", _positions[ui.databox_enemy_single], 0.3)

	var mons_text: String = " and ".join(
		battle.enemy_pokemon \
			.filter(func(pokemon: BattlePokemon): return pokemon != null) \
			.map(func(pokemon: BattlePokemon): return pokemon.name)
	)
	tween.tween_callback(
		func():
			tween.pause()
			battle.show_text("Oh! A wild %s appeared!" % mons_text)
			await battle.last_buffer_ran
			tween.play()
	)

	tween.tween_subtween(_send_out_pokemon_animation())


func _send_out_pokemon_animation() -> Tween:
	var subtween: Tween = create_tween()

	var mons_text: String = " and ".join(
		battle.ally_pokemon \
			.filter(func(pokemon: BattlePokemon): return pokemon != null) \
			.map(func(pokemon: BattlePokemon): return pokemon.name)
	)
	subtween.tween_callback(battle.show_text.bind("Go! %s!" % mons_text))
	for sprite: AnimatedSprite2D in battle.ally_trainer_sprites:
		subtween.parallel().tween_callback(sprite.play)
		subtween.parallel().tween_property(
			sprite, "position:x", -sprite.sprite_frames.get_frame_texture("default", 0).get_width(), 1.0
		)
	
	# TODO: Add pokeball animation

	for pokemon: BattlePokemon in battle.ally_pokemon:
		if not pokemon:
			continue
		var sprite: Node2D = battle.sprites[battle.get_slot(pokemon)]
		subtween.parallel().tween_callback(sprite.show)
		subtween.parallel().tween_property(sprite, "scale", Vector2.ONE, 0.75).set_delay(0.2)
	
	if battle.double_battle:
		for databox: Databox in ui.databox_allies_double:
			subtween.parallel().tween_property(databox, "position", _positions[databox], 0.3)
	else:
		subtween.tween_property(ui.databox_ally_single, "position", _positions[ui.databox_ally_single], 0.3)

	subtween.tween_callback(
		func():
			if battle.is_buffering:
				subtween.pause()
				await battle.last_buffer_ran
				subtween.play()
	)
	subtween.tween_interval(0.05)

	return subtween
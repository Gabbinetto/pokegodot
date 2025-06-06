extends State

@export var battle: Battle


func enter() -> void:
	battle.current_pokemon_index = 0
	battle.refresh_move_buttons()

	for button: MoveButton in battle.move_buttons:
		button.pressed.connect(_on_move_selected.bind(button.move))

	battle.pokemon_button.pressed.connect(_open_party)
	battle.run_button.pressed.connect(_try_run)

	battle.show_commands(battle.base_commands)
	battle.fight_button.grab_focus.call_deferred()

	await _show_text()


func exit() -> void:
	for button: MoveButton in battle.move_buttons:
		button.pressed.disconnect(_on_move_selected)

	battle.pokemon_button.pressed.disconnect(_open_party)
	battle.run_button.pressed.disconnect(_try_run)


	battle.base_commands.hide()
	battle.fight_commands.hide()


func _next(action: Battle.TurnAction) -> void:
	battle.turn_selections[battle.current_pokemon_index] = action
	battle.current_pokemon_index += 1
	
	if not battle.current_pokemon or not battle.current_pokemon.trainer.is_player:
		transition.emit(self, "NPCActionSelection")
		return
	
	await _show_text()


func _on_move_selected(move: PokemonMove) -> void:
	var targets: Array[bool]
	targets.resize(battle.pokemons.size())
	if battle.double_battle:
		battle.show_commands(battle.target_commands)
		# TODO: Double battle target selection
	else:
		targets = move.get_possible_targets(battle, battle.current_pokemon)
		_confirm_move(move, targets)


func _confirm_move(move: PokemonMove, targets: Array[bool]) -> void:
	var action: Battle.TurnAction = Battle.TurnAction.new(
		Battle.Actions.FIGHT, {"pokemon": battle.current_pokemon, "move": move, "targets": targets}
	)
	_next(action)


func _open_party() -> void:
	var party: PartyMenu = PartyMenu.create(PlayerData.team, {"in_battle": true})
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished
	battle.ui_layer.add_child(party)
	party.pokemon_selected.connect(func(pokemon: Pokemon):
		if pokemon.hp <= 0:
			return
		party.closed.emit()
		_switch(pokemon)
	)
	party.closed.connect(_close_party.bind(party))
	
func _close_party(party: PartyMenu) -> void:
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished
	party.queue_free()
	await party.tree_exited
	TransitionManager.play_out()
	await TransitionManager.finished
	battle.pokemon_button.grab_focus.call_deferred()



func _switch(to: Pokemon) -> void:
	var action: Battle.TurnAction = Battle.TurnAction.new(
		Battle.Actions.SWITCH, {"from": battle.current_pokemon_index, "to": to}
	)
	_next(action)


func _try_run() -> void:
	var action: Battle.TurnAction = Battle.TurnAction.new(Battle.Actions.RUN)
	_next(action)
	

func _show_text() -> void:
	var manager: DialogueManager
	for node: Node in battle.selection_dialogue.get_children():
		if node is DialogueManager:
			manager = node
			node.starting_sequence.text = "What will\n%s do?" % battle.current_pokemon.name
			break
	battle.selection_dialogue.run_dialogue(manager)
	await battle.selection_dialogue.finished
	

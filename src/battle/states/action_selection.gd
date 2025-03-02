extends State

@export var battle: Battle


func enter() -> void:
	battle.current_pokemon_index = 0

	for button: MoveButton in battle.move_buttons:
		button.pressed.connect(_on_move_selected.bind(button.move))

	battle.show_commands(battle.base_commands)
	battle.fight_button.grab_focus.call_deferred()

	_show_text()


func exit() -> void:
	for button: MoveButton in battle.move_buttons:
		button.pressed.disconnect(_on_move_selected)

	battle.base_commands.hide()
	battle.fight_commands.hide()


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
	var action = Battle.TurnAction.new(
		Battle.Actions.FIGHT, {"pokemon": battle.current_pokemon, "move": move, "targets": targets}
	)

	battle.turn_selections[battle.current_pokemon] = action
	battle.current_pokemon_index += 1
	
	if not battle.current_pokemon or not battle.current_pokemon.trainer.is_player:
		transition.emit(self, "NPCActionSelection")
		return
	
	_show_text()


func _show_text() -> void:
	battle.show_text(battle.selection_dialogue, "What will\n%s do?" % battle.current_pokemon.pokemon.name)
	

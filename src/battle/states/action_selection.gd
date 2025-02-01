extends State

@export var battle: Battle


func enter() -> void:
	battle.current_pokemon_index = 0

	for button: MoveButton in battle.move_buttons:
		button.pressed.connect(_on_move_selected.bind(button.move))

	battle.base_commands.show()
	battle.fight_button.grab_focus()

	_show_text()




func exit() -> void:
	for button: MoveButton in battle.move_buttons:
		button.pressed.disconnect(_on_move_selected)

	battle.base_commands.hide()
	battle.fight_commands.hide()


func _on_move_selected(move: PokemonMove) -> void:
	var action = Battle.TurnAction.new(
		Battle.Actions.FIGHT, {"pokemon": battle.current_pokemon, "move": move}
	)

	battle.turn_selections[battle.current_pokemon] = action

	_show_text()

	battle.current_pokemon_index += 1
	if not battle.current_pokemon or not battle.current_pokemon.trainer.is_player:
		transition.emit(self, "NPCActionSelection")


func _show_text() -> void:
	battle.selection_dialogue.dialogues.front().text = (
		"What will\n%s do?" % battle.current_pokemon.pokemon.name
	)
	battle.selection_dialogue.start()

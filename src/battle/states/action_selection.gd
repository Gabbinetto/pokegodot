extends State

@export var battle: Battle
@export var ui: BattleUI


func _ready() -> void:
	ui.move_selected.connect(_on_move_selected)


func enter() -> void:
	battle.current_pokemon_index = 0
	ui.refresh_move_buttons()

	ui.pokemon_selected.connect(_switch)
	ui.run_selected.connect(_try_run)

	ui.show_screen(BattleUI.Screens.BASE)

	await _show_text()


func exit() -> void:
	ui.pokemon_selected.disconnect(_switch)
	ui.run_selected.disconnect(_try_run)


func _next(action: Battle.TurnAction) -> void:
	battle.turn_selections[battle.current_pokemon_index] = action
	battle.current_pokemon_index += 1
	
	if not battle.current_pokemon or not battle.current_pokemon.trainer.is_player:
		transition.emit(self, "NPCActionSelection")
		return
	
	await _show_text()


func _on_move_selected(move: PokemonMove) -> void:
	var targets: Array[bool]
	if battle.double_battle:
		ui.show_screen(BattleUI.Screens.TARGET_SELECT)
		# TODO: Double battle target selection
	else:
		targets = move.get_possible_targets(battle, battle.current_pokemon)
		_confirm_move(move, targets)


func _confirm_move(move: PokemonMove, targets: Array[bool]) -> void:
	var action: Battle.TurnAction = Battle.TurnAction.new(
		Battle.Actions.FIGHT, {"pokemon": battle.current_pokemon, "move": move, "targets": targets}
	)
	_next(action)


func _switch(to: Pokemon) -> void:
	var action: Battle.TurnAction = Battle.TurnAction.new(
		Battle.Actions.SWITCH, {"from": battle.current_pokemon_index, "to": to}
	)
	_next(action)


func _try_run() -> void:
	var action: Battle.TurnAction = Battle.TurnAction.new(Battle.Actions.RUN)
	_next(action)
	

func _show_text() -> void:
	await ui.show_selection_text("What will\n%s do?" % battle.current_pokemon.name).finished
	

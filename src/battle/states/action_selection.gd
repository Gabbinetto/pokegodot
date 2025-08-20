extends State

@export var battle: Battle
@export var ui: BattleUI

var last_selected_move: PokemonMove
var selection_buffer: Array[Array]


func _ready() -> void:
	ui.move_selected.connect(_on_move_selected)
	ui.target_selected.connect(_on_target_selected)


func enter() -> void:
	battle.current_pokemon_index = 0
	selection_buffer.clear()
	if not battle.current_pokemon or not battle.current_pokemon.trainer.is_player:
		battle.current_pokemon_index += 1

	ui.pokemon_selected.connect(_switch)
	ui.run_selected.connect(_try_run)
	ui.base_cancel_selected.connect(_cancel_selection)

	ui.show_screen(BattleUI.Screens.BASE)
	ui.set_base_cancel_button(not selection_buffer.is_empty())
	ui.refresh_move_buttons()

	await _show_text()


func exit() -> void:
	ui.pokemon_selected.disconnect(_switch)
	ui.run_selected.disconnect(_try_run)
	ui.base_cancel_selected.disconnect(_cancel_selection)


func _next(action: Battle.TurnAction, force_transition: bool = false) -> void:
	if action:
		selection_buffer.append([battle.current_pokemon_index, action])
	battle.current_pokemon_index += 1
	
	if force_transition or not battle.current_pokemon or not battle.current_pokemon.trainer.is_player:
		for elem: Array in selection_buffer:
			battle.turn_selections[elem[0]] = elem[1]
		transition.emit(self, "NPCActionSelection")
		return
	
	ui.show_screen(BattleUI.Screens.BASE)
	ui.set_base_cancel_button(not selection_buffer.is_empty())
	ui.refresh_move_buttons()

	await _show_text()


func _on_move_selected(move: PokemonMove) -> void:
	last_selected_move = move
	var targets: Array[bool]
	if battle.double_battle:
		ui.show_screen(BattleUI.Screens.TARGET_SELECT)
		ui.set_target_buttons_to_move(move, battle.current_pokemon)
	else:
		targets = move.get_possible_targets(battle, battle.current_pokemon)
		_confirm_move(move, targets)


func _on_target_selected(index: int) -> void:
	var targets: Array[bool] = last_selected_move.select_targets(battle, battle.current_pokemon, index)
	_confirm_move(last_selected_move, targets)


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
	selection_buffer.clear()
	var action: Battle.TurnAction = Battle.TurnAction.new(Battle.Actions.RUN)
	_next(action, true)
	

func _cancel_selection() -> void:
	if selection_buffer.is_empty():
		ui.set_base_cancel_button(false)
		return
	
	selection_buffer.pop_back()
	battle.current_pokemon_index -= 2
	_next(null)
	

func _show_text() -> void:
	await ui.show_selection_text("What will\n%s do?" % battle.current_pokemon.name).finished

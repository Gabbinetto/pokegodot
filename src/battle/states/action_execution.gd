extends State

@export var battle: Battle
@export var ui: BattleUI

var current_pokemon: BattlePokemon
var switching: bool = false


func enter() -> void:
	battle.acted.clear()
	var callable: Callable = func(_buffer: Dictionary): _process_turn()
	set_meta("connected_callable", callable)
	battle.last_buffer_ran.connect(callable)
	
	ui.show_screen(BattleUI.Screens.DIALOGUE)
	
	_process_turn()


func exit() -> void:
	ui.show_text("")
	battle.last_buffer_ran.disconnect(get_meta("connected_callable"))


func _process_turn() -> void:
	if battle.outcome != Battle.Outcomes.NONE:
		transition.emit(self, "BattleFinish")
		return

	if battle.check_fainted_pokemon(battle.player_trainer):
		battle.switch_fainted()
		return
	

	battle.refresh_turn_order()
	if battle.turn_order.is_empty():
		transition.emit(self, "ActionSelection")
		return

	current_pokemon = battle.pokemons[battle.turn_order.pop_front()]
	var action: Battle.TurnAction = battle.turn_selections.get(battle.pokemons.find(current_pokemon))
	battle.acted.append(battle.get_slot(current_pokemon))
	if not action:
		return

	battle.execute_turn(action, current_pokemon)

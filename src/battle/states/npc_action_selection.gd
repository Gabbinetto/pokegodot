extends State

@export var battle: Battle


func enter() -> void:


	for pokemon: Battle.PokemonBattleInfo in battle.enemy_pokemon:
		var action: Battle.TurnAction = Battle.TurnAction.new(
			Battle.Actions.FIGHT,
			{
				"pokemon": pokemon,
				"move": pokemon.pokemon.moves[Globals.rng.randi_range(0, pokemon.pokemon.moves.size() - 1)]
			}
		)

		battle.turn_selections[pokemon] = action
	
	await get_tree().create_timer(0.2).timeout

	transition.emit(self, "ActionExecution")
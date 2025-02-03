extends State

@export var battle: Battle


func enter() -> void:

	# TODO: Make actual AI
	for pokemon: Battle.PokemonBattleInfo in battle.enemy_pokemon:
		var move: PokemonMove = pokemon.pokemon.moves[Globals.rng.randi_range(0, pokemon.pokemon.moves.size() - 1)]
		var targets: Array[bool] = []
		targets.resize(battle.pokemons.size())
		if battle.double_battle:
			pass
		else:
			targets = move.get_possible_targets(battle, pokemon)
		
		var action: Battle.TurnAction = Battle.TurnAction.new(
			Battle.Actions.FIGHT,
			{
				"pokemon": pokemon,
				"move": move,
				"targets": targets,
			}
		)

		battle.turn_selections[pokemon] = action
	
	await get_tree().create_timer(0.2).timeout

	transition.emit(self, "ActionExecution")

extends State

@export var battle: Battle


func enter() -> void:
	# TODO: Make actual AI
	for pokemon: BattlePokemon in battle.pokemons:
		if not pokemon or pokemon.trainer.is_player:
			continue
		var move: PokemonMove = pokemon.pokemon.moves.pick_random()
		var targets: Array[bool] = []
		targets.resize(battle.pokemons.size())
		if battle.double_battle:
			var possible: Array[bool] = move.get_possible_targets(battle, pokemon)
			var chosen: int = Globals.rng.randi_range(0, possible.size() - 1)
			while not possible[chosen]:
				chosen = Globals.rng.randi_range(0, possible.size() - 1)
			targets = move.select_targets(battle, pokemon, chosen)
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

		battle.turn_selections[battle.pokemons.find(pokemon)] = action
	
	await get_tree().create_timer(0.2).timeout

	transition.emit(self, "ActionExecution")

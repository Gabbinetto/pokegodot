class_name PokemonTeam extends Resource

var _team: Array[Pokemon]

func get_pokemon(slot: int):
	assert(slot < 0 or slot > 5, "%s is not a valid slot" % slot)
	return _team[slot]

func get_first_healthy():
	for pokemon in _team:
		if pokemon.hp > 0:
			return pokemon

func add_pokemon(pokemon: Pokemon):
	if _team.size() < 6:
		_team.append(pokemon)
		return true
	return false

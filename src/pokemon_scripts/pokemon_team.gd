class_name PokemonTeam extends Resource

## Pokegodot's team resource
##
## Resource holding data about a pokemon team.

var _team: Array[Pokemon] = []
var _iterator: int = 0


func _init(list: Array[Pokemon] = []) -> void:
	if list.size() > 6:
		list = list.slice(0, 6)
	_team.assign(list)

func _iter_init(_arg) -> bool:
	_iterator = 0
	return _iterator < _team.size()


func _iter_next(_arg) -> bool:
	_iterator += 1
	return _iterator < _team.size()


func _iter_get(_arg) -> Pokemon:
	return _team[_iterator]


## Returns the internal array of the team holding the pokemon data.
## Basically meant only to be used for methods like [method Array.filter] and [method Array.map]. [br][br]
## [b]NOTE[/b]: Be careful, as this returns not a copy of the internal array, but a direct reference to it.
## Modifying it means modifying the team.
func get_array() -> Array[Pokemon]:
	return _team


## Returns the size of the team.
func size() -> int:
	return _team.size()


## Returns pokemon at slot [param pokemon_slot]. If out of range, will return [code]null[/code].
## If less than 0, the slot will be [method size] - [param pokemon_slot].
func slot(pokemon_slot: int) -> Pokemon:
	if pokemon_slot < 0:
		pokemon_slot = size() - pokemon_slot
	if pokemon_slot > size() - 1:
		push_error(pokemon_slot, " is out of ", self, " range")
		return
	return _team[pokemon_slot]


## Removes pokemon at slot [param pokemon_slot] from the team and returns it. If out of range, will [code]null[/code].
## If less than 0, the slot will be [method size] - [param pokemon_slot].
func pop_slot(pokemon_slot: int) -> Pokemon:
	if pokemon_slot < 0:
		pokemon_slot = size() - pokemon_slot
	if pokemon_slot > size() - 1:
		push_error(pokemon_slot, " is out of ", self, " range")
		return
	return _team.pop_at(pokemon_slot)


## Removes pokemon at slot [param pokemon_slot] from the team and returns [code]true[/code]. If out of range, will return [code]false[/code].
## If less than 0, the slot will be [method size] - [param pokemon_slot].
func remove_slot(pokemon_slot: int) -> bool:
	if pokemon_slot < 0:
		pokemon_slot = size() - pokemon_slot
	if pokemon_slot > size() - 1:
		push_error(pokemon_slot, " is out of ", self, " range")
		return false
	_team.remove_at(pokemon_slot)
	return true


## Adds [param pokemon] to the team and returns [code]true[/code]. If there's no room, will return [code]false[/code].
func add_pokemon(pokemon: Pokemon) -> bool:
	if size() < 6:
		_team.append(pokemon)
		return true
	push_error(self, " has no room for new pokemon")
	return false


## Removes [param pokemon] from the team and returns [code]true[/code]. If not found, will return [code]false[/code].
func remove_pokemon(pokemon: Pokemon) -> bool:
	if _team.has(pokemon):
		_team.erase(pokemon)
		return true
	push_error(pokemon, " not found in ", self)
	return false


## Sets a slot to [param pokemon]. If [param slot] is bigger than the team size, it's the same as calling [method add_pokemon].
## Returns [code]true[/code] if swapping was successful.
## If less than 0, the slot will be [method size] - [param pokemon_slot].
## [br][br][b]Note:[/b] Setting a slot to [param pokemon] is dangerous as you might lose reference to the old pokemon in that slot.
func set_pokemon(pokemon_slot: int, pokemon: Pokemon) -> bool:
	if pokemon_slot >= size():
		return add_pokemon(pokemon)
	if pokemon_slot < 0:
		pokemon_slot = size() - pokemon_slot
	_team[pokemon_slot] = pokemon
	return true


## Swaps two slots.
func swap(from: int, to: int) -> void:
	var from_pokemon: Pokemon = slot(from)
	var to_pokemon: Pokemon = slot(to)
	set_pokemon(to, from_pokemon)
	set_pokemon(from, to_pokemon)


## Returns the first healthy pokemon in the party, that being a pokemon with more than 0 hp. Returns [code]null[/code] if there's none.
func first_healthy() -> Pokemon:
	for pokemon: Pokemon in _team:
		if pokemon.hp > 0:
			return pokemon
	return

## Returns the second healthy pokemon in the party, that being a pokemon with more than 0 hp. Returns [code]null[/code] if there's none.
## Used mainly to set up double battles.
func second_healthy() -> Pokemon:
	var first: bool = true
	for pokemon: Pokemon in _team:
		if pokemon.hp > 0:
			if first:
				first = false
				continue
			return pokemon
	return


## Heals the team.
func heal() -> void:
	for pokemon: Pokemon in _team:
		pokemon.heal()



func as_save_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []

	for pokemon: Pokemon in _team:
		data.append(pokemon.as_save_data())

	return data


static func from_save_data(data: Array[Dictionary]) -> PokemonTeam:
	var list: Array[Pokemon] = []
	for pokemon: Dictionary[String, Variant] in data:
		list.append(Pokemon.from_save_data(pokemon))

	return PokemonTeam.new(list)

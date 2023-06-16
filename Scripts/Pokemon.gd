extends Resource
class_name Pokemon

## Pokegodot's pokemon class
##
## Pokegodot's pokemon class. It holds all the data of a pokemon. Not to be confused with the [PokemonSpecies] class

## Self-explanatory. Emitted when the hp changes, sending the hp before and after the change.
signal hp_changed(old_hp: int, new_hp: int)

## A pokemon's possible genders
enum {MALE, FEMALE, GENDERLESS}

## The pokemons species. Used to store all the common data of the species, like it's typing or name.
var species : PokemonSpecies

## The species ID, used to create the species.
@export var species_id: String 
## The pokemon nickname, if not set it uses the species name.
@export var nickname: = "" 
## The pokemon's gender.
@export var gender: = MALE
## Whether the pokemon's shiny or not.
@export var shiny: = false
## The pokemon's level. This influences it's learnable moves and stats.
@export var level: = 1
## The pokemon's ability.
@export var ability: String = ""
## The pokemon's current exp. The setter function automatically checks if the pokemon should level up when the variable changes.
var current_exp: = 0:
	set(value):
		if level < GameVariables.MAX_LEVEL:
			current_exp = value
		else:
			current_exp = GameVariables.exp_table[species.growth_rate][-1]
		check_level()

## The pokemon's moves. It's an array of dictionary, which contain the [PokemonMove] object,
## the amount of PPs left and the amount of PPUps used on that move
var moves : Array[Dictionary] = [
	{"MOVE": null, "PPs": 0, "PPUPs": 0.0},
	{"MOVE": null, "PPs": 0, "PPUPs": 0.0},
	{"MOVE": null, "PPs": 0, "PPUPs": 0.0},
	{"MOVE": null, "PPs": 0, "PPUPs": 0.0}
]

# In-battle variables
var hp : = 0:
	set(value):
		hp_changed.emit(hp, value)
		hp = value
		if hp < 0:
			hp = 0
var status = null
var volatile_statuses = []

var held_item = null
var nature = "HARDY" # Insert this in nature boosts

## A dictionary holding this pokemon stats
var stats : = {
	"HP": 0,
	"ATTACK": 0,
	"DEFENSE": 0,
	"SPECIAL_ATTACK": 0,
	"SPECIAL_DEFENSE": 0,
	"SPEED": 0,
}
@export var ivs : = {
	"HP": 0,
	"ATTACK": 0,
	"DEFENSE": 0,
	"SPECIAL_ATTACK": 0,
	"SPECIAL_DEFENSE": 0,
	"SPEED": 0,
}
@export var evs : = {
	"HP": 0,
	"ATTACK": 0,
	"DEFENSE": 0,
	"SPECIAL_ATTACK": 0,
	"SPECIAL_DEFENSE": 0,
	"SPEED": 0,
}
var nature_boosts : = {
	"ATTACK": 1,
	"DEFENSE": 1,
	"SPECIAL_ATTACK": 1,
	"SPECIAL_DEFENSE": 1,
	"SPEED": 1,
}

## The pokemon's front sprite. Varies based on shininess and gender.
var front : Texture
## The pokemon's back sprite. Varies based on shininess and gender.
var back : Texture

func _init(_species_id : String, form_number = 0, _nickname = "", _level = 1, _shiny = false, _gender = MALE, _nature = "HARDY", _ivs = {}, _evs = {}, hidden_ability = false) -> void:
	# If the form is not 0 use a PokemonForm instead of PokemonSpecies
	if form_number > 0:
		species = PokemonForm.new()
		species.FORM_NUMBER = form_number
	else:
		species = PokemonSpecies.new()
	species_id = _species_id
	species.ID = species_id.to_upper() # Set the ID for the species
	species.load_data() # and load it"s data

	# Setting all data specific to one exemplary
	nickname = _nickname
	level = _level
	shiny = _shiny
	gender = _gender if species.gender_ratio != GameVariables.GENDER_RATIOS.Genderless else GENDERLESS
	nature = GameVariables.NATURES[_nature]
	if _ivs != {} and typeof(_ivs) == TYPE_DICTIONARY:
		ivs = _ivs
	else:
		ivs = GameFunctions.generate_random_ivs()
	if _evs != {} and typeof(_evs) == TYPE_DICTIONARY:
		evs = _evs
	
	front = species.sprite_front if !shiny else species.sprite_front_s
	back = species.sprite_back if !shiny else species.sprite_back_s
	if gender == FEMALE and species.f_sprite_front != null:
		front = species.f_sprite_front if !shiny else species.f_sprite_front_s
		back = species.f_sprite_back if !shiny else species.f_sprite_back_s
	
	if nickname == "":
		nickname = species.name
	
	if nature != null:
		for key in nature:
			nature_boosts[key] = nature[key]
	
	for stat in stats:
		stats[stat] = calc_stat(stat)
	hp = stats.HP
		
	
	if species.ability_2 != null:
		var abilities : Array = [species.ability_1, species.ability_2]
		abilities.shuffle()
		ability = abilities.front()
	else:
		ability = species.ability_1
	if hidden_ability:
		ability = species.hidden_ability
	
	set_moves_for_level()
	
	if not GameVariables.loaded:
		await GameVariables.finished_loading
	
	current_exp = GameVariables.exp_table[species.growth_rate][level-1]

## Set moves to the last 4 moves learnt at the pokemon's current level
func set_moves_for_level():
	var learnt_moves = species.moves
	var move_index = 0 # This will cycle from 0 to 3, representing the move slot
	for i in range(0, learnt_moves.size() - 1, 2):
		if learnt_moves[i] != "0":
			var move_level = learnt_moves[i].to_int()
			var move = learnt_moves[i+1]
			if move_level > level:
				break
			set_move(move_index, move)
			move_index += 1
			if move_index >= 4:
				move_index = 0
			

## Sets this pokemon's move in the indicated slot. Returns the dictionary at the [member moves] slot index.
func set_move(slot : int, move : String, pp_ups = 0.0) -> Dictionary:
	moves[slot].MOVE = PokemonMove.new(move)
	moves[slot].PPs = moves[slot].MOVE.total_pp
	moves[slot].PPUPs = pp_ups
	return moves[slot]


## Calculate the stats, formula for HP is different. Refer to https://bulbapedia.bulbagarden.net/wiki/Stat#Generation_III_onward
func calc_stat(stat: String) -> int:
	if stat == "HP":
		var _hp = floor(0.01 * (2 * species.base_stats.HP + ivs.HP + floor(0.25 * evs.HP)) * level) + level + 10
		
		# If the pokemon is Shedinja, HP is always 1 
		if species.ID == "SHEDINJA":
			_hp = 1
		return _hp
	else:
		var calculated = floor((floor(0.01 * (2 * species.base_stats[stat] + ivs[stat] + floor(0.25 * evs[stat])) * level) + 5) * nature_boosts[stat])
		return calculated


## Get the total exp for current level and total exp for next level
func exp_to_next_level(_level = level):
	return [
		GameVariables.exp_table[species.growth_rate][level - 1],
		GameVariables.exp_table[species.growth_rate][level] if level < GameVariables.MAX_LEVEL else GameVariables.exp_table[species.growth_rate][level - 1],
	]


## Function to check level and exp
func check_level():
	var table = GameVariables.exp_table[species.growth_rate]
	for i in 100:
		if current_exp >= table[i]:
			level = i+1
		else:
			break


## Get a move"s max pp
func get_move_max_pp(slot):
	return moves[slot].MOVE.total_pp * ((5 + moves[slot].PPUPs) / 5.0)


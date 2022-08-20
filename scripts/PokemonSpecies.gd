extends Resource
class_name PokemonSpecies, 'res://icons/pokeball.svg'

export var ID : = 'BULBASAUR'

# Main data
var name : = 'Bulbasaur'
var type_1 = null
var type_2 = null
var base_stats : = {
	'HP': 0,
	'ATTACK': 0,
	'DEFENSE': 0,
	'SPECIAL_ATTACK': 0,
	'SPECIAL_DEFENSE': 0,
	'SPEED': 0,
}
var gender_ratio : = 0.5
var growth_rate : = 'Medium'
var base_exp : = 0
var ev_yield : = {'stat': null, 'quantity': 1}
var catch_rate : = 255
var happiness : = 70
var ability_1 = null
var ability_2 = null
var hidden_ability = null

# Moves data
var moves : = []
var tutor_moves : = []
var egg_moves : = []

# Breeding data
var egg_group_1 : = -1
var egg_group_2 : = -1
var hatch_steps : = 1
var offspring = null

# Pokedex data
var weight : = 0.0
var height : = 0.0
var color : = ''
var shape : = ''
var habitat : = ''
var category : = ''
var description : = ''
var form_name : = ''
var generation : = 0

var sprite_front : Texture
var sprite_back : Texture
var sprite_front_s : Texture
var sprite_back_s : Texture


const GENDER_RATIOS = {
	'AlwaysMale': 0,
	'FemaleOneEight': 1/8,
	'Female25Percent': 1/4,
	'Female50Percent': 1/2,
	'Female75Percent': 3/4,
	'FemaleSevenEights': 7/8,
	'AlwaysFemale': 1/1,
	'Genderless': -1,
}

const TYPES = {
	'NORMAL': 0,
	'FIGHT': 1,
	'FLYING': 2,
	'POISON': 3,
	'GROUND': 4,
	'ROCK': 5,
	'BUG': 6,
	'GHOST': 7,
	'STEEL': 8,
	'???': 10,
	'FIRE': 11,
	'WATER': 12,
	'GRASS': 13,
	'ELECTRIC': 14,
	'PSYCHIC': 15,
	'ICE': 16,
	'DRAGON': 17,
	'DARK': 18,
	'FAIRY': 19,
}

enum EGG_GROUPS {
	Monster,
	Water1,
	Bug,
	Flying,
	Field,
	Fairy,
	Grass,
	Humanlike,
	Water3,
	Mineral,
	Amorphous,
	Water2,
	Ditto,
	Dragon,
	Undiscovered
}

func load_data():
	var f = File.new()
	var target = '[' + ID + ']'
	var found = false
	
	f.open(Globals.pokemon_file, File.READ)
	while (not f.eof_reached()) and (not found):
		var line = f.get_line()
		if line == target:
			found = true
			

	for i in 32:
		var line = f.get_line()
		if line == '#-------------------------------':
			break
		set_data(line)

	f.close()
	return

func set_data(data : String):
	
	ID = ID.to_upper()
	
	sprite_front = load(Globals.sprites_front + ID + '.png')
	sprite_front_s = load(Globals.sprites_front_shiny + ID + '.png')
	sprite_back = load(Globals.sprites_back + ID + '.png')
	sprite_back_s = load(Globals.sprites_back_shiny + ID + '.png')
	
	var split_line : = data.split(' = ') # Split data between: 
	var type : String = split_line[0] # type of data
	var value : String = split_line[1] # value of data
	
	match type:
		'Name':
			name = value
		'Types':
			var types : = value.split(',')
			type_1 = types[0]
			if types.size() > 1:
				type_2 = types[1]
		'BaseStats':
			var stats = value.split(',')
			base_stats.HP = int(stats[0])
			base_stats.ATTACK = int(stats[1])
			base_stats.DEFENSE = int(stats[2])
			base_stats.SPECIAL_ATTACK = int(stats[3])
			base_stats.SPECIAL_DEFENSE = int(stats[4])
			base_stats.SPEED = int(stats[5])
		'GenderRatio':
			gender_ratio = GENDER_RATIOS[value]
		'GrowthRate':
			growth_rate = value
		'BaseExp':
			base_exp = int(value)
		'EVs':
			var splitted = value.split(',')
			ev_yield.stat = splitted[0]
			ev_yield.quantity = splitted[1]
		'CatchRate':
			catch_rate = int(value)
		'Happiness':
			happiness = int(value)
		'Abilities':
			var abilities = value.split(',')
			ability_1 = abilities[0]
			if abilities.size() > 1:
				ability_2 = abilities[1]
		'HiddenAbilities':
			hidden_ability = value
		'Moves':
			moves = value.split(',')
		'TutorMoves':
			tutor_moves = value.split(',')
		'EggMoves':
			egg_moves = value.split(',')
		'EggGroups':
			var egg_groups = value.split(',')
			egg_group_1 = EGG_GROUPS[egg_groups[0]]
			if egg_groups.size() > 1:
				egg_group_2 = EGG_GROUPS[egg_groups[1]]
		'HatchSteps':
			hatch_steps = int(value)
		_:
			pass


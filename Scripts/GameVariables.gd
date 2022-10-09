extends Node

signal finished_loading

const TILE_SIZE : = 32

const SHINY_CHANCE : = 1.0 / 4096.0

const GENDER_RATIOS = {
	'AlwaysMale': 0,
	'FemaleOneEighth': 1/8,
	'Female25Percent': 1/4,
	'Female50Percent': 1/2,
	'Female75Percent': 3/4,
	'FemaleSevenEights': 7/8,
	'AlwaysFemale': 1/1,
	'Genderless': -1,
}

const TYPES_INDEX = {
	'NORMAL': 0,
	'FIGHTING': 1,
	'FLYING': 2,
	'POISON': 3,
	'GROUND': 4,
	'ROCK': 5,
	'BUG': 6,
	'GHOST': 7,
	'STEEL': 8,
	'???': 9,
	'FIRE': 10,
	'WATER': 11,
	'GRASS': 12,
	'ELECTRIC': 13,
	'PSYCHIC': 14,
	'ICE': 15,
	'DRAGON': 16,
	'DARK': 17,
	'FAIRY': 18,
}

# Type chart, used to get the effectiveness of an attack.
# The numbers are 1.0: NORMAL, 2.0:SUPEREFFECTIVE, 0.5: NOT VERY EFFECTIVE, 0.0: IMMUNE
# To point at something do TYPE_CHART[attacking_type_index][target_type_index] and get the damage multiplier
# These get generated at runtime from types.txt
const TYPE_CHART = [
#	NORM FIGH FLYN POIS GROU ROCK BUG  GHOS STEE ???  FIRE WATE GRAS ELEC PSYC ICE  DRAG DARK FAIR
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # NORMAL
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # FIGHTING
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # FLYING
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # POISON
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # GROUND
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # ROCK
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # BUG
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # GHOST
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # STEEL
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # ???
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # FIRE
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # WATER
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # GRASS
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # ELECTRIC
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # PSYCHIC
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # ICE
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # DRAGON
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # DARK
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], # FAIRY
]


const CATEGORIES_INDEX = {
	'PHYSICAL': 0,
	'SPECIAL': 1,
	'STATUS': 2,
}

const NATURES = {
	'HARDY': null,
	'LONELY': {'ATTACK': 1.1, 'DEFENSE': 0.9},
	'BRAVE': {'ATTACK': 1.1, 'SPEED': 0.9},
	'ADAMANT': {'ATTACK': 1.1, 'SPECIAL_ATTACK': 0.9},
	'NAUGHTY': {'ATTACK': 1.1, 'SPECIAL_DEFENSE': 0.9},
	'BOLD': {'DEFENSE': 1.1, 'ATTACK': 0.9},
	'DOCILE': null,
	'RELAXED': {'DEFENSE': 1.1, 'SPEED': 0.9},
	'IMPISH': {'DEFENSE': 1.1, 'SPECIAL_ATTACK': 0.9},
	'LAX': {'DEFENSE': 1.1, 'SPECIAL_DEFENSE': 0.9},
	'TIMID': {'SPEED': 1.1, 'ATTACK': 0.9},
	'HASTY': {'SPEED': 1.1, 'DEFENSE': 0.9},
	'SERIOUS': null,
	'JOLLY': {'SPEED': 1.1, 'SPECIAL_ATTACK': 0.9},
	'NAIVE': {'SPEED': 1.1, 'SPECIAL_DEFENSE': 0.9},
	'MODEST': {'SPECIAL_ATTACK': 1.1, 'ATTACK': 0.9},
	'MILD': {'SPECIAL_ATTACK': 1.1, 'DEFENSE': 0.9},
	'QUIET': {'SPECIAL_ATTACK': 1.1, 'SPEED': 0.9},
	'BASHFUL': null,
	'RASH': {'SPECIAL_ATTACK': 1.1, 'SPECIAL_DEFENSE': 0.9},
	'CALM': {'SPECIAL_DEFENSE': 1.1, 'ATTACK': 0.9},
	'GENTLE': {'SPECIAL_DEFENSE': 1.1, 'DEFENSE': 0.9},
	'SASSY': {'SPECIAL_DEFENSE': 1.1, 'SPEED': 0.9},
	'CAREFUL': {'SPECIAL_DEFENSE': 1.1, 'SPECIAL_ATTACK': 0.9},
	'QUIRKY': null,
}

const MAX_LEVEL = 100

var player_team = {
	0: null,
	1: null,
	2: null,
	3: null,
	4: null,
	5: null,
}

# const BALLS = {
#	 BEASTBALL,
#	 CHERISHBALL,
#	 DIVEBALL,
#	 DREAMBALL,
#
# }

const exp_table = {
	'Erratic': [0,0,0,0,0,0],
	'Fast': [0,0,0,0,0,0],
	'Medium': [0,0,0,0,0,0],
	'Parabolic': [0,0,0,0,0,0],
	'Slow': [0,0,0,0,0,0],
	'Fluctuating': [0,0,0,0,0,0],
}

enum {SLOW = 8, MEDIUM = 16, FAST = 32}
var text_speed = FAST :
	get:
		return 1.0 / text_speed


# Used to convert the exp tables in exp.txt from string to an actual array
func _generate_exp_table(curve : String):
	
	var f = FileAccess.open(Globals.exp_file, FileAccess.READ)
	var found : = false
	var line

	while (not f.eof_reached()) and (not found):
		line = f.get_line()
		if line.begins_with(curve):
			found = true

	# Remove brackets and spaces from table
	var table = line.split(' = ')[-1]
	table = table.replace('[', '')
	table = table.replace(']', '')
	table = table.replace(' ', '')

	# Split table in a string array
	var string_numbers = table.split(',')
	var output = []

	# Convert string array in int array
	for i in string_numbers:
		output.append(i.to_int())

	# Set table
	exp_table[curve] = output



func _generate_type_chart():
	var f = FileAccess.open(Globals.types_file, FileAccess.READ)
	for type in TYPES_INDEX.keys():
		f.seek(0)

		var target = '[%s]' % type
		var line = ''
		while !f.eof_reached():
			line = f.get_line()
			if line == target:
				break
		
		for _i in 6:
			line = f.get_line()
			if line.begins_with('#-'):
				break
			elif line.begins_with('Weaknesses = '):
				line = line.replace('Weaknesses = ', '')
				for weakness in line.split(','):
					TYPE_CHART[TYPES_INDEX[weakness]][TYPES_INDEX[type]] = 2.0
			elif line.begins_with('Resistances = '):
				line = line.replace('Resistances = ', '')
				for resistances in line.split(','):
					TYPE_CHART[TYPES_INDEX[resistances]][TYPES_INDEX[type]] = 0.5
			elif line.begins_with('Immunities = '):
				line = line.replace('Immunities = ', '')
				for immunities in line.split(','):
					TYPE_CHART[TYPES_INDEX[immunities]][TYPES_INDEX[type]] = 0.0


func _ready() -> void:
	
	for i in exp_table.keys():
		_generate_exp_table(i)
	player_team[0] = Pokemon.new('CHARMANDER', 0, '', 1)
	_generate_type_chart()

	emit_signal('finished_loading')

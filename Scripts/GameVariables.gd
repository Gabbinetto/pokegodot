extends Node

## Pokegodot's game variables singleton
##
## This class holds important game data, suck as shiny chance, the type chart or natures. Not to be confused with [GameFunctions]

signal finished_loading
var loaded : = false

const TILE_SIZE : = 32

const SHINY_CHANCE : = 1.0 / 4096.0

const GENDER_RATIOS = {
	"AlwaysMale": 0.0,
	"FemaleOneEighth": 1.0/8.0,
	"Female25Percent": 1.0/4.0,
	"Female50Percent": 1.0/2.0,
	"Female75Percent": 3.0/4.0,
	"FemaleSevenEights": 7.0/8.0,
	"AlwaysFemale": 1.0/1.0,
	"Genderless": -1.0,
}

const TYPES_INDEX = {
	"NORMAL": 0,
	"FIGHTING": 1,
	"FLYING": 2,
	"POISON": 3,
	"GROUND": 4,
	"ROCK": 5,
	"BUG": 6,
	"GHOST": 7,
	"STEEL": 8,
	"???": 9,
	"FIRE": 10,
	"WATER": 11,
	"GRASS": 12,
	"ELECTRIC": 13,
	"PSYCHIC": 14,
	"ICE": 15,
	"DRAGON": 16,
	"DARK": 17,
	"FAIRY": 18,
}

## Type chart, used to get the effectiveness of an attack.
## The numbers are 1.0: NORMAL, 2.0:SUPEREFFECTIVE, 0.5: NOT VERY EFFECTIVE, 0.0: IMMUNE.
## To point at something do TYPE_CHART[attacking_type_index][target_type_index] and get the damage multiplier.
## These get generated at runtime from types.txt.
var TYPE_CHART = [
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
	"PHYSICAL": 0,
	"SPECIAL": 1,
	"STATUS": 2,
}

const NATURES = {
	"HARDY": null,
	"LONELY": {"ATTACK": 1.1, "DEFENSE": 0.9},
	"BRAVE": {"ATTACK": 1.1, "SPEED": 0.9},
	"ADAMANT": {"ATTACK": 1.1, "SPECIAL_ATTACK": 0.9},
	"NAUGHTY": {"ATTACK": 1.1, "SPECIAL_DEFENSE": 0.9},
	"BOLD": {"DEFENSE": 1.1, "ATTACK": 0.9},
	"DOCILE": null,
	"RELAXED": {"DEFENSE": 1.1, "SPEED": 0.9},
	"IMPISH": {"DEFENSE": 1.1, "SPECIAL_ATTACK": 0.9},
	"LAX": {"DEFENSE": 1.1, "SPECIAL_DEFENSE": 0.9},
	"TIMID": {"SPEED": 1.1, "ATTACK": 0.9},
	"HASTY": {"SPEED": 1.1, "DEFENSE": 0.9},
	"SERIOUS": null,
	"JOLLY": {"SPEED": 1.1, "SPECIAL_ATTACK": 0.9},
	"NAIVE": {"SPEED": 1.1, "SPECIAL_DEFENSE": 0.9},
	"MODEST": {"SPECIAL_ATTACK": 1.1, "ATTACK": 0.9},
	"MILD": {"SPECIAL_ATTACK": 1.1, "DEFENSE": 0.9},
	"QUIET": {"SPECIAL_ATTACK": 1.1, "SPEED": 0.9},
	"BASHFUL": null,
	"RASH": {"SPECIAL_ATTACK": 1.1, "SPECIAL_DEFENSE": 0.9},
	"CALM": {"SPECIAL_DEFENSE": 1.1, "ATTACK": 0.9},
	"GENTLE": {"SPECIAL_DEFENSE": 1.1, "DEFENSE": 0.9},
	"SASSY": {"SPECIAL_DEFENSE": 1.1, "SPEED": 0.9},
	"CAREFUL": {"SPECIAL_DEFENSE": 1.1, "SPECIAL_ATTACK": 0.9},
	"QUIRKY": null,
}

const MAX_LEVEL = 100

enum WEATHERS {
	NONE,
	SUN,
	RAIN,
	SANDSTORM,
	HAIL,
	HARSH_SUN,
	STRONG_RAIN,
	STRONG_WINDS
}

enum TERRAINS {
	GRASS, ELECTRIC, PSYCHIC, MISTY
}

var exp_table: = {
	"Erratic": [],
	"Fast": [],
	"Medium": [],
	"Parabolic": [],
	"Slow": [],
	"Fluctuating": [],
}

var player_name: String = "Red"
var player_team: Dictionary = {
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


enum TEXT_SPEEDS {SLOW = 8, MEDIUM = 16, FAST = 32}
## The text speed. The getter function returns 1 divided by the text speed.
## It is intended to be the time (in seconds) between characters appearing in textboxes.
## Refer to [constant TEXT_SPEEDS] for the possible text speeds.
var text_speed = TEXT_SPEEDS.FAST :
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
	var table = line.split(" = ")[-1]
	table = table.replace("[", "")
	table = table.replace("]", "")
	table = table.replace(" ", "")

	# Split table in a string array
	var string_numbers = table.split(",")
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

		var target = "[%s]" % type
		var line = ""
		while !f.eof_reached():
			line = f.get_line()
			if line == target:
				break
		
		for _i in 6:
			line = f.get_line()
			if line.begins_with("#-"):
				break
			elif line.begins_with("Weaknesses = "):
				line = line.replace("Weaknesses = ", "")
				for weakness in line.split(","):
					TYPE_CHART[TYPES_INDEX[weakness]][TYPES_INDEX[type]] = 2.0
			elif line.begins_with("Resistances = "):
				line = line.replace("Resistances = ", "")
				for resistances in line.split(","):
					TYPE_CHART[TYPES_INDEX[resistances]][TYPES_INDEX[type]] = 0.5
			elif line.begins_with("Immunities = "):
				line = line.replace("Immunities = ", "")
				for immunities in line.split(","):
					TYPE_CHART[TYPES_INDEX[immunities]][TYPES_INDEX[type]] = 0.0


func _ready() -> void:
	
	for i in exp_table.keys():
		_generate_exp_table(i)

	_generate_type_chart()

	loaded = true
	emit_signal("finished_loading")
	
	player_team[0] = await Pokemon.new("CHARMANDER", 0, "", 5)
	player_team[1] = await Pokemon.new("BULBASAUR", 0, "", 5)
	player_team[2] = await Pokemon.new("XERNEAS", 0, "", 70)

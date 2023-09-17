extends Resource
class_name PokemonSpecies



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

@export var ID: = 'BULBASAUR'
signal done_loading

# Main data
var name: = 'Bulbasaur'
var type_1 = null
var type_2 = null
var base_stats: = {
	'HP': 0,
	'ATTACK': 0,
	'DEFENSE': 0,
	'SPECIAL_ATTACK': 0,
	'SPECIAL_DEFENSE': 0,
	'SPEED': 0,
}
var gender_ratio = GameVariables.GENDER_RATIOS.Female50Percent
var growth_rate: = 'Medium'
var base_exp: = 0
var ev_yield: = {'stat': null, 'quantity': 1}
var catch_rate: = 255
var happiness: = 70
var ability_1 = null
var ability_2 = null
var hidden_ability = null
var evolutions: = []

# Moves data
var moves: = []
var tutor_moves: = []
var egg_moves: = []

# Breeding data
var egg_group_1 = EGG_GROUPS.Undiscovered
var egg_group_2 = EGG_GROUPS.Undiscovered
var hatch_steps: = 1
var offspring = null
var breeding_item: = ''

# Pokedex data
var height: = 0.0
var weight: = 0.0
var color: = 'Red'
var shape: = 'Head'
var habitat: = 'None'
var category: = '???'
var description: = '???'
var form_name = null
var generation: = 0
var flags: = []

var wild_item_common: = ''
var wild_item_uncommon: = ''
var wild_item_rare: = ''

# All possible sprites
var sprite_front: Texture
var sprite_back: Texture
var sprite_front_s: Texture
var sprite_back_s: Texture

var f_sprite_front: Texture
var f_sprite_back: Texture
var f_sprite_front_s: Texture
var f_sprite_back_s: Texture
var icon: Texture

func load_data():
	var f = FileAccess.open(Globals.pokemon_file, FileAccess.READ)
	var target = '[' + ID + ']'
	var found = false
	
	while (not f.eof_reached()) and (not found):
		var line = f.get_line()
		if line == target:
			found = true
	assert(found, 'Pokemon %s not found' % ID)

	for i in 32:
		var line = f.get_line()
		if line == '#-------------------------------':
			break
		set_data(line)

	emit_signal('done_loading')
	return

func set_data(data: String):
	
	ID = ID.to_upper()
	
	sprite_front = load(Globals.sprites_front + ID + '.png')
	sprite_front_s = load(Globals.sprites_front_shiny + ID + '.png')
	sprite_back = load(Globals.sprites_back + ID + '.png')
	sprite_back_s = load(Globals.sprites_back_shiny + ID + '.png')
	icon = load(Globals.icons + ID + '.png')
	
	if FileAccess.file_exists('res://Graphics/Pokemon/Front/' + ID + '_female.png'):
		f_sprite_front = load('res://Graphics/Pokemon/Front/' + ID + '_female.png')
		f_sprite_front_s = load('res://Graphics/Pokemon/FrontShiny/' + ID + '_female.png')
		f_sprite_back = load('res://Graphics/Pokemon/Back/' + ID + '_female.png')
		f_sprite_back_s = load('res://Graphics/Pokemon/BackShiny/' + ID + '_female.png')
	
	var split_line: = data.split(' = ') # Split data between: 
	var type: String = split_line[0] # type of data
	var value: String = split_line[1] # value of data
	
	match type:
		'Name':
			name = value
		'Types':
			var types: = value.split(',')
			type_1 = types[0]
			if types.size() > 1:
				type_2 = types[1]
		'BaseStats':
			var stats: PackedStringArray = value.split(',')
			base_stats.HP = stats[0].to_int()
			base_stats.ATTACK = stats[1].to_int()
			base_stats.DEFENSE = stats[2].to_int()
			base_stats.SPECIAL_ATTACK = stats[4].to_int()
			base_stats.SPECIAL_DEFENSE = stats[5].to_int()
			base_stats.SPEED = stats[3].to_int()
		'GenderRatio':
			gender_ratio = GameVariables.GENDER_RATIOS[value]
		'GrowthRate':
			growth_rate = value
		'BaseExp':
			base_exp = value.to_int()
		'EVs':
			var splitted = value.split(',')
			ev_yield.stat = splitted[0]
			ev_yield.quantity = splitted[1]
		'CatchRate':
			catch_rate = value.to_int()
		'Happiness':
			happiness = value.to_int()
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
			hatch_steps = value.to_int()
		'OffSpring':
			offspring = value
		'Height':
			height = value.to_float()
		'Weight':
			weight = value.to_float()
		'Color':
			color = value
		'Shape':
			shape = value
		'Habitat':
			habitat = value
		'Category':
			category = value
		'Pokedex':
			description = value
		'FormName':
			form_name = value
		'Generation':
			generation = value.to_int()
		'Flags':
			flags = value.split(',')
		'WildItemCommon':
			wild_item_common = value
		'WildItemUncommon':
			wild_item_uncommon = value
		'WildItemRare':
			wild_item_rare = value
		'Evolutions':
			evolutions = value.split(',')
		'Incense':
			breeding_item = value
		_:
			pass


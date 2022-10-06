extends PokemonSpecies
class_name PokemonForm

@export_range(1, 2147483647, 1) var FORM_NUMBER = 1

# These types of data (type, stats, happiness)
# can either be inherited from the base form or be
# overwritten.
# Example: Marowak and Marowak-Alola have the
# same base stats, therefore in pokemon_forms.txt
# they will not be listed and they will be inherited from the base
# form of Marowak, in pokemon.txt
var changed_type : = false
var changed_stats : = false
var changed_happiness : = false
var changed_abilities : = false
var changed_hidden : = false
var changed_egg_groups : = false
var changed_color : = false
var changed_shape : = false
var changed_habitat : = false
var changed_flags : = false

var form_change_item : = '' # Item needed to change into this form, like mega stones
var form_change_move : = '' # Same as above, but with moves. Like Rayquaza and its Dragon Ascent
var change_message : = 0 # The kind of message displayed when changing form
var revert_form : = 0 # Whether the pokemon will go back to it's base form at the end of the battle
var pokedex_form : = 0

func load_data():
	var f = FileAccess.open(Globals.pokemon_forms_file, FileAccess.READ)
	var target = '[' + ID + ',' + str(FORM_NUMBER) + ']'
	var found = false
	
	while (not f.eof_reached()) and (not found):
		var line = f.get_line()
		if line == target:
			found = true
	assert(found, 'Pokemon not found!')

	for i in 32:
		var line = f.get_line()
		if line == '#-------------------------------':
			break
		set_data(line)

	f.close()
	emit_signal('done_loading')
	return



func set_data(data : String):
	
	ID = ID.to_upper()
	
	var original_form : = PokemonSpecies.new()
	original_form.ID = ID
	original_form.load_data()
	
	sprite_front = load(Globals.sprites_front + ID + '_' + str(FORM_NUMBER) + '.png')
	sprite_front_s = load(Globals.sprites_front_shiny + ID + '_' + str(FORM_NUMBER) + '.png')
	sprite_back = load(Globals.sprites_back + ID + '_' + str(FORM_NUMBER) + '.png')
	sprite_back_s = load(Globals.sprites_back_shiny + ID + '_' + str(FORM_NUMBER) + '.png')

	
	var split_line : = data.split(' = ') # Split data between: 
	var type : String = split_line[0] # type of data
	var value : String = split_line[1] # value of data
	
	match type:
		'Types':
			var types : = value.split(',')
			type_1 = types[0]
			if types.size() > 1:
				type_2 = types[1]
			changed_type = true
		'BaseStats':
			var stats : Array[String] = value.split(',')
			base_stats.HP = stats[0].to_int()
			base_stats.ATTACK = stats[1].to_int()
			base_stats.DEFENSE = stats[2].to_int()
			base_stats.SPECIAL_ATTACK = stats[3].to_int()
			base_stats.SPECIAL_DEFENSE = stats[4].to_int()
			base_stats.SPEED = stats[5].to_int()
			changed_stats = true
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
			changed_egg_groups = true
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
			changed_color = true
		'Shape':
			shape = value
			changed_shape = true
		'Habitat':
			habitat = value
			changed_habitat = true
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
			changed_flags = true
		'WildItemCommon':
			wild_item_common = value
		'WildItemUncommon':
			wild_item_uncommon = value
		'WildItemRare':
			wild_item_rare = value
		'Evolutions':
			evolutions = value.split(',')
		'MegaStone':
			form_change_item = value
		'MegaMove':
			form_change_move = value
		'MegaMessage':
			change_message = value.to_int()
		'UnmegaForm':
			revert_form = value.to_int()
		'PokedexForm':
			pokedex_form = value.to_int()
		_:
			pass
	
	name = original_form.name
	# If all of those didn't change with the form use the original form's ones
	if not changed_type:
		type_1 = original_form.type_1
		type_2 = original_form.type_2
	base_stats = base_stats if changed_stats else original_form.base_stats
	gender_ratio = original_form.gender_ratio
	growth_rate = original_form.growth_rate
	base_exp = base_exp if base_exp != 0 else original_form.base_exp
	ev_yield = ev_yield if ev_yield.stat != null else original_form.ev_yield
	catch_rate = catch_rate if catch_rate != 255 else original_form.catch_rate
	happiness = happiness if changed_happiness else original_form.happiness
	if !changed_abilities:
		ability_1 = original_form.ability_1
		ability_2 = original_form.ability_2
	if !changed_hidden:
		hidden_ability = original_form.hidden_ability
	evolutions = evolutions if evolutions != [] else original_form.evolutions
	moves = moves if moves != [] else original_form.moves
	tutor_moves = tutor_moves if tutor_moves != [] else original_form.tutor_moves
	egg_moves = egg_moves if egg_moves != [] else original_form.egg_moves
	if !changed_egg_groups:
		egg_group_1 = original_form.egg_group_1
		egg_group_2 = original_form.egg_group_2
	hatch_steps = hatch_steps if hatch_steps != 1 else original_form.hatch_steps
	offspring = offspring if offspring != null else offspring
	breeding_item = original_form.breeding_item
	height = height if height != 0.0 else original_form.height
	weight = weight if weight != 0.0 else original_form.weight
	color = color if changed_color else original_form.color
	shape = shape if changed_shape else original_form.shape
	habitat = habitat if changed_habitat else original_form.habitat
	category = category if category != '???' else original_form.category
	description = description if description != '???' else original_form.description
	generation = generation if generation != 0 else original_form.generation
	flags = flags if changed_flags else original_form.flags


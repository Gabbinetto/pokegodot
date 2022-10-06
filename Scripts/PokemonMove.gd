extends Resource
class_name PokemonMove

@export var ID : = 'MEGAHORN'

var name : = 'Unnamed'
var type : = '???'
var category : = 'Status'
var base_power : = 0
var accuracy : = 100
var total_pp : = 5
var target = null
var priority : = 0
var move_effect : = 'None'
var flags : = []
var effect_chance = 0
var description = '???'

func _init(id : String) -> void:
	ID = id
	load_data()

func load_data():
	var f = FileAccess.open(Globals.moves_file, FileAccess.READ)
	var _target = '[' + ID + ']'
	var found = false
	
	while (not f.eof_reached()) and (not found):
		var line = f.get_line()
		if line == _target:
			found = true
	assert(found, 'Move not found!')

	for i in 32:
		var line = f.get_line()
		if line == '#-------------------------------':
			break
		set_data(line)

	return

func set_data(data : String):
	
	ID = ID.to_upper()
	
	var split_line : = data.split(' = ') # Split data between: 
	var _type : String = split_line[0] # type of data
	var value : String = split_line[1] # value of data
	
	match _type:
		'Name':
			name = value
		'Type':
			type = value
		'Category':
			category = value.to_upper()
		'Power':
			base_power = value.to_int()
		'Accuracy':
			accuracy = value.to_int()
		'TotalPP':
			total_pp = value.to_int()
		'Target':
			target = value
		'Priority':
			priority = value.to_int()
		'FunctionCode':
			move_effect = value
		'Flags':
			flags = value.split(',')
		'EffectChance':
			effect_chance = value.to_int()
		'Description':
			description = value
		_:
			pass

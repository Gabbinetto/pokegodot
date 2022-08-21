extends Resource
class_name Pokemon

var species : Resource

enum {MALE, FEMALE, GENDERLESS}



var nickname : String
var gender : = MALE
var shiny : = false
var status = null
var volatile_statuses = []
var hp : = 0
var level : = 1
var moves : = [
	{'MOVE': null, 'PPs': 0, 'PPUPs': 0},
	{'MOVE': null, 'PPs': 0, 'PPUPs': 0},
	{'MOVE': null, 'PPs': 0, 'PPUPs': 0},
	{'MOVE': null, 'PPs': 0, 'PPUPs': 0}
]
var held_item = null
var nature = Globals.NATURES['HARDY']
var stats : = {
	'HP': 0,
	'ATTACK': 0,
	'DEFENSE': 0,
	'SPECIAL_ATTACK': 0,
	'SPECIAL_DEFENSE': 0,
	'SPEED': 0,
}
var ivs : = {
	'HP': 0,
	'ATTACK': 0,
	'DEFENSE': 0,
	'SPECIAL_ATTACK': 0,
	'SPECIAL_DEFENSE': 0,
	'SPEED': 0,
}
var evs : = {
	'HP': 0,
	'ATTACK': 0,
	'DEFENSE': 0,
	'SPECIAL_ATTACK': 0,
	'SPECIAL_DEFENSE': 0,
	'SPEED': 0,
}
var nature_boosts : = {
	'ATTACK': 1,
	'DEFENSE': 1,
	'SPECIAL_ATTACK': 1,
	'SPECIAL_DEFENSE': 1,
	'SPEED': 1,
}

var front : Texture
var back : Texture

func _init(species_id : String, form_number = 0) -> void:
	if form_number > 0:
		species = PokemonForm.new()
		species.FORM_NUMBER = form_number
	else:
		species = PokemonSpecies.new()
	species.ID = species_id
	species.load_data()

	front = species.sprite_front
	back = species.sprite_back
	
	nickname = species.name
	
	if nature != null:
		for key in nature:
			nature_boosts[key] = nature[key]
	
	for stat in stats:
		stats[stat] = calc_stat(stat)
	hp = stats.HP
		
	get_moves_for_level()

func get_moves_for_level():
	var learnt_moves = species.moves
	var move_index = 0
	for i in range(0, learnt_moves.size() - 1, 2):
		if learnt_moves[i] != '0':
			var move_level = int(learnt_moves[i])
			var move = learnt_moves[i+1]
			if move_level > level:
				break
			set_move(move_index, move)
			move_index += 1
			if move_index >= 4:
				move_index = 0
			

func set_move(slot : int, move : String, pp_ups = 0):
	moves[slot].MOVE = PokemonMove.new(move)
	moves[slot].PPs = moves[slot].MOVE.total_pp
	moves[slot].PPUPs = pp_ups

func calc_stat(stat):
	if stat == 'HP':
		var hp = floor(0.01 * (2 * species.base_stats.HP + ivs.HP + floor(0.25 * evs.HP)) * level) + level + 10
		if species.ID == 'SHEDINJA':
			hp = 1
		return hp
	else:
		var calculated = (floor(0.01 * (2 * species.base_stats[stat] + ivs[stat] + floor(0.25 * evs[stat])) * level) + 5) * nature_boosts[stat]
		return calculated

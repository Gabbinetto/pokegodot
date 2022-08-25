extends Control

enum STATES {
	START, # Battle start
	ACTION_SELECTION, # Action selection, like using a move or running away
	ACTION_EXECUTION, # The phase where the action gets executed
	WIN, LOSE, # When the player wins/loses
	RUN # When the player runs away
}

var state : = -1

export(Dictionary) var pokemon_1_data = {'ID': '', 'FORM_NUMBER': 0, 'LEVEL': 1, 'GENDER': 0, 'SHINY': false}
export(Dictionary) var pokemon_2_data = {'ID': '', 'FORM_NUMBER': 0, 'LEVEL': 1, 'GENDER': 0, 'SHINY': false}

onready var sprite_1 : = $Ground1/Sprite1
onready var sprite_2 : = $Ground2/Sprite2

var pokemon_1 : Resource
var pokemon_2 : Resource

func _ready() -> void:
	load_scene()
	
func load_scene() -> void:
	
	if pokemon_1 == null:
		pokemon_1 = Pokemon.new(pokemon_1_data.ID.to_upper(), pokemon_1_data.FORM_NUMBER, pokemon_1_data.LEVEL, pokemon_1_data.SHINY, pokemon_1_data.GENDER)
	if pokemon_2 == null:
		pokemon_2 = Pokemon.new(pokemon_2_data.ID.to_upper(), pokemon_2_data.FORM_NUMBER, pokemon_2_data.LEVEL, pokemon_2_data.SHINY, pokemon_2_data.GENDER)
	
	
	sprite_1.texture = pokemon_1.back
	sprite_2.texture = pokemon_2.front

	var lowest_sprite1_pixel = Globals.get_lowest_pixel_position(sprite_1.texture.get_data())
	var lowest_sprite2_pixel = Globals.get_lowest_pixel_position(sprite_2.texture.get_data())

	sprite_1.offset.y += sprite_1.texture.get_height() - lowest_sprite1_pixel.y
	sprite_2.offset.y += sprite_2.texture.get_height() - lowest_sprite2_pixel.y

	$DataboxPokemon1.pokemon = pokemon_1
	$DataboxPokemon2.pokemon = pokemon_2


func _handle_state(new_state : int):
	state = new_state
	if state == STATES.START:
		pass
	elif state == STATES.ACTION_SELECTION:
		pass
	elif state == STATES.ACTION_EXECUTION:
		pass
	elif state == STATES.WIN:
		pass
	elif state == STATES.LOSE:
		pass
	elif state == STATES.RUN:
		pass

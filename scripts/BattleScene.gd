extends Control

export(Dictionary) var pokemon_1_data = {'ID': '', 'FORM_NUMBER': 0}
export(Dictionary) var pokemon_2_data = {'ID': '', 'FORM_NUMBER': 0}

onready var sprite_1 : = $Ground1/Sprite1
onready var sprite_2 : = $Ground2/Sprite2

var pokemon_1 : Resource
var pokemon_2 : Resource

func _ready() -> void:
	load_scene()
	
func load_scene() -> void:
	pokemon_1 = Pokemon.new(pokemon_1_data.ID, pokemon_1_data.FORM_NUMBER)
	pokemon_2 = Pokemon.new(pokemon_2_data.ID, pokemon_2_data.FORM_NUMBER)
	
	sprite_1.texture = pokemon_1.back
	sprite_2.texture = pokemon_2.front

	var lowest_sprite1_pixel = Globals.get_lowest_pixel_position(sprite_1.texture.get_data())
	var lowest_sprite2_pixel = Globals.get_lowest_pixel_position(sprite_2.texture.get_data())

	sprite_1.offset.y += sprite_1.texture.get_height() - lowest_sprite1_pixel.y
	sprite_2.offset.y += sprite_2.texture.get_height() - lowest_sprite2_pixel.y

	print(pokemon_1)
	print(pokemon_1.hp)
	$DataboxPokemon1/HealthText/Label.text = str(pokemon_1.hp) + '/' + str(pokemon_1.stats.HP)

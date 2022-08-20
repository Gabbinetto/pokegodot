extends Node2D

export var pokemon_species : Resource

onready var front : = $Sprites/Front
onready var front_shiny : = $Sprites/FrontShiny
onready var back : = $Sprites/Back
onready var back_shiny : = $Sprites/BackShiny
onready var stats : = $Stats

func _ready() -> void:
	pokemon_species.load_data()
	
	front.texture = pokemon_species.sprite_front
	front_shiny.texture = pokemon_species.sprite_front_s
	back.texture = pokemon_species.sprite_back
	back_shiny.texture = pokemon_species.sprite_back_s

	front_shiny.position.x = front_shiny.texture.get_width()
	back.position.y = front.texture.get_height()
	back_shiny.position = Vector2(
		back.texture.get_width(),
		front_shiny.texture.get_height()
	)

	stats.rect_position.y = front.texture.get_height() + back.texture.get_height()
	
	$Types.rect_position.y = stats.rect_position.y + stats.rect_size.y + 32
	$Types/Type1.region_rect.position.y = 28 * pokemon_species.TYPES[pokemon_species.type_1]
	if pokemon_species.type_2:
		$Types/Type2.visible = true
		$Types/Type2.region_rect.position.y = 28 * pokemon_species.TYPES[pokemon_species.type_2]

	stats.get_node('HP/Bar/BarShade').rect_size.x = stats.get_node('HP/Bar').rect_size.x
	stats.get_node('ATTACK/Bar/BarShade').rect_size.x = stats.get_node('ATTACK/Bar').rect_size.x
	stats.get_node('DEFENSE/Bar/BarShade').rect_size.x = stats.get_node('DEFENSE/Bar').rect_size.x
	stats.get_node('SPATTACK/Bar/BarShade').rect_size.x = stats.get_node('SPATTACK/Bar').rect_size.x
	stats.get_node('SPDEFENSE/Bar/BarShade').rect_size.x = stats.get_node('SPDEFENSE/Bar').rect_size.x
	stats.get_node('SPEED/Bar/BarShade').rect_size.x = stats.get_node('SPEED/Bar').rect_size.x

	stats.get_node('HP/Value').text = '   '.substr(0, 3 - str(pokemon_species.base_stats.HP).length()) + str(pokemon_species.base_stats.HP)
	stats.get_node('ATTACK/Value').text = '   '.substr(0, 3 - str(pokemon_species.base_stats.ATTACK).length()) + str(pokemon_species.base_stats.ATTACK)
	stats.get_node('DEFENSE/Value').text = '   '.substr(0, 3 - str(pokemon_species.base_stats.DEFENSE).length()) + str(pokemon_species.base_stats.DEFENSE)
	stats.get_node('SPATTACK/Value').text = '   '.substr(0, 3 - str(pokemon_species.base_stats.SPECIAL_ATTACK).length()) + str(pokemon_species.base_stats.SPECIAL_ATTACK)
	stats.get_node('SPDEFENSE/Value').text = '   '.substr(0, 3 - str(pokemon_species.base_stats.SPECIAL_DEFENSE).length()) + str(pokemon_species.base_stats.SPECIAL_DEFENSE)
	stats.get_node('SPEED/Value').text = '   '.substr(0, 3 - str(pokemon_species.base_stats.SPEED).length()) + str(pokemon_species.base_stats.SPEED)

	var hp = range_lerp(pokemon_species.base_stats.HP, 1, 255, 0, 1)
	stats.get_node('HP/Bar').rect_scale.x = hp
	stats.get_node('HP/Bar').modulate = Color.from_hsv(range_lerp(hp, 0, 1, 0, 0.5), 1, 1)
	var attack = range_lerp(pokemon_species.base_stats.ATTACK, 1, 255, 0, 1)
	stats.get_node('ATTACK/Bar').rect_scale.x = attack
	stats.get_node('ATTACK/Bar').modulate = Color.from_hsv(range_lerp(attack, 0, 1, 0, 0.5), 1, 1)
	var defense = range_lerp(pokemon_species.base_stats.DEFENSE, 1, 255, 0, 1)
	stats.get_node('DEFENSE/Bar').rect_scale.x = defense
	stats.get_node('DEFENSE/Bar').modulate = Color.from_hsv(range_lerp(defense, 0, 1, 0, 0.5), 1, 1)
	var spattack = range_lerp(pokemon_species.base_stats.SPECIAL_ATTACK, 1, 255, 0, 1)
	stats.get_node('SPATTACK/Bar').rect_scale.x = spattack
	stats.get_node('SPATTACK/Bar').modulate = Color.from_hsv(range_lerp(spattack, 0, 1, 0, 0.5), 1, 1)
	var spdefense = range_lerp(pokemon_species.base_stats.SPECIAL_DEFENSE, 1, 255, 0, 1)
	stats.get_node('SPDEFENSE/Bar').rect_scale.x = spdefense
	stats.get_node('SPDEFENSE/Bar').modulate = Color.from_hsv(range_lerp(spdefense, 0, 1, 0, 0.5), 1, 1)
	var speed = range_lerp(pokemon_species.base_stats.SPEED, 1, 255, 0, 1)
	stats.get_node('SPEED/Bar').rect_scale.x = speed
	stats.get_node('SPEED/Bar').modulate = Color.from_hsv(range_lerp(speed, 0, 1, 0, 0.5), 1, 1)

	

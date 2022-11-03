extends Sprite2D
class_name Databox


@export var pokemon : Pokemon
@export var health_bar_max_scale : = 48.0
@export var exp_bar_max_scale : = 96.0

@export var player : = true

var exp_bar : Sprite2D
var health_bar : Sprite2D
var health_text : Label
var level : Label
var gender_symbol : Sprite2D

func _ready() -> void:
	if player:
		exp_bar = %ExpBar
		health_text = %Health
	
	health_bar = %HealthBar
	level = %Level
	gender_symbol = %GenderSymbol

func _process(delta: float) -> void:
	if exp_bar:
		var current_level_exp = pokemon.exp_to_next_level().front()
		var next_level_exp = pokemon.exp_to_next_level().back()
		
		exp_bar.scale.x = clamp(remap(pokemon.current_exp, current_level_exp, next_level_exp, 0, exp_bar_max_scale), 0, exp_bar_max_scale)

	if health_text:
		health_text.text = str(
			clamp(pokemon.hp, 0, pokemon.stats.HP)
			) + '/' + str(pokemon.stats.HP)

#		print(current_level_exp, ' ', next_level_exp, ' ', pokemon.current_exp)

	health_bar.scale.x = clamp(remap(pokemon.hp, 0, pokemon.stats.HP, 0, health_bar_max_scale), 0, health_bar_max_scale)
	level.text = str(pokemon.level)
	
	match pokemon.gender:
		pokemon.GENDERLESS:
			gender_symbol.hide()
		pokemon.MALE:
			gender_symbol.region_rect.position.x = 2
		pokemon.FEMALE:
			gender_symbol.region_rect.position.x = 2 + gender_symbol.region_rect.size.x

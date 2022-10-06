extends Sprite2D

@export var pokemon : Resource
@export var bar_100_scale : = 16.0

var bar_height : int
var gender_width : int
var bar_region_y : int
var gender_region_x : int

@onready var health_bar = $HealthBar
@onready var gender_symbol = $GenderSymbol
@onready var name_label = $NameContainer/Name
@onready var level = $Level

func _ready() -> void:
	bar_region_y = health_bar.region_rect.position.y
	gender_region_x = gender_symbol.region_rect.position.x
	bar_height = health_bar.region_rect.size.y
	gender_width = gender_symbol.region_rect.size.x


func _process(_delta: float) -> void:
	if !pokemon:
		return
	
	name_label.text = pokemon.nickname
	health_bar.scale.x = remap(pokemon.hp, 0, pokemon.stats.HP, 0, bar_100_scale)
	if pokemon.hp <= pokemon.stats.HP * 0.2:
		health_bar.region_rect.position.y = bar_region_y + bar_height * 2
	elif pokemon.hp <= pokemon.stats.HP * 0.5:
		health_bar.region_rect.position.y = bar_region_y + bar_height
	else:
		health_bar.region_rect.position.y = bar_region_y
	
	print(pokemon.level)
	level.text = str(pokemon.level)
	
	if pokemon.gender == pokemon.GENDERLESS:
		gender_symbol.visible = false
	gender_symbol.region_rect.position.x = gender_region_x if pokemon.gender == pokemon.MALE else gender_region_x + gender_width

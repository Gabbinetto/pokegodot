extends Sprite

export var pokemon : Resource
export var bar_100_scale : = 16.0

var bar_height : int
var gender_width : int
var bar_region_y : int
var gender_region_x : int

func _ready() -> void:
	bar_region_y = $HealthBar.region_rect.position.y
	gender_region_x = $GenderSymbol.region_rect.position.x
	bar_height = $HealthBar.region_rect.size.y
	gender_width = $GenderSymbol.region_rect.size.x

func _process(_delta: float) -> void:
	if !pokemon:
		return
	
	
	$NameContainer/Name.text = pokemon.nickname
	$HealthText/Label.text = str(pokemon.hp) + '/' + str(pokemon.stats.HP)
	$HealthBar.scale.x = range_lerp(pokemon.hp, 0, pokemon.stats.HP, 0, bar_100_scale)
	if pokemon.hp <= pokemon.stats.HP * 0.2:
		$HealthBar.region_rect.position.y = bar_region_y + bar_height * 2
	elif pokemon.hp <= pokemon.stats.HP * 0.5:
		$HealthBar.region_rect.position.y = bar_region_y + bar_height
	else:
		$HealthBar.region_rect.position.y = bar_region_y
		
	$Level.text = str(pokemon.level)
	
	if pokemon.gender == pokemon.GENDERLESS:
		$GenderSymbol.visible = false
	$GenderSymbol.region_rect.position.x = gender_region_x if pokemon.gender == pokemon.MALE else gender_region_x + gender_width

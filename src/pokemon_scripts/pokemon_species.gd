class_name PokemonSpecies extends Resource


## Pokegodot's Pokemon class
##
## Pokegodot's Pokemon class. It defines a Pokemon species and all it's properties. Those aren't meant to change at runtime. 
## The data is taken from [code]pokemon.json[/code]
## Not to be confused with [Pokemon]


var id: String = ""
var name: String = "Unnamed"
var form_number: int = 0
var form_name: String = ""
var types: Array[Types.List] = []
var base_stats: Dictionary = {
	Globals.STATS.HP: 1,
	Globals.STATS.ATTACK: 1,
	Globals.STATS.DEFENSE: 1,
	Globals.STATS.SPECIAL_ATTACK: 1,
	Globals.STATS.SPECIAL_DEFENSE: 1,
	Globals.STATS.SPEED: 1,
}
var gender_ratio: float = 4.0
var female_chance: float:
	get: return gender_ratio / 8.0
var growth_rate: Experience.GrowthRates
var base_exp: int = 0
var evs: Dictionary = {
	Globals.STATS.HP: 0,
	Globals.STATS.ATTACK: 0,
	Globals.STATS.DEFENSE: 0,
	Globals.STATS.SPECIAL_ATTACK: 0,
	Globals.STATS.SPECIAL_DEFENSE: 0,
	Globals.STATS.SPEED: 0,
}
var catch_rate: int = 255
var base_happiness: int = 70
var abilities: Array[String] = []
var hidden_abilities: Array[String] = []
var moves: Array[Dictionary] = []
var tutor_moves: Array[String] = []
var egg_moves: Array[String] = []
var egg_groups: Array[String] = []
var egg_cycles: int = 1
var incense: String = ""
var offspring: Array[Dictionary] = []
var info: Dictionary = {
	"height": 0.0,
	"weight": 0.0,
	"color": "Red",
	"shape": "Head",
	"habitat": "",
	"category": "???",
	"description": "???",
	"generation": 0,
}
var flags: Array[String] = []
var items: Dictionary = {
	"common": "",
	"uncommon": "",
	"rare": "",
}
var evolutions: Array[Dictionary] = [] # TODO: Implement
# TODO: Implement form properties

# Sprites
var sprite_front_n_m: Texture
var sprite_front_n_f: Texture
var sprite_front_s_m: Texture
var sprite_front_s_f: Texture
var sprite_back_n_m: Texture
var sprite_back_n_f: Texture
var sprite_back_s_m: Texture
var sprite_back_s_f: Texture
var sprite_icon_n: Texture
var sprite_icon_s: Texture
var sprite_footprint: Texture

# Shorthand variables
var hp: int:
	get: return base_stats.HP
	set(value): base_stats.HP = value
var attack: int:
	get: return base_stats.ATTACK
	set(value): base_stats.ATTACK = value
var defense: int:
	get: return base_stats.DEFENSE
	set(value): base_stats.DEFENSE = value
var spatk: int:
	get: return base_stats.SPECIAL_ATTACK
	set(value): base_stats.SPECIAL_ATTACK = value
var spdef: int:
	get: return base_stats.SPECIAL_DEFENSE
	set(value): base_stats.SPECIAL_DEFENSE = value
var speed: int:
	get: return base_stats.SPEED
	set(value): base_stats.SPEED = value


func _init(_id: String, _form_number: int = 0) -> void:
	id = _id
	form_number = form_number

	var data: Dictionary
	for form: Dictionary in DB.pokemon.get(id).forms:
		if form.form_number == form_number:
			data = form.duplicate(true)
			break
	
	# Array properties have to be assigned manually because Godot is silly
	for type: int in data.types:
		types.append(type as Types.List)
	data.erase("types")
	abilities.assign(data.abilities)
	data.erase("abilities")
	hidden_abilities.assign(data.hidden_abilities)
	data.erase("hidden_abilities")
	moves.assign(data.moves)
	data.erase("moves")
	tutor_moves.assign(data.tutor_moves)
	data.erase("tutor_moves")
	egg_moves.assign(data.egg_moves)
	data.erase("egg_moves")
	egg_groups.assign(data.egg_groups)
	data.erase("egg_groups")
	offspring.assign(data.offspring)
	data.erase("offspring")
	evolutions.assign(data.evolutions)
	data.erase("evolutions")


	for attribute: String in data:
		if attribute in self:
			set(attribute, data[attribute])

	_set_sprites()


func _set_sprites() -> void:
	sprite_front_n_m = load(DB.POKEMON_SPRITES_PATH + id + "/front_n_m.png")
	if not sprite_front_n_m:
		sprite_front_n_m = DB.DEFAULT_FRONT_SPRITE
	sprite_front_n_f = load(DB.POKEMON_SPRITES_PATH + id + "/front_n_f.png")
	if not sprite_front_n_f:
		sprite_front_n_f = sprite_front_n_m
	sprite_front_s_m = load(DB.POKEMON_SPRITES_PATH + id + "/front_s_m.png")
	if not sprite_front_s_m:
		sprite_front_s_m = sprite_front_n_m
	sprite_front_s_f = load(DB.POKEMON_SPRITES_PATH + id + "/front_s_f.png")
	if not sprite_front_s_f:
		sprite_front_s_f = sprite_front_s_m

	sprite_back_n_m = load(DB.POKEMON_SPRITES_PATH + id + "/back_n_m.png")
	if not sprite_back_n_m:
		sprite_back_n_m = DB.DEFAULT_BACK_SPRITE
	sprite_back_n_f = load(DB.POKEMON_SPRITES_PATH + id + "/back_n_f.png")
	if not sprite_back_n_f:
		sprite_back_n_f = sprite_back_n_m
	sprite_back_s_m = load(DB.POKEMON_SPRITES_PATH + id + "/back_s_m.png")
	if not sprite_back_s_m:
		sprite_back_s_m = sprite_back_n_m
	sprite_back_s_f = load(DB.POKEMON_SPRITES_PATH + id + "/back_s_f.png")
	if not sprite_back_s_f:
		sprite_back_s_f = sprite_back_s_m
	
	sprite_icon_n = load(DB.POKEMON_SPRITES_PATH + id + "/icon_n.png")
	if not sprite_icon_n:
		sprite_icon_n = DB.DEFAULT_ICON_SPRITE
	sprite_icon_s = load(DB.POKEMON_SPRITES_PATH + id + "/icon_s.png")
	if not sprite_icon_s:
		sprite_icon_s = sprite_icon_n
	
	sprite_footprint = load(DB.POKEMON_SPRITES_PATH + id + "/footprint.png")

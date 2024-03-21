class_name PokemonSpecies extends Resource

## Pokegodot's PokemonSpecies class
##
## Pokegodot's PokemonSpecies class. It holds all the immutable data of a Pokemon, 
## such as its base stats, types, etc...

var data: Dictionary = {}

const GENDER_RATIOS: Dictionary = {
	"AlwaysMale": 0.0,
	"FemaleOneEight": 1.0 / 8.0,
	"Female25Percent": 0.25,
	"Female50Percent": 0.5,
	"Female75Percent": 0.75,
	"FemaleSevenEights": 7.0 / 8.0,
	"AlwaysFemale": 1.0,
	"Genderless": -1.0,
}

var id: String = ""  ## The Pokemon's ID, used to get data from the PBS.json
var name: String = ""  ## The Pokemon's displayed name
var form_name: String = ""
var type_1: String = ""  ## The Pokemon's first type
var type_2: String = ""  ## The Pokemon's first type
var base_stats: Dictionary = {
	"HP": 1,
	"ATTACK": 1,
	"DEFENSE": 1,
	"SPEED": 1,
	"SPECIAL_ATTACK": 1,
	"SPECIAL_DEFENSE": 1,
}
var gender_ratio: float = GENDER_RATIOS.get("Female50Percent")
var growth_rate: PokemonEXP.GrowthRates = PokemonEXP.GrowthRates.Medium
var base_exp: int = 100
var evs_yield: Dictionary = {
	"HP": 0,
	"ATTACK": 0,
	"DEFENSE": 0,
	"SPEED": 0,
	"SPECIAL_ATTACK": 0,
	"SPECIAL_DEFENSE": 0,
}
var catch_rate: int = 255
var base_happiness: int = 70
var ability_1: String = ""
var ability_2: String = ""
var hidden_ability: String = ""
var moves: Array[Array] = []
var tutor_moves: PackedStringArray = []
var egg_moves: PackedStringArray = []
var egg_groups: PackedStringArray = []
var hatch_steps: int = 1
var incense: String = ""
var offspring: PackedStringArray = []
var height: float = 0.1
var weight: float = 0.1
var color: String = "Red"
var shape: String = "Head"
var habitat: String = ""
var category: String = "???"
var pokedex: String = "???"
var generation: int = 0
var flags: PackedStringArray = []
var item_common: String = ""
var item_uncommon: String = ""
var item_rare: String = ""
var evolutions: Array[Array] = []

# Textures
var front: Texture
var front_f: Texture
var back: Texture
var back_f: Texture
var front_s: Texture
var front_f_s: Texture
var back_s: Texture
var back_f_s: Texture
var icon: Texture
var icon_s: Texture
var footprint: Texture


func _init(id: String):
	self.id = id
	if data == {}:
		data = Global.pokemons.get(self.id)
	name = data.get("Name", name)
	form_name = data.get("FormName", form_name)
	var types: PackedStringArray = data.get("Types", "").split(",")
	type_1 = types[0]
	if types.size() > 1:
		type_2 = types[1]
	for i in 6:
		base_stats[base_stats.keys()[i]] = int(data.get("BaseStats", "").split(",")[i])
	gender_ratio = GENDER_RATIOS.get(data.get("GenderRatio", "Female50Percent"), gender_ratio)
	growth_rate = PokemonEXP.GrowthRates[data.get("GrowthRate", "Medium")]
	base_exp = data.get("BaseExp", base_exp)
	var split: PackedStringArray = data.get("EVs", ",").split(",")
	for i in range(0, split.size(), 2):
		evs_yield[split[i]] = int(split[i+1])
	catch_rate = data.get("CatchRate", catch_rate)
	base_happiness = data.get("Happiness", base_happiness)
	ability_1 = data.get("Abilities", ability_1).split(",")[0]
	if data.get("Abilities").split(",").size() > 1:
		ability_2 = data.get("Abilities", ability_2).split(",")[1]
	hidden_ability = data.get("HiddenAbilities", hidden_ability)
	
	var fetched_moves: PackedStringArray = data.get("Moves").split(",")
	for i in range(0, fetched_moves.size(), 2):
		moves.append([int(fetched_moves[i]), fetched_moves[i+1]])
	tutor_moves = data.get("TutorMoves", "").split(",")
	egg_moves = data.get("EggMoves", "").split(",")
	egg_groups = data.get("EggGroups", "").split(",")
	hatch_steps = data.get("HatchSteps", hatch_steps)
	incense = data.get("Incense", incense)
	offspring = data.get("Offspring", "").split(",")
	height = data.get("Height", height)
	weight = data.get("Weight", weight)
	color = data.get("Color", color)
	shape = data.get("Shape", shape)
	habitat = data.get("Habitat", habitat)
	category = data.get("Category", category)
	pokedex = data.get("Pokedex", pokedex)
	generation = data.get("Generation", generation)
	flags = data.get("Flags", "").split(",")
	item_common = data.get("WildItemCommon", item_common)
	item_uncommon = data.get("WildItemUncommon", item_uncommon)
	item_rare = data.get("WildItemRare", item_rare)
	var evos: PackedStringArray = data.get("Evolutions", ",,").split(",")
	for i in range(0, evos.size(), 3):
		evolutions.append([evos[i], evos[i+1], evos[i+2]])
		
	# Texture
	front = load(Global.FRONT_SPRITES_PATH + self.id + ".png")
	back = load(Global.BACK_SPRITES_PATH + self.id + ".png")
	front_s = load(Global.SHINY_FRONT_SPRITES_PATH + self.id + ".png")
	back_s = load(Global.SHINY_BACK_SPRITES_PATH + self.id + ".png")
	front_f = load(Global.FRONT_SPRITES_PATH + self.id + "_female.png") if FileAccess.file_exists(Global.FRONT_SPRITES_PATH + self.id + "_female.png") else null
	back_f = load(Global.BACK_SPRITES_PATH + self.id + "_female.png") if FileAccess.file_exists(Global.BACK_SPRITES_PATH + self.id + "_female.png") else null
	front_f_s = load(Global.SHINY_FRONT_SPRITES_PATH + self.id + "_female.png") if FileAccess.file_exists(Global.SHINY_FRONT_SPRITES_PATH + self.id + "_female.png") else null
	back_f_s = load(Global.SHINY_BACK_SPRITES_PATH + self.id + "_female.png") if FileAccess.file_exists(Global.SHINY_BACK_SPRITES_PATH + self.id + "_female.png") else null
	icon = load(Global.ICONS_SPRITES_PATH + self.id + ".png")
	icon_s = load(Global.SHINY_ICONS_SPRITES_PATH + self.id + ".png") if FileAccess.file_exists(Global.SHINY_ICONS_SPRITES_PATH + self.id + ".png") else null
	footprint = load(Global.FOOTPRINTS_SPRITES_PATH + self.id + ".png")

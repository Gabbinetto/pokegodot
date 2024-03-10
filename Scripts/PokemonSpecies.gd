class_name PokemonSpecies extends Resource


const GENDER_RATIOS: = {
	"AlwaysMale": 0.0,
	"FemaleOneEight": 1.0 / 8.0,
	"Female25Percent": 0.25,
	"Female50Percent": 0.5,
	"Female75Percent": 0.75,
	"FemaleSevenEights": 7.0 / 8.0,
	"AlwaysFemale": 1.0,
	"Genderless": -1.0,
}

var id: = ""  ## The Pokemon's ID, used to get data from the PBS.json
var name: = ""  ## The Pokemon's displayed name
var type_1: = ""  ## The Pokemon's first type
var type_2: = ""  ## The Pokemon's first type
var base_stats: = {
	"HP": 1,
	"ATTACK": 1,
	"DEFENSE": 1,
	"SPEED": 1,
	"SPECIAL_ATTACK": 1,
	"SPECIAL_DEFENSE": 1,
}
var gender_ratio: float = GENDER_RATIOS.get("Female50Percent")
var growth_rate: PokemonEXP.GrowthRates = PokemonEXP.GrowthRates.Medium
var base_exp: = 100
var evs_yield: = {
	"HP": 0,
	"ATTACK": 0,
	"DEFENSE": 0,
	"SPEED": 0,
	"SPECIAL_ATTACK": 0,
	"SPECIAL_DEFENSE": 0,
}
var catch_rate: = 255
var base_happiness = 70
var ability_1: = ""
var ability_2: = ""
var hidden_ability: = ""
var moves: = []
var tutor_moves: = []
var egg_moves: = []
var egg_groups: = []
var hatch_steps: = 1
var incense: = ""
var offspring: = ""
var height: = 0.1
var weight: = 0.1
var color: = "Red"
var shape: = "Head"
var habitat: = ""
var category: = "???"
var pokedex: = "???"
var generation: = 0
var flags: = []
var item_common: = ""
var item_uncommon: = ""
var item_rare: = ""
var evolutions: = []

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
	var data: Dictionary = Global.pokemons.get(self.id)
	name = data.get("Name", name)
	var types: PackedStringArray = data.get("Types", "").split(",")
	type_1 = types[0]
	if types.size() > 1:
		type_2 = types[1]
	for i in 6:
		base_stats[base_stats.keys()[i]] = int(data.get("BaseStats", "").split(",")[i])
	gender_ratio = GENDER_RATIOS.get(data.get("GenderRatio", "Female50Percent"), gender_ratio)
	growth_rate = PokemonEXP.GrowthRates[data.get("GrowthRate", growth_rate)]
	base_exp = data.get("BaseExp", "")
	for i in range(0, data.get("EVs").split(",").size(), 2):
		var split: PackedStringArray = data.get("EVs").split(",")
		evs_yield[split[i]] = int(split[i+1])
	catch_rate = data.get("CatchRate")
	base_happiness = data.get("Happiness")
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
	offspring = data.get("Offspring", offspring)
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
	icon_s = load(Global.SHINY_ICONS_SPRITES_PATH + self.id + ".png")
	footprint = load(Global.FOOTPRINTS_SPRITES_PATH + self.id + ".png")

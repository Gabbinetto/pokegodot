class_name PokemonSpecies extends Resource


## Pokegodot's PokemonSpecies class
##
## Pokegodot's PokemonSpecies class. It defines a Pokemon species and all it's properties. Those aren't meant to change at runtime.
## The data is taken from [member DB.pokemon], therefore [code]pokemon.json[/code].
## Not to be confused with [Pokemon].


var id: String = "" ## The species id. Always all caps, like [code]BULBASAUR[/code]. Matches the key in [member DB.pokemon].
var name: String = "Unnamed" ## The species name.
var form_number: int = 0 ## The form number. 0 if is default form.
var form_name: String = "" ## The form name, describes the form. For example, Alolan Vulpix form name is "Alolan".
var types: Array[int] = [] ## This species types.
var base_stats: Dictionary[String, int] = { ## This species base stats. The keys match [member Globals.STATS] and the values are [int].
	Globals.STATS.HP: 1,
	Globals.STATS.ATTACK: 1,
	Globals.STATS.DEFENSE: 1,
	Globals.STATS.SPECIAL_ATTACK: 1,
	Globals.STATS.SPECIAL_DEFENSE: 1,
	Globals.STATS.SPEED: 1,
}
var gender_ratio: float = 4.0 ## This species chance of being female, in eights, it is -1 if the species is genderless. To get the actual chance as a float from 0 to 1, see [member female_chance].
var female_chance: float: ## Returns the actual chance of being female, that being [member gender_ratio] divided by 8.
	get: return gender_ratio / 8.0
var growth_rate: Experience.GrowthRates ## The species growth rate.
var base_exp: int = 0 ## The base value needed to calculate a species exp reward.
var evs: Dictionary[String, int] = { ## The evs given by this species. The keys match [member Globals.STATS] and the values are [int].
	Globals.STATS.HP: 0,
	Globals.STATS.ATTACK: 0,
	Globals.STATS.DEFENSE: 0,
	Globals.STATS.SPECIAL_ATTACK: 0,
	Globals.STATS.SPECIAL_DEFENSE: 0,
	Globals.STATS.SPEED: 0,
}
var catch_rate: int = 255 ## This species catch rate.
var base_happiness: int = 70 ## This species starting happiness when caught.
var abilities: Array[String] = [] ## A list of this species possible abilities as [PokemonAbility] ids.
var hidden_abilities: Array[String] = [] ## Same as [member abilities], but for hidden abilities. Usually pokemon have just one hidden ability.
## A list of this species level up moves. Contains dictionaries with two keys.
## [codeblock]
## {
##   "id": "", # The PokemonMove id
##   "level": 0, # The level this move is learnt at
## }
## [/codeblock]
## If the level is 0, it's learnt at evolution. If the level is -1, it's only learnt through move reminding.
var moves: Array[Dictionary] = []
var tutor_moves: Array[String] = [] ## A list of this species tutor moves as [PokemonMove] ids. Learnable through Tutors, TMs and HMs.
var egg_moves: Array[String] = [] ## A list of this species egg moves as [PokemonMove] ids. Learnable through breeding.
var egg_groups: Array[String] = [] ## A list of all this species egg groups, used in breeding.
var egg_cycles: int = 1 ## The egg cycles needed for this species to hatch. 1 egg cycle translates to 256 steps.
## A list of dictionaries holding informations about a species possible offsprings
## [codeblock]
## {
##   "id": "", # The id of the offspring
##   "form_number": 0, # The form number of the offspring
##   "item": "" # The id of the item needed to get the offspring, such as incense for many babies
##   "special_moves": [] # Special moves that the offspring will have. For Volt Tackle and Pichu
## }
## [/codeblock]
## Offsprings have an equal chance to be picked, but offsprings requiring an item have priority over those who don't.
## For example, if a species has 3 offsprings, and one of them requires an incense,
## if the pokemon has the incense the only possible offspring will be the one requiring the incense,
## otherwise it will be a 50/50 between one of the other two offsprings.
var offspring: Array[Dictionary] = []
## Dictionary holding pokedex information. The keys are: [br]
## - [code]height[/code]: [int][br]
## - [code]weigth[/code]: [int][br]
## - [code]color[/code]: [String][br]
## - [code]shape[/code]: [String][br]
## - [code]habitat[/code]: [String][br]
## - [code]category[/code]: [String][br]
## - [code]description[/code]: [String][br]
## - [code]generation[/code]: [int]
var info: Dictionary[String, Variant] = {
	"height": 0.0,
	"weight": 0.0,
	"color": "Red",
	"shape": "Head",
	"habitat": "",
	"category": "???",
	"description": "???",
	"generation": 0,
}
## Flags useful for various things, such as fateful encounters.
var flags: Array[String] = []
## List of wild items. Those are dictionaries with the [code]id[/code] key,
## holding the id of the item, and the [code]weight[/code] key,
## used in the weigthed random function to spawn it.
var items: Array[Dictionary] = []
var evolutions: Array[Dictionary] = [] # TODO: Implement
# Form properties
## The ID of the item needed for this pokemon to mega evolve. Currently unused.
var mega_stone: String = ""
## The ID of the move needed for this pokemon to mega evolve. Currently unused.
var mega_move: String = ""
## The message shown when this pokemon mega evolves. Currently unused.
var mega_message: String = "{pokemon}'s {mega_stone} is reacting to {player}'s Mega Ring!"
## The form this pokemon goes back to when mega evolution ends. Currently unused.
var unmega_form: int = 0
## If [code]pokedex_form[/code] is different from 0, this pokemon species is invisible in the pokedex and
## the form corresponding to [code]pokedex_form[/code] will be shown instead. [br][br]
## Used in instances such as Zygarde, who has two complete forms to remember if it turned complete from the
## 10% form or the 50% form. The second complete form just points to the first one in the pokedex by having
## [code]pokedex_form[/code] set to the first complete form.
var pokedex_form: int = 0


# Sprites
var sprite_front_n_m: Texture2D ## Front normal male sprite.
var sprite_front_n_f: Texture2D ## Front normal female sprite.
var sprite_front_s_m: Texture2D ## Front shiny male sprite.
var sprite_front_s_f: Texture2D ## Front shiny female sprite.
var sprite_back_n_m: Texture2D ## Back normal male sprite.
var sprite_back_n_f: Texture2D ## Back normal female sprite.
var sprite_back_s_m: Texture2D ## Back shiny male sprite.
var sprite_back_s_f: Texture2D ## Back shiny female sprite.
var sprite_icon_n: Texture2D ## Icon normal sprite.
var sprite_icon_s: Texture2D ## Icon shiny sprite.
var sprite_footprint: Texture2D ## Footprint sprite.

# Shorthand variables
var hp: int: ## Shorthand for [member base_stats] HP key.
	get: return base_stats.HP
	set(value): base_stats.HP = value
var attack: int: ## Shorthand for [member base_stats] ATTACK key.
	get: return base_stats.ATTACK
	set(value): base_stats.ATTACK = value
var defense: int: ## Shorthand for [member base_stats] DEFENSE key.
	get: return base_stats.DEFENSE
	set(value): base_stats.DEFENSE = value
var spattack: int: ## Shorthand for [member base_stats] SPECIAL_ATTACK key.
	get: return base_stats.SPECIAL_ATTACK
	set(value): base_stats.SPECIAL_ATTACK = value
var spdefense: int: ## Shorthand for [member base_stats] SPECIAL_DEFENSE key.
	get: return base_stats.SPECIAL_DEFENSE
	set(value): base_stats.SPECIAL_DEFENSE = value
var speed: int: ## Shorthand for [member base_stats] SPEED key.
	get: return base_stats.SPEED
	set(value): base_stats.SPEED = value
var metrics: Dictionary[String, int]: ## Shorthand for [method get_metrics] of a species instance.
	get: return get_metrics(id, form_number)
var exp_table: Array[int]: ## Shorthand for the EXP table from [member Experience.tables] of a species instance.
	get: return Experience.tables[growth_rate]


func _init(_id: String, _form_number: int = 0) -> void:
	id = _id
	form_number = _form_number

	var data: Dictionary[String, Variant]
	data.assign(DB.pokemon[id].forms[0])
	if form_number != 0:
		for form: Dictionary in DB.pokemon.get(id).forms:
			if form.form_number != form_number:
				continue
			for key: String in form:
				data[key] = form[key]
			break

	# Typed arrays and dictionaries
	types.assign(data.get("types", types))
	data.erase("types")
	base_stats.assign(data.get("base_stats", base_stats))
	data.erase("base_stats")
	evs.assign(data.get("evs", evs))
	data.erase("evs")
	abilities.assign(data.get("abilities", abilities))
	data.erase("abilities")
	hidden_abilities.assign(data.get("hidden_abilities", hidden_abilities))
	data.erase("hidden_abilities")
	moves.assign(data.get("moves", moves))
	data.erase("moves")
	tutor_moves.assign(data.get("tutor_moves", tutor_moves))
	data.erase("tutor_moves")
	egg_moves.assign(data.get("egg_moves", egg_moves))
	data.erase("egg_moves")
	egg_groups.assign(data.get("egg_groups", egg_groups))
	data.erase("egg_groups")
	offspring.assign(data.get("offspring", offspring))
	data.erase("offspring")
	flags.assign(data.get("flags", flags))
	data.erase("flags")
	items.assign(data.get("items", items))
	data.erase("items")
	evolutions.assign(data.get("evolutions", evolutions))
	data.erase("evolutions")


	for attribute: String in data:
		if attribute in self:
			set(attribute, data[attribute])

	_set_sprites()


func _set_sprites() -> void:
	sprite_front_n_m = Utils.load_no_error(DB.POKEMON_SPRITES_PATH + id + "_" + str(form_number) + "/front_n_m.png")
	if not sprite_front_n_m:
		sprite_front_n_m = DB.default_front_sprite
	sprite_front_n_f = Utils.load_no_error(DB.POKEMON_SPRITES_PATH + id + "_" + str(form_number) + "/front_n_f.png")
	if not sprite_front_n_f:
		sprite_front_n_f = sprite_front_n_m
	sprite_front_s_m = Utils.load_no_error(DB.POKEMON_SPRITES_PATH + id + "_" + str(form_number) + "/front_s_m.png")
	if not sprite_front_s_m:
		sprite_front_s_m = sprite_front_n_m
	sprite_front_s_f = Utils.load_no_error(DB.POKEMON_SPRITES_PATH + id + "_" + str(form_number) + "/front_s_f.png")
	if not sprite_front_s_f:
		sprite_front_s_f = sprite_front_s_m

	sprite_back_n_m = Utils.load_no_error(DB.POKEMON_SPRITES_PATH + id + "_" + str(form_number) + "/back_n_m.png")
	if not sprite_back_n_m:
		sprite_back_n_m = DB.default_back_sprite
	sprite_back_n_f = Utils.load_no_error(DB.POKEMON_SPRITES_PATH + id + "_" + str(form_number) + "/back_n_f.png")
	if not sprite_back_n_f:
		sprite_back_n_f = sprite_back_n_m
	sprite_back_s_m = Utils.load_no_error(DB.POKEMON_SPRITES_PATH + id + "_" + str(form_number) + "/back_s_m.png")
	if not sprite_back_s_m:
		sprite_back_s_m = sprite_back_n_m
	sprite_back_s_f = Utils.load_no_error(DB.POKEMON_SPRITES_PATH + id + "_" + str(form_number) + "/back_s_f.png")
	if not sprite_back_s_f:
		sprite_back_s_f = sprite_back_s_m

	sprite_icon_n = Utils.load_no_error(DB.POKEMON_SPRITES_PATH + id + "_" + str(form_number) + "/icon_n.png")
	if not sprite_icon_n:
		sprite_icon_n = DB.default_icon_sprite
	sprite_icon_s = Utils.load_no_error(DB.POKEMON_SPRITES_PATH + id + "_" + str(form_number) + "/icon_s.png")
	if not sprite_icon_s:
		sprite_icon_s = sprite_icon_n

	sprite_footprint = Utils.load_no_error(DB.POKEMON_SPRITES_PATH + id + "_" + str(form_number) + "/footprint.png")


## Get the pokemon metrics from [member DB.metrics].
static func get_metrics(pokemon_id: String, form: int = 0) -> Dictionary[String, int]:
	var data: Dictionary[String, int] = {}
	for form_data: Dictionary in DB.metrics.get(pokemon_id, []):
		if form_data.form_number == form:
			data.assign(form_data)
			break
	if form > 0 and data.is_empty():
		data.assign(DB.metrics.get(pokemon_id)[0])
	return data

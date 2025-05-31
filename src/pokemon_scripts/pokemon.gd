class_name Pokemon extends Resource

## Pokegodot's Pokemon class
##
## Pokegodot's Pokemon class. It defines a single Pokemon and all it's properties.
## Not to be confused with [PokemonSpecies].

signal hp_changed(old_hp: int) ## Emitted when [member hp] changes.
signal level_up ## Emitted when the pokemon levels up, therefore when [member experience] increases enough for [member level] to go up.

enum Genders {MALE, FEMALE, GENDERLESS} ## Possible pokemon genders.
enum Markings {NONE, BLACK, BLUE, PINK} ## Possible markings states.

const MAX_NICKNAME_SIZE: int = 12

# Core properties
var species: PokemonSpecies ## This pokemon's species.
var name: String = "": ## This pokemon's nickname. If set to empty, it will return the [member species] [member PokemonSpecies.name].
	get: return species.name if not name else name
	set(value): name = value.left(MAX_NICKNAME_SIZE)
var happiness: int = 70 ## This pokemon's happiness.
var gender: Genders = Genders.MALE ## This pokemon's gender.
var nature: String = "" ## This pokemon's nature. Must be one of [member Globals.natures] keys.
var shiny: bool = false ## If true, this pokemon is shiny.
var super_shiny: bool = false: ## If true, this pokemon has shiny and has different, rarer sparkles.
	set(value):
		super_shiny = value
		if super_shiny:
			shiny = super_shiny
var ability: PokemonAbility ## This pokemon's ability.
var has_hidden_ability: bool: ## True if [member ability] is an hidden ability set in the [member species] [member PokemonSpecies.hidden_abilities]. If set manually, sets [member ability] to the first hidden ability (If true) or the first normal ability (If false).
	set(value):
		if has_hidden_ability == value:
			return
		has_hidden_ability = value
		ability_index = ability_index
## This pokemons [member ability] index. Corresponds to the index of the ability id in the [member species] [member PokemonSpecies.abilities]
## property (If [member has_hidden_ability] is false) or the [member PokemonSpecies.hidden_abilities] property (If [member has_hidden_ability] is true)
var ability_index: int:
	set(value):
		ability_index = value
		if has_hidden_ability:
			ability = PokemonAbility.new(
				species.hidden_abilities[
					clampi(value, 0, species.hidden_abilities.size() - 1)
				]
			)
		else:
			ability = PokemonAbility.new(
				species.abilities[
					clampi(value, 0, species.abilities.size() - 1)
				]
			)
## Random value bound to the instance of one pokemon, used in things such as [url=https://bulbapedia.bulbagarden.net/wiki/Personality_value#Shininess]shininess[/url]
var personality_value: int = 0
## Extension of [member personality_value]. Check [url]https://bulbapedia.bulbagarden.net/wiki/Personality_value[/url].
var encryption_constant: int = 0
var secret_id: int = 0 ## A random 4 digit number like [member personality_value].
# Growth and stats
var experience: int = 0: ## This pokemon's experience points, limited between 0 and the highest value in the growth rate table ([member Experience.tables])
	set(value):
		var old_level: int = level
		experience = clampi(value, 0, Experience.tables[species.growth_rate][-1])
		if level > old_level:
			level_up.emit()
			SignalRouter.pokemon_level_up.emit(self)
## This pokemon's level. When set, it also sets [member experience] to the closest needed experience points to get to the set level. [br]
## For example, if level 2 requires 10 points, 3 requires 20 and 4 requires 40 and the pokemon has 23 points, when [member level] gets set to 2,
## [member experience] will be 19. When set to 4, [member experience] will be 40. When set to 3, [member experience] will remain the same.
var level: int = 1:
	get: return Experience.get_level_at_exp(experience, species.growth_rate)
	set(value):
		var table: Array[int] = Experience.tables[species.growth_rate]
		value = clampi(value, 1, Experience.MAX_LEVEL)
		if value >= table.size():
			value = table.size()
			experience = table[-1]
			return
		if experience < table[value - 1]:
			experience = table[value - 1]
		elif experience >= table[value]:
			experience = table[value] - 1
## This pokemon's stats, calculated through [method calculate_stats]. Keys should match [member Globals.STATS] values.
var stats: Dictionary[String, int] = {
	Globals.STATS.HP: 1,
	Globals.STATS.ATTACK: 1,
	Globals.STATS.DEFENSE: 1,
	Globals.STATS.SPECIAL_ATTACK: 1,
	Globals.STATS.SPECIAL_DEFENSE: 1,
	Globals.STATS.SPEED: 1,
}
## This pokemon's EVs. Keys should match [member Globals.STATS] values.
var evs: Dictionary[String, int] = {
	Globals.STATS.HP: 0,
	Globals.STATS.ATTACK: 0,
	Globals.STATS.DEFENSE: 0,
	Globals.STATS.SPECIAL_ATTACK: 0,
	Globals.STATS.SPECIAL_DEFENSE: 0,
	Globals.STATS.SPEED: 0,
}
## This pokemon's IVs. Keys should match [member Globals.STATS] values.
var ivs: Dictionary[String, int] = {
	Globals.STATS.HP: 0,
	Globals.STATS.ATTACK: 0,
	Globals.STATS.DEFENSE: 0,
	Globals.STATS.SPECIAL_ATTACK: 0,
	Globals.STATS.SPECIAL_DEFENSE: 0,
	Globals.STATS.SPEED: 0,
}
var pokerus_strain: int = 0
var pokerus_day_left: int = 0
var has_pokerus: bool:
	get: return pokerus_strain != 0
var has_pokerus_cured: bool:
	get: return has_pokerus and pokerus_day_left <= 0
# Status outside of battle
## This pokemon's hp in and out of battle. Limited between 0 and [member max_hp].
var hp: int = 1:
	set(value):
		var old: int = hp
		hp = clamp(value, 0, max_hp)
		hp_changed.emit(old)
var status: PokemonStatus ## This pokemon's current status.
var held_item: Item ## The [Item] this pokemon holds currently.
# Breeding and obtainement
var egg_cycles_left: int = 0 ## The egg cycles left for hatching. 1 cycle is 256 steps.
var is_egg: bool: ## If this pokemon is in the egg, basically if [member egg_cycles_left] is greater than 0. When set, it either sets [member egg_cycles_left] to 0, if false, or to [member species] [code]egg_cycles[/code] if true.
	get: return egg_cycles_left > 0
	set(value):
		if is_egg == value:
			return
		egg_cycles_left = species.egg_cycles * int(value)
var original_trainer_id: int = 0 ## Original trainer's ID.
var original_trainer_secret_id: int = 0 ## Original trainers's secred ID.
var original_trainer_name: String = "" ## Original trainers's name.
var trainer_id: int = 0 ## The current trainer's ID.
var obtained_level: int = 1 ## The level this was obtained at.
## The map this was obtained on.
var obtained_map: String = "" # TODO: Review when maps are implemented
var obtained_time: float = 0 ## The UNIX time this was obtained at.
var has_hatched: bool = false ## If this pokemon was obtained through hatching or not.
var hatched_map: String = "" ## The map this was hatched on.
var hatched_time: int = 0 ## The UNIX time this pokemon was hatched at.
var language: Globals.Languages = Globals.Languages.UNKNOWN ## This pokemon's language.
# Moves
var moves: Array[PokemonMove] ## This pokemon's 4 or less learnt moves.
# Miscellaneous
var pokeball: String ## The pokeball id this pokemon was caught in.
## This pokemon contest stats. Keys should match [member Globals.CONTEST_STATS] values.
var contest_stats: Dictionary[String, int] = {
	Globals.CONTEST_STATS.BEAUTY: 0,
	Globals.CONTEST_STATS.COOL: 0,
	Globals.CONTEST_STATS.CUTE: 0,
	Globals.CONTEST_STATS.SMART: 0,
	Globals.CONTEST_STATS.TOUGH: 0,
	Globals.CONTEST_STATS.SHEEN: 0,
}
## This pokemon's markings.
var markings: Array[Markings] = [Markings.NONE, Markings.NONE, Markings.NONE, Markings.NONE, Markings.NONE, Markings.NONE]
## This pokemon's ribbons.
var ribbons: Array[int] # TODO: Change to enum eventually
## This pokemon's marks.
var marks: Array[int] # TODO: Change to enum eventually
## The pokemon this one is fused with. Used for pokemons like Kyurem (with Zekrom and Reshiram), Necrozma (With Solgaleo and Lunala) and Calyrex (With Glastrier and Spectrier).
var fused_pokemon: Pokemon

# Sprites
var sprite_front: Texture ## This pokemon's front sprite.
var sprite_back: Texture ## This pokemon's back sprite.
var sprite_icon: Texture ## This pokemon's icon sprite.

# Shorthands
var max_hp: int: ## Shorthand for [member stats] HP key
	get: return stats.HP
	set(value): stats.HP = value
var attack: int: ## Shorthand for [member stats] ATTACK key
	get: return stats.ATTACK
	set(value): stats.ATTACK = value
var defense: int: ## Shorthand for [member stats] DEFENSE key
	get: return stats.DEFENSE
	set(value): stats.DEFENSE = value
var spattack: int: ## Shorthand for [member stats] SPECIAL_ATTACK key
	get: return stats.SPECIAL_ATTACK
	set(value): stats.SPECIAL_ATTACK = value
var spdefense: int: ## Shorthand for [member stats] SPECIAL_DEFENSE key
	get: return stats.SPECIAL_DEFENSE
	set(value): stats.SPECIAL_DEFENSE = value
var speed: int: ## Shorthand for [member stats] SPEED key
	get: return stats.SPEED
	set(value): stats.SPEED = value


func _init(_species: Variant, form: int = 0, attributes: Dictionary[String, Variant] = {}) -> void:

	if _species is PokemonSpecies:
		species = _species
	elif _species is String:
		species = PokemonSpecies.new(_species, form)

	original_trainer_name = PlayerData.player_name
	original_trainer_id = PlayerData.player_id
	original_trainer_secret_id = PlayerData.secret_id
	trainer_id = PlayerData.player_id
	secret_id = Globals.rng.randi_range(0, 9999)

	obtained_time = Time.get_unix_time_from_system()

	for attribute: String in attributes:
		if attribute in self:
			match attribute:
				"evs", "ivs", "moves", "contest_stats", "markings", "ribbons", "marks":
					get(attribute).assign(attributes[attribute])
				_:
					set(attribute, attributes[attribute])

	if not ability:
		ability = PokemonAbility.new(species.abilities[0])

	obtained_level = level

	calculate_stats()
	set_sprites()
	heal()

	if moves.size() == 0:
		set_moves(level)


	level_up.connect(_on_level_up)


func _on_level_up() -> void:
	var old_max_hp: int = max_hp
	calculate_stats()
	hp += max_hp - old_max_hp



## Resets the sprites.
func set_sprites() -> void:
	if shiny or super_shiny:
		sprite_front = species.sprite_front_s_f if gender == Genders.FEMALE else species.sprite_front_s_m
		sprite_back = species.sprite_back_s_f if gender == Genders.FEMALE else species.sprite_back_s_m
		sprite_icon = species.sprite_icon_s
		return
	sprite_front = species.sprite_front_n_f if gender == Genders.FEMALE else species.sprite_front_n_m
	sprite_back = species.sprite_back_n_f if gender == Genders.FEMALE else species.sprite_back_n_m
	sprite_icon = species.sprite_icon_n


## Recalculates stats. See [url]https://bulbapedia.bulbagarden.net/wiki/Stat#Generation_III_onward[/url]
func calculate_stats() -> void:
	for stat: String in Globals.STATS:
		stats[stat] = calculate_stat(self, stat)


## Heal this pokemon.
func heal() -> void:
	hp = max_hp
	status = null


## Set this pokemon's moves to the last four moves learnt at [param _level]
func set_moves(_level: int, clear_old: bool = false) -> void:
	if clear_old:
		moves.clear()
	for i: int in range(_level, 0, -1):
		if moves.size() >= 4:
			break
		var moves_at_level: Array[String]
		for move: Dictionary in species.moves:
			if move.level < 1:
				continue
			if move.level > _level:
				break
			moves_at_level.append(move.id)
		moves_at_level.reverse()

		for move_id: String in moves_at_level:
			var learnt_moves: Array[String]
			learnt_moves.assign(moves.map(func(move: PokemonMove): return move.id))
			if moves.size() >= 4 or learnt_moves.has(move_id):
				break
			moves.append(PokemonMove.new(move_id))


func as_save_data() -> Dictionary[String, Variant]:
	var data: Dictionary[String, Variant] = {
		"species_id": species.id,
		"form": species.form_number,
		"name": name if name != species.name else "",
		"happiness": happiness,
		"gender": gender,
		"nature": nature,
		"shiny": shiny,
		"super_shiny": super_shiny,
		"has_hidden_ability": has_hidden_ability,
		"ability_index": ability_index,
		"personality_value": personality_value,
		"encryption_constant": encryption_constant,
		"secret_id": secret_id,
		"experience": experience,
		"evs": evs,
		"ivs": ivs,
		"pokerus_strain": pokerus_strain,
		"pokerus_day_left": pokerus_day_left,
		"hp": hp,
		"status": status.as_save_data() if status else {},
		"held_item": held_item.as_save_data() if held_item else {},
		"egg_cycles_left": egg_cycles_left,
		"original_trainer_id": original_trainer_id,
		"original_trainer_secret_id": original_trainer_secret_id,
		"original_trainer_name": original_trainer_name,
		"trainer_id": trainer_id,
		"obtained_level": obtained_level,
		"obtained_map": obtained_map,
		"obtained_time": obtained_time,
		"has_hatched": has_hatched,
		"hatched_map": hatched_map,
		"hatched_time": hatched_time,
		"language": language,
		"moves": [],
		"pokeball": pokeball,
		"contest_stats": contest_stats,
		"markings": markings,
		"ribbons": ribbons,
		"marks": marks,
		"fused_pokemon": fused_pokemon.as_save_data() if fused_pokemon else {},
	}

	# Add moves
	for move: PokemonMove in moves:
		data.moves.append(move.as_save_data())

	return data


static func from_save_data(data: Dictionary[String, Variant]) -> Pokemon:
	var attributes: Dictionary[String, Variant] = data.duplicate()
	attributes.erase("species_id")
	attributes.erase("form")

	var buffer: Dictionary[String, Variant] = {}
	buffer.assign(data.status)
	attributes.status = PokemonStatus.from_save_data(buffer)
	buffer.assign(data.held_item)
	attributes.held_item = Item.from_save_data(buffer)

	# Add moves
	attributes.moves = []
	for move: Dictionary[String, Variant] in data.moves:
		attributes.moves.append(PokemonMove.from_save_data(move))

	# Fused pokemon
	if data.fused_pokemon:
		attributes.fused_pokemon = Pokemon.from_save_data(data.fused_pokemon)

	return Pokemon.new(data.species_id, data.form, attributes)



## Generate a random pokemon. [param fixed_attributes] is a dictionary of attributes you don't want to be randomly generated, rather be set to the value held in the dictionary.
static func generate(species_id: String, form: int = 0, fixed_attributes: Dictionary[String, Variant] = {}) -> Pokemon:

	var _species: PokemonSpecies = PokemonSpecies.new(species_id, form)

	# Get personality value and encryption constant as most random properties are based on that
	if not fixed_attributes.has("personality_value"):
		fixed_attributes["personality_value"] = Globals.rng.randi()
	var _personality_value = fixed_attributes["personality_value"]

	if not fixed_attributes.has("encryption_constant"):
		fixed_attributes["encryption_constant"] = Globals.rng.randi()
	var _encryption_constant = fixed_attributes["encryption_constant"]


	if not fixed_attributes.has("gender"):
		var is_female: bool = Globals.rng.randf() <= _species.female_chance
		if _species.gender_ratio == -1:
			fixed_attributes["gender"] = Genders.GENDERLESS
		elif is_female:
			fixed_attributes["gender"] = Genders.FEMALE
		else:
			fixed_attributes["gender"] = Genders.MALE

	if not fixed_attributes.has("nature"):
		fixed_attributes["nature"] = Globals.natures.keys().pick_random()

	# https://bulbapedia.bulbagarden.net/wiki/Personality_value#Shininess
	if not fixed_attributes.has("shiny") or not fixed_attributes.has("super_shiny"):
		# TODO: Account for modifiers like the Masuda method
		var p1: int = _personality_value / 0x10000
		var p2: int = _personality_value % 0x10000
		var s: int = (p1 ^ p2 ^ PlayerData.player_id ^ PlayerData.secret_id) & 0xFFFF
		if s < Globals.SHINY_THRESHOLD:
			fixed_attributes["shiny"] = true
			if s == 0:
				fixed_attributes["super_shiny"] = true

	if not fixed_attributes.has("ability"):
		fixed_attributes["ability"] = _species.abilities.pick_random()


	if not fixed_attributes.has("ivs"):
		var _ivs: Dictionary[String, int] = {}
		for stat: String in Globals.STATS.values():
			_ivs[stat] = randi_range(0, 31)
		fixed_attributes["ivs"] = _ivs

	var pokemon: Pokemon = Pokemon.new(_species, 0, fixed_attributes)

	return pokemon


## Calculate the [param pokemon] [param stat]. [param stat] should be in [member Globals.STATS].[br]
## From [url]https://bulbapedia.bulbagarden.net/wiki/Stat#Generation_III_onward[/url]
static func calculate_stat(pokemon: Pokemon, stat: String) -> int:
	if stat == Globals.STATS.HP:
		if pokemon.species.id == "SHEDINJA":
			return 1
		return floori(
			(((2.0 * pokemon.species.base_stats.HP + pokemon.ivs.HP + floorf(pokemon.evs.HP / 4.0))) * pokemon.level) / 100.0
		) + pokemon.level + 10
	return floori(
		(floori((((2 * pokemon.species.base_stats[stat] + pokemon.ivs[stat] + floori(pokemon.evs[stat] / 4.0))) * pokemon.level) / 100.0) + 5) * Globals.natures[pokemon.nature][stat]
	)

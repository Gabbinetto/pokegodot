class_name Pokemon extends Resource

## Pokegodot's Pokemon class
##
## Pokegodot's Pokemon class. It defines a single Pokemon and all it's properties.
## Not to be confused with [PokemonSpecies]

signal hp_changed(old_hp: int, current_hp: int)

enum Genders {MALE, FEMALE, GENDERLESS}
enum Markings {NONE, BLACK, BLUE, PINK}


# Core properties
var species: PokemonSpecies
var name: String = ""
var happiness: int = 70
var gender: Genders = Genders.MALE
var nature: String = ""
var shiny: bool = false
var super_shiny: bool = false
var ability: PokemonAbility
var has_hidden_ability: bool:
	get: return species.hidden_abilities.has(ability.id)
var personality_value: int = 0
# Growth and stats
var experience: int = 0:
	set(value): experience = clampi(value, 0, Experience.tables[species.growth_rate][-1])
var level: int = 1:
	get:
		var out: int = 1
		for i in Experience.tables[species.growth_rate].size():
			var level_exp: int = Experience.tables[species.growth_rate][i]
			if experience >= level_exp:
				out = i + 1
			else:
				break
		return out
	set(value):
		var table: Array[int] = Experience.tables[species.growth_rate]
		level = value
		if level >= table.size():
			level = table.size()
			experience = table[-1]
			return
		if experience < table[level - 1]:
			experience = table[level - 1]
		elif experience >= table[level]:
			experience = table[level] - 1
var stats: Dictionary = {
	Globals.STATS.HP: 1,
	Globals.STATS.ATTACK: 1,
	Globals.STATS.DEFENSE: 1,
	Globals.STATS.SPECIAL_ATTACK: 1,
	Globals.STATS.SPECIAL_DEFENSE: 1,
	Globals.STATS.SPEED: 1,
}
var evs: Dictionary = {
	Globals.STATS.HP: 0,
	Globals.STATS.ATTACK: 0,
	Globals.STATS.DEFENSE: 0,
	Globals.STATS.SPECIAL_ATTACK: 0,
	Globals.STATS.SPECIAL_DEFENSE: 0,
	Globals.STATS.SPEED: 0,
}
var ivs: Dictionary = {
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
var hp: int = 1:
	set(value):
		var old: int = hp
		hp = clamp(value, 0, stats.HP)
		hp_changed.emit(old, hp)
var status: PokemonStatus
var held_item: Item
# Breeding and obtainement
var egg_cycles_left: int = 0
var is_egg: bool:
	get: return egg_cycles_left > 0
var original_trainer_id: int = 0
var original_trainer_name: String = ""
var trainer_id: int = 0
var obtained_level: int = 1
var obtained_map: String = "" # TODO: Review when maps are implemented
var obtained_time: int = 0
var has_hatched: bool = false
var hatched_map: String = ""
var hatched_time: int = 0
var language: Globals.Languages = Globals.Languages.UNKNOWN
# Moves
var moves: Array[PokemonMove]
# Miscellaneous
var pokeball: String
var constest_stats: Dictionary = {
	Globals.CONTEST_STATS.BEAUTY: 0,
	Globals.CONTEST_STATS.COOL: 0,
	Globals.CONTEST_STATS.CUTE: 0,
	Globals.CONTEST_STATS.SMART: 0,
	Globals.CONTEST_STATS.TOUGH: 0,
	Globals.CONTEST_STATS.SHEEN: 0,
}
var markings: Array[Markings] = [Markings.NONE, Markings.NONE, Markings.NONE, Markings.NONE, Markings.NONE, Markings.NONE]
var ribbons: Array[int] # TODO: Change to enum eventually
var marks: Array[int] # TODO: Change to enum eventually
var fused_pokemon: Pokemon

# Sprites
var sprite_front: Texture
var sprite_back: Texture
var sprite_icon: Texture


func _init(species_id: String, form: int = 0, attributes: Dictionary = {}) -> void:
	species = PokemonSpecies.new(species_id, form)

	for attribute: String in attributes:
		if attribute in self:
			set(attribute, attributes[attribute])
	
	set_sprites()


func set_sprites() -> void:
	if shiny or super_shiny:
		sprite_front = species.sprite_front_s_f if gender == Genders.FEMALE else species.sprite_front_s_m
		sprite_back = species.sprite_back_s_f if gender == Genders.FEMALE else species.sprite_back_s_m
		sprite_icon = species.sprite_icon_s
		return
	sprite_front = species.sprite_front_n_f if gender == Genders.FEMALE else species.sprite_front_n_m
	sprite_back = species.sprite_back_n_f if gender == Genders.FEMALE else species.sprite_back_n_m
	sprite_icon = species.sprite_icon_n
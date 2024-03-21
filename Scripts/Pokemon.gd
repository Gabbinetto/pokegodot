class_name Pokemon extends Resource

## Pokegodot's Pokemon class
##
## Pokegodot's Pokemon class. It defines a single Pokemon and all it's properties.
## Not to be confused with [PokemonSpecies]

enum {MALE, FEMALE, GENDERLESS}

signal hp_changed(old_hp: int, new_hp: int)

var species: PokemonSpecies
var name: String = "" ## Pokemon nickname
var level: int = 1 
var ability: String = ""
var ability_index: int = 0
var gender: int = MALE
var nature: String = ""
var shiny: bool = false
var super_shiny: bool = false
var form: int = 0
var hp: = 0:
	set(value):
		hp_changed.emit(hp, value)
		hp = min(value, 0)
# Stats ?
var happiness: int = 70
var status: String = ""
# Status count ?
var steps_to_hatch: int = 0
var moves: Array[Move]
var pokeball: String = ""
var item: String = ""
# Mail ?
var ev: Dictionary = {
	"HP": 0,
	"ATTACK": 0,
	"DEFENSE": 0,
	"SPEED": 0,
	"SPECIAL_ATTACK": 0,
	"SPECIAL_DEFENSE": 0,
}
var iv: Dictionary = {
	"HP": 0,
	"ATTACK": 0,
	"DEFENSE": 0,
	"SPEED": 0,
	"SPECIAL_ATTACK": 0,
	"SPECIAL_DEFENSE": 0,
}
var pokerus: int = 0
var fused: bool = false
var contest: Dictionary = {
	"BEAUTY": 0,
	"COOL": 0,
	"CUTE": 0,
	"SMART": 0,
	"TOUGH": 0,
	"SHEEN": 0,
}
var markings: Array[int] = [0, 0, 0, 0, 0, 0]
var ribbons: Array[String]
var personal_id: int
var owner_id: int
var owner_name: String
var owner_gender: int = 0
var owner_language: int = 2
var obtain_method: int = 0

# Sprite data
var front: Texture
var back: Texture
var icon: Texture

func _init(id: String, attributes: Dictionary = {}) -> void:
	species = PokemonSpecies.new(id)
	
	for attribute in attributes:
		if attribute in self:
			set(attribute, attributes.get(attribute))

	set_sprites()

func set_sprites() -> void:
	icon = species.icon_s if (shiny and Flags.USE_SHINY_ICONS and species.icon_s != null) else species.icon
	if gender == FEMALE and (species.front_f != null) and (species.back_f != null):
		front = species.front_f if not shiny else species.front_f_s
		back = species.back_f if not shiny else species.back_f_s
		return
	front = species.front if not shiny else species.front_s
	back = species.back if not shiny else species.back_s

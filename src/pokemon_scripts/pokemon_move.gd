class_name PokemonMove extends Resource

## Pokegodot's move resource
## 
## A resource holding information about a pokemon move, including per-instance properties such ass PPs left.

enum Categories { ## Move categories.
	PHYSICAL, ## Does direct damage using the user's attack stat.
	SPECIAL, ## Does direct damage using the user's special attack stat.
	STATUS, ## Does no direct damage, only has a secondary effect.
}
enum Targets { ## The move's possible targets.
	USER, ## Targets the user.
	OTHER, ## Targets one of the other pokemon on the field.
	FOE, ## Targets a foe.
	FOE_SIDE, ## Targets all foes.
	RANDOM_FOE, ## Targets a random foe (Moves like Outrage).
	ALLY, ## Targets an ally only.
	ALLY_SIDE, ## Targets the user and the ally.
	USER_OR_ALLY, ## Targets the user or the ally.
	ALL, ## Targets all pokemon.
	ALL_OTHER, ## Targets all pokemon except the user.
}

## Icons shown in the summary screen for move categories.
const CATEGORY_ICONS: Dictionary[Categories, Texture2D] = {
	Categories.PHYSICAL: preload("res://assets/resources/move_category_textures/physical.tres"),
	Categories.SPECIAL: preload("res://assets/resources/move_category_textures/special.tres"),
	Categories.STATUS: preload("res://assets/resources/move_category_textures/status.tres"),
}


var id: String = "" ## This move's id. Matches it's key in [member DB.moves].
var name: String = "Unnamed" ## This move's name.
var type: int = Types.QMARKS ## This moves type.
var power: int = 0 ## This move's base power.
var accuracy: int = 100 ## This move's accuracy.
var category: Categories = Categories.PHYSICAL ## This move's category.
var total_pp: int = 5 ## This move's base total PP.
var target: Targets = Targets.OTHER ## This move's range.
var priority: int = 0 ## This move's priority.
var effects: Array[BattleEffect] = [] ## This move's secondary effects.
var flags: Array[String] = [] ## This moves flags, such as "Punching" for punching moves boosted by Iron Fist.
var description: String = "???" ## This move's description.
# Properties of a single instance of a move
var pp_upgrades: int = 0 ## The number of PP upgrades given to this move.
var pp: int ## The number of PPs this move has right now.


func _init(_id: String) -> void:
	id = _id

	var data: Dictionary[String, Variant]
	data.assign(DB.moves[id].duplicate(true))

	for effect: Dictionary in data.effects:
		var effect_script: GDScript = BattleEffect.get_effect(effect.script)
		if effect_script:
			var attributes: Dictionary[String, Variant] = {}
			attributes.assign(effect.get("attributes", {}))
			effects.append(effect_script.new(self, effect.get("chance", 100.0), attributes))
	data.erase("effects")
	flags.assign(data.flags)
	data.erase("flags")

	for attribute: String in data:
		if attribute in self:
			set(attribute, data[attribute])
	
	refresh_pp()


## Refreshes this move's PPs, setting [member pp] to [member total_pp] + 20% for every [member pp_upgrades].
func refresh_pp() -> void:
	pp = total_pp + floor(total_pp * 0.2 * pp_upgrades)


## Returns a list that tells whether a pokemon on the field is a valid target. The index matches that of the [BattlePokemon] in [member Battle.pokemons]
func get_possible_targets(battle: Battle, user: BattlePokemon, move_target: Targets = target) -> Array[bool]:
	var targets: Array[bool]
	var user_is_enemy: bool = battle.enemy_pokemon.has(user)
	targets.resize(battle.pokemons.size())
	for i: int in targets.size(): 
		var current: BattlePokemon = battle.pokemons[i]
		match move_target:
			Targets.USER:
				targets[i] = user == current
			Targets.OTHER, Targets.ALL_OTHER:
				targets[i] = user != current
			Targets.FOE, Targets.FOE_SIDE, Targets.RANDOM_FOE:
				if user_is_enemy:
					targets[i] = battle.ally_pokemon.has(current)
				else:
					targets[i] = battle.enemy_pokemon.has(current)
			Targets.ALLY:
				if user_is_enemy:
					targets[i] = battle.enemy_pokemon.has(current) and current != user
				else:
					targets[i] = battle.ally_pokemon.has(current) and current != user
			Targets.ALLY_SIDE, Targets.USER_OR_ALLY:
				if user_is_enemy:
					targets[i] = battle.enemy_pokemon.has(current)
				else:
					targets[i] = battle.ally_pokemon.has(current)
			Targets.ALL:
				targets[i] = true
	return targets


func enable_effects() -> void:
	for effect: BattleEffect in effects:
		effect.enable()


func disable_effects() -> void:
	for effect: BattleEffect in effects:
		effect.disable()

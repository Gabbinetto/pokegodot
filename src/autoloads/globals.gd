extends Node

## Pokegodot's Globals singleton
## 
## A singleton holding general stuff, such as stats key names.

enum Languages { ## Possible languages.
	UNKNOWN,
	JAPANESE,
	ENGLISH,
	FRENCH,
	ITALIAN,
	GERMAN,
	SPANISH,
	KOREAN,
}

const STATS: Dictionary[String, String] = { ## Stat key names following an UPPERCASE_SNAKE_CASE format. Used in properties such as [member PokemonSpecies.base_stats]
	"HP": "HP",
	"ATTACK": "ATTACK",
	"DEFENSE": "DEFENSE",
	"SPECIAL_ATTACK": "SPECIAL_ATTACK",
	"SPECIAL_DEFENSE": "SPECIAL_DEFENSE",
	"SPEED": "SPEED",
}
const CONTEST_STATS: Dictionary[String, String] = { ## Same as [member STATS], but for contest stats.
	"BEAUTY": "BEAUTY",
	"COOL": "COOL",
	"CUTE": "CUTE",
	"SMART": "SMART",
	"TOUGH": "TOUGH",
	"SHEEN": "SHEEN",
}
const CRITICAL_MULTIPLIER: float = 1.5 ## Critical hit multiplier
const MULTIPLE_TARGETS_MULTIPLIER: float = 0.75 ## Multiplier for multiple targets

var game_root: SubViewport ## When meaning to add a node to the root which gets visualized, it's best to add it as a child to this node as to let it scale with the rest of the game.
var rng: RandomNumberGenerator = RandomNumberGenerator.new() ## A global random number generator. Useful to be "coherent" with randomness. Its seed gets also set as the global seed, to make methods such as [method Array.pick_random] coherent.
## Dictionary where the key is the nature name in uppercase and the value is another dictionary the multiplier for each stat [member STATS] (10% increase or decrease).
var natures: Dictionary[String, Dictionary] = {}


func _init() -> void:
	rng.randomize()
	seed(rng.seed)

	for nature: String in DB.natures:
		var stats_multipliers: Dictionary[String, float] = {}
		for stat: String in STATS:
			stats_multipliers[stat] = 1.0
		
		var up_nature: String = DB.natures[nature][0]
		var down_nature: String = DB.natures[nature][1]

		stats_multipliers[up_nature] = 1.1
		stats_multipliers[down_nature] = 0.9 if up_nature != down_nature else 1.0

		natures[nature] = stats_multipliers
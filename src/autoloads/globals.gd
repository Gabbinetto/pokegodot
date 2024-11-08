extends Node

enum Languages {
	UNKNOWN,
	JAPANESE,
	ENGLISH,
	FRENCH,
	ITALIAN,
	GERMAN,
	SPANISH,
	KOREAN,
}

const STATS: Dictionary = {
	"HP": "HP",
	"ATTACK": "ATTACK",
	"DEFENSE": "DEFENSE",
	"SPECIAL_ATTACK": "SPECIAL_ATTACK",
	"SPECIAL_DEFENSE": "SPECIAL_DEFENSE",
	"SPEED": "SPEED",
}
const CONTEST_STATS: Dictionary = {
	"BEAUTY": "BEAUTY",
	"COOL": "COOL",
	"CUTE": "CUTE",
	"SMART": "SMART",
	"TOUGH": "TOUGH",
	"SHEEN": "SHEEN",
}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var natures: Dictionary = {}


func _init() -> void:
	rng.randomize()
	seed(rng.seed)

	for nature: String in DB.natures:
		var stats_multipliers: Dictionary = {}
		for stat: String in STATS:
			stats_multipliers[stat] = 1.0
		
		var up_nature: String = DB.natures[nature][0]
		var down_nature: String = DB.natures[nature][1]

		stats_multipliers[up_nature] = 1.1
		stats_multipliers[down_nature] = 0.9 if up_nature != down_nature else 1.0

		natures[nature] = stats_multipliers
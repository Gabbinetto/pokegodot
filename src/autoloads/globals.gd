extends Node

## Pokegodot's Globals singleton
##
## A singleton holding miscellaneous data that doesn't require a dedicated script, or
## data that should be accessible from everywhere often.

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

const SCREENSHOT_PATH: String = "user://screenshots/" ## Path where screenshots are saved. Screenshots are taken by pressing F9 (Default).

const DAY_NAMES: Dictionary[Time.Weekday, String] = { ## Days of the week
	Time.WEEKDAY_MONDAY: "Monday",
	Time.WEEKDAY_TUESDAY: "Tuesday",
	Time.WEEKDAY_WEDNESDAY: "Wednesday",
	Time.WEEKDAY_THURSDAY: "Thursday",
	Time.WEEKDAY_FRIDAY: "Friday",
	Time.WEEKDAY_SATURDAY: "Saturday",
	Time.WEEKDAY_SUNDAY: "Sunday",
}

const MONTH_NAMES: Dictionary[Time.Month, String] = { ## Months of the year
	Time.MONTH_JANUARY: "January",
	Time.MONTH_FEBRUARY: "February",
	Time.MONTH_MARCH: "March",
	Time.MONTH_APRIL: "April",
	Time.MONTH_MAY: "May",
	Time.MONTH_JUNE: "June",
	Time.MONTH_JULY: "July",
	Time.MONTH_AUGUST: "August",
	Time.MONTH_SEPTEMBER: "September",
	Time.MONTH_OCTOBER: "October",
	Time.MONTH_NOVEMBER: "November",
	Time.MONTH_DECEMBER: "December",
}

## Stat key names following an UPPERCASE_SNAKE_CASE format. Used in properties such as [member PokemonSpecies.base_stats] for consistency.
const STATS: Dictionary[String, String] = {
	"HP": "HP",
	"ATTACK": "ATTACK",
	"DEFENSE": "DEFENSE",
	"SPECIAL_ATTACK": "SPECIAL_ATTACK",
	"SPECIAL_DEFENSE": "SPECIAL_DEFENSE",
	"SPEED": "SPEED",
}
const SHORT_STATS: Dictionary[String, String] = { ## Shortened stats names.
	STATS.ATTACK: "Atk",
	STATS.DEFENSE: "Def",
	STATS.SPECIAL_ATTACK: "Sp.Atk",
	STATS.SPECIAL_DEFENSE: "Sp.Def",
	STATS.SPEED: "Spd",
}
const OTHER_STATS: Dictionary[String, String] = { ## Same as [member STATS], but for other type of stats.
	"ACCURACY": "ACCURACY",
	"EVASIVENESS": "EVASIVENESS",
	"CRITICAL": "CRITICAL",
}
const CONTEST_STATS: Dictionary[String, String] = { ## Same as [member STATS], but for contest stats.
	"BEAUTY": "BEAUTY",
	"COOL": "COOL",
	"CUTE": "CUTE",
	"SMART": "SMART",
	"TOUGH": "TOUGH",
	"SHEEN": "SHEEN",
}
const MAX_BOOST: int = 6 ## Max/min amount of stat boosts in battle.
const MAX_OTHER_BOOST: int = 3 ## Max/min amount of accuracy/evasiveness boosts in battle.
const CRITICAL_MULTIPLIER: float = 1.5 ## Critical hit multiplier
const MULTIPLE_TARGETS_MULTIPLIER: float = 0.75 ## Multiplier for multiple targets
## Defines how rare a shiny is. When defining the shininess, a number between 0 and 65535.
## If this number is less than the threshold, then the pokemon is shiny.[br]
## See: [url]https://bulbapedia.bulbagarden.net/wiki/Personality_value#Shininess[/url] and
## [url]https://bulbapedia.bulbagarden.net/wiki/Shiny_Pok%C3%A9mon#Generation_III_onwards[/url]
const SHINY_THRESHOLD: int = 16

## The viewport used by the game which mantains the aspect ratio while allowing to have nodes in the empty
## space around. When in need for the viewport outside of the viewport itself, use this instead of [method Node.get_viewport]
var game_root: SubViewport
var in_game: bool = false ## Must be true when playing. False when in menus like the main menu, before loading the save file.
var game_world: World ## The game world which holds maps, the player and similar stuff.
var player: Player ## Reference to the [Player] actor. Set by the player itself as there should only be one.
var movement_enabled: bool = true ## Enable or disable the player's movement.
var event_input_enabled: bool = true ## Enable or disable the player's ability to interact with events.
var current_battle: Battle = null ## The battle currently happening. [code]null[/code] if there's no battle.
var in_battle: bool: ## True if a battle is happening. Checks if [member current_battle] is not [code]null[/code]. Can't be set.
	get: return current_battle != null
## A global random number generator. Useful to be "coherent" with randomness.
## Its seed gets also set as the global seed, to make methods such as [method Array.pick_random] coherent.
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Dictionary where the key is the nature name in uppercase and the value is another dictionary the multiplier for each stat [member STATS] (10% increase or decrease).
## Different from [member DB.natures] and should actually be used for nature related calculations.
var natures: Dictionary[String, Dictionary] = {}


func _init() -> void:
	rng.randomize()
	seed(rng.seed)

	# Set nature multipliers
	for nature: String in DB.natures:
		var stats_multipliers: Dictionary[String, float] = {}
		for stat: String in STATS:
			stats_multipliers[stat] = 1.0

		var up_nature: String = DB.natures[nature][0]
		var down_nature: String = DB.natures[nature][1]

		stats_multipliers[up_nature] = 1.1
		stats_multipliers[down_nature] = 0.9 if up_nature != down_nature else 1.0

		natures[nature] = stats_multipliers


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Screenshot"):
		var image: Image = game_root.get_texture().get_image()
		if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(SCREENSHOT_PATH)):
			DirAccess.make_dir_absolute(ProjectSettings.globalize_path(SCREENSHOT_PATH))
		var time: Dictionary = Time.get_datetime_dict_from_system()
		var filename: String = "%04d%02d%02d-%02d%02d%02d.png" % [
			time.year, time.month, time.day, time.hour, time.minute, time.second
		]
		image.save_png(SCREENSHOT_PATH + filename)
		print_rich("[color=#55FF55]Saved screenshot at %s" % filename)

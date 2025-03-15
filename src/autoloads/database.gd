extends Node

## Pokegodot's database
##
## Pokegodots's database, meant to hold various types of data, maily data held in files such as [code]pokemon.json[/code].

const DATA_PATH: String = "res://assets/data/"
const GRAPHICS_PATH: String = "res://assets/graphics/"
const EXTERNAL_GRAPHICS_PATH: String = "user://external_graphics/" # Unused
const EXTERNAL_GRAPHICS_ARCHIVE: String = GRAPHICS_PATH + "external_graphics.zip" # Unused
const POKEMON_GRAPHICS_PACK: String = GRAPHICS_PATH + "pokemon_graphics.pck"
const POKEMON_SPRITES_PATH: String = GRAPHICS_PATH + "pokemon_sprites/"
const POKEMON_FOLLOWERS_PATH: String = GRAPHICS_PATH + "actors/pokemon/"

var default_front_sprite: Texture2D ## Fallback front sprite.
var default_back_sprite: Texture2D ## Fallback back sprite.
var default_icon_sprite: Texture2D ## Fallback icon sprite.

var pokemon: Dictionary[String, Dictionary] ## Holds the data in [code]pokemon.json[/code]
var natures: Dictionary[String, Array] ## Holds the data in [code]natures.json[/code]
var moves: Dictionary[String, Dictionary] ## Holds the data in [code]moves.json[/code]
var types: Dictionary[String, Dictionary] ## Holds the data in [code]types.json[/code]
var metrics: Dictionary[String, Array] ## Holds the data in [code]metrics.json[/code]

var zip_total_files: int = 0 # Unused
var zip_checked_files: int = 0 # Unused

func _init() -> void:
	if not DirAccess.dir_exists_absolute(POKEMON_SPRITES_PATH) or not DirAccess.dir_exists_absolute(POKEMON_FOLLOWERS_PATH):
		# Load the pokemon graphics asset as the files slow down the editor
		if ProjectSettings.load_resource_pack(POKEMON_GRAPHICS_PACK):
			print_debug("Pokemon graphics asset pack loaded.")
		else:
			push_error("Failed loading pokemon graphics asset pack.")

	
	default_front_sprite = Utils.load_or_null(POKEMON_SPRITES_PATH + "_default/front_n_m.png")
	default_back_sprite = Utils.load_or_null(POKEMON_SPRITES_PATH + "_default/back_n_m.png")
	default_icon_sprite = Utils.load_or_null(POKEMON_SPRITES_PATH + "_default/icon_n.png")

	# Load JSON files
	pokemon.assign(JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH + "pokemon.json")))
	natures.assign(JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH + "natures.json")))
	moves.assign(JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH + "moves.json")))
	types.assign(JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH + "types.json")))
	metrics.assign(JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH + "metrics.json")))


## Unused
func load_external_archive() -> void:
	if OS.get_name() == "Android":
		print_debug("Checking Android permissions.")
		if OS.request_permission("android.permission.READ_EXTERNAL_STORAGE"):
			return
		if OS.request_permission("android.permission.WRITE_EXTERNAL_STORAGE"):
			return
		print_debug("Android permissions granted.")

	var dir: DirAccess = DirAccess.open("user://")
	var error: Error = DirAccess.get_open_error()
	if error:
		printerr("Couldn't open %s: %s" % [ProjectSettings.globalize_path("user://"), error_string(error)])
		return
	
	print("Reading zip, ", FileAccess.file_exists(EXTERNAL_GRAPHICS_ARCHIVE))
	var zip: ZIPReader = ZIPReader.new()
	error = zip.open(EXTERNAL_GRAPHICS_ARCHIVE)
	print("Read zip, ", error_string(error))
	if error:
		print_debug("Can't open sprites archive at ", EXTERNAL_GRAPHICS_ARCHIVE)
		get_tree().quit()
		return
	print("Checked error")
	var zip_files: PackedStringArray = zip.get_files()
	print("Got files")
	zip_total_files = zip_files.size()
	zip_checked_files = 0
	for path: String in zip_files:
		# Check if file or dir exists
		if path.ends_with("/"):
			if dir.dir_exists(path):
				zip_checked_files += 1
				continue
		else:
			if dir.file_exists(path):
				zip_checked_files += 1
				continue
		
		dir.make_dir_recursive(path.get_base_dir())
		if path.ends_with("/"):
			zip_checked_files += 1
			continue
		var file: FileAccess = FileAccess.open("user://" + path, FileAccess.WRITE)
		var buffer: PackedByteArray = zip.read_file(path)
		file.store_buffer(buffer)
		file.close()
		zip_checked_files += 1

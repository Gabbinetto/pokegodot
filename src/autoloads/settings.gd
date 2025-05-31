extends Node

enum ScreenSizes {SMALL, MEDIUM, LARGE, EXTRA_LARGE, FULL}

const CONFIG_PATH: String = "user://settings.cfg"
const BOX_TEXTURES_PATH: String = "res://assets/graphics/ui/speech_boxes/hgss/"
const BOX_FORMAT: String = "box%d.png"
const BOX_FULL_FORMAT: String = "box_full%d.png"
const SCREEN_SIZES: Dictionary[ScreenSizes, Vector2i] = {
	ScreenSizes.SMALL: Vector2i(256, 192),
	ScreenSizes.MEDIUM: Vector2i(512, 384),
	ScreenSizes.LARGE: Vector2i(768, 576),
	ScreenSizes.EXTRA_LARGE: Vector2i(1024, 768),
	ScreenSizes.FULL: Vector2i(-1, -1),
}

var text_speed: DialogueManager.Speeds = DialogueManager.Speeds.FAST
var battle_effects: bool = true
var battle_style_switch: bool = true
var default_run: bool = false
var automatic_box: bool = false
var give_nicknames: bool = true
var box_frame: int = _box_frame:
	set(value): _set_box_frame(value)
	get: return _box_frame
var text_entry_keyboard: bool = false

var _box_frame: int = 0
var box_texture: StyleBoxTexture = preload("res://assets/resources/ui/box_texture.tres")
var box_full_texture: StyleBoxTexture = preload("res://assets/resources/ui/box_full_texture.tres")
var box_frame_count: int = 0

func _init() -> void:
	# Count box frames
	while ResourceLoader.exists(BOX_TEXTURES_PATH + BOX_FORMAT % box_frame_count) and ResourceLoader.exists(BOX_TEXTURES_PATH + BOX_FULL_FORMAT % box_frame_count):
		box_frame_count += 1


func _ready() -> void:
	await get_tree().process_frame
	load_settings()



func set_screen_size(size: ScreenSizes) -> void:
	var size_vector: Vector2i = SCREEN_SIZES.get(size)
	if size_vector == SCREEN_SIZES[ScreenSizes.FULL]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	get_window().size = size_vector



func save_settings() -> void:
	var file: ConfigFile = ConfigFile.new()
	if FileAccess.file_exists(CONFIG_PATH):
		file.load(CONFIG_PATH)

	file.set_value("Settings", "text_speed", text_speed)
	file.set_value("Settings", "battle_effects", battle_effects)
	file.set_value("Settings", "battle_style_switch", battle_style_switch)
	file.set_value("Settings", "default_run", default_run)
	file.set_value("Settings", "automatic_box", automatic_box)
	file.set_value("Settings", "give_nicknames", give_nicknames)
	file.set_value("Settings", "box_frame", box_frame)
	file.set_value("Settings", "text_entry_keyboard", text_entry_keyboard)

	file.save(CONFIG_PATH)


func load_settings() -> void:
	var file: ConfigFile = ConfigFile.new()

	var error: int = file.load(CONFIG_PATH)

	if error != OK:
		print_debug("Settings file not found, loaded default settings.")
		return

	for key: String in file.get_section_keys("Settings"):
		set(
			key,
			file.get_value(
				"Settings",
				key,
				get(key)
			)
		)

func _set_box_frame(value: int) -> void:
	value = value % box_frame_count

	_box_frame = value
	var texture: Texture2D = Utils.load_no_error(BOX_TEXTURES_PATH + BOX_FORMAT % box_frame)
	var texture_full: Texture2D = Utils.load_no_error(BOX_TEXTURES_PATH + BOX_FULL_FORMAT % box_frame)

	box_texture.texture = texture
	box_full_texture.texture = texture_full

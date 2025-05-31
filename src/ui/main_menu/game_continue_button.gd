extends TextureButton

const RED_TEXT: LabelSettings = preload("res://assets/resources/ui/text_resources/red.tres")
const BLUE_TEXT: LabelSettings = preload("res://assets/resources/ui/text_resources/blue.tres")

@export var map_name: Label
@export var badges: Label
@export var pokedex: Label
@export var time: Label
@export var player_name: Label


func _ready() -> void:
	if not PlayerData.exists_data():
		return

	var info: Dictionary[String, Variant] = PlayerData.load_save_info()

	pokedex.text = str(info.get("pokedex"))
	map_name.text = info.get("map_name")
	badges.text = str(info.get("badges"))
	var time_played: int = Time.get_datetime_dict_from_unix_time(info.get("time_played")).get("minute", 0)
	time.text = "%dm" % time_played
	player_name.text = info.get("player_name")
	player_name.label_settings = RED_TEXT if info.get("gender") == PlayerData.FEMALE else BLUE_TEXT

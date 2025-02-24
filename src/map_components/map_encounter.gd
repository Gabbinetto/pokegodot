class_name MapEncounter extends Resource


@export var id: String = "BULBASAUR"
@export var form: int = 0
@export_range(1, 100, 1) var min_level: int = 1
@export_range(1, 100, 1) var max_level: int = 1
@export_range(0, 100, 1) var chance: int = 0

class_name HPBar extends TextureProgressBar

@export var high_texture: Texture2D
@export var middle_texture: Texture2D
@export var low_texture: Texture2D

@export var low_threshold: float = 0.2
@export var middle_threshold: float = 0.5


func _ready() -> void:
	value_changed.connect(_on_value_changed)

	_on_value_changed(value)


func _on_value_changed(_new_value: float) -> void:
	if ratio <= low_threshold:
		texture_progress = low_texture
	elif ratio <= middle_threshold:
		texture_progress = middle_texture
	else:
		texture_progress = high_texture

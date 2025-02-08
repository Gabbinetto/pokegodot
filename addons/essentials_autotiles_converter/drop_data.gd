@tool
extends LineEdit

@export var extensions: PackedStringArray

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data.type == "files" and data.files.size() == 1 and extensions.has(data.files[0].get_extension()) 

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var new_text: String = data.files[0]
	if ["res://", "user://"].has(new_text.left(6)):
		new_text = ProjectSettings.globalize_path(new_text)
	text = new_text

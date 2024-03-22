class_name ColoredBar extends ProgressBar

@export var colors: Gradient

var fill: StyleBoxFlat
func _ready() -> void:
	fill = get("theme_override_styles/fill")
	
	var change_color = func(val: int):
		var color = colors.sample((value + min_value) / (max_value + min_value))
		self_modulate = color

	value_changed.connect(change_color)
	value_changed.emit(value)

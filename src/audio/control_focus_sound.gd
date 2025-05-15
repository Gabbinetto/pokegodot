class_name ControlFocusSound extends AudioStreamPlayer


var parent: Control:
	set(value):
		if parent:
			parent.focus_entered.disconnect(play)
		parent = value
		parent.focus_entered.connect(play)


func _ready() -> void:
	parent = get_parent()

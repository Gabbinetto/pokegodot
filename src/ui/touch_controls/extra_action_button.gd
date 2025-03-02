class_name ExtraActionButton extends TouchScreenButton


@export var extra_action: String
var event: InputEventAction

func _ready() -> void:
	event = InputEventAction.new()
	event.action = extra_action
	
	pressed.connect(
		func():
			event.pressed = true
			Input.parse_input_event(event)
	)
	released.connect(
		func():
			event.pressed = false
			Input.parse_input_event(event)
	)

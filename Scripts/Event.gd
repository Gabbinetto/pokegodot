extends Area2D
class_name Event

signal event_finished

@export var activate_when_stepped : = false
@export var activate_when_interacted : = true

var is_running : = false


func _ready() -> void:
	if activate_when_stepped:
		body_entered.connect(_stepped)

func run():
	is_running = true
	_functionality()
	
	await event_finished
	is_running = false

# Always call super() at the end of an event functionality
func _functionality():
	event_finished.emit()

func _stepped(_body : CharacterBody2D):
	run()

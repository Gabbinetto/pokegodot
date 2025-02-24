class_name Dialogue extends Control

## Pokegodot's dialogue UI node
##
## A class that handles the UI side of dialogues, while [DialogueManager] does the actual processing. [br]
## This class is not necessary to use dialogues, but an instance where anything other than the main Dialogue
## is used should be rare. Most of the time, [member Globals.dialogue] should be used.

signal finished

@export var box: Control ## The dialogue box control
@export var label: RichTextLabel ## The dialogue label.
@export var input_arrow: CanvasItem ## Arrows which shows up when input is needed.
@export var choice_box: Control ## The control which holds choices like Yes/No.
@export var choice_container: DialogueChoiceContainer ## The container with functionality to add choices.

var running: DialogueManager ## The [DialogueManager] that is currently being ran.


func _ready() -> void:
	box.gui_input.connect(_on_box_input)


func _process(_delta: float) -> void:
	if not running:
		return
	if running.current_dialogue.get("needs_input") != null:
		input_arrow.visible = running.current_dialogue.needs_input
	else:
		input_arrow.visible = false


## Run a [DialogueManager]
func run_dialogue(manager: DialogueManager) -> void:
	show()
	running = manager
	manager.label = label
	manager.choices = choice_container
	manager.start()
	
	manager.finished.connect(_on_manager_ran, CONNECT_ONE_SHOT)


func _on_manager_ran() -> void:
	if running.hide_box:
		hide()
	running = null
	finished.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not running:
		return
	if event.is_action_pressed("A") or event.is_action_pressed("B"):
		running.input()


func _on_box_input(event: InputEvent) -> void:
	if not running:
		return
	if event is InputEventMouseButton:
		if event.pressed:
			running.input()

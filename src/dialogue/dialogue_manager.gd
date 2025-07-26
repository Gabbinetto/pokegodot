@tool
class_name DialogueManager extends Node

## Pokegodot's dialogue manager
##
## This node is responsible for managing dialogues and relies on [DialogueSequence] resources.


signal finished ## Emitted when the dialogue has finished.

## The various dialogue speeds.
enum Speeds {
	SLOW, ## 7.5 characters shown per second.
	MEDIUM, ## 15 characters shown per second.
	FAST, ## 30 characters shown per second.
	INSTANT, ## Text is shown istantly.
}

## The time needed to show a single character, in seconds. Keys are [enum Speeds] values.
const SECONDS_PER_CHARACTER: Dictionary[Speeds, float] = {
	Speeds.SLOW: 1.0 / 7.5,
	Speeds.MEDIUM: 1.0 / 15.0,
	Speeds.FAST: 1.0 / 30.0,
	Speeds.INSTANT: 0.0,
}

## The first sequence in the dialogue. If not set, it will check the first child. If that child
## is a [DialogueSequence], it will be set as the starting sequence, otherwise an error will be pushed.[br][br]
## [b]NOTE[/b]: It won't throw an error and stop the game execution, it will just push an error with [method @GlobalScope.push_error].
@export var starting_sequence: DialogueSequence
## Whether the dialogue box should be hidden when the dialogue ends.[br][br]
## [b]Warning:[/b] this node doesn't handle hiding the dialogue box. It should be handled by the script running
## the dialogue. This is only useful to tell the running script whether to do it or not.
@export var hide_box: bool = true
@export var disable_movement: bool = true ## Disables player movement while the dialogue is running.
@export var clear_label: bool = true ## Clear label on finish
@export var label: RichTextLabel ## The label where the dialogue is shown.
@export var choices: DialogueChoiceContainer ## The container for choice dialogues like `Yes/No`
var current_dialogue: DialogueSequence ## The dialogue currently being ran.
var running: bool = false ## Is the dialogue is running.


func _ready() -> void:
	finished.connect(_on_finished)
	if not starting_sequence:
		var child: Node = get_child(0)
		if child is DialogueSequence:
			starting_sequence = child
		else:
			push_error("Couln't find a valid DialogueSequence for ", name)



func _process(delta: float) -> void:
	if running:
		current_dialogue.process(delta)


func _on_finished() -> void:
	running = false
	label.visible_characters = -1
	if disable_movement:
		Globals.movement_enabled = get_meta("previous_movement", true)
	Globals.event_input_enabled = get_meta("previous_event_input", true)
	if clear_label:
		label.text = ""


func start() -> void:
	current_dialogue = starting_sequence
	if not current_dialogue:
		push_error("No starting sequence selected for ", name)
		return
	label.text = ""
	if Globals.player and Globals.player.is_moving and Globals.player.is_processing():
		await Globals.player.stopped_moving
	if disable_movement:
		set_meta("previous_movement", Globals.movement_enabled)
		Globals.movement_enabled = false
	set_meta("previous_event_input", Globals.event_input_enabled)
	Globals.event_input_enabled = false
	running = true
	next()


## Advance to the next [DialogueSequence]
func next() -> void:
	current_dialogue.manager = self
	current_dialogue.done = false
	current_dialogue.start()
	await current_dialogue.finished
	var next_dialogue: DialogueSequence = current_dialogue.get_next()
	if next_dialogue:
		current_dialogue = next_dialogue
		next()
	else:
		finished.emit()


## Sends input to the [current_dialogue].
func input() -> void:
	if running:
		current_dialogue.input()

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

@export var speed: Speeds = Speeds.FAST ## The currently set speed.
## Whether the dialogue box should be hidden when the dialogue ends.[br][br]
## [b]Warning:[/b] this node doesn't handle hiding the dialogue box. It should be handled by the script running 
## the dialogue. This is only useful to tell the running script whether to do it or not.
@export var hide_box: bool = true
@export var disable_movement: bool = true ## Disables player movement while the dialogue is running.
@export var clear_label: bool = true ## Clear label on finish
@export var label: RichTextLabel ## The label where the dialogue is shown.
@export var choices: DialogueChoiceContainer ## The container for choice dialogues like `Yes/No`
var dialogues: Array[DialogueSequence] ## The [DialogueSequence]s of the dialogue.
var current_index: int = -1 ## The index of the current [DialogueSequence] shown.
var current_dialogue: DialogueSequence: ## Shorthand to get the current dialogue from [member dialogues] with [member current_index].
	get: return dialogues[current_index]
var running: bool = false ## Is the dialogue is running.


func _ready() -> void:
	finished.connect(_on_finished)
	child_exiting_tree.connect(func(_node: Node): _update_dialogues())
	child_entered_tree.connect(func(_node: Node): _update_dialogues())
	child_order_changed.connect(_update_dialogues)
	_update_dialogues()


func _process(delta: float) -> void:
	if running:
		current_dialogue.process(delta)


func _update_dialogues() -> void:
	dialogues.clear()
	for child: Node in get_children():
		if child is DialogueSequence:
			dialogues.append(child)


func _on_finished() -> void:
	running = false
	label.visible_characters = -1
	if clear_label:
		label.text = ""


## Start the dialogue.
func start() -> void:
	current_index = -1
	label.text = ""
	if Globals.player.is_moving and Globals.player.is_processing():
		await Globals.player.stopped_moving
	if disable_movement:
		Globals.movement_enabled = false
	Globals.event_input_enabled = false
	next()


## Advance to the next [DialogueSequence]
func next() -> void:
	current_index += 1
	if current_index == dialogues.size():
		if disable_movement:
			Globals.movement_enabled = true
		Globals.event_input_enabled = true
		finished.emit()
		return
	current_dialogue.manager = self
	current_dialogue.done = false
	current_dialogue.start()
	if not current_dialogue.finished.is_connected(next):
		current_dialogue.finished.connect(next, CONNECT_ONE_SHOT)
	running = true


## Sends input to the [current_dialogue].
func input() -> void:
	if running:
		current_dialogue.input()

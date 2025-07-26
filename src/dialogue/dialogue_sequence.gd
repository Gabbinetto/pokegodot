@tool
class_name DialogueSequence extends Node

## Pokegodot's dialogue sequence resource
##
## Resource that holds the data regarding a single sequence of a dialogue,
## such as a textbox or a choice. Relies on [DialogueManager].

@warning_ignore("unused_signal")
signal finished ## Emitted when the textbox is finished.

@export var next_sequence: DialogueSequence ## The next sequence in the dialogue. If [code]null[/code], it's the last sequence.
var manager: DialogueManager ## The manager which runs this.
var done: bool = false ## If the sequence is done.


## Start the sequence.
func start() -> void:
	pass


## Process the sequence. Ran by [manager] on every frame call.
func process(_delta: float) -> void:
	pass


## Runs when input is received, such as pressing A or pressing on the screen. Received by [manager].
func input() -> void:
	pass


## Returns the next sequence in the dialogue. By default it's [member next_sequence]
func get_next() -> DialogueSequence:
	return next_sequence

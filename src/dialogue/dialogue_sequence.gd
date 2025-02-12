@tool
class_name DialogueSequence extends Node

## Pokegodot's dialogue sequence resource
##
## Resource that holds the data regarding a single sequence of a dialogue,
## such as a textbox or a choice. Relies on [DialogueManager].

signal finished ## Emitted when the textbox is finished.

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

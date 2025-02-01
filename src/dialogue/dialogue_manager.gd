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
@export var label: RichTextLabel ## The label where the dialogue is show.
var dialogues: Array[DialogueSequence]: ## The [DialogueSequence]s of the dialogue.
    get:
        var arr: Array[DialogueSequence] = []
        for child: Node in get_children():
            if child is DialogueSequence:
                arr.append(child)
        return arr


var current_index: int = -1 ## The index of the current [DialogueSequence] shown.
var current_dialogue: DialogueSequence: ## Shorthand to get the current dialogue from [member dialogues] with [member current_index].
    get: return dialogues[current_index]
var running: bool = false ## Is the dialogue is running.


func _ready() -> void:
    finished.connect(_on_finished)


func _process(delta: float) -> void:
    if running:
        current_dialogue.process(delta)


func _on_finished() -> void:
    running = false
    label.visible_characters = -1


## Start the dialogue.
func start() -> void:
    current_index = -1
    label.visible_characters = 0
    next()


## Advance to the next [DialogueSequence]
func next() -> void:
    current_index += 1
    if current_index == dialogues.size():
        finished.emit()
        return
    current_dialogue.manager = self
    current_dialogue.done = false
    current_dialogue.parse_text()
    if not current_dialogue.finished.is_connected(next):
        current_dialogue.finished.connect(next)
    running = true


func input() -> void:
    current_dialogue.input()
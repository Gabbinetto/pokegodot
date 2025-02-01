@tool
class_name DialogueSequence extends Node

## Pokegodot's dialogue sequence resource
##
## Resource that holds the data regarding a single textbox of dialogue. Relies on [DialogueManager].

signal pause_done ## Emitted when a pause is done.
signal finished ## Emitted when the textbox is finished.


@export_multiline var text: String ## The text in the textbox.
## The moments in which the textbox pauses.
@export var set_pauses: Dictionary[int, float] = {}
var pauses: Dictionary[int, float] = {}
var parsed_text: String
var target_characters: int = 0
var done: bool = false
var time_elapsed: float = 0.0
var pause_time_elapsed: float = 0.0
var current_pause_index: int = -1
var manager: DialogueManager
var visible_characters: int:
    get: return manager.label.visible_characters
    set(value): manager.label.visible_characters = value
var needs_input: bool:
    get:
        print(current_pause_index)
        return visible_characters == pauses.keys()[current_pause_index] and pauses[visible_characters] < 0

func process(delta: float) -> void:
    if done:
        return

    if time_elapsed >= DialogueManager.SECONDS_PER_CHARACTER.get(manager.speed):
        if manager.speed == DialogueManager.Speeds.INSTANT:
            visible_characters = target_characters
        visible_characters = int(move_toward(visible_characters, target_characters, 1))
        time_elapsed = 0.0

    if visible_characters == pauses.keys()[current_pause_index]:
        if pause_time_elapsed >= pauses[visible_characters] and pauses[visible_characters] >= 0:
            advance_pause()
        pause_time_elapsed += delta

    time_elapsed += delta


func parse_text() -> void:
    pauses = set_pauses.duplicate()

    parsed_text = text

    manager.label.text = parsed_text
    current_pause_index = -1
    pauses[parsed_text.length()] = 0.0
    advance_pause()


func advance_pause() -> void:
    if current_pause_index + 1 == pauses.size():
    # if visible_characters == text.length():
        done = true
        finished.emit()
        return
    current_pause_index += 1
    target_characters = pauses.keys()[current_pause_index]
    pause_time_elapsed = 0.0
    pause_done.emit()


func input() -> void:
    if visible_characters == pauses.keys()[current_pause_index]:
        advance_pause()
    else:
        visible_characters = pauses.keys()[current_pause_index]
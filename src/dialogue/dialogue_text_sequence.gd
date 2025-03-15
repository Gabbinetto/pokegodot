@tool
class_name DialogueTextSequence extends DialogueSequence

## Text [DialogueSequence]
##
## Resource that holds the data regarding a single textbox of dialogue. Relies on [DialogueManager].

signal pause_done ## Emitted when a pause is done.

@export_multiline var text: String ## The text in the textbox.
## If true, an input will be needed to advance the sequence in the end.
@export var needs_input_on_finish: bool = true
## The moments in which the textbox pauses. Keys represent the amount of characters shown 
## when the text pauses. Negative pause times mean that an input is needed.
@export var set_pauses: Dictionary[int, float] = {}
# TODO: Fix it EditorInterface not being defined in builds
#@export_tool_button("Show text length") var show_text_length: Callable = func():
	#if OS.has_feature("editor"):
		#EditorInterface.get_editor_toaster().push_toast(str(text.length()))
var pauses: Dictionary[int, float] = {}
var parsed_text: String
var target_characters: int = 0
var time_elapsed: float = 0.0
var pause_time_elapsed: float = 0.0
var current_pause_index: int = -1
var visible_characters: int:
	get: return manager.label.visible_characters if manager and manager.label else -1
	set(value):
		if manager and manager.label:
			manager.label.visible_characters = value
var needs_input: bool:
	get:
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

## Start the sequence.
func start() -> void:
	pauses = set_pauses.duplicate()

	parsed_text = text

	if needs_input_on_finish:
		pauses[-1] = -1

	# Count negative keys from the end
	for pause_key: int in pauses.keys().filter(func(key: int): return key < 0):
		pauses[parsed_text.length() + 1 - pause_key] = pauses[pause_key]
		pauses.erase(pause_key)

	manager.label.text = parsed_text
	visible_characters = 0
	current_pause_index = -1
	pauses[parsed_text.length()] = 0.0
	advance_pause()

## Advance to the next pause.
func advance_pause() -> void:
	if current_pause_index + 1 == pauses.size():
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

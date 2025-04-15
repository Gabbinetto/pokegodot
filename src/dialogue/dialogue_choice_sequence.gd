@tool
class_name DialogueChoiceSequence extends DialogueSequence

## Choice [DialogueSequence]
##
## Resource that shows a choice to the player during a dialogue. Relies on [DialogueManager].

signal choice_taken(index: int) ## Emitted when a choice is taken.

@export var choices: Array[String] ## The choices shown to the player.
## The next sequence based on the choice taken. The index must match the choice index in [member choices].
## If this is empty, [member next_sequence] won't be affected and will work normally like in any [DialogueSequence].
## If this isn't empty, [member next_sequence] will be set to the sequence at the taken index before emitting [signal DialogueSequence.finished].
@export var next_sequences: Array[DialogueSequence]


## Start the sequence.
func start() -> void:
	manager.choices.set_choices(choices)
	for choice: Button in manager.choices.get_children():
		choice.pressed.connect(_on_choice_taken.bind(choice.get_index()), CONNECT_ONE_SHOT)
	manager.choices.get_parent().show()
	manager.choices.get_child(0).grab_focus.call_deferred()


func _on_choice_taken(index: int) -> void:
	if next_sequences.size() > 0:
		next_sequence = next_sequences[index]
	manager.choices.get_parent().hide()
	choice_taken.emit(index)
	done = true
	finished.emit()

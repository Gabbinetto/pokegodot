@tool
class_name DialogueChoiceSequence extends DialogueSequence

## Choice [DialogueSequence]
##
## Resource that shows a choice to the player during a dialogue. Relies on [DialogueManager].

signal choice_taken(index: int) ## Emitted when a choice is taken.

@export var choices: Array[String] ## The choices shown to the player.


## Start the sequence.
func start() -> void:
	manager.choices.set_choices(choices)
	for choice: Button in manager.choices.get_children():
		choice.pressed.connect(_on_choice_taken.bind(choice.get_index()), CONNECT_ONE_SHOT)
	manager.choices.get_parent().show()
	manager.choices.get_child(0).grab_focus.call_deferred() # TODO: Fix focus not getting grabbed on second activation

func _on_choice_taken(index: int) -> void:
	manager.choices.get_parent().hide()
	choice_taken.emit(index)
	done = true
	finished.emit()

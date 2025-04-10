@tool
class_name DialogueEvent extends Event


@export var dialogue: DialogueManager


func _run() -> void:
	MainDialogue.run_dialogue(dialogue)
	MainDialogue.finished.connect(done.emit, CONNECT_ONE_SHOT)

class_name DialogueEvent extends Event


@export var dialogue: DialogueManager


func _run() -> void:
	super()
	Globals.dialogue.run_dialogue(dialogue)
	Globals.dialogue.finished.connect(done.emit, CONNECT_ONE_SHOT)

class_name DialogueEvent extends Event


@export var dialogue: DialogueManager


func run() -> void:
	Globals.dialogue.run_dialogue(dialogue)

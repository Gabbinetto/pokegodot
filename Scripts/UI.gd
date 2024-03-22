extends CanvasLayer

@onready var dialogue_text: Label = %DialogueText

func _ready() -> void:
	dialogue_text.text = ""

func show_text(text: String) -> void:
	dialogue_text.text = text

@tool
extends MarginContainer


@onready var edit: TextEdit = %DialogueEdit
@onready var run_button: Button = %RunButton
@onready var labels: Array[RichTextLabel] = [
	%DialogueLabel
]
@onready var dialogue_boxes: Array[NinePatchRect] = [
	%DialogueBox
]
@onready var dialogue_arrow: AnimatedSprite2D = %DialogueArrow
@onready var dialogue_manager: DialogueManager = %DialogueManager
@onready var speed_button: MenuButton = %SpeedButton
@onready var speed_popup: PopupMenu = speed_button.get_popup()
@onready var pauses_text: TextEdit = %PausesText
@onready var pauses_button: Button = %PausesButton


func _ready() -> void:

	for label: RichTextLabel in labels:
		edit.text_changed.connect(func():
			label.text = edit.text
			dialogue_manager.dialogues.front().text = label.text
		)

	run_button.pressed.connect(func(): dialogue_manager.start())

	speed_popup.index_pressed.connect(_on_index_pressed)

	pauses_button.pressed.connect(
		func():
			var pauses: Array = Array(pauses_text.text.split("\n")).map(
				func(item: String):
					return item.split(":")
			)
			dialogue_manager.dialogues.front().set_pauses.clear()
			for pause: PackedStringArray in pauses:
				dialogue_manager.dialogues.front().set_pauses[int(pause[0])] = float(pause[1])
	)

	for box: NinePatchRect in dialogue_boxes:
		box.gui_input.connect(
			func(event: InputEvent):
				if event.as_text() == "Left Mouse Button":
					dialogue_manager.input()
		)
	
	dialogue_manager.finished.connect(print.bind("Dialogue finished"))


func _process(_delta: float) -> void:
	dialogue_arrow.visible = dialogue_manager.running and dialogue_manager.current_dialogue.needs_input

	
func _on_index_pressed(idx: int) -> void:
	dialogue_manager.speed = DialogueManager.Speeds.values()[idx]
	speed_button.text = DialogueManager.Speeds.keys()[idx]
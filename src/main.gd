extends Control


@export var viewport: SubViewport
@export var main_dialogue: Dialogue
@export var touchscreen_controls: CanvasItem
@export var controls_visibility_button: BaseButton


func _ready() -> void:
	Globals.game_root = viewport
	Globals.dialogue = main_dialogue
	controls_visibility_button.pressed.connect(func(): touchscreen_controls.visible = not touchscreen_controls.visible)

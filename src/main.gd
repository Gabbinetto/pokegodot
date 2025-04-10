extends Control


@export var viewport: SubViewport
@export var main_dialogue: Dialogue
@export var touchscreen_controls: CanvasItem
@export var controls_visibility_button: BaseButton
@export_group("Autoload reparenting")
@export var hud_layer: CanvasLayer
@export var main_dialogue_layer: CanvasLayer


func _ready() -> void:
	Globals.game_root = viewport
	controls_visibility_button.pressed.connect(func(): touchscreen_controls.visible = not touchscreen_controls.visible)

	# Add certain autoloads to the SubViewport
	await get_tree().process_frame
	MainDialogue.reparent(main_dialogue_layer)
	MainDialogue.hide()
	HUD.reparent(hud_layer)
	HUD.hide()
	TransitionManager.reparent(viewport)
	viewport.move_child(TransitionManager, main_dialogue_layer.get_index()) # Dialogues should appear above

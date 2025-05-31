class_name TextInputButton extends Label


signal pressed(character: String)

const FOCUS_TEXTURE_OFFSET: Vector2 = Vector2(1, 2)

@export var focus_texture: Texture2D
@export var action_mode: BaseButton.ActionMode = BaseButton.ACTION_MODE_BUTTON_PRESS


func _ready() -> void:
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)

	grab_focus.call_deferred()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if action_mode == BaseButton.ACTION_MODE_BUTTON_PRESS and event.is_pressed():
			pressed.emit(text.substr(0, 1))
		elif action_mode == BaseButton.ACTION_MODE_BUTTON_RELEASE and event.is_released():
			pressed.emit(text.substr(0, 1))
	elif action_mode == BaseButton.ACTION_MODE_BUTTON_PRESS and event.is_action_pressed("ui_accept"):
		pressed.emit(text.substr(0, 1))
	elif action_mode == BaseButton.ACTION_MODE_BUTTON_RELEASE and event.is_action_released("ui_accept"):
		pressed.emit(text.substr(0, 1))


func _draw() -> void:
	if not has_focus():
		return

	draw_texture(
		focus_texture,
		FOCUS_TEXTURE_OFFSET,
	)

class_name TextInputField extends HBoxContainer


const CHARACTER_SCENE: PackedScene = preload("res://src/ui/text_input/text_input_field_character.tscn")
const UNDERLINE_Y: int = 26
const UNDERLINE_OFFSET: int = 4

@export var length: int = 10:
	set(value):
		length = max(0, value)
		_refresh()
@export var focus_style: StyleBox


var text: String:
	set(value):
		set_text(value)
	get:
		return _text

var selected: int = 0:
	set(value):
		if value > text.length():
			value = text.length()
		selected = clampi(value, 0, length - 1)
		for i: int in get_child_count():
			if i == selected:
				get_child(i).get_child(0).position.y = UNDERLINE_Y + UNDERLINE_OFFSET
			else:
				get_child(i).get_child(0).position.y = UNDERLINE_Y



var _text: String:
	set(value):
		_text = value.substr(0, length)
		_refresh_text()


func _ready() -> void:
	_refresh()
	set_deferred("selected", 0)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if not focus_style or not has_focus():
		return
	focus_style.draw(
		get_canvas_item(), Rect2(Vector2.ZERO, size)
	)



func _refresh() -> void:
	if length > get_child_count():
		for i: int in max(length - get_child_count(), 0):
			var new: Label = CHARACTER_SCENE.instantiate()
			add_child(new)
	elif length < get_child_count():
		for i: int in range(1, get_child_count() - length + 1):
			get_child(-i).queue_free()

	for child: Control in get_children():
		child.show_behind_parent = true

	_connect()


func _refresh_text() -> void:
	for i: int in length:
		get_child(i).text = _text[i] if i < _text.length() else ""



func _connect() -> void:
	for node: Label in get_children():
		if not node.gui_input.is_connected(_on_character_input):
			node.gui_input.connect(_on_character_input.bind(node.get_index()))


func _on_character_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			selected = index


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		selected += 1
	elif event.is_action_pressed("ui_left"):
		selected -= 1
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_BACKSPACE:
			remove_character()
			return

		var input_char: String = char(event.unicode)
		if input_char.length() > 1 or input_char.is_empty():
			return
		add_character(input_char)

func set_character(character: String, index: int) -> void:
	if index < 0:
		index = length - index
	if character.is_empty():
		_text = "%s%s" % [_text.left(index), _text.substr(index + 1)]
		return
	_text = "%s%s%s" % [
		_text.left(index), character[0], _text.substr(index + 1)
	]


func set_text(new_text: String) -> void:
	for i: int in new_text.length():
		set_character(new_text[i], i)
	if new_text.length() > get_child_count():
		for i: int in range(1, get_child_count() - new_text.length() + 1):
			get_child(-i).text = ""


func add_character(character: String) -> void:
	set_character(character, selected)
	selected += 1

func remove_character() -> void:
	set_character(
		"",
		selected if selected < _text.length() else max(0, selected - 1)
	)
	selected -= 1

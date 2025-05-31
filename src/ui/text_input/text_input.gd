class_name TextInput extends Control

signal submitted(text: String)

const MENU_SCENE: PackedScene = preload("res://src/ui/text_input/text_input.tscn")
const TAB_SWITCH_TIME: float = 0.5

@export var tabs: Array[InputButtonGrid]
@export var tab_buttons: Control
@export var tab_overlays: Array[TextureRect]
@export var tab_textures: Array[Texture2D]
@export var field: TextInputField
@export var ok_button: BaseButton
@export var back_button: BaseButton
@export var label: Label

var _base_tab_pos: Vector2
var _current_tab: InputButtonGrid

func _ready() -> void:
	for tab: InputButtonGrid in tabs:
		for button: TextInputButton in tab.get_children():
			button.pressed.connect(field.add_character)
			button.gui_input.connect(_on_button_gui_input)

	for node: Control in tab_buttons.get_children() + [ok_button, back_button]:
		node.focus_entered.connect(
			field.set.bind("focus_neighbor_bottom", node.get_path())
		)

	var button_group: ButtonGroup = ButtonGroup.new()
	for button: BaseButton in tab_buttons.get_children():
		button.button_group = button_group
		button.pressed.connect(_change_to_tab.bind(button.get_index()))


	back_button.pressed.connect(field.remove_character)
	ok_button.pressed.connect(
		func():
			submitted.emit(field.text)
	)

	for i: int in tabs.size():
		if i > 0:
			tabs[i].get_parent().remove_child(tabs[i])

	_base_tab_pos = tab_overlays[0].position
	_current_tab = tabs[0]

	tab_buttons.get_child(0).button_pressed = true

	field.grab_focus.call_deferred()




func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if not ok_button.has_focus():
			ok_button.grab_focus.call_deferred()


func _on_button_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		field.remove_character()



func _change_to_tab(index: int) -> void:
	if index >= tabs.size():
		return

	var tab: InputButtonGrid = tabs[index]
	if tab == _current_tab:
		return

	for node: BaseButton in tab_buttons.get_children() + [back_button, ok_button]:
		node.disabled = true

	var old: TextureRect = tab_overlays[0]
	var new: TextureRect = tab_overlays[-1]

	tab_overlays.append(tab_overlays.pop_front())

	new.add_child(tab)

	var tween: Tween = create_tween()

	tween.tween_property(old, "position:y", size.y, TAB_SWITCH_TIME)
	tween.parallel().tween_property(new, "position:x", _base_tab_pos.x, TAB_SWITCH_TIME)
	tween.tween_callback(old.remove_child.bind(tab))
	tween.tween_callback(old.set.bind("position", Vector2(-old.size.x, _base_tab_pos.y)))
	for node: BaseButton in tab_buttons.get_children() + [back_button, ok_button]:
		tween.tween_callback(node.set.bind("disabled", false))
	tween.tween_callback(set.bind("_current_tab", tab))


static func create(attributes: Dictionary[String, Variant] = {}) -> TextInput:
	var menu: TextInput = MENU_SCENE.instantiate()
	menu.label.text = attributes.get("label", "")
	menu.field.length = attributes.get("length", 10)
	menu.field.set_deferred("text", attributes.get("text", ""))

	return menu

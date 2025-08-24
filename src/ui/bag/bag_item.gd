class_name BagItem extends Control

signal pressed

@export var item: Item:
	set(value):
		item = value
		refresh()
@export var is_close_button: bool = false
@export var name_label: Label
@export var amount_label: Label


func refresh() -> void:
	if is_close_button:
		name_label.text = "CLOSE BAG"
		amount_label.hide()
		return

	if not item:
		return
	
	name_label.text = item.name
	amount_label.text = "x %d" % Bag.get_amount(item.id)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if Rect2(global_position, size).has_point(event.global_position):
				pressed.emit()

	if event.is_action("ui_accept"):
		pressed.emit()
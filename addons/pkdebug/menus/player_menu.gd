@tool
extends Control

const PKDebug: GDScript = preload("res://addons/pkdebug/pkdebug.gd")

@export var fill_bag: BaseButton

var plugin: PKDebug


func setup(parent_plugin: PKDebug) -> void:
	plugin = parent_plugin

	fill_bag.pressed.connect(_on_fill_bag)


func _on_fill_bag() -> void:
	var dialog: AcceptDialog = AcceptDialog.new()
	dialog.min_size.x = 335
	dialog.title = "How much of each item?"
	var spinbox: SpinBox = SpinBox.new()
	spinbox.min_value = 1
	spinbox.max_value = 999
	spinbox.value = 100
	dialog.get_label().add_sibling(spinbox)

	dialog.confirmed.connect(
		func():
			plugin.send_message("fill_bag", [spinbox.value])
	)

	EditorInterface.popup_dialog_centered(dialog)
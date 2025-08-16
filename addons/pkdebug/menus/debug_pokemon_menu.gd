@tool
extends Control

const PKDebug: GDScript = preload("res://addons/pkdebug/pkdebug.gd")

@export var editor: Control
@export var slot_buttons: Control
@export var heal_team: BaseButton

var plugin: PKDebug


func setup(parent_plugin: PKDebug) -> void:
	plugin = parent_plugin
	editor.setup(parent_plugin)

	for button: BaseButton in slot_buttons.get_children():
		button.pressed.connect(_on_slot_pressed.bind(button.get_index()))

	heal_team.pressed.connect(plugin.send_message.bind("heal_team"))

func _on_slot_pressed(slot: int) -> void:
	var pokemon: Dictionary[String, Variant] = await plugin.get_pokemon(slot)
	if pokemon.is_empty():
		EditorInterface.get_editor_toaster().push_toast("No pokemon is present in slot %d." % slot)
		editor.hide()
		return
	
	editor.set_pokemon(slot, pokemon)
	editor.show()
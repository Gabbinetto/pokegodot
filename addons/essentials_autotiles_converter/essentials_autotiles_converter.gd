@tool
extends EditorPlugin

const Extractor: PackedScene = preload("res://addons/essentials_autotiles_converter/extractor.tscn")

var extractor: Control


func _enter_tree() -> void:
	extractor = Extractor.instantiate()
	extractor.visible = false
	EditorInterface.get_editor_main_screen().add_child(extractor)


func _exit_tree() -> void:
	if extractor:
		extractor.queue_free()


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon("Control", "EditorIcons")


func _get_plugin_name() -> String:
	return "Autotile Extractor"


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if extractor:
		extractor.visible = visible

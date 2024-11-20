@tool
extends EditorPlugin

const TestingTab: PackedScene = preload("test_tab/test_dialogue.tscn")

var test_dialogue: Control

func _enter_tree() -> void:

	test_dialogue = TestingTab.instantiate()
	test_dialogue.visible = false
	EditorInterface.get_editor_main_screen().add_child(test_dialogue)


func _exit_tree() -> void:

	if test_dialogue:
		test_dialogue.queue_free()


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon("Control", "EditorIcons")


func _get_plugin_name() -> String:
	return "Dialogue Test"


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if test_dialogue:
		test_dialogue.visible = visible

@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("ExpandableViewportContainer", "SubViewportContainer", preload("expand_viewport_container.gd"), EditorInterface.get_base_control().get_theme_icon("SubViewportContainer", "EditorIcons"))


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("ExpandableViewportContainer")
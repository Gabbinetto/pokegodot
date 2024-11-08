@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("ExpandableViewportContainer", "SubViewportContainer", preload("expand_viewport_container.gd"), ThemeDB.get_default_theme().get_icon("SubViewportContainer", "Normal"))


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("ExpandableViewportContainer")
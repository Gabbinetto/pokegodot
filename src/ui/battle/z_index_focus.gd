class_name ZIndexFocus extends Node


func _ready() -> void:
    var parent: Control = get_parent()
    
    parent.focus_entered.connect(func(): parent.z_index += 1)
    parent.focus_exited.connect(func(): parent.z_index -= 1)

class_name DialogueChoiceContainer extends Container

## A container made for choices in dialogues


@export var choice_button: PackedScene ## The button added when a choice is added.


func _set_focus_neighbors() -> void:
	for i: int in get_child_count():
		var button: Button = get_child(i)
		if i > 0:
			var prev: NodePath = get_child(i - 1).get_path()
			button.focus_neighbor_left = prev
			button.focus_neighbor_top = prev
			button.focus_previous = prev
		if i < get_child_count() - 1:
			var next: NodePath = get_child(i + 1).get_path()
			button.focus_neighbor_right = next
			button.focus_neighbor_bottom = next
			button.focus_next = next


## Adds a choice by instantiating a [member choice_button].
func add_choice(text: String) -> Button:
	var button: Button = choice_button.instantiate()
	button.text = text
	add_child(button)
	_set_focus_neighbors()
	return button


## Sets multiple choices. Removes old choices.
func set_choices(choices: Array[String]) -> void:
	for child: Node in get_children():
		child.queue_free()
	for choice: String in choices:
		add_choice(choice)

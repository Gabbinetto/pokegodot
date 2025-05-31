class_name InputButtonGrid extends GridContainer


const INPUT_BUTTON: PackedScene = preload("res://src/ui/text_input/text_input_button.tscn")


@export_multiline var charset: String
var buttons: Array[Array] = []


func _ready() -> void:
	charset = charset.replace("\n", "")

	generate()


func generate() -> void:
	buttons.clear()
	for i in columns:
		buttons.append([] as Array[TextInputButton])


	for child: Node in get_children():
		child.queue_free()

	for character: String in charset:
		var button: TextInputButton = INPUT_BUTTON.instantiate()
		button.name = character
		add_child(button)
		button.text = character

		var index: int = button.get_index()
		buttons[index % columns].append(button)

	for x: int in buttons.size():
		for y: int in buttons[x].size():
			var button: TextInputButton = buttons[x][y]

			button.focus_neighbor_right = buttons[mini(x + 1, buttons.size() - 1)][y].get_path()
			button.focus_neighbor_left = buttons[maxi(x - 1, 0)][y].get_path()
			button.focus_neighbor_bottom = buttons[x][min(y + 1, buttons[x].size() - 1)].get_path()
			if y > 0:
				button.focus_neighbor_top = buttons[x][y - 1].get_path()

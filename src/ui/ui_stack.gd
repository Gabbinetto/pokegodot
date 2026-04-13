extends CanvasLayer

var stack: Array[UIStackElement] = []

func push(control: UIStackElement) -> void:
	stack.push_back(control)
	add_child(control)

func pop() -> UIStackElement:
	var control: UIStackElement = stack.pop_back()
	remove_child(control)
	return control

func top() -> UIStackElement:
	return stack[stack.size() - 1]

func is_empty() -> bool:
	return stack.is_empty()

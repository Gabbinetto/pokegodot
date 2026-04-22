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
	if stack.is_empty():
		return null
	return stack.back()

func is_empty() -> bool:
	return stack.is_empty()

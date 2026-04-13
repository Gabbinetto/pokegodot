@abstract
class_name UIStackElement extends Control

signal data_sent(data: Variant)
signal closed

func close() -> void:
	UIStack.pop()
	data_sent.emit(null)
	closed.emit()

static func build(_options: Dictionary[String, Variant] = {}) -> UIStackElement:
	return null

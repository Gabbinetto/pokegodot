class_name Utils extends Object


static func load_no_error(path: String) -> Variant:
	if ResourceLoader.exists(path):
		return load(path)
	return


class SignalPool extends RefCounted:
	signal all
	signal any

	var _signals: Dictionary[Signal, bool] = {}

	func register_signal(new_signal: Signal):
		_signals[new_signal] = false
		new_signal.connect(
			func(..._vars: Array):
				on_signal(new_signal)
		)

	func on_signal(emitted: Signal) -> void:
		_signals[emitted] = true
		any.emit()
		if _signals.values().all(func(val: bool): return val):
			all.emit()

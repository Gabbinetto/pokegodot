@tool
extends EditorPlugin

signal connected
signal disconnected

var debugger: Debugger
var menu: Control
var is_connected: bool = false


func _enter_tree() -> void:
	debugger = Debugger.new()
	debugger.connected.connect(
		func():
			is_connected = true
			connected.emit()
	)
	debugger.disconnected.connect(
		func():
			is_connected = false
			disconnected.emit()
	)

	menu = preload("res://addons/pkdebug/debug_menu.tscn").instantiate()

	add_debugger_plugin(debugger)
	add_autoload_singleton("PKDebugAutoload", "res://addons/pkdebug/pkdebug_autoload.gd")
	EditorInterface.get_editor_main_screen().add_child(menu)

	menu.hide()
	menu.setup(self)


func _exit_tree() -> void:
	if debugger:
		remove_debugger_plugin(debugger)
	if menu:
		menu.queue_free()
	remove_autoload_singleton("PKDebugAutoload")


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if menu:
		menu.visible = visible


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Edit", "EditorIcons")


func _get_plugin_name() -> String:
	return "PK Debug"


func send_message(message: String, data: Array = []) -> void:
	if not debugger.last_session:
		return
	debugger.last_session.send_message("pkdebug:" + message, data)


func get_pokemon(slot: int) -> Dictionary[String, Variant]:
	send_message("get_pokemon", [slot])
	await debugger.data_requested
	if debugger.buffer.is_empty():
		return {}
	var pokemon: Dictionary[String, Variant] = debugger.buffer[0]

	return pokemon


func request_stats(id: String, base_stat: Dictionary, ivs: Dictionary, evs: Dictionary, level: int, nature: String) -> Dictionary[String, int]:
	var stats: Dictionary[String, int]
	send_message("calculate_stats", [id, base_stat, ivs, evs, level, nature])
	await debugger.data_requested
	stats.assign(debugger.buffer[0])
	return stats


func request_level(experience: int, growth_rate: int) -> int:
	send_message("calculate_level", [experience, growth_rate])
	await debugger.data_requested
	return debugger.buffer[0]


func request_exp(level: int, growth_rate: int) -> int:
	send_message("calculate_exp", [level, growth_rate])
	await debugger.data_requested
	return debugger.buffer[0]


func request_max_exp() -> Dictionary[int, int]:
	var data: Dictionary[int, int]
	send_message("get_max_exp")
	await debugger.data_requested
	# Don't know why it says "Error: can't assign to Dictionary[String, int]"
	for i: int in debugger.buffer[0]:
		data[i] = debugger.buffer[0][i]
	return data


static func decode_texture(size: Vector2i, buffer: PackedByteArray) -> Texture2D:
	var image: Image = Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.load_png_from_buffer(buffer)
	return ImageTexture.create_from_image(image)


class Debugger extends EditorDebuggerPlugin:
	signal data_requested
	signal connected
	signal disconnected
	signal battle_started
	signal battle_update(pokemon: Array[Dictionary])
	signal battle_ended

	
	var last_session: EditorDebuggerSession
	var buffer: Array

	func _has_capture(capture: String) -> bool:
		return capture == "pkdebug"

	func _setup_session(session_id: int) -> void:
		prints("PK Debug: Setup session", session_id)

		var session: EditorDebuggerSession = get_session(session_id)
		session.started.connect(
			func():
				print("PK Debug: Session started")
				last_session = session
				connected.emit()
		)
		session.stopped.connect(
			func():
				print("PK Debug: Session stopped")
				disconnected.emit()
		)

	func _capture(message: String, data: Array, session_id: int) -> bool:
		var session: EditorDebuggerSession = get_session(session_id)
		buffer.clear()

		if message == "pkdebug:data_send":
			buffer = data
			data_requested.emit()
			return true
		elif message == "pkdebug:toast":
			EditorInterface.get_editor_toaster().push_toast(data[0], data[1])
			return true
		elif message == "pkdebug:battle_started":
			battle_started.emit()
			return true
		elif message == "pkdebug:battle_update":
			battle_update.emit(data)
			return true
		elif message == "pkdebug:battle_ended":
			battle_ended.emit()
			return true
		
		return false
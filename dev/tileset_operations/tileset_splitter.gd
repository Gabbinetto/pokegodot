@tool
extends EditorScript

var file_dialog: EditorFileDialog
var main_screen: VBoxContainer
var tile_size: int = 32
var split_amount: int = 2


func _run() -> void:
	main_screen = get_editor_interface().get_editor_main_screen()
	var popup: ConfirmationDialog = ConfirmationDialog.new()
	var hbox: HBoxContainer = HBoxContainer.new()
	var tile_size_input: SpinBox = SpinBox.new()
	tile_size_input.prefix = "Tile size: "
	tile_size_input.suffix = "px"
	tile_size_input.min_value = 1
	tile_size_input.allow_greater = true
	tile_size_input.value = tile_size
	tile_size_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var split_amount_input: SpinBox = SpinBox.new()
	split_amount_input.prefix = "Split into: "
	split_amount_input.min_value = 2
	split_amount_input.allow_greater = true
	split_amount_input.value = split_amount
	split_amount_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(tile_size_input)
	hbox.add_child(split_amount_input)
	popup.add_child(hbox)
	main_screen.add_child(popup)
	popup.set_meta("_created_by", self)
	popup.popup_centered(Vector2(400, 0))
	popup.grab_focus.call_deferred()
	popup.confirmed.connect(
		func():
			tile_size = tile_size_input.value
			split_amount = split_amount_input.value
			_open_dialog()
	)
	


func _open_dialog() -> void:
	file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	file_dialog.force_native = true
	file_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	file_dialog.file_selected.connect(_on_file_selected)
	file_dialog.title = "Select images where red crosses have to be removed"
	file_dialog.add_filter("*.png, *.jpg, *.jpeg", "Images")
	main_screen.add_child(file_dialog)
	file_dialog.set_meta("_created_by", self)
	file_dialog.popup_file_dialog()


func _on_file_selected(path: String) -> void:
	
	var image: Image = Image.load_from_file(path)
	var splits: Array[Image]
	var last_y: int = 0
	for i: int in split_amount:
		var size: Vector2i = Vector2i(
			image.get_width(),
			floori(float(image.get_height()) / split_amount) if i != split_amount - 1 else ceili(float(image.get_height()) / split_amount)
		)
		var split: Image = Image.create_empty(size.x, size.y, false, image.get_format())
		split.blit_rect(
			image,
			Rect2i(Vector2i(0, last_y), size), Vector2i.ZERO
		)
		last_y += size.y
		splits.append(split)

	for i: int in split_amount:
		var name: String = path.get_basename() + "_%d." % i + path.get_extension()
		match path.get_extension():
			"png":
				splits[i].save_png(name)
			"jpg", "jpeg":
				splits[i].save_jpg(name)

	EditorInterface.get_editor_toaster().push_toast("Split image.")

	if file_dialog:
		file_dialog.queue_free()

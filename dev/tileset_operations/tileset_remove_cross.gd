@tool
extends EditorScript

const RED_CROSS: Image = preload("res://dev/tileset_operations/red_cross.png")

var file_dialog: EditorFileDialog
var main_screen: VBoxContainer
var tile_size: int:
	get: return RED_CROSS.get_width()

func _run() -> void:
	main_screen = get_editor_interface().get_editor_main_screen()
	file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILES
	file_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	file_dialog.force_native = true
	file_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	file_dialog.files_selected.connect(_on_files_selected)
	file_dialog.title = "Select images where red crosses have to be removed"
	file_dialog.add_filter("*.png, *.jpg, *.jpeg", "Images")
	main_screen.add_child(file_dialog)
	file_dialog.set_meta("_created_by", self)
	file_dialog.popup_file_dialog()


func _on_files_selected(paths: PackedStringArray) -> void:
	var image: Image
	for path: String in paths:
		image = Image.load_from_file(path)
		var edited: bool = false
		for x: int in range(0, image.get_width(), tile_size):
			for y: int in range(0, image.get_height(), tile_size):
				if _compare_tile(image, Vector2i(x, y)):
					edited = true
					for tile_x: int in tile_size:
						for tile_y: int in tile_size:
							image.set_pixel(x + tile_x, y + tile_y, Color(0, 0, 0, 0))
		if edited:
			match path.get_extension():
				"png":
					image.save_png(path)
				"jpg", "jpeg":
					image.save_jpg(path)

	EditorInterface.get_editor_toaster().push_toast("Done removing crosses.")

	if file_dialog:
		file_dialog.queue_free()


func _compare_tile(src: Image, position: Vector2i) -> bool:
	for x: int in tile_size:
		for y: int in tile_size:
			if src.get_pixelv(position + Vector2i(x, y)) != RED_CROSS.get_pixel(x, y):
				return false
	return true

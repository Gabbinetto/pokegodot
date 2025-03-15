class_name Utils extends Node


static func load_external_texture(path: String) -> ImageTexture:
	if not FileAccess.file_exists(path):
		push_error(path, " does not exist.")
		return
	var image: Image = Image.load_from_file(path)
	if image:
		return ImageTexture.create_from_image(image)
	else:
		return

static func load_or_null(path: String) -> Variant:
	if FileAccess.file_exists(path):
		return load(path)
	return

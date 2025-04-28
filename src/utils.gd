class_name Utils extends Object


static func load_no_error(path: String) -> Variant:
	if ResourceLoader.exists(path):
		return load(path)
	return

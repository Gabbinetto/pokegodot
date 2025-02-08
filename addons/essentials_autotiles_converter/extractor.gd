@tool
extends Control

enum Corners {TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT}

const TERRAIN_BITS_IMAGE: Image = preload("res://addons/essentials_autotiles_converter/terrain_bits.png")
const TERRAIN_UV: Image = preload("res://addons/essentials_autotiles_converter/terrain_uv.png")
const OUTPUT_TILES: Vector2i = Vector2i(12, 4)


@export var tiles_texture: TextureRect
@export var preview: TextureRect
@export var source_input: LineEdit
@export var source_button: BaseButton
@export var source_file_dialogue: FileDialog
@export var image_output_input: LineEdit
@export var image_output_button: BaseButton
@export var image_output_file_dialogue: FileDialog
@export var tileset_input: LineEdit
@export var tileset_button: BaseButton
@export var tileset_load_button: BaseButton
@export var tileset_file_dialogue: FileDialog
@export var generate_image_button: BaseButton
@export var image_only_button: BaseButton
@export var save_button: BaseButton
var frames: int:
	get: return %Frames.value
	set(value): %Frames.value = value
var tile_size: int:
	get: return %TileSize.value
	set(value): %TileSize.value = value
var frame_duration: float:
	get: return %FrameDuration.value
	set(value): %FrameDuration.value = value
var overwrite: bool:
	get: return %Overwrite.button_pressed
	set(value): %Overwrite.button_pressed = value
var terrain_bits: BitMap = BitMap.new()
var tiles_image: Image
var output_image: Image
var tileset: TileSet:
	set(value):
		tileset = value
		if tileset:
			%TilesetLoadedLabel.show()
		else:
			%TilesetLoadedLabel.hide()
var saved_image: bool = false


func _ready() -> void:
	source_button.pressed.connect(source_file_dialogue.show)
	image_output_button.pressed.connect(image_output_file_dialogue.show)
	tileset_button.pressed.connect(tileset_file_dialogue.show)

	source_file_dialogue.file_selected.connect(_select_image)
	image_output_file_dialogue.file_selected.connect(
		func(path: String):
			image_output_input.text = path
			saved_image = false
	)
	tileset_file_dialogue.file_selected.connect(func(path: String): tileset_input.text = path)
	tileset_load_button.pressed.connect(func(): _select_tileset(tileset_input.text))

	generate_image_button.pressed.connect(_generate_image)
	image_only_button.pressed.connect(
		func():
			if output_image:
				output_image.save_png(image_output_input.text)
				saved_image = true
				if Engine.is_editor_hint():
					EditorInterface.get_editor_toaster().push_toast("Saved image.")
	)
	save_button.pressed.connect(_generate)

	terrain_bits.create_from_image_alpha(TERRAIN_BITS_IMAGE)


func _select_tileset(path: String) -> void:
	if not path:
		return
	tileset = load(path)
	if not tileset:
		if Engine.is_editor_hint():
			EditorInterface.get_editor_toaster().push_toast("Couldn't load tileset at %s" % path, EditorToaster.SEVERITY_ERROR)
		tileset = null
		tileset_input.text = ""
		return
	if Engine.is_editor_hint():
		EditorInterface.get_editor_toaster().push_toast("Tileset loaded.")


func _select_image(path: String) -> void:
	source_input.text = path
	saved_image = false
	tiles_image = Image.load_from_file(path)
	if not tiles_image:
		if Engine.is_editor_hint():
			EditorInterface.get_editor_toaster().push_toast("Couldn't load image at %s" % path, EditorToaster.SEVERITY_ERROR)
		tiles_texture.texture = null
		return
	if Engine.is_editor_hint():
		EditorInterface.get_editor_toaster().push_toast("Image loaded")
	var tex: Image = tiles_image.duplicate()
	tex.crop(tex.get_width() / frames, tex.get_height())
	tiles_texture.texture = ImageTexture.create_from_image(tex)


func _get_corner_offset(corner: Corners) -> Vector2i:
	match corner:
		Corners.TOP_LEFT:
			return Vector2i(0, 0)
		Corners.TOP_RIGHT:
			return Vector2i(tile_size / 2, 0)
		Corners.BOTTOM_LEFT:
			return Vector2i(0, tile_size / 2)
		Corners.BOTTOM_RIGHT:
			return Vector2i(tile_size / 2, tile_size / 2)
		_:
			return Vector2i.ZERO


func _get_quarter(x: int, y: int, corner: Corners, frame: int = 0) -> Image:
	var quarter: Image = Image.create_empty(tile_size / 2, tile_size / 2, false, Image.FORMAT_RGBA8)
	var offset: Vector2i = _get_corner_offset(corner)
	if frames > 1:
		offset += Vector2i(tiles_image.get_width() / frames * frame, 0)

	quarter.blit_rect(
		tiles_image,
		Rect2i(
			Vector2i(x * tile_size, y * tile_size) + offset,
			Vector2i(tile_size / 2, tile_size / 2)
		),
		Vector2i.ZERO
	)

	return quarter


func _generate_image(update_texture: bool = true):
	output_image = Image.create_empty(OUTPUT_TILES.x * tile_size * frames, OUTPUT_TILES.y * tile_size, false, Image.FORMAT_RGBA8)
	for frame: int in frames:
		var x_off: int = frame * tile_size * OUTPUT_TILES.x
		for x: int in OUTPUT_TILES.x * 2:
			for y: int in OUTPUT_TILES.y * 2:
				var pixel: Color = TERRAIN_UV.get_pixel(x, y)
				if pixel.a8 <= 0:
					continue
				var quarter: Image = _get_quarter(pixel.r8, pixel.g8, pixel.b8 as Corners, frame)
				output_image.blit_rect(
					quarter, Rect2i(Vector2i.ZERO, quarter.get_size()),
					Vector2i((x / 2 * tile_size) + x_off, y / 2 * tile_size) + _get_corner_offset(pixel.b8 as Corners)
				)
	if update_texture:
		var tex: Image = output_image.duplicate(true)
		tex.crop(tex.get_width() / frames, tex.get_height())
		preview.texture = ImageTexture.create_from_image(tex)

func _generate() -> void:
	if not tileset:
		print_rich("[color=yellow]No tileset resource loaded. Created new one[/color]")
		tileset = TileSet.new()
		tileset.tile_size = tile_size * Vector2i.ONE
	if not output_image:
		if Engine.is_editor_hint():
			EditorInterface.get_editor_toaster().push_toast("No image generated.", EditorToaster.SEVERITY_WARNING)
		return
	if not saved_image:
		if Engine.is_editor_hint():
			EditorInterface.get_editor_toaster().push_toast("Generated image must be saved.", EditorToaster.SEVERITY_ERROR)
		return
	
	var texture: Texture2D = load(image_output_input.text)
	if not texture:
		if Engine.is_editor_hint():
			EditorInterface.get_editor_toaster().push_toast("Error while loading saved image at %s" % image_output_input.text, EditorToaster.SEVERITY_ERROR)
		return
	var source: TileSetAtlasSource
	var terrain_set: int
	var terrain: int
	if overwrite:
		source = tileset.get_source(tileset.get_next_source_id() - 1)
		var sample_tile: TileData = source.get_tile_data(Vector2i.ZERO, 0)
		terrain_set = sample_tile.terrain_set
		terrain = sample_tile.terrain
	else:
		source = TileSetAtlasSource.new()
		source.resource_name = image_output_input.text.get_file().get_slice(".", 0)
		tileset.add_source(source)
		tileset.add_terrain_set()
		terrain_set = tileset.get_terrain_sets_count() - 1
		tileset.add_terrain(terrain_set)
		terrain = tileset.get_terrains_count(terrain_set) - 1
		tileset.set_terrain_name(terrain_set, terrain, source.resource_name)
	
	source.texture = texture
	source.texture_region_size = tile_size * Vector2i.ONE
	
	for x: int in OUTPUT_TILES.x:
		for y: int in OUTPUT_TILES.y:
			var coords: Vector2i = Vector2i(x, y)
			if overwrite and source.has_tile(coords):
				source.remove_tile(coords)
			source.create_tile(coords)
			var tile: TileData = source.get_tile_data(coords, 0)
			if not tile:
				if Engine.is_editor_hint():
					EditorInterface.get_editor_toaster().push_toast("Couldn't get tile created at %d,%d" % [x, y], EditorToaster.SEVERITY_ERROR)
				continue
			if frames > 1:
				source.set_tile_animation_columns(coords, frames)
				source.set_tile_animation_separation(coords, Vector2i(OUTPUT_TILES.x - 1, 0))
				source.set_tile_animation_frames_count(coords, frames)
				for frame: int in frames:
					source.set_tile_animation_frame_duration(coords, frame, frame_duration)
				
			tile.terrain_set = terrain_set
			if terrain_bits.get_bit(x * 3 + 0, y * 3 + 0):
				tile.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER, terrain)
			if terrain_bits.get_bit(x * 3 + 1, y * 3 + 0):
				tile.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_SIDE, terrain)
			if terrain_bits.get_bit(x * 3 + 2, y * 3 + 0):
				tile.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER, terrain)
			if terrain_bits.get_bit(x * 3 + 0, y * 3 + 1):
				tile.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_LEFT_SIDE, terrain)
			if terrain_bits.get_bit(x * 3 + 1, y * 3 + 1):
				tile.terrain = terrain
			if terrain_bits.get_bit(x * 3 + 2, y * 3 + 1):
				tile.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_RIGHT_SIDE, terrain)
			if terrain_bits.get_bit(x * 3 + 0, y * 3 + 2):
				tile.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, terrain)
			if terrain_bits.get_bit(x * 3 + 1, y * 3 + 2):
				tile.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_SIDE, terrain)
			if terrain_bits.get_bit(x * 3 + 2, y * 3 + 2):
				tile.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, terrain)
	
	ResourceSaver.save(tileset, tileset_input.text)
	if Engine.is_editor_hint():
		EditorInterface.get_editor_toaster().push_toast("Saved tileset at %s" % tileset_input.text)

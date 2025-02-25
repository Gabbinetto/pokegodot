class_name ActorFrames extends SpriteFrames


@export var texture: Texture2D:
	set(value):
		texture = value
		if texture:
			generate_animations()
			remove_animation("default")

@export_range(1, 99, 1, "or_greater") var animation_frames: int = 4


func generate_animations() -> void:
	var frame_size: Vector2i = Vector2i(
		texture.get_width() / animation_frames,
		texture.get_height() / Actor.DIRECTIONS.size()
	)
	
	for i: int in Actor.DIRECTIONS.size():
		var direction: String = Actor.DIRECTIONS.keys()[i]
		if has_animation(Actor.ANIMATION_WALK_PREFIX + direction):
			remove_animation(Actor.ANIMATION_WALK_PREFIX + direction)
		add_animation(Actor.ANIMATION_WALK_PREFIX + direction)
		for frame_idx: int in animation_frames:
			var frame: AtlasTexture = AtlasTexture.new()
			frame.atlas = texture
			frame.region = Rect2i(frame_size * Vector2i(frame_idx, i), frame_size)
			add_frame(Actor.ANIMATION_WALK_PREFIX + direction, frame)
			if frame_idx == 0:
				if has_animation(Actor.ANIMATION_IDLE_PREFIX + direction):
					remove_animation(Actor.ANIMATION_IDLE_PREFIX + direction)
				add_animation(Actor.ANIMATION_IDLE_PREFIX + direction)
				add_frame(Actor.ANIMATION_IDLE_PREFIX + direction, frame)

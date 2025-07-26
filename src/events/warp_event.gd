@tool
class_name WarpEvent extends Event


@export var target_map_id: String
@export var target_position: Vector2i
@export var step_down_after_warp: bool = false
@export var transition: bool = true:
	set(value):
		transition = value
		notify_property_list_changed()
@export var transition_type: TransitionManager.TransitionTypes
@export var transition_params: Dictionary[String, Variant] = {}


func _validate_property(property: Dictionary) -> void:
	super(property)

	if property.name == "transition_type" or property.name == "transition_params":
		if transition:
			property.usage |= PROPERTY_USAGE_EDITOR
		else:
			property.usage &= ~PROPERTY_USAGE_EDITOR



func _run() -> void:
	var map: Map = Globals.game_world.get_map(target_map_id)
	if not map:
		return

	if transition:
		TransitionManager.play_in(transition_type, transition_params)
		await TransitionManager.finished

	var is_target_instantiated: bool = Globals.game_world.instantiated_maps_ids.has(target_map_id)

	if is_target_instantiated:
		Globals.game_world.instantiate_map(map)
	else:
		if Globals.game_world.is_instantiated:
			Globals.game_world.dispose_map()
		elif map != Globals.game_world.current_map:
			Globals.game_world.unload_map(Globals.game_world.current_map)
		Globals.game_world.load_map(map)

	Globals.player.global_position = map.to_global(target_position * Globals.TILE_SIZE)
	Globals.player.update_initial_position()

	var step_down: Callable = func():
		Globals.player.input_direction = Globals.DIRECTIONS.DOWN
		Globals.player.input_enabled = false
		Globals.player.disable_collision = true
		Globals.player.stopped_moving.connect(func():
			Globals.player.input_enabled = true
			Globals.player.disable_collision = false
		)

	if transition:
		TransitionManager.play_out()
		if step_down_after_warp:
			TransitionManager.finished.connect(step_down, CONNECT_ONE_SHOT)
	else:
		if step_down_after_warp:
			step_down.call()

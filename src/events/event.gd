@tool
class_name Event extends Area2D

signal done ## Make sure to emit this signal when your event ends.

@export var run_on_interaction: bool = true
@export var run_on_collision: bool = false:
	set(value):
		run_on_collision = value
		notify_property_list_changed()
@export_flags("Down", "Left", "Right", "Up") var valid_collision_directions: int = 1
@export var run_on_enter: bool = false
@export var bound_npc: NPC


func _validate_property(property: Dictionary) -> void:
	if property.name == "valid_collision_directions":
		if run_on_collision:
			property.usage |= PROPERTY_USAGE_EDITOR
		else:
			property.usage &= ~PROPERTY_USAGE_EDITOR


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area != Globals.player.area or not run_on_enter:
		return
	if Globals.player.is_moving:
		await Globals.player.stopped_moving
	run()


func collision(direction: Vector2) -> void:
	if run_on_collision:
		for i: int in 4:
			if direction == Actor.DIRECTIONS.values()[i] and not bool(valid_collision_directions & 2 ** i):
				return
		Globals.player.input_direction = Vector2.ZERO
		run()


func interact() -> void:
	if run_on_interaction:
		run()


func run() -> void:
	if bound_npc:
		if not bound_npc.no_turning:
			bound_npc.facing_direction = bound_npc.global_position.direction_to(
				Globals.player.global_position
			)
		bound_npc.can_move = false
		bound_npc.interacting = true
	_run()
	if bound_npc:
		await done
		bound_npc.can_move = true
		bound_npc.interacting = false



func _run() -> void:
	pass

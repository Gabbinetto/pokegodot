class_name Event extends Area2D

signal done ## Make sure to emit this signal when your event ends.

@export var run_on_interaction: bool = true
@export var run_on_collision: bool = false
@export var bound_npc: NPC


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if not (area == Globals.player) or not run_on_collision:
		return
	
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

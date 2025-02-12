class_name Event extends Area2D


@export var run_on_interaction: bool = true
@export var run_on_collision: bool = false


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
	pass

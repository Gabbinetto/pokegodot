class_name BattleAnimation extends Node2D

## Battle animation class.
##
## An animation that plays during battle.

signal finished ## Emitted when finished.

## Path to all battle animations.
const ANIMATIONS_PATH: String = "res://src/battle/battle_animations/"

@export var pivot: Node2D ## When playing the animation, the targets are reparented under this node, then brought back when it finishes.
@export var animation: AnimationPlayer ## The [AnimationPlayer] node that plays the animation.
@export var animation_name: String = "default" ## The animation played by [member animation]
@export var clear: bool = true ## If true, runs [method Node.queue_free] when finished.
var targets: Array[Node2D] ## The targets of the animation, usually the Pokemon sprites in battle.


## Plays the animation on all nodes in [member targets].
func play() -> void:
	# Move in the middle of targets
	var pos: Vector2
	for target: Node2D in targets:
		pos += target.global_position
	pos /= float(targets.size())
	global_position += pos
	
	# Reparent targets to pivot
	for target: Node2D in targets:
		target.set_meta("original_parent", target.get_parent())
		target.reparent(pivot)
	
	await _play_animation()
	
	for target: Node2D in targets:
		target.reparent(target.get_meta("original_parent"))
		target.remove_meta("original_parent")
	global_position -= pos
	
	finished.emit()
	
	if clear:
		queue_free()


func _play_animation() -> void:
	animation.play(animation_name)
	await animation.animation_finished


## Returns a [BattleAnimation] instance by loading a scene file from [member ANIMATIONS_PATH].
## If the [code]tscn[/code] file extension is not present in [param path], it gets added automatically.[br][br]
## [b]Example[/b]: calling this function with [code]hurt_flash[/code] as [param path] will return an instance of [code]res://src/battle/battle_animations/hurt_flash.tscn[/code]
static func get_animation(path: String, animation_targets: Array[Node2D] = [], parent: Node = null) -> BattleAnimation:
	if path.get_extension() != "tscn":
		path += ".tscn"
	if FileAccess.file_exists(ANIMATIONS_PATH + path):
		var animation_scene: PackedScene = load(ANIMATIONS_PATH + path)
		var animation: BattleAnimation = animation_scene.instantiate()
		animation.targets.assign(animation_targets)
		if parent:
			parent.add_child(animation)
		return animation
	return

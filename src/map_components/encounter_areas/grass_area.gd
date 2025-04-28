class_name GrassArea extends EncounterArea


@export var over_sprite: Node2D
@export var leaves_sprite: AnimatedSprite2D


func _ready() -> void:
	super()
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Actor:
		if leaves_sprite:
			if body.is_moving:
				await body.stopped_moving
			leaves_sprite.play("walked")
		if over_sprite:
			if body.is_moving:
				await body.stopped_moving
			over_sprite.show()
			if not body.started_moving.is_connected(over_sprite.hide):
				body.started_moving.connect(over_sprite.hide)

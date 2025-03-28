class_name GrassArea extends EncounterArea


@export var leaves_sprite: AnimatedSprite2D


func _ready() -> void:
	super()
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Actor and leaves_sprite:
		if body.is_moving:
			await body.stopped_moving
		leaves_sprite.play("walked")

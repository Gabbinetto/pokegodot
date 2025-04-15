extends BattleAnimation

@export var base_particle: GPUParticles2D

func _ready() -> void:
	remove_child(base_particle)


func _play_animation() -> void:
	var particle: GPUParticles2D
	for target: Node2D in targets:
		particle = base_particle.duplicate()
		target.add_child(particle)
		particle.position = Vector2.ZERO
		particle.restart()
		particle.finished.connect(particle.queue_free)
	await particle.finished

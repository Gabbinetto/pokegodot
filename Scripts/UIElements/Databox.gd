extends Control

@export var pokemon: Pokemon:
	set(value):
		pokemon = value
		pokemon.hp_changed.connect(_on_hp_changed)
@export var player: bool = true

@onready var hp_bar: ProgressBar = $HPBar
@onready var exp_bar: ProgressBar = $EXPBar
@onready var name_label: Label = $Name
@onready var level: Label = $Level
@onready var hps: Label = $HPs

func _ready() -> void:
	if not player:
		hps.hide()
		exp_bar.hide()

func _on_hp_changed(old_hp: int, new_hp: int) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(hp_bar, "value", new_hp, 0.1)

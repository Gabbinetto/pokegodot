extends Control

@export var pokemon: Pokemon
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

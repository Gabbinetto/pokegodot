class_name World extends Node2D


func _ready() -> void:
	Globals.game_world = self ## There can only be one game world

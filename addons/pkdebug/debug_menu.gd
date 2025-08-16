@tool
extends Control

const PKDebug: GDScript = preload("res://addons/pkdebug/pkdebug.gd")

@export var tabs: Control
@export var not_connected_screen: Control

@export var menus: Array[Control]

var plugin: PKDebug

func setup(parent_plugin: PKDebug) -> void:
	plugin = parent_plugin

	plugin.connected.connect(
		func():
			tabs.show()
			not_connected_screen.hide()
	)
	plugin.disconnected.connect(
		func():
			tabs.hide()
			not_connected_screen.show()
	)

	for menu: Control in menus:
		menu.setup(parent_plugin)

@tool
extends VBoxContainer

const PKDebug: GDScript = preload("res://addons/pkdebug/pkdebug.gd")

@export var name_label: Label
@export var level_label: Label
@export var health_bar: Range
@export var health_bar_gradient: Gradient
@export var stat_template: Control
@export var stats_button: Button
@export var stats_container: Control


var plugin: PKDebug
var stats: Dictionary[String, Control]
var slot: int = -1


func setup(parent_plugin: PKDebug) -> void:
	plugin = parent_plugin

	stat_template.get_node("Buttons/Up").icon = EditorInterface.get_editor_theme().get_icon("GuiSpinboxUp", "EditorIcons")
	stat_template.get_node("Buttons/Down").icon = EditorInterface.get_editor_theme().get_icon("GuiSpinboxDown", "EditorIcons")
	stats_button.pressed.connect(func(): stats_container.visible = not stats_container.visible)
	stats_button.icon = EditorInterface.get_editor_theme().get_icon("GuiTreeUpdown", "EditorIcons")

	stats_container.remove_child(stat_template)


func update(data: Dictionary) -> void:
	slot = data.get("slot", -1)
	if slot == -1:
		hide()

	name_label.text = data.get("name", "")
	level_label.text = "Lv. %d" % data.get("level", 1)
	health_bar.max_value = data.get("max_hp", 100)
	health_bar.value = data.get("hp", 100)
	health_bar.self_modulate = health_bar_gradient.sample(health_bar.value / health_bar.max_value)

	var boosts: Dictionary[String, int] = data.get("boosts")
	for stat: String in boosts:
		var node: Control = stats.get(stat)
		if not node:
			node = stat_template.duplicate()
			stats[stat] = node
			stats_container.add_child(node)
			node.get_node("Buttons/Up").pressed.connect(
				func():
					plugin.send_message("battle_boost_pokemon", [slot, stat, 1])
			)
			node.get_node("Buttons/Down").pressed.connect(
				func():
					plugin.send_message("battle_boost_pokemon", [slot, stat, -1])
			)

		node.get_node("Name").text = stat.capitalize()
		node.get_node("Value").text = "%+d" % boosts[stat]

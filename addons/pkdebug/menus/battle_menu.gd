@tool
extends Control

const PKDebug: GDScript = preload("res://addons/pkdebug/pkdebug.gd")

@export_group("Battle explorer")
@export var explorer: Control
@export var connect_to_battle: BaseButton
@export_group("Wild battle", "wild_battle_")
@export var wild_battle_button: BaseButton
@export var wild_battle_dialog: ConfirmationDialog
@export var wild_battle_id: LineEdit
@export var wild_battle_form: SpinBox
@export var wild_battle_level: SpinBox

var plugin: PKDebug


func setup(parent_plugin: PKDebug) -> void:
	plugin = parent_plugin

	#region Explorer setup
	explorer.setup(parent_plugin)
	connect_to_battle.pressed.connect(func(): plugin.send_message("connect_battle", [explorer.update_timer.value]))
	plugin.debugger.battle_started.connect(
		func():
			connect_to_battle.get_parent().hide()
			explorer.show()
	)
	plugin.debugger.battle_ended.connect(
		func():
			connect_to_battle.get_parent().show()
			explorer.hide()
	)
	plugin.disconnected.connect(
		func():
			connect_to_battle.get_parent().show()
			explorer.hide()
	)
	#endregion

	#region Wild battle setup
	wild_battle_button.pressed.connect(
		wild_battle_dialog.popup_centered
	)
	wild_battle_dialog.confirmed.connect(_wild_battle_confirm)
	wild_battle_dialog.canceled.connect(
		func():
			wild_battle_id.text = ""
			wild_battle_form.set_value_no_signal(0)
			wild_battle_level.set_value_no_signal(1)
	)

	wild_battle_id.text_submitted.connect(wild_battle_form.grab_focus.call_deferred)
	wild_battle_form.value_changed.connect(wild_battle_level.grab_focus.call_deferred)
	wild_battle_level.value_changed.connect(wild_battle_dialog.get_ok_button().grab_focus.call_deferred)
	#endregion


func _wild_battle_confirm() -> void:
	plugin.send_message("wild_battle", [
		wild_battle_id.text,
		wild_battle_form.value,
		wild_battle_level.value,
	])
	wild_battle_id.text = ""
	wild_battle_form.set_value_no_signal(0)
	wild_battle_level.set_value_no_signal(1)

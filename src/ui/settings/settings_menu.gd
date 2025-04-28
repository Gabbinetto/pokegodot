class_name SettingsMenu extends Control

signal closed

const SETTINGS_MENU: PackedScene = preload("res://src/ui/settings/settings_menu.tscn")
const SettingsMenuEntry: GDScript = preload("res://src/ui/settings/settings_menu_entry.gd")

@export var entries: Control
@export var description: RichTextLabel
@export_group("Entries")
@export var text_speed: SettingsMenuEntry
@export var battle_effects: SettingsMenuEntry
@export var battle_style: SettingsMenuEntry
@export var default_run: SettingsMenuEntry
@export var automatic_box: SettingsMenuEntry
@export var give_nickname: SettingsMenuEntry
@export var box_frame: SettingsMenuEntry
@export var window_size: SettingsMenuEntry
@export var close: SettingsMenuEntry


func _ready() -> void:
	for node: Control in entries.get_children():
		if node is SettingsMenuEntry:
			node.focus_entered.connect(description.set_text.bind(node.description))
	
	# TODO: Add music and sfx volume sliders
	text_speed.value_changed.connect(_set_setting.bind("text_speed", text_speed.get_value))
	battle_effects.value_changed.connect(_set_setting.bind("battle_effects", func(): return battle_effects.get_value() == 0))
	battle_style.value_changed.connect(_set_setting.bind("battle_style_switch", func(): return battle_style.get_value() == 0))
	default_run.value_changed.connect(_set_setting.bind("default_run", func(): return default_run.get_value() > 0))
	automatic_box.value_changed.connect(_set_setting.bind("automatic_box", func(): return default_run.get_value() > 0))
	give_nickname.value_changed.connect(_set_setting.bind("give_nickname", func(): return default_run.get_value() == 0))
	box_frame.value_changed.connect(_set_setting.bind("box_frame", func(): return box_frame.get_value()))
	window_size.value_changed.connect(_window_size_changed)
	close.value_changed.connect(_close)
	
	_sync()
	entries.get_child(0).grab_focus.call_deferred()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_close()


func _close() -> void:
	Settings.save_settings()
	closed.emit()


func _sync() -> void:
	text_speed.set_value(Settings.text_speed)
	battle_effects.set_value(int(not Settings.battle_effects))
	battle_style.set_value(int(not Settings.battle_style_switch))
	default_run.set_value(int(Settings.default_run))
	automatic_box.set_value(int(Settings.automatic_box))
	give_nickname.set_value(int(not Settings.give_nicknames))
	box_frame.set_value(Settings.box_frame)
	box_frame.max = Settings.box_frame_count

	# Window size
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		window_size.set_value(Settings.ScreenSizes.FULL)
	elif Settings.SCREEN_SIZES.values().has(DisplayServer.window_get_size()):
		window_size.set_value(Settings.SCREEN_SIZES.find_key(DisplayServer.window_get_size()))
	else:
		window_size.set_value(0)
		


func _set_setting(setting: String, value_function: Callable) -> void:
	Settings.set(setting, value_function.call())


func _window_size_changed():
	Settings.set_screen_size(window_size.get_value() as Settings.ScreenSizes)


static func create() -> SettingsMenu:
	return SETTINGS_MENU.instantiate()

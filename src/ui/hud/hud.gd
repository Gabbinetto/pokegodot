extends Control


@export var menu: Control
@export var buttons_container: Control
@export_group("Buttons", "button_")
@export var button_party: BaseButton
@export var button_save: BaseButton
@export var button_settings: BaseButton
@export var button_debug: BaseButton
@export var button_quit: BaseButton
@export var save_dialogue: DialogueManager
@export var save_choice: DialogueChoiceSequence

var last_menu_option: Control
var submenu_open: bool = false

func _ready() -> void:
	for node: Control in buttons_container.get_children():
		node.focus_entered.connect(set.bind("last_menu_option", node))

	button_party.pressed.connect(_open_party)
	button_save.pressed.connect(_save)
	button_settings.pressed.connect(_open_settings)
	button_debug.pressed.connect(_open_debug)
	button_quit.pressed.connect(_quit)


func _can_open() -> bool:
	return (
		not Globals.in_battle and
		not submenu_open and
		not MainDialogue.running and
		not TransitionManager.transition and
		is_instance_valid(Globals.player)
	)


func _input(event: InputEvent) -> void:
	if _can_open():
		if event.is_action_pressed("Start") or event.is_action_pressed("X"):
			if not visible:
				open()
			else:
				close()
		elif event.is_action_pressed("B") and visible:
			close()


func _open_party() -> void:
	Audio.play_sfx(Audio.SOUNDS.GUI_SEL_DECISION)
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished

	menu.hide()

	submenu_open = true
	var party_menu: PartyMenu = PartyMenu.create()
	add_child(party_menu)
	party_menu.closed.connect(
		func():
			Audio.play_sfx(Audio.SOUNDS.GUI_MENU_CLOSE)
			TransitionManager.layer += 1
			TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
			await TransitionManager.finished
			party_menu.queue_free()
			await party_menu.tree_exited
			menu.show()
			submenu_open = false

			TransitionManager.play_out()
			await TransitionManager.finished
			TransitionManager.layer -= 1

			button_party.grab_focus.call_deferred()
	)


func _open_settings() -> void:
	Audio.play_sfx(Audio.SOUNDS.GUI_SEL_DECISION)
	menu.hide()
	submenu_open = true
	var settings: SettingsMenu = SettingsMenu.create()

	add_child(settings)

	settings.closed.connect(
		func():
			Audio.play_sfx(Audio.SOUNDS.GUI_MENU_CLOSE)
			settings.queue_free()
			menu.show.call_deferred()
			submenu_open = false
			button_settings.grab_focus.call_deferred()
	)


func _open_debug() -> void:
	Audio.play_sfx(Audio.SOUNDS.GUI_SEL_DECISION)
	menu.hide()
	submenu_open = true
	var debug: DebugMenu = DebugMenu.create()

	add_child(debug)

	debug.closed.connect(
		func():
			Audio.play_sfx(Audio.SOUNDS.GUI_MENU_CLOSE)
			debug.queue_free()
			menu.show.call_deferred()
			submenu_open = false
			button_debug.grab_focus.call_deferred()
	)


func _quit() -> void:
	Audio.play_sfx(Audio.SOUNDS.GUI_SEL_DECISION)
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished
	get_tree().quit.call_deferred()


func open() -> void:
	if Globals.player.is_moving:
		await Globals.player.stopped_moving

	Globals.movement_enabled = false
	Globals.event_input_enabled = false

	button_party.visible = PlayerData.team.size() > 0

	show()
	var focus_node: Control
	if last_menu_option:
		focus_node = last_menu_option
	else:
		for node: Control in buttons_container.get_children():
			if node.visible:
				focus_node = node
				break
	focus_node.grab_focus.call_deferred()
	var focus_sound: ControlFocusSound
	for node: Node in focus_node.get_children():
		if node is ControlFocusSound:
			focus_sound = node
	if focus_sound:
		focus_sound.volume_linear = 0.0
	Audio.play_sfx(Audio.SOUNDS.GUI_MENU_OPEN)
	if focus_sound:
		Audio.sfx_finished.connect(focus_sound.set.bind("volume_linear", 1.0), CONNECT_ONE_SHOT)


func close() -> void:
	Globals.movement_enabled = true
	Globals.event_input_enabled = true
	hide()
	Audio.play_sfx(Audio.SOUNDS.GUI_MENU_CLOSE)


#region Saving
func _save() -> void:
	Audio.play_sfx(Audio.SOUNDS.GUI_SEL_DECISION)
	button_save.release_focus()
	save_choice.choice_taken.connect(_on_save_selected, CONNECT_ONE_SHOT)
	MainDialogue.run_dialogue(save_dialogue)
	await MainDialogue.finished
	button_save.grab_focus.call_deferred()



func _on_save_selected(choice: int) -> void:
	if choice > 0:
		return
	PlayerData.save_data()
	print("Saved!")

#endregion

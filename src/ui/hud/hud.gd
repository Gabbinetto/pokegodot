class_name Hud extends UIStackElement

const SCENE: PackedScene = preload("res://src/ui/hud/hud.tscn")

@export var menu: Control
@export var buttons_container: Control
@export_group("Buttons", "button_")
@export var button_party: BaseButton
@export var button_bag: BaseButton
@export var button_save: BaseButton
@export var button_settings: BaseButton
@export var button_quit: BaseButton
@export var save_dialogue: DialogueManager
@export var save_choice: DialogueChoiceSequence

var last_menu_option: Control

func _ready() -> void:
	for node: Control in buttons_container.get_children():
		node.focus_entered.connect(set.bind("last_menu_option", node))

	button_party.pressed.connect(_open_menu.bind(func(): return PartyMenu.build()))
	button_bag.pressed.connect(_open_menu.bind(func(): return BagMenu.build()))
	button_save.pressed.connect(_save)
	button_settings.pressed.connect(_open_menu.bind(func(): return SettingsMenu.build(), false))
	button_quit.pressed.connect(_quit)


func _open_menu(menu_builder: Callable, transition: bool = true) -> void:
	Audio.play_sfx(Audio.SOUNDS.GUI_SEL_DECISION)
	if transition:
		TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
		await TransitionManager.finished

	var submenu: UIStackElement = menu_builder.call()
	submenu.closed.connect(last_menu_option.grab_focus.call_deferred, CONNECT_ONE_SHOT)
	UIStack.push(submenu)
	if transition:
		TransitionManager.play_out()


func _open_party() -> void:
	Audio.play_sfx(Audio.SOUNDS.GUI_SEL_DECISION)
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished

	var party_menu: PartyMenu = PartyMenu.build()
	UIStack.push(party_menu)
	TransitionManager.play_out()


func _open_bag() -> void:
	Audio.play_sfx(Audio.SOUNDS.GUI_SEL_DECISION)
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished

	var bag_menu: BagMenu = BagMenu.build()
	UIStack.push(bag_menu)
	TransitionManager.play_out()


func _open_settings() -> void:
	Audio.play_sfx(Audio.SOUNDS.GUI_SEL_DECISION)
	menu.hide()
	var settings: SettingsMenu = SettingsMenu.build()
	UIStack.push(settings)


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
	Audio.play_sfx(Audio.SOUNDS.GUI_MENU_CLOSE)
	UIStack.pop()
	queue_free()


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

static func build(_options: Dictionary = {}) -> Hud:
	var hud: Hud = SCENE.instantiate()
	hud.open()
	return hud

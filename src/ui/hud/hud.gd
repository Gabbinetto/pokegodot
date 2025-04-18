extends Control


@export var menu: Control
@export var buttons_container: Control
@export_group("Buttons", "button_")
@export var button_party: BaseButton
@export var button_debug: BaseButton
@export var button_quit: BaseButton

var last_menu_option: Control
var submenu_open: bool = false

func _ready() -> void:
	for node: Control in buttons_container.get_children():
		node.focus_entered.connect(set.bind("last_menu_option", node))
	
	button_party.pressed.connect(_open_party)
	button_debug.pressed.connect(_open_debug)
	button_quit.pressed.connect(_quit)


func _can_open() -> bool:
	return not Globals.in_battle and not submenu_open and not MainDialogue.running and not TransitionManager.transition


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
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished
	
	menu.hide()
	
	submenu_open = true
	var party_menu: PartyMenu = PartyMenu.create()
	add_child(party_menu)
	party_menu.closed.connect(
		func():
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


func _open_debug() -> void:
	menu.hide()
	submenu_open = true
	var debug: DebugMenu = DebugMenu.create()
	
	add_child(debug)
	
	debug.closed.connect(
		func():
			debug.queue_free()
			menu.show()
			submenu_open = false
			button_debug.grab_focus.call_deferred()
	)


func _quit() -> void:
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
	if last_menu_option:
		last_menu_option.grab_focus.call_deferred()
	else:
		for node: Control in buttons_container.get_children():
			if node.visible:
				node.grab_focus.call_deferred()
				break


func close() -> void:
	Globals.movement_enabled = true
	Globals.event_input_enabled = true
	hide()

extends Control


@export var menu: Control
@export var buttons_container: Control
@export_group("Buttons", "button_")
@export var button_party: BaseButton
@export var button_quit: BaseButton

var last_menu_option: Control
var submenu_open: bool = false

func _ready() -> void:
	for node: Control in buttons_container.get_children():
		node.focus_entered.connect(set.bind("last_menu_option", node))
	
	button_party.pressed.connect(_open_party)
	button_quit.pressed.connect(_quit)


func _can_open() -> bool:
	return not Globals.in_battle and not submenu_open and not Globals.dialogue.running


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
	menu.hide()
	submenu_open = true
	var party_menu: PartyMenu = PartyMenu.create()
	add_child(party_menu)
	party_menu.closed.connect(
		func():
			menu.show()
			submenu_open = false
			party_menu.queue_free()
			button_party.grab_focus.call_deferred()
	)


func _quit() -> void:
	get_tree().quit()


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

class_name PartyMenu extends Control

signal closed
signal pokemon_selected(pokemon: Pokemon)

const MENU_SCENE: PackedScene = preload("res://src/ui/party/party_menu.tscn")
const SWAP_ANIMATION_DURATION: float = 1.0
const SWAP_OFFSET: float = 10.0
const SOUND_PARTY_SWITCH = preload("res://assets/audio/sfx/GUI party switch.ogg")


@export var panels_container: Control
@export var cancel_button: BaseButton
@export var menu: Control
@export var menu_buttons_container: Control
@export_group("Menu buttons", "button_")
@export var button_switch_in: BaseButton
@export var button_summary: BaseButton
@export var button_switch: BaseButton
@export var button_nickname: BaseButton
@export var button_item: BaseButton
@export var button_menu_cancel: BaseButton


var in_battle: bool = false
var can_cancel: bool = true
var team: PokemonTeam
var panels: Array[PartyPanel]
var current_panel: PartyPanel
var swapping_from: PartyPanel:
	set(value):
		if swapping_from:
			swapping_from.swapping_from = false
		swapping_from = value
		if value:
			value.swapping_from = true
		_disable_cancel_on_swap()
var swapping_to: PartyPanel:
	set(value):
		if swapping_to:
			swapping_to.swapping_to = false
		swapping_to = value
		if value:
			value.swapping_to = true
		_disable_cancel_on_swap()
var swapping: bool = false


func _ready() -> void:
	panels.assign(panels_container.get_children())
	if not team:
		team = PlayerData.team
	if team.size() < 2:
		button_switch.hide()

	var team_array: Array[Pokemon] = team.array().duplicate()
	if in_battle:
		var mon_in_battle: Array[Pokemon]
		var mon_out_battle: Array[Pokemon]
		for pokemon: Pokemon in team_array:
			if _is_pokemon_in_battle(pokemon):
				mon_in_battle.append(pokemon)
			else:
				mon_out_battle.append(pokemon)
		if Globals.current_battle.ally_pokemon[0].pokemon != mon_in_battle[0]:
			mon_in_battle.reverse()
		team_array = mon_in_battle + mon_out_battle

	for i: int in panels.size():
		if i < team_array.size():
			panels[i].pokemon = team_array[i]
		else:
			panels[i].pokemon = null

		panels[i].focus_entered.connect(_on_panel_focus.bind(panels[i]))
		panels[i].focus_exited.connect(_on_panel_unfocus.bind(panels[i]))
		panels[i].pressed.connect(_on_panel_pressed.bind(panels[i]))

	if team.size() != 0:
		panels[0].grab_focus.call_deferred()
	else:
		cancel_button.grab_focus.call_deferred()

	for button: BaseButton in menu_buttons_container.get_children():
		button.gui_input.connect(_menu_button_input)
	button_summary.pressed.connect(_on_summary_pressed)
	button_switch.pressed.connect(_on_switch_pressed)
	button_nickname.pressed.connect(_on_nickname_pressed)
	button_switch_in.pressed.connect(_on_switch_in_pressed)
	button_menu_cancel.pressed.connect(_menu_cancel)
	cancel_button.pressed.connect(closed.emit)
	cancel_button.disabled = not can_cancel

	menu.visibility_changed.connect(_on_menu_visibility_changed)

	if in_battle:
		for button: BaseButton in menu_buttons_container.get_children():
			button.visible = [button_switch_in, button_summary, button_menu_cancel].has(button)

	if TransitionManager.transition:
		TransitionManager.play_out()
		await TransitionManager.finished




func _unhandled_input(event: InputEvent) -> void:
	if swapping:
		return
	if event.is_action_pressed("B"):
		if swapping_from != null or swapping_to != null:
			swapping_from = null
			swapping_to = null
			_refresh_panels()
		elif not menu.visible:
			closed.emit()


func _on_panel_focus(panel: PartyPanel) -> void:
	Audio.play_sfx(Audio.SOUNDS.GUI_SEL_CURSOR)
	current_panel = panel
	if swapping_from != null:
		swapping_to = panel



func _on_panel_unfocus(_panel: PartyPanel) -> void:
	pass


func _on_panel_pressed(_panel: PartyPanel) -> void:
	if swapping:
		return
	if swapping_from == null:
		menu.show()
		var first: Control
		for node: Control in menu_buttons_container.get_children():
			if node.visible:
				first = node
				break
		first.grab_focus.call_deferred()
	else:
		swap_slots()


func _set_panels_mouse(can_press: bool) -> void:
	for node: Control in panels_container.get_children():
		node.mouse_filter = Control.MOUSE_FILTER_STOP if can_press else Control.MOUSE_FILTER_IGNORE


#region Menu functions
func _menu_cancel() -> void:
	menu.hide()
	current_panel.grab_focus.call_deferred()


func _menu_button_input(input: InputEvent) -> void:
	if input.is_action_pressed("ui_cancel"):
		_menu_cancel.call_deferred()


func _set_menu_neighbors() -> void:
	for node: Control in menu_buttons_container.get_children():
		node.focus_neighbor_left = node.get_path()
		node.focus_neighbor_right = node.get_path()
		node.focus_neighbor_top = menu_buttons_container.get_child(max(node.get_index() - 1, 0)).get_path()
		node.focus_neighbor_bottom = menu_buttons_container.get_child(min(node.get_index() + 1, menu_buttons_container.get_child_count() - 1)).get_path()


func _on_menu_visibility_changed() -> void:
	Audio.play_sfx.call_deferred(Audio.SOUNDS.GUI_SEL_DECISION)
	_set_menu_neighbors()
	_set_panels_mouse.call_deferred(not menu.visible)


#region In battle functions
func _is_pokemon_in_battle(pokemon: Pokemon) -> bool:
	for info: BattlePokemon in Globals.current_battle.pokemons:
		if info != null and pokemon == info.pokemon:
			return true
	return false


func _on_switch_in_pressed() -> void:
	if not _is_pokemon_in_battle(current_panel.pokemon):
		pokemon_selected.emit(current_panel.pokemon)
#endregion

#region Swap only functions
func _on_switch_pressed() -> void:
	if team.size() <= 1:
		return
	swapping_from = current_panel
	swapping_to = current_panel
	menu.hide()
	current_panel.grab_focus.call_deferred()


func _disable_cancel_on_swap() -> void:
	if swapping_from or swapping_to:
		cancel_button.disabled = true
		cancel_button.focus_mode = Control.FOCUS_NONE
	else:
		cancel_button.disabled = false
		cancel_button.focus_mode = Control.FOCUS_ALL


func swap_slots() -> void:
	if swapping_from == swapping_to:
		return

	swapping = true
	var _swap: Callable = func():
		team.swap(swapping_from.get_index(), swapping_to.get_index())
		var tmp: Pokemon = swapping_from.pokemon
		swapping_from.pokemon = swapping_to.pokemon
		swapping_to.pokemon = tmp

	for panel: PartyPanel in [swapping_from, swapping_to]:
		panel.set_meta("original_position", panel.position)
		var target_position: Vector2 = Vector2(0, panel.position.y)
		if panel.get_index() % 2 == 0:
			target_position.x = -panel.size.x - SWAP_OFFSET
		else:
			target_position.x = size.x + SWAP_OFFSET
		panel.set_meta("target_position", target_position)


	var tween: Tween = create_tween()
	tween.tween_callback(Audio.play_sfx.bind(SOUND_PARTY_SWITCH))
	tween.tween_property(swapping_from, "position", swapping_from.get_meta("target_position"), SWAP_ANIMATION_DURATION / 2.0)
	tween.parallel().tween_property(swapping_to, "position", swapping_to.get_meta("target_position"), SWAP_ANIMATION_DURATION / 2.0)
	tween.tween_callback(_swap)
	tween.tween_callback(Audio.play_sfx.bind(SOUND_PARTY_SWITCH))
	tween.tween_property(swapping_from, "position", swapping_from.get_meta("original_position"), SWAP_ANIMATION_DURATION / 2.0)
	tween.parallel().tween_property(swapping_to, "position", swapping_to.get_meta("original_position"), SWAP_ANIMATION_DURATION / 2.0)

	await tween.finished

	swapping_from = null
	swapping_to = null
	swapping = false

	_refresh_panels()
#endregion
#endregion

func _on_summary_pressed() -> void:
	var summary: SummaryMenu = SummaryMenu.create(team.array(), {"starting_index": current_panel.get_index(), "in_battle": in_battle})
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished
	add_sibling(summary)
	hide()
	summary.closed.connect(
		func():
			TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
			await TransitionManager.finished
			summary.queue_free()
			await summary.tree_exited
			show()
			TransitionManager.play_out()
			await TransitionManager.finished
			# Await to make sure focus is grabbed after closing (Especially when in moves screen)
			await get_tree().process_frame
			button_summary.grab_focus()
	)


func _on_nickname_pressed() -> void:
	var pokemon: Pokemon = current_panel.pokemon
	var text_input: TextInput = TextInput.create(
		{
			"label": "What is %s's name?" % pokemon.species.name,
			"length": Pokemon.MAX_NICKNAME_SIZE,
		}
	)
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished
	add_sibling(text_input)
	hide()
	TransitionManager.play_out()
	await TransitionManager.finished
	text_input.submitted.connect(
		func(text: String):
			pokemon.name = text
			_refresh_panels()

			TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
			await TransitionManager.finished

			text_input.queue_free()
			show()

			TransitionManager.play_out()
			await TransitionManager.finished

			button_nickname.grab_focus.call_deferred()
	)


func _refresh_panels():
	for panel: PartyPanel in panels:
		panel.refresh()


static func create(pokemon_team: PokemonTeam = null, attributes: Dictionary[String, Variant] = {}) -> PartyMenu:
	var party_menu: PartyMenu = MENU_SCENE.instantiate()
	party_menu.team = pokemon_team
	party_menu.in_battle = attributes.get("in_battle", false)
	party_menu.can_cancel = attributes.get("can_cancel", true)
	return party_menu

class_name BattleUI extends Node

signal move_selected(move: PokemonMove)
signal target_selected(index: int)
signal pokemon_selected
signal run_selected
signal base_cancel_selected


enum Screens {
	NONE,
	BASE,
	FIGHT,
	TARGET_SELECT,
	DIALOGUE,
}


@export var battle: Battle
@export var message_background: TextureRect
@export var all_screens: Array[CanvasItem]
@export_group("Databoxes", "databox_")
@export var databox_singles_container: Control
@export var databox_doubles_container: Control
@export var databox_ally_single: Databox
@export var databox_enemy_single: Databox
@export var databox_allies_double: Array[Databox]
@export var databox_enemies_double: Array[Databox]
@export_group("Base screen")
@export var base_screen: Control
@export var fight_button: BaseButton
@export var pokemon_button: BaseButton
@export var bag_button: BaseButton
@export var run_button: BaseButton
@export var base_cancel_button: BaseButton
@export_group("Fight screen")
@export var fight_screen: Control
@export var move_buttons: Array[MoveButton]
@export var fight_cancel_button: BaseButton
@export var info_box: Control
@export var info_pp: Label
@export var info_type: TextureRect
@export_group("Target selection screen")
@export var target_screen: Control
@export var target_buttons: Array[Button] ## Target buttons when choosing a target in double battles. Should select the allies first, then the foes.
@export var target_cancel_button: BaseButton
@export_group("Dialogues")
@export var selection_dialogue: Dialogue
@export var selection_dialogue_manager: DialogueManager
@export var battle_dialogue: Dialogue
@export var battle_dialogue_manager: DialogueManager

var used_databoxes: Array[Databox] = [null, null, null, null]
var last_move_buttons: Dictionary[int, MoveButton]
var last_selected_pokemon: Pokemon
var current_screen: Screens:
	get:
		var node: CanvasItem
		for screen: CanvasItem in all_screens:
			if screen.visible:
				node = screen
		match node:
			base_screen: return Screens.BASE
			fight_screen: return Screens.FIGHT
			target_screen: return Screens.TARGET_SELECT
			battle_dialogue: return Screens.DIALOGUE
			_: return Screens.NONE


func _ready() -> void:
	base_screen.visibility_changed.connect(_on_base_visible)
	fight_button.pressed.connect(show_screen.bind(Screens.FIGHT))
	pokemon_button.pressed.connect(prompt_switch)
	run_button.pressed.connect(run_selected.emit)
	base_cancel_button.pressed.connect(base_cancel_selected.emit)
	
	fight_screen.visibility_changed.connect(_on_fight_visible)
	fight_cancel_button.pressed.connect(_on_fight_cancel)
	
	target_screen.visibility_changed.connect(_on_target_visible.call_deferred)
	target_cancel_button.pressed.connect(show_screen.bind(Screens.FIGHT))
	for button: BaseButton in target_buttons:
		button.pressed.connect(target_selected.emit.bind(target_buttons.find(button)))
	
	for button: MoveButton in move_buttons:
		button.focus_entered.connect(_on_move_focus.bind(button))
		button.focus_exited.connect(_on_move_unfocus)
		button.pressed.connect(_on_move_pressed.bind(button))

	_on_base_visible.call_deferred()


## Shows [param screen] while hiding all other commands.
func show_screen(screen: Screens) -> void:
	var node: CanvasItem
	match screen:
		Screens.BASE:
			node = base_screen
			fight_button.grab_focus.call_deferred()
		Screens.FIGHT:
			node = fight_screen
		Screens.TARGET_SELECT:
			node = target_screen
		Screens.DIALOGUE:
			node = battle_dialogue
	
	for child: CanvasItem in all_screens:
		if child == node:
			child.show()
		else:
			child.hide()


func set_base_cancel_button(enabled: bool) -> void:
	var button: BaseButton = base_cancel_button if enabled else run_button
	if enabled:
		run_button.hide()
	else:
		base_cancel_button.hide()
	button.show()
	pokemon_button.focus_neighbor_bottom = button.get_path()
	bag_button.focus_neighbor_right = button.get_path()


## Shows the current pokemon's moves in the move buttons.
func refresh_move_buttons() -> void:
	if not battle.current_pokemon:
		return
	for i: int in 4:
		if i + 1 > battle.current_pokemon.pokemon.moves.size():
			move_buttons[i].hide()
		else:
			move_buttons[i].show()
			move_buttons[i].move = battle.current_pokemon.pokemon.moves[i]


## Assigns the current pokemon to the databoxes and hides them if needed.
func refresh_databoxes() -> void:
	if battle.double_battle:
		databox_doubles_container.show()
		databox_singles_container.hide()

		used_databoxes = databox_allies_double + databox_enemies_double
	else:
		databox_doubles_container.hide()
		databox_singles_container.show()
		used_databoxes.fill(null)
		used_databoxes[0] = databox_ally_single
		used_databoxes[2] = databox_enemy_single
	
	for i: int in battle.pokemons.size():
		var pokemon: BattlePokemon = battle.pokemons[i]
		if not used_databoxes[i]:
			continue
		if not pokemon:
			used_databoxes[i].hide()
			used_databoxes[i].enabled = false
			continue
		used_databoxes[i].pokemon = pokemon.pokemon
		used_databoxes[i].show()
		used_databoxes[i].enabled = true


#region Target screen functions
## Update the target buttons with the current pokemon on the field.
func refresh_target_buttons() -> void:
	for i: int in battle.pokemons.size():
		target_buttons[i].text = battle.pokemons[i].name if battle.pokemons[i] else ""


func set_target_buttons_to_move(move: PokemonMove, user: BattlePokemon) -> void:
	var possible_targets: Array[bool] = move.get_possible_targets(battle, user)
	for i: int in target_buttons.size():
		var button: BaseButton = target_buttons[i]
		button.disabled = not possible_targets[i] or not battle.pokemons[i]
		button.focus_mode = Control.FOCUS_NONE if button.disabled else Control.FOCUS_ALL
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE if button.disabled else Control.MOUSE_FILTER_STOP
		# Make buttons appear as focused if a move selects all targets
		if move.hits_all() and not button.disabled:
			var style: StyleBox = button.get_theme_stylebox("focus")
			button.add_theme_stylebox_override("normal", style)
			button.add_theme_stylebox_override("hover", style)
		else:
			button.remove_theme_stylebox_override("normal")
			button.remove_theme_stylebox_override("hover")
#endregion


func prompt_switch(can_cancel: bool = true) -> void:
	var party: PartyMenu = PartyMenu.create(PlayerData.team, {"in_battle": true, "can_cancel": can_cancel})
	party.pokemon_selected.connect(_on_pokemon_selected.bind(party))
	party.closed.connect(_on_party_closed.bind(party))
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished
	add_child(party)


func _on_pokemon_selected(pokemon: Pokemon, party: PartyMenu) -> void:
	if pokemon.hp <= 0:
		return
	await _on_party_closed(party)
	last_selected_pokemon = pokemon
	pokemon_selected.emit(pokemon)


func _on_party_closed(party: PartyMenu) -> void:
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished
	party.queue_free()
	await party.tree_exited
	TransitionManager.play_out()
	await TransitionManager.finished
	if base_screen.visible:
		pokemon_button.grab_focus.call_deferred()


## Grab focus on the fight button when visible
func _on_base_visible() -> void:
	if not base_screen.visible:
		return
	fight_button.grab_focus.call_deferred()


func _on_move_focus(button: MoveButton) -> void:
	last_move_buttons[battle.current_pokemon_index] = button
	info_box.show()
	info_pp.text = "PP: %d/%d" % [button.move.pp, button.move.total_pp]
	info_type.texture = Types.ICONS[button.move.type]


func _on_move_unfocus() -> void:
	if get_viewport().gui_get_focus_owner() in move_buttons:
		return
	info_box.hide()


func _on_move_pressed(button: MoveButton) -> void:
	move_selected.emit(button.move)


func _on_fight_visible() -> void:
	if not fight_screen.visible:
		return
	var last_move_button: MoveButton = last_move_buttons.get(battle.current_pokemon_index)
	if last_move_button and last_move_button.visible:
		last_move_button.grab_focus.call_deferred()
	else:
		move_buttons.front().grab_focus.call_deferred()


func _on_fight_cancel() -> void:
	show_screen(Screens.BASE)


func _on_target_visible() -> void:
	if not target_screen.visible:
		return
	
	var selection_order: Array[BaseButton]
	@warning_ignore("integer_division")
	selection_order.assign(
		target_buttons.slice(target_buttons.size() / 2) + target_buttons.slice(0, target_buttons.size() / 2)
	)

	for button: Button in selection_order:
		if not button.disabled:
			button.grab_focus.call_deferred()
			break


func show_text(text: String) -> Dialogue:
	battle_dialogue_manager.starting_sequence.text = text
	battle_dialogue.run_dialogue(battle_dialogue_manager)
	return battle_dialogue


func show_selection_text(text: String) -> Dialogue:
	selection_dialogue_manager.starting_sequence.text = text
	selection_dialogue.run_dialogue(selection_dialogue_manager)
	return selection_dialogue


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if current_screen == Screens.BASE and base_cancel_button.visible:
			base_cancel_button.pressed.emit()
		elif current_screen == Screens.FIGHT:
			fight_cancel_button.pressed.emit()
